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
  String get agencyLoginDemoEmail => 'ئیمەیل: admin@alsafwah.com';

  @override
  String get agencyLoginDemoPassword => 'وشەی نهێنی: pass123';

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
}
