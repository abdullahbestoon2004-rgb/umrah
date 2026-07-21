import 'dart:typed_data';

import '../models/agency_document_model.dart';
import '../models/agency_operations_model.dart';
import '../models/booking_model.dart';
import '../models/commission_model.dart';
import '../models/company_model.dart';
import '../models/home_ad_model.dart';
import '../models/inquiry_model.dart';
import '../models/notification_model.dart';
import '../models/offer_model.dart';
import '../models/review_model.dart';
import '../models/support_message_model.dart';
import '../models/user_profile.dart';
import 'api_client.dart';

class AccountPrefs {
  final bool marketingEmails;
  final bool shareActivity;
  final String preferredPayMethod;

  const AccountPrefs({
    this.marketingEmails = true,
    this.shareActivity = false,
    this.preferredPayMethod = 'cash',
  });
}

/// Backend contract used by AppProvider and by the test fakes.
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
  Future<String?> updateProfile(
    String userId, {
    String? fullName,
    String? phone,
  });
  Future<String?> updateEmail(String newEmail);
  Future<String?> reauthenticate(String email, String password);
  Future<String?> changePassword(String newPassword);
  Future<String?> deleteAccount();

  Future<List<Company>> fetchCompanies();
  Future<List<Offer>> fetchOffers(List<Company> companies);
  Future<List<Offer>> fetchCompanyPackages(
    String companyId,
    List<Company> companies,
  );
  Future<List<Offer>> fetchAdminPackages(List<Company> companies);
  Future<Company?> fetchMyCompany(String ownerId);
  Future<Company?> createCompany({
    required String ownerId,
    required String name,
    required String location,
    String about,
    int? since,
  });
  Future<Company?> ensureAgencyCompany(String ownerId);
  Future<String?> updateCompany(
    String id, {
    String? location,
    String? about,
    List<String>? tags,
    int? since,
    String? tint,
  });
  Future<String?> uploadCompanyLogo(String companyId, Uint8List bytes);
  Future<String?> uploadCompanyBanner(String companyId, Uint8List bytes);
  Future<String?> uploadAgencyDocument({
    required String companyId,
    required String documentType,
    required Uint8List bytes,
    required String fileName,
  });
  Future<List<AgencyDocument>> fetchAgencyDocuments(String companyId);
  Future<String?> submitCompanyApplication(String companyId);
  Future<String?> reviewCompanyApplication(
    String companyId,
    String decision, {
    String? reason,
  });

  Future<Offer?> createPackage(
    Map<String, dynamic> fields,
    List<ItineraryDay> itinerary,
    Company company,
  );
  Future<String?> updatePackage(
    String id,
    Map<String, dynamic> fields,
    List<ItineraryDay> itinerary,
  );
  Future<String?> deletePackage(String id);
  Future<String?> uploadPackageImage(String packageId, Uint8List bytes);
  Future<String?> submitPackage(String packageId);
  Future<String?> pausePackage(String packageId, {String? reason});
  Future<String?> reviewPackage(
    String packageId,
    String decision, {
    String? reason,
  });

  Future<List<Booking>> fetchMyBookings(String clientId);
  Future<BookingQuote> fetchBookingQuote({
    required String packageId,
    required int travellers,
    required int roomOccupancy,
  });
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
    String? requestKey,
  });
  Future<List<BookingTraveller>> fetchBookingTravellers(String bookingId);
  Future<String?> saveTravellerPassport({
    required String travellerId,
    required String bookingId,
    required Uint8List passportBytes,
    required Uint8List selfieBytes,
  });
  Future<String?> cancelBooking(String id, String reason);

  Future<Set<String>> fetchSavedOfferIds(String clientId);
  Future<void> saveOfferRemote(String clientId, String packageId);
  Future<void> unsaveOfferRemote(String clientId, String packageId);
  Future<AccountPrefs> fetchAccountPrefs(String clientId);
  Future<void> updateAccountPrefs(
    String clientId, {
    bool? marketingEmails,
    bool? shareActivity,
    String? preferredPayMethod,
  });

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
  Future<String?> setCompanyPromoted(String id, bool promoted);
  Future<String?> setPackageFeatured(String id, bool featured);
  Future<String?> setAgencyBadge(
    String agencyId,
    String badgeKey,
    bool enabled,
  );

  Future<List<AppNotification>> fetchNotifications(String userId);
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead(String userId);
  Future<void> deleteNotification(String id);
  Future<void> clearNotifications(String userId);

  Future<List<Booking>> fetchCompanyBookings(String companyId);
  Future<List<Booking>> fetchAllBookings();
  Future<String?> setBookingStatus(
    String bookingId,
    String status, {
    String? reason,
  });
  Future<String?> confirmCashReceived(String bookingId);
  Future<Map<String, dynamic>?> initiateFibPayment(
    String bookingId,
    int amountIqd,
  );

  Future<AgencyWallet> fetchAgencyWallet(String companyId);
  Future<List<BookingTraveller>> fetchTripTravellers(String packageId);
  Future<List<TravellerDocument>> fetchTravellerDocuments(String bookingId);
  Future<String?> travellerDocumentUrl(String storagePath);
  Future<String?> uploadTravellerDocument({
    required String travellerId,
    required String bookingId,
    required String companyId,
    required String kind,
    required Uint8List bytes,
    required String fileName,
  });
  Future<String?> updateTravellerOperations({
    required String travellerId,
    String? documentStatus,
    String? documentReason,
    String? visaStatus,
    String? visaReference,
    String? visaReason,
    String? transportSeat,
  });
  Future<String?> reviewTravellerDocument({
    required String documentId,
    required String status,
    String? reason,
    DateTime? expiresOn,
  });
  Future<List<TripAnnouncement>> fetchTripAnnouncements(String packageId);
  Future<String?> createTripAnnouncement({
    required String packageId,
    required String companyId,
    required String title,
    required String body,
    required String audience,
  });
  Future<List<TripRoom>> fetchTripRooms(String packageId);
  Future<String?> createTripRoom({
    required String packageId,
    required String companyId,
    required String city,
    required String label,
    required int capacity,
    required String genderPolicy,
  });
  Future<String?> deleteTripRoom(String roomId);
  Future<String?> assignTravellerRoom({
    required String roomId,
    required String travellerId,
  });
  Future<List<TripTransportSegment>> fetchTripTransport(String packageId);
  Future<String?> createTripTransport({
    required String packageId,
    required String companyId,
    required Map<String, dynamic> fields,
  });
  Future<String?> deleteTripTransport(String segmentId);
  Future<List<AgencyStaffMember>> fetchAgencyStaff(String companyId);
  Future<String?> addAgencyStaff({
    required String companyId,
    required String userId,
    required String role,
    required List<String> permissions,
  });
  Future<String?> removeAgencyStaff(String membershipId);

  Future<List<Commission>> fetchCommissions({String? companyId});
  Future<String?> setCommissionCollected(String id);
  Future<String?> sendSupportMessage({
    String? userId,
    String? email,
    required String message,
  });
  Future<List<SupportMessage>> fetchSupportMessages();
  Future<String?> deleteSupportMessage(String id);
  Future<String?> createReview({
    required String bookingId,
    required String companyId,
    required String clientId,
    required int rating,
    String comment,
  });
  Future<Set<String>> fetchReviewedBookingIds(String clientId);
  Future<List<Review>> fetchCompanyReviews(String companyId);
  Future<String?> replyToReview(String reviewId, String reply);
  Future<String?> reportAgency({
    required String reporterId,
    required String agencyId,
    required String reason,
    String details,
  });
  Future<List<InquiryThread>> fetchAgencyInquiries(String agencyId);
  Future<String?> sendInquiryReply({
    required String inquiryId,
    required String senderId,
    required String body,
  });
  Future<String?> sendPasswordResetCode(String email);
  Future<String?> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  });

  // ── push notification device tokens ──────────────────────────────────────
  /// Binds this handset's push token to the signed-in user.
  Future<void> registerDeviceToken(String token, String platform);

  /// Stops delivery to this handset (called on sign-out).
  Future<void> unregisterDeviceToken(String token);

  Future<void> logError({
    String? userId,
    required String message,
    String? stack,
    String? context,
  });
}

