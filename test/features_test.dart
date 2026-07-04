import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:umrah_app/models/booking_model.dart';
import 'package:umrah_app/models/company_model.dart';
import 'package:umrah_app/models/home_ad_model.dart';
import 'package:umrah_app/models/notification_model.dart';
import 'package:umrah_app/models/offer_model.dart';
import 'package:umrah_app/models/payment_card_model.dart';
import 'package:umrah_app/models/user_profile.dart';
import 'package:umrah_app/providers/app_provider.dart';
import 'package:umrah_app/services/supabase_service.dart';
import 'package:umrah_app/screens/profile/help_support_screen.dart';
import 'package:umrah_app/screens/profile/notifications_screen.dart';
import 'package:umrah_app/screens/profile/payment_methods_screen.dart';
import 'package:umrah_app/screens/profile/privacy_security_screen.dart';
import 'package:umrah_app/l10n/generated/app_localizations.dart';

class FakeService implements DataService {
  final companies = [
    Company(id: 'c1', ownerId: 'agency1', name: 'گەشتیاری نوور', nameEn: 'Noor Travel',
        location: 'Erbil', since: 2009, rating: 4.8, isVerified: true),
    Company(id: 'c2', ownerId: 'agency1', name: 'کاروانی سەلام', nameEn: 'Salam Caravans',
        location: 'Sulaymaniyah', since: 2014, rating: 4.6, isVerified: true),
  ];
  final offers = <Offer>[
    const Offer(id: 'o1', companyId: 'c1', title: 'عومرەی زێڕین', titleEn: 'Golden Umrah',
        transport: 'plane', acc: 5, days: 12, price: 2750000, original: 3100000,
        rating: 4.8, hotel: 'Swissôtel', badge: 'Best value',
        gradColors: [Colors.teal, Colors.black]),
    const Offer(id: 'o2', companyId: 'c2', title: 'عومرەی ئاسوودە', titleEn: 'Comfort Umrah',
        transport: 'bus', acc: 4, days: 9, price: 1450000,
        rating: 4.6, hotel: 'Dar Al Eiman',
        gradColors: [Colors.blueGrey, Colors.black]),
  ];
  final bookings = <Booking>[];
  UserProfile? user;

  @override
  bool get isSignedIn => user != null;

  @override
  Future<UserProfile?> restoreSession() async => user;

  @override
  Future<String?> signIn(String email, String password) async {
    final role = email.startsWith('admin') ? 'admin' : 'client';
    user = UserProfile(id: 'u1', email: email, role: role, fullName: 'Test User');
    return null;
  }

  String? _pendingCompanyName;
  String? _pendingCompanyLocation;
  String _pendingCompanyAbout = '';
  int? _pendingCompanySince;

  @override
  Future<String?> signUp({required String email, required String password,
      required String fullName, String phone = '', String role = 'client',
      String? companyName, String? companyLocation,
      String? companyAbout, int? companySince}) async {
    user = UserProfile(id: 'u1', email: email, role: role, fullName: fullName, phone: phone);
    _pendingCompanyName = companyName;
    _pendingCompanyLocation = companyLocation;
    _pendingCompanyAbout = companyAbout ?? '';
    _pendingCompanySince = companySince;
    return null;
  }

  @override
  Future<void> signOut() async => user = null;

  @override
  Future<String?> updateProfile(String userId, {String? fullName, String? phone}) async {
    if (user != null) {
      if (fullName != null) user!.fullName = fullName;
      if (phone != null) user!.phone = phone;
    }
    return null;
  }

  @override
  Future<String?> changePassword(String newPassword) async => null;

  @override
  Future<String?> deleteAccount() async {
    user = null;
    return null;
  }

  @override
  Future<List<Company>> fetchCompanies() async => companies;

  @override
  Future<List<Offer>> fetchOffers(List<Company> _) async => offers;

  @override
  Future<Company?> fetchMyCompany(String ownerId) async =>
      companies.where((c) => c.ownerId == ownerId).firstOrNull;

  @override
  Future<Company?> createCompany({required String ownerId, required String name,
      required String location, String about = '', int? since}) async {
    final c = Company(id: 'c${companies.length + 1}', ownerId: ownerId, name: name,
        location: location, about: about, since: since ?? 2020);
    companies.add(c);
    return c;
  }

