// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kurdish (`ku`).
class AppLocalizationsKu extends AppLocalizations {
  AppLocalizationsKu([String locale = 'ku']) : super(locale);

  @override
  String get appTitle => 'تەواف';

  @override
  String get navHome => 'ماڵەوە';

  @override
  String get navAgencies => 'کۆمپانیاکان';

  @override
  String get navOffers => 'گەشتەکان';

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
  String get profileAgencyDivider => 'کۆمپانیا';

  @override
  String profileAgencyDashboardWithName(String name) {
    return 'داشبۆردی کۆمپانیا · $name';
  }

  @override
  String get profileAgencyPortal => 'دەروازەی کۆمپانیا و بەڕێوەبەر';

  @override
  String get profileAdminDashboard => 'داشبۆردی بەڕێوەبەر';

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
      'کلیک لەسەر دڵی هەر گەشتێک بکە بۆ هەڵگرتنی.';

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
  String get offerDetailReturnFlightsEconomy =>
      'فڕینی چوون و هاتنەوە، پۆلی گشتی';

  @override
  String get offerDetailLuxuryCoach => 'پاسی لوکسی سارد کەرەوەدار';

  @override
  String offerDetailCarrierTransfersIncluded(String carrier) {
    return '$carrier · هەموو گواستنەوە زەمینییەکان لەخۆدەگرێت';
  }

  @override
  String get offerDetailItinerary => 'بەرنامەی گەشت';

  @override
  String get offerDetailWhatsIncluded => 'ئەوەی لەخۆدەگرێت';

  @override
  String get offerDetailPackagePerPerson => 'گەشت (بۆ هەر کەسێک)';

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
  String get offersTitle => 'گەشتەکان';

  @override
  String offersPackagesMatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count گەشت گونجاون',
      one: '$count گەشت گونجاوە',
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
  String get filterSheetAgencyRating => 'هەڵسەنگاندنی کۆمپانیا';

  @override
  String filterSheetShowPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'پیشاندانی $count گەشت',
      one: 'پیشاندانی $count گەشت',
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
  String get homeSponsored => 'ڕیکلام';

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
  String get homeSearchPlaceholder => 'گەڕان بۆ گەشتەکانی عومرە…';

  @override
  String get homeTopAgencies => 'باشترین کۆمپانیاکان';

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
  String get homeCuratedPackages => 'گەشتە هەڵبژێردراوەکان';

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
  String get searchHint => 'گەڕان بۆ گەشت، کۆمپانیا، شار…';

  @override
  String get searchPopularSearches => 'گەڕانە باوەکان';

