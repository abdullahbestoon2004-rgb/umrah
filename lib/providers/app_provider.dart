import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer_model.dart';
import '../models/booking_model.dart';
import '../models/company_model.dart';
import '../models/notification_model.dart';
import '../models/home_ad_model.dart';
import '../models/user_profile.dart';
import '../models/commission_model.dart';
import '../models/support_message_model.dart';
import '../models/review_model.dart';
import '../models/inquiry_model.dart';
import '../models/agency_document_model.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/biometric_service.dart';
import '../theme/app_theme.dart';

class OfferFilters {
  final String transport;
  final String acc;
  final String dur;
  final double rating;
  final double priceMax;
  final String sort;

  static const double priceCeiling = 5000000; // IQD

  const OfferFilters({
    this.transport = 'all',
    this.acc = 'all',
    this.dur = 'all',
    this.rating = 0,
    this.priceMax = priceCeiling,
    this.sort = 'popular',
  });

  OfferFilters copyWith({
    String? transport,
    String? acc,
    String? dur,
    double? rating,
    double? priceMax,
    String? sort,
  }) => OfferFilters(
    transport: transport ?? this.transport,
    acc: acc ?? this.acc,
    dur: dur ?? this.dur,
    rating: rating ?? this.rating,
    priceMax: priceMax ?? this.priceMax,
    sort: sort ?? this.sort,
  );

  OfferFilters reset() => const OfferFilters();

  bool get hasActiveFilters =>
      transport != 'all' ||
      acc != 'all' ||
      dur != 'all' ||
      rating > 0 ||
      priceMax < priceCeiling;

  int get activeCount {
    int c = 0;
    if (transport != 'all') c++;
    if (acc != 'all') c++;
    if (dur != 'all') c++;
    if (rating > 0) c++;
    if (priceMax < priceCeiling) c++;
    return c;
  }
}

class AppProvider extends ChangeNotifier {
  AppProvider({DataService? service, bool autoLoad = true})
    : _service = service ?? SupabaseService() {
    AppTheme.isArabicScript = _locale.languageCode != 'en';
    if (autoLoad) init();
  }

  final DataService _service;
  SharedPreferences? _prefs;
  final List<RealtimeChannel> _realtimeChannels = [];
  bool _realtimeRefreshScheduled = false;

  bool _needsPasswordReset = false;
  bool get needsPasswordReset => _needsPasswordReset;
  set needsPasswordReset(bool value) {
    _needsPasswordReset = value;
    notifyListeners();
  }

