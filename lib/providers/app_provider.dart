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
import '../services/supabase_service.dart';
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
    String? transport, String? acc, String? dur,
    double? rating, double? priceMax, String? sort,
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
      transport != 'all' || acc != 'all' || dur != 'all' || rating > 0 || priceMax < priceCeiling;

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

  Future<void> init() async {
    await _loadPrefs();
    await loadData();
    await restoreAuth();
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
      _offers = await _service.fetchOffers(_companies);
      _homeAds = await _service.fetchHomeAds();
      _loadFailed = false;
    } catch (_) {
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
  void setTab(int i) { _currentTab = i; notifyListeners(); }

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
      final localOnly = _saved.where((id) => !remoteSaved.contains(id)).toList();
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
        email: email, password: password, fullName: fullName, phone: phone);
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
        email: email, password: password, fullName: fullName, phone: phone,
        role: 'agency', companyName: companyName, companyLocation: companyLocation,
        companyAbout: companyAbout, companySince: companySince);
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
      ..add(AppNotification(id: 'n1', type: NotificationType.welcome, time: DateTime.now()));
    notifyListeners();
  }

  Future<String?> updateAccountDetails({String? fullName, String? phone}) async {
    if (_user == null) return null;
    final err = await _service.updateProfile(_user!.id, fullName: fullName, phone: phone);
    if (err != null) return err;
    if (fullName != null) _user!.fullName = fullName;
    if (phone != null) _user!.phone = phone;
    notifyListeners();
    return null;
  }

  Future<String?> changePassword(String newPassword) =>
      _service.changePassword(newPassword);

  Future<String?> deleteAccount() async {
    final err = await _service.deleteAccount();
    if (err != null) return err;
    await _clearLocalAccountState();
    return null;
  }

  void agencyLogout() {
    signOut();
  }

  // ── admin ─────────────────────────────────────────────────────────────────
  List<Company> _pendingCompanies = [];
  List<Company> get pendingCompanies => List.unmodifiable(_pendingCompanies);

  Future<void> loadAdminData() async {
    if (!isAdminUser) return;
    try {
      _pendingCompanies = await _service.fetchPendingCompanies();
      _homeAds = await _service.fetchHomeAds();
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

  Future<bool> createHomeAd({required String title, String? packageId, Uint8List? imageBytes}) async {
    final offer = offerById(packageId);
    final ad = await _service.createHomeAd(
        title: title, packageId: packageId, companyId: offer?.companyId);
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
                id: a.id, companyId: a.companyId, packageId: a.packageId,
                title: a.title, titleAr: a.titleAr, titleEn: a.titleEn,
                imageUrl: a.imageUrl, sortOrder: a.sortOrder, isActive: active)
            : a
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
  void updateFilters(OfferFilters f) { _filters = f; notifyListeners(); }
  void resetFilters() { _filters = const OfferFilters(); notifyListeners(); }

  // ── search ───────────────────────────────────────────────────────────────
  List<Offer> searchOffers(String q) {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    bool hit(String? s) => (s ?? '').toLowerCase().contains(lower);
    return _offers.where((o) {
      final company = companyById(o.companyId);
      return hit(o.title) || hit(o.titleAr) || hit(o.titleEn) ||
          hit(o.city) || hit(o.hotel) || hit(o.badge) ||
          hit(company?.name) || hit(company?.nameAr) || hit(company?.nameEn);
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
  void setOfferImage(String id, Uint8List bytes) { _offerImages[id] = bytes; notifyListeners(); }
  void removeOfferImage(String id) { _offerImages.remove(id); notifyListeners(); }

  // ── offers (agency CRUD against the backend) ─────────────────────────────
  Map<String, dynamic> _pkgFields(Offer o) => {
        'company_id': o.companyId,
        'title': o.title,
        'overview': o.overview.isEmpty ? null : o.overview,
        'price_iqd': o.price.round(),
        'original_iqd': o.original > 0 ? o.original.round() : null,
        'days': o.days,
        'nights': o.nights,
        'transport': o.transport,
        'carrier': o.carrier.isEmpty ? null : o.carrier,
        'acc_stars': o.acc,
        'hotel': o.hotel.isEmpty ? null : o.hotel,
        'distance_haram': o.distance.isEmpty ? null : o.distance,
        'room': o.room.isEmpty ? null : o.room,
        'meals': o.meals.isEmpty ? null : o.meals,
        'includes': o.customIncludes ?? const [],
        'badge': o.badge.isEmpty ? null : o.badge,
        'is_published': true,
      };

  /// Returns (ok, imageFailed): ok is whether the package itself saved;
  /// imageFailed flags that the package saved but its cover photo didn't
  /// persist (e.g. the storage bucket from patches.sql isn't set up yet) —
  /// distinct from ok so the caller can warn without treating it as a
  /// full failure.
  Future<(bool ok, bool imageFailed)> addOffer(Offer offer, {Uint8List? imageBytes}) async {
    final company = companyById(offer.companyId);
    if (company == null) return (false, false);
    final created = await _service.createPackage(
        _pkgFields(offer), offer.customItinerary ?? const [], company);
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

  Future<(bool ok, bool imageFailed)> updateOffer(Offer updated, {Uint8List? imageBytes}) async {
    final err = await _service.updatePackage(
        updated.id, _pkgFields(updated), updated.customItinerary ?? const []);
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

  List<Offer> getFilteredOffers([OfferFilters? override]) {
    var list = List<Offer>.from(_offers);
    final f = override ?? _filters;
    if (f.transport != 'all') list = list.where((o) => o.transport == f.transport).toList();
    if (f.acc != 'all') list = list.where((o) => o.acc == int.parse(f.acc)).toList();
    if (f.dur == 'short') list = list.where((o) => o.days >= 7 && o.days <= 9).toList();
    if (f.dur == 'mid') list = list.where((o) => o.days >= 10 && o.days <= 14).toList();
    if (f.dur == 'long') list = list.where((o) => o.days >= 15).toList();
    if (f.rating > 0) list = list.where((o) => o.rating >= f.rating).toList();
    list = list.where((o) => o.price <= f.priceMax).toList();
    switch (f.sort) {
      case 'low': list.sort((a, b) => a.price.compareTo(b.price));
      case 'high': list.sort((a, b) => b.price.compareTo(a.price));
      default: list.sort((a, b) => b.rating.compareTo(a.rating));
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
    if (_myCompany?.id == id) return _myCompany;
    return null;
  }

  Future<String?> updateCompanyProfile(String companyId, {
    String? location, String? about, List<String>? tags, int? since,
    Uint8List? logoBytes,
  }) async {
    final err = await _service.updateCompany(companyId,
        location: location, about: about, tags: tags, since: since);
    if (err != null) return err;
    final c = companyById(companyId);
    if (c != null) {
      if (location != null) c.location = location;
      if (about != null) c.about = about;
      if (tags != null) c.tags = tags;
      if (since != null) c.since = since;
    }
    if (logoBytes != null) {
      final url = await _service.uploadCompanyLogo(companyId, logoBytes);
      if (url != null) c?.logoUrl = url;
    }
    notifyListeners();
    return null;
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
  }) async {
    if (_user == null) return 'auth';
    final err = await _service.createBooking(
      packageId: offer.id,
      clientId: _user!.id,
      travellers: travelers,
      payMethod: payMethod,
      departureDate: departureDate,
      contactPhone: _user!.phone,
    );
    if (err != null) return err;
    await refreshBookings();
    // Honest about the actual state — the agency hasn't acted on this yet.
    // A real "confirmed"/"cancelled" notification arrives later from the
    // backend (see _loadRemoteNotifications) once the agency responds.
    pushNotification(NotificationType.bookingRequested, arg: offer.titleFor(lang));
    return null;
  }

  Future<String?> cancelBooking(String bookingId) async {
    final err = await _service.cancelBooking(bookingId);
    if (err != null) return err;
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i >= 0) {
      _bookings = List.from(_bookings);
      _bookings[i] = _bookings[i].copyWith(status: 'Cancelled');
      pushNotification(NotificationType.bookingCancelled, arg: _bookings[i].titleFor(lang));
    }
    notifyListeners();
    return null;
  }

  // ── reviews (pilgrim side) ────────────────────────────────────────────────
  final Set<String> _reviewedBookingIds = {};
  bool hasReviewed(String bookingId) => _reviewedBookingIds.contains(bookingId);

  Future<String?> submitReview(String bookingId, String companyId, int rating, {String comment = ''}) async {
    if (_user == null) return 'auth';
    final err = await _service.createReview(
      bookingId: bookingId, companyId: companyId, clientId: _user!.id,
      rating: rating, comment: comment,
    );
    if (err != null) return err;
    _reviewedBookingIds.add(bookingId);
    await loadData(); // the DB trigger just recalculated the company's rating
    notifyListeners();
    return null;
  }

  // ── bookings (agency side: review + confirm/decline requests) ────────────
  List<Booking> _agencyBookings = [];
  List<Booking> get agencyBookings => List.unmodifiable(_agencyBookings);
  int get pendingBookingCount => _agencyBookings.where((b) => b.status == 'Pending').length;

  Future<void> loadAgencyBookings() async {
    if (_myCompany == null) return;
    try {
      _agencyBookings = await _service.fetchCompanyBookings(_myCompany!.id);
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> respondToBooking(String bookingId, {required bool confirm}) async {
    final err = await _service.setBookingStatus(bookingId, confirm ? 'confirmed' : 'cancelled');
    if (err != null) return false;
    final i = _agencyBookings.indexWhere((b) => b.id == bookingId);
    if (i >= 0) {
      _agencyBookings = List.from(_agencyBookings);
      _agencyBookings[i] = _agencyBookings[i].copyWith(status: confirm ? 'Confirmed' : 'Cancelled');
    }
    notifyListeners();
    return true;
  }

  /// Closes the loop so a completed trip becomes reviewable by the pilgrim.
  Future<bool> markBookingCompleted(String bookingId) async {
    final err = await _service.setBookingStatus(bookingId, 'completed');
    if (err != null) return false;
    final i = _agencyBookings.indexWhere((b) => b.id == bookingId);
    if (i >= 0) {
      _agencyBookings = List.from(_agencyBookings);
      _agencyBookings[i] = _agencyBookings[i].copyWith(status: 'Completed');
    }
    notifyListeners();
    return true;
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
      _commissions = await _service.fetchCommissions(companyId: isAdminUser ? null : _myCompany?.id);
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
        id: c.id, bookingId: c.bookingId, companyId: c.companyId,
        companyName: c.companyName, amount: c.amount,
        status: 'collected', createdAt: c.createdAt,
      );
    }
    notifyListeners();
    return true;
  }

  // ── support messages ──────────────────────────────────────────────────────
  List<SupportMessage> _supportMessages = [];
  List<SupportMessage> get supportMessages => List.unmodifiable(_supportMessages);

  Future<void> loadSupportMessages() async {
    if (!isAdminUser) return;
    try {
      _supportMessages = await _service.fetchSupportMessages();
    } catch (_) {}
    notifyListeners();
  }

  Future<bool> sendSupportMessage(String message) async {
    final err = await _service.sendSupportMessage(
      userId: _user?.id, email: _user?.email, message: message,
    );
    return err == null;
  }

  // ── password reset (OTP-code, works without deep linking) ────────────────
  Future<String?> sendPasswordResetCode(String email) => _service.sendPasswordResetCode(email);

  Future<String?> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) =>
      _service.resetPasswordWithCode(email: email, code: code, newPassword: newPassword);

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
    _notifications.insert(0, AppNotification(
      id: 'n${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      arg: arg,
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final n = _notifications.where((n) => n.id == id).firstOrNull;
    if (n != null && !n.read) {
      n.read = true;
      notifyListeners();
      if (n.isRemote) _service.markNotificationRead(id);
    }
  }

  void markAllNotificationsRead() {
    for (final n in _notifications) { n.read = true; }
    notifyListeners();
    if (_user != null) _service.markAllNotificationsRead(_user!.id);
  }

  void clearNotifications() {
    _notifications.clear();
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
      case 'biometric': biometricLock = value;
      case 'marketing': marketingEmails = value;
      case 'activity': shareActivity = value;
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
