import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../models/booking_model.dart';
import '../models/company_model.dart';
import '../models/agency_account.dart';
import '../data/sample_data.dart';

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
  // ── tab navigation ───────────────────────────────────────────────────────
  int _currentTab = 0;
  int get currentTab => _currentTab;
  void setTab(int i) { _currentTab = i; notifyListeners(); }

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
          o.hotel.toLowerCase().contains(lower);
    }).toList();
  }

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

  List<Offer> getFilteredOffers() {
    var list = List<Offer>.from(allOffers);
    final f = _filters;
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
  void confirmBooking(Offer offer, int travelers, String companyName) {
    final ref = 'UM-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(0, 6)}';
    _bookings = [
      Booking(
        id: 'b${DateTime.now().millisecondsSinceEpoch}',
        offerId: offer.id,
        title: offer.title,
        companyName: companyName,
        gradColors: offer.gradColors,
        date: 'To be scheduled',
        travelers: travelers,
        status: 'Confirmed',
        ref: ref,
        total: offer.price * travelers,
      ),
      ..._bookings,
    ];
    notifyListeners();
  }
}
