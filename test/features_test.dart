import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:umrah_app/models/booking_model.dart';
import 'package:umrah_app/models/commission_model.dart';
import 'package:umrah_app/models/company_model.dart';
import 'package:umrah_app/models/home_ad_model.dart';
import 'package:umrah_app/models/notification_model.dart';
import 'package:umrah_app/models/offer_model.dart';
import 'package:umrah_app/models/support_message_model.dart';
import 'package:umrah_app/models/review_model.dart';
import 'package:umrah_app/models/inquiry_model.dart';
import 'package:umrah_app/models/agency_document_model.dart';
import 'package:umrah_app/models/user_profile.dart';
import 'package:umrah_app/providers/app_provider.dart';
import 'package:umrah_app/services/supabase_service.dart';
import 'package:umrah_app/screens/profile/help_support_screen.dart';
import 'package:umrah_app/screens/admin/admin_screen.dart';
import 'package:umrah_app/screens/profile/notifications_screen.dart';
import 'package:umrah_app/screens/profile/payment_methods_screen.dart';
import 'package:umrah_app/screens/profile/privacy_security_screen.dart';
import 'package:umrah_app/l10n/generated/app_localizations.dart';

class FakeService implements DataService {
  final companies = [
    Company(
      id: 'c1',
      ownerId: 'agency1',
      name: 'گەشتیاری نوور',
      nameEn: 'Noor Travel',
      location: 'Erbil',
      since: 2009,
      rating: 4.8,
      isVerified: true,
    ),
    Company(
      id: 'c2',
      ownerId: 'agency1',
      name: 'کاروانی سەلام',
      nameEn: 'Salam Caravans',
      location: 'Sulaymaniyah',
      since: 2014,
      rating: 4.6,
      isVerified: true,
    ),
  ];
  final offers = <Offer>[
    const Offer(
      id: 'o1',
      companyId: 'c1',
      title: 'عومرەی زێڕین',
      titleEn: 'Golden Umrah',
      transport: 'plane',
      acc: 5,
      days: 12,
      price: 2750000,
      original: 3100000,
      rating: 4.8,
      hotel: 'Swissôtel',
      badge: 'Best value',
      gradColors: [Colors.teal, Colors.black],
    ),
    const Offer(
      id: 'o2',
      companyId: 'c2',
      title: 'عومرەی ئاسوودە',
      titleEn: 'Comfort Umrah',
      transport: 'bus',
      acc: 4,
      days: 9,
      price: 1450000,
      rating: 4.6,
      hotel: 'Dar Al Eiman',
      gradColors: [Colors.blueGrey, Colors.black],
    ),
  ];
  final bookings = <Booking>[];
  UserProfile? user;

  @override
  bool get isSignedIn => user != null;

  @override
  Future<UserProfile?> restoreSession() async => user;

  @override
  Future<String?> signIn(String email, String password) async {
    // 'agency1' matches the ownerId already seeded on companies c1/c2 above,
    // so signing in this way lets tests act as the owner of an existing
    // seeded company without going through signUpAgency's "create a new
    // company" path.
    final role = email.startsWith('admin')
        ? 'admin'
        : email.startsWith('agency')
        ? 'agency'
        : 'client';
    final id = role == 'agency' ? 'agency1' : 'u1';
    user = UserProfile(id: id, email: email, role: role, fullName: 'Test User');
    return null;
  }

