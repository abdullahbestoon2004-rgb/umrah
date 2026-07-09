import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_model.dart';
import '../models/offer_model.dart';
import '../models/booking_model.dart';
import '../models/user_profile.dart';
import '../models/home_ad_model.dart';
import '../models/notification_model.dart';
import '../models/commission_model.dart';
import '../models/support_message_model.dart';

/// Account-wide preferences that follow the user across devices
/// (as opposed to the biometric lock, which is deliberately per-device).
class AccountPrefs {
  final bool marketingEmails;
  final bool shareActivity;
  final String preferredPayMethod; // 'cash' | 'card' | 'fib'
  const AccountPrefs({
    this.marketingEmails = true,
    this.shareActivity = false,
    this.preferredPayMethod = 'cash',
  });
}

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
    String? companyName,
    String? companyLocation,
    String? companyAbout,
    int? companySince,
  });
  Future<void> signOut();
  Future<String?> updateProfile(String userId, {String? fullName, String? phone});
  Future<String?> updateEmail(String newEmail);
  /// Re-authenticates the user by verifying their current password.
  /// Returns null on success, or an error message on failure.
  Future<String?> reauthenticate(String email, String password);
  Future<String?> changePassword(String newPassword);
  /// Permanently deletes the auth user (and everything that cascades from it).
  Future<String?> deleteAccount();

  Future<List<Company>> fetchCompanies();
  Future<List<Offer>> fetchOffers(List<Company> companies);
  Future<Company?> fetchMyCompany(String ownerId);
  Future<Company?> createCompany({
    required String ownerId,
    required String name,
    required String location,
    String about,
    int? since,
  });
  /// Fetches the agency's company, creating it from the sign-up metadata
  /// if it doesn't exist yet — covers the case where email confirmation
  /// delayed the first session past the original sign-up call.
  Future<Company?> ensureAgencyCompany(String ownerId);
  Future<String?> updateCompany(String id,
      {String? location, String? about, List<String>? tags, int? since});
  Future<String?> uploadCompanyLogo(String companyId, Uint8List bytes);
  Future<String?> uploadCompanyBanner(String companyId, Uint8List bytes);

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

  // ── account sync ────────────────────────────────────────────────────────
  Future<Set<String>> fetchSavedOfferIds(String clientId);
  Future<void> saveOfferRemote(String clientId, String packageId);
  Future<void> unsaveOfferRemote(String clientId, String packageId);

  Future<AccountPrefs> fetchAccountPrefs(String clientId);
  Future<void> updateAccountPrefs(String clientId, {
    bool? marketingEmails,
    bool? shareActivity,
    String? preferredPayMethod,
  });

  // ── home ads & admin ────────────────────────────────────────────────────
  Future<List<HomeAd>> fetchHomeAds();
  Future<HomeAd?> createHomeAd({
    required String title,
    String? packageId,
    String? companyId,
  });
  Future<String?> updateHomeAd(String id, {String? title, bool? isActive});
  Future<String?> deleteHomeAd(String id);
  Future<String?> uploadAdImage(String adId, Uint8List bytes);

  Future<List<Company>> fetchPendingCompanies();
  Future<String?> setCompanyVerified(String id, bool verified);
  Future<String?> setPackageFeatured(String id, bool featured);

  // ── notifications ────────────────────────────────────────────────────────
  Future<List<AppNotification>> fetchNotifications(String userId);
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead(String userId);
  Future<void> clearNotifications(String userId);

  // ── agency booking management ────────────────────────────────────────────
  Future<List<Booking>> fetchCompanyBookings(String companyId);
  Future<String?> setBookingStatus(String bookingId, String status);

  // ── commissions (what each agency owes the platform) ────────────────────
  /// Pass a companyId to scope to one agency; omit for the admin's full ledger.
  Future<List<Commission>> fetchCommissions({String? companyId});
  Future<String?> setCommissionCollected(String id);

  // ── support ───────────────────────────────────────────────────────────────
  Future<String?> sendSupportMessage({String? userId, String? email, required String message});
  Future<List<SupportMessage>> fetchSupportMessages();

  // ── reviews ───────────────────────────────────────────────────────────────
  Future<String?> createReview({
    required String bookingId,
    required String companyId,
    required String clientId,
    required int rating,
    String comment,
  });
  Future<Set<String>> fetchReviewedBookingIds(String clientId);

  // ── password reset (OTP-code, no deep-linking required) ─────────────────
  Future<String?> sendPasswordResetCode(String email);
  Future<String?> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  });

  // ── error logging (best-effort, never throws) ────────────────────────────
  Future<void> logError({String? userId, required String message, String? stack, String? context});
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
    String? companyName,
    String? companyLocation,
    String? companyAbout,
    int? companySince,
  }) async {
    try {
      final res = await _c.auth.signUp(email: email, password: password, data: {
        'role': role,
        'full_name': fullName,
        'phone': phone,
        // stashed so the company can still be created once a session exists —
        // e.g. after the user confirms their email and logs in later, when the
        // original sign-up form's values are long gone.
        if (companyName != null) 'company_name': companyName,
        if (companyLocation != null) 'company_location': companyLocation,
        if (companyAbout != null) 'company_about': companyAbout,
        if (companySince != null) 'company_since': companySince,
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

  @override
  Future<String?> updateProfile(String userId, {String? fullName, String? phone}) async {
    try {
      await _c.from('profiles').update({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
      }).eq('id', userId);
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> updateEmail(String newEmail) async {
    try {
      await _c.auth.updateUser(UserAttributes(email: newEmail));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> reauthenticate(String email, String password) async {
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
  Future<String?> changePassword(String newPassword) async {
    try {
      await _c.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> deleteAccount() async {
    try {
      // security-definer RPC (see supabase/patches.sql) — a client can't
      // delete its own auth.users row directly
      await _c.rpc('delete_my_account');
      // the auth user is already gone, so revoking the session may 4xx —
      // that must not surface as a deletion failure
      try {
        await _c.auth.signOut();
      } catch (_) {}
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

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
    String about = '',
    int? since,
  }) async {
    try {
      final row = await _c
          .from('companies')
          .insert({
            'owner_id': ownerId,
            'name': name,
            'name_en': name,
            'location': location,
            if (about.isNotEmpty) 'about': about,
            if (since != null) 'since': since,
          })
          .select()
          .single();
      return Company.fromRow(row);
    } on PostgrestException catch (e) {
      // 'about' column comes from patches.sql; retry without it
      if (e.code == 'PGRST204' && about.isNotEmpty) {
        return createCompany(ownerId: ownerId, name: name, location: location, since: since);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Company?> ensureAgencyCompany(String ownerId) async {
    final existing = await fetchMyCompany(ownerId);
    if (existing != null) return existing;
    final meta = _c.auth.currentUser?.userMetadata;
    final name = (meta?['company_name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;
    final location = (meta?['company_location'] as String?)?.trim() ?? '';
    final about = (meta?['company_about'] as String?)?.trim() ?? '';
    final since = (meta?['company_since'] as num?)?.toInt();
    return createCompany(
        ownerId: ownerId, name: name, location: location, about: about, since: since);
  }

  @override
  Future<String?> updateCompany(String id,
      {String? location, String? about, List<String>? tags, int? since}) async {
    try {
      await _c.from('companies').update({
        if (location != null) 'location': location,
        if (about != null) 'about': about,
        if (tags != null) 'tags': tags,
        if (since != null) 'since': since,
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

  @override
  Future<String?> uploadCompanyLogo(String companyId, Uint8List bytes) async {
    try {
      // lives in the existing package-images bucket (logos/ prefix) so no
      // extra storage setup is needed beyond patches.sql
      final path = 'logos/$companyId.jpg';
      await _c.storage.from('package-images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      // version param busts image caches when the logo is replaced in place
      final url =
          '${_c.storage.from('package-images').getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
      await _c.from('companies').update({'logo_url': url}).eq('id', companyId);
      return url;
    } catch (e) {
      print('uploadCompanyLogo error: $e');
      return null; // bucket not created yet (see supabase/patches.sql)
    }
  }

  @override
  Future<String?> uploadCompanyBanner(String companyId, Uint8List bytes) async {
    try {
      final path = 'banners/$companyId.jpg';
      await _c.storage.from('package-images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final url =
          '${_c.storage.from('package-images').getPublicUrl(path)}?v=${DateTime.now().millisecondsSinceEpoch}';
      await _c.from('companies').update({'banner_url': url}).eq('id', companyId);
      return url;
    } catch (e) {
      print('uploadCompanyBanner error: $e');
      return null;
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

  // ── account sync ─────────────────────────────────────────────────────────
  // Every method here degrades gracefully (empty/no-op) if
  // supabase/patches_account_sync.sql hasn't been run yet, so the app still
  // works — saves and cards just won't follow the account until it has.

  @override
  Future<Set<String>> fetchSavedOfferIds(String clientId) async {
    try {
      final rows = await _c.from('saved_offers').select('package_id').eq('client_id', clientId);
      return rows.map((r) => r['package_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> saveOfferRemote(String clientId, String packageId) async {
    try {
      await _c.from('saved_offers').insert({'client_id': clientId, 'package_id': packageId});
    } catch (_) {}
  }

  @override
  Future<void> unsaveOfferRemote(String clientId, String packageId) async {
    try {
      await _c.from('saved_offers').delete().eq('client_id', clientId).eq('package_id', packageId);
    } catch (_) {}
  }

  @override
  Future<AccountPrefs> fetchAccountPrefs(String clientId) async {
    try {
      final row = await _c
          .from('profiles')
          .select('marketing_emails, share_activity, preferred_pay_method')
          .eq('id', clientId)
          .maybeSingle();
      if (row == null) return const AccountPrefs();
      return AccountPrefs(
        marketingEmails: (row['marketing_emails'] ?? true) as bool,
        shareActivity: (row['share_activity'] ?? false) as bool,
        preferredPayMethod: (row['preferred_pay_method'] ?? 'cash') as String,
      );
    } catch (_) {
      return const AccountPrefs();
    }
  }

  @override
  Future<void> updateAccountPrefs(String clientId, {
    bool? marketingEmails,
    bool? shareActivity,
    String? preferredPayMethod,
  }) async {
    try {
      await _c.from('profiles').update({
        if (marketingEmails != null) 'marketing_emails': marketingEmails,
        if (shareActivity != null) 'share_activity': shareActivity,
        if (preferredPayMethod != null) 'preferred_pay_method': preferredPayMethod,
      }).eq('id', clientId);
    } catch (_) {}
  }

  // ── home ads & admin ──────────────────────────────────────────────────────
  // All graceful if patches_admin.sql hasn't been run yet.

  @override
  Future<List<HomeAd>> fetchHomeAds() async {
    try {
      final rows = await _c
          .from('home_ads')
          .select()
          .order('sort_order')
          .order('created_at', ascending: false);
      return rows.map((r) => HomeAd.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<HomeAd?> createHomeAd({
    required String title,
    String? packageId,
    String? companyId,
  }) async {
    try {
      final row = await _c.from('home_ads').insert({
        'title': title,
        if (packageId != null) 'package_id': packageId,
        if (companyId != null) 'company_id': companyId,
      }).select().single();
      return HomeAd.fromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> updateHomeAd(String id, {String? title, bool? isActive}) async {
    try {
      await _c.from('home_ads').update({
        if (title != null) 'title': title,
        if (isActive != null) 'is_active': isActive,
      }).eq('id', id);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> deleteHomeAd(String id) async {
    try {
      await _c.from('home_ads').delete().eq('id', id);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> uploadAdImage(String adId, Uint8List bytes) async {
    try {
      final path = 'ads/$adId.jpg';
      await _c.storage.from('package-images').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final url = _c.storage.from('package-images').getPublicUrl(path);
      await _c.from('home_ads').update({'image_url': url}).eq('id', adId);
      return url;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Company>> fetchPendingCompanies() async {
    try {
      final rows = await _c
          .from('companies')
          .select()
          .eq('is_verified', false)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return rows.map((r) => Company.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<String?> setCompanyVerified(String id, bool verified) async {
    try {
      final rows = await _c
          .from('companies')
          .update({'is_verified': verified})
          .eq('id', id)
          .select('id');
      return rows.isEmpty ? 'rls' : null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> setPackageFeatured(String id, bool featured) async {
    try {
      final rows = await _c
          .from('packages')
          .update({'is_featured': featured})
          .eq('id', id)
          .select('id');
      return rows.isEmpty ? 'rls' : null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── notifications ────────────────────────────────────────────────────────

  @override
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    try {
      final rows = await _c
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      final out = <AppNotification>[];
      for (final r in rows) {
        try {
          out.add(AppNotification.fromRow(r));
        } catch (_) {
          // unrecognized type — ignore rather than break the whole list
        }
      }
      return out;
    } catch (_) {
      return []; // table not created yet (see supabase/patches.sql)
    }
  }

  @override
  Future<void> markNotificationRead(String id) async {
    try {
      await _c.from('notifications').update({'read': true}).eq('id', id);
    } catch (_) {}
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    try {
      await _c.from('notifications').update({'read': true}).eq('user_id', userId).eq('read', false);
    } catch (_) {}
  }

  @override
  Future<void> clearNotifications(String userId) async {
    try {
      await _c.from('notifications').delete().eq('user_id', userId);
    } catch (_) {}
  }

  // ── agency booking management ────────────────────────────────────────────

  @override
  Future<List<Booking>> fetchCompanyBookings(String companyId) async {
    try {
      final rows = await _c
          .from('bookings')
          .select(_bookingSelect)
          .eq('company_id', companyId)
          .order('created_at', ascending: false);
      return rows.map((r) => Booking.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<String?> setBookingStatus(String bookingId, String status) async {
    try {
      final rows = await _c
          .from('bookings')
          .update({'status': status})
          .eq('id', bookingId)
          .select('id');
      return rows.isEmpty ? 'rls' : null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── commissions ──────────────────────────────────────────────────────────

  @override
  Future<List<Commission>> fetchCommissions({String? companyId}) async {
    try {
      var query = _c.from('commissions').select('*, companies(name,name_ar,name_en)');
      if (companyId != null) query = query.eq('company_id', companyId);
      final rows = await query.order('created_at', ascending: false);
      return rows.map((r) => Commission.fromRow(r)).toList();
    } catch (_) {
      return []; // table not created yet (see supabase/schema.sql)
    }
  }

  @override
  Future<String?> setCommissionCollected(String id) async {
    try {
      await _c.from('commissions').update({
        'status': 'collected',
        'collected_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── support ───────────────────────────────────────────────────────────────

  @override
  Future<String?> sendSupportMessage({String? userId, String? email, required String message}) async {
    try {
      await _c.from('support_messages').insert({
        if (userId != null) 'user_id': userId,
        if (email != null) 'email': email,
        'message': message,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<List<SupportMessage>> fetchSupportMessages() async {
    try {
      final rows = await _c.from('support_messages').select().order('created_at', ascending: false);
      return rows.map((r) => SupportMessage.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── reviews ───────────────────────────────────────────────────────────────

  @override
  Future<String?> createReview({
    required String bookingId,
    required String companyId,
    required String clientId,
    required int rating,
    String comment = '',
  }) async {
    try {
      await _c.from('reviews').insert({
        'booking_id': bookingId,
        'company_id': companyId,
        'client_id': clientId,
        'rating': rating,
        'comment': comment,
      });
      return null;
    } on PostgrestException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<Set<String>> fetchReviewedBookingIds(String clientId) async {
    try {
      final rows = await _c.from('reviews').select('booking_id').eq('client_id', clientId);
      return rows.map((r) => r['booking_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  // ── password reset ───────────────────────────────────────────────────────

  @override
  Future<String?> sendPasswordResetCode(String email) async {
    try {
      await _c.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _c.auth.verifyOTP(email: email, token: code, type: OtpType.recovery);
      await _c.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ── error logging ────────────────────────────────────────────────────────

  @override
  Future<void> logError({String? userId, required String message, String? stack, String? context}) async {
    try {
      await _c.from('error_logs').insert({
        if (userId != null) 'user_id': userId,
        'message': message,
        if (stack != null) 'stack': stack,
        if (context != null) 'context': context,
      });
    } catch (_) {
      // logging must never throw — worst case we just lose this one report
    }
  }
}
