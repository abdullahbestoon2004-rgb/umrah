import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_model.dart';
import '../models/offer_model.dart';
import '../models/booking_model.dart';
import '../models/user_profile.dart';

/// All backend access goes through this interface so tests can fake it.
abstract class DataService {
  bool get isSignedIn;
  Future<UserProfile?> restoreSession();
  Future<String?> signIn(String email, String password);
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    String phone,
    String role,
  });
  Future<void> signOut();

  Future<List<Company>> fetchCompanies();
  Future<List<Offer>> fetchOffers(List<Company> companies);
  Future<Company?> fetchMyCompany(String ownerId);
  Future<Company?> createCompany({
    required String ownerId,
    required String name,
    required String location,
  });
  Future<String?> updateCompany(String id, {String? location, String? about, List<String>? tags});

  Future<Offer?> createPackage(Map<String, dynamic> fields, List<ItineraryDay> itinerary, Company company);
  Future<String?> updatePackage(String id, Map<String, dynamic> fields, List<ItineraryDay> itinerary);
  Future<String?> deletePackage(String id);
  Future<String?> uploadPackageImage(String packageId, Uint8List bytes);

  Future<List<Booking>> fetchMyBookings(String clientId);
  Future<String?> createBooking({
    required String packageId,
    required String clientId,
    required int travellers,
    required String payMethod,
    DateTime? departureDate,
    String? contactPhone,
  });
  Future<String?> cancelBooking(String id);
}

class SupabaseService implements DataService {
  SupabaseClient get _c => Supabase.instance.client;

  @override
  bool get isSignedIn => _c.auth.currentSession != null;

  // ── auth ──────────────────────────────────────────────────────────────────