  @override
  Future<Company?> ensureAgencyCompany(String ownerId) async {
    final existing = await fetchMyCompany(ownerId);
    if (existing != null) return existing;
    final name = _pendingCompanyName;
    if (name == null || name.isEmpty) return null;
    return createCompany(ownerId: ownerId, name: name,
        location: _pendingCompanyLocation ?? '',
        about: _pendingCompanyAbout, since: _pendingCompanySince);
  }

  @override
  Future<String?> updateCompany(String id,
      {String? location, String? about, List<String>? tags, int? since}) async => null;

  @override
  Future<String?> uploadCompanyLogo(String companyId, Uint8List bytes) async => null;

  @override
  Future<Offer?> createPackage(Map<String, dynamic> fields, List<ItineraryDay> itinerary, Company company) async {
    final o = Offer(
      id: 'o${offers.length + 1}',
      companyId: fields['company_id'] as String,
      title: fields['title'] as String,
      transport: fields['transport'] as String,
      acc: fields['acc_stars'] as int,
      days: fields['days'] as int,
      price: (fields['price_iqd'] as int).toDouble(),
      gradColors: const [Colors.teal, Colors.black],
      customItinerary: itinerary,
    );
    offers.add(o);
    return o;
  }

  @override
  Future<String?> updatePackage(String id, Map<String, dynamic> fields, List<ItineraryDay> itinerary) async => null;

  @override
  Future<String?> deletePackage(String id) async {
    offers.removeWhere((o) => o.id == id);
    return null;
  }

  @override
  Future<String?> uploadPackageImage(String packageId, Uint8List bytes) async => null;

  @override
  Future<List<Booking>> fetchMyBookings(String clientId) async => List.from(bookings);

  @override
  Future<String?> createBooking({required String packageId, required String clientId,
      required int travellers, required String payMethod, DateTime? departureDate,
      String? contactPhone}) async {
    final offer = offers.firstWhere((o) => o.id == packageId);
    bookings.insert(0, Booking(
      id: 'b${bookings.length + 1}-abcdef',
      offerId: packageId,
      title: offer.title,
      titleEn: offer.titleEn,
      companyName: 'Test Co',
      gradColors: const [Colors.teal, Colors.black],
      departureDate: departureDate,
      travelers: travellers,
      status: 'Pending',
      payMethod: payMethod,
      ref: 'UM-TEST',
      total: offer.price * travellers,
    ));
    return null;
  }

  @override
  Future<String?> cancelBooking(String id) async {
    final i = bookings.indexWhere((b) => b.id == id);
    if (i < 0) return 'not found';
    bookings[i] = bookings[i].copyWith(status: 'Cancelled');
    return null;
  }

  // ── account sync (in-memory, per client id) ──────────────────────────────
  final Map<String, Set<String>> _savedByClient = {};
  final Map<String, List<PaymentCard>> _cardsByClient = {};
  final Map<String, AccountPrefs> _prefsByClient = {};

  @override
  Future<Set<String>> fetchSavedOfferIds(String clientId) async =>
      Set.from(_savedByClient[clientId] ?? const {});

  @override
  Future<void> saveOfferRemote(String clientId, String packageId) async {
    (_savedByClient[clientId] ??= {}).add(packageId);
  }

  @override
  Future<void> unsaveOfferRemote(String clientId, String packageId) async {
    _savedByClient[clientId]?.remove(packageId);
  }

  @override
  Future<List<PaymentCard>> fetchPaymentCards(String clientId) async =>
      List.from(_cardsByClient[clientId] ?? const []);

  @override
  Future<PaymentCard?> addPaymentCard(String clientId, {
    required String holder, required String last4, required String expiry,
    required String brand, required bool isDefault,
  }) async {
    final list = _cardsByClient[clientId] ??= [];
    if (isDefault) {
      for (var i = 0; i < list.length; i++) {
        list[i] = PaymentCard(id: list[i].id, holder: list[i].holder, last4: list[i].last4,
            expiry: list[i].expiry, brand: list[i].brand, isDefault: false);
      }
    }
    final card = PaymentCard(id: 'pc${list.length + 1}', holder: holder, last4: last4,
        expiry: expiry, brand: brand, isDefault: isDefault);
    list.add(card);
    return card;
  }

  @override
  Future<void> removePaymentCard(String id) async {
    for (final list in _cardsByClient.values) {
      list.removeWhere((c) => c.id == id);
    }
  }

