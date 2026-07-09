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
  String get offerDetailFreeCancellation =>
      'إلغاء مجاني حتى 30 يومًا قبل موعد السفر';

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
    return 'سيتم إلغاء \"$title\". الإلغاء مجاني حتى 30 يومًا قبل المغادرة.';
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
      'نعم — الإلغاء مجاني حتى 30 يومًا قبل المغادرة. افتح حجوزاتي واضغط \"إلغاء الحجز\" على الرحلة.';

  @override
  String get helpFaq3Q => 'هل الوكالات موثقة؟';

  @override
  String get helpFaq3A =>
      'كل وكالة مدرجة مرخصة حكوميًا وتم التحقق منها من قبل فريقنا قبل نشر باقاتها.';

  @override
  String get helpFaq4Q => 'ماذا تشمل الباقة؟';

  @override
  String get helpFaq4A =>
      'كل عرض يوضح ما يشمله — التأشيرة والنقل والفندق والوجبات والزيارات المصحوبة بمرشد. راجع قسم \"ما تشمله الباقة\" في العرض.';

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
  String get adminNoLink => 'بدون ربط';

  @override
  String get adminAdImage => 'صورة الإعلان';

  @override
  String get adminPickImage => 'اضغط لاختيار صورة';

  @override
  String get adminAdCreated => 'تم نشر الإعلان في الصفحة الرئيسية!';

  @override
  String get adminFeaturedOffers => 'الباقات المميزة في الرئيسية';

  @override
  String get adminFeaturedHint =>
      'الباقات المميزة بنجمة تظهر أولًا في الصفحة الرئيسية.';

  @override
  String get adminNoOffers => 'لا توجد باقات منشورة بعد.';

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
  String get authErrInvalidEmail => 'يرجى إدخال بريد إلکتروني صالح.';

  @override
  String get accountChangeEmail => 'تغيير البريد الإلکتروني';

  @override
  String get accountChangeEmailBody =>
      'أدخل بريدک الإلکتروني الجديد. ستحتاج إلى تأکيد التغيير عبر البريد الإلکتروني.';

  @override
  String get accountUpdate => 'تحديث';

  @override
  String get accountEmailConfirmationTitle => 'تم إرسال التأکيد';

  @override
  String get accountEmailConfirmationBody =>
      'تم إرسال رابط تأکيد إلى بريدک الإلکتروني الجديد. يرجى التحقق من بريدک لإتمام التغيير.';
}