  Future<void> init() async {
    await _loadPrefs();
    await loadData();
    await restoreAuth();
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          _needsPasswordReset = true;
          notifyListeners();
        }
      });
    } catch (_) {}
  }

  // ── persisted settings ───────────────────────────────────────────────────
  Future<void> _loadPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      return; // plugin unavailable (e.g. in tests) — run without persistence
    }
    final p = _prefs!;
    final lang = p.getString('locale');
    if (lang != null) {
      _locale = Locale(lang);
      AppTheme.isArabicScript = lang != 'en';
    }
    _saved
      ..clear()
      ..addAll(p.getStringList('saved') ?? const []);
    biometricLock = p.getBool('biometric') ?? false;
    marketingEmails = p.getBool('marketing') ?? true;
    shareActivity = p.getBool('activity') ?? false;
    preferredPayMethod = p.getString('payMethod') ?? 'cash';
    _restoreLocalNotifications(p);
    if (biometricLock && BiometricService.isSupported) _locked = true;
    notifyListeners();
  }

  // ── biometric app lock ───────────────────────────────────────────────────
  bool _locked = false;
  bool get locked => _locked;

  Future<bool> unlock(String reason) async {
    final ok = await BiometricService.authenticate(reason);
    if (ok) {
      _locked = false;
      notifyListeners();
    }
    return ok;
  }

  // ── remote data ──────────────────────────────────────────────────────────
  List<Company> _companies = [];
  List<Offer> _offers = [];
  bool _loading = true;
  bool _loadFailed = false;

  bool get isLoading => _loading;
  bool get loadFailed => _loadFailed;
  List<Company> get companies => List.unmodifiable(_companies);
  List<Offer> get allOffers => List.unmodifiable(_offers);

  Future<void> loadData() async {
    _loading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      _companies = await _service.fetchCompanies();
      _offers = isAdminUser
          ? await _service.fetchAdminPackages(_companies)
          : await _service.fetchOffers(_companies);
      _homeAds = await _service.fetchHomeAds();
      _loadFailed = false;
    } catch (error, stackTrace) {
      debugPrint('Failed to load app data: $error');
      debugPrintStack(stackTrace: stackTrace);
      _loadFailed = true;
    }
    _loading = false;
    notifyListeners();
  }

  // ── home ads (paid agency placements, managed by the admin) ─────────────
  List<HomeAd> _homeAds = [];
  List<HomeAd> get homeAds =>
      List.unmodifiable(_homeAds.where((a) => a.isActive));
  List<HomeAd> get allHomeAds => List.unmodifiable(_homeAds); // admin view

  Offer? offerById(String? id) {
    if (id == null) return null;
    for (final o in _offers) {
      if (o.id == id) return o;
    }
    return null;
  }

  // ── tab navigation ───────────────────────────────────────────────────────
  int _currentTab = 0;
  int get currentTab => _currentTab;
  void setTab(int i) {
    _currentTab = i;
    notifyListeners();
  }

  // ── locale ───────────────────────────────────────────────────────────────
  Locale _locale = const Locale('ku'); // Kurdish (Sorani) is the default
  Locale get locale => _locale;
  void setLocale(Locale l) {
    _locale = l;
    AppTheme.isArabicScript = l.languageCode != 'en';
    _prefs?.setString('locale', l.languageCode);
    notifyListeners();
  }

  String get lang => _locale.languageCode;

  // ── auth ─────────────────────────────────────────────────────────────────
  UserProfile? _user;
  Company? _myCompany; // the agency user's own company (may be unverified)

  UserProfile? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isAgencyUser => _user?.isAgency ?? false;
  bool get isAdminUser => _user?.isAdmin ?? false;
  bool get isAgencyLoggedIn => isAgencyUser;
  Company? get agencyCompany => _myCompany;

  Future<void> restoreAuth() async {
    try {
      _user = await _service.restoreSession();
      if (_user != null) {
        if (_user!.isAgency) {
          _myCompany = await _service.ensureAgencyCompany(_user!.id);
          await loadAgencyBookings();
        }
        await refreshBookings();
        await _syncAccountData();
        await _loadRemoteNotifications();
        _startRealtime();
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Pulls everything that belongs to this account down from the backend —
  /// saved trips, payment methods, preferences — and pushes up any saves
  /// made as a guest before signing in, so nothing is lost.
  Future<void> _syncAccountData() async {
    final uid = _user!.id;
    try {
      final remoteSaved = await _service.fetchSavedOfferIds(uid);
      final localOnly = _saved
          .where((id) => !remoteSaved.contains(id))
          .toList();
      for (final id in localOnly) {
        await _service.saveOfferRemote(uid, id);
      }
      _saved
        ..clear()
        ..addAll(remoteSaved)
        ..addAll(localOnly);
      await _prefs?.setStringList('saved', _saved);
    } catch (_) {}

    try {
      final prefs = await _service.fetchAccountPrefs(uid);
      marketingEmails = prefs.marketingEmails;
      shareActivity = prefs.shareActivity;
      preferredPayMethod = prefs.preferredPayMethod;
    } catch (_) {}

    try {
      _reviewedBookingIds
        ..clear()
        ..addAll(await _service.fetchReviewedBookingIds(uid));
    } catch (_) {}
  }

  Future<String?> signIn(String email, String password) async {
    final err = await _service.signIn(email, password);
    if (err != null) return err;
    await restoreAuth();
    return null;
  }

  Future<String?> signUpClient({
    required String email,
    required String password,
    required String fullName,
    String phone = '',
  }) async {
    final err = await _service.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    if (err != null) return err;
    await restoreAuth();
    return null;
  }

  Future<String?> signUpAgency({
    required String email,
    required String password,
    required String fullName,
    required String companyName,
    required String companyLocation,
    String companyAbout = '',
    int? companySince,
    Uint8List? logoBytes,
    String phone = '',
  }) async {
    final err = await _service.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: 'agency',
      companyName: companyName,
      companyLocation: companyLocation,
      companyAbout: companyAbout,
      companySince: companySince,
    );
    if (err != null) return err;
    // restoreAuth's ensureAgencyCompany call creates the company row — it
    // reads the profile fields back from the sign-up metadata, so this also
    // covers the case where email confirmation delays the first session.
    await restoreAuth();
    // The logo can't ride along in metadata; upload it now if we already
    // have a session. With email confirmation on, it's re-added later via
    // the Edit profile screen.
    if (logoBytes != null && _myCompany != null) {
      final url = await _service.uploadCompanyLogo(_myCompany!.id, logoBytes);
      if (url != null) {
        _myCompany!.logoUrl = url;
        notifyListeners();
      }
    }
    return null;
  }

  /// Re-attempts creating the agency's company from sign-up metadata.
  /// Lets a user whose confirmation email arrived after they left the
  /// registration form recover without signing out and back in.
  Future<void> retryAgencyCompany() async {
    if (_user == null || !_user!.isAgency) return;
    _myCompany = await _service.ensureAgencyCompany(_user!.id);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _service.signOut();
    await _clearLocalAccountState();
  }

  /// Clears account-scoped data so it can't leak to the next person who
  /// uses this device — cards, saves, and account prefs all follow the
  /// account, not the device.
  Future<void> _clearLocalAccountState() async {
    await _stopRealtime();
    _user = null;
    _myCompany = null;
    _bookings = [];
    _saved.clear();
    await _prefs?.remove('saved');
    marketingEmails = true;
    shareActivity = false;
    preferredPayMethod = 'cash';
    _reviewedBookingIds.clear();
    _agencyBookings = [];
    _commissions = [];
    _notifications
      ..clear()
      ..add(
        AppNotification(
          id: 'n1',
          type: NotificationType.welcome,
          time: DateTime.now(),
        ),
      );
    _persistLocalNotifications();
    notifyListeners();
  }

  void _startRealtime() {
    final current = _user;
    if (current == null || _realtimeChannels.isNotEmpty) return;
    try {
      final client = Supabase.instance.client;
      final notifications =
          client
              .channel('notifications:${current.id}')
              .onPostgresChanges(
                event: PostgresChangeEvent.all,
                schema: 'public',
                table: 'notifications',
                filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'user_id',
                  value: current.id,
                ),
                callback: (_) => _scheduleRealtimeRefresh('notifications'),
              )
            ..subscribe();
      _realtimeChannels.add(notifications);

      if (current.isAgency && _myCompany != null) {
        final companyId = _myCompany!.id;
        for (final table in const ['bookings', 'inquiries']) {
          final channel =
              client
                  .channel('$table:$companyId')
                  .onPostgresChanges(
                    event: PostgresChangeEvent.all,
                    schema: 'public',
                    table: table,
                    filter: PostgresChangeFilter(
                      type: PostgresChangeFilterType.eq,
                      column: table == 'bookings' ? 'company_id' : 'agency_id',
                      value: companyId,
                    ),
                    callback: (_) => _scheduleRealtimeRefresh(table),
                  )
                ..subscribe();
          _realtimeChannels.add(channel);
        }
        final messages =
            client
                .channel('inquiry_messages:$companyId')
                .onPostgresChanges(
                  event: PostgresChangeEvent.all,
                  schema: 'public',
                  table: 'inquiry_messages',
                  callback: (_) => _scheduleRealtimeRefresh('inquiries'),
                )
              ..subscribe();
        _realtimeChannels.add(messages);
      } else if (current.isAdmin) {
        for (final table in const [
          'companies',
          'packages',
          'bookings',
          'agency_reports',
          'carousel_requests',
        ]) {
          final channel =
              client
                  .channel('admin:$table')
                  .onPostgresChanges(
                    event: PostgresChangeEvent.all,
                    schema: 'public',
                    table: table,
                    callback: (_) => _scheduleRealtimeRefresh('admin'),
                  )
                ..subscribe();
          _realtimeChannels.add(channel);
        }
      }
    } catch (_) {
      // Realtime is an enhancement; pull-to-refresh remains available.
    }
  }

  void _scheduleRealtimeRefresh(String scope) {
    if (_realtimeRefreshScheduled) return;
    _realtimeRefreshScheduled = true;
    Future<void>.delayed(const Duration(milliseconds: 250), () async {
      _realtimeRefreshScheduled = false;
      if (_user == null) return;
      if (scope == 'notifications') await _loadRemoteNotifications();
      if (_user!.isAdmin) {
        await loadAdminData();
      } else if (_user!.isAgency) {
        await loadAgencyBookings();
        await loadAgencyInquiries();
      } else {
        await refreshBookings();
      }
    });
  }

  Future<void> _stopRealtime() async {
    try {
      final client = Supabase.instance.client;
      for (final channel in _realtimeChannels) {
        await client.removeChannel(channel);
      }
    } catch (_) {}
    _realtimeChannels.clear();
  }

  @override
  void dispose() {
    _stopRealtime();
    super.dispose();
  }

  Future<String?> updateAccountDetails({
    String? fullName,
    String? phone,
  }) async {
    if (_user == null) return null;
    final err = await _service.updateProfile(
      _user!.id,
      fullName: fullName,
      phone: phone,
    );
    if (err != null) return err;
    if (fullName != null) _user!.fullName = fullName;
    if (phone != null) _user!.phone = phone;
    notifyListeners();
    return null;
  }

  Future<String?> updateEmail(String newEmail) async {
    if (_user == null) return null;
    final err = await _service.updateEmail(newEmail);
    // Supabase will send a confirmation email. We don't update local state
    // until the user confirms and the session is refreshed.
    return err;
  }

  /// Re-authenticates the user without changing local state.
  /// Used before sensitive operations like email change.
  Future<String?> reauthenticate(String password) async {
    if (_user == null) return 'No user';
    return _service.reauthenticate(_user!.email, password);
  }

  Future<String?> changePassword(String newPassword) =>
      _service.changePassword(newPassword);

  Future<String?> deleteAccount() async {
    final err = await _service.deleteAccount();
    if (err != null) return err;
    await _clearLocalAccountState();
    return null;
  }

  Future<void> agencyLogout() => signOut();

  // ── admin ─────────────────────────────────────────────────────────────────
  List<Company> _pendingCompanies = [];
  List<Company> get pendingCompanies => List.unmodifiable(_pendingCompanies);
  List<Booking> _adminBookings = [];
  List<Booking> get adminBookings => List.unmodifiable(_adminBookings);
  final Map<String, List<AgencyDocument>> _agencyDocuments = {};

  List<AgencyDocument> documentsForAgency(String companyId) =>
      List.unmodifiable(_agencyDocuments[companyId] ?? const []);

  Future<void> loadAgencyDocuments(String companyId) async {
    _agencyDocuments[companyId] = await _service.fetchAgencyDocuments(
      companyId,
    );
    notifyListeners();
  }

  Future<void> loadAdminData() async {
    if (!isAdminUser) return;
    try {
      _pendingCompanies = await _service.fetchPendingCompanies();
      _homeAds = await _service.fetchHomeAds();
      // Refresh the catalog too so the overview metrics (agencies, packages,
      // featured) stay accurate on pull-to-refresh, without flipping the
      // global _loading flag the way loadData() would.
      _companies = await _service.fetchCompanies();
      _offers = await _service.fetchAdminPackages(_companies);
      _adminBookings = await _service.fetchAllBookings();
    } catch (_) {}
    await loadCommissions();
    await loadSupportMessages();
    notifyListeners();
  }

  Future<bool> approveCompany(String id) async {
    final err = await _service.setCompanyVerified(id, true);
    if (err != null) return false;
    _pendingCompanies = _pendingCompanies.where((c) => c.id != id).toList();
    await loadData(); // newly verified agency becomes publicly visible
    notifyListeners();
    return true;
  }

  Future<String?> submitCompanyForReview() async {
    final company = _myCompany;
    if (company == null) return 'Company not found';
    final err = await _service.submitCompanyApplication(company.id);
    if (err == null && _user != null) {
      _myCompany = await _service.fetchMyCompany(_user!.id);
      notifyListeners();
    }
    return err;
  }

  Future<String?> reviewCompany(
    String id,
    String decision, {
    String? reason,
  }) async {
    final err = await _service.reviewCompanyApplication(
      id,
      decision,
      reason: reason,
    );
    if (err == null) await loadAdminData();
    return err;
  }

  Future<bool> declineCompany(String id) async {
    final err = await _service.setCompanyVerified(id, false);
    if (err != null) return false;
    _pendingCompanies = _pendingCompanies.where((c) => c.id != id).toList();
    notifyListeners();
    return true;
  }

  Future<bool> createHomeAd({
    required String title,
    String? packageId,
    String? companyId,
    Uint8List? imageBytes,
  }) async {
    final offer = offerById(packageId);
    final ad = await _service.createHomeAd(
      title: title,
      packageId: packageId,
      companyId: companyId ?? offer?.companyId,
    );
    if (ad == null) return false;
    if (imageBytes != null) {
      await _service.uploadAdImage(ad.id, imageBytes);
    }
    _homeAds = await _service.fetchHomeAds();
    notifyListeners();
    return true;
  }

  Future<bool> setAdActive(String id, bool active) async {
    final err = await _service.updateHomeAd(id, isActive: active);
    if (err != null) return false;
    _homeAds = [
      for (final a in _homeAds)
        a.id == id
            ? HomeAd(
                id: a.id,
                companyId: a.companyId,
                packageId: a.packageId,
                title: a.title,
                titleAr: a.titleAr,
                titleEn: a.titleEn,
                imageUrl: a.imageUrl,
                sortOrder: a.sortOrder,
                isActive: active,
              )
            : a,
    ];
    notifyListeners();
    return true;
  }

  Future<bool> deleteHomeAd(String id) async {
    final err = await _service.deleteHomeAd(id);
    if (err != null) return false;
    _homeAds = _homeAds.where((a) => a.id != id).toList();
    notifyListeners();
    return true;
  }

  Future<bool> setOfferFeatured(String id, bool featured) async {
    final err = await _service.setPackageFeatured(id, featured);
    if (err != null) return false;
    await loadData();
    return true;
  }

  Future<bool> setCompanyPromoted(String id, bool promoted) async {
    final err = await _service.setCompanyPromoted(id, promoted);
    if (err != null) return false;
    await loadData();
    return true;
  }

  Future<bool> setAgencyBadge(
    String agencyId,
    String badgeKey,
    bool enabled,
  ) async {
    final error = await _service.setAgencyBadge(agencyId, badgeKey, enabled);
    if (error != null) return false;
    await loadAdminData();
    return true;
  }

  // ── saved trips (local, per device) ──────────────────────────────────────
  final List<String> _saved = [];
  List<String> get saved => List.unmodifiable(_saved);

  bool isSaved(String offerId) => _saved.contains(offerId);

  void toggleSave(String offerId) {
    final nowSaved = !_saved.contains(offerId);
    nowSaved ? _saved.add(offerId) : _saved.remove(offerId);
    _prefs?.setStringList('saved', _saved);
    notifyListeners();
    // Guests keep saves locally only (there's no account to attach them to);
    // once signed in this follows the account instead.
    if (_user != null) {
      nowSaved
          ? _service.saveOfferRemote(_user!.id, offerId)
          : _service.unsaveOfferRemote(_user!.id, offerId);
    }
  }

  List<Offer> get savedOffers =>
      _offers.where((o) => _saved.contains(o.id)).toList();

  // ── filters ──────────────────────────────────────────────────────────────
  OfferFilters _filters = const OfferFilters();
  OfferFilters get filters => _filters;
  void updateFilters(OfferFilters f) {
    _filters = f;
    notifyListeners();
  }

  void resetFilters() {
    _filters = const OfferFilters();
    notifyListeners();
  }

  // ── search ───────────────────────────────────────────────────────────────
  List<Offer> searchOffers(String q) {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    bool hit(String? s) => (s ?? '').toLowerCase().contains(lower);
    return _offers.where((o) {
      final company = companyById(o.companyId);
      return hit(o.title) ||
          hit(o.titleAr) ||
          hit(o.titleEn) ||
          hit(o.city) ||
          hit(o.hotel) ||
          hit(o.badge) ||
          hit(company?.name) ||
          hit(company?.nameAr) ||
          hit(company?.nameEn);
    }).toList();
  }

  /// Suggestion chips built from real data so every chip returns results.
  List<String> get searchSuggestions {
    final seen = <String>{};
    final out = <String>[];
    void add(String s) {
      final key = s.trim().toLowerCase();
      if (key.isNotEmpty && seen.add(key)) out.add(s.trim());
    }

    for (final o in _offers) {
      add(o.badge);
    }
    for (final o in _offers) {
      add(o.hotel);
    }
    for (final c in _companies.take(3)) {
      add(c.nameFor(lang));
    }
    return out.take(10).toList();
  }

  // ── offer images (local preview for freshly picked covers) ──────────────
  final Map<String, Uint8List> _offerImages = {};
  Uint8List? getOfferImage(String id) => _offerImages[id];
  void setOfferImage(String id, Uint8List bytes) {
    _offerImages[id] = bytes;
    notifyListeners();
  }

  void removeOfferImage(String id) {
    _offerImages.remove(id);
    notifyListeners();
  }

  // ── offers (agency CRUD against the backend) ─────────────────────────────
  Map<String, dynamic> _pkgFields(Offer o) => {
    'company_id': o.companyId,
    'title': o.title,
    'title_ar': o.titleAr,
    'title_en': o.titleEn,
    'overview': o.overview.isEmpty ? null : o.overview,
    'price_iqd': o.price.round(),
    'original_iqd': o.original > 0 ? o.original.round() : null,
    'days': o.days,
    'nights': o.nights,
    'transport': o.transport,
    'carrier': o.carrier.isEmpty ? null : o.carrier,
    'acc_stars': o.acc,
    'hotel': o.hotel.isEmpty ? null : o.hotel,
    'hotel_makkah_description': o.hotelMakkahDescription.isEmpty
        ? null
        : o.hotelMakkahDescription,
    'hotel_madinah_description': o.hotelMadinahDescription.isEmpty
        ? null
        : o.hotelMadinahDescription,
    'distance_haram': o.distance.isEmpty ? null : o.distance,
    'room': o.room.isEmpty ? null : o.room,
    'room_occupancies': o.roomOccupancies,
    'meals': o.meals.isEmpty ? null : o.meals,
    'includes': o.customIncludes ?? const [],
    'badge': o.badge.isEmpty ? null : o.badge,
    'capacity': o.capacity,
    'departure_date': o.departureDate?.toIso8601String().substring(0, 10),
    'return_date': o.returnDate?.toIso8601String().substring(0, 10),
    'overview_ar': o.overviewAr,
    'overview_en': o.overviewEn,
    'package_tier': o.packageTier,
    'group_type': o.groupType,
    'season_tag': o.seasonTag,
    'departure_airport': o.departureAirport,
    'airline_name': o.airlineName,
    'airline_logo_url': o.airlineLogoUrl,
    'flight_type': o.flightType,
    'bus_between_cities': o.busBetweenCities,
    'airport_transfers': o.airportTransfers,
    'transport_notes': o.transportNotes.isEmpty ? null : o.transportNotes,
    'meals_per_day': o.mealsPerDay,
    'video_url': o.videoUrl,
    'cancellation_policy': o.cancellationPolicy.isEmpty
        ? null
        : o.cancellationPolicy,
    'cancellation_policy_ar': o.cancellationPolicyAr,
    'cancellation_policy_en': o.cancellationPolicyEn,
    'deposit_iqd': o.depositIqd.round(),
    'non_refundable_deposit': o.nonRefundableDeposit,
    'deposit_terms': o.depositTerms.isEmpty ? null : o.depositTerms,
    'accepted_payment_methods': o.acceptedPaymentMethods,
    '_pricing': o.pricing.isNotEmpty
        ? [
            for (final item in o.pricing)
              {
                'occupancy_type': item.occupancyType,
                'price_iqd': item.priceIqd.round(),
                if (item.priceUsd != null) 'price_usd': item.priceUsd,
              },
          ]
        : [
            for (final occupancy in o.availableRoomOccupancies)
              if (occupancy >= 2 && occupancy <= 5)
                {
                  'occupancy_type': switch (occupancy) {
                    2 => 'double',
                    3 => 'triple',
                    4 => 'quad',
                    _ => 'quintuple',
                  },
                  'price_iqd': o.price.round(),
                },
          ],
    '_hotels': o.hotels.isNotEmpty
        ? [
            for (final hotel in o.hotels)
              {
                'city': hotel.city,
                'name': hotel.name,
                'name_ar': hotel.nameAr,
                'name_en': hotel.nameEn,
                'star_rating': hotel.starRating,
                'photo_urls': hotel.photoUrls,
                'nights': hotel.nights,
                'distance_from_haram_m': hotel.distanceFromHaramM,
              },
          ]
        : _legacyHotelRows(o),
    '_inclusions': o.inclusions.isNotEmpty
        ? [
            for (final item in o.inclusions)
              {
                'type': item.type,
                'included': item.included,
                'details': item.details,
                'details_ar': item.detailsAr,
                'details_en': item.detailsEn,
              },
          ]
        : [
            for (var i = 0; i < (o.customIncludes ?? const []).length; i++)
              {
                'type': 'extra_$i',
                'included': true,
                'details': o.customIncludes![i],
              },
          ],
  };

  List<Map<String, dynamic>> _legacyHotelRows(Offer offer) {
    final distance =
        int.tryParse(
          RegExp(r'\d+').firstMatch(offer.distance)?.group(0) ?? '',
        ) ??
        0;
    final makkahNights = (offer.nights / 2).ceil();
    return [
      if (offer.hotelMakkah.isNotEmpty)
        {
          'city': 'makkah',
          'name': offer.hotelMakkah,
          'star_rating': offer.acc,
          'photo_urls': const <String>[],
          'nights': makkahNights,
          'distance_from_haram_m': distance,
        },
      if (offer.hotelMadinah.isNotEmpty)
        {
          'city': 'madinah',
          'name': offer.hotelMadinah,
          'star_rating': offer.acc,
          'photo_urls': const <String>[],
          'nights': offer.nights - makkahNights,
          'distance_from_haram_m': distance,
        },
    ];
  }

  /// Returns (ok, imageFailed): ok is whether the package itself saved;
  /// imageFailed flags that the package saved but its cover photo didn't
  /// persist (e.g. the storage bucket from patches.sql isn't set up yet) —
  /// distinct from ok so the caller can warn without treating it as a
  /// full failure.
  Future<(bool ok, bool imageFailed)> addOffer(
    Offer offer, {
    Uint8List? imageBytes,
  }) async {
    final company = companyById(offer.companyId);
    if (company == null) return (false, false);
    final created = await _service.createPackage(
      _pkgFields(offer),
      offer.customItinerary ?? const [],
      company,
    );
    if (created == null) return (false, false);
    var withImage = created;
    var imageFailed = false;
    if (imageBytes != null) {
      _offerImages[created.id] = imageBytes;
      final url = await _service.uploadPackageImage(created.id, imageBytes);
      if (url != null) {
        withImage = created.copyWith(imageUrl: url);
      } else {
        imageFailed = true;
      }
    }
    _offers = [withImage, ..._offers];
    notifyListeners();
    return (true, imageFailed);
  }

  Future<(bool ok, bool imageFailed)> updateOffer(
    Offer updated, {
    Uint8List? imageBytes,
  }) async {
    final fields = _pkgFields(updated)..remove('company_id');
    final err = await _service.updatePackage(
      updated.id,
      fields,
      updated.customItinerary ?? const [],
    );
    if (err != null) return (false, false);
    var withImage = updated;
    var imageFailed = false;
    if (imageBytes != null) {
      _offerImages[updated.id] = imageBytes;
      final url = await _service.uploadPackageImage(updated.id, imageBytes);
      if (url != null) {
        withImage = updated.copyWith(imageUrl: url);
      } else {
        imageFailed = true;
      }
    }
    final i = _offers.indexWhere((o) => o.id == updated.id);
    if (i >= 0) {
      _offers = List.from(_offers);
      _offers[i] = withImage;
    }
    notifyListeners();
    return (true, imageFailed);
  }

  Future<bool> deleteOffer(String offerId) async {
    final err = await _service.deletePackage(offerId);
    if (err != null) return false;
    _offers = _offers.where((o) => o.id != offerId).toList();
    notifyListeners();
    return true;
  }

  Future<String?> submitOfferForReview(String offerId) async {
    final err = await _service.submitPackage(offerId);
    if (err == null) {
      await loadData();
      if (_user?.isAgency == true) {
        _myCompany = await _service.fetchMyCompany(_user!.id);
      }
    }
    return err;
  }

  Future<String?> reviewOffer(
    String offerId,
    String decision, {
    String? reason,
  }) async {
    final err = await _service.reviewPackage(offerId, decision, reason: reason);
    if (err == null) await loadAdminData();
    return err;
  }

  List<Offer> getFilteredOffers([OfferFilters? override]) {
    var list = List<Offer>.from(_offers);
    final f = override ?? _filters;
    if (f.transport != 'all')
      list = list.where((o) => o.transport == f.transport).toList();
    if (f.acc != 'all')
      list = list.where((o) => o.acc == int.parse(f.acc)).toList();
    if (f.dur == 'short')
      list = list.where((o) => o.days >= 7 && o.days <= 9).toList();
    if (f.dur == 'mid')
      list = list.where((o) => o.days >= 10 && o.days <= 14).toList();
    if (f.dur == 'long') list = list.where((o) => o.days >= 15).toList();
    if (f.rating > 0) list = list.where((o) => o.rating >= f.rating).toList();
    list = list.where((o) => o.price <= f.priceMax).toList();
    switch (f.sort) {
      case 'low':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'high':
        list.sort((a, b) => b.price.compareTo(a.price));
      default:
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  List<Offer> getCompanyOffers(String companyId) =>
      _offers.where((o) => o.companyId == companyId).toList();

  // ── companies ────────────────────────────────────────────────────────────
  Company? companyById(String id) {
    for (final c in _companies) {
      if (c.id == id) return c;
    }
    for (final c in _pendingCompanies) {
      if (c.id == id) return c;
    }
    if (_myCompany?.id == id) return _myCompany;
    return null;
  }

  Future<String?> updateCompanyProfile(
    String companyId, {
    String? location,
    String? about,
    List<String>? tags,
    int? since,
    Color? tint,
    Uint8List? logoBytes,
    Uint8List? bannerBytes,
  }) async {
    final err = await _service.updateCompany(
      companyId,
      location: location,
      about: about,
      tags: tags,
      since: since,
      tint: tint == null ? null : _colorToHex(tint),
    );
    if (err != null) return err;
    final c = companyById(companyId);
    if (c != null) {
      if (location != null) c.location = location;
      if (about != null) c.about = about;
      if (tags != null) c.tags = tags;
      if (since != null) c.since = since;
      if (tint != null) c.tint = tint;
    }
    if (logoBytes != null) {
      final url = await _service.uploadCompanyLogo(companyId, logoBytes);
      if (url != null) c?.logoUrl = url;
    }
    if (bannerBytes != null) {
      final url = await _service.uploadCompanyBanner(companyId, bannerBytes);
      if (url != null) c?.bannerUrl = url;
    }
    notifyListeners();
    return null;
  }

  String _colorToHex(Color color) {
    final red = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final green = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final blue = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$red$green$blue';
  }

  Future<String?> uploadAgencyDocument({
    required String documentType,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final company = _myCompany;
    if (company == null) return 'Company not found';
    final error = await _service.uploadAgencyDocument(
      companyId: company.id,
      documentType: documentType,
      bytes: bytes,
      fileName: fileName,
    );
    if (error == null &&
        company.status != 'active' &&
        company.verificationStatus != 'pending') {
      await _service.submitCompanyApplication(company.id);
      if (_user != null) {
        _myCompany = await _service.fetchMyCompany(_user!.id);
      }
      notifyListeners();
    }
    return error;
  }

  // ── bookings (pilgrim side) ───────────────────────────────────────────────
  List<Booking> _bookings = [];
  List<Booking> get bookings => List.unmodifiable(_bookings);

  Future<void> refreshBookings() async {
    if (_user == null) return;
    try {
      _bookings = await _service.fetchMyBookings(_user!.id);
    } catch (_) {}
    notifyListeners();
  }

  Future<String?> confirmBooking(
    Offer offer,
    int travelers, {
    String payMethod = 'cash',
    DateTime? departureDate,
    String? roomLabel,
    int? roomOccupancy,
    String? mealPreference,
    List<PilgrimInfo>? pilgrims,
  }) async {
    if (_user == null) return 'auth';
    // Room preference + per-pilgrim details travel in the booking note,
    // one line each, so the agency sees them with the request.
    final noteLines = <String>[
      if ((roomLabel ?? '').isNotEmpty) 'room:$roomLabel',
      if (pilgrims != null)
        for (var i = 0; i < pilgrims.length; i++) pilgrims[i].toNoteLine(i + 1),
    ];
    final err = await _service.createBooking(
      packageId: offer.id,
      clientId: _user!.id,
      travellers: travelers,
      payMethod: payMethod,
      departureDate: departureDate,
      contactPhone: _user!.phone,
      note: noteLines.isEmpty ? null : noteLines.join('\n'),
      roomLabel: roomLabel,
      roomOccupancy: roomOccupancy,
      mealPreference: mealPreference,
      pilgrims: pilgrims,
    );
    if (err != null) return err;
    await refreshBookings();
    // Honest about the actual state — the agency hasn't acted on this yet.
    // A real "confirmed"/"cancelled" notification arrives later from the
    // backend (see _loadRemoteNotifications) once the agency responds.
    pushNotification(
      NotificationType.bookingRequested,
      arg: offer.titleFor(lang),
    );
    return null;
  }

  Future<String?> cancelBooking(String bookingId) async {
    final err = await _service.cancelBooking(bookingId);
    if (err != null) return err;
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i >= 0) {
      _bookings = List.from(_bookings);
      _bookings[i] = _bookings[i].copyWith(
        status: 'Cancelled',
        operationalStage: 'cancelled',
      );
      pushNotification(
        NotificationType.bookingCancelled,
        arg: _bookings[i].titleFor(lang),
      );
    }
    notifyListeners();
    return null;
  }

  Future<List<BookingTraveller>> bookingTravellers(String bookingId) =>
      _service.fetchBookingTravellers(bookingId);

  Future<String?> saveTravellerPassport({
    required String travellerId,
    required String bookingId,
    required Uint8List passportBytes,
    required Uint8List selfieBytes,
  }) => _service.saveTravellerPassport(
    travellerId: travellerId,
    bookingId: bookingId,
    passportBytes: passportBytes,
    selfieBytes: selfieBytes,
  );

  // ── reviews (pilgrim side) ────────────────────────────────────────────────
  final Set<String> _reviewedBookingIds = {};
  bool hasReviewed(String bookingId) => _reviewedBookingIds.contains(bookingId);

  Future<String?> submitReview(
    String bookingId,
    String companyId,
    int rating, {
    String comment = '',
  }) async {
    if (_user == null) return 'auth';
    final err = await _service.createReview(
      bookingId: bookingId,
      companyId: companyId,
      clientId: _user!.id,
      rating: rating,
      comment: comment,
    );
    if (err != null) return err;
    _reviewedBookingIds.add(bookingId);
    await loadData(); // the DB trigger just recalculated the company's rating
    notifyListeners();
    return null;
  }

  final Map<String, List<Review>> _companyReviews = {};

  List<Review> reviewsForCompany(String companyId) =>
      List.unmodifiable(_companyReviews[companyId] ?? const []);

  Future<void> loadCompanyReviews(String companyId) async {
    _companyReviews[companyId] = await _service.fetchCompanyReviews(companyId);
    notifyListeners();
  }

  Future<String?> replyToReview(String reviewId, String reply) async {
    final error = await _service.replyToReview(reviewId, reply);
    if (error == null && _myCompany != null) {
      await loadCompanyReviews(_myCompany!.id);
    }
    return error;
  }

  Future<String?> reportAgency({
    required String agencyId,
    required String reason,
    String details = '',
  }) async {
    if (_user == null || !_user!.role.startsWith('client')) {
      return 'Client sign-in required';
    }
    return _service.reportAgency(
      reporterId: _user!.id,
      agencyId: agencyId,
      reason: reason,
      details: details,
    );
  }

  // ── bookings (agency side: review + confirm/decline requests) ────────────
  List<Booking> _agencyBookings = [];
  List<Booking> get agencyBookings => List.unmodifiable(_agencyBookings);
  List<InquiryThread> _agencyInquiries = [];
  List<InquiryThread> get agencyInquiries =>
      List.unmodifiable(_agencyInquiries);
  int get pendingBookingCount => _agencyBookings
      .where(
        (b) =>
            b.operationalStage == 'requested' ||
            b.operationalStage == 'needs_information',
      )
      .length;

  Future<void> loadAgencyBookings() async {
    if (_myCompany == null) return;
    try {
      _agencyBookings = await _service.fetchCompanyBookings(_myCompany!.id);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> loadAgencyInquiries() async {
    final company = _myCompany;
    if (company == null) return;
    _agencyInquiries = await _service.fetchAgencyInquiries(company.id);
    notifyListeners();
  }

  Future<String?> replyToInquiry(String inquiryId, String body) async {
    if (_user == null) return 'Sign-in required';
    final error = await _service.sendInquiryReply(
      inquiryId: inquiryId,
      senderId: _user!.id,
      body: body,
    );
    if (error == null) await loadAgencyInquiries();
    return error;
  }

  Future<String?> respondToBooking(
    String bookingId, {
    required bool confirm,
  }) async {
    final action = confirm ? 'accept' : 'reject';
    final err = await _service.setBookingStatus(bookingId, action);
    if (err != null) return err;
    final i = _agencyBookings.indexWhere((b) => b.id == bookingId);
    if (i >= 0) {
      _agencyBookings = List.from(_agencyBookings);
      _agencyBookings[i] = _agencyBookings[i].copyWith(
        status: confirm ? 'Pending' : 'Cancelled',
        operationalStage: confirm ? 'awaiting_payment' : 'rejected',
      );
    }
    notifyListeners();
    return null;
  }

  /// Closes the loop so a completed trip becomes reviewable by the pilgrim.
  Future<String?> markBookingCompleted(String bookingId) async {
    final err = await _service.setBookingStatus(bookingId, 'complete');
    if (err != null) return err;
    final i = _agencyBookings.indexWhere((b) => b.id == bookingId);
    if (i >= 0) {
      _agencyBookings = List.from(_agencyBookings);
      _agencyBookings[i] = _agencyBookings[i].copyWith(
        status: 'Completed',
        operationalStage: 'completed',
      );
    }
    notifyListeners();
    return null;
  }

  Future<String?> markBookingReady(String bookingId) =>
      _transitionAgencyBooking(bookingId, 'ready', 'ready');

  Future<String?> confirmCashPayment(String bookingId) async {
    final err = await _service.confirmCashReceived(bookingId);
    if (err == null) await loadAgencyBookings();
    return err;
  }

  Future<Map<String, dynamic>?> initiateFibPayment(Booking booking) =>
      _service.initiateFibPayment(booking.id, booking.total.round());

  Future<String?> startBookingTrip(String bookingId) =>
      _transitionAgencyBooking(bookingId, 'start', 'in_progress');

  Future<String?> _transitionAgencyBooking(
    String bookingId,
    String action,
    String stage,
  ) async {
    final err = await _service.setBookingStatus(bookingId, action);
    if (err != null) return err;
    final i = _agencyBookings.indexWhere((b) => b.id == bookingId);
    if (i >= 0) {
      _agencyBookings = List.from(_agencyBookings);
      _agencyBookings[i] = _agencyBookings[i].copyWith(
        status: 'Confirmed',
        operationalStage: stage,
      );
    }
    notifyListeners();
    return null;
  }

  // ── commissions (what an agency owes the platform) ───────────────────────
  List<Commission> _commissions = [];
  List<Commission> get commissions => List.unmodifiable(_commissions);
  double get commissionsOwed => _commissions
      .where((c) => c.status == 'owed')
      .fold(0.0, (sum, c) => sum + c.amount);
  double get commissionsCollected => _commissions
      .where((c) => c.status == 'collected')
      .fold(0.0, (sum, c) => sum + c.amount);

  /// Admins see the full ledger; agencies see only their own.
  Future<void> loadCommissions() async {
    try {
      _commissions = await _service.fetchCommissions(
        companyId: isAdminUser ? null : _myCompany?.id,
      );
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> markCommissionCollected(String id) async {
    final err = await _service.setCommissionCollected(id);
    if (err != null) return false;
    final i = _commissions.indexWhere((c) => c.id == id);
    if (i >= 0) {
      final c = _commissions[i];
      _commissions = List.from(_commissions);
      _commissions[i] = Commission(
        id: c.id,
        bookingId: c.bookingId,
        companyId: c.companyId,
        companyName: c.companyName,
        amount: c.amount,
        status: 'collected',
        createdAt: c.createdAt,
      );
    }
    notifyListeners();
    return true;
  }

  // ── support messages ──────────────────────────────────────────────────────
  List<SupportMessage> _supportMessages = [];
  List<SupportMessage> get supportMessages =>
      List.unmodifiable(_supportMessages);

  Future<void> loadSupportMessages() async {
    if (!isAdminUser) return;
    try {
      _supportMessages = await _service.fetchSupportMessages();
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> sendSupportMessage(String message) async {
    final err = await _service.sendSupportMessage(
      userId: _user?.id,
      email: _user?.email,
      message: message,
    );
    return err == null;
  }

  /// Admin resolves a support message — removes it from the inbox for good.
  Future<bool> deleteSupportMessage(String id) async {
    final err = await _service.deleteSupportMessage(id);
    if (err != null) return false;
    _supportMessages = _supportMessages.where((m) => m.id != id).toList();
    notifyListeners();
    return true;
  }

  // ── password reset (OTP-code, works without deep linking) ────────────────
  Future<String?> sendPasswordResetCode(String email) =>
      _service.sendPasswordResetCode(email);

  Future<String?> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) => _service.resetPasswordWithCode(
    email: email,
    code: code,
    newPassword: newPassword,
  );

  // ── notifications ─────────────────────────────────────────────────────────
  // Local, synthetic entries (welcome message, instant feedback on the
  // pilgrim's own request/cancel) sit alongside real rows fetched from the
  // backend — the latter cover actions an agency/admin took in a completely
  // different session (see supabase/patches.sql's notifications table).
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      type: NotificationType.welcome,
      time: DateTime.now(),
    ),
  ];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadNotifications => _notifications.where((n) => !n.read).length;

  /// Local entries live only on this device, so their read/cleared state is
  /// kept in shared_preferences — without this the welcome notification came
  /// back unread on every launch.
  void _restoreLocalNotifications(SharedPreferences p) {
    final stored = p.getString('localNotifs');
    if (stored == null) return; // first launch — keep the default welcome
    try {
      final locals = (jsonDecode(stored) as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      _notifications
        ..removeWhere((n) => !n.isRemote)
        ..insertAll(0, locals)
        ..sort((a, b) => b.time.compareTo(a.time));
    } catch (_) {}
  }

  void _persistLocalNotifications() {
    _prefs?.setString(
      'localNotifs',
      jsonEncode([
        for (final n in _notifications.where((n) => !n.isRemote)) n.toJson(),
      ]),
    );
  }

  Future<void> _loadRemoteNotifications() async {
    if (_user == null) return;
    try {
      final remote = await _service.fetchNotifications(_user!.id);
      _notifications
        ..removeWhere((n) => n.isRemote)
        ..addAll(remote)
        ..sort((a, b) => b.time.compareTo(a.time));
    } catch (_) {}
    notifyListeners();
  }

  void pushNotification(NotificationType type, {String? arg}) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        arg: arg,
        time: DateTime.now(),
      ),
    );
    _persistLocalNotifications();
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final n = _notifications.where((n) => n.id == id).firstOrNull;
    if (n != null && !n.read) {
      n.read = true;
      notifyListeners();
      if (n.isRemote) {
        _service.markNotificationRead(id);
      } else {
        _persistLocalNotifications();
      }
    }
  }

  void markAllNotificationsRead() {
    var changed = false;
    for (final n in _notifications) {
      if (!n.read) {
        n.read = true;
        changed = true;
      }
    }
    if (!changed) return;
    _persistLocalNotifications();
    notifyListeners();
    if (_user != null) _service.markAllNotificationsRead(_user!.id);
  }

  void removeNotification(String id) {
    final n = _notifications.where((n) => n.id == id).firstOrNull;
    if (n == null) return;
    _notifications.remove(n);
    notifyListeners();
    if (n.isRemote) {
      _service.deleteNotification(id);
    } else {
      _persistLocalNotifications();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _persistLocalNotifications();
    notifyListeners();
    if (_user != null) _service.clearNotifications(_user!.id);
  }

  // ── privacy & security settings ──────────────────────────────────────────
  // Biometric lock is deliberately per-device (stored only in shared_
  // preferences); the rest follow the account across devices.
  bool biometricLock = false;
  bool marketingEmails = true;
  bool shareActivity = false;
  String preferredPayMethod = 'cash'; // 'cash' | 'card' | 'fib'

  void setSecuritySetting(String key, bool value) {
    switch (key) {
      case 'biometric':
        biometricLock = value;
      case 'marketing':
        marketingEmails = value;
      case 'activity':
        shareActivity = value;
    }
    notifyListeners();
    if (key == 'biometric') {
      _prefs?.setBool(key, value);
      return;
    }
    if (_user != null) {
      _service.updateAccountPrefs(
        _user!.id,
        marketingEmails: key == 'marketing' ? value : null,
        shareActivity: key == 'activity' ? value : null,
      );
    } else {
      _prefs?.setBool(key, value);
    }
  }

  Future<void> setPreferredPayMethod(String method) async {
    preferredPayMethod = method;
    notifyListeners();
    if (_user != null) {
      await _service.updateAccountPrefs(_user!.id, preferredPayMethod: method);
    } else {
      await _prefs?.setString('payMethod', method);
    }
  }
}