class PhpApiService implements DataService {
  PhpApiService({ApiClient? client}) : _api = client ?? ApiClient.shared;

  final ApiClient _api;

  @override
  bool get isSignedIn => _api.hasToken;

  UserProfile _profile(Map<String, dynamic> row) => UserProfile(
    id: row['id'] as String,
    email: (row['email'] ?? '') as String,
    role: (row['role'] ?? 'client') as String,
    fullName: (row['full_name'] ?? '') as String,
    phone: (row['phone'] ?? '') as String,
  );

  List<Map<String, dynamic>> _rows(dynamic data) => (data as List)
      .map((row) => Map<String, dynamic>.from(row as Map))
      .toList();

  Map<String, dynamic> _compact(Map<String, dynamic> values) =>
      Map.fromEntries(values.entries.where((entry) => entry.value != null));

  Future<String?> _mutate(Future<dynamic> Function() action) async {
    try {
      await action();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    }
  }

  @override
  Future<UserProfile?> restoreSession() async {
    try {
      final data = await _api.get('auth/me');
      return _profile(Map<String, dynamic>.from(data as Map));
    } on ApiException catch (error) {
      if (error.statusCode == 401) return null;
      rethrow;
    }
  }

  @override
  Future<String?> signIn(String email, String password) async {
    try {
      final data = Map<String, dynamic>.from(
        await _api.post(
              'auth/login',
              body: {
                'email': email,
                'password': password,
                'device_label': 'Tawaf Flutter app',
              },
            )
            as Map,
      );
      await _api.setToken(data['token'] as String?);
      return null;
    } on ApiException catch (error) {
      return error.message;
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
      final data = Map<String, dynamic>.from(
        await _api.post(
              'auth/register',
              body: {
                'email': email,
                'password': password,
                'full_name': fullName,
                'phone': phone,
                'role': role,
                'company_name': companyName,
                'company_location': companyLocation,
                'company_about': companyAbout,
                'company_since': companySince,
              },
            )
            as Map,
      );
      await _api.setToken(data['token'] as String?);
      return null;
    } on ApiException catch (error) {
      return error.message;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _api.post('auth/logout');
    } finally {
      await _api.setToken(null);
    }
  }

