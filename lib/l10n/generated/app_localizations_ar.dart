// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'عمرة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAgencies => 'الوكالات';

  @override
  String get navOffers => 'العروض';

  @override
  String get navBookings => 'الحجوزات';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageKurdish => 'الكردية';

  @override
  String get chooseLanguageTitle => 'اختر اللغة';

  @override
  String get profileSavedTrips => 'الرحلات المحفوظة';

  @override
  String get profileMyBookings => 'حجوزاتي';

  @override
  String get profileNotifications => 'الإشعارات';

  @override
  String get profilePaymentMethods => 'طرق الدفع';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profilePrivacySecurity => 'الخصوصية والأمان';

  @override
  String get profileHelpSupport => 'المساعدة والدعم';

  @override
  String get profileAgencyDivider => 'الوكالة';

  @override
  String profileAgencyDashboardWithName(String name) {
    return 'لوحة الوكالة · $name';
  }

  @override
  String get profileAgencyPortal => 'بوابة الوكالة';

  @override
  String get comingSoonBody => 'هذه الميزة ستتوفر قريبًا.';

  @override
  String get profilePilgrim => 'حاجّ';

  @override
  String get profileGoldMember => '★ عضو ذهبي';

  @override
  String get profileStatTrips => 'الرحلات';

  @override
  String get profileStatSaved => 'المحفوظات';

  @override
  String get profileStatReviews => 'التقييمات';

  @override
  String get savedTripsTitle => 'الرحلات المحفوظة';

  @override
  String get savedTripsEmptyTitle => 'لا توجد رحلات محفوظة بعد';

  @override
  String get savedTripsEmptyBody => 'اضغط على أيقونة القلب في أي عرض لحفظه.';

  @override
  String get priceFromPrefix => 'ابتداءً من ';

  @override
  String get offerDetailOverview => 'نظرة عامة';

  @override
  String offerDetailOverviewBody(
    int days,
    String transport,
    String city,
    int acc,
    String hotel,
    String distance,
    String company,
  ) {
    return 'رحلة مدتها $days أيام $transport إلى $city، تشمل الإقامة في فندق $hotel المصنّف $acc نجوم، على بُعد $distance فقط من الحرم. تتضمن إرشاد المجموعة المميز من $company، ودعمًا يوميًا للعبادة، وزيارة كاملة.';
  }

  @override
  String offerDetailDaysCount(int days) {
    return '$days أيام';
  }

  @override
  String offerDetailNightsCount(int nights) {
    return '$nights ليالٍ';
  }

  @override
  String offerDetailStarCount(int acc) {
    return '$acc نجوم';
  }

  @override
  String get offerDetailHotelLower => 'فندق';

  @override
  String get offerDetailPilgrimReviews => ' تقييمات الحجاج';

  @override
  String get offerDetailViewAgency => 'عرض الوكالة ←';

  @override
  String get offerDetailAccommodation => 'الإقامة';

  @override
  String offerDetailDistanceToHaram(String distance) {
    return '$distance إلى الحرم';
  }

  @override
  String get offerDetailRoom => 'الغرفة';

  @override
  String get offerDetailMeals => 'الوجبات';

  @override
  String get offerDetailTransportation => 'وسيلة التنقل';

  @override
  String offerDetailCarrierTransfersIncluded(String carrier) {
    return '$carrier · تشمل جميع النقلات البرية';
  }

  @override
  String get offerDetailItinerary => 'برنامج الرحلة';

  @override
  String get offerDetailWhatsIncluded => 'ما يشمله العرض';

  @override
  String get offerDetailPackagePerPerson => 'الباقة (للشخص الواحد)';

  @override
  String get offerDetailVisaProcessing => 'التأشيرة والإجراءات';

  @override
  String get offerDetailIncluded => 'مشمولة';

  @override
  String get offerDetailTaxesFees => 'الضرائب والرسوم';

  @override
  String get offerDetailTotalFrom => 'الإجمالي ابتداءً من';

  @override
  String get offerDetailFromPerPerson => 'ابتداءً من / للشخص';

  @override
  String get offerDetailBookThisTrip => 'احجز هذه الرحلة';

  @override
  String get offerDetailConfirmBooking => 'تأكيد الحجز';

  @override
  String offerDetailBookingSummaryLine(int days, String transport, int acc) {
    return '$days أيام · $transport · $acc★';
  }

  @override
  String get offerDetailTravelers => 'المسافرون';

  @override
  String offerDetailPricePerPerson(String price) {
    return '$price للشخص الواحد';
  }

  @override
  String get offerDetailTotal => 'الإجمالي';

  @override
  String get offerDetailBookingConfirmed => 'تم تأكيد الحجز!';

  @override
  String offerDetailConfirmAndPay(String total) {
    return 'تأكيد والدفع $total';
  }

  @override
  String get offerDetailFreeCancellation =>
      'إلغاء مجاني حتى 30 يومًا قبل موعد السفر';

  @override
  String get offersTitle => 'العروض';

  @override
  String offersPackagesMatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count باقة مطابقة',
      one: '$count باقة مطابقة',
    );
    return '$_temp0';
  }

  @override
  String get offersFilters => 'تصفية';

  @override
  String get offersAll => 'الكل';

  @override
  String get offersByAir => 'عن طريق الطائرة';

  @override
  String get offersByCoach => 'عن طريق الحافلة';

  @override
  String get offers5Star => '5 نجوم';

  @override
  String get offers4Star => '4 نجوم';

  @override
  String get offersSort => 'ترتيب';

  @override
  String get offersPopular => 'الأكثر طلباً';

  @override
  String get offersPriceLowToHigh => 'السعر ↑';

  @override
  String get offersPriceHighToLow => 'السعر ↓';

  @override
  String get offersNoMatches => 'لا توجد نتائج';

  @override
  String get offersTryWideningFilters => 'حاول توسيع نطاق التصفية.';

  @override
  String get offersResetFilters => 'إعادة تعيين التصفية';

  @override
  String offersDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام',
      one: '$count يوم',
    );
    return '$_temp0';
  }

  @override
  String offersStarCount(int count) {
    return '$count نجوم';
  }

  @override
  String get offersFromPricePrefix => 'ابتداءً من';

  @override
  String get filterSheetTitle => 'التصفية';

  @override
  String get filterSheetReset => 'إعادة تعيين';

  @override
  String get filterSheetMaxPricePerPerson => 'أقصى سعر / للشخص';

  @override
  String get filterSheetTransportation => 'وسيلة النقل';

  @override
  String get filterSheetAll => 'الكل';

  @override
  String get filterSheetByAir => 'عن طريق الطائرة';

  @override
  String get filterSheetByCoach => 'عن طريق الحافلة';

  @override
  String get filterSheetAccommodation => 'الإقامة';

  @override
  String get filterSheetAny => 'أي';

  @override
  String get filterSheetTripDuration => 'مدة الرحلة';

  @override
  String get filterSheetDuration7to9 => '٧–٩ أيام';

  @override
  String get filterSheetDuration10to14 => '١٠–١٤ يوماً';

  @override
  String get filterSheetDuration15Plus => '+١٥ يوماً';

  @override
  String get filterSheetAgencyRating => 'تقييم الوكالة';

  @override
  String filterSheetShowPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض $count باقة',
      one: 'عرض $count باقة',
    );
    return '$_temp0';
  }

  @override
  String get homeGreeting => 'السلام عليكم';

  @override
  String get homeWelcomePilgrim => 'أهلاً بك أيها الحاج';

  @override
  String get homeFeatured => 'مميز';

  @override
  String homeDaysStarHotel(int days, int acc) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days أيام',
      one: '$days يوم',
    );
    return '$_temp0 · فندق $acc نجوم';
  }

  @override
  String get homeSearchPlaceholder => 'ابحث عن باقات العمرة…';

  @override
  String get homeTopAgencies => 'أفضل الوكالات';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String homeRatingOffersCount(double rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عرض',
      one: '$count عرض',
    );
    return '$rating · $_temp0';
  }

  @override
  String get homeCuratedPackages => 'باقات مختارة';

  @override
  String homeDaysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days أيام',
      one: '$days يوم',
    );
    return '$_temp0';
  }

  @override
  String get homeFromPrefix => 'ابتداءً من ';

  @override
  String get searchHint => 'ابحث عن باقات، وكالات، مدن…';

  @override
  String get searchPopularSearches => 'عمليات بحث شائعة';

  @override
  String get searchSuggestionPremiumPackages => 'باقات مميزة';

  @override
  String get searchSuggestionByAir => 'بالطائرة';

  @override
  String get searchSuggestionByCoach => 'بالحافلة';

  @override
  String get searchSuggestionRamadan => 'رمضان';

  @override
  String get searchSuggestionFiveStar => 'خمس نجوم';

  @override
  String get searchSuggestionMadinah => 'المدينة المنورة';

  @override
  String get searchSuggestionFamily => 'عائلي';

  @override
  String searchNoResultsFor(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get searchTryDifferentTerm => 'جرّب اسماً أو مدينة أو فندقاً مختلفاً.';

  @override
  String get searchFromPrefix => 'ابتداءً من ';

  @override
  String get companiesTitle => 'الوكالات';

  @override
  String companiesSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منظم رحلات عمرة موثّق',
      one: '$count منظم رحلات عمرة موثّق',
    );
    return '$_temp0';
  }

  @override
  String get companiesVerifiedBadge => 'موثّقة';

  @override
  String companiesLocationEst(String location, int since) {
    return '$location · تأسست $since';
  }

  @override
  String companiesPackageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count باقة',
      one: 'باقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get companiesFromPrefix => 'تبدأ من ';

  @override
  String get companyDetailAbout => 'نبذة';

  @override
  String companyDetailPackagesHeader(int count) {
    return 'الباقات ($count)';
  }

  @override
  String companyDetailLocationSince(String location, int since) {
    return '$location · تأسست منذ $since';
  }

  @override
  String companyDetailReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييم',
      one: 'تقييم واحد',
    );
    return '$_temp0';
  }

  @override
  String get companyDetailPackagesLabel => 'الباقات';

  @override
  String get companyDetailStartingLabel => 'تبدأ من';

  @override
  String get companyDetailFromPrefix => 'تبدأ من ';

  @override
  String get bookingsTitle => 'حجوزاتي';

  @override
  String bookingsTripCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رحلة',
      one: 'رحلة واحدة',
    );
    return '$_temp0';
  }

  @override
  String bookingsPaxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسافر',
      one: 'مسافر واحد',
    );
    return '$_temp0';
  }

  @override
  String bookingsRefLabel(String ref) {
    return 'الرقم المرجعي $ref';
  }

  @override
  String get bookingsEmptyTitle => 'لا توجد حجوزات بعد';

  @override
  String get bookingsEmptyBody => 'ستظهر رحلاتك المؤكدة هنا.';

  @override
  String get bookingsBrowseOffers => 'تصفح العروض';

  @override
  String get agencyLoginTitle => 'بوابة الوكالة';

  @override
  String get agencyLoginSubtitle => 'سجّل الدخول لإدارة باقاتك وملفك الشخصي.';

  @override
  String get agencyLoginEmail => 'البريد الإلكتروني';

  @override
  String get agencyLoginPassword => 'كلمة المرور';

  @override
  String get agencyLoginInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة. جرّب: admin@alsafwah.com / pass123';

  @override
  String get agencyLoginSignIn => 'تسجيل الدخول';

  @override
  String get agencyLoginDemoCredentials => 'بيانات تجريبية';

  @override
  String get agencyLoginDemoEmail => 'البريد الإلكتروني: admin@alsafwah.com';

  @override
  String get agencyLoginDemoPassword => 'كلمة المرور: pass123';

  @override
  String get agencyLoginDemoHint =>
      '(استخدم admin@noorharamain.com وغيره للوكالات الأخرى)';

  @override
  String agencyDashboardYourPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'باقاتك ($count)',
      one: 'باقاتك (1)',
      zero: 'لا توجد باقات',
    );
    return '$_temp0';
  }

  @override
  String get agencyDashboardAddPackage => 'إضافة باقة';

  @override
  String get agencyDashboardVerificationPending => 'التحقق قيد الانتظار';

  @override
  String get agencyDashboardVerificationPendingBody =>
      'حسابك قيد المراجعة. بعد التحقق ستتمكن من نشر الباقات وتعديل ملفك الشخصي.';

  @override
  String get agencyDashboardEditProfile => 'تعديل الملف الشخصي';

  @override
  String get agencyDashboardVerifiedAgency => 'وكالة موثقة';

  @override
  String get agencyDashboardPendingVerification => 'التحقق معلّق';

  @override
  String agencyDashboardDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get agencyDashboardDeletePackageTitle => 'حذف الباقة؟';

  @override
  String agencyDashboardDeletePackageBody(String title) {
    return 'سيؤدي هذا إلى إزالة \"$title\" بشكل نهائي.';
  }

  @override
  String get agencyDashboardCancel => 'إلغاء';

  @override
  String get agencyDashboardDelete => 'حذف';

  @override
  String get agencyDashboardNoPackagesYet => 'لا توجد باقات بعد';

  @override
  String get agencyDashboardNoPackagesHint =>
      'اضغط على \"إضافة باقة\" لنشر أول عرض عمرة خاص بك.';

  @override
  String get editAgencyProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editAgencyProfileSave => 'حفظ';

  @override
  String get editAgencyProfileUpdated => 'تم تحديث الملف الشخصي!';

  @override
  String editAgencyProfileSinceReadOnly(int since) {
    return 'منذ $since · الحقول أعلاه للقراءة فقط';
  }

  @override
  String get editAgencyProfileLocationLabel => 'الموقع / المدينة';

  @override
  String get editAgencyProfileLocationHint => 'مثال: الرياض، السعودية';

  @override
  String get editAgencyProfileAboutLabel => 'نبذة عن وكالتك';

  @override
  String get editAgencyProfileAboutHint => 'صف وكالتك وتخصصاتها وتاريخها…';

  @override
  String get editAgencyProfileTagsLabel => 'الوسوم (مفصولة بفواصل)';

  @override
  String get editAgencyProfileTagsHint =>
      'مثال: مرخّصة حكومياً، متخصصة في العائلات';

  @override
  String get editAgencyProfileTagsBadgeHint =>
      'تظهر الوسوم في ملف وكالتك كشارات.';

  @override
  String get addEditOfferEditTitle => 'تعديل الباقة';

  @override
  String get addEditOfferNewTitle => 'باقة جديدة';

  @override
  String get addEditOfferSave => 'حفظ';

  @override
  String get addEditOfferAddCoverImage => 'إضافة صورة غلاف';

  @override
  String get addEditOfferChangeImage => 'تغيير الصورة';

  @override
  String get addEditOfferPackageDetails => 'تفاصيل الباقة';

  @override
  String get addEditOfferTitleField => 'العنوان *';

  @override
  String get addEditOfferTitleHint => 'مثال: مكة والمدينة المميزة';

  @override
  String get addEditOfferCitiesRoute => 'المدن / المسار';

  @override
  String get addEditOfferCitiesRouteHint => 'مثال: مكة · المدينة المنورة';

  @override
  String get addEditOfferBadgeOptional => 'الشارة (اختياري)';

  @override
  String get addEditOfferBadgeHint => 'مثال: الأكثر مبيعًا، رمضان';

  @override
  String get addEditOfferTransportStay => 'النقل والإقامة';

  @override
  String get addEditOfferTransport => 'وسيلة النقل';

  @override
  String get addEditOfferByAir => 'عن طريق الجو';

  @override
  String get addEditOfferByCoach => 'عن طريق الحافلة';

  @override
  String get addEditOfferDays => 'الأيام';

  @override
  String get addEditOfferStars => 'النجوم';

  @override
  String get addEditOfferMeals => 'الوجبات';

  @override
  String get addEditOfferHotel => 'الفندق';

  @override
  String get addEditOfferHotelName => 'اسم الفندق';

  @override
  String get addEditOfferHotelNameHint => 'مثال: كونراد مكة سويتس';

  @override
  String get addEditOfferDistanceToHaram => 'المسافة إلى الحرم';

  @override
  String get addEditOfferDistanceHint => 'مثال: 200م';

  @override
  String get addEditOfferRoomType => 'نوع الغرفة';

  @override
  String get addEditOfferRoomTypeHint => 'مثال: ديلوكس توين';

  @override
  String get addEditOfferCarrierCoach => 'شركة النقل / الحافلة';

  @override
  String get addEditOfferCarrierHint => 'مثال: السعودية، فلاي ناس';

  @override
  String get addEditOfferPricing => 'التسعير';

  @override
  String get addEditOfferPriceUsd => 'السعر (دولار) *';

  @override
  String get addEditOfferOriginalPrice => 'السعر الأصلي';

  @override
  String get addEditOfferOriginalPriceHint => '0 (اختياري)';

  @override
  String get addEditOfferItinerary => 'برنامج الرحلة';

  @override
  String get addEditOfferItineraryHelper =>
      'أضف تفصيلًا يوميًا لبرنامج الرحلة.';

  @override
  String get addEditOfferAddItineraryDay => 'إضافة يوم لبرنامج الرحلة';

  @override
  String get addEditOfferDayOneHint => 'اليوم 1';

  @override
  String get addEditOfferDayTitleHint => 'عنوان اليوم…';

  @override
  String get addEditOfferDaySummaryHint => 'صف ما يحدث في هذا اليوم…';

  @override
  String addEditOfferDayN(int n) {
    return 'اليوم $n';
  }

  @override
  String get addEditOfferWhatsIncluded => 'ما يتضمنه العرض';

  @override
  String get addEditOfferWhatsIncludedHelper => 'اذكر كل ما تتضمنه الباقة.';

  @override
  String get addEditOfferIncludeItemHint =>
      'مثال: تذاكر الطيران، إجراءات التأشيرة…';

  @override
  String get addEditOfferAddIncludedItem => 'إضافة عنصر متضمن';

  @override
  String get addEditOfferFillTitlePrice => 'يرجى إدخال العنوان وسعر صالح.';

  @override
  String get addEditOfferUpdated => 'تم تحديث الباقة!';

  @override
  String get addEditOfferPublished => 'تم نشر الباقة!';
}
