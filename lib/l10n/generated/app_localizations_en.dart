// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Umrah';

  @override
  String get navHome => 'Home';

  @override
  String get navAgencies => 'Agencies';

  @override
  String get navOffers => 'Offers';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageKurdish => 'Kurdish';

  @override
  String get chooseLanguageTitle => 'Choose language';

  @override
  String get profileSavedTrips => 'Saved trips';

  @override
  String get profileMyBookings => 'My Bookings';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePaymentMethods => 'Payment methods';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profilePrivacySecurity => 'Privacy & security';

  @override
  String get profileHelpSupport => 'Help & support';

  @override
  String get profileAgencyDivider => 'Agency';

  @override
  String profileAgencyDashboardWithName(String name) {
    return 'Agency Dashboard · $name';
  }

  @override
  String get profileAgencyPortal => 'Agency Portal';

  @override
  String get comingSoonBody => 'This feature is coming soon.';

  @override
  String get profilePilgrim => 'Pilgrim';

  @override
  String get profileGoldMember => '★ Gold Member';

  @override
  String get profileStatTrips => 'Trips';

  @override
  String get profileStatSaved => 'Saved';

  @override
  String get profileStatReviews => 'Reviews';

  @override
  String get savedTripsTitle => 'Saved Trips';

  @override
  String get savedTripsEmptyTitle => 'No saved trips yet';

  @override
  String get savedTripsEmptyBody => 'Tap the heart on any offer to save it.';

  @override
  String get priceFromPrefix => 'from ';

  @override
  String get offerDetailOverview => 'Overview';

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
    return 'A $days-day $transport journey to $city, staying at the $acc-star $hotel, just $distance from the Haram. Includes $company\'s signature group guidance, daily worship support and full ziyarah.';
  }

  @override
  String offerDetailDaysCount(int days) {
    return '$days days';
  }

  @override
  String offerDetailNightsCount(int nights) {
    return '$nights nights';
  }

  @override
  String offerDetailStarCount(int acc) {
    return '$acc-Star';
  }

  @override
  String get offerDetailHotelLower => 'hotel';

  @override
  String get offerDetailPilgrimReviews => ' pilgrim reviews';

  @override
  String get offerDetailViewAgency => 'View agency →';

  @override
  String get offerDetailAccommodation => 'Accommodation';

  @override
  String offerDetailDistanceToHaram(String distance) {
    return '$distance to Haram';
  }

  @override
  String get offerDetailRoom => 'Room';

  @override
  String get offerDetailMeals => 'Meals';

  @override
  String get offerDetailTransportation => 'Transportation';

  @override
  String offerDetailCarrierTransfersIncluded(String carrier) {
    return '$carrier · All ground transfers included';
  }

  @override
  String get offerDetailItinerary => 'Itinerary';

  @override
  String get offerDetailWhatsIncluded => 'What\'s Included';

  @override
  String get offerDetailPackagePerPerson => 'Package (per person)';

  @override
  String get offerDetailVisaProcessing => 'Visa & processing';

  @override
  String get offerDetailIncluded => 'Included';

  @override
  String get offerDetailTaxesFees => 'Taxes & fees';

  @override
  String get offerDetailTotalFrom => 'Total from';

  @override
  String get offerDetailFromPerPerson => 'from / person';

  @override
  String get offerDetailBookThisTrip => 'Book this trip';

  @override
  String get offerDetailConfirmBooking => 'Confirm booking';

  @override
  String offerDetailBookingSummaryLine(int days, String transport, int acc) {
    return '$days days · $transport · $acc★';
  }

  @override
  String get offerDetailTravelers => 'Travelers';

  @override
  String offerDetailPricePerPerson(String price) {
    return '$price per person';
  }

  @override
  String get offerDetailTotal => 'Total';

  @override
  String get offerDetailBookingConfirmed => 'Booking confirmed!';

  @override
  String offerDetailConfirmAndPay(String total) {
    return 'Confirm & pay $total';
  }

  @override
  String get offerDetailFreeCancellation =>
      'Free cancellation up to 30 days before departure';

  @override
  String get offersTitle => 'Offers';

  @override
  String offersPackagesMatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packages match',
      one: '$count package matches',
    );
    return '$_temp0';
  }

  @override
  String get offersFilters => 'Filters';

  @override
  String get offersAll => 'All';

  @override
  String get offersByAir => 'By Air';

  @override
  String get offersByCoach => 'By Coach';

  @override
  String get offers5Star => '5 Star';

  @override
  String get offers4Star => '4 Star';

  @override
  String get offersSort => 'Sort';

  @override
  String get offersPopular => 'Popular';

  @override
  String get offersPriceLowToHigh => 'Price ↑';

  @override
  String get offersPriceHighToLow => 'Price ↓';

  @override
  String get offersNoMatches => 'No matches';

  @override
  String get offersTryWideningFilters => 'Try widening your filters.';

  @override
  String get offersResetFilters => 'Reset filters';

  @override
  String offersDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String offersStarCount(int count) {
    return '$count-Star';
  }

  @override
  String get offersFromPricePrefix => 'from';

  @override
  String get filterSheetTitle => 'Filters';

  @override
  String get filterSheetReset => 'Reset';

  @override
  String get filterSheetMaxPricePerPerson => 'Max price / person';

  @override
  String get filterSheetTransportation => 'Transportation';

  @override
  String get filterSheetAll => 'All';

  @override
  String get filterSheetByAir => 'By Air';

  @override
  String get filterSheetByCoach => 'By Coach';

  @override
  String get filterSheetAccommodation => 'Accommodation';

  @override
  String get filterSheetAny => 'Any';

  @override
  String get filterSheetTripDuration => 'Trip duration';

  @override
  String get filterSheetDuration7to9 => '7–9 days';

  @override
  String get filterSheetDuration10to14 => '10–14 days';

  @override
  String get filterSheetDuration15Plus => '15+ days';

  @override
  String get filterSheetAgencyRating => 'Agency rating';

  @override
  String filterSheetShowPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count packages',
      one: 'Show $count package',
    );
    return '$_temp0';
  }

  @override
  String get homeGreeting => 'السلام عليكم';

  @override
  String get homeWelcomePilgrim => 'Welcome, Pilgrim';

  @override
  String get homeFeatured => 'FEATURED';

  @override
  String homeDaysStarHotel(int days, int acc) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0 · $acc-Star Hotel';
  }

  @override
  String get homeSearchPlaceholder => 'Search Umrah packages…';

  @override
  String get homeTopAgencies => 'Top Agencies';

  @override
  String get homeViewAll => 'View all';

  @override
  String homeRatingOffersCount(double rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offers',
      one: '$count offer',
    );
    return '$rating · $_temp0';
  }

  @override
  String get homeCuratedPackages => 'Curated Packages';

  @override
  String homeDaysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0';
  }

  @override
  String get homeFromPrefix => 'from ';

  @override
  String get searchHint => 'Search packages, agencies, cities…';

  @override
  String get searchPopularSearches => 'Popular searches';

  @override
  String get searchSuggestionPremiumPackages => 'Premium packages';

  @override
  String get searchSuggestionByAir => 'By Air';

  @override
  String get searchSuggestionByCoach => 'By Coach';

  @override
  String get searchSuggestionRamadan => 'Ramadan';

  @override
  String get searchSuggestionFiveStar => '5-Star';

  @override
  String get searchSuggestionMadinah => 'Madinah';

  @override
  String get searchSuggestionFamily => 'Family';

  @override
  String searchNoResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchTryDifferentTerm => 'Try a different name, city, or hotel.';

  @override
  String get searchFromPrefix => 'from ';

  @override
  String get companiesTitle => 'Agencies';

  @override
  String companiesSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verified Umrah operators',
      one: '$count verified Umrah operator',
    );
    return '$_temp0';
  }

  @override
  String get companiesVerifiedBadge => 'VERIFIED';

  @override
  String companiesLocationEst(String location, int since) {
    return '$location · est. $since';
  }

  @override
  String companiesPackageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packages',
      one: '$count package',
    );
    return '$_temp0';
  }

  @override
  String get companiesFromPrefix => 'from ';

  @override
  String get companyDetailAbout => 'About';

  @override
  String companyDetailPackagesHeader(int count) {
    return 'Packages ($count)';
  }

  @override
  String companyDetailLocationSince(String location, int since) {
    return '$location · since $since';
  }

  @override
  String companyDetailReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '$count review',
    );
    return '$_temp0';
  }

  @override
  String get companyDetailPackagesLabel => 'packages';

  @override
  String get companyDetailStartingLabel => 'starting';

  @override
  String get companyDetailFromPrefix => 'from ';

  @override
  String get bookingsTitle => 'My Bookings';

  @override
  String bookingsTripCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips',
      one: '$count trip',
    );
    return '$_temp0';
  }

  @override
  String bookingsPaxCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pax',
      one: '$count pax',
    );
    return '$_temp0';
  }

  @override
  String bookingsRefLabel(String ref) {
    return 'REF $ref';
  }

  @override
  String get bookingsEmptyTitle => 'No bookings yet';

  @override
  String get bookingsEmptyBody => 'Your confirmed trips will appear here.';

  @override
  String get bookingsBrowseOffers => 'Browse offers';

  @override
  String get agencyLoginTitle => 'Agency Portal';

  @override
  String get agencyLoginSubtitle =>
      'Sign in to manage your packages and profile.';

  @override
  String get agencyLoginEmail => 'Email address';

  @override
  String get agencyLoginPassword => 'Password';

  @override
  String get agencyLoginInvalidCredentials =>
      'Invalid email or password. Try: admin@alsafwah.com / pass123';

  @override
  String get agencyLoginSignIn => 'Sign In';

  @override
  String get agencyLoginDemoCredentials => 'Demo credentials';

  @override
  String get agencyLoginDemoEmail => 'Email: admin@alsafwah.com';

  @override
  String get agencyLoginDemoPassword => 'Password: pass123';

  @override
  String get agencyLoginDemoHint =>
      '(Use admin@noorharamain.com etc. for other agencies)';

  @override
  String agencyDashboardYourPackages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your Packages ($count)',
      one: 'Your Packages (1)',
      zero: 'No Packages',
    );
    return '$_temp0';
  }

  @override
  String get agencyDashboardAddPackage => 'Add Package';

  @override
  String get agencyDashboardVerificationPending => 'Verification Pending';

  @override
  String get agencyDashboardVerificationPendingBody =>
      'Your account is under review. Once verified you can publish packages and edit your profile.';

  @override
  String get agencyDashboardEditProfile => 'Edit Profile';

  @override
  String get agencyDashboardVerifiedAgency => 'Verified Agency';

  @override
  String get agencyDashboardPendingVerification => 'Pending Verification';

  @override
  String agencyDashboardDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get agencyDashboardDeletePackageTitle => 'Delete package?';

  @override
  String agencyDashboardDeletePackageBody(String title) {
    return 'This will permanently remove \"$title\".';
  }

  @override
  String get agencyDashboardCancel => 'Cancel';

  @override
  String get agencyDashboardDelete => 'Delete';

  @override
  String get agencyDashboardNoPackagesYet => 'No packages yet';

  @override
  String get agencyDashboardNoPackagesHint =>
      'Tap \"Add Package\" to publish your first Umrah offer.';

  @override
  String get editAgencyProfileTitle => 'Edit Profile';

  @override
  String get editAgencyProfileSave => 'Save';

  @override
  String get editAgencyProfileUpdated => 'Profile updated!';

  @override
  String editAgencyProfileSinceReadOnly(int since) {
    return 'Since $since · Read-only fields above';
  }

  @override
  String get editAgencyProfileLocationLabel => 'Location / City';

  @override
  String get editAgencyProfileLocationHint => 'e.g. Riyadh, KSA';

  @override
  String get editAgencyProfileAboutLabel => 'About your agency';

  @override
  String get editAgencyProfileAboutHint =>
      'Describe your agency, specialisations, history…';

  @override
  String get editAgencyProfileTagsLabel => 'Tags (comma-separated)';

  @override
  String get editAgencyProfileTagsHint =>
      'e.g. Govt. licensed, Family specialist';

  @override
  String get editAgencyProfileTagsBadgeHint =>
      'Tags appear on your agency profile as badges.';

  @override
  String get addEditOfferEditTitle => 'Edit Package';

  @override
  String get addEditOfferNewTitle => 'New Package';

  @override
  String get addEditOfferSave => 'Save';

  @override
  String get addEditOfferAddCoverImage => 'Add cover image';

  @override
  String get addEditOfferChangeImage => 'Change image';

  @override
  String get addEditOfferPackageDetails => 'Package details';

  @override
  String get addEditOfferTitleField => 'Title *';

  @override
  String get addEditOfferTitleHint => 'e.g. Premium Makkah & Madinah';

  @override
  String get addEditOfferCitiesRoute => 'Cities / Route';

  @override
  String get addEditOfferCitiesRouteHint => 'e.g. Makkah · Madinah';

  @override
  String get addEditOfferBadgeOptional => 'Badge (optional)';

  @override
  String get addEditOfferBadgeHint => 'e.g. Bestseller, Ramadan';

  @override
  String get addEditOfferTransportStay => 'Transport & stay';

  @override
  String get addEditOfferTransport => 'Transport';

  @override
  String get addEditOfferByAir => 'By Air';

  @override
  String get addEditOfferByCoach => 'By Coach';

  @override
  String get addEditOfferDays => 'Days';

  @override
  String get addEditOfferStars => 'Stars';

  @override
  String get addEditOfferMeals => 'Meals';

  @override
  String get addEditOfferHotel => 'Hotel';

  @override
  String get addEditOfferHotelName => 'Hotel name';

  @override
  String get addEditOfferHotelNameHint => 'e.g. Conrad Makkah Suites';

  @override
  String get addEditOfferDistanceToHaram => 'Distance to Haram';

  @override
  String get addEditOfferDistanceHint => 'e.g. 200m';

  @override
  String get addEditOfferRoomType => 'Room type';

  @override
  String get addEditOfferRoomTypeHint => 'e.g. Deluxe Twin';

  @override
  String get addEditOfferCarrierCoach => 'Carrier / Coach';

  @override
  String get addEditOfferCarrierHint => 'e.g. Saudia, Flynas';

  @override
  String get addEditOfferPricing => 'Pricing';

  @override
  String get addEditOfferPriceUsd => 'Price (USD) *';

  @override
  String get addEditOfferOriginalPrice => 'Original price';

  @override
  String get addEditOfferOriginalPriceHint => '0 (optional)';

  @override
  String get addEditOfferItinerary => 'Itinerary';

  @override
  String get addEditOfferItineraryHelper =>
      'Add day-by-day breakdown of the trip.';

  @override
  String get addEditOfferAddItineraryDay => 'Add itinerary day';

  @override
  String get addEditOfferDayOneHint => 'Day 1';

  @override
  String get addEditOfferDayTitleHint => 'Day title…';

  @override
  String get addEditOfferDaySummaryHint => 'Describe what happens on this day…';

  @override
  String addEditOfferDayN(int n) {
    return 'Day $n';
  }

  @override
  String get addEditOfferWhatsIncluded => 'What\'s included';

  @override
  String get addEditOfferWhatsIncludedHelper =>
      'List everything included in the package.';

  @override
  String get addEditOfferIncludeItemHint =>
      'e.g. Return flights, Visa processing…';

  @override
  String get addEditOfferAddIncludedItem => 'Add included item';

  @override
  String get addEditOfferFillTitlePrice =>
      'Please fill in title and a valid price.';

  @override
  String get addEditOfferUpdated => 'Package updated!';

  @override
  String get addEditOfferPublished => 'Package published!';
}