  Future<UserProfile?> _profileFor(User user) async {
    try {
      final row = await _c.from('profiles').select().eq('id', user.id).maybeSingle();
      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        role: (row?['role'] ?? 'client') as String,
        fullName: (row?['full_name'] ?? '') as String,
        phone: (row?['phone'] ?? '') as String,
      );
    } catch (_) {
      return UserProfile(id: user.id, email: user.email ?? '', role: 'client');
    }
  }

  @override
  Future<UserProfile?> restoreSession() async {
    final user = _c.auth.currentUser;
    if (user == null) return null;
    return _profileFor(user);
  }

  @override
  Future<String?> signIn(String email, String password) async {
    try {
      await _c.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    String phone = '',
    String role = 'client',
  }) async {
    try {
      final res = await _c.auth.signUp(email: email, password: password, data: {
        'role': role,
        'full_name': fullName,
        'phone': phone,
      });
      if (res.session == null) {
        return 'confirm-email'; // project has email confirmation enabled
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<void> signOut() => _c.auth.signOut();

  // ── companies & packages ─────────────────────────────────────────────────

  @override
  Future<List<Company>> fetchCompanies() async {
    final rows = await _c.from('companies').select().eq('is_active', true).order('rating', ascending: false);
    return rows.map((r) => Company.fromRow(r)).where((c) => c.isVerified).toList();
  }

  @override
  Future<List<Offer>> fetchOffers(List<Company> companies) async {
    final rows = await _c
        .from('packages')
        .select('*, itinerary_days(*)')
        .eq('is_published', true)
        .order('created_at', ascending: false);
    final byId = {for (final c in companies) c.id: c};
    return rows.map((r) => Offer.fromRow(r, company: byId[r['company_id']])).toList();
  }

  @override
  Future<Company?> fetchMyCompany(String ownerId) async {
    final row = await _c.from('companies').select().eq('owner_id', ownerId).maybeSingle();
    return row == null ? null : Company.fromRow(row);
  }

  @override
  Future<Company?> createCompany({
    required String ownerId,
    required String name,
    required String location,
  }) async {
    try {
      final row = await _c
          .from('companies')
          .insert({'owner_id': ownerId, 'name': name, 'name_en': name, 'location': location})
          .select()
          .single();
      return Company.fromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> updateCompany(String id, {String? location, String? about, List<String>? tags}) async {
    try {
      await _c.from('companies').update({
        if (location != null) 'location': location,
        if (about != null) 'about': about,
        if (tags != null) 'tags': tags,
      }).eq('id', id);
      return null;
    } on PostgrestException catch (e) {
      // about/tags columns come from patches.sql; retry with location only
      if (e.code == 'PGRST204' && location != null) {
        try {
          await _c.from('companies').update({'location': location}).eq('id', id);
          return null;
        } catch (e2) {
          return e2.toString();
        }
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<Offer?> createPackage(
      Map<String, dynamic> fields, List<ItineraryDay> itinerary, Company company) async {
    try {
      final row = await _c.from('packages').insert(fields).select('*, itinerary_days(*)').single();
      final id = row['id'] as String;
      await _replaceItinerary(id, itinerary);
      final fresh = await _c.from('packages').select('*, itinerary_days(*)').eq('id', id).single();
      return Offer.fromRow(fresh, company: company);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> updatePackage(String id, Map<String, dynamic> fields, List<ItineraryDay> itinerary) async {
    try {
      await _c.from('packages').update(fields).eq('id', id);
      await _replaceItinerary(id, itinerary);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _replaceItinerary(String packageId, List<ItineraryDay> itinerary) async {
    await _c.from('itinerary_days').delete().eq('package_id', packageId);
    if (itinerary.isEmpty) return;
    await _c.from('itinerary_days').insert([
      for (var i = 0; i < itinerary.length; i++)
        {
          'package_id': packageId,
          'day_no': i + 1,
          'title': itinerary[i].title,
          'summary': itinerary[i].summary,
        }
    ]);
  }

  @override
  Future<String?> deletePackage(String id) async {
    try {
      await _c.from('packages').delete().eq('id', id);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> uploadPackageImage(String packageId, Uint8List bytes) async {
    try {
      final path = '$packageId.jpg';
      await _c.storage.from('package-images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final url = _c.storage.from('package-images').getPublicUrl(path);
      await _c.from('packages').update({'image_url': url}).eq('id', packageId);
      return url;
    } catch (_) {
      return null; // bucket not created yet (see supabase/patches.sql)
    }
  }

  // ── bookings ─────────────────────────────────────────────────────────────

  static const _bookingSelect =
      '*, packages(title,title_ar,title_en), companies(name,name_ar,name_en,tint)';

  @override
  Future<List<Booking>> fetchMyBookings(String clientId) async {
    final rows = await _c
        .from('bookings')
        .select(_bookingSelect)
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return rows.map((r) => Booking.fromRow(r)).toList();
  }

  @override
  Future<String?> createBooking({
    required String packageId,
    required String clientId,
    required int travellers,
    required String payMethod,
    DateTime? departureDate,
    String? contactPhone,
  }) async {
    try {
      final note = departureDate == null
          ? null
          : 'dep:${departureDate.toIso8601String().substring(0, 10)}';
      await _c.from('bookings').insert({
        'package_id': packageId,
        'client_id': clientId,
        'travellers': travellers,
        'pay_method': payMethod,
        if (contactPhone != null && contactPhone.isNotEmpty) 'contact_phone': contactPhone,
        if (note != null) 'note': note,
        // company_id / prices / commission are filled by the DB trigger
        'company_id': '00000000-0000-0000-0000-000000000000',
        'unit_price_iqd': 0,
        'total_iqd': 0,
        'commission_iqd': 0,
        'payout_iqd': 0,
      });
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> cancelBooking(String id) async {
    try {
      final rows =
          await _c.from('bookings').update({'status': 'cancelled'}).eq('id', id).select('id');
      if (rows.isEmpty) {
        return 'rls'; // no row updated — client cancel policy missing (patches.sql)
      }
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