  @override
  Future<void> setDefaultPaymentCard(String clientId, String id) async {
    final list = _cardsByClient[clientId];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      list[i] = PaymentCard(id: list[i].id, holder: list[i].holder, last4: list[i].last4,
          expiry: list[i].expiry, brand: list[i].brand, isDefault: list[i].id == id);
    }
  }

  @override
  Future<AccountPrefs> fetchAccountPrefs(String clientId) async =>
      _prefsByClient[clientId] ?? const AccountPrefs();

  @override
  Future<void> updateAccountPrefs(String clientId, {
    bool? marketingEmails, bool? twoFactorEnabled, bool? shareActivity,
  }) async {
    final cur = _prefsByClient[clientId] ?? const AccountPrefs();
    _prefsByClient[clientId] = AccountPrefs(
      marketingEmails: marketingEmails ?? cur.marketingEmails,
      twoFactorEnabled: twoFactorEnabled ?? cur.twoFactorEnabled,
      shareActivity: shareActivity ?? cur.shareActivity,
    );
  }

  // ── home ads & admin ──────────────────────────────────────────────────────
  final homeAds = <HomeAd>[];

  @override
  Future<List<HomeAd>> fetchHomeAds() async => List.from(homeAds);

  @override
  Future<HomeAd?> createHomeAd({required String title, String? packageId, String? companyId}) async {
    final ad = HomeAd(id: 'ad${homeAds.length + 1}', title: title, packageId: packageId, companyId: companyId);
    homeAds.add(ad);
    return ad;
  }

  @override
  Future<String?> updateHomeAd(String id, {String? title, bool? isActive}) async {
    final i = homeAds.indexWhere((a) => a.id == id);
    if (i < 0) return 'not found';
    homeAds[i] = HomeAd(
      id: homeAds[i].id,
      companyId: homeAds[i].companyId,
      packageId: homeAds[i].packageId,
      title: title ?? homeAds[i].title,
      imageUrl: homeAds[i].imageUrl,
      isActive: isActive ?? homeAds[i].isActive,
    );
    return null;
  }

  @override
  Future<String?> deleteHomeAd(String id) async {
    homeAds.removeWhere((a) => a.id == id);
    return null;
  }

  @override
  Future<String?> uploadAdImage(String adId, Uint8List bytes) async => null;

  @override
  Future<List<Company>> fetchPendingCompanies() async =>
      companies.where((c) => !c.isVerified).toList();

  @override
  Future<String?> setCompanyVerified(String id, bool verified) async => null;

  @override
  Future<String?> setPackageFeatured(String id, bool featured) async {
    final i = offers.indexWhere((o) => o.id == id);
    if (i < 0) return 'not found';
    final o = offers[i];
    offers[i] = Offer(
      id: o.id, companyId: o.companyId, title: o.title, titleEn: o.titleEn,
      transport: o.transport, acc: o.acc, days: o.days, price: o.price,
      original: o.original, rating: o.rating, hotel: o.hotel, badge: o.badge,
      gradColors: o.gradColors, isFeatured: featured,
    );
    return null;
  }
}

Future<AppProvider> makeProvider() async {
  final p = AppProvider(service: FakeService(), autoLoad: false);
  await p.init();
  return p;
}

