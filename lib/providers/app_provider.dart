import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../models/booking_model.dart';
import '../models/company_model.dart';
import '../models/agency_account.dart';
import '../models/notification_model.dart';
import '../models/payment_card_model.dart';
import '../data/sample_data.dart';
import '../theme/app_theme.dart';

class OfferFilters {
  final String transport;
  final String acc;
  final String dur;
  final double rating;
  final double priceMax;
  final String sort;

  const OfferFilters({
    this.transport = 'all',
    this.acc = 'all',
    this.dur = 'all',
    this.rating = 0,
    this.priceMax = 5000,
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
      transport != 'all' || acc != 'all' || dur != 'all' || rating > 0 || priceMax < 5000;

  int get activeCount {
    int c = 0;
    if (transport != 'all') c++;
    if (acc != 'all') c++;
    if (dur != 'all') c++;
    if (rating > 0) c++;
    if (priceMax < 5000) c++;
    return c;
  }
}

class AppProvider extends ChangeNotifier {
  AppProvider() {
    AppTheme.isArabicScript = _locale.languageCode != 'en';
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

  // ── saved / bookings ─────────────────────────────────────────────────────
  final List<String> _saved = ['o3', 'o7'];
  List<Booking> _bookings = List.from(sampleBookings);
  List<String> get saved => List.unmodifiable(_saved);
  List<Booking> get bookings => List.unmodifiable(_bookings);

  bool isSaved(String offerId) => _saved.contains(offerId);

  void toggleSave(String offerId) {
    _saved.contains(offerId) ? _saved.remove(offerId) : _saved.add(offerId);
    notifyListeners();
  }

  List<Offer> get savedOffers =>
      allOffers.where((o) => _saved.contains(o.id)).toList();

  // ── filters ──────────────────────────────────────────────────────────────
  OfferFilters _filters = const OfferFilters();
  OfferFilters get filters => _filters;
  void updateFilters(OfferFilters f) { _filters = f; notifyListeners(); }
  void resetFilters() { _filters = const OfferFilters(); notifyListeners(); }

  // ── search ───────────────────────────────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearch(String q) { _searchQuery = q; notifyListeners(); }

  List<Offer> searchOffers(String q) {
    if (q.trim().isEmpty) return [];
    final lower = q.toLowerCase();
    return allOffers.where((o) {
      final company = companyById(o.companyId);
      return o.title.toLowerCase().contains(lower) ||
          o.city.toLowerCase().contains(lower) ||
          (company?.name.toLowerCase().contains(lower) ?? false) ||
          o.hotel.toLowerCase().contains(lower) ||
          o.badge.toLowerCase().contains(lower);
    }).toList();
  }

  /// Suggestion chips built from real data (cities, badges, agency names),
  /// so tapping one always returns results regardless of the UI language.
  List<String> get searchSuggestions {
    final seen = <String>{};
    final out = <String>[];
    void add(String s) {
      final key = s.toLowerCase();
      if (s.isNotEmpty && seen.add(key)) out.add(s);
    }

    for (final o in allOffers) {
      for (final city in o.city.split('·')) {
        add(city.trim());
      }
    }
    for (final o in allOffers) {
      add(o.badge);
    }
    for (final c in sampleCompanies.take(3)) {
      add(c.name);
    }
    return out.take(10).toList();
  }

  // ── offer images ─────────────────────────────────────────────────────────
  final Map<String, Uint8List> _offerImages = {};
  Uint8List? getOfferImage(String id) => _offerImages[id];
  void setOfferImage(String id, Uint8List bytes) { _offerImages[id] = bytes; notifyListeners(); }
  void removeOfferImage(String id) { _offerImages.remove(id); notifyListeners(); }

  // ── offers (sample + agency-added) ───────────────────────────────────────
  List<Offer> get allOffers => [...sampleOffers, ...agencyOffers];

  void addOffer(Offer offer) {
    agencyOffers.add(offer);
    notifyListeners();
  }

  void updateOffer(Offer updated) {
    final i = agencyOffers.indexWhere((o) => o.id == updated.id);
    if (i >= 0) agencyOffers[i] = updated;
    notifyListeners();
  }

  void deleteOffer(String offerId) {
    agencyOffers.removeWhere((o) => o.id == offerId);
    notifyListeners();
  }

  /// Filters [allOffers]; pass [override] to preview a filter selection
  /// without committing it (used by the filter sheet's live count).
  List<Offer> getFilteredOffers([OfferFilters? override]) {
    var list = List<Offer>.from(allOffers);
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
      allOffers.where((o) => o.companyId == companyId).toList();

  // ── companies ─────────────────────────────────────────────────────────────
  Company? companyById(String id) {
    try {
      return [...sampleCompanies, ...pendingCompanies].firstWhere((c) => c.id == id);
    } catch (_) { return null; }
  }

  void updateCompanyProfile(String companyId, {
    String? location, String? about, List<String>? tags,
  }) {
    final list = [...sampleCompanies, ...pendingCompanies];
    final c = list.firstWhere((c) => c.id == companyId);
    if (location != null) c.location = location;
    if (about != null) c.about = about;
    if (tags != null) c.tags = tags;
    notifyListeners();
  }

  // ── agency auth ──────────────────────────────────────────────────────────
  AgencyAccount? _loggedInAgency;
  AgencyAccount? get loggedInAgency => _loggedInAgency;
  bool get isAgencyLoggedIn => _loggedInAgency != null;

  Company? get agencyCompany => _loggedInAgency == null
      ? null
      : companyById(_loggedInAgency!.companyId);

  bool agencyLogin(String email, String password) {
    try {
      final account = [...sampleAgencyAccounts].firstWhere(
        (a) => a.email.toLowerCase() == email.toLowerCase() && a.password == password,
      );
      _loggedInAgency = account;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void agencyLogout() {
    _loggedInAgency = null;
    notifyListeners();
  }

  // ── bookings ─────────────────────────────────────────────────────────────
  void confirmBooking(Offer offer, int travelers, String companyName, {DateTime? departureDate}) {
    final ref = 'UM-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(0, 6)}';
    _bookings = [
      Booking(
        id: 'b${DateTime.now().millisecondsSinceEpoch}',
        offerId: offer.id,
        title: offer.title,
        companyName: companyName,
        gradColors: offer.gradColors,
        departureDate: departureDate,
        travelers: travelers,
        status: 'Confirmed',
        ref: ref,
        total: offer.price * travelers,
      ),
      ..._bookings,
    ];
    pushNotification(NotificationType.bookingConfirmed, arg: offer.title);
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    final i = _bookings.indexWhere((b) => b.id == bookingId);
    if (i < 0) return;
    _bookings = List.from(_bookings);
    _bookings[i] = _bookings[i].copyWith(status: 'Cancelled');
    pushNotification(NotificationType.bookingCancelled, arg: _bookings[i].title);
    notifyListeners();
  }

  // ── notifications ────────────────────────────────────────────────────────
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n3',
      type: NotificationType.tripReminder,
      arg: 'Family Umrah Retreat',
      time: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      id: 'n2',
      type: NotificationType.promo,
      time: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'n1',
      type: NotificationType.welcome,
      time: DateTime.now().subtract(const Duration(days: 3)),
      read: true,
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

  // ── payment methods ──────────────────────────────────────────────────────
  final List<PaymentCard> _cards = [
    const PaymentCard(id: 'pc1', holder: 'Pilgrim', last4: '4242', expiry: '08/27', brand: 'Visa'),
  ];
  String _defaultCardId = 'pc1';
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

  // ── privacy & security settings ──────────────────────────────────────────
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