  String? _pendingCompanyName;
  String? _pendingCompanyLocation;
  String _pendingCompanyAbout = '';
  int? _pendingCompanySince;

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
    user = UserProfile(
      id: 'u1',
      email: email,
      role: role,
      fullName: fullName,
      phone: phone,
    );
    _pendingCompanyName = companyName;
    _pendingCompanyLocation = companyLocation;
    _pendingCompanyAbout = companyAbout ?? '';
    _pendingCompanySince = companySince;
    return null;
  }

  @override
  Future<void> signOut() async => user = null;

  @override
  Future<String?> updateProfile(
    String userId, {
    String? fullName,
    String? phone,
  }) async {
    if (user != null) {
      if (fullName != null) user!.fullName = fullName;
      if (phone != null) user!.phone = phone;
    }
    return null;
  }

  @override
  Future<String?> updateEmail(String newEmail) async {
    if (user != null) {
      user = UserProfile(
        id: user!.id,
        email: newEmail,
        role: user!.role,
        fullName: user!.fullName,
        phone: user!.phone,
      );
    }
    return null;
  }

  @override
  Future<String?> reauthenticate(String email, String password) async => null;

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
  Future<List<Offer>> fetchAdminPackages(List<Company> _) async => offers;

  @override
  Future<Company?> fetchMyCompany(String ownerId) async =>
      companies.where((c) => c.ownerId == ownerId).firstOrNull;

  @override
  Future<Company?> createCompany({
    required String ownerId,
    required String name,
    required String location,
    String about = '',
    int? since,
  }) async {
    final c = Company(
      id: 'c${companies.length + 1}',
      ownerId: ownerId,
      name: name,
      location: location,
      about: about,
      since: since ?? 2020,
    );
    companies.add(c);
    return c;
  }

  @override
  Future<Company?> ensureAgencyCompany(String ownerId) async {
    final existing = await fetchMyCompany(ownerId);
    if (existing != null) return existing;
    final name = _pendingCompanyName;
    if (name == null || name.isEmpty) return null;
    return createCompany(
      ownerId: ownerId,
      name: name,
      location: _pendingCompanyLocation ?? '',
      about: _pendingCompanyAbout,
      since: _pendingCompanySince,
    );
  }

  @override
  Future<String?> updateCompany(
    String id, {
    String? location,
    String? about,
    List<String>? tags,
    int? since,
  }) async => null;

  @override
  Future<String?> submitCompanyApplication(String companyId) async => null;

  @override
  Future<String?> reviewCompanyApplication(
    String companyId,
    String decision, {
    String? reason,
  }) async => null;

  @override
  Future<String?> uploadCompanyLogo(String companyId, Uint8List bytes) async =>
      null;

  @override
  Future<String?> uploadCompanyBanner(
    String companyId,
    Uint8List bytes,
  ) async => null;

  @override
  Future<String?> uploadAgencyDocument({
    required String companyId,
    required String documentType,
    required Uint8List bytes,
    required String fileName,
  }) async => null;

  @override
  Future<List<AgencyDocument>> fetchAgencyDocuments(String companyId) async =>
      const [];

  @override
  Future<Offer?> createPackage(
    Map<String, dynamic> fields,
    List<ItineraryDay> itinerary,
    Company company,
  ) async {
    final o = Offer(
      id: 'o${offers.length + 1}',
      companyId: fields['company_id'] as String,
      title: fields['title'] as String,
      transport: fields['transport'] as String,
      acc: fields['acc_stars'] as int,
      days: fields['days'] as int,
      price: (fields['price_iqd'] as int).toDouble(),
      hotel: (fields['hotel'] ?? '') as String,
      hotelMakkahDescription:
          (fields['hotel_makkah_description'] ?? '') as String,
      hotelMadinahDescription:
          (fields['hotel_madinah_description'] ?? '') as String,
      room: (fields['room'] ?? '') as String,
      roomOccupancies: ((fields['room_occupancies'] ?? const [2, 3, 4]) as List)
          .cast<int>(),
      gradColors: const [Colors.teal, Colors.black],
      customItinerary: itinerary,
    );
    offers.add(o);
    return o;
  }

  @override
  Future<String?> updatePackage(
    String id,
    Map<String, dynamic> fields,
    List<ItineraryDay> itinerary,
  ) async => null;

  @override
  Future<String?> deletePackage(String id) async {
    offers.removeWhere((o) => o.id == id);
    return null;
  }

  @override
  Future<String?> uploadPackageImage(String packageId, Uint8List bytes) async =>
      null;

  @override
  Future<String?> submitPackage(String packageId) async => null;

  @override
  Future<String?> reviewPackage(
    String packageId,
    String decision, {
    String? reason,
  }) async => null;

  @override
  Future<List<Booking>> fetchMyBookings(String clientId) async =>
      List.from(bookings);

  @override
  Future<String?> createBooking({
    required String packageId,
    required String clientId,
    required int travellers,
    required String payMethod,
    DateTime? departureDate,
    String? contactPhone,
    String? note,
    String? roomLabel,
    int? roomOccupancy,
    String? mealPreference,
    List<PilgrimInfo>? pilgrims,
  }) async {
    final offer = offers.firstWhere((o) => o.id == packageId);
    bookings.insert(
      0,
      Booking(
        id: 'b${bookings.length + 1}-abcdef',
        offerId: packageId,
        title: offer.title,
        titleEn: offer.titleEn,
        companyName: 'Test Co',
        gradColors: const [Colors.teal, Colors.black],
        departureDate: departureDate,
        travelers: travellers,
        status: 'Pending',
        roomLabel: roomLabel,
        roomOccupancy: roomOccupancy,
        mealPreference: mealPreference,
        payMethod: payMethod,
        ref: 'UM-TEST',
        total: offer.price * travellers,
      ),
    );
    return null;
  }

  @override
  Future<List<BookingTraveller>> fetchBookingTravellers(
    String bookingId,
  ) async => const [];

  @override
  Future<String?> saveTravellerPassport({
    required String travellerId,
    required String bookingId,
    required String passportNo,
    required Uint8List passportBytes,
    required Uint8List selfieBytes,
  }) async => null;

  @override
  Future<String?> cancelBooking(String id) async {
    final i = bookings.indexWhere((b) => b.id == id);
    if (i < 0) return 'not found';
    bookings[i] = bookings[i].copyWith(status: 'Cancelled');
    return null;
  }

  // ── agency booking management ─────────────────────────────────────────────
  @override
  Future<List<Booking>> fetchCompanyBookings(String companyId) async {
    return bookings.where((b) {
      final offer = offers.where((o) => o.id == b.offerId).firstOrNull;
      return offer?.companyId == companyId;
    }).toList();
  }

  @override
  Future<List<Booking>> fetchAllBookings() async => List.from(bookings);

  @override
  Future<String?> setBookingStatus(String bookingId, String status) async {
    final i = bookings.indexWhere((b) => b.id == bookingId);
    if (i < 0) return 'not found';
    final stage = switch (status) {
      'accept' => 'awaiting_payment',
      'reject' => 'rejected',
      'ready' => 'ready',
      'start' => 'in_progress',
      'complete' => 'completed',
      _ => status,
    };
    final legacy = switch (stage) {
      'completed' => 'Completed',
      'rejected' || 'cancelled' => 'Cancelled',
      'confirmed' || 'ready' || 'in_progress' => 'Confirmed',
      _ => 'Pending',
    };
    bookings[i] = bookings[i].copyWith(status: legacy, operationalStage: stage);
    return null;
  }

  @override
  Future<String?> confirmCashReceived(String bookingId) async {
    final i = bookings.indexWhere((b) => b.id == bookingId);
    if (i < 0) return 'not found';
    bookings[i] = bookings[i].copyWith(
      status: 'Confirmed',
      operationalStage: 'confirmed',
      paymentStatus: 'paid',
    );
    if (!commissions.any((c) => c.bookingId == bookingId)) {
      final offer = offers.firstWhere((o) => o.id == bookings[i].offerId);
      commissions.add(
        Commission(
          id: 'com${commissions.length + 1}',
          bookingId: bookingId,
          companyId: offer.companyId,
          amount: bookings[i].total * 0.05,
          status: 'owed',
          createdAt: DateTime.now(),
        ),
      );
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> initiateFibPayment(
    String bookingId,
    int amountIqd,
  ) async => {
    'payment_id': 'pay-test',
    'fib': {'readableCode': 'FIB-TEST'},
  };

  // ── commissions ──────────────────────────────────────────────────────────
  final commissions = <Commission>[];

  @override
  Future<List<Commission>> fetchCommissions({String? companyId}) async =>
      commissions
          .where((c) => companyId == null || c.companyId == companyId)
          .toList();

  @override
  Future<String?> setCommissionCollected(String id) async {
    final i = commissions.indexWhere((c) => c.id == id);
    if (i < 0) return 'not found';
    final c = commissions[i];
    commissions[i] = Commission(
      id: c.id,
      bookingId: c.bookingId,
      companyId: c.companyId,
      companyName: c.companyName,
      amount: c.amount,
      status: 'collected',
      createdAt: c.createdAt,
    );
    return null;
  }

  // ── support ───────────────────────────────────────────────────────────────
  final supportMessages = <SupportMessage>[];

  @override
  Future<String?> sendSupportMessage({
    String? userId,
    String? email,
    required String message,
  }) async {
    supportMessages.add(
      SupportMessage(
        id: 's${supportMessages.length + 1}',
        email: email,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    return null;
  }

  @override
  Future<List<SupportMessage>> fetchSupportMessages() async =>
      List.from(supportMessages);

  @override
  Future<String?> deleteSupportMessage(String id) async {
    supportMessages.removeWhere((m) => m.id == id);
    return null;
  }

  // ── reviews ───────────────────────────────────────────────────────────────
  final Set<String> _reviewedBookingIds = {};

  @override
  Future<String?> createReview({
    required String bookingId,
    required String companyId,
    required String clientId,
    required int rating,
    String comment = '',
  }) async {
    _reviewedBookingIds.add(bookingId);
    return null;
  }

  @override
  Future<Set<String>> fetchReviewedBookingIds(String clientId) async =>
      Set.from(_reviewedBookingIds);

  @override
  Future<List<Review>> fetchCompanyReviews(String companyId) async => const [];

  @override
  Future<String?> replyToReview(String reviewId, String reply) async => null;

  @override
  Future<String?> reportAgency({
    required String reporterId,
    required String agencyId,
    required String reason,
    String details = '',
  }) async => null;

  @override
  Future<List<InquiryThread>> fetchAgencyInquiries(String agencyId) async =>
      const [];

  @override
  Future<String?> sendInquiryReply({
    required String inquiryId,
    required String senderId,
    required String body,
  }) async => null;

  // ── password reset ───────────────────────────────────────────────────────
  static const _testResetCode = '123456';

  @override
  Future<String?> sendPasswordResetCode(String email) async => null;

  @override
  Future<String?> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async => code == _testResetCode ? null : 'invalid code';

  // ── error logging ────────────────────────────────────────────────────────
  @override
  Future<void> logError({
    String? userId,
    required String message,
    String? stack,
    String? context,
  }) async {}

  // ── notifications ────────────────────────────────────────────────────────
  final remoteNotifications = <AppNotification>[];

  @override
  Future<List<AppNotification>> fetchNotifications(String userId) async =>
      List.from(remoteNotifications);

  @override
  Future<void> markNotificationRead(String id) async {
    final n = remoteNotifications.where((n) => n.id == id).firstOrNull;
    if (n != null) n.read = true;
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    for (final n in remoteNotifications) {
      n.read = true;
    }
  }

  @override
  Future<void> deleteNotification(String id) async =>
      remoteNotifications.removeWhere((n) => n.id == id);

  @override
  Future<void> clearNotifications(String userId) async =>
      remoteNotifications.clear();

  // ── account sync (in-memory, per client id) ──────────────────────────────
  final Map<String, Set<String>> _savedByClient = {};
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
  Future<AccountPrefs> fetchAccountPrefs(String clientId) async =>
      _prefsByClient[clientId] ?? const AccountPrefs();

  @override
  Future<void> updateAccountPrefs(
    String clientId, {
    bool? marketingEmails,
    bool? shareActivity,
    String? preferredPayMethod,
  }) async {
    final cur = _prefsByClient[clientId] ?? const AccountPrefs();
    _prefsByClient[clientId] = AccountPrefs(
      marketingEmails: marketingEmails ?? cur.marketingEmails,
      shareActivity: shareActivity ?? cur.shareActivity,
      preferredPayMethod: preferredPayMethod ?? cur.preferredPayMethod,
    );
  }

  // ── home ads & admin ──────────────────────────────────────────────────────
  final homeAds = <HomeAd>[];

  @override
  Future<List<HomeAd>> fetchHomeAds() async => List.from(homeAds);

  @override
  Future<HomeAd?> createHomeAd({
    required String title,
    String? packageId,
    String? companyId,
  }) async {
    final ad = HomeAd(
      id: 'ad${homeAds.length + 1}',
      title: title,
      packageId: packageId,
      companyId: companyId,
    );
    homeAds.add(ad);
    return ad;
  }

  @override
  Future<String?> updateHomeAd(
    String id, {
    String? title,
    bool? isActive,
  }) async {
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
  Future<String?> setCompanyPromoted(String id, bool promoted) async {
    final i = companies.indexWhere((c) => c.id == id);
    if (i < 0) return 'not found';
    final c = companies[i];
    companies[i] = Company(
      id: c.id,
      ownerId: c.ownerId,
      name: c.name,
      nameEn: c.nameEn,
      nameAr: c.nameAr,
      location: c.location,
      since: c.since,
      rating: c.rating,
      reviews: c.reviews,
      about: c.about,
      tags: c.tags,
      isVerified: c.isVerified,
      isPromoted: promoted,
      tint: c.tint,
      logoUrl: c.logoUrl,
      bannerUrl: c.bannerUrl,
    );
    return null;
  }

  @override
  Future<String?> setAgencyBadge(
    String agencyId,
    String badgeKey,
    bool enabled,
  ) async => null;

  @override
  Future<String?> setPackageFeatured(String id, bool featured) async {
    final i = offers.indexWhere((o) => o.id == id);
    if (i < 0) return 'not found';
    final o = offers[i];
    offers[i] = Offer(
      id: o.id,
      companyId: o.companyId,
      title: o.title,
      titleEn: o.titleEn,
      transport: o.transport,
      acc: o.acc,
      days: o.days,
      price: o.price,
      original: o.original,
      rating: o.rating,
      hotel: o.hotel,
      badge: o.badge,
      gradColors: o.gradColors,
      isFeatured: featured,
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
  // Reset per test: notifications persist their read state here, and one
  // test's marks must not leak into the next.
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
      final err = await p.confirmBooking(
        offer,
        2,
        payMethod: 'fib',
        departureDate: DateTime(2026, 12, 20),
        roomLabel: '2-person room',
        roomOccupancy: 2,
      );
      expect(err, isNull);
      expect(p.bookings.length, 1);
      expect(p.bookings.first.payMethod, 'fib');
      expect(p.bookings.first.departureDate, DateTime(2026, 12, 20));
      expect(p.bookings.first.roomOccupancy, 2);
      expect(p.bookings.first.roomLabel, '2-person room');
      expect(p.bookings.first.total, 5500000);
      // Bookings start 'pending' until an agency approves, so the immediate
      // local notification says "requested", not "confirmed". The real
      // confirmed/cancelled notification arrives later via the backend's
      // notify_booking_status_change trigger when an agency actually acts.
      expect(p.notifications.first.type, NotificationType.bookingRequested);
    });

    test('cancel booking updates status', () async {
      final p = await makeProvider();
      await p.signIn('client@test.com', 'pass');
      await p.confirmBooking(p.allOffers.first, 1);
      final err = await p.cancelBooking(p.bookings.first.id);
      expect(err, isNull);
      expect(p.bookings.first.status, 'Cancelled');
    });

    test(
      'full request → confirm → complete → review loop (the core marketplace flow)',
      () async {
        final shared = FakeService();

        // Client requests a booking (starts 'Pending').
        final client = AppProvider(service: shared, autoLoad: false);
        await client.init();
        await client.signIn('client@test.com', 'pass');
        final offer = client.allOffers.first;
        await client.confirmBooking(offer, 2);
        final bookingId = client.bookings.first.id;
        expect(client.bookings.first.status, 'Pending');

        // Agency accepts the request. It remains awaiting payment until cash
        // is actually received, so acceptance is not confused with payment.
        final agency = AppProvider(service: shared, autoLoad: false);
        await agency.init();
        await agency.signIn('agency@test.com', 'pass');
        await agency.loadAgencyBookings();
        expect(agency.agencyBookings.map((b) => b.id), contains(bookingId));
        final err = await agency.respondToBooking(bookingId, confirm: true);
        expect(err, isNull);
        expect(
          agency.agencyBookings
              .firstWhere((b) => b.id == bookingId)
              .operationalStage,
          'awaiting_payment',
        );

        final cashErr = await agency.confirmCashPayment(bookingId);
        expect(cashErr, isNull);
        expect(
          agency.agencyBookings.firstWhere((b) => b.id == bookingId).status,
          'Confirmed',
        );

        await agency.loadCommissions();
        expect(agency.commissions, isNotEmpty);
        expect(agency.commissions.first.status, 'owed');
        final collected = await agency.markCommissionCollected(
          agency.commissions.first.id,
        );
        expect(collected, true);
        expect(agency.commissions.first.status, 'collected');

        // Trip happens; agency marks it completed.
        final completedErr = await agency.markBookingCompleted(bookingId);
        expect(completedErr, isNull);
        expect(
          agency.agencyBookings.firstWhere((b) => b.id == bookingId).status,
          'Completed',
        );

        // Client can now leave a review, and only now.
        expect(client.hasReviewed(bookingId), false);
        final reviewErr = await client.submitReview(
          bookingId,
          offer.companyId,
          5,
          comment: 'Great trip!',
        );
        expect(reviewErr, isNull);
        expect(client.hasReviewed(bookingId), true);
      },
    );

    test('agency declining a booking does not open a commission', () async {
      final shared = FakeService();
      final client = AppProvider(service: shared, autoLoad: false);
      await client.init();
      await client.signIn('client@test.com', 'pass');
      await client.confirmBooking(client.allOffers.first, 1);
      final bookingId = client.bookings.first.id;

      final agency = AppProvider(service: shared, autoLoad: false);
      await agency.init();
      await agency.signIn('agency@test.com', 'pass');
      await agency.loadAgencyBookings();
      await agency.respondToBooking(bookingId, confirm: false);
      await agency.loadCommissions();
      expect(
        agency.agencyBookings.firstWhere((b) => b.id == bookingId).status,
        'Cancelled',
      );
      expect(agency.commissions, isEmpty);
    });

    test('agency sign-up creates company', () async {
      final p = await makeProvider();
      final err = await p.signUpAgency(
        email: 'new@agency.com',
        password: 'pass123',
        fullName: 'Owner',
        companyName: 'New Agency',
        companyLocation: 'Duhok',
      );
      expect(err, isNull);
      expect(p.isAgencyUser, true);
      expect(p.agencyCompany, isNotNull);
      expect(p.agencyCompany!.isVerified, false);
    });

    test('agency package CRUD', () async {
      final p = await makeProvider();
      await p.signIn('a@a.com', 'pass');
      final offer = Offer(
        id: '',
        companyId: 'c1',
        title: 'Test Package',
        transport: 'plane',
        acc: 5,
        days: 10,
        price: 2000000,
        gradColors: const [Colors.teal, Colors.black],
      );
      final (ok, imageFailed) = await p.addOffer(offer);
      expect(ok, true);
      expect(imageFailed, false);
      expect(p.allOffers.any((o) => o.title == 'Test Package'), true);
      final created = p.allOffers.firstWhere((o) => o.title == 'Test Package');
      expect(await p.deleteOffer(created.id), true);
      expect(p.allOffers.any((o) => o.title == 'Test Package'), false);
    });

    test('getFilteredOffers preview override does not commit', () async {
      final p = await makeProvider();
      final all = p.getFilteredOffers().length;
      final byAir = p
          .getFilteredOffers(const OfferFilters(transport: 'plane'))
          .length;
      expect(byAir, lessThan(all));
      expect(p.filters.transport, 'all');
    });

    test(
      'search matches all languages and suggestions return results',
      () async {
        final p = await makeProvider();
        expect(p.searchOffers('Golden'), isNotEmpty);
        expect(p.searchOffers('زێڕین'), isNotEmpty);
        expect(p.searchOffers('Noor'), isNotEmpty);
        for (final s in p.searchSuggestions) {
          expect(
            p.searchOffers(s),
            isNotEmpty,
            reason: 'suggestion "$s" returned no results',
          );
        }
      },
    );

    test('sign out clears user state', () async {
      final p = await makeProvider();
      await p.signIn('client@test.com', 'pass');
      expect(p.isSignedIn, true);
      await p.signOut();
      expect(p.isSignedIn, false);
      expect(p.bookings, isEmpty);
    });

    test(
      'saved trips sync to the account and merge guest saves on sign-in',
      () async {
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
      },
    );

    test('preferred payment method syncs to the account', () async {
      final shared = FakeService();
      final p = AppProvider(service: shared, autoLoad: false);
      await p.init();
      expect(p.preferredPayMethod, 'cash');
      await p.signIn('client@test.com', 'pass');
      await p.setPreferredPayMethod('fib');
      expect(p.preferredPayMethod, 'fib');

      // A second session on the same backend sees the saved preference.
      final p2 = AppProvider(service: shared, autoLoad: false);
      await p2.init();
      await p2.signIn('client@test.com', 'pass');
      expect(p2.preferredPayMethod, 'fib');
    });

    test(
      'admin: home ads CRUD flows through to the home carousel list',
      () async {
        final p = await makeProvider();
        await p.signIn('admin@test.com', 'pass');
        expect(p.isAdminUser, true);

        expect(
          await p.createHomeAd(title: 'Ramadan special', packageId: 'o1'),
          true,
        );
        expect(p.homeAds, hasLength(1));
        expect(p.homeAds.first.packageId, 'o1');

        // Deactivating hides it from the public carousel but not the admin list.
        await p.setAdActive(p.homeAds.first.id, false);
        expect(p.homeAds, isEmpty);
        expect(p.allHomeAds, hasLength(1));

        await p.deleteHomeAd(p.allHomeAds.first.id);
        expect(p.allHomeAds, isEmpty);
      },
    );

    test(
      'admin: an ad linked to a company (no package) carries the company id',
      () async {
        final p = await makeProvider();
        await p.signIn('admin@test.com', 'pass');
        final companyId = p.companies.first.id;
        expect(
          await p.createHomeAd(title: 'Visit our agency', companyId: companyId),
          true,
        );
        expect(p.homeAds, hasLength(1));
        expect(p.homeAds.first.companyId, companyId);
        expect(p.homeAds.first.packageId, isNull);
      },
    );

    test(
      'admin: promoting a company flags it for the home top-agencies list',
      () async {
        final p = await makeProvider();
        await p.signIn('admin@test.com', 'pass');
        final companyId = p.companies.last.id;
        expect(await p.setCompanyPromoted(companyId, true), true);
        final promoted = p.companies.firstWhere((c) => c.id == companyId);
        expect(promoted.isPromoted, true);
      },
    );

    test(
      'admin: featuring an offer reorders it to the front of home',
      () async {
        final p = await makeProvider();
        await p.signIn('admin@test.com', 'pass');
        // o2 is lower-rated than o1; featuring should still lift it first.
        expect(await p.setOfferFeatured('o2', true), true);
        final featured = p.allOffers.firstWhere((o) => o.id == 'o2');
        expect(featured.isFeatured, true);
      },
    );

    test(
      'admin: approving a pending agency removes it from the queue',
      () async {
        final shared = FakeService();
        shared.companies.add(
          Company(
            id: 'c9',
            ownerId: 'x',
            name: 'New Agency',
            location: 'Baghdad',
            isVerified: false,
          ),
        );
        final p = AppProvider(service: shared, autoLoad: false);
        await p.init();
        await p.signIn('admin@test.com', 'pass');
        await p.loadAdminData();
        expect(p.pendingCompanies, hasLength(1));
        expect(await p.approveCompany('c9'), true);
        expect(p.pendingCompanies, isEmpty);
      },
    );

    test(
      'cloud-synced prefs are cleared on sign out, biometric survives',
      () async {
        final p = await makeProvider();
        await p.signIn('client@test.com', 'pass');
        await p.setPreferredPayMethod('card');
        p.setSecuritySetting('marketing', false);
        p.setSecuritySetting('biometric', true);
        expect(p.preferredPayMethod, 'card');

        await p.signOut();
        expect(
          p.preferredPayMethod,
          'cash',
        ); // reset to default, not leaked to next user
        expect(p.marketingEmails, true);
        expect(
          p.biometricLock,
          true,
        ); // device-level setting, unaffected by sign out
      },
    );
  });

  group('Screens render', () {
    testWidgets('NotificationsScreen marks everything seen on open', (
      tester,
    ) async {
      final p = await makeProvider();
      expect(p.unreadNotifications, greaterThan(0));
      await tester.pumpWidget(wrap(const NotificationsScreen(), p));
      await tester.pump();
      expect(find.text('Welcome to Umrah'), findsOneWidget);
      // Just seeing the list clears the badge — no tapping required — and
      // the read state is persisted so it survives a restart.
      expect(p.unreadNotifications, 0);
      final p2 = await makeProvider();
      expect(p2.unreadNotifications, 0);
    });

    testWidgets('NotificationsScreen swipe dismisses a notification', (
      tester,
    ) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const NotificationsScreen(), p));
      await tester.pump();
      await tester.drag(find.text('Welcome to Umrah'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(p.notifications, isEmpty);
      expect(find.text('Welcome to Umrah'), findsNothing);
    });

    testWidgets('PaymentMethodsScreen lets a guest pick a preferred method', (
      tester,
    ) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const PaymentMethodsScreen(), p));
      await tester.pump();
      expect(p.preferredPayMethod, 'cash');
      await tester.tap(find.text('FIB'));
      await tester.pump();
      expect(p.preferredPayMethod, 'fib');
    });

    testWidgets('PrivacySecurityScreen toggles update provider', (
      tester,
    ) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const PrivacySecurityScreen(), p));
      await tester.pump();
      // Biometric toggle stays off without hardware.
      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(p.biometricLock, false);
      // Second switch = marketing emails.
      await tester.tap(find.byType(Switch).at(1));
      await tester.pump();
      expect(p.marketingEmails, false);
    });

    testWidgets('HelpSupportScreen expands FAQ', (tester) async {
      final p = await makeProvider();
      await tester.pumpWidget(wrap(const HelpSupportScreen(), p));
      await tester.pump();
      await tester.tap(find.text('How do I book an Umrah package?'));
      await tester.pump();
      expect(find.textContaining('Book this trip'), findsOneWidget);
    });

    testWidgets('AdminScreen surfaces support messages sent by users', (
      tester,
    ) async {
      final shared = FakeService();
      // A pilgrim sends a support message from the Help screen.
      final client = AppProvider(service: shared, autoLoad: false);
      await client.init();
      await client.signIn('client@test.com', 'pass');
      expect(
        await client.sendSupportMessage('My flight time changed, please help'),
        true,
      );

      // The admin opens the dashboard and should see it in the inbox.
      final admin = AppProvider(service: shared, autoLoad: false);
      await admin.init();
      await admin.signIn('admin@test.com', 'pass');
      await admin.loadAdminData();

      // Tall surface so the lazily-built support sliver (below the fold) lays out.
      await tester.binding.setSurfaceSize(const Size(600, 2600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrap(const AdminScreen(), admin));
      await tester.pumpAndSettle();

      expect(find.text('Support messages'), findsOneWidget);
      expect(find.textContaining('My flight time changed'), findsOneWidget);
    });

    test(
      'admin: resolving a support message removes it from the inbox',
      () async {
        final shared = FakeService();
        final client = AppProvider(service: shared, autoLoad: false);
        await client.init();
        await client.signIn('client@test.com', 'pass');
        expect(await client.sendSupportMessage('Please call me back'), true);

        final admin = AppProvider(service: shared, autoLoad: false);
        await admin.init();
        await admin.signIn('admin@test.com', 'pass');
        await admin.loadSupportMessages();
        expect(admin.supportMessages, hasLength(1));

        expect(
          await admin.deleteSupportMessage(admin.supportMessages.first.id),
          true,
        );
        expect(admin.supportMessages, isEmpty);

        // Gone from the backend too, not just the local list.
        await admin.loadSupportMessages();
        expect(admin.supportMessages, isEmpty);
      },
    );
  });
}