  @override
  String get searchSuggestionPremiumPackages => 'گەشتی تایبەت';

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
  String get companiesTitle => 'کۆمپانیاکان';

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
      other: '$count گەشت',
      one: '$count گەشت',
    );
    return '$_temp0';
  }

  @override
  String get companiesFromPrefix => 'لە ';

  @override
  String get companyDetailAbout => 'دەربارە';

  @override
  String companyDetailPackagesHeader(int count) {
    return 'گەشتەکان ($count)';
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
  String get companyDetailPackagesLabel => 'گەشتەکان';

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
  String get bookingsStatusCompleted => 'تەواوبووە';

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
  String get bookingsRateThisTrip => 'ئەم گەشتە هەڵسەنگێنە';

  @override
  String get reviewDialogTitle => 'گەشتەکەت چۆن بوو؟';

  @override
  String get reviewCommentHint =>
      'چەند وشەیەک دەربارەی ئەزموونەکەت بنووسە (ئارەزوومەندانە)';

  @override
  String get reviewSubmit => 'ناردنی هەڵسەنگاندن';

  @override
  String get reviewSubmitted => 'سوپاس بۆ هەڵسەنگاندنەکەت!';

  @override
  String get reviewFailed => 'هەڵسەنگاندنەکەت نەنێردرا. دووبارە هەوڵ بدەرەوە.';

  @override
  String get actionFailedGeneric =>
      'هەڵەیەک ڕوویدا. تکایە دووبارە هەوڵ بدەرەوە.';

  @override
  String get agencyBookingsTitle => 'داواکاری گەشتەکان';

  @override
  String get agencyBookingsRequests => 'داواکارییەکان';

  @override
  String get agencyBookingsEmptyTitle => 'هێشتا هیچ داواکاری گەشتێک نییە';

  @override
  String get agencyBookingsEmptyBody => 'داواکاری حاجییەکان لێرە دەردەکەون.';

  @override
  String get agencyBookingsCompleted => 'تەواوبووە';

  @override
  String get agencyBookingsConfirm => 'پشتڕاستکردنەوە';

  @override
  String get agencyBookingsDecline => 'ڕەتکردنەوە';

  @override
  String get agencyBookingsMarkCompleted => 'وەک تەواوبوو دابنێ';

  @override
  String get agencyBookingsConfirmedSnack => 'گەشتەکە پشتڕاستکرایەوە.';

  @override
  String get agencyBookingsDeclinedSnack => 'گەشتەکە ڕەتکرایەوە.';

  @override
  String get agencyBookingsCompletedSnack => 'وەک تەواوبوو دانرا.';

  @override
  String get adminCommissionsTitle => 'کۆمیسیۆنەکان';

  @override
  String get adminCommissionsEmptyTitle => 'هێشتا هیچ کۆمیسیۆنێک نییە';

  @override
  String get adminCommissionsEmptyBody =>
      'ئەمانە بەخۆکار دەکرێنەوە کاتێک گەشتێک پشتڕاست دەکرێتەوە.';

  @override
  String get adminCommissionsOwedLabel => 'کۆی قەرز';

  @override
  String get adminCommissionsOwed => 'قەرزە';

  @override
  String get adminCommissionsCollected => 'کۆکراوەتەوە';

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
      'کۆمپانیای متمانەپێکراو و گەشتی هەڵبژێردراو بۆ گەشتەکەت بدۆزەرەوە.';

  @override
  String get notifPromoTitle => 'پێشنیارە وەرزییەکان بەردەستن';

  @override
  String get notifPromoBody =>
      'ئەم مانگە تا 20% لە گەشتە هەڵبژێردراوەکان پاشەکەوت بکە.';

  @override
  String get notifTripReminderTitle => 'گەشتی داهاتوو';

  @override
  String notifTripReminderBody(String title) {
    return 'گەشتەکەت \"$title\" نزیک بووەتەوە. بەڵگەنامەکانت بپشکنە.';
  }

  @override
  String get notifBookingRequestedTitle => 'داواکاری گەشت نێردرا';

  @override
  String notifBookingRequestedBody(String title) {
    return 'داواکاریت بۆ \"$title\" بۆ کۆمپانیاکە نێردرا. کاتێک وەڵامیان دایەوە ئاگادارت دەکەینەوە.';
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
  String get paymentSaveFailed =>
      'کارتەکە پاشەکەوت نەکرا. دووبارە هەوڵ بدەرەوە.';

  @override
  String get paymentSignInTitle => 'بچۆ ژوورەوە بۆ زیادکردنی شێوازی پارەدان';

  @override
  String get paymentSignInBody =>
      'کارتە پاشەکەوتکراوەکانت لەگەڵ هەژمارەکەت لەسەر هەموو ئامێرێک دەبن.';

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
  String get helpFaq1Q => 'چۆن گەشتی عومرە تۆمار بکەم؟';

  @override
  String get helpFaq1A =>
      'هەر پێشنیارێک بکەرەوە، دەست بنێ بە \"ئەم گەشتە تۆمار بکە\"، ژمارەی گەشتیاران هەڵبژێرە و پشتڕاستی بکەرەوە. گەشتەکەت لە گەشتەکانم دەردەکەوێت لەگەڵ ژمارەی سەلماندن.';

  @override
  String get helpFaq2Q => 'دەتوانم گەشتێک هەڵبوەشێنمەوە؟';

  @override
  String get helpFaq2A =>
      'بەڵێ — هەڵوەشاندنەوە بێبەرامبەرە تا 30 ڕۆژ پێش گەشت. گەشتەکانم بکەرەوە و دەست بنێ بە \"هەڵوەشاندنەوەی گەشت\".';

  @override
  String get helpFaq3Q => 'کۆمپانیاکان پشتڕاستکراون؟';

  @override
  String get helpFaq3A =>
      'هەموو کۆمپانیایەکی تۆمارکراو مۆڵەتی حکومی هەیە و لەلایەن تیمەکەمانەوە پشتڕاستکراوەتەوە پێش بڵاوکردنەوەی گەشتەکانیان.';

  @override
  String get helpFaq4Q => 'گەشتەکە چی لەخۆدەگرێت؟';

  @override
  String get helpFaq4A =>
      'هەر پێشنیارێک ئەوانە دەنووسێت کە لەخۆی دەگرێت — ڤیزا، گواستنەوە، هوتێل، خواردن و زیارەتی بە ڕێنمایی. سەیری بەشی \"چی لەخۆدەگرێت\" بکە.';

  @override
  String get helpFaq5Q => 'کۆمپانیاکان چۆن بەشداری پلاتفۆرمەکە دەکەن؟';

  @override
  String get helpFaq5A =>
      'کۆمپانیاکان لە ڕێگەی پۆرتاڵی کۆمپانیاوە لە تابی پڕۆفایل خۆیان تۆمار دەکەن. دوای پشتڕاستکردنەوە دەتوانن گەشت بڵاو بکەنەوە و بەڕێوەیان ببەن.';

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
  String get helpMessageFailed =>
      'نامەکەت نەنێردرا. ئینتەرنێتەکەت بپشکنە و دووبارە هەوڵ بدەرەوە.';

  @override
  String get agencyLoginTitle => 'پۆرتاڵی کۆمپانیا';

  @override
  String get agencyLoginSubtitle =>
      'بچۆ ژوورەوە بۆ بەڕێوەبردنی گەشتەکانت و پڕۆفایلت.';

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
      '(admin@noorharamain.com هتد بەکاربهێنە بۆ کۆمپانیاکانی تر)';

  @override
  String get adminTitle => 'داشبۆردی بەڕێوەبەر';

  @override
  String get adminPendingAgencies => 'کۆمپانیا چاوەڕوانەکان';

  @override
  String get adminNoPending => 'هیچ کۆمپانیایەک چاوەڕوانی پەسەندکردن نییە.';

  @override
  String get adminApprove => 'پەسەندکردن';

  @override
  String get adminApproved =>
      'کۆمپانیاکە پەسەند کرا و ئێستا بۆ هەمووان دەرکەوتووە!';

  @override
  String get adminActionFailed =>
      'کردارەکە سەرنەکەوت — دڵنیابە کە patches_admin.sql جێبەجێ کراوە.';

  @override
  String get adminHomeAds => 'ڕیکلامەکانی پەڕەی سەرەکی';

  @override
  String get adminNoAds =>
      'هێشتا هیچ ڕیکلامێک نییە. یەکێک زیاد بکە بۆ سەرەوەی پەڕەی سەرەکی.';

  @override
  String get adminAddAd => 'زیادکردنی ڕیکلام';

  @override
  String get adminAdTitle => 'ناونیشانی ڕیکلام';

  @override
  String get adminAdTitleHint => 'نموونە: گەشتی ڕەمەزان — گەشتیاری نوور';

  @override
  String get adminLinkPackage => 'بەستنەوە بە گەشتێک (ئارەزوومەندانە)';

  @override
  String get adminNoLink => 'بێ بەستنەوە';

  @override
  String get adminAdImage => 'وێنەی ڕیکلام';

  @override
  String get adminPickImage => 'دەست بنێ بۆ هەڵبژاردنی وێنە';

  @override
  String get adminAdCreated => 'ڕیکلامەکە لە پەڕەی سەرەکی بڵاوکرایەوە!';

  @override
  String get adminFeaturedOffers => 'گەشتە تایبەتەکانی پەڕەی سەرەکی';

  @override
  String get adminFeaturedHint =>
      'گەشتە ئەستێرەدارەکان یەکەمجار لە پەڕەی سەرەکی دەردەکەون.';

  @override
  String get adminNoOffers => 'هێشتا هیچ گەشتێک بڵاو نەکراوەتەوە.';

  @override
  String get adminStatPending => 'چاوەڕوان';

  @override
  String get adminStatOwed => 'قەرز';

  @override
  String get adminStatCollected => 'کۆکراوە';

  @override
  String get adminSupportInbox => 'نامەکانی پشتگیری';

  @override
  String get adminSupportEmpty => 'هێشتا هیچ نامەیەک نییە.';

  @override
  String get adminSupportAnonymous => 'میوان';

  @override
  String agencyDashboardYourPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'گەشتەکانت ($count)',
      one: 'گەشتەکانت (1)',
      zero: 'هیچ گەشتێک نییە',
    );
    return '$_temp0';
  }

  @override
  String get agencyDashboardAddPackage => 'زیادکردنی گەشت';

  @override
  String get agencyDashboardVerificationPending => 'پشتڕاستکردنەوە چاوەڕوانە';

  @override
  String get agencyDashboardVerificationPendingBody =>
      'هەژمارەکەت لەژێر پێداچوونەوەدایە. کاتێک پشتڕاست کرایەوە دەتوانیت گەشت بڵاو بکەیتەوە و پڕۆفایلت دەستکاری بکەیت.';

  @override
  String get agencyDashboardEditProfile => 'دەستکاریکردنی پڕۆفایل';

  @override
  String get agencyDashboardVerifiedAgency => 'کۆمپانیای پشتڕاستکراو';

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
  String get agencyDashboardDeletePackageTitle => 'گەشتەکە بسڕدرێتەوە؟';

  @override
  String agencyDashboardDeletePackageBody(String title) {
    return 'ئەمە بە یەکجاری \"$title\" دەسڕێتەوە.';
  }

  @override
  String get agencyDashboardCancel => 'هەڵوەشاندنەوە';

  @override
  String get agencyDashboardDelete => 'سڕینەوە';

  @override
  String get agencyDashboardNoPackagesYet => 'هێشتا هیچ گەشتێک نییە';

  @override
  String get agencyDashboardNoPackagesHint =>
      'لەسەر \"زیادکردنی گەشت\" دابگرە بۆ بڵاوکردنەوەی یەکەم پێشکەشکردنی عومرەت.';

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
  String get editAgencyProfileAboutLabel => 'دەربارەی کۆمپانیاکەت';

  @override
  String get editAgencyProfileAboutHint =>
      'کۆمپانیاکەت، تایبەتمەندی و مێژووەکەی باس بکە…';

  @override
  String get editAgencyProfileTagsLabel => 'تاگەکان (بە کۆما جیاکراوەتەوە)';

  @override
  String get editAgencyProfileTagsHint =>
      'بۆ نموونە: مۆڵەتدراو لەلایەن حکومەتەوە، پسپۆڕی خێزانی';

  @override
  String get editAgencyProfileTagsBadgeHint =>
      'تاگەکان وەک باج لەسەر پڕۆفایلی کۆمپانیاکەت دەردەکەون.';

  @override
  String get editAgencyProfileBannerLabel => 'وێنەی پاشبنەما';

  @override
  String get addEditOfferEditTitle => 'دەستکاریکردنی گەشت';

  @override
  String get addEditOfferNewTitle => 'گەشتی نوێ';

  @override
  String get addEditOfferSave => 'پاشەکەوتکردن';

  @override
  String get addEditOfferAddCoverImage => 'زیادکردنی وێنەی بەرگ';

  @override
  String get addEditOfferChangeImage => 'گۆڕینی وێنە';

  @override
  String get addEditOfferPackageDetails => 'وردەکارییەکانی گەشت';

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
  String get mealsBreakfast => 'تەنها نانی بەیانی';

  @override
  String get mealsHalfBoard => 'نیوە خۆراک';

  @override
  String get mealsFullBoard => 'خۆراکی تەواو';

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
      'هەموو ئەوەی گەشتەکە لەخۆیدەگرێت بنووسە.';

  @override
  String get addEditOfferIncludeItemHint =>
      'نموونە: فڕۆکەی هاتوچۆ، پرۆسەی ڤیزا…';

  @override
  String get addEditOfferAddIncludedItem => 'زیادکردنی بڕگەی لەخۆگیراو';

  @override
  String get addEditOfferFillTitlePrice =>
      'تکایە ناونیشان و نرخێکی دروست بنووسە.';

  @override
  String get addEditOfferUpdated => 'گەشت نوێکرایەوە!';

  @override
  String get addEditOfferPublished => 'گەشت بڵاوکرایەوە!';

  @override
  String get addEditOfferSavedImageFailed =>
      'گەشتەکە پاشەکەوتکرا، بەڵام وێنەی بەرگ نەتوانرا باربکرێت. پەیوەندییەکەت بپشکنە و لە دەستکاریکردنەوە دووبارە هەوڵ بدەرەوە.';

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
  String get profileSignOutConfirmTitle => 'دەرچیت؟';

  @override
  String get profileSignOutConfirmBody =>
      'دەتوانیت هەر کاتێک بە ئیمەیڵ و وشەی نهێنیت دووبارە بچیتەوە ژوورەوە.';

  @override
  String get profileSectionAccount => 'هەژمار';

  @override
  String get profileSectionPreferences => 'هەڵبژاردنەکان';

  @override
  String get profileSectionSupport => 'پشتگیری';

  @override
  String get profileGuestBadge => 'مێوان';

  @override
  String get profileStatAlerts => 'ئاگاداریەکان';

  @override
  String get profileAccountDetails => 'وردەکاری هەژمار';

  @override
  String get accountPhoneHint => '+964 750 000 0000';

  @override
  String get accountSaveChanges => 'پاشەکەوتکردنی گۆڕانکارییەکان';

  @override
  String get accountUpdated => 'پرۆفایلەکە نوێکرایەوە.';

  @override
  String get accountChangePassword => 'گۆڕینی وشەی نهێنی';

  @override
  String get accountNewPassword => 'وشەی نهێنی نوێ';

  @override
  String get accountNewPasswordHint => 'لانیکەم ٦ پیت';

  @override
  String get accountPasswordUpdated => 'وشەی نهێنی نوێکرایەوە.';

  @override
  String get accountPasswordTooShort => 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت.';

  @override
  String get accountDangerZone => 'ناوچەی مەترسی';

  @override
  String get accountDeleteAccount => 'سڕینەوەی هەژمار';

  @override
  String get accountDeleteHint => 'هەژمار و زانیارییەکانت بە یەکجاری لادەبات.';

  @override
  String get accountDeleteTitle => 'هەژمارەکە بسڕدرێتەوە؟';

  @override
  String get accountDeleteBody =>
      'ئەمە هەژمارەکەت و حجزەکانت و زانیاریە پاشەکەوتکراوەکانت بە یەکجاری دەسڕێتەوە. ناتوانرێت بگەڕێنرێتەوە.';

  @override
  String get accountDeleteConfirm => 'بەڵێ، هەژمارەکەم بسڕەوە';

  @override
  String get accountDeleted => 'هەژمارەکەت سڕایەوە.';

  @override
  String get accountDeleteFailed =>
      'نەتوانرا هەژمارەکە بسڕدرێتەوە. دووبارە هەوڵ بدەرەوە.';

  @override
  String get profileAbout => 'دەربارە';

  @override
  String aboutVersion(String version) {
    return 'وەشانی $version';
  }

  @override
  String get aboutPrivacyPolicy => 'سیاسەتی تایبەتمەندی';

  @override
  String get aboutTermsOfUse => 'مەرجەکانی بەکارهێنان';

  @override
  String get legalPrivacyBody =>
      'ئەپی عومرە ڕێز لە تایبەتمەندییەکەت دەگرێت. تەنها ئەو زانیاریانە کۆدەکەینەوە کە بۆ کارکردنی خزمەتگوزارییەکە پێویستن: ناوت، زانیاری پەیوەندی و داواکارییەکانی حجز. ئەم زانیاریانە تەنها لەگەڵ ئەو کۆمپانیایە هاوبەش دەکرێن کە تۆ هەڵیدەبژێریت، و هەرگیز بە لایەنی سێیەم نافرۆشرێن.\n\nزانیارییەکانت بە پارێزراوی هەڵدەگیرێن. دەتوانیت هەر کاتێک لە وردەکاری هەژمارەوە هەژمارەکەت بسڕیتەوە، ئەمەش پرۆفایل و زانیارییە کەسییەکانت بە یەکجاری لە سیستەمەکانمان لادەبات.';

  @override
  String get legalTermsBody =>
      'ئەپی عومرە بازاڕێکە کە گەشتیاران بە کۆمپانیا گەشتییە مۆڵەتدارەکانەوە دەبەستێتەوە. حجزەکان لە ڕێگەی ئەپەکەوە داواکارین: کۆمپانیاکە پشتڕاستیان دەکاتەوە یان ڕەتیان دەکاتەوە، و پارەدان ڕاستەوخۆ لای کۆمپانیاکە دەبێت. وردەکاری گەشت و نرخ و بەردەستبوون لەلایەن کۆمپانیاکانەوە دابین دەکرێن و لەوانەیە بگۆڕێن.\n\nبە بەکارهێنانی ئەپەکە ڕازی دەبیت بە پێدانی زانیاری دروست و بەکارهێنانی خزمەتگوزارییەکە تەنها بۆ مەبەستی کەسی و یاسایی. ئەپەکە کۆمپانیای گەشت نییە و لایەنێک نییە لە گرێبەستی نێوان تۆ و کۆمپانیاکە.';

  @override
  String get bookingPayMethod => 'شێوازی پارەدان';

  @override
  String get payCash => 'نەقد';

  @override
  String get payCard => 'کارت';

  @override
  String get payFib => 'FIB';

  @override
  String get preferredPaymentTitle => 'شێوازی پارەدان';

  @override
  String get preferredPaymentBody =>
      'ئەو شێوازە هەڵبژێرە کە پێت باشترە پێی پارە بدەیت. پارەدان هەمیشە لای کۆمپانیاکە بەشێوەی ڕووبەڕوو دەبێت — هیچ شتێک لەناو ئەپەکەدا کەم ناکرێتەوە.';

  @override
  String get preferredPaymentSaved => 'پەسەندکراوەکە پاشەکەوت کرا.';

  @override
  String get bookingFailed =>
      'نەتوانرا گەشتەکە تۆمار بکرێت. دووبارە هەوڵ بدەرەوە.';

  @override
  String get bookingsCancelFailed =>
      'نەتوانرا ئەم گەشتە هەڵبوەشێنرێتەوە — تکایە پەیوەندی بە کۆمپانیاکە بکە.';

  @override
  String get loadErrorTitle => 'نەتوانرا داتاکان بار بکرێن';

  @override
  String get loadErrorBody =>
      'پەیوەندی ئینتەرنێتەکەت بپشکنە و دووبارە هەوڵ بدەرەوە.';

  @override
  String get retry => 'دووبارە هەوڵ بدەرەوە';

  @override
  String get agencyRegisterTitle => 'تۆمارکردنی کۆمپانیا';

  @override
  String get agencyRegisterSubtitle =>
      'هەژمارێک دروست بکە بۆ بڵاوکردنەوەی گەشتەکانی عومرەت.';

  @override
  String get agencyRegisterBtn => 'تۆمارکردنی کۆمپانیا';

  @override
  String get agencyRegisterPrompt => 'کۆمپانیای نوێیت؟';

  @override
  String get agencyCompanyName => 'ناوی کۆمپانیا';

  @override
  String get agencyCompanyNameHint => 'وەک: گەشتیاری نوور';

  @override
  String get agencyCompanyLocation => 'شار / شوێن';

  @override
  String get agencyCompanyLocationHint => 'وەک: هەولێر';

  @override
  String get agencyCompanyAbout => 'دەربارەی کۆمپانیاکەت';

  @override
  String get agencyCompanyAboutHint =>
      'وەسفێکی کورت کە بۆ گەشتیاران دەردەکەوێت';

  @override
  String get agencyCompanySince => 'ساڵی دامەزراندن';

  @override
  String get agencyCompanySinceHint => 'وەک: 2015';

  @override
  String get agencyCompanyLogo => 'لۆگۆی کۆمپانیا';

  @override
  String get agencyLogoAdd => 'زیادکردنی لۆگۆ';

  @override
  String get agencyLogoChange => 'گۆڕینی لۆگۆ';

  @override
  String get agencyLogoOptional =>
      'ئارەزوومەندانەیە — لە پەڕەی کۆمپانیاکان دەردەکەوێت';

  @override
  String get agencyBannerAdd => 'زیادکردنی وێنەی بەرگ';

  @override
  String get agencyBannerChange => 'گۆڕینی وێنەی بەرگ';

  @override
  String get agencyNotAgencyAccount => 'ئەم هەژمارە هەژماری کۆمپانیا نییە.';

  @override
  String get addEditOfferSaveFailed =>
      'نەتوانرا گەشتەکە پاشەکەوت بکرێت. پەیوەندییەکەت بپشکنە و دووبارە هەوڵ بدەرەوە.';

  @override
  String offerFallbackDayLabel(int n) {
    return 'ڕۆژی $n';
  }

  @override
  String offerFallbackDayRangeLabel(int a, int b) {
    return 'ڕۆژی $a–$b';
  }

  @override
  String get offerFallbackFinalDaysLabel => 'ڕۆژە کۆتاییەکان';

  @override
  String get offerFallbackDay1Title => 'گەیشتن و گواستنەوە';

  @override
  String get offerFallbackDay1Summary =>
      'گەیشتن بۆ جیدە، بەرێوەبەرەکەت لەوێ چاوەڕوانت دەبێت، و دەگوازرێیتەوە بۆ هۆتێلەکەت لەتەنیشت حەرەم.';

  @override
  String get offerFallbackDay2Title => 'ئەنجامدانی عومرە';

  @override
  String get offerFallbackDay2Summary =>
      'عومرەیەکی ڕابەرایەتیکراو — تەواف، سەعی و تەحەلول لەگەڵ مامۆستای گرووپەکەت.';

  @override
  String get offerFallbackMakkahTitle => 'عیبادەت لە مەککە';

  @override
  String get offerFallbackMakkahSummary =>
      'نوێژ لە مزگەوتی حەرام لەگەڵ زیارەتی ئارەزوومەندانە بۆ مینا، عەرەفات و شوێنە مێژووییەکان.';

  @override
  String get offerFallbackMadinahTravelTitle => 'گەشتن بۆ مەدینە';

  @override
  String get offerFallbackMadinahTravelSummary =>
      'گواستنەوەی خێرا بۆ مەدینە و هەنگاوەکانی چوونەژوورەوەی هۆتێل لەتەنیشت مزگەوتی پێغەمبەر (ﷺ).';

  @override
  String get offerFallbackMadinahReturnTitle => 'مەدینە و گەڕانەوە';

  @override
  String get offerFallbackMadinahReturnSummary =>
      'عیبادەت لە مزگەوتی نەبەوی، گەشتی زیارەتی، پاشان گواستنەوە بۆ گەڕانەوەی ماڵەوە.';

  @override
  String get offerFallbackWorshipReturnTitle => 'عیبادەت و گەڕانەوە';

  @override
  String get offerFallbackWorshipReturnSummary =>
      'دوایین نوێژەکان و تەوافی وەداع، پاشان گواستنەوە بۆ فڕۆکەخانە بۆ گەڕانەوە.';

  @override
  String get offerFallbackIncludeVisa => 'ڤیزای عومرە و پرۆسەکانی';

  @override
  String get offerFallbackIncludeFlights => 'فڕینی نێودەوڵەتی چوون و هاتنەوە';

  @override
  String get offerFallbackIncludeCoach => 'گواستنەوەی پاسی سارد کەرەوەدار';

  @override
  String offerFallbackIncludeHotel(int acc, String hotel) {
    return 'هۆتێلی $acc ئەستێرە — $hotel';
  }

  @override
  String offerFallbackIncludeMeals(String meals) {
    return 'خواردنی $meals ڕۆژانە';
  }

  @override
  String get offerFallbackIncludeZiyarah => 'گەشتی زیارەتی ڕابەرایەتیکراو';

  @override
  String get offerFallbackIncludeGuide => 'ڕابەرایەتی فرەزمان ٢٤/٧';

  @override
  String get profileAdminDashboardSub =>
      'بەڕێوەبردنی ئاژانسەکان و رێکلامەکان و کۆمیسیۆنەکان';

  @override
  String get profileAgencyDashboardSub => 'بەڕێوەبردنی پاکێجەکانت و حجزەکانت';

  @override
  String get profileAgencyPortalSub => 'چوونە ژوورەوە وەک ئاژانس یان ئەدمین';

  @override
  String get profileAgencyLogout => 'دەرچوون لە ئاژانس';

  @override
  String get profileAgencyLogoutTitle => 'دەرچوون لە ئاژانس؟';

  @override
  String get profileAgencyLogoutBody =>
      'دەردەچیت لە دەروازەی ئاژانسەکە. دەتوانیت هەرکاتێک دووبارە بچیتە ژوورەوە.';

  @override
  String get adminDecline => 'ڕەتکردنەوە';

  @override
  String get adminDeclineTitle => 'ڕەتکردنەوەی ئاژانس؟';

  @override
  String get adminDeclineBody =>
      'ئەم ئاژانسە پەسەند ناکرێت و پاکێجەکانی لە پلاتفۆرمەکە دەرناکەوێت.';

  @override
  String get adminDeclined => 'ئاژانسەکە ڕەتکرایەوە.';

  @override
  String get agencyLoginInfoNote =>
      'ئەو زانیاریانەی بەکاربێنە کە لەلایەن بەڕێوەبەری ئاژانسەکەت پێتدراون بۆ چوونە ژوورەوە.';

  @override
  String get editAgencyProfileLocationRequired => 'شوێن پێویستە.';

  @override
  String get editAgencyProfileYearInvalid =>
      'تکایە ساڵێکی دروست بنووسە (1900–ئێستا).';

  @override
  String get adminDeleteAdTitle => 'سڕینەوەی ئەم رێکلامە؟';

  @override
  String get adminDeleteAdBody =>
      'ئەم رێکلامە بەتەواوی لە پەڕەی سەرەکیەوە سڕێنەوە دەکرێت.';

  @override
  String get adminDeleteAdConfirm => 'سڕینەوە';

  @override
  String get forgotPasswordLink => 'وشەی نهێنیت لەبیرچووە؟';

  @override
  String get forgotPasswordTitle => 'ڕیسێتکردنی وشەی نهێنی';

  @override
  String get forgotPasswordSubtitle =>
      'ئیمەیلەکەت بنووسە و کۆدێکی پشتڕاستکردنەوە بۆت دەنێرین.';

  @override
  String get forgotPasswordStep2Subtitle =>
      'کۆدی 6 ژمارەیی کە بۆ ئیمەیلەکەت نێردراوە بنووسە و وشەیەکی نوێ هەڵبژێرە.';

  @override
  String get forgotPasswordCodeLabel => 'کۆدی پشتڕاستکردنەوە';

  @override
  String get forgotPasswordNewPass => 'وشەی نهێنیی نوێ';

  @override
  String get forgotPasswordConfirmPass => 'دڵنیاکردنەوەی وشەی نهێنی';

  @override
  String get forgotPasswordSendCode => 'ناردنی کۆدی پشتڕاستکردنەوە';

  @override
  String get forgotPasswordResetBtn => 'ڕیسێتکردنی وشەی نهێنی';

  @override
  String get forgotPasswordResend => 'کۆدەکەت وەرنەگرت؟ دووبارە بینێرە';

  @override
  String get forgotPasswordCodeSent =>
      'کۆدی پشتڕاستکردنەوە بۆ ئیمەیلەکەت نێردرا.';

  @override
  String get forgotPasswordSuccess =>
      'وشەی نهێنی بە سەرکەوتی ڕیسێتکرا! گەڕانەوە...';

  @override
  String get forgotPasswordErrEmail => 'تکایە ئیمەیلەکەت بنووسە.';

  @override
  String get forgotPasswordErrCode => 'تکایە کۆدی پشتڕاستکردنەوە بنووسە.';

  @override
  String get forgotPasswordErrShort => 'وشەی نهێنی دەبێت لانی کەم 6 پیت بێت.';

  @override
  String get forgotPasswordErrNoMatch => 'وشەی نهێنیەکان وەک نین.';

  @override
  String get authNext => 'دواتر';

  @override
  String get authEnterPassword => 'وشەی نهێنییەکەت بنووسە بۆ بەردەوامبوون';

  @override
  String get authErrInvalidEmail => 'تکایە ئیمەیلێکی دروست بنووسە.';

  @override
  String get authErrEmailEmpty => 'تکایە ئیمەیلەکەت بنووسە.';

  @override
  String get authErrEmailSpaces => 'ئیمەیل نابێت بۆشایی تێدا هەبێت.';

  @override
  String get authErrEmailNoAt => 'ئیمەیل دەبێت نیشانەی @ تێدابێت.';

  @override
  String get authErrEmailInvalidDomain =>
      'تکایە دۆمەینێکی دروست بنووسە (وەک: gmail.com).';

  @override
  String get authErrPhoneTooShort =>
      'ژمارەی مۆبایل کورتە. لانی کەم 7 ژمارە دەبێت.';

  @override
  String get authErrPhoneTooLong => 'ژمارەی مۆبایل درێژە. زۆرترین 15 ژمارە.';

  @override
  String get authErrPhoneInvalidChars => 'ژمارەی مۆبایل پیتی نادروستی تێدایە.';

  @override
  String get authErrPhoneInvalid => 'تکایە ژمارەیەکی دروست بنووسە.';

  @override
  String get authErrPasswordEmpty => 'تکایە وشەی نهێنییەکەت بنووسە.';

  @override
  String get authErrPasswordShort => 'وشەی نهێنی دەبێت لانی کەم 6 پیت بێت.';

  @override
  String get authErrPasswordNoLetter =>
      'وشەی نهێنی دەبێت لانی کەم یەک پیت تێدابێت.';

  @override
  String get authErrPasswordNoDigit =>
      'وشەی نهێنی دەبێت لانی کەم یەک ژمارە تێدابێت.';

  @override
  String get authErrNameEmpty => 'تکایە ناوی تەواوەکەت بنووسە.';

  @override
  String get authErrNameTooShort => 'ناو دەبێت لانی کەم 2 پیت بێت.';

  @override
  String get accountChangeEmail => 'گۆڕین';

  @override
  String get accountChangeEmailBody =>
      'ئیمەیلە نوێیەکەت بنووسە. بەستەری پشتڕاستکردنەوە دەنێردرێت بۆ پشتڕاستکردنەوەی گۆڕانکارییەکە.';

  @override
  String get accountUpdate => 'نوێکردنەوە';

  @override
  String get accountVerifyIdentity => 'ناسنامەکەت پشتڕاست بکەرەوە';

  @override
  String get accountVerifyIdentityBody =>
      'بۆ مەبەستی ئاسایشی، تکایە وشەی نهێنییە ئێستایەکەت بنووسە بۆ بەردەوامبوون.';

  @override
  String get accountVerify => 'پشتڕاستکردنەوە';

  @override
  String get accountWrongPassword => 'وشەی نهێنی هەڵەیە. دوبارە هەوڵ بدەرەوە.';

  @override
  String get accountEmailSameAsCurrent => 'ئەمە ئیمەیلە ئێستاکەتە.';

  @override
  String get accountEmailConfirmationTitle => 'پشتڕاستکردنەوە نێردرا';

  @override
  String get accountEmailConfirmationBody =>
      'بەستەری پشتڕاستکردنەوە بۆ ئیمەیلە نوێیەکەت نێردرا. سندوقی نامەکانت بپشکنە و کلیک لەسەر بەستەرەکە بکە بۆ تەواوکردنی گۆڕانکارییەکە.';
}