  @override
  Future<String?> updateProfile(
    String userId, {
    String? fullName,
    String? phone,
  }) => _mutate(
    () => _api.patch(
      'auth/profile',
      body: _compact({'full_name': fullName, 'phone': phone}),
    ),
  );

  @override
  Future<String?> updateEmail(String newEmail) =>
      _mutate(() => _api.patch('auth/email', body: {'email': newEmail}));

  @override
  Future<String?> reauthenticate(String email, String password) => _mutate(
    () => _api.post('auth/reauthenticate', body: {'password': password}),
  );

  @override
  Future<String?> changePassword(String newPassword) => _mutate(
    () => _api.patch('auth/password', body: {'password': newPassword}),
  );

  @override
  Future<String?> deleteAccount() => _mutate(() => _api.delete('auth/delete'));

  @override
  Future<List<Company>> fetchCompanies() async =>
      _rows(await _api.get('companies')).map(Company.fromRow).toList();

  @override
  Future<List<Offer>> fetchOffers(List<Company> companies) async {
    final byId = {for (final company in companies) company.id: company};
    return _rows(await _api.get('packages'))
        .map((row) => Offer.fromRow(row, company: byId[row['company_id']]))
        .toList();
  }

  @override
  Future<List<Offer>> fetchCompanyPackages(
    String companyId,
    List<Company> companies,
  ) async {
    final byId = {for (final company in companies) company.id: company};
    return _rows(
          await _api.get('packages/company', query: {'company_id': companyId}),
        )
        .map((row) => Offer.fromRow(row, company: byId[row['company_id']]))
        .toList();
  }

  @override
  Future<List<Offer>> fetchAdminPackages(List<Company> companies) async {
    final byId = {for (final company in companies) company.id: company};
    return _rows(await _api.get('packages/admin'))
        .map((row) => Offer.fromRow(row, company: byId[row['company_id']]))
        .toList();
  }

