import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../models/booking_model.dart';
import '../models/company_model.dart';
import '../models/notification_model.dart';
import '../models/payment_card_model.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
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

  Future<void> init() async {
    await loadData();
    await restoreAuth();
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
      _loadFailed = false;
    } catch (_) {
      _loadFailed = true;
    }
    _loading = false;
    notifyListeners();
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
    notifyListeners();
  }

  String get lang => _locale.languageCode;

  // ── auth ─────────────────────────────────────────────────────────────────
  UserProfile? _user;
  Company? _myCompany; // the agency user's own company (may be unverified)

  UserProfile? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isAgencyUser => _user?.isAgency ?? false;
  bool get isAgencyLoggedIn => isAgencyUser;
  Company? get agencyCompany => _myCompany;

  Future<void> restoreAuth() async {
    try {
      _user = await _service.restoreSession();
      if (_user != null) {
        if (_user!.isAgency) _myCompany = await _service.fetchMyCompany(_user!.id);
        await refreshBookings();
      }
    } catch (_) {}
    notifyListeners();
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
    String phone = '',
  }) async {
    final err = await _service.signUp(
        email: email, password: password, fullName: fullName, phone: phone, role: 'agency');
    if (err != null) return err;
    await restoreAuth();
    if (_user != null && _myCompany == null) {
      _myCompany = await _service.createCompany(
          ownerId: _user!.id, name: companyName, location: companyLocation);
      notifyListeners();
    }
    return null;
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    _myCompany = null;
    _bookings = [];
    notifyListeners();
  }

  void agencyLogout() {
    signOut();
  }

  // ── saved trips (local, per device) ──────────────────────────────────────
  final List<String> _saved = [];
  List<String> get saved => List.unmodifiable(_saved);

  bool isSaved(String offerId) => _saved.contains(offerId);

  void toggleSave(String offerId) {
    _saved.contains(offerId) ? _saved.remove(offerId) : _saved.add(offerId);
    notifyListeners();
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

  Future<bool> addOffer(Offer offer, {Uint8List? imageBytes}) async {
    final company = companyById(offer.companyId);
    if (company == null) return false;
    final created = await _service.createPackage(
        _pkgFields(offer), offer.customItinerary ?? const [], company);
    if (created == null) return false;
    var withImage = created;
    if (imageBytes != null) {
      _offerImages[created.id] = imageBytes;
      await _service.uploadPackageImage(created.id, imageBytes);
    }
    _offers = [withImage, ..._offers];
    notifyListeners();
    return true;
  }

  Future<bool> updateOffer(Offer updated, {Uint8List? imageBytes}) async {
    final err = await _service.updatePackage(
        updated.id, _pkgFields(updated), updated.customItinerary ?? const []);
    if (err != null) return false;
    if (imageBytes != null) {
      _offerImages[updated.id] = imageBytes;
      await _service.uploadPackageImage(updated.id, imageBytes);
    }
    final i = _offers.indexWhere((o) => o.id == updated.id);
    if (i >= 0) {
      _offers = List.from(_offers);
      _offers[i] = updated;
    }
    notifyListeners();
    return true;
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
    String? location, String? about, List<String>? tags,
  }) async {
    final err = await _service.updateCompany(companyId,
        location: location, about: about, tags: tags);
    if (err != null) return err;
    final c = companyById(companyId);
    if (c != null) {
      if (location != null) c.location = location;
      if (about != null) c.about = about;
      if (tags != null) c.tags = tags;
    }
    notifyListeners();
    return null;
  }

  // ── bookings ─────────────────────────────────────────────────────────────
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
    pushNotification(NotificationType.bookingConfirmed, arg: offer.titleFor(lang));
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

  // ── notifications (local) ────────────────────────────────────────────────
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      type: NotificationType.welcome,
      time: DateTime.now(),
    ),
  ];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadNotifications => _notifications.where((n) => !n.read).length;

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
    if (n != null && !n.read) { n.read = true; notifyListeners(); }
  }

  void markAllNotificationsRead() {
    for (final n in _notifications) { n.read = true; }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // ── payment methods (local) ──────────────────────────────────────────────
  final List<PaymentCard> _cards = [];
  String _defaultCardId = '';
  List<PaymentCard> get cards => List.unmodifiable(_cards);
  String get defaultCardId => _defaultCardId;

  void addCard({required String holder, required String number, required String expiry}) {
    final card = PaymentCard(
      id: 'pc${DateTime.now().millisecondsSinceEpoch}',
      holder: holder,
      last4: number.substring(number.length - 4),
      expiry: expiry,
      brand: PaymentCard.detectBrand(number),
    );
    _cards.add(card);
    if (_cards.length == 1) _defaultCardId = card.id;
    notifyListeners();
  }

  void removeCard(String id) {
    _cards.removeWhere((c) => c.id == id);
    if (_defaultCardId == id && _cards.isNotEmpty) _defaultCardId = _cards.first.id;
    notifyListeners();
  }

  void setDefaultCard(String id) {
    _defaultCardId = id;
    notifyListeners();
  }

  // ── privacy & security settings (local) ──────────────────────────────────
  bool biometricLock = false;
  bool twoFactorAuth = false;
  bool marketingEmails = true;
  bool shareActivity = false;

  void setSecuritySetting(String key, bool value) {
    switch (key) {
      case 'biometric': biometricLock = value;
      case 'twoFactor': twoFactorAuth = value;
      case 'marketing': marketingEmails = value;
      case 'activity': shareActivity = value;
    }
    notifyListeners();
  }
}