Widget wrap(Widget child, AppProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  // In-memory store so provider init doesn't hang on the missing plugin.
  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  group('AppProvider with backend service', () {
    test('loads companies and offers', () async {
      final p = await makeProvider();
      expect(p.isLoading, false);
      expect(p.companies.length, 2);
      expect(p.allOffers.length, 2);
    });

    test('IQD formatting', () {
      expect(fmtIqd(2750000), '2,750,000 IQD');
      expect(fmtIqd(500), '500 IQD');
    });

    test('localized names fall back correctly', () async {
      final p = await makeProvider();
      final offer = p.allOffers.first;
      expect(offer.titleFor('en'), 'Golden Umrah');
      expect(offer.titleFor('ku'), 'عومرەی زێڕین');
      expect(offer.titleFor('ar'), 'عومرەی زێڕین'); // no Arabic → Kurdish base
    });

    test('booking requires sign-in, then persists', () async {
      final p = await makeProvider();
      final offer = p.allOffers.first;
      expect(await p.confirmBooking(offer, 2), 'auth');
      await p.signIn('client@test.com', 'pass');
      final err = await p.confirmBooking(offer, 2,
          payMethod: 'fib', departureDate: DateTime(2026, 12, 20));
      expect(err, isNull);
      expect(p.bookings.length, 1);
      expect(p.bookings.first.payMethod, 'fib');
      expect(p.bookings.first.departureDate, DateTime(2026, 12, 20));
      expect(p.bookings.first.total, 5500000);
      expect(p.notifications.first.type, NotificationType.bookingConfirmed);
    });

    test('cancel booking updates status', () async {
      final p = await makeProvider();
      await p.signIn('client@test.com', 'pass');
      await p.confirmBooking(p.allOffers.first, 1);
      final err = await p.cancelBooking(p.bookings.first.id);
      expect(err, isNull);
      expect(p.bookings.first.status, 'Cancelled');
    });

    test('agency sign-up creates company', () async {
      final p = await makeProvider();
      final err = await p.signUpAgency(
          email: 'new@agency.com', password: 'pass123',
          fullName: 'Owner', companyName: 'New Agency', companyLocation: 'Duhok');
      expect(err, isNull);
      expect(p.isAgencyUser, true);
      expect(p.agencyCompany, isNotNull);
      expect(p.agencyCompany!.isVerified, false);
    });

    test('agency package CRUD', () async {
      final p = await makeProvider();
      await p.signIn('a@a.com', 'pass');
      final offer = Offer(
        id: '', companyId: 'c1', title: 'Test Package',
        transport: 'plane', acc: 5, days: 10, price: 2000000,
        gradColors: const [Colors.teal, Colors.black],
      );
      expect(await p.addOffer(offer), true);
      expect(p.allOffers.any((o) => o.title == 'Test Package'), true);
      final created = p.allOffers.firstWhere((o) => o.title == 'Test Package');
      expect(await p.deleteOffer(created.id), true);
      expect(p.allOffers.any((o) => o.title == 'Test Package'), false);
    });

    test('getFilteredOffers preview override does not commit', () async {
      final p = await makeProvider();
      final all = p.getFilteredOffers().length;
      final byAir = p.getFilteredOffers(const OfferFilters(transport: 'plane')).length;
      expect(byAir, lessThan(all));
      expect(p.filters.transport, 'all');
    });

    test('search matches all languages and suggestions return results', () async {
      final p = await makeProvider();
      expect(p.searchOffers('Golden'), isNotEmpty);
      expect(p.searchOffers('زێڕین'), isNotEmpty);
      expect(p.searchOffers('Noor'), isNotEmpty);
      for (final s in p.searchSuggestions) {
        expect(p.searchOffers(s), isNotEmpty, reason: 'suggestion "$s" returned no results');
      }
    });

    test('sign out clears user state', () async {
      final p = await makeProvider();
      await p.signIn('client@test.com', 'pass');
      expect(p.isSignedIn, true);
      await p.signOut();
      expect(p.isSignedIn, false);
      expect(p.bookings, isEmpty);
    });

    test('saved trips sync to the account and merge guest saves on sign-in', () async {
      final shared = FakeService();
      final p = AppProvider(service: shared, autoLoad: false);
      await p.init();
      // Save one offer as a guest, before signing in.
      p.toggleSave('o1');
      expect(p.saved, ['o1']);

      await p.signIn('client@test.com', 'pass');
      // The guest-made save should have been pushed to the account, not lost.
      expect(p.saved, contains('o1'));

      // New saves while signed in go straight to the account.
      p.toggleSave('o2');
      expect(p.saved, containsAll(['o1', 'o2']));

      // A second session on the same backend for the same account sees both
      // saves immediately — this is the actual "syncs across devices" check.
      final p2 = AppProvider(service: shared, autoLoad: false);
      await p2.init();
      await p2.signIn('client@test.com', 'pass');
      expect(p2.saved, containsAll(['o1', 'o2']));
    });

    test('payment cards require sign-in and sync per account', () async {
      final p = await makeProvider();
      expect(await p.addCard(holder: 'Guest', number: '4111111111111111', expiry: '08/29'), false);
      expect(p.cards, isEmpty);

      await p.signIn('client@test.com', 'pass');
      expect(await p.addCard(holder: 'Test User', number: '4111111111111111', expiry: '08/29'), true);
      expect(p.cards, hasLength(1));
      expect(p.cards.first.isDefault, true);
      expect(p.defaultCardId, p.cards.first.id);
    });

    test('admin: home ads CRUD flows through to the home carousel list', () async {
      final p = await makeProvider();
      await p.signIn('admin@test.com', 'pass');
      expect(p.isAdminUser, true);

      expect(await p.createHomeAd(title: 'Ramadan special', packageId: 'o1'), true);
      expect(p.homeAds, hasLength(1));
      expect(p.homeAds.first.packageId, 'o1');

      // Deactivating hides it from the public carousel but not the admin list.
      await p.setAdActive(p.homeAds.first.id, false);
      expect(p.homeAds, isEmpty);
      expect(p.allHomeAds, hasLength(1));

      await p.deleteHomeAd(p.allHomeAds.first.id);
      expect(p.allHomeAds, isEmpty);
    });

    test('admin: featuring an offer reorders it to the front of home', () async {
      final p = await makeProvider();
      await p.signIn('admin@test.com', 'pass');
      // o2 is lower-rated than o1; featuring should still lift it first.
      expect(await p.setOfferFeatured('o2', true), true);
      final featured = p.allOffers.firstWhere((o) => o.id == 'o2');
      expect(featured.isFeatured, true);
    });

    test('admin: approving a pending agency removes it from the queue', () async {
      final shared = FakeService();
      shared.companies.add(Company(
          id: 'c9', ownerId: 'x', name: 'New Agency', location: 'Baghdad', isVerified: false));
      final p = AppProvider(service: shared, autoLoad: false);
      await p.init();
      await p.signIn('admin@test.com', 'pass');
      await p.loadAdminData();
      expect(p.pendingCompanies, hasLength(1));
      expect(await p.approveCompany('c9'), true);
      expect(p.pendingCompanies, isEmpty);
    });

    test('cards and cloud-synced prefs are cleared on sign out, biometric survives', () async {
      final p = await makeProvider();
      await p.signIn('client@test.com', 'pass');
      await p.addCard(holder: 'Test User', number: '4111111111111111', expiry: '08/29');
      p.setSecuritySetting('marketing', false);
      p.setSecuritySetting('biometric', true);
      expect(p.cards, isNotEmpty);

      await p.signOut();
      expect(p.cards, isEmpty);
      expect(p.marketingEmails, true); // reset to default, not leaked to next user
      expect(p.biometricLock, true); // device-level setting, unaffected by sign out
    });
  });

  group('Screens render', () {
    testWidgets('NotificationsScreen shows welcome and marks read on tap', (tester) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const NotificationsScreen(), p));
      await tester.pump();
      expect(find.text('Welcome to Umrah'), findsOneWidget);
      final unreadBefore = p.unreadNotifications;
      await tester.tap(find.text('Welcome to Umrah'));
      await tester.pump();
      expect(p.unreadNotifications, unreadBefore - 1);
    });

    testWidgets('PaymentMethodsScreen requires sign-in, then validates add-card sheet', (tester) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const PaymentMethodsScreen(), p));
      await tester.pump();
      expect(find.text('Sign in to add payment methods'), findsOneWidget);
      expect(find.text('Add card'), findsNothing);

      await p.signIn('client@test.com', 'pass');
      await tester.pumpWidget(wrap(const PaymentMethodsScreen(), p));
      await tester.pump();
      await tester.tap(find.text('Add card'));
      await tester.pumpAndSettle();
      expect(find.text('Add new card'), findsOneWidget);
      await tester.tap(find.text('Save card'));
      await tester.pump();
      expect(find.text('Enter the cardholder name.'), findsOneWidget);
    });

    testWidgets('PrivacySecurityScreen toggles update provider', (tester) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const PrivacySecurityScreen(), p));
      await tester.pump();
      // Second switch = two-factor. (The first, biometric lock, correctly
      // refuses to enable when the device has no fingerprint hardware.)
      await tester.tap(find.byType(Switch).at(1));
      await tester.pump();
      expect(p.twoFactorAuth, true);
      // Biometric toggle stays off without hardware.
      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(p.biometricLock, false);
    });

    testWidgets('HelpSupportScreen expands FAQ', (tester) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const HelpSupportScreen(), p));
      await tester.pump();
      await tester.tap(find.text('How do I book an Umrah package?'));
      await tester.pump();
      expect(find.textContaining('Book this trip'), findsOneWidget);
    });
  });
}