  @override
  Future<Company?> fetchMyCompany(String ownerId) async {
    final data = await _api.get('companies/mine');
    return data == null
        ? null
        : Company.fromRow(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<Company?> ensureAgencyCompany(String ownerId) =>
      fetchMyCompany(ownerId);

  @override
  Future<Company?> createCompany({
    required String ownerId,
    required String name,
    required String location,
    String about = '',
    int? since,
  }) async {
    try {
      final data = await _api.post(
        'companies/create',
        body: {
          'name': name,
          'location': location,
          'about': about,
          'since': since,
        },
      );
      return Company.fromRow(Map<String, dynamic>.from(data as Map));
    } on ApiException {
      return null;
    }
  }

  @override
  Future<String?> updateCompany(
    String id, {
    String? location,
    String? about,
    List<String>? tags,
    int? since,
    String? tint,
  }) => _mutate(
    () => _api.patch(
      'companies/update',
      body: _compact({
        'id': id,
        'location': location,
        'about': about,
        'tags': tags,
        'since': since,
        'tint': tint,
      }),
    ),
  );

  Future<String?> _uploadImage(
    String route,
    String idField,
    String id,
    Uint8List bytes,
  ) async {
    try {
      final data = Map<String, dynamic>.from(
        await _api.multipart(
              route,
              fields: {idField: id},
              files: {'file': bytes},
            )
            as Map,
      );
      return data['url'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> uploadCompanyLogo(String companyId, Uint8List bytes) =>
      _uploadImage('companies/logo', 'company_id', companyId, bytes);

  @override
  Future<String?> uploadCompanyBanner(String companyId, Uint8List bytes) =>
      _uploadImage('companies/banner', 'company_id', companyId, bytes);

  @override
  Future<String?> uploadAgencyDocument({
    required String companyId,
    required String documentType,
    required Uint8List bytes,
    required String fileName,
  }) => _mutate(
    () => _api.multipart(
      'companies/documents/upload',
      fields: {'company_id': companyId, 'document_type': documentType},
      files: {'file': bytes},
      fileNames: {'file': fileName},
    ),
  );

  @override
  Future<List<AgencyDocument>> fetchAgencyDocuments(String companyId) async =>
      _rows(
            await _api.get(
              'companies/documents',
              query: {'company_id': companyId},
            ),
          )
          .map(
            (row) => AgencyDocument.fromRow(
              row,
              previewUrl: row['preview_url'] as String?,
            ),
          )
          .toList();

  @override
  Future<String?> submitCompanyApplication(String companyId) => _mutate(
    () => _api.post('companies/submit', body: {'company_id': companyId}),
  );

  @override
  Future<String?> reviewCompanyApplication(
    String companyId,
    String decision, {
    String? reason,
  }) => _mutate(
    () => _api.post(
      'companies/review',
      body: {'company_id': companyId, 'decision': decision, 'reason': reason},
    ),
  );

  Map<String, dynamic> _packagePayload(
    Map<String, dynamic> source,
    List<ItineraryDay> itinerary,
  ) {
    final fields = Map<String, dynamic>.from(source);
    final pricing = fields.remove('_pricing') ?? const [];
    final hotels = fields.remove('_hotels') ?? const [];
    final inclusions = fields.remove('_inclusions') ?? const [];
    return {
      'fields': fields,
      'itinerary': [
        for (var index = 0; index < itinerary.length; index++)
          {
            'day_no': index + 1,
            'title': itinerary[index].title,
            'summary': itinerary[index].summary,
          },
      ],
      'pricing': pricing,
      'hotels': hotels,
      'inclusions': inclusions,
    };
  }

  @override
  Future<Offer?> createPackage(
    Map<String, dynamic> fields,
    List<ItineraryDay> itinerary,
    Company company,
  ) async {
    try {
      final data = await _api.post(
        'packages/create',
        body: _packagePayload(fields, itinerary),
      );
      return Offer.fromRow(
        Map<String, dynamic>.from(data as Map),
        company: company,
      );
    } on ApiException {
      return null;
    }
  }

  @override
  Future<String?> updatePackage(
    String id,
    Map<String, dynamic> fields,
    List<ItineraryDay> itinerary,
  ) {
    final payload = _packagePayload(fields, itinerary)..['id'] = id;
    return _mutate(() => _api.patch('packages/update', body: payload));
  }

  @override
  Future<String?> deletePackage(String id) =>
      _mutate(() => _api.delete('packages/delete', body: {'id': id}));

  @override
  Future<String?> uploadPackageImage(String packageId, Uint8List bytes) =>
      _uploadImage('packages/image', 'package_id', packageId, bytes);

  @override
  Future<String?> submitPackage(String packageId) => _mutate(
    () => _api.post('packages/submit', body: {'package_id': packageId}),
  );

  @override
  Future<String?> pausePackage(String packageId, {String? reason}) => _mutate(
    () => _api.post(
      'packages/pause',
      body: {'package_id': packageId, 'reason': reason},
    ),
  );

  @override
  Future<String?> reviewPackage(
    String packageId,
    String decision, {
    String? reason,
  }) => _mutate(
    () => _api.post(
      'packages/review',
      body: {'package_id': packageId, 'decision': decision, 'reason': reason},
    ),
  );

  @override
  Future<List<Booking>> fetchMyBookings(String clientId) async =>
      _rows(await _api.get('bookings/mine')).map(Booking.fromRow).toList();

  @override
  Future<BookingQuote> fetchBookingQuote({
    required String packageId,
    required int travellers,
    required int roomOccupancy,
  }) async => BookingQuote.fromJson(
    Map<String, dynamic>.from(
      await _api.get(
            'bookings/quote',
            query: {
              'package_id': packageId,
              'travellers': travellers,
              'room_occupancy': roomOccupancy,
            },
          )
          as Map,
    ),
  );

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
    String? requestKey,
  }) => _mutate(
    () => _api.post(
      'bookings/create',
      body: {
        'package_id': packageId,
        'travellers': travellers,
        'pay_method': payMethod,
        'contact_phone': contactPhone,
        'note': note,
        'room_label': roomLabel,
        'room_occupancy': roomOccupancy,
        'meal_preference': mealPreference,
        'request_key': requestKey,
        'pilgrims': [
          for (var index = 0; index < (pilgrims ?? const []).length; index++)
            {
              'full_name': pilgrims![index].fullName,
              'local_name': pilgrims[index].localName,
              'passport_no': pilgrims[index].passportNo,
              'date_of_birth': pilgrims[index].dateOfBirth
                  ?.toIso8601String()
                  .substring(0, 10),
              'phone': pilgrims[index].phone,
              'is_lead': index == 0,
            },
        ],
      },
    ),
  );

  @override
  Future<List<BookingTraveller>> fetchBookingTravellers(
    String bookingId,
  ) async => _rows(
    await _api.get('bookings/travellers', query: {'booking_id': bookingId}),
  ).map(BookingTraveller.fromRow).toList();

  @override
  Future<String?> saveTravellerPassport({
    required String travellerId,
    required String bookingId,
    required Uint8List passportBytes,
    required Uint8List selfieBytes,
  }) => _mutate(
    () => _api.multipart(
      'bookings/passports',
      fields: {'traveller_id': travellerId, 'booking_id': bookingId},
      files: {'passport': passportBytes, 'selfie': selfieBytes},
      fileNames: {'passport': 'passport.jpg', 'selfie': 'selfie.jpg'},
    ),
  );

  @override
  Future<String?> cancelBooking(String id, String reason) => _mutate(
    () => _api.post(
      'bookings/cancel',
      body: {'booking_id': id, 'reason': reason},
    ),
  );

  @override
  Future<Set<String>> fetchSavedOfferIds(String clientId) async =>
      ((await _api.get('saved')) as List).cast<String>().toSet();

  @override
  Future<void> saveOfferRemote(String clientId, String packageId) async {
    await _api.post('saved', body: {'package_id': packageId});
  }

  @override
  Future<void> unsaveOfferRemote(String clientId, String packageId) async {
    await _api.delete('saved', body: {'package_id': packageId});
  }

  @override
  Future<AccountPrefs> fetchAccountPrefs(String clientId) async {
    final data = Map<String, dynamic>.from(
      await _api.get('preferences') as Map,
    );
    return AccountPrefs(
      marketingEmails: (data['marketing_emails'] ?? true) as bool,
      shareActivity: (data['share_activity'] ?? false) as bool,
      preferredPayMethod: (data['preferred_pay_method'] ?? 'cash') as String,
    );
  }

  @override
  Future<void> updateAccountPrefs(
    String clientId, {
    bool? marketingEmails,
    bool? shareActivity,
    String? preferredPayMethod,
  }) async {
    await _api.patch(
      'preferences',
      body: _compact({
        'marketing_emails': marketingEmails,
        'share_activity': shareActivity,
        'preferred_pay_method': preferredPayMethod,
      }),
    );
  }

  @override
  Future<List<HomeAd>> fetchHomeAds() async =>
      _rows(await _api.get('ads')).map(HomeAd.fromRow).toList();

  @override
  Future<HomeAd?> createHomeAd({
    required String title,
    String? packageId,
    String? companyId,
  }) async {
    try {
      return HomeAd.fromRow(
        Map<String, dynamic>.from(
          await _api.post(
                'ads/create',
                body: {
                  'title': title,
                  'package_id': packageId,
                  'company_id': companyId,
                },
              )
              as Map,
        ),
      );
    } on ApiException {
      return null;
    }
  }

  @override
  Future<String?> updateHomeAd(String id, {String? title, bool? isActive}) =>
      _mutate(
        () => _api.patch(
          'ads/update',
          body: _compact({'id': id, 'title': title, 'is_active': isActive}),
        ),
      );

  @override
  Future<String?> deleteHomeAd(String id) =>
      _mutate(() => _api.delete('ads/delete', body: {'id': id}));

  @override
  Future<String?> uploadAdImage(String adId, Uint8List bytes) =>
      _uploadImage('ads/image', 'ad_id', adId, bytes);

  @override
  Future<List<Company>> fetchPendingCompanies() async =>
      _rows(await _api.get('companies/pending')).map(Company.fromRow).toList();

  @override
  Future<String?> setCompanyVerified(String id, bool verified) =>
      reviewCompanyApplication(
        id,
        verified ? 'approved' : 'rejected',
        reason: verified ? null : 'Application declined by administrator',
      );

  @override
  Future<String?> setCompanyPromoted(String id, bool promoted) => _mutate(
    () => _api.post(
      'companies/promote',
      body: {'company_id': id, 'value': promoted},
    ),
  );

  @override
  Future<String?> setPackageFeatured(String id, bool featured) => _mutate(
    () => _api.post(
      'packages/featured',
      body: {'package_id': id, 'value': featured},
    ),
  );

  @override
  Future<String?> setAgencyBadge(
    String agencyId,
    String badgeKey,
    bool enabled,
  ) => _mutate(
    () => _api.post(
      'companies/badge',
      body: {'company_id': agencyId, 'badge_key': badgeKey, 'enabled': enabled},
    ),
  );

  @override
  Future<List<AppNotification>> fetchNotifications(String userId) async =>
      _rows(
        await _api.get('notifications'),
      ).map(AppNotification.fromRow).toList();

  @override
  Future<void> markNotificationRead(String id) async {
    await _api.post('notifications/read', body: {'id': id});
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    await _api.post('notifications/read-all');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _api.delete('notifications/delete', body: {'id': id});
  }

  @override
  Future<void> clearNotifications(String userId) async {
    await _api.delete('notifications/clear');
  }

  @override
  Future<List<Booking>> fetchCompanyBookings(String companyId) async => _rows(
    await _api.get('bookings/company', query: {'company_id': companyId}),
  ).map(Booking.fromRow).toList();

  @override
  Future<List<Booking>> fetchAllBookings() async =>
      _rows(await _api.get('bookings/admin')).map(Booking.fromRow).toList();

  @override
  Future<String?> setBookingStatus(
    String bookingId,
    String status, {
    String? reason,
  }) => _mutate(
    () => _api.post(
      'bookings/status',
      body: {'booking_id': bookingId, 'action': status, 'reason': reason},
    ),
  );

  @override
  Future<String?> confirmCashReceived(String bookingId) => _mutate(
    () => _api.post('bookings/cash', body: {'booking_id': bookingId}),
  );

  @override
  Future<Map<String, dynamic>?> initiateFibPayment(
    String bookingId,
    int amountIqd,
  ) async {
    try {
      final data = await _api.post(
        'payments/fib/create',
        body: {
          'booking_id': bookingId,
          'amount_iqd': amountIqd,
          'idempotency_key': 'fib-$bookingId-$amountIqd',
        },
      );
      return Map<String, dynamic>.from(data as Map);
    } on ApiException {
      return null;
    }
  }

  @override
  Future<AgencyWallet> fetchAgencyWallet(String companyId) async {
    try {
      final data = Map<String, dynamic>.from(
        await _api.get('wallet', query: {'company_id': companyId}) as Map,
      );
      return AgencyWallet(
        balanceIqd: ((data['balance_iqd'] ?? 0) as num).toDouble(),
        entries: ((data['entries'] ?? const []) as List)
            .map(
              (row) => AgencyLedgerEntry.fromRow(
                Map<String, dynamic>.from(row as Map),
              ),
            )
            .toList(),
        payouts: ((data['payouts'] ?? const []) as List)
            .map(
              (row) =>
                  AgencyPayout.fromRow(Map<String, dynamic>.from(row as Map)),
            )
            .toList(),
      );
    } on ApiException {
      return const AgencyWallet();
    }
  }

  @override
  Future<List<BookingTraveller>> fetchTripTravellers(String packageId) async =>
      _rows(
        await _api.get('trips/travellers', query: {'package_id': packageId}),
      ).map(BookingTraveller.fromRow).toList();

  @override
  Future<List<TravellerDocument>> fetchTravellerDocuments(
    String bookingId,
  ) async => _rows(
    await _api.get('trips/documents', query: {'booking_id': bookingId}),
  ).map(TravellerDocument.fromRow).toList();

  @override
  Future<String?> travellerDocumentUrl(String storagePath) async {
    try {
      final data = Map<String, dynamic>.from(
        await _api.get('trips/document-url', query: {'path': storagePath})
            as Map,
      );
      return data['url'] as String?;
    } on ApiException {
      return null;
    }
  }

  @override
  Future<String?> uploadTravellerDocument({
    required String travellerId,
    required String bookingId,
    required String companyId,
    required String kind,
    required Uint8List bytes,
    required String fileName,
  }) => _mutate(
    () => _api.multipart(
      'trips/documents/upload',
      fields: {
        'traveller_id': travellerId,
        'booking_id': bookingId,
        'company_id': companyId,
        'kind': kind,
      },
      files: {'file': bytes},
      fileNames: {'file': fileName},
    ),
  );

  @override
  Future<String?> updateTravellerOperations({
    required String travellerId,
    String? documentStatus,
    String? documentReason,
    String? visaStatus,
    String? visaReference,
    String? visaReason,
    String? transportSeat,
  }) => _mutate(
    () => _api.patch(
      'trips/traveller-update',
      body: _compact({
        'traveller_id': travellerId,
        'document_status': documentStatus,
        'document_reason': documentReason,
        'visa_status': visaStatus,
        'visa_reference': visaReference,
        'visa_reason': visaReason,
        'transport_seat': transportSeat,
      }),
    ),
  );

  @override
  Future<String?> reviewTravellerDocument({
    required String documentId,
    required String status,
    String? reason,
    DateTime? expiresOn,
  }) => _mutate(
    () => _api.post(
      'trips/documents/review',
      body: {
        'document_id': documentId,
        'status': status,
        'reason': reason,
        'expires_on': expiresOn?.toIso8601String().substring(0, 10),
      },
    ),
  );

  @override
  Future<List<TripAnnouncement>> fetchTripAnnouncements(
    String packageId,
  ) async => _rows(
    await _api.get('trips/announcements', query: {'package_id': packageId}),
  ).map(TripAnnouncement.fromRow).toList();

  @override
  Future<String?> createTripAnnouncement({
    required String packageId,
    required String companyId,
    required String title,
    required String body,
    required String audience,
  }) => _mutate(
    () => _api.post(
      'trips/announcements',
      body: {
        'package_id': packageId,
        'company_id': companyId,
        'title': title,
        'body': body,
        'audience': audience,
      },
    ),
  );

  @override
  Future<List<TripRoom>> fetchTripRooms(String packageId) async => _rows(
    await _api.get('trips/rooms', query: {'package_id': packageId}),
  ).map(TripRoom.fromRow).toList();

  @override
  Future<String?> createTripRoom({
    required String packageId,
    required String companyId,
    required String city,
    required String label,
    required int capacity,
    required String genderPolicy,
  }) => _mutate(
    () => _api.post(
      'trips/rooms/create',
      body: {
        'package_id': packageId,
        'company_id': companyId,
        'city': city,
        'label': label,
        'capacity': capacity,
        'gender_policy': genderPolicy,
      },
    ),
  );

  @override
  Future<String?> deleteTripRoom(String roomId) => _mutate(
    () => _api.delete('trips/rooms/delete', body: {'room_id': roomId}),
  );

  @override
  Future<String?> assignTravellerRoom({
    required String roomId,
    required String travellerId,
  }) => _mutate(
    () => _api.post(
      'trips/rooms/assign',
      body: {'room_id': roomId, 'traveller_id': travellerId},
    ),
  );

  @override
  Future<List<TripTransportSegment>> fetchTripTransport(
    String packageId,
  ) async => _rows(
    await _api.get('trips/transport', query: {'package_id': packageId}),
  ).map(TripTransportSegment.fromRow).toList();

  @override
  Future<String?> createTripTransport({
    required String packageId,
    required String companyId,
    required Map<String, dynamic> fields,
  }) => _mutate(
    () => _api.post(
      'trips/transport/create',
      body: {...fields, 'package_id': packageId, 'company_id': companyId},
    ),
  );

  @override
  Future<String?> deleteTripTransport(String segmentId) => _mutate(
    () =>
        _api.delete('trips/transport/delete', body: {'segment_id': segmentId}),
  );

  @override
  Future<List<AgencyStaffMember>> fetchAgencyStaff(String companyId) async =>
      _rows(
        await _api.get('agency/staff', query: {'company_id': companyId}),
      ).map(AgencyStaffMember.fromRow).toList();

  @override
  Future<String?> addAgencyStaff({
    required String companyId,
    required String userId,
    required String role,
    required List<String> permissions,
  }) => _mutate(
    () => _api.post(
      'agency/staff/add',
      body: {
        'company_id': companyId,
        'user_id': userId,
        'role': role,
        'permissions': permissions,
      },
    ),
  );

  @override
  Future<String?> removeAgencyStaff(String membershipId) => _mutate(
    () => _api.delete(
      'agency/staff/remove',
      body: {'membership_id': membershipId},
    ),
  );

  @override
  Future<List<Commission>> fetchCommissions({String? companyId}) async => _rows(
    await _api.get(
      'commissions',
      query: companyId == null ? null : {'company_id': companyId},
    ),
  ).map(Commission.fromRow).toList();

  @override
  Future<String?> setCommissionCollected(String id) =>
      _mutate(() => _api.post('commissions/collect', body: {'id': id}));

  @override
  Future<String?> sendSupportMessage({
    String? userId,
    String? email,
    required String message,
  }) => _mutate(
    () => _api.post('support/send', body: {'email': email, 'message': message}),
  );

  @override
  Future<List<SupportMessage>> fetchSupportMessages() async =>
      _rows(await _api.get('support')).map(SupportMessage.fromRow).toList();

  @override
  Future<String?> deleteSupportMessage(String id) =>
      _mutate(() => _api.post('support/resolve', body: {'id': id}));

  @override
  Future<String?> createReview({
    required String bookingId,
    required String companyId,
    required String clientId,
    required int rating,
    String comment = '',
  }) => _mutate(
    () => _api.post(
      'reviews/create',
      body: {
        'booking_id': bookingId,
        'company_id': companyId,
        'rating': rating,
        'comment': comment,
      },
    ),
  );

  @override
  Future<Set<String>> fetchReviewedBookingIds(String clientId) async =>
      ((await _api.get('reviews/reviewed')) as List).cast<String>().toSet();

  @override
  Future<List<Review>> fetchCompanyReviews(String companyId) async => _rows(
    await _api.get('reviews/company', query: {'company_id': companyId}),
  ).map(Review.fromRow).toList();

  @override
  Future<String?> replyToReview(String reviewId, String reply) => _mutate(
    () => _api.post(
      'reviews/reply',
      body: {'review_id': reviewId, 'reply': reply},
    ),
  );

  @override
  Future<String?> reportAgency({
    required String reporterId,
    required String agencyId,
    required String reason,
    String details = '',
  }) => _mutate(
    () => _api.post(
      'reports/create',
      body: {'agency_id': agencyId, 'reason': reason, 'details': details},
    ),
  );

  @override
  Future<List<InquiryThread>> fetchAgencyInquiries(String agencyId) async =>
      _rows(
        await _api.get('inquiries/agency', query: {'agency_id': agencyId}),
      ).map(InquiryThread.fromRow).toList();

  @override
  Future<String?> sendInquiryReply({
    required String inquiryId,
    required String senderId,
    required String body,
  }) => _mutate(
    () => _api.post(
      'inquiries/reply',
      body: {'inquiry_id': inquiryId, 'body': body},
    ),
  );

  @override
  Future<String?> sendPasswordResetCode(String email) =>
      _mutate(() => _api.post('auth/password/forgot', body: {'email': email}));

  @override
  Future<String?> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) => _mutate(
    () => _api.post(
      'auth/password/reset',
      body: {'email': email, 'code': code, 'password': newPassword},
    ),
  );

  @override
  Future<void> logError({
    String? userId,
    required String message,
    String? stack,
    String? context,
  }) async {
    try {
      await _api.post(
        'errors/log',
        body: {'message': message, 'stack': stack, 'context': context},
      );
    } catch (_) {}
  }

  @override
  Future<void> registerDeviceToken(String token, String platform) async {
    try {
      await _api.post(
        'devices/register',
        body: {'token': token, 'platform': platform},
      );
    } catch (_) {}
  }

  @override
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _api.post('devices/unregister', body: {'token': token});
    } catch (_) {}
  }
}
