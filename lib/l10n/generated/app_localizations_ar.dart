// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'طواف';

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
  String get profileAgencyPortal => 'بوابة الوكالة والمشرف';

  @override
  String get profileAdminDashboard => 'لوحة المشرف';

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
  String get offerDetailReturnFlightsEconomy =>
      'رحلات ذهاب وعودة، درجة اقتصادية';

  @override
  String get offerDetailLuxuryCoach => 'حافلة فاخرة مكيفة';

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
  String get offerDetailFreeCancellation => 'راجع سياسة إلغاء هذه الرحلة';

  @override
  String get offerDetailDepartureDate => 'تاريخ المغادرة';

  @override
  String get dateToBeScheduled => 'يُحدد لاحقًا';

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
  String get homeSponsored => 'إعلان ممول';

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
  String get homeNoTripsTitle => 'رحلات جديدة قريباً';

  @override
  String get homeNoTripsBody =>
      'تعمل الشركات الموثقة على تجهيز باقات العمرة القادمة.';

  @override
  String get homeNewVerified => 'جديدة وموثقة';

  @override
  String get homeNoActivePackages => 'لا توجد باقات نشطة بعد';

  @override
  String get homeNewOffer => 'جديد';

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
  String get companiesSearchHint => 'ابحث عن وكالة أو مدينة…';

  @override
  String get companiesFilterVerified => 'موثّقة';

  @override
  String get companiesFilterTopRated => 'الأعلى تقييماً';

  @override
  String get companiesFilterPromoted => 'مميزة';

  @override
  String get companiesFilterWithPackages => 'لديها باقات';

  @override
  String get companiesNoMatches => 'لم يتم العثور على وكالات';

  @override
  String get companiesTryDifferentSearch =>
      'جرّب اسماً أو مدينة أو فلترًا مختلفًا.';

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
  String get bookingsStatusConfirmed => 'مؤكد';

  @override
  String get bookingsStatusPending => 'قيد الانتظار';

  @override
  String get bookingsStatusCancelled => 'ملغى';

  @override
  String get bookingsStatusCompleted => 'مكتمل';

  @override
  String get bookingsCancelBooking => 'إلغاء الحجز';

  @override
  String get bookingsCancelTitle => 'إلغاء هذا الحجز؟';

  @override
  String bookingsCancelBody(String title) {
    return 'سيتم إلغاء \"$title\". راجع سياسة الرحلة ومبلغ الاسترداد المتوقع أدناه قبل المتابعة.';
  }

  @override
  String get bookingsKeepBooking => 'الاحتفاظ بالحجز';

  @override
  String get bookingsConfirmCancel => 'نعم، إلغاء';

  @override
  String get bookingsCancelledSnack => 'تم إلغاء الحجز.';

  @override
  String get bookingsRateThisTrip => 'قيّم هذه الرحلة';

  @override
  String get reviewDialogTitle => 'كيف كانت رحلتك؟';

  @override
  String get reviewCommentHint => 'شاركنا بضع كلمات عن تجربتك (اختياري)';

  @override
  String get reviewSubmit => 'إرسال التقييم';

  @override
  String get reviewSubmitted => 'شكرًا على تقييمك!';

  @override
  String get reviewFailed => 'تعذّر إرسال تقييمك. حاول مرة أخرى.';

  @override
  String get actionFailedGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get agencyBookingsTitle => 'طلبات الحجز';

  @override
  String get agencyBookingsRequests => 'الطلبات';

  @override
  String get agencyBookingsEmptyTitle => 'لا توجد طلبات حجز بعد';

  @override
  String get agencyBookingsEmptyBody => 'ستظهر هنا طلبات الحجاج.';

  @override
  String get agencyBookingsCompleted => 'مكتمل';

  @override
  String get agencyBookingsConfirm => 'تأكيد';

  @override
  String get agencyBookingsDecline => 'رفض';

  @override
  String get agencyBookingsMarkCompleted => 'تحديد كمكتمل';

  @override
  String get agencyBookingsConfirmedSnack => 'تم تأكيد الحجز.';

  @override
  String get agencyBookingsDeclinedSnack => 'تم رفض الحجز.';

  @override
  String get agencyBookingsCompletedSnack => 'تم تحديده كمكتمل.';

  @override
  String get adminCommissionsTitle => 'العمولات';

  @override
  String get adminCommissionsEmptyTitle => 'لا توجد عمولات بعد';

  @override
  String get adminCommissionsEmptyBody =>
      'تُفتح هذه تلقائيًا عند تأكيد أي حجز.';

  @override
  String get adminCommissionsOwedLabel => 'إجمالي المستحق';

  @override
  String get adminCommissionsOwed => 'مستحقة';

  @override
  String get adminCommissionsCollected => 'محصّلة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get notificationsClearAll => 'مسح الكل';

  @override
  String get notificationsEmptyTitle => 'لا توجد إشعارات';

  @override
  String get notificationsEmptyBody => 'لقد اطلعت على كل شيء.';

  @override
  String get notifWelcomeTitle => 'مرحبًا بك في تطبيق العمرة';

  @override
  String get notifWelcomeBody => 'اكتشف وكالات موثوقة وباقات مختارة لرحلتك.';

  @override
  String get notifPromoTitle => 'العروض الموسمية متاحة الآن';

  @override
  String get notifPromoBody => 'وفّر حتى 20% على باقات مختارة هذا الشهر.';

  @override
  String get notifTripReminderTitle => 'رحلة قادمة';

  @override
  String notifTripReminderBody(String title) {
    return 'رحلتك \"$title\" قادمة قريبًا. تحقق من مستنداتك.';
  }

  @override
  String get notifBookingRequestedTitle => 'تم إرسال طلب الحجز';

  @override
  String notifBookingRequestedBody(String title) {
    return 'تم إرسال طلبك لباقة \"$title\" إلى الوكالة. سيتم إعلامك عند الرد.';
  }

  @override
  String get notifBookingConfirmedTitle => 'تم تأكيد الحجز';

  @override
  String notifBookingConfirmedBody(String title) {
    return 'تم تأكيد حجزك لباقة \"$title\". راجع حجوزاتي للتفاصيل.';
  }

  @override
  String get notifBookingCancelledTitle => 'تم إلغاء الحجز';

  @override
  String notifBookingCancelledBody(String title) {
    return 'تم إلغاء حجزك لباقة \"$title\".';
  }

  @override
  String get notifJustNow => 'الآن';

  @override
  String notifMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count دقيقة',
      one: 'قبل دقيقة',
    );
    return '$_temp0';
  }

  @override
  String notifHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count ساعة',
      one: 'قبل ساعة',
    );
    return '$_temp0';
  }

  @override
  String notifDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count يوم',
      one: 'قبل يوم',
    );
    return '$_temp0';
  }

  @override
  String get paymentTitle => 'طرق الدفع';

  @override
  String get paymentDefaultBadge => 'افتراضي';

  @override
  String get paymentSetDefault => 'تعيين كافتراضي';

  @override
  String get paymentRemoveCard => 'إزالة البطاقة';

  @override
  String get paymentRemoveTitle => 'إزالة هذه البطاقة؟';

  @override
  String paymentRemoveBody(String brand, String last4) {
    return 'سيتم إزالة بطاقة $brand المنتهية بـ $last4.';
  }

  @override
  String get paymentKeepCard => 'الاحتفاظ';

  @override
  String get paymentConfirmRemove => 'إزالة';

  @override
  String get paymentAddCard => 'إضافة بطاقة';

  @override
  String get paymentAddCardTitle => 'إضافة بطاقة جديدة';

  @override
  String get paymentCardHolder => 'اسم حامل البطاقة';

  @override
  String get paymentCardHolderHint => 'الاسم على البطاقة';

  @override
  String get paymentCardNumber => 'رقم البطاقة';

  @override
  String get paymentCardNumberHint => '1234 5678 9012 3456';

  @override
  String get paymentExpiry => 'تاريخ الانتهاء';

  @override
  String get paymentExpiryHint => 'شش/سس';

  @override
  String get paymentCvv => 'رمز الأمان';

  @override
  String get paymentCvvHint => '123';

  @override
  String get paymentSaveCard => 'حفظ البطاقة';

  @override
  String get paymentCardAdded => 'تمت إضافة البطاقة.';

  @override
  String get paymentCardRemoved => 'تمت إزالة البطاقة.';

  @override
  String get paymentEmptyTitle => 'لا توجد بطاقات محفوظة';

  @override
  String get paymentEmptyBody => 'أضف بطاقة لتسريع عملية الدفع.';

  @override
  String paymentExpiresLabel(String expiry) {
    return 'تنتهي في $expiry';
  }

  @override
  String get paymentErrHolder => 'أدخل اسم حامل البطاقة.';

  @override
  String get paymentErrNumber => 'أدخل رقم بطاقة صالحًا (13–19 رقمًا).';

  @override
  String get paymentErrExpiry =>
      'أدخل تاريخ انتهاء صالحًا في المستقبل (شش/سس).';

  @override
  String get paymentErrCvv => 'أدخل رمز أمان صالحًا (3–4 أرقام).';

  @override
  String get paymentSaveFailed => 'تعذّر حفظ البطاقة. حاول مرة أخرى.';

  @override
  String get paymentSignInTitle => 'سجّل الدخول لإضافة وسائل الدفع';

  @override
  String get paymentSignInBody => 'بطاقاتك المحفوظة تتبع حسابك على كل جهاز.';

  @override
  String get privacyTitle => 'الخصوصية والأمان';

  @override
  String get privacySectionSecurity => 'الأمان';

  @override
  String get privacyBiometric => 'قفل التطبيق بالبصمة';

  @override
  String get privacyBiometricSub => 'طلب بصمة الوجه / الإصبع لفتح التطبيق';

  @override
  String get privacyTwoFactor => 'المصادقة الثنائية';

  @override
  String get privacyTwoFactorSub => 'تأكيد تسجيل الدخول برمز لمرة واحدة';

  @override
  String get privacySectionPrivacy => 'الخصوصية';

  @override
  String get privacyMarketing => 'رسائل تسويقية';

  @override
  String get privacyMarketingSub => 'استلام العروض ونصائح السفر عبر البريد';

  @override
  String get privacyActivity => 'مشاركة بيانات الاستخدام';

  @override
  String get privacyActivitySub => 'ساعد في تحسين التطبيق ببيانات مجهولة';

  @override
  String get privacyChangePassword => 'تغيير كلمة المرور';

  @override
  String get privacyCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get privacyNewPassword => 'كلمة المرور الجديدة';

  @override
  String get privacyConfirmPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get privacyUpdatePassword => 'تحديث كلمة المرور';

  @override
  String get privacyPasswordChanged => 'تم تحديث كلمة المرور.';

  @override
  String get privacyErrCurrentRequired => 'أدخل كلمة المرور الحالية.';

  @override
  String get privacyErrTooShort => 'يجب ألا تقل كلمة المرور الجديدة عن 6 أحرف.';

  @override
  String get privacyErrNoMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get privacyBiometricMobileOnly =>
      'قفل البصمة متاح فقط في تطبيق الهاتف.';

  @override
  String get privacyBiometricUnavailable =>
      'لا توجد بصمة أو التعرف على الوجه مفعّل على هذا الجهاز.';

  @override
  String get lockTitle => 'التطبيق مقفل';

  @override
  String get lockSubtitle => 'استخدم بصمتك أو وجهك للمتابعة.';

  @override
  String get lockUnlock => 'فتح القفل';

  @override
  String get lockFailed => 'فشل التحقق. حاول مرة أخرى.';

  @override
  String get lockReason => 'افتح تطبيق العمرة';

  @override
  String get helpTitle => 'المساعدة والدعم';

  @override
  String get helpFaqHeader => 'الأسئلة الشائعة';

  @override
  String get helpFaq1Q => 'كيف أحجز باقة عمرة؟';

  @override
  String get helpFaq1A =>
      'افتح أي عرض، اضغط \"احجز هذه الرحلة\"، اختر عدد المسافرين وأكّد. سيظهر حجزك في حجوزاتي مع رقم مرجعي.';

  @override
  String get helpFaq2Q => 'هل يمكنني إلغاء الحجز؟';

  @override
  String get helpFaq2A =>
      'افتح حجوزاتي واضغط \"إلغاء الحجز\". يعرض التطبيق سياسة الرحلة المحفوظة ومبلغ الاسترداد المتوقع قبل التأكيد.';

  @override
  String get helpFaq3Q => 'هل الوكالات موثقة؟';

  @override
  String get helpFaq3A =>
      'كل وكالة مدرجة مرخصة حكوميًا وتم التحقق منها من قبل فريقنا قبل نشر باقاتها.';

  @override
  String get helpFaq4Q => 'ماذا تشمل الباقة؟';

  @override
  String get helpFaq4A =>
      'لكل عرض خدماته المعلنة. راجع قسم \"ما تشمله الباقة\" ولا تفترض شمول أي خدمة غير مذكورة.';

  @override
  String get helpFaq5Q => 'كيف تنضم الوكالات إلى المنصة؟';

  @override
  String get helpFaq5A =>
      'تسجل الوكالات عبر بوابة الوكالات في تبويب الملف الشخصي. بعد التحقق يمكنها نشر الباقات وإدارتها.';

  @override
  String get helpContactHeader => 'تواصل معنا';

  @override
  String get helpContactEmail => 'الدعم عبر البريد';

  @override
  String get helpContactPhone => 'اتصل بنا';

  @override
  String helpCopiedToClipboard(String value) {
    return 'تم نسخ $value';
  }

  @override
  String get helpMessageHeader => 'أرسل لنا رسالة';

  @override
  String get helpMessageHint => 'اشرح سؤالك أو مشكلتك…';

  @override
  String get helpMessageSend => 'إرسال الرسالة';

  @override
  String get helpMessageSent => 'تم إرسال الرسالة! سنرد خلال 24 ساعة.';

  @override
  String get helpMessageEmpty => 'يرجى كتابة رسالة أولًا.';

  @override
  String get helpMessageFailed =>
      'تعذّر إرسال رسالتك. تحقق من اتصالك وحاول مرة أخرى.';

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
  String get agencyLoginDemoEmail =>
      'البريد الإلكتروني: agency.demo@umrahapp.dev';

  @override
  String get agencyLoginDemoPassword => 'كلمة المرور: demo1234';

  @override
  String get agencyLoginDemoHint =>
      '(استخدم admin@noorharamain.com وغيره للوكالات الأخرى)';

  @override
  String get adminTitle => 'لوحة المشرف';

  @override
  String get adminOverview => 'نظرة عامة على المنصة';

  @override
  String get adminQuickActions => 'إجراءات سريعة';

  @override
  String get adminMetricAgencies => 'الوكالات';

  @override
  String get adminMetricPackages => 'الباقات';

  @override
  String get adminMetricFeatured => 'المميزة';

  @override
  String get adminMetricLiveAds => 'الإعلانات النشطة';

  @override
  String get adminActionPromote => 'ترويج';

  @override
  String get adminActionFinance => 'المالية';

  @override
  String get adminActionAd => 'إعلان جديد';

  @override
  String get adminAllCaughtUp =>
      'تمت المتابعة — لا توجد عناصر تحتاج إلى اهتمامك.';

  @override
  String adminAttentionAgencies(int count) {
    return 'هناك $count وكالة بانتظار الموافقة.';
  }

  @override
  String adminAttentionMessages(int count) {
    return 'توجد $count رسالة دعم تحتاج إلى رد.';
  }

  @override
  String adminAttentionAgenciesAndMessages(int agencies, int messages) {
    return 'تحتاج $agencies وكالات و$messages رسائل دعم إلى اهتمامك.';
  }

  @override
  String get tabOverview => 'نظرة عامة';

  @override
  String get tabContent => 'المحتوى';

  @override
  String get tabMore => 'المزيد';

  @override
  String get profilePreviewCard => 'معاينة بطاقتي العامة';

  @override
  String get adminRecentActivity => 'النشاط الأخير';

  @override
  String get adminNeedsAttention => 'بحاجة إلى انتباه';

  @override
  String get adminFilterActive => 'نشطة';

  @override
  String get adminInfoTab => 'معلومات';

  @override
  String get adminSignOut => 'تسجيل الخروج';

  @override
  String packagesCount(int count) {
    return '$count باقة';
  }

  @override
  String financeRecordsCount(int count) {
    return '$count سجل';
  }

  @override
  String get contentPreviewHome => 'معاينة الصفحة الرئيسية';

  @override
  String get moreGroupPeople => 'الأشخاص';

  @override
  String get moreGroupSystem => 'النظام';

  @override
  String get moreSupportSubtitle => 'رسائل من مستخدمي التطبيق';

  @override
  String get morePreviewSubtitle => 'شاهد الصفحة الرئيسية كما يراها العملاء';

  @override
  String get agencyNextDeparture => 'المغادرة القادمة';

  @override
  String agencyInDaysCount(int count) {
    return 'بعد $count يوم';
  }

  @override
  String get agencyKpiRevenue => 'الإيرادات';

  @override
  String get agencyKpiRequests => 'طلبات معلقة';

  @override
  String get agencyMoneyYouOwe => 'المستحق عليك للمنصة';

  @override
  String get agencyMoneySettled => 'تمت التسوية — لا مستحقات حالياً.';

  @override
  String stepOf(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get commonBack => 'رجوع';

  @override
  String get adminPendingAgencies => 'وكالات بانتظار الموافقة';

  @override
  String get adminNoPending => 'لا توجد وكالات بانتظار الموافقة.';

  @override
  String get adminApprove => 'موافقة';

  @override
  String get adminApproved => 'تمت الموافقة على الوكالة وأصبحت ظاهرة للجميع!';

  @override
  String get adminActionFailed =>
      'فشلت العملية — تأكد من تنفيذ patches_admin.sql أولًا.';

  @override
  String get adminHomeAds => 'إعلانات الصفحة الرئيسية';

  @override
  String get adminNoAds =>
      'لا توجد إعلانات بعد. أضف إعلانًا ليظهر أعلى الصفحة الرئيسية.';

  @override
  String get adminAddAd => 'إضافة إعلان';

  @override
  String get adminAdTitle => 'عنوان الإعلان';

  @override
  String get adminAdTitleHint => 'مثال: عرض رمضان — شركة النور';

  @override
  String get adminLinkPackage => 'ربط بباقة (اختياري)';

  @override
  String get adminLinkCompany => 'ربط بوكالة (اختياري)';

  @override
  String get adminNoLink => 'بدون ربط';

  @override
  String get adminAdImage => 'صورة الإعلان';

  @override
  String get adminPickImage => 'اضغط لاختيار صورة';

  @override
  String get adminAdCreated => 'تم نشر الإعلان في الصفحة الرئيسية!';

  @override
  String get adminStatPending => 'قيد الانتظار';

  @override
  String get adminStatOwed => 'مستحق';

  @override
  String get adminStatCollected => 'محصّل';

  @override
  String get adminSupportInbox => 'رسائل الدعم';

  @override
  String get adminSupportEmpty => 'لا توجد رسائل بعد.';

  @override
  String get adminSupportAnonymous => 'زائر';

  @override
  String get adminSectionManage => 'الإدارة';

  @override
  String get adminFilterAll => 'الكل';

  @override
  String get adminSupportResolved => 'تمت معالجة الرسالة وحذفها.';

  @override
  String get emailCopied => 'تم نسخ البريد الإلكتروني';

  @override
  String get adminCommissionsCardSubtitle => 'المستحق والمحصّل لجميع الوكالات';

  @override
  String get adminPromoteTitle => 'الترويج للوكالات والباقات';

  @override
  String get adminPromoteSubtitle =>
      'أبرز الوكالات والباقات في الصفحة الرئيسية';

  @override
  String get promoteScreenTitle => 'ترويجات الصفحة الرئيسية';

  @override
  String get promoteSearchTrips => 'ابحث عن الباقات…';

  @override
  String get promoteSearchAgencies => 'ابحث عن الوكالات…';

  @override
  String get promoteTabTrips => 'الباقات';

  @override
  String get promoteTabAgencies => 'الوكالات';

  @override
  String get promoteNoTrips => 'لم يتم العثور على باقات';

  @override
  String get promoteNoAgencies => 'لم يتم العثور على وكالات';

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
  String get editAgencyProfileBannerLabel => 'صورة الخلفية';

  @override
  String get editAgencyProfileBackgroundColorLabel => 'لون خلفية البطاقة';

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
  String get mealsBreakfast => 'الإفطار فقط';

  @override
  String get mealsHalfBoard => 'نصف إقامة';

  @override
  String get mealsFullBoard => 'إقامة كاملة';

  @override
  String get addEditOfferHotel => 'الفندق';

  @override
  String get addEditOfferHotelName => 'اسم الفندق';

  @override
  String get addEditOfferHotelNameHint => 'مثال: كونراد مكة سويتس';

  @override
  String get addEditOfferHotelMakkah => 'الفندق في مكة';

  @override
  String get addEditOfferHotelMakkahHint => 'مثال: كونراد مكة سويتس';

  @override
  String get addEditOfferHotelMadinah => 'الفندق في المدينة المنورة';

  @override
  String get addEditOfferHotelMadinahHint => 'مثال: أنوار المدينة موفنبيك';

  @override
  String get addEditOfferAirport => 'مطار المغادرة';

  @override
  String get addEditOfferAirportHint => 'مثال: مطار أربيل الدولي';

  @override
  String get addEditOfferBusStation => 'محطة الحافلات للمغادرة';

  @override
  String get addEditOfferBusStationHint => 'مثال: محطة حافلات السليمانية';

  @override
  String get offerDetailHotelMakkah => 'فندق مكة';

  @override
  String get offerDetailHotelMadinah => 'فندق المدينة المنورة';

  @override
  String get airportDeparture => 'مطار المغادرة';

  @override
  String get busStationPickup => 'محطة المغادرة';

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
  String get addEditOfferPriceUsd => 'السعر الأساسي (د.ع) *';

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

  @override
  String get addEditOfferSavedImageFailed =>
      'تم حفظ الباقة، لكن تعذر رفع صورة الغلاف. تحقق من اتصالك وحاول مرة أخرى من التعديل.';

  @override
  String get authSignInTitle => 'مرحبًا بعودتك';

  @override
  String get authSignUpTitle => 'إنشاء حساب';

  @override
  String get authSubtitle => 'سجّل الدخول لحجز الرحلات وإدارة حجوزاتك.';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authFullNameHint => 'اسمك';

  @override
  String get authPhone => 'رقم الهاتف';

  @override
  String get authSignUpBtn => 'إنشاء حساب';

  @override
  String get authNoAccount => 'جديد هنا؟';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authErrFillAll => 'يرجى ملء جميع الحقول.';

  @override
  String get authConfirmEmailSent =>
      'تم إنشاء الحساب — تحقق من بريدك لتأكيده ثم سجّل الدخول.';

  @override
  String get authWelcomeSnack => 'مرحبًا بك!';

  @override
  String get profileSignIn => 'تسجيل الدخول / إنشاء حساب';

  @override
  String get profileSignInBannerSubtitle =>
      'احجز رحلاتك، احفظ المفضلة، وتابع حجوزاتك.';

  @override
  String get profileSignOut => 'تسجيل الخروج';

  @override
  String get profileSignedOut => 'تم تسجيل الخروج.';

  @override
  String get profileSignOutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get profileSignOutConfirmBody =>
      'يمكنك تسجيل الدخول مرة أخرى في أي وقت ببريدك الإلكتروني وكلمة المرور.';

  @override
  String get profileSectionAccount => 'الحساب';

  @override
  String get profileSectionPreferences => 'التفضيلات';

  @override
  String get profileSectionSupport => 'الدعم';

  @override
  String get profileGuestBadge => 'ضيف';

  @override
  String get profileStatAlerts => 'تنبيهات';

  @override
  String get profileAccountDetails => 'تفاصيل الحساب';

  @override
  String get accountPhoneHint => '+964 750 000 0000';

  @override
  String get accountSaveChanges => 'حفظ التغييرات';

  @override
  String get accountUpdated => 'تم تحديث الملف الشخصي.';

  @override
  String get accountChangePassword => 'تغيير كلمة المرور';

  @override
  String get accountNewPassword => 'كلمة المرور الجديدة';

  @override
  String get accountNewPasswordHint => '٦ أحرف على الأقل';

  @override
  String get accountPasswordUpdated => 'تم تحديث كلمة المرور.';

  @override
  String get accountPasswordTooShort =>
      'يجب أن تكون كلمة المرور ٦ أحرف على الأقل.';

  @override
  String get accountDangerZone => 'منطقة الخطر';

  @override
  String get accountDeleteAccount => 'حذف الحساب';

  @override
  String get accountDeleteHint => 'يزيل حسابك وبياناتك نهائيًا.';

  @override
  String get accountDeleteTitle => 'حذف الحساب؟';

  @override
  String get accountDeleteBody =>
      'سيؤدي هذا إلى حذف حسابك وحجوزاتك وبياناتك المحفوظة نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get accountDeleteConfirm => 'نعم، احذف حسابي';

  @override
  String get accountDeleted => 'تم حذف حسابك.';

  @override
  String get accountDeleteFailed => 'تعذر حذف الحساب. حاول مرة أخرى.';

  @override
  String get profileAbout => 'حول التطبيق';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutTermsOfUse => 'شروط الاستخدام';

  @override
  String get legalPrivacyBody =>
      'يحترم تطبيق العمرة خصوصيتك. نجمع فقط المعلومات اللازمة لتشغيل الخدمة: اسمك وبيانات الاتصال وطلبات الحجز. تُشارك هذه المعلومات فقط مع وكالة السفر التي تختار الحجز لديها، ولا تُباع أبدًا لأطراف ثالثة.\n\nتُخزَّن بياناتك بأمان. يمكنك حذف حسابك في أي وقت من تفاصيل الحساب، وسيؤدي ذلك إلى إزالة ملفك الشخصي وبياناتك الشخصية نهائيًا من أنظمتنا.';

  @override
  String get legalTermsBody =>
      'تطبيق العمرة منصة تربط المعتمرين بوكالات سفر مرخصة. الحجوزات عبر التطبيق هي طلبات: تقوم الوكالة بتأكيدها أو رفضها، ويتم الدفع مباشرة لدى الوكالة. تفاصيل الباقات والأسعار والتوفر تقدمها الوكالات وقد تتغير.\n\nباستخدامك للتطبيق فإنك توافق على تقديم معلومات صحيحة واستخدام الخدمة لأغراض شخصية ومشروعة فقط. التطبيق ليس وكالة سفر وليس طرفًا في العقد بينك وبين الوكالة.';

  @override
  String get bookingPayMethod => 'طريقة الدفع';

  @override
  String get payCash => 'نقدًا';

  @override
  String get payCard => 'بطاقة';

  @override
  String get payFib => 'FIB';

  @override
  String get preferredPaymentTitle => 'طريقة الدفع';

  @override
  String get preferredPaymentBody =>
      'اختر طريقة الدفع المفضلة لديك. يتم الدفع دائمًا شخصيًا لدى الوكالة — لا يُخصم أي مبلغ داخل التطبيق أبدًا.';

  @override
  String get preferredPaymentSaved => 'تم حفظ التفضيل.';

  @override
  String get bookingFailed => 'تعذر إتمام الحجز. حاول مرة أخرى.';

  @override
  String get bookingsCancelFailed =>
      'تعذر إلغاء هذا الحجز — يرجى التواصل مع الوكالة.';

  @override
  String get loadErrorTitle => 'تعذر تحميل البيانات';

  @override
  String get loadErrorBody => 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get agencyRegisterTitle => 'تسجيل وكالة';

  @override
  String get agencyRegisterSubtitle =>
      'أنشئ حسابًا لنشر باقات العمرة الخاصة بك.';

  @override
  String get agencyRegisterBtn => 'تسجيل الوكالة';

  @override
  String get agencyRegisterPrompt => 'وكالة جديدة؟';

  @override
  String get agencyCompanyName => 'اسم الوكالة';

  @override
  String get agencyCompanyNameHint => 'مثال: شركة النور';

  @override
  String get agencyCompanyLocation => 'المدينة / الموقع';

  @override
  String get agencyCompanyLocationHint => 'مثال: أربيل';

  @override
  String get agencyCompanyAbout => 'نبذة عن الوكالة';

  @override
  String get agencyCompanyAboutHint => 'وصف قصير يظهر للمعتمرين';

  @override
  String get agencyCompanySince => 'سنة التأسيس';

  @override
  String get agencyCompanySinceHint => 'مثال: 2015';

  @override
  String get agencyCompanyLogo => 'شعار الوكالة';

  @override
  String get agencyLogoAdd => 'إضافة شعار';

  @override
  String get agencyLogoChange => 'تغيير الشعار';

  @override
  String get agencyLogoOptional => 'اختياري — يظهر في صفحة الوكالات';

  @override
  String get agencyBannerAdd => 'إضافة صورة الغلاف';

  @override
  String get agencyBannerChange => 'تغيير صورة الغلاف';

  @override
  String get agencyNotAgencyAccount => 'هذا الحساب ليس حساب وكالة.';

  @override
  String get addEditOfferSaveFailed =>
      'تعذر حفظ الباقة. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String offerFallbackDayLabel(int n) {
    return 'اليوم $n';
  }

  @override
  String offerFallbackDayRangeLabel(int a, int b) {
    return 'الأيام $a–$b';
  }

  @override
  String get offerFallbackFinalDaysLabel => 'الأيام الأخيرة';

  @override
  String get offerFallbackDay1Title => 'الوصول والتنقل';

  @override
  String get offerFallbackDay1Summary =>
      'الوصول إلى جدة، حيث يستقبلك مرشدك، ثم التنقل إلى فندقك بالقرب من الحرم.';

  @override
  String get offerFallbackDay2Title => 'أداء العمرة';

  @override
  String get offerFallbackDay2Summary =>
      'عمرة بإشراف مرشد — الطواف والسعي والتحلل برفقة عالم المجموعة.';

  @override
  String get offerFallbackMakkahTitle => 'العبادة في مكة';

  @override
  String get offerFallbackMakkahSummary =>
      'الصلاة في المسجد الحرام مع إمكانية زيارة منى وعرفات والمواقع التاريخية.';

  @override
  String get offerFallbackMadinahTravelTitle => 'السفر إلى المدينة';

  @override
  String get offerFallbackMadinahTravelSummary =>
      'نقل سريع إلى المدينة المنورة وإجراءات تسجيل الدخول بالقرب من المسجد النبوي.';

  @override
  String get offerFallbackMadinahReturnTitle => 'المدينة والعودة';

  @override
  String get offerFallbackMadinahReturnSummary =>
      'الصلاة في المسجد النبوي وجولات الزيارة، ثم التنقل لرحلة العودة.';

  @override
  String get offerFallbackWorshipReturnTitle => 'العبادة والعودة';

  @override
  String get offerFallbackWorshipReturnSummary =>
      'الصلوات الأخيرة وطواف الوداع، ثم التنقل إلى المطار للمغادرة.';

  @override
  String get offerFallbackIncludeVisa => 'تأشيرة العمرة وإجراءاتها';

  @override
  String get offerFallbackIncludeFlights => 'رحلات طيران دولية ذهابًا وإيابًا';

  @override
  String get offerFallbackIncludeCoach => 'نقل بحافلة مكيفة';

  @override
  String offerFallbackIncludeHotel(int acc, String hotel) {
    return 'فندق $acc نجوم — $hotel';
  }

  @override
  String offerFallbackIncludeMeals(String meals) {
    return 'وجبات $meals يوميًا';
  }

  @override
  String get offerFallbackIncludeZiyarah => 'جولات زيارة بإشراف مرشد';

  @override
  String get offerFallbackIncludeGuide => 'مرشد متعدد اللغات على مدار الساعة';

  @override
  String get profileAdminDashboardSub => 'إدارة الوكالات والإعلانات والعمولات';

  @override
  String get profileAgencyDashboardSub => 'إدارة باقاتك وحجوزاتك';

  @override
  String get profileAgencyPortalSub => 'تسجيل الدخول كوكالة أو مسؤول';

  @override
  String get profileAgencyLogout => 'تسجيل الخروج من الوكالة';

  @override
  String get profileAgencyLogoutTitle => 'تسجيل الخروج من الوكالة؟';

  @override
  String get profileAgencyLogoutBody =>
      'سيتم تسجيل خروجك من بوابة الوكالة. يمكنك تسجيل الدخول مرة أخرى في أي وقت.';

  @override
  String get adminDecline => 'رفض';

  @override
  String get adminDeclineTitle => 'رفض الوكالة؟';

  @override
  String get adminDeclineBody =>
      'لن تتم الموافقة على هذه الوكالة ولن تظهر باقاتها على المنصة.';

  @override
  String get adminDeclined => 'تم رفض الوكالة.';

  @override
  String get agencyLoginInfoNote =>
      'استخدم بيانات الاعتماد المقدمة من مسؤول وكالتك لتسجيل الدخول.';

  @override
  String get editAgencyProfileLocationRequired => 'الموقع مطلوب.';

  @override
  String get editAgencyProfileYearInvalid =>
      'يرجى إدخال سنة صالحة (1900–الحاضر).';

  @override
  String get adminDeleteAdTitle => 'حذف هذا الإعلان؟';

  @override
  String get adminDeleteAdBody =>
      'سيتم حذف هذا الإعلان نهائيًا من الصفحة الرئيسية.';

  @override
  String get adminDeleteAdConfirm => 'حذف';

  @override
  String get forgotPasswordLink => 'نسيت کلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين کلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدک الإلکتروني وسنرسل لک رمز تحقق لإعادة تعيين کلمة المرور.';

  @override
  String get forgotPasswordStep2Subtitle =>
      'أدخل الرمز المکون من 6 أرقام المرسل إلى بريدک واختر کلمة مرور جديدة.';

  @override
  String get forgotPasswordCodeLabel => 'رمز التحقق';

  @override
  String get forgotPasswordNewPass => 'کلمة المرور الجديدة';

  @override
  String get forgotPasswordConfirmPass => 'تأکيد کلمة المرور';

  @override
  String get forgotPasswordSendCode => 'إرسال رمز التحقق';

  @override
  String get forgotPasswordResetBtn => 'إعادة تعيين کلمة المرور';

  @override
  String get forgotPasswordResend => 'لم تستلم الرمز؟ إعادة الإرسال';

  @override
  String get forgotPasswordCodeSent =>
      'تم إرسال رمز التحقق إلى بريدک الإلکتروني.';

  @override
  String get forgotPasswordSuccess =>
      'تم إعادة تعيين کلمة المرور بنجاح! جارٍ العودة...';

  @override
  String get forgotPasswordErrEmail => 'يرجى إدخال بريدک الإلکتروني.';

  @override
  String get forgotPasswordErrCode => 'يرجى إدخال رمز التحقق.';

  @override
  String get forgotPasswordErrShort =>
      'کلمة المرور يجب أن تکون 6 أحرف على الأقل.';

  @override
  String get forgotPasswordErrNoMatch => 'کلمتا المرور غير متطابقتين.';

  @override
  String get authNext => 'التالي';

  @override
  String get authEnterPassword => 'أدخل کلمة المرور للمتابعة';

  @override
  String get authErrInvalidEmail => 'يرجى إدخال بريد إلکتروني صالح.';

  @override
  String get authErrEmailEmpty => 'يرجى إدخال البريد الإلکتروني.';

  @override
  String get authErrEmailSpaces =>
      'البريد الإلکتروني لا يمکن أن يحتوي على مسافات.';

  @override
  String get authErrEmailNoAt => 'يجب أن يحتوي البريد على رمز @.';

  @override
  String get authErrEmailInvalidDomain =>
      'يرجى إدخال نطاق بريد صالح (مثل: gmail.com).';

  @override
  String get authErrPhoneTooShort =>
      'رقم الهاتف قصير جداً. يجب أن يکون 7 أرقام على الأقل.';

  @override
  String get authErrPhoneTooLong =>
      'رقم الهاتف طويل جداً. الحد الأقصى 15 رقماً.';

  @override
  String get authErrPhoneInvalidChars => 'رقم الهاتف يحتوي على أحرف غير صالحة.';

  @override
  String get authErrPhoneInvalid => 'يرجى إدخال رقم هاتف صالح.';

  @override
  String get authErrPasswordEmpty => 'يرجى إدخال کلمة المرور.';

  @override
  String get authErrPasswordShort =>
      'کلمة المرور يجب أن تکون 6 أحرف على الأقل.';

  @override
  String get authErrPasswordNoLetter =>
      'کلمة المرور يجب أن تحتوي على حرف واحد على الأقل.';

  @override
  String get authErrPasswordNoDigit =>
      'کلمة المرور يجب أن تحتوي على رقم واحد على الأقل.';

  @override
  String get authErrNameEmpty => 'يرجى إدخال الاسم الکامل.';

  @override
  String get authErrNameTooShort => 'الاسم يجب أن يکون حرفين على الأقل.';

  @override
  String get accountChangeEmail => 'تغيير';

  @override
  String get accountChangeEmailBody =>
      'أدخل بريدک الإلکتروني الجديد. سيتم إرسال رابط تأکيد للتحقق من التغيير.';

  @override
  String get accountUpdate => 'تحديث';

  @override
  String get accountVerifyIdentity => 'تحقق من هويتک';

  @override
  String get accountVerifyIdentityBody =>
      'لأسباب أمنية، يرجى إدخال کلمة المرور الحالية للمتابعة.';

  @override
  String get accountVerify => 'تحقق';

  @override
  String get accountWrongPassword => 'کلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get accountEmailSameAsCurrent => 'هذا هو بريدک الحالي بالفعل.';

  @override
  String get accountEmailConfirmationTitle => 'تم إرسال التأکيد';

  @override
  String get accountEmailConfirmationBody =>
      'تم إرسال رابط تأکيد إلى بريدک الجديد. تحقق من بريدک وانقر على الرابط لإتمام التغيير.';

  @override
  String get bookingStepRoom => 'الغرفة والحجاج';

  @override
  String get bookingStepPilgrims => 'معلومات الحجاج';

  @override
  String get bookingStepPay => 'الدفع';

  @override
  String get bookingChooseRoom => 'اختر نوع الغرفة';

  @override
  String get bookingChooseMeal => 'اختر نوع الوجبات';

  @override
  String get bookingMealPreference => 'تفضيل الوجبات لهذا الحجز';

  @override
  String get bookingRoomDouble => 'غرفة ثنائية';

  @override
  String get bookingRoomTriple => 'غرفة ثلاثية';

  @override
  String get bookingRoomQuad => 'غرفة رباعية';

  @override
  String bookingRoomPax(int count) {
    return '$count أشخاص في الغرفة';
  }

  @override
  String get bookingMostPopular => 'الأكثر طلباً';

  @override
  String get bookingPilgrimCountTitle => 'عدد الحجاج';

  @override
  String get bookingPilgrimAge => 'العمر +12 سنة';

  @override
  String bookingTotalLine(int count, String price) {
    return '$count × $price';
  }

  @override
  String get bookingContinue => 'متابعة';

  @override
  String get bookingContinueToPay => 'المتابعة إلى الدفع';

  @override
  String bookingPilgrimN(int n) {
    return 'الحاج $n';
  }

  @override
  String get bookingStatusComplete => 'مكتمل';

  @override
  String get bookingStatusIncomplete => 'غير مكتمل';

  @override
  String get bookingFullName => 'الاسم الكامل (كما في الجواز)';

  @override
  String get bookingFullNameHint => 'مثال: كاروان عمر أحمد';

  @override
  String get bookingPassportNo => 'رقم جواز السفر';

  @override
  String get bookingDob => 'تاريخ الميلاد';

  @override
  String get bookingDobHint => 'اختر التاريخ';

  @override
  String get bookingPhoneLabel => 'رقم الهاتف';

  @override
  String get bookingReviewTitle => 'المراجعة والدفع';

  @override
  String get bookingReviewSub => 'الخطوة الأخيرة';

  @override
  String get bookingSummaryTitle => 'ملخص الحجز';

  @override
  String get bookingSummaryTrip => 'الرحلة';

  @override
  String get bookingSummaryCompany => 'الشركة';

  @override
  String get bookingSummaryDeparture => 'تاريخ المغادرة';

  @override
  String get bookingSummaryPilgrims => 'الحجاج';

  @override
  String get bookingSummaryRoom => 'الغرفة';

  @override
  String get bookingSummaryMeal => 'الوجبات';

  @override
  String get bookingPassportDocuments => 'جوازات سفر المسافرين';

  @override
  String bookingPassportDocumentsBody(int count) {
    return 'بيانات الجواز مطلوبة لجميع المسافرين وعددهم $count';
  }

  @override
  String get bookingPassportPrivacy =>
      'أضف بيانات الجواز لكل مسافر بشكل منفصل. تُحفظ الصور بشكل خاص لهذا الحجز فقط.';

  @override
  String get bookingPassportRequired =>
      'حمّل صورتي جواز السفر والصورة الشخصية.';

  @override
  String get bookingPassportSaved => 'تم حفظ بيانات الجواز.';

  @override
  String get bookingPassportChooseImage => 'اختر صورة الجواز';

  @override
  String get bookingPassportImageUploaded => 'تم رفع صورة الجواز';

  @override
  String get bookingPhotoExamples => 'أمثلة الصور';

  @override
  String get bookingTakeRequiredPhotos => 'التقط صورة شخصية وصورة الجواز';

  @override
  String get payFibSub => 'ادفع مباشرة عبر تطبيق FIB';

  @override
  String get payCardSub => 'Visa · Mastercard';

  @override
  String get payCashSub => 'الدفع في مكتب الشركة';

  @override
  String get bookingConfirmBtn => 'تأكيد الحجز';

  @override
  String get bookingRegisteredTitle => 'تم تسجيل حجزك';

  @override
  String bookingRegisteredBody(String company) {
    return 'تم إرسال طلبك إلى $company. سنعلمك فور تأكيده — عادةً خلال 24 ساعة.';
  }

  @override
  String get bookingRefTitle => 'رقم الحجز';

  @override
  String get bookingAwaitingConfirmation => 'بانتظار التأكيد';

  @override
  String get bookingBackHome => 'العودة إلى الرئيسية';

  @override
  String get bookingViewMyBookings => 'عرض حجوزاتي';

  @override
  String bookingPilgrimsSummary(int count, String room) {
    return '$count حجاج · $room';
  }

  @override
  String get workflowSubmitForReview => 'إرسال للمراجعة';

  @override
  String get workflowSubmitted => 'تم الإرسال للمراجعة.';

  @override
  String get workflowSubmitCompanyBody => 'أكمل ملف الشركة ثم أرسله للتحقق.';

  @override
  String get workflowChangesRequired => 'التغييرات مطلوبة';

  @override
  String get workflowPackagesToReview => 'الباقات قيد المراجعة';

  @override
  String get workflowNoPackagesToReview => 'لا توجد باقات بانتظار المراجعة';

  @override
  String get workflowReasonRequired => 'السبب مطلوب';

  @override
  String get workflowReasonHint => 'اشرح ما الذي يجب تغييره';

  @override
  String get workflowSendDecision => 'إرسال القرار';

  @override
  String get workflowDecisionSaved => 'تم حفظ القرار.';

  @override
  String get workflowAwaitingPayment => 'بانتظار الدفع';

  @override
  String get workflowReadyToTravel => 'جاهز للسفر';

  @override
  String get workflowInProgress => 'الرحلة جارية';

  @override
  String get workflowRejected => 'مرفوض';

  @override
  String get workflowExpired => 'منتهي الصلاحية';

  @override
  String get workflowMarkReady => 'تحديد كجاهز';

  @override
  String get workflowStartTrip => 'بدء الرحلة';

  @override
  String get workflowStatusUpdated => 'تم تحديث حالة الحجز.';

  @override
  String get workflowCompanyReviewTitle => 'تم تحديث التحقق من الشركة';

  @override
  String workflowCompanyReviewBody(Object status) {
    return 'حالة طلب شركتك الآن: $status';
  }

  @override
  String get workflowPackageReviewTitle => 'تم تحديث مراجعة الباقة';

  @override
  String workflowPackageReviewBody(Object status) {
    return 'حالة باقتك الآن: $status';
  }

  @override
  String get workflowConfirmCash => 'تأكيد استلام النقد';

  @override
  String get workflowCashConfirmed => 'تم تأكيد الدفع النقدي.';

  @override
  String get workflowDraftSaved => 'تم حفظ الباقة كمسودة.';

  @override
  String get workflowCapacity => 'سعة المسافرين';

  @override
  String get workflowDepartureDate => 'تاريخ المغادرة';

  @override
  String get workflowReturnDate => 'تاريخ العودة';

  @override
  String get workflowPayNow => 'ادفع الآن';

  @override
  String get workflowPaymentStartFailed => 'تعذر بدء عملية الدفع.';

  @override
  String get workflowFibPaymentTitle => 'الدفع عبر FIB';

  @override
  String get workflowFibPaymentBody =>
      'افتح تطبيق FIB واستخدم رمز الدفع. سيتم تأكيد الحجز تلقائياً بعد تحقق FIB من الدفع.';

  @override
  String get workflowCopyPayment => 'نسخ تفاصيل الدفع';

  @override
  String get addEditOfferHotelMakkahDescription => 'وصف فندق مكة';

  @override
  String get addEditOfferHotelMadinahDescription => 'وصف فندق المدينة';

  @override
  String get addEditOfferHotelDescriptionHint =>
      'صف الموقع والمرافق والخدمة والمعالم القريبة';

  @override
  String get addEditOfferAvailableRooms => 'أنواع الغرف المتاحة';

  @override
  String get addEditOfferAvailableRoomsHelper =>
      'اختر جميع أحجام الغرف التي يمكن للعملاء حجزها ضمن هذه الباقة.';

  @override
  String get addEditOfferChooseRoomType =>
      'اختر نوع غرفة متاحاً واحداً على الأقل.';

  @override
  String bookingRoomOccupancy(int count) {
    return 'غرفة لـ $count أشخاص';
  }

  @override
  String get offerFormCommercialPolicy => 'السياسة والدفع';

  @override
  String get offerFormTitleKu => 'عنوان الباقة (كردي)';

  @override
  String get offerFormTitleAr => 'عنوان الباقة (عربي)';

  @override
  String get offerFormTitleEn => 'عنوان الباقة (إنجليزي)';

  @override
  String get offerFormOverviewKu => 'نبذة (كردي)';

  @override
  String get offerFormOverviewAr => 'نبذة (عربي)';

  @override
  String get offerFormOverviewEn => 'نبذة (إنجليزي)';

  @override
  String get offerFormOverviewHint => 'اشرح ما يميز هذه الباقة';

  @override
  String get offerFormPackageTier => 'فئة الباقة';

  @override
  String get offerTierEconomy => 'اقتصادية';

  @override
  String get offerTierStandard => 'قياسية';

  @override
  String get offerTierVip => 'VIP';

  @override
  String get offerFormGroupType => 'نوع المجموعة';

  @override
  String get offerGroupFamily => 'عائلية';

  @override
  String get offerGroupIndividual => 'فردية';

  @override
  String get offerGroupGroup => 'مجموعة';

  @override
  String get offerFormSeason => 'الموسم';

  @override
  String get offerSeasonRamadan => 'رمضان';

  @override
  String get offerSeasonRegular => 'اعتيادي';

  @override
  String get offerSeasonShawwal => 'شوال';

  @override
  String get offerSeasonOther => 'أخرى';

  @override
  String get offerFormDepartureAirport => 'مطار المغادرة';

  @override
  String get offerFormFlightType => 'نوع الرحلة';

  @override
  String get offerFlightDirect => 'مباشرة';

  @override
  String get offerFlightConnecting => 'ترانزيت';

  @override
  String get offerFormBusBetweenCities => 'يشمل النقل بين مكة والمدينة';

  @override
  String get offerFormAirportTransfers => 'يشمل النقل من وإلى المطار';

  @override
  String get offerFormOccupancyPricing => 'سعر الشخص حسب إشغال الغرفة';

  @override
  String offerFormOccupancyPrice(String room) {
    return 'سعر $room (د.ع)';
  }

  @override
  String get offerFormDepositAmount => 'مبلغ العربون (د.ع)';

  @override
  String get offerFormNonRefundableDeposit => 'العربون غير قابل للاسترداد';

  @override
  String get offerFormDepositTerms => 'شروط العربون';

  @override
  String get offerFormDepositTermsHint => 'وضح موعد دفع المبلغ المتبقي';

  @override
  String get offerFormCancellationPolicy => 'سياسة الإلغاء والاسترداد';

  @override
  String get offerFormCancellationPolicyHint =>
      'وضح مواعيد الإلغاء والرسوم ومدة الاسترداد';

  @override
  String get offerFormAcceptedPayments => 'طرق الدفع المقبولة';

  @override
  String get offerFormRequired => 'مطلوب';

  @override
  String get offerFormInvalidValue => 'أدخل قيمة صحيحة.';

  @override
  String get offerFormSelectOne => 'اختر خياراً واحداً على الأقل.';

  @override
  String get offerFormReturnDateAfterDeparture =>
      'يجب أن يكون تاريخ العودة بعد تاريخ المغادرة.';

  @override
  String get offerFormFixHighlighted => 'يرجى إكمال الحقول المطلوبة المميزة.';

  @override
  String get offerSoldOut => 'نفدت المقاعد';

  @override
  String offerFewSeatsLeft(int count) {
    return 'متبقي $count مقاعد فقط';
  }

  @override
  String get offerAvailable => 'متاح';

  @override
  String get offerOccupancyPricing => 'أسعار الغرف';

  @override
  String get offerTrustAndPolicy => 'الثقة والسياسة والدفع';

  @override
  String offerDepositLabel(String amount) {
    return 'العربون: $amount';
  }

  @override
  String offerAcceptedPaymentsLabel(String methods) {
    return 'المقبول: $methods';
  }

  @override
  String get offerCapacitySoldOut => 'نفدت المقاعد';

  @override
  String offerCapacityFewLeft(int count) {
    return 'متبقي $count مقاعد فقط';
  }

  @override
  String get offerCapacityAvailable => 'متاح';

  @override
  String offerCapacityRemaining(int count) {
    return 'متبقي $count مقعداً';
  }

  @override
  String offerHotelNights(int count) {
    return '$count ليالٍ';
  }

  @override
  String offerDepositRequired(String amount) {
    return 'العربون المطلوب: $amount';
  }

  @override
  String get offerDepositNonRefundable => 'العربون غير قابل للاسترداد';

  @override
  String offerAcceptedPaymentList(String methods) {
    return 'طرق الدفع المقبولة: $methods';
  }

  @override
  String get agencyAccessUnderReviewTitle => 'وكالتك قيد المراجعة';

  @override
  String get agencyAccessUnderReviewBody =>
      'يمكنك تسجيل الدخول أثناء تحقق الإدارة من التسجيل والمستندات. ستُفتح لوحة التحكم بعد الموافقة.';

  @override
  String get agencyAccessRejectedTitle => 'التسجيل يحتاج إلى مراجعة';

  @override
  String get agencyAccessRejectedBody =>
      'لم تتم الموافقة على التسجيل. راجع ملاحظات الإدارة وأعد إرسال المستندات.';

  @override
  String get agencyAccessSuspendedTitle => 'تم تعليق وصول الوكالة';

  @override
  String get agencyAccessSuspendedBody =>
      'تم إخفاء عروضك أثناء مراجعة التعليق. تواصل مع دعم المنصة للتفاصيل.';

  @override
  String get companyTrustSignals => 'الثقة والتحقق';

  @override
  String companyLicenseNumber(String number) {
    return 'رقم الترخيص: $number';
  }

  @override
  String companyPilgrimsServed(int count) {
    return 'خدمت أكثر من $count حاج';
  }

  @override
  String companyResponseTime(String time) {
    return 'ترد عادة خلال $time';
  }

  @override
  String get companyContactLocation => 'التواصل والموقع';

  @override
  String get companyAgencyReply => 'رد الوكالة';

  @override
  String get companyReportAgency => 'الإبلاغ عن هذه الوكالة';

  @override
  String get companyReportReason => 'السبب';

  @override
  String get companyReportDetails => 'التفاصيل (اختياري)';

  @override
  String get companyReportSubmit => 'إرسال البلاغ';

  @override
  String get companyReportSubmitted => 'تم إرسال البلاغ للمراجعة';

  @override
  String get adminBookingsPayments => 'الحجوزات والمدفوعات';

  @override
  String get adminNoBookings => 'لا توجد حجوزات';

  @override
  String get bookingStageRequested => 'مطلوب';

  @override
  String get bookingStageConfirmed => 'مؤكد';

  @override
  String get bookingStageCompleted => 'مكتمل';

  @override
  String get bookingStageCancelled => 'ملغى';

  @override
  String get agencyMessages => 'الرسائل';

  @override
  String get agencyMessagesEmpty => 'لا توجد استفسارات بعد';

  @override
  String get agencyMessagesEmptyBody => 'ستظهر أسئلة العملاء هنا فوراً.';

  @override
  String agencyInquiryNumber(int number) {
    return 'استفسار رقم $number';
  }

  @override
  String get agencyInquiryNoMessages => 'لا توجد رسائل';

  @override
  String get agencyReplyHint => 'اكتب رداً…';

  @override
  String get adminAgencyBadges => 'الشارات اليدوية';

  @override
  String get badgeVerified => 'موثّقة';

  @override
  String get badgePremiumPartner => 'شريك مميز';

  @override
  String get agencyDocumentsTitle => 'المستندات والتحقق';

  @override
  String get agencyDocumentsMenuSubtitle => 'رفع أو تجديد مستندات الترخيص';

  @override
  String get agencyDocumentsBody =>
      'ارفع صوراً واضحة لمستندات العمل السارية. يمكن للإدارة معاينتها بأمان أثناء المراجعة.';

  @override
  String get agencyDocumentType => 'نوع المستند';

  @override
  String get agencyDocumentLicense => 'ترخيص وكالة السفر';

  @override
  String get agencyDocumentRegistration => 'تسجيل الشركة';

  @override
  String get agencyDocumentOffice => 'التحقق من المكتب';

  @override
  String get agencyDocumentChoose => 'اختر صورة المستند';

  @override
  String get agencyDocumentUpload => 'رفع المستند';

  @override
  String get agencyDocumentUploaded => 'تم رفع المستند للمراجعة';

  @override
  String get agencyDocumentsResubmit => 'رفع أو إعادة إرسال المستندات';

  @override
  String get adminNoAgencyDocuments => 'لم تُرفع مستندات بعد';

  @override
  String get agencyDocumentStatusPending => 'قيد المراجعة';

  @override
  String get agencyDocumentStatusApproved => 'مقبول';

  @override
  String get agencyDocumentStatusRejected => 'مرفوض';

  @override
  String get adminRequestMoreInfo => 'طلب معلومات إضافية';

  @override
  String get adminMoreInfoRequested => 'تم إرسال طلب المعلومات';

  @override
  String get identityVerification => 'التحقق من الهوية';

  @override
  String get identityVerificationTitle => 'تحقق من هويتك';

  @override
  String get identityVerificationBody =>
      'ارفع صورة واضحة لجواز السفر وصورة شخصية. تُحفظ مستنداتك بأمان وتُراجع بشكل خاص.';

  @override
  String get identityPassportPhoto => 'صورة جواز السفر';

  @override
  String get identityPassportBody => 'صورة واضحة لصفحة البيانات في جواز سفرك';

  @override
  String get identitySelfiePhoto => 'صورة شخصية';

  @override
  String get identitySelfieBody =>
      'صورة واضحة لك وأنت تنظر مباشرة إلى الكاميرا';

  @override
  String get identityExampleTitle => 'مثال للصورة والتعليمات';

  @override
  String get identityPassportInstruction1 =>
      'أظهر صفحة البيانات كاملة مع الزوايا الأربع.';

  @override
  String get identityPassportInstruction2 =>
      'استخدم إضاءة جيدة وتجنب الوهج والظلال.';

  @override
  String get identityPassportInstruction3 =>
      'تأكد من أن جميع التفاصيل واضحة وقابلة للقراءة.';

  @override
  String get identitySelfieInstruction1 =>
      'انظر مباشرة إلى الكاميرا في إضاءة جيدة.';

  @override
  String get identitySelfieInstruction2 =>
      'اجعل وجهك كاملاً ظاهراً وفي منتصف الصورة.';

  @override
  String get identitySelfieInstruction3 =>
      'لا ترتدِ قبعة أو نظارة شمسية أو غطاء للوجه.';

  @override
  String get identityClose => 'إغلاق';

  @override
  String get identityContinue => 'متابعة';

  @override
  String get identityChooseSource => 'اختر مصدر الصورة';

  @override
  String get identityCamera => 'التقط صورة';

  @override
  String get identityGallery => 'اختر من المعرض';

  @override
  String get identityNoPhoto => 'لم يتم اختيار صورة';

  @override
  String get identityViewExample => 'عرض المثال';

  @override
  String get identityUploadPhoto => 'رفع الصورة';

  @override
  String get identityChangePhoto => 'تغيير الصورة';

  @override
  String get identitySubmit => 'إرسال للتحقق';

  @override
  String get identitySubmitted => 'تم إرسال مستندات هويتك للمراجعة.';

  @override
  String get identitySignInRequired =>
      'يرجى تسجيل الدخول قبل إرسال مستندات الهوية.';

  @override
  String get identityUploadFailed =>
      'تعذر رفع المستندات. يرجى المحاولة مرة أخرى.';

  @override
  String get identitySecureTitle => 'تحقق آمن';

  @override
  String get identitySecureBody =>
      'نطلب التحقق من هويتك للمساعدة في ضمان أن الحجوزات مشروعة ومتوافقة مع متطلبات السفر. تُشفّر مستنداتك وتُحفظ بأمان.';

  @override
  String get identityPassportPlaceholder => 'صفحة معلومات جواز السفر';

  @override
  String get identitySelfiePlaceholder => 'صورتك الشخصية';

  @override
  String get identitySelfieInstruction4 => 'استخدم خلفية بسيطة وغير مزدحمة.';

  @override
  String get identityPassportExampleTitle => 'مثال لجواز السفر';

  @override
  String get identitySelfieExampleTitle => 'مثال للصورة الشخصية';

  @override
  String get identityPassportExampleCaption =>
      'تأكد من أن جميع المعلومات واضحة وقابلة للقراءة.';

  @override
  String get identitySelfieExampleCaption =>
      'انظر مباشرة إلى الكاميرا مع إضاءة جيدة ومن دون قبعة أو نظارة شمسية.';

  @override
  String get bookingRoomCount => 'عدد الغرف';

  @override
  String get bookingNotes => 'ملاحظات';

  @override
  String get bookingAmountDueNow => 'المبلغ المستحق الآن';

  @override
  String get bookingCancelReason => 'سبب الإلغاء';

  @override
  String get bookingCancelReasonHint => 'أخبر الشركة بسبب حاجتك إلى الإلغاء';

  @override
  String get bookingCancellationPolicy => 'سياسة الإلغاء';

  @override
  String get bookingEstimatedRefund => 'المبلغ المتوقع استرداده';

  @override
  String bookingExpiresAt(String time) {
    return 'أكمل هذا الطلب قبل $time';
  }

  @override
  String get agencyBookingDetails => 'تفاصيل الحجز';

  @override
  String get agencyRequestInformation => 'طلب معلومات';

  @override
  String get agencyRequestInformationHint =>
      'وضّح بدقة ما الذي يجب على المعتمر تقديمه';

  @override
  String get agencyTravellerDocuments => 'مستندات المسافرين';

  @override
  String get agencyDeclineReason => 'سبب الرفض';

  @override
  String get offerFormBothHotelsRequired =>
      'يجب إدخال اسم ووصف مستقل لكل من الفندقين.';

  @override
  String offerFormHotelNightsTotal(int nights) {
    return 'يجب أن يكون مجموع ليالي الفندقين $nights.';
  }

  @override
  String get offerFormPaymentRequired => 'اختر طريقة دفع واحدة على الأقل.';

  @override
  String get offerFormRoomPriceRequired =>
      'يجب إدخال سعر صحيح لكل نوع غرفة محدد.';

  @override
  String get offerFormDepositTooHigh =>
      'لا يمكن أن تكون العربون أعلى من أقل سعر للفرد حسب نوع الغرفة.';

  @override
  String get workflowPauseTrip => 'إيقاف الرحلة مؤقتًا';

  @override
  String get workflowPausedSnack => 'تم إيقاف الرحلة وإزالتها من السوق.';

  @override
  String get offerUnavailable => 'غير متاح';

  @override
  String get agencyTripOverview => 'نظرة عامة';

  @override
  String get agencyTripBookings => 'الحجوزات';

  @override
  String get agencyTripTravellers => 'المسافرون';

  @override
  String get agencyTripDocumentsVisa => 'المستندات والتأشيرة';

  @override
  String get agencyTripOperations => 'العمليات';

  @override
  String get agencyTripUpdates => 'التحديثات';

  @override
  String get agencyTripDuplicate => 'نسخ الرحلة';

  @override
  String get agencyTripDuplicateBody =>
      'إنشاء مسودة جديدة تحتوي على الفنادق والأسعار والبرنامج والسياسات نفسها؟ يمكنك تعديل التواريخ والسعة قبل الإرسال.';

  @override
  String get agencyTripDuplicated => 'تم نسخ الرحلة كمسودة.';

  @override
  String get agencyTripDuplicateFailed => 'تعذر نسخ الرحلة.';

  @override
  String get agencyTripExportFailed => 'تعذر إنشاء ملف المسافرين.';

  @override
  String get agencyTripConfirmedValue => 'قيمة الحجوزات المؤكدة';

  @override
  String get agencyTripCollected => 'مدفوعات العملاء المستلمة';

  @override
  String get agencyTripDocumentsMissing => 'مستندات تحتاج إلى متابعة';

  @override
  String get agencyTripVisaPending => 'تأشيرات غير معتمدة';

  @override
  String get agencyTripPassengerExports => 'كشوف المسافرين';

  @override
  String get agencyTripExportExcel => 'تصدير Excel';

  @override
  String get agencyTripExportPdf => 'تصدير PDF';

  @override
  String get agencyTripSearchTravellers => 'البحث بالاسم أو رقم الجواز';

  @override
  String get agencyTripNoTravellers => 'لا يوجد مسافرون في هذه الرحلة بعد';

  @override
  String get agencyDocumentReview => 'مراجعة المستند';

  @override
  String get agencyDocumentUploads => 'مستندات المسافرين المرفوعة';

  @override
  String get agencyVisaStatus => 'حالة التأشيرة';

  @override
  String get agencyVisaReference => 'مرجع طلب التأشيرة';

  @override
  String get agencyTripTransportSeat => 'مقعد الطائرة أو الحافلة';

  @override
  String get agencyTripRooming => 'توزيع الغرف';

  @override
  String get agencyTripAddRoom => 'إضافة غرفة';

  @override
  String get agencyTripNoRooms => 'لم تتم تهيئة غرف بعد.';

  @override
  String get agencyTripCity => 'المدينة';

  @override
  String get agencyTripMakkah => 'مكة';

  @override
  String get agencyTripMadinah => 'المدينة المنورة';

  @override
  String get agencyTripRoomLabel => 'رقم الغرفة أو اسمها';

  @override
  String get agencyTripRoomPolicy => 'مجموعة الغرفة';

  @override
  String get agencyTripRoomFamily => 'عائلة';

  @override
  String get agencyTripRoomMale => 'رجال';

  @override
  String get agencyTripRoomFemale => 'نساء';

  @override
  String get agencyTripRoomCreated => 'تمت إضافة الغرفة.';

  @override
  String get agencyTripRoomDeleted => 'تم حذف الغرفة.';

  @override
  String get agencyTripTransport => 'النقل';

  @override
  String get agencyTripAddTransport => 'إضافة وسيلة نقل';

  @override
  String get agencyTripNoTransport =>
      'لم تتم إضافة تفاصيل رحلة جوية أو حافلة بعد.';

  @override
  String get agencyTripTransportProvider => 'شركة الطيران أو الحافلات';

  @override
  String get agencyTripTransportReference => 'رقم الرحلة أو الحافلة أو المركبة';

  @override
  String get agencyTripDeparturePlace => 'مكان المغادرة';

  @override
  String get agencyTripMeetingPoint => 'نقطة التجمع';

  @override
  String get agencyTripGuide => 'المرشد المكلّف';

  @override
  String get agencyTripTransportCreated => 'تمت إضافة وسيلة النقل.';

  @override
  String get agencyTripTransportDeleted => 'تم حذف وسيلة النقل.';

  @override
  String get agencyTripNewAnnouncement => 'إعلان جديد';

  @override
  String get agencyTripAnnouncementTitle => 'عنوان الإعلان';

  @override
  String get agencyTripAnnouncementMessage => 'الرسالة';

  @override
  String get agencyTripAudience => 'المستلمون';

  @override
  String get agencyTripAudienceUnpaid =>
      'المسافرون الذين لديهم مبالغ غير مدفوعة';

  @override
  String get agencyTripSendAnnouncement => 'إرسال الإعلان';

  @override
  String get agencyTripAnnouncementSent => 'تم إرسال الإعلان.';

  @override
  String get agencyTripNoAnnouncements => 'لم يتم إرسال أي إعلانات بعد';

  @override
  String get agencyWalletTitle => 'المحفظة والدفعات';

  @override
  String get agencyWalletSubtitle =>
      'أرباح الدفع الإلكتروني وعمولة النقد في رصيد واحد';

  @override
  String get agencyWalletTawafOwesYou => 'طواف مدينة لشركتك';

  @override
  String get agencyWalletYouOweTawaf => 'شركتك مدينة لطواف';

  @override
  String get agencyWalletSettled => 'رصيدك مسوّى';

  @override
  String get agencyWalletBalanceExplanation =>
      'تضيف المدفوعات الإلكترونية صافي أرباحك، وتخصم الحجوزات النقدية عمولة طواف. تُسجّل الدفعات والاستردادات تلقائيًا.';

  @override
  String get agencyWalletAvailablePayout => 'متاح للدفع';

  @override
  String get agencyWalletPendingPayout => 'دفعة قيد الانتظار';

  @override
  String get agencyWalletActivity => 'حركة المحفظة';

  @override
  String get agencyWalletNoActivity => 'لا توجد حركة في المحفظة بعد';

  @override
  String get agencyWalletNoActivityBody => 'ستظهر مدفوعات العملاء الناجحة هنا.';

  @override
  String get agencyWalletPayouts => 'سجل الدفعات';

  @override
  String get agencyWalletPaid => 'مدفوع';

  @override
  String get agencyWalletFailed => 'فشل';

  @override
  String get agencyWalletPending => 'قيد الانتظار';

  @override
  String get agencyWalletOnlinePayment => 'أرباح حجز إلكتروني';

  @override
  String get agencyWalletCashCommission => 'عمولة حجز نقدي';

  @override
  String get agencyWalletRefund => 'عكس مبلغ مسترد';

  @override
  String get agencyWalletPayout => 'دفعة للشركة';

  @override
  String get agencyWalletAdjustment => 'تسوية الرصيد';

  @override
  String get agencyOverviewUnpaidBookings => 'حجوزات لديها مبالغ غير مدفوعة';

  @override
  String get agencyManagementTitle => 'الفريق والتقارير والتقييمات';

  @override
  String get agencyManagementMenuSubtitle =>
      'الأداء وآراء العملاء وصلاحيات الموظفين';

  @override
  String get agencyManagementReports => 'التقارير';

  @override
  String get agencyManagementStaff => 'الموظفون';

  @override
  String get agencyManagementBookingValue => 'قيمة الحجوزات النشطة';

  @override
  String get agencyManagementOccupancy => 'نسبة إشغال المقاعد';

  @override
  String get agencyManagementCancellationRate => 'معدل الإلغاء';

  @override
  String get agencyManagementTripPerformance => 'أداء الرحلات';

  @override
  String get agencyManagementNoReportData => 'لا تتوفر بيانات رحلات بعد';

  @override
  String get agencyManagementNoReviews => 'لا توجد تقييمات من العملاء بعد';

  @override
  String get agencyManagementReplyReview => 'الرد على التقييم';

  @override
  String get agencyManagementReplyReviewHint => 'اكتب ردًا عامًا مفيدًا';

  @override
  String get agencyManagementReplySent => 'تم نشر ردك العام.';

  @override
  String get agencyManagementAddStaff => 'إضافة موظف';

  @override
  String get agencyManagementProfileId => 'معرّف ملف المستخدم';

  @override
  String get agencyManagementProfileIdHelp =>
      'أدخل معرّف UUID لملف الموظف في طواف';

  @override
  String get agencyManagementRole => 'الدور';

  @override
  String get agencyManagementStaffAdded => 'تمت إضافة صلاحية الموظف.';

  @override
  String get agencyManagementStaffRemoved => 'تم حذف صلاحية الموظف.';

  @override
  String get agencyManagementNoStaff => 'لم تتم إضافة موظفين بعد';

  @override
  String get agencyManagementNoStaffBody =>
      'أضف الموظفين وامنح كل دور الصلاحيات التي يحتاجها فقط.';

  @override
  String agencyManagementTripCounts(int bookings, int travellers) {
    return 'الحجوزات: $bookings · المسافرون: $travellers';
  }

  @override
  String get agencyTripAssignRoom => 'تعيين غرفة (الأسرّة المتبقية)';

  @override
  String get bookingTripUpdates => 'تحديثات وإعلانات الرحلة';

  @override
  String get bookingTripNoUpdates => 'لم تنشر الشركة أي تحديثات بعد.';

  @override
  String get bookingAdditionalDocument => 'رفع مستند آخر';

  @override
  String get bookingAdditionalDocumentUploaded =>
      'تم رفع المستند لمراجعة الشركة.';

  @override
  String get bookingDocumentNationalId => 'الهوية الوطنية';

  @override
  String get bookingDocumentResidency => 'بطاقة الإقامة';

  @override
  String get bookingDocumentVaccination => 'شهادة التطعيم';

  @override
  String get bookingDocumentAgreement => 'الاتفاقية الموقعة';

  @override
  String get bookingDocumentPaymentReceipt => 'إيصال الدفع';

  @override
  String get bookingDocumentOther => 'مستند آخر';

  @override
  String get bookingPassportName => 'الاسم كما هو مكتوب في جواز السفر';

  @override
  String get bookingPassportNameHint => 'تهجئة الاسم اللاتينية في الجواز';

  @override
  String get bookingLocalName => 'الاسم باللغة المحلية (اختياري)';

  @override
  String get bookingLocalNameHint => 'الاسم بالكردية أو العربية';
}
