// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appTitle => 'عومرە';

  @override
  String get navHome => 'ماڵەوە';

  @override
  String get navAgencies => 'ئاژانسەکان';

  @override
  String get navOffers => 'ئۆفەرەکان';

  @override
  String get navBookings => 'حجزەکان';

  @override
  String get navProfile => 'پرۆفایل';

  @override
  String get languageEnglish => 'ئینگلیزی';

  @override
  String get languageArabic => 'عەرەبی';

  @override
  String get languageKurdish => 'کوردی';

  @override
  String get chooseLanguageTitle => 'زمان هەڵبژێرە';

  @override
  String get profileSavedTrips => 'گەشتە هەڵگیراوەکان';

  @override
  String get profileMyBookings => 'حجزەکانم';

  @override
  String get profileNotifications => 'ئاگادارکردنەوەکان';

  @override
  String get profilePaymentMethods => 'شێوازەکانی پارەدان';

  @override
  String get profileLanguage => 'زمان';

  @override
  String get profilePrivacySecurity => 'تایبەتمەندی و ئاسایش';

  @override
  String get profileHelpSupport => 'یارمەتی و پشتگیری';

  @override
  String get profileAgencyDivider => 'ئاژانس';

  @override
  String profileAgencyDashboardWithName(String name) {
    return 'داشبۆردی ئاژانس · $name';
  }

  @override
  String get profileAgencyPortal => 'دەروازەی ئاژانس';

  @override
  String get comingSoonBody => 'ئەم تایبەتمەندییە بەم زووانە دێت.';

  @override
  String get profilePilgrim => 'حاجی';

  @override
  String get profileGoldMember => '★ ئەندامی زێڕین';

  @override
  String get profileStatTrips => 'گەشتەکان';

  @override
  String get profileStatSaved => 'هەڵگیراو';

  @override
  String get profileStatReviews => 'هەڵسەنگاندنەکان';

  @override
  String get savedTripsTitle => 'گەشتە هەڵگیراوەکان';

  @override
  String get savedTripsEmptyTitle => 'هێشتا هیچ گەشتێکی هەڵگیراو نییە';

  @override
  String get savedTripsEmptyBody =>
      'کلیک لەسەر دڵی هەر ئۆفەرێک بکە بۆ هەڵگرتنی.';

  @override
  String get priceFromPrefix => 'لە ';

  @override
  String get offerDetailOverview => 'تێڕوانینی گشتی';

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
    return 'گەشتێکی $days ڕۆژە بە $transport بۆ $city، نیشتەجێبوون لە هۆتێلی $hotelی $acc ئەستێرە، تەنها $distance لە حەرەم دوورە. ڕابەرایەتی تایبەتی گرووپی $company، پشتگیری ڕۆژانەی عیبادەت و زیارەتی تەواو لەخۆدەگرێت.';
  }

  @override
  String offerDetailDaysCount(int days) {
    return '$days ڕۆژ';
  }

  @override
  String offerDetailNightsCount(int nights) {
    return '$nights شەو';
  }

  @override
  String offerDetailStarCount(int acc) {
    return '$acc ئەستێرە';
  }

  @override
  String get offerDetailHotelLower => 'هۆتێل';

  @override
  String get offerDetailPilgrimReviews => ' هەڵسەنگاندنی حاجی';

  @override
  String get offerDetailViewAgency => 'بینینی کۆمپانیا ←';

  @override
  String get offerDetailAccommodation => 'نیشتەجێبوون';

  @override
  String offerDetailDistanceToHaram(String distance) {
    return '$distance بۆ حەرەم';
  }

  @override
  String get offerDetailRoom => 'ژوور';

  @override
  String get offerDetailMeals => 'خواردن';

  @override
  String get offerDetailTransportation => 'گواستنەوە';

  @override
  String offerDetailCarrierTransfersIncluded(String carrier) {
    return '$carrier · هەموو گواستنەوە زەمینییەکان لەخۆدەگرێت';
  }

  @override
  String get offerDetailItinerary => 'بەرنامەی گەشت';

  @override
  String get offerDetailWhatsIncluded => 'ئەوەی لەخۆدەگرێت';

  @override
  String get offerDetailPackagePerPerson => 'پاکێج (بۆ هەر کەسێک)';

  @override
  String get offerDetailVisaProcessing => 'ڤیزا و پرۆسەکان';

  @override
  String get offerDetailIncluded => 'لەخۆگیراوە';

  @override
  String get offerDetailTaxesFees => 'باج و کرێ';

  @override
  String get offerDetailTotalFrom => 'کۆی گشتی لە';

  @override
  String get offerDetailFromPerPerson => 'لە / بۆ هەر کەسێک';

  @override
  String get offerDetailBookThisTrip => 'ئەم گەشتە حجز بکە';

  @override
  String get offerDetailConfirmBooking => 'دڵنیاکردنەوەی حجز';

  @override
  String offerDetailBookingSummaryLine(int days, String transport, int acc) {
    return '$days ڕۆژ · $transport · $acc★';
  }

  @override
  String get offerDetailTravelers => 'گەشتیاران';

  @override
  String offerDetailPricePerPerson(String price) {
    return '$price بۆ هەر کەسێک';
  }

  @override
  String get offerDetailTotal => 'کۆی گشتی';

  @override
  String get offerDetailBookingConfirmed => 'حجز دڵنیا کرایەوە!';

  @override
  String offerDetailConfirmAndPay(String total) {
    return 'دڵنیاکردنەوە و پارەدان $total';
  }

  @override
  String get offerDetailFreeCancellation =>
      'هەڵوەشاندنەوەی بەخۆڕایی تا ٣٠ ڕۆژ پێش بەڕێکەوتن';

  @override
  String get offerDetailDepartureDate => 'بەرواری گەشت';

  @override
  String get dateToBeScheduled => 'دواتر دیاری دەکرێت';

  @override
  String get offersTitle => 'ئۆفەرەکان';

  @override
  String offersPackagesMatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پاکێج گونجاون',
      one: '$count پاکێج گونجاوە',
    );
    return '$_temp0';
  }

  @override
  String get offersFilters => 'فلتەرەکان';

  @override
  String get offersAll => 'هەمووی';

  @override
  String get offersByAir => 'بە فڕۆکە';

  @override
  String get offersByCoach => 'بە پاس';

  @override
  String get offers5Star => '٥ ئەستێرە';

  @override
  String get offers4Star => '٤ ئەستێرە';

  @override
  String get offersSort => 'ڕیزکردن';

  @override
  String get offersPopular => 'بەناوبانگ';

  @override
  String get offersPriceLowToHigh => 'نرخ ↑';

  @override
  String get offersPriceHighToLow => 'نرخ ↓';

  @override
  String get offersNoMatches => 'هیچ ئەنجامێک نییە';

  @override
  String get offersTryWideningFilters => 'فلتەرەکان فراوانتر بکە.';

  @override
  String get offersResetFilters => 'ڕێکخستنی فلتەرەکان لابە';

  @override
  String offersDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕۆژ',
      one: '$count ڕۆژ',
    );
    return '$_temp0';
  }

  @override
  String offersStarCount(int count) {
    return '$count ئەستێرە';
  }

  @override
  String get offersFromPricePrefix => 'لە';

  @override
  String get filterSheetTitle => 'فلتەرەکان';

  @override
  String get filterSheetReset => 'ڕێکخستنەوە';

  @override
  String get filterSheetMaxPricePerPerson => 'زۆرترین نرخ / بۆ هەر کەسێک';

  @override
  String get filterSheetTransportation => 'گواستنەوە';

  @override
  String get filterSheetAll => 'هەمووی';

  @override
  String get filterSheetByAir => 'بە فڕۆکە';

  @override
  String get filterSheetByCoach => 'بە پاس';

  @override
  String get filterSheetAccommodation => 'نیشتەجێبوون';

  @override
  String get filterSheetAny => 'هەرکام';

  @override
  String get filterSheetTripDuration => 'ماوەی گەشت';

  @override
  String get filterSheetDuration7to9 => '٧–٩ ڕۆژ';

  @override
  String get filterSheetDuration10to14 => '١٠–١٤ ڕۆژ';

  @override
  String get filterSheetDuration15Plus => '+١٥ ڕۆژ';

  @override
  String get filterSheetAgencyRating => 'هەڵسەنگاندنی ئاژانس';

  @override
  String filterSheetShowPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پیشاندانی $count پاکێج',
      one: 'پیشاندانی $count پاکێج',
    );
    return '$_temp0';
  }

  @override
  String get homeGreeting => 'السلام عليكم';

  @override
  String get homeWelcomePilgrim => 'بەخێربێیت، ئەی حاجی';

  @override
  String get homeFeatured => 'تایبەت';

  @override
  String homeDaysStarHotel(int days, int acc) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days ڕۆژ',
      one: '$days ڕۆژ',
    );
    return '$_temp0 · هۆتێلی $acc ئەستێرە';
  }

  @override
  String get homeSearchPlaceholder => 'گەڕان بۆ پاکێجەکانی عومرە…';

  @override
  String get homeTopAgencies => 'باشترین ئاژانسەکان';

  @override
  String get homeViewAll => 'بینینی هەموو';

  @override
  String homeRatingOffersCount(double rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پێشنیار',
      one: '$count پێشنیار',
    );
    return '$rating · $_temp0';
  }

  @override
  String get homeCuratedPackages => 'پاکێجە هەڵبژێردراوەکان';

  @override
  String homeDaysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days ڕۆژ',
      one: '$days ڕۆژ',
    );
    return '$_temp0';
  }

  @override
  String get homeFromPrefix => 'لە ';

  @override
  String get searchHint => 'گەڕان بۆ پاکێج، ئاژانس، شار…';

  @override
  String get searchPopularSearches => 'گەڕانە باوەکان';

  @override
  String get searchSuggestionPremiumPackages => 'پاکێجی تایبەت';

  @override
  String get searchSuggestionByAir => 'بە فڕۆکە';

  @override
  String get searchSuggestionByCoach => 'بە پاس';

  @override
  String get searchSuggestionRamadan => 'ڕەمەزان';

  @override
  String get searchSuggestionFiveStar => '٥ ئەستێرە';

  @override
  String get searchSuggestionMadinah => 'مەدینە';

  @override
  String get searchSuggestionFamily => 'خێزانی';

  @override
  String searchNoResultsFor(String query) {
    return 'هیچ ئەنجامێک نەدۆزرایەوە بۆ \"$query\"';
  }

  @override
  String get searchTryDifferentTerm =>
      'ناوێکی تر، شارێک یان هۆتێلێکی تر تاقی بکەرەوە.';

  @override
  String get searchFromPrefix => 'لە ';

  @override
  String get companiesTitle => 'ئاژانسەکان';

  @override
  String companiesSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕێکخەری گەشتی عومرەی پشتڕاستکراو',
      one: '$count ڕێکخەری گەشتی عومرە پشتڕاستکراو',
    );
    return '$_temp0';
  }

  @override
  String get companiesVerifiedBadge => 'پشتڕاستکراوە';

  @override
  String companiesLocationEst(String location, int since) {
    return '$location · دامەزراوە لە $since';
  }

  @override
  String companiesPackageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پاکێج',
      one: '$count پاکێج',
    );
    return '$_temp0';
  }

  @override
  String get companiesFromPrefix => 'لە ';

  @override
  String get companyDetailAbout => 'دەربارە';

  @override
  String companyDetailPackagesHeader(int count) {
    return 'پاکێجەکان ($count)';
  }

  @override
  String companyDetailLocationSince(String location, int since) {
    return '$location · دامەزراوە لە ساڵی $since';
  }

  @override
  String companyDetailReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count هەڵسەنگاندن',
      one: '$count هەڵسەنگاندن',
    );
    return '$_temp0';
  }

  @override
  String get companyDetailPackagesLabel => 'پاکێجەکان';

  @override
  String get companyDetailStartingLabel => 'نرخی سەرەتا';

  @override
  String get companyDetailFromPrefix => 'لە ';

  @override
  String get bookingsTitle => 'گەشتە تۆمارکراوەکانم';

  @override
  String bookingsTripCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count گەشت',
      one: '$count گەشت',
    );
    return '$_temp0';
  }

  @override
  String bookingsPaxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کەس',
      one: '$count کەس',
    );
    return '$_temp0';
  }

  @override
  String bookingsRefLabel(String ref) {
    return 'ژمارەی سەلماندن $ref';
  }

  @override
  String get bookingsEmptyTitle => 'هێشتا هیچ گەشتێک تۆمار نەکراوە';

  @override
  String get bookingsEmptyBody => 'گەشتە پشتڕاستکراوەکانت لێرە دەردەکەون.';

  @override
  String get bookingsBrowseOffers => 'بینینی پێشنیارەکان';

  @override
  String get bookingsStatusConfirmed => 'پشتڕاستکراوە';

  @override
  String get bookingsStatusPending => 'چاوەڕوانە';

  @override
  String get bookingsStatusCancelled => 'هەڵوەشێنراوە';

  @override
  String get bookingsCancelBooking => 'هەڵوەشاندنەوەی گەشت';

  @override
  String get bookingsCancelTitle => 'ئەم گەشتە هەڵبوەشێنرێتەوە؟';

  @override
  String bookingsCancelBody(String title) {
    return '\"$title\" هەڵدەوەشێنرێتەوە. هەڵوەشاندنەوە بێبەرامبەرە تا 30 ڕۆژ پێش گەشت.';
  }

  @override
  String get bookingsKeepBooking => 'هێشتنەوەی گەشت';

  @override
  String get bookingsConfirmCancel => 'بەڵێ، هەڵیبوەشێنەوە';

  @override
  String get bookingsCancelledSnack => 'گەشتەکە هەڵوەشێنرایەوە.';

  @override
  String get notificationsTitle => 'ئاگادارکردنەوەکان';

  @override
  String get notificationsMarkAllRead => 'هەموو وەک خوێندراوە دابنێ';

  @override
  String get notificationsClearAll => 'سڕینەوەی هەموو';

  @override
  String get notificationsEmptyTitle => 'هیچ ئاگادارکردنەوەیەک نییە';

  @override
  String get notificationsEmptyBody => 'هەموو شتێکت بینیوە.';

  @override
  String get notifWelcomeTitle => 'بەخێربێیت بۆ ئەپی عومرە';

  @override
  String get notifWelcomeBody =>
      'ئاژانسی متمانەپێکراو و پاکێجی هەڵبژێردراو بۆ گەشتەکەت بدۆزەرەوە.';

  @override
  String get notifPromoTitle => 'پێشنیارە وەرزییەکان بەردەستن';

  @override
  String get notifPromoBody =>
      'ئەم مانگە تا 20% لە پاکێجە هەڵبژێردراوەکان پاشەکەوت بکە.';

  @override
  String get notifTripReminderTitle => 'گەشتی داهاتوو';

  @override
  String notifTripReminderBody(String title) {
    return 'گەشتەکەت \"$title\" نزیک بووەتەوە. بەڵگەنامەکانت بپشکنە.';
  }

  @override
  String get notifBookingConfirmedTitle => 'گەشتەکە پشتڕاستکرایەوە';

  @override
  String notifBookingConfirmedBody(String title) {
    return 'گەشتەکەت بۆ \"$title\" پشتڕاستکرایەوە. بۆ وردەکاری سەیری گەشتەکانم بکە.';
  }

  @override
  String get notifBookingCancelledTitle => 'گەشتەکە هەڵوەشێنرایەوە';

  @override
  String notifBookingCancelledBody(String title) {
    return 'گەشتەکەت بۆ \"$title\" هەڵوەشێنرایەوە.';
  }

  @override
  String get notifJustNow => 'هەر ئێستا';

  @override
  String notifMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خولەک لەمەوبەر',
      one: '$count خولەک لەمەوبەر',
    );
    return '$_temp0';
  }

  @override
  String notifHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کاتژمێر لەمەوبەر',
      one: '$count کاتژمێر لەمەوبەر',
    );
    return '$_temp0';
  }

  @override
  String notifDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕۆژ لەمەوبەر',
      one: '$count ڕۆژ لەمەوبەر',
    );
    return '$_temp0';
  }

  @override
  String get paymentTitle => 'شێوازەکانی پارەدان';

  @override
  String get paymentDefaultBadge => 'بنەڕەتی';

  @override
  String get paymentSetDefault => 'کردنە بنەڕەتی';

  @override
  String get paymentRemoveCard => 'لابردنی کارت';

  @override
  String get paymentRemoveTitle => 'ئەم کارتە لاببرێت؟';

  @override
  String paymentRemoveBody(String brand, String last4) {
    return 'کارتی $brand کە بە $last4 کۆتایی دێت لادەبرێت.';
  }

  @override
  String get paymentKeepCard => 'هێشتنەوە';

  @override
  String get paymentConfirmRemove => 'لابردن';

  @override
  String get paymentAddCard => 'زیادکردنی کارت';

  @override
  String get paymentAddCardTitle => 'زیادکردنی کارتی نوێ';

  @override
  String get paymentCardHolder => 'ناوی خاوەنی کارت';

  @override
  String get paymentCardHolderHint => 'ناو لەسەر کارت';

  @override
  String get paymentCardNumber => 'ژمارەی کارت';

  @override
  String get paymentCardNumberHint => '1234 5678 9012 3456';

  @override
  String get paymentExpiry => 'بەرواری بەسەرچوون';

  @override
  String get paymentExpiryHint => 'MM/YY';

  @override
  String get paymentCvv => 'CVV';

  @override
  String get paymentCvvHint => '123';

  @override
  String get paymentSaveCard => 'پاشەکەوتکردنی کارت';

  @override
  String get paymentCardAdded => 'کارتەکە زیادکرا.';

  @override
  String get paymentCardRemoved => 'کارتەکە لابرا.';

  @override
  String get paymentEmptyTitle => 'هیچ کارتێک پاشەکەوت نەکراوە';

  @override
  String get paymentEmptyBody => 'کارتێک زیاد بکە بۆ خێراکردنی پارەدان.';

  @override
  String paymentExpiresLabel(String expiry) {
    return 'بەسەردەچێت لە $expiry';
  }

  @override
  String get paymentErrHolder => 'ناوی خاوەنی کارت بنووسە.';

  @override
  String get paymentErrNumber => 'ژمارەیەکی دروستی کارت بنووسە (13–19 ژمارە).';

  @override
  String get paymentErrExpiry => 'بەروارێکی دروستی داهاتوو بنووسە (MM/YY).';

  @override
  String get paymentErrCvv => 'کۆدێکی دروستی CVV بنووسە (3–4 ژمارە).';

  @override
  String get privacyTitle => 'تایبەتمەندی و ئاسایش';

  @override
  String get privacySectionSecurity => 'ئاسایش';

  @override
  String get privacyBiometric => 'قوفڵی ئەپ بە پەنجەمۆر';

  @override
  String get privacyBiometricSub =>
      'داواکردنی ناسینەوەی ڕوخسار / پەنجەمۆر بۆ کردنەوەی ئەپ';

  @override
  String get privacyTwoFactor => 'سەلماندنی دوو هەنگاوی';

  @override
  String get privacyTwoFactorSub =>
      'پشتڕاستکردنەوەی چوونەژوورەوە بە کۆدی تاک بەکارهێنان';

  @override
  String get privacySectionPrivacy => 'تایبەتمەندی';

  @override
  String get privacyMarketing => 'ئیمەیلی بازرگانی';

  @override
  String get privacyMarketingSub =>
      'وەرگرتنی پێشنیار و ئامۆژگاری گەشت بە ئیمەیل';

  @override
  String get privacyActivity => 'هاوبەشکردنی داتای بەکارهێنان';

  @override
  String get privacyActivitySub =>
      'یارمەتی باشترکردنی ئەپ بدە بە داتای نەناسراو';

  @override
  String get privacyChangePassword => 'گۆڕینی وشەی نهێنی';

  @override
  String get privacyCurrentPassword => 'وشەی نهێنی ئێستا';

  @override
  String get privacyNewPassword => 'وشەی نهێنی نوێ';

  @override
  String get privacyConfirmPassword => 'دووبارە وشەی نهێنی نوێ';

  @override
  String get privacyUpdatePassword => 'نوێکردنەوەی وشەی نهێنی';

  @override
  String get privacyPasswordChanged => 'وشەی نهێنی نوێکرایەوە.';

  @override
  String get privacyErrCurrentRequired => 'وشەی نهێنی ئێستات بنووسە.';

  @override
  String get privacyErrTooShort => 'وشەی نهێنی نوێ دەبێت لانیکەم 6 پیت بێت.';

  @override
  String get privacyErrNoMatch => 'وشە نهێنییەکان وەک یەک نین.';

  @override
  String get privacyBiometricMobileOnly =>
      'قوفڵی پەنجەمۆر تەنها لە ئەپی مۆبایلدا بەردەستە.';

  @override
  String get privacyBiometricUnavailable =>
      'هیچ پەنجەمۆر یان ناسینەوەی ڕوخسار لەم ئامێرەدا ڕێکنەخراوە.';

  @override
  String get lockTitle => 'ئەپەکە قوفڵ دراوە';

  @override
  String get lockSubtitle => 'پەنجەمۆر یان ڕوخسارت بەکاربهێنە بۆ بەردەوامبوون.';

  @override
  String get lockUnlock => 'کردنەوە';

  @override
  String get lockFailed => 'سەلماندن سەرنەکەوت. دووبارە هەوڵ بدەرەوە.';

  @override
  String get lockReason => 'ئەپی عومرە بکەرەوە';

  @override
  String get helpTitle => 'یارمەتی و پشتگیری';

  @override
  String get helpFaqHeader => 'پرسیارە باوەکان';

  @override
  String get helpFaq1Q => 'چۆن پاکێجی عومرە تۆمار بکەم؟';

  @override
  String get helpFaq1A =>
      'هەر پێشنیارێک بکەرەوە، دەست بنێ بە \"ئەم گەشتە تۆمار بکە\"، ژمارەی گەشتیاران هەڵبژێرە و پشتڕاستی بکەرەوە. گەشتەکەت لە گەشتەکانم دەردەکەوێت لەگەڵ ژمارەی سەلماندن.';

  @override
  String get helpFaq2Q => 'دەتوانم گەشتێک هەڵبوەشێنمەوە؟';

  @override
  String get helpFaq2A =>
      'بەڵێ — هەڵوەشاندنەوە بێبەرامبەرە تا 30 ڕۆژ پێش گەشت. گەشتەکانم بکەرەوە و دەست بنێ بە \"هەڵوەشاندنەوەی گەشت\".';

  @override
  String get helpFaq3Q => 'ئاژانسەکان پشتڕاستکراون؟';

  @override
  String get helpFaq3A =>
      'هەموو ئاژانسێکی تۆمارکراو مۆڵەتی حکومی هەیە و لەلایەن تیمەکەمانەوە پشتڕاستکراوەتەوە پێش بڵاوکردنەوەی پاکێجەکانیان.';

  @override
  String get helpFaq4Q => 'پاکێجەکە چی لەخۆدەگرێت؟';

  @override
  String get helpFaq4A =>
      'هەر پێشنیارێک ئەوانە دەنووسێت کە لەخۆی دەگرێت — ڤیزا، گواستنەوە، هوتێل، خواردن و زیارەتی بە ڕێنمایی. سەیری بەشی \"چی لەخۆدەگرێت\" بکە.';

  @override
  String get helpFaq5Q => 'ئاژانسەکان چۆن بەشداری پلاتفۆرمەکە دەکەن؟';

  @override
  String get helpFaq5A =>
      'ئاژانسەکان لە ڕێگەی پۆرتاڵی ئاژانسەوە لە تابی پڕۆفایل خۆیان تۆمار دەکەن. دوای پشتڕاستکردنەوە دەتوانن پاکێج بڵاو بکەنەوە و بەڕێوەیان ببەن.';

  @override
  String get helpContactHeader => 'پەیوەندیمان پێوە بکە';

  @override
  String get helpContactEmail => 'پشتگیری بە ئیمەیل';

  @override
  String get helpContactPhone => 'پەیوەندی تەلەفۆنی';

  @override
  String helpCopiedToClipboard(String value) {
    return '$value کۆپی کرا';
  }

  @override
  String get helpMessageHeader => 'نامەیەکمان بۆ بنێرە';

  @override
  String get helpMessageHint => 'پرسیار یان کێشەکەت باس بکە…';

  @override
  String get helpMessageSend => 'ناردنی نامە';

  @override
  String get helpMessageSent =>
      'نامەکە نێردرا! لە ماوەی 24 کاتژمێردا وەڵام دەدەینەوە.';

  @override
  String get helpMessageEmpty => 'تکایە سەرەتا نامەیەک بنووسە.';

  @override
  String get agencyLoginTitle => 'پۆرتاڵی ئاژانس';

  @override
  String get agencyLoginSubtitle =>
      'بچۆ ژوورەوە بۆ بەڕێوەبردنی پاکێجەکانت و پڕۆفایلت.';

  @override
  String get agencyLoginEmail => 'ئیمەیل';

  @override
  String get agencyLoginPassword => 'وشەی نهێنی';

  @override
  String get agencyLoginInvalidCredentials =>
      'ئیمەیل یان وشەی نهێنی هەڵەیە. تاقی بکەرەوە: admin@alsafwah.com / pass123';

  @override
  String get agencyLoginSignIn => 'چوونەژوورەوە';

  @override
  String get agencyLoginDemoCredentials => 'زانیاری نموونەیی';

  @override
  String get agencyLoginDemoEmail => 'ئیمەیل: agency.demo@umrahapp.dev';

  @override
  String get agencyLoginDemoPassword => 'وشەی نهێنی: demo1234';

  @override
  String get agencyLoginDemoHint =>
      '(admin@noorharamain.com هتد بەکاربهێنە بۆ ئاژانسەکانی تر)';

  @override
  String agencyDashboardYourPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پاکێجەکانت ($count)',
      one: 'پاکێجەکانت (1)',
      zero: 'هیچ پاکێجێک نییە',
    );
    return '$_temp0';
  }

  @override
  String get agencyDashboardAddPackage => 'زیادکردنی پاکێج';

  @override
  String get agencyDashboardVerificationPending => 'پشتڕاستکردنەوە چاوەڕوانە';

  @override
  String get agencyDashboardVerificationPendingBody =>
      'هەژمارەکەت لەژێر پێداچوونەوەدایە. کاتێک پشتڕاست کرایەوە دەتوانیت پاکێج بڵاو بکەیتەوە و پڕۆفایلت دەستکاری بکەیت.';

  @override
  String get agencyDashboardEditProfile => 'دەستکاریکردنی پڕۆفایل';

  @override
  String get agencyDashboardVerifiedAgency => 'ئاژانسی پشتڕاستکراو';

  @override
  String get agencyDashboardPendingVerification => 'پشتڕاستکردنەوە چاوەڕوانە';

  @override
  String agencyDashboardDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕۆژ',
      one: '١ ڕۆژ',
    );
    return '$_temp0';
  }

  @override
  String get agencyDashboardDeletePackageTitle => 'پاکێجەکە بسڕدرێتەوە؟';

  @override
  String agencyDashboardDeletePackageBody(String title) {
    return 'ئەمە بە یەکجاری \"$title\" دەسڕێتەوە.';
  }

  @override
  String get agencyDashboardCancel => 'هەڵوەشاندنەوە';

  @override
  String get agencyDashboardDelete => 'سڕینەوە';

  @override
  String get agencyDashboardNoPackagesYet => 'هێشتا هیچ پاکێجێک نییە';

  @override
  String get agencyDashboardNoPackagesHint =>
      'لەسەر \"زیادکردنی پاکێج\" دابگرە بۆ بڵاوکردنەوەی یەکەم پێشکەشکردنی عومرەت.';

  @override
  String get editAgencyProfileTitle => 'دەستکاریکردنی پڕۆفایل';

  @override
  String get editAgencyProfileSave => 'پاشەکەوتکردن';

  @override
  String get editAgencyProfileUpdated => 'پڕۆفایل نوێ کرایەوە!';

  @override
  String editAgencyProfileSinceReadOnly(int since) {
    return 'لە $sinceەوە · خانەکانی سەرەوە تەنها بۆ خوێندنەوەن';
  }

  @override
  String get editAgencyProfileLocationLabel => 'شوێن / شار';

  @override
  String get editAgencyProfileLocationHint => 'بۆ نموونە: ڕیاز، سعودیە';

  @override
  String get editAgencyProfileAboutLabel => 'دەربارەی ئاژانسەکەت';

  @override
  String get editAgencyProfileAboutHint =>
      'ئاژانسەکەت، تایبەتمەندی و مێژووەکەی باس بکە…';

  @override
  String get editAgencyProfileTagsLabel => 'تاگەکان (بە کۆما جیاکراوەتەوە)';

  @override
  String get editAgencyProfileTagsHint =>
      'بۆ نموونە: مۆڵەتدراو لەلایەن حکومەتەوە، پسپۆڕی خێزانی';

  @override
  String get editAgencyProfileTagsBadgeHint =>
      'تاگەکان وەک باج لەسەر پڕۆفایلی ئاژانسەکەت دەردەکەون.';

  @override
  String get addEditOfferEditTitle => 'دەستکاریکردنی پاکێج';

  @override
  String get addEditOfferNewTitle => 'پاکێجی نوێ';

  @override
  String get addEditOfferSave => 'پاشەکەوتکردن';

  @override
  String get addEditOfferAddCoverImage => 'زیادکردنی وێنەی بەرگ';

  @override
  String get addEditOfferChangeImage => 'گۆڕینی وێنە';

  @override
  String get addEditOfferPackageDetails => 'وردەکارییەکانی پاکێج';

  @override
  String get addEditOfferTitleField => 'ناونیشان *';

  @override
  String get addEditOfferTitleHint => 'نموونە: مەککە و مەدینەی تایبەت';

  @override
  String get addEditOfferCitiesRoute => 'شارەکان / ڕێگا';

  @override
  String get addEditOfferCitiesRouteHint => 'نموونە: مەککە · مەدینە';

  @override
  String get addEditOfferBadgeOptional => 'نیشانە (ئارەزوومەندانە)';

  @override
  String get addEditOfferBadgeHint => 'نموونە: زۆرترین فرۆش، ڕەمەزان';

  @override
  String get addEditOfferTransportStay => 'گواستنەوە و مانەوە';

  @override
  String get addEditOfferTransport => 'گواستنەوە';

  @override
  String get addEditOfferByAir => 'بە فڕۆکە';

  @override
  String get addEditOfferByCoach => 'بە پاس';

  @override
  String get addEditOfferDays => 'ڕۆژەکان';

  @override
  String get addEditOfferStars => 'ئەستێرەکان';

  @override
  String get addEditOfferMeals => 'خواردنەکان';

  @override
  String get addEditOfferHotel => 'هۆتێل';

  @override
  String get addEditOfferHotelName => 'ناوی هۆتێل';

  @override
  String get addEditOfferHotelNameHint => 'نموونە: کۆنراد مەککە سویتس';

  @override
  String get addEditOfferDistanceToHaram => 'دووری لە حەرەم';

  @override
  String get addEditOfferDistanceHint => 'نموونە: 200م';

  @override
  String get addEditOfferRoomType => 'جۆری ژوور';

  @override
  String get addEditOfferRoomTypeHint => 'نموونە: دیلوکس توین';

  @override
  String get addEditOfferCarrierCoach => 'کۆمپانیای گواستنەوە / پاس';

  @override
  String get addEditOfferCarrierHint => 'نموونە: سعودیە، فلای ناس';

  @override
  String get addEditOfferPricing => 'نرخنان';

  @override
  String get addEditOfferPriceUsd => 'نرخ (دۆلار) *';

  @override
  String get addEditOfferOriginalPrice => 'نرخی ڕەسەن';

  @override
  String get addEditOfferOriginalPriceHint => '0 (ئارەزوومەندانە)';

  @override
  String get addEditOfferItinerary => 'بەرنامەی گەشت';

  @override
  String get addEditOfferItineraryHelper =>
      'وردەکاری ڕۆژانەی گەشتەکە زیاد بکە.';

  @override
  String get addEditOfferAddItineraryDay => 'زیادکردنی ڕۆژی گەشت';

  @override
  String get addEditOfferDayOneHint => 'ڕۆژی 1';

  @override
  String get addEditOfferDayTitleHint => 'ناونیشانی ڕۆژ…';

  @override
  String get addEditOfferDaySummaryHint =>
      'باسی ئەوە بکە کە لەم ڕۆژەدا ڕوودەدات…';

  @override
  String addEditOfferDayN(int n) {
    return 'ڕۆژی $n';
  }

  @override
  String get addEditOfferWhatsIncluded => 'ئەوەی لەخۆدەگرێت';

  @override
  String get addEditOfferWhatsIncludedHelper =>
      'هەموو ئەوەی پاکێجەکە لەخۆیدەگرێت بنووسە.';

  @override
  String get addEditOfferIncludeItemHint =>
      'نموونە: فڕۆکەی هاتوچۆ، پرۆسەی ڤیزا…';

  @override
  String get addEditOfferAddIncludedItem => 'زیادکردنی بڕگەی لەخۆگیراو';

  @override
  String get addEditOfferFillTitlePrice =>
      'تکایە ناونیشان و نرخێکی دروست بنووسە.';

  @override
  String get addEditOfferUpdated => 'پاکێج نوێکرایەوە!';

  @override
  String get addEditOfferPublished => 'پاکێج بڵاوکرایەوە!';

  @override
  String get authSignInTitle => 'بەخێربێیتەوە';

  @override
  String get authSignUpTitle => 'دروستکردنی هەژمار';

  @override
  String get authSubtitle =>
      'بچۆ ژوورەوە بۆ تۆمارکردنی گەشت و بەڕێوەبردنی گەشتەکانت.';

  @override
  String get authFullName => 'ناوی تەواو';

  @override
  String get authFullNameHint => 'ناوت';

  @override
  String get authPhone => 'ژمارەی تەلەفۆن';

  @override
  String get authSignUpBtn => 'دروستکردنی هەژمار';

  @override
  String get authNoAccount => 'تازەیت لێرە؟';

  @override
  String get authHaveAccount => 'پێشتر هەژمارت هەیە؟';

  @override
  String get authErrFillAll => 'تکایە هەموو خانەکان پڕ بکەرەوە.';

  @override
  String get authConfirmEmailSent =>
      'هەژمارەکە دروستکرا — ئیمەیلەکەت بپشکنە بۆ پشتڕاستکردنەوە، پاشان بچۆ ژوورەوە.';

  @override
  String get authWelcomeSnack => 'بەخێربێیت!';

  @override
  String get profileSignIn => 'چوونەژوورەوە / دروستکردنی هەژمار';

  @override
  String get profileSignInBannerSubtitle =>
      'گەشت حجز بکە، دڵخوازەکان هەڵبگرە، و گەشتەکانت بەدواداچوون بکە.';

  @override
  String get profileSignOut => 'چوونەدەرەوە';

  @override
  String get profileSignedOut => 'چوویتە دەرەوە.';

  @override
  String get profileGuestBadge => 'میوان';

  @override
  String get profileStatAlerts => 'ئاگادارییەکان';

  @override
  String get bookingPayMethod => 'شێوازی پارەدان';

  @override
  String get payCash => 'نەقد';

  @override
  String get payCard => 'کارت';

  @override
  String get payFib => 'FIB';

  @override
  String get bookingFailed =>
      'نەتوانرا گەشتەکە تۆمار بکرێت. دووبارە هەوڵ بدەرەوە.';

  @override
  String get bookingsCancelFailed =>
      'نەتوانرا ئەم گەشتە هەڵبوەشێنرێتەوە — تکایە پەیوەندی بە ئاژانسەکە بکە.';

  @override
  String get loadErrorTitle => 'نەتوانرا داتاکان بار بکرێن';

  @override
  String get loadErrorBody =>
      'پەیوەندی ئینتەرنێتەکەت بپشکنە و دووبارە هەوڵ بدەرەوە.';

  @override
  String get retry => 'دووبارە هەوڵ بدەرەوە';

  @override
  String get agencyRegisterTitle => 'تۆمارکردنی ئاژانس';

  @override
  String get agencyRegisterSubtitle =>
      'هەژمارێک دروست بکە بۆ بڵاوکردنەوەی پاکێجەکانی عومرەت.';

  @override
  String get agencyRegisterBtn => 'تۆمارکردنی ئاژانس';

  @override
  String get agencyRegisterPrompt => 'ئاژانسی نوێیت؟';

  @override
  String get agencyCompanyName => 'ناوی ئاژانس';

  @override
  String get agencyCompanyNameHint => 'وەک: گەشتیاری نوور';

  @override
  String get agencyCompanyLocation => 'شار / شوێن';

  @override
  String get agencyCompanyLocationHint => 'وەک: هەولێر';

  @override
  String get agencyNotAgencyAccount => 'ئەم هەژمارە هەژماری ئاژانس نییە.';

  @override
  String get addEditOfferSaveFailed =>
      'نەتوانرا پاکێجەکە پاشەکەوت بکرێت. پەیوەندییەکەت بپشکنە و دووبارە هەوڵ بدەرەوە.';
}
