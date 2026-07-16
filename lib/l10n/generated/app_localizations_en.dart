// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tawaf';

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
  String get profileAgencyPortal => 'Agency & Admin portal';

  @override
  String get profileAdminDashboard => 'Admin Dashboard';

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
  String get offerDetailReturnFlightsEconomy => 'Return flights, economy';

  @override
  String get offerDetailLuxuryCoach => 'Luxury air-conditioned coach';

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
      'See this trip\'s cancellation policy';

  @override
  String get offerDetailDepartureDate => 'Departure date';

  @override
  String get dateToBeScheduled => 'To be scheduled';

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
  String get homeSponsored => 'SPONSORED';

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
  String get companiesSearchHint => 'Search agencies or cities…';

  @override
  String get companiesFilterVerified => 'Verified';

  @override
  String get companiesFilterTopRated => 'Top Rated';

  @override
  String get companiesFilterPromoted => 'Promoted';

  @override
  String get companiesFilterWithPackages => 'With Packages';

  @override
  String get companiesNoMatches => 'No agencies found';

  @override
  String get companiesTryDifferentSearch =>
      'Try a different agency name, city, or filter.';

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
  String get bookingsStatusConfirmed => 'Confirmed';

  @override
  String get bookingsStatusPending => 'Pending';

  @override
  String get bookingsStatusCancelled => 'Cancelled';

  @override
  String get bookingsStatusCompleted => 'Completed';

  @override
  String get bookingsCancelBooking => 'Cancel booking';

  @override
  String get bookingsCancelTitle => 'Cancel this booking?';

  @override
  String bookingsCancelBody(String title) {
    return '\"$title\" will be cancelled. Review the trip policy and estimated refund below before continuing.';
  }

  @override
  String get bookingsKeepBooking => 'Keep booking';

  @override
  String get bookingsConfirmCancel => 'Yes, cancel';

  @override
  String get bookingsCancelledSnack => 'Booking cancelled.';

  @override
  String get bookingsRateThisTrip => 'Rate this trip';

  @override
  String get reviewDialogTitle => 'How was your trip?';

  @override
  String get reviewCommentHint =>
      'Share a few words about your experience (optional)';

  @override
  String get reviewSubmit => 'Submit review';

  @override
  String get reviewSubmitted => 'Thanks for your review!';

  @override
  String get reviewFailed => 'Couldn\'t submit your review. Try again.';

  @override
  String get actionFailedGeneric => 'Something went wrong. Please try again.';

  @override
  String get agencyBookingsTitle => 'Booking requests';

  @override
  String get agencyBookingsRequests => 'Requests';

  @override
  String get agencyBookingsEmptyTitle => 'No booking requests yet';

  @override
  String get agencyBookingsEmptyBody =>
      'Requests from pilgrims will show up here.';

  @override
  String get agencyBookingsCompleted => 'Completed';

  @override
  String get agencyBookingsConfirm => 'Confirm';

  @override
  String get agencyBookingsDecline => 'Decline';

  @override
  String get agencyBookingsMarkCompleted => 'Mark completed';

  @override
  String get agencyBookingsConfirmedSnack => 'Booking confirmed.';

  @override
  String get agencyBookingsDeclinedSnack => 'Booking declined.';

  @override
  String get agencyBookingsCompletedSnack => 'Marked as completed.';

  @override
  String get adminCommissionsTitle => 'Commissions';

  @override
  String get adminCommissionsEmptyTitle => 'No commissions yet';

  @override
  String get adminCommissionsEmptyBody =>
      'These open automatically once a booking is confirmed.';

  @override
  String get adminCommissionsOwedLabel => 'Total owed';

  @override
  String get adminCommissionsOwed => 'OWED';

  @override
  String get adminCommissionsCollected => 'COLLECTED';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsClearAll => 'Clear all';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptyBody => 'You\'re all caught up.';

  @override
  String get notifWelcomeTitle => 'Welcome to Umrah';

  @override
  String get notifWelcomeBody =>
      'Discover trusted agencies and curated packages for your pilgrimage.';

  @override
  String get notifPromoTitle => 'Seasonal offers are live';

  @override
  String get notifPromoBody =>
      'Save up to 20% on selected packages this month.';

  @override
  String get notifTripReminderTitle => 'Upcoming trip';

  @override
  String notifTripReminderBody(String title) {
    return 'Your trip \"$title\" is coming up. Check your documents.';
  }

  @override
  String get notifBookingRequestedTitle => 'Booking requested';

  @override
  String notifBookingRequestedBody(String title) {
    return 'Your request for \"$title\" was sent to the agency. You\'ll be notified once they respond.';
  }

  @override
  String get notifBookingConfirmedTitle => 'Booking confirmed';

  @override
  String notifBookingConfirmedBody(String title) {
    return 'Your booking for \"$title\" is confirmed. See My Bookings for details.';
  }

  @override
  String get notifBookingCancelledTitle => 'Booking cancelled';

  @override
  String notifBookingCancelledBody(String title) {
    return 'Your booking for \"$title\" was cancelled.';
  }

  @override
  String get notifJustNow => 'Just now';

  @override
  String notifMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mins ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String notifHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String notifDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get paymentTitle => 'Payment methods';

  @override
  String get paymentDefaultBadge => 'DEFAULT';

  @override
  String get paymentSetDefault => 'Set as default';

  @override
  String get paymentRemoveCard => 'Remove card';

  @override
  String get paymentRemoveTitle => 'Remove this card?';

  @override
  String paymentRemoveBody(String brand, String last4) {
    return '$brand ending in $last4 will be removed.';
  }

  @override
  String get paymentKeepCard => 'Keep';

  @override
  String get paymentConfirmRemove => 'Remove';

  @override
  String get paymentAddCard => 'Add card';

  @override
  String get paymentAddCardTitle => 'Add new card';

  @override
  String get paymentCardHolder => 'Cardholder name';

  @override
  String get paymentCardHolderHint => 'Name on card';

  @override
  String get paymentCardNumber => 'Card number';

  @override
  String get paymentCardNumberHint => '1234 5678 9012 3456';

  @override
  String get paymentExpiry => 'Expiry';

  @override
  String get paymentExpiryHint => 'MM/YY';

  @override
  String get paymentCvv => 'CVV';

  @override
  String get paymentCvvHint => '123';

  @override
  String get paymentSaveCard => 'Save card';

  @override
  String get paymentCardAdded => 'Card added.';

  @override
  String get paymentCardRemoved => 'Card removed.';

  @override
  String get paymentEmptyTitle => 'No cards saved';

  @override
  String get paymentEmptyBody => 'Add a card to speed up checkout.';

  @override
  String paymentExpiresLabel(String expiry) {
    return 'Expires $expiry';
  }

  @override
  String get paymentErrHolder => 'Enter the cardholder name.';

  @override
  String get paymentErrNumber => 'Enter a valid card number (13–19 digits).';

  @override
  String get paymentErrExpiry => 'Enter a valid future expiry (MM/YY).';

  @override
  String get paymentErrCvv => 'Enter a valid CVV (3–4 digits).';

  @override
  String get paymentSaveFailed => 'Couldn\'t save the card. Try again.';

  @override
  String get paymentSignInTitle => 'Sign in to add payment methods';

  @override
  String get paymentSignInBody =>
      'Your saved cards follow your account across every device.';

  @override
  String get privacyTitle => 'Privacy & security';

  @override
  String get privacySectionSecurity => 'Security';

  @override
  String get privacyBiometric => 'Biometric app lock';

  @override
  String get privacyBiometricSub =>
      'Require Face ID / fingerprint to open the app';

  @override
  String get privacyTwoFactor => 'Two-factor authentication';

  @override
  String get privacyTwoFactorSub => 'Verify sign-ins with a one-time code';

  @override
  String get privacySectionPrivacy => 'Privacy';

  @override
  String get privacyMarketing => 'Marketing emails';

  @override
  String get privacyMarketingSub => 'Receive offers and travel tips by email';

  @override
  String get privacyActivity => 'Share usage analytics';

  @override
  String get privacyActivitySub => 'Help improve the app with anonymous data';

  @override
  String get privacyChangePassword => 'Change password';

  @override
  String get privacyCurrentPassword => 'Current password';

  @override
  String get privacyNewPassword => 'New password';

  @override
  String get privacyConfirmPassword => 'Confirm new password';

  @override
  String get privacyUpdatePassword => 'Update password';

  @override
  String get privacyPasswordChanged => 'Password updated.';

  @override
  String get privacyErrCurrentRequired => 'Enter your current password.';

  @override
  String get privacyErrTooShort =>
      'New password must be at least 6 characters.';

  @override
  String get privacyErrNoMatch => 'Passwords do not match.';

  @override
  String get privacyBiometricMobileOnly =>
      'Fingerprint lock is only available in the mobile app.';

  @override
  String get privacyBiometricUnavailable =>
      'No fingerprint or face unlock is set up on this device.';

  @override
  String get lockTitle => 'App locked';

  @override
  String get lockSubtitle => 'Use your fingerprint or face to continue.';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockFailed => 'Authentication failed. Try again.';

  @override
  String get lockReason => 'Unlock the Umrah app';

  @override
  String get helpTitle => 'Help & support';

  @override
  String get helpFaqHeader => 'Frequently asked questions';

  @override
  String get helpFaq1Q => 'How do I book an Umrah package?';

  @override
  String get helpFaq1A =>
      'Open any offer, tap \"Book this trip\", choose the number of travelers and confirm. Your booking appears under My Bookings with a reference number.';

  @override
  String get helpFaq2Q => 'Can I cancel a booking?';

  @override
  String get helpFaq2A =>
      'Open My Bookings and tap \"Cancel booking\". The app shows the trip\'s snapshotted policy and estimated refund before you confirm.';

  @override
  String get helpFaq3Q => 'Are the agencies verified?';

  @override
  String get helpFaq3A =>
      'Every listed agency is government-licensed and verified by our team before their packages go live.';

  @override
  String get helpFaq4Q => 'What is included in a package?';

  @override
  String get helpFaq4A =>
      'Each offer has its own declared inclusions. Check the \"What\'s Included\" section; anything not listed there should not be assumed.';

  @override
  String get helpFaq5Q => 'How do agencies join the platform?';

  @override
  String get helpFaq5A =>
      'Agencies register through the Agency Portal on the Profile tab. After verification they can publish and manage packages.';

  @override
  String get helpContactHeader => 'Contact us';

  @override
  String get helpContactEmail => 'Email support';

  @override
  String get helpContactPhone => 'Call us';

  @override
  String helpCopiedToClipboard(String value) {
    return '$value copied to clipboard';
  }

  @override
  String get helpMessageHeader => 'Send us a message';

  @override
  String get helpMessageHint => 'Describe your question or issue…';

  @override
  String get helpMessageSend => 'Send message';

  @override
  String get helpMessageSent => 'Message sent! We\'ll reply within 24 hours.';

  @override
  String get helpMessageEmpty => 'Please write a message first.';

  @override
  String get helpMessageFailed =>
      'Couldn\'t send your message. Check your connection and try again.';

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
  String get agencyLoginDemoEmail => 'Email: agency.demo@umrahapp.dev';

  @override
  String get agencyLoginDemoPassword => 'Password: demo1234';

  @override
  String get agencyLoginDemoHint =>
      '(Use admin@noorharamain.com etc. for other agencies)';

  @override
  String get adminTitle => 'Admin Dashboard';

  @override
  String get adminOverview => 'Platform overview';

  @override
  String get adminQuickActions => 'Quick actions';

  @override
  String get adminMetricAgencies => 'Agencies';

  @override
  String get adminMetricPackages => 'Packages';

  @override
  String get adminMetricFeatured => 'Featured';

  @override
  String get adminMetricLiveAds => 'Live ads';

  @override
  String get adminActionPromote => 'Promote';

  @override
  String get adminActionFinance => 'Finance';

  @override
  String get adminActionAd => 'New ad';

  @override
  String get adminAllCaughtUp =>
      'All caught up — there are no items requiring your attention.';

  @override
  String adminAttentionAgencies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'agencies are',
      one: 'agency is',
    );
    return '$count $_temp0 waiting for approval.';
  }

  @override
  String adminAttentionMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'messages need',
      one: 'message needs',
    );
    return '$count support $_temp0 a response.';
  }

  @override
  String adminAttentionAgenciesAndMessages(int agencies, int messages) {
    String _temp0 = intl.Intl.pluralLogic(
      agencies,
      locale: localeName,
      other: 'agencies',
      one: 'agency',
    );
    String _temp1 = intl.Intl.pluralLogic(
      messages,
      locale: localeName,
      other: 'messages',
      one: 'message',
    );
    return '$agencies $_temp0 and $messages support $_temp1 require attention.';
  }

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabContent => 'Content';

  @override
  String get tabMore => 'More';

  @override
  String get profilePreviewCard => 'Preview my public card';

  @override
  String get adminRecentActivity => 'Recent activity';

  @override
  String get adminNeedsAttention => 'Needs attention';

  @override
  String get adminFilterActive => 'Active';

  @override
  String get adminInfoTab => 'Info';

  @override
  String get adminSignOut => 'Sign out';

  @override
  String packagesCount(int count) {
    return '$count packages';
  }

  @override
  String financeRecordsCount(int count) {
    return '$count records';
  }

  @override
  String get contentPreviewHome => 'Preview home screen';

  @override
  String get moreGroupPeople => 'People';

  @override
  String get moreGroupSystem => 'System';

  @override
  String get moreSupportSubtitle => 'Messages from app users';

  @override
  String get morePreviewSubtitle => 'See the home screen exactly as clients do';

  @override
  String get agencyNextDeparture => 'Next departure';

  @override
  String agencyInDaysCount(int count) {
    return 'In $count days';
  }

  @override
  String get agencyKpiRevenue => 'Revenue';

  @override
  String get agencyKpiRequests => 'Pending requests';

  @override
  String get agencyMoneyYouOwe => 'You owe the platform';

  @override
  String get agencyMoneySettled => 'All settled — nothing owed right now.';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get commonBack => 'Back';

  @override
  String get adminPendingAgencies => 'Pending agencies';

  @override
  String get adminNoPending => 'No agencies waiting for approval.';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminApproved => 'Agency approved and now public!';

  @override
  String get adminActionFailed =>
      'Action failed — make sure patches_admin.sql has been run.';

  @override
  String get adminHomeAds => 'Home ads carousel';

  @override
  String get adminNoAds =>
      'No ads yet. Add one to fill the top of the home screen.';

  @override
  String get adminAddAd => 'Add ad';

  @override
  String get adminAdTitle => 'Ad title';

  @override
  String get adminAdTitleHint => 'e.g. Ramadan special — Noor Travel';

  @override
  String get adminLinkPackage => 'Link to a package (optional)';

  @override
  String get adminLinkCompany => 'Link to a company (optional)';

  @override
  String get adminNoLink => 'No link';

  @override
  String get adminAdImage => 'Ad image';

  @override
  String get adminPickImage => 'Tap to pick an image';

  @override
  String get adminAdCreated => 'Ad published to the home screen!';

  @override
  String get adminStatPending => 'Pending';

  @override
  String get adminStatOwed => 'Owed';

  @override
  String get adminStatCollected => 'Collected';

  @override
  String get adminSupportInbox => 'Support messages';

  @override
  String get adminSupportEmpty => 'No messages yet.';

  @override
  String get adminSupportAnonymous => 'Guest';

  @override
  String get adminSectionManage => 'Manage';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminSupportResolved => 'Message resolved and removed.';

  @override
  String get emailCopied => 'Email copied';

  @override
  String get adminCommissionsCardSubtitle =>
      'Owed and collected across all agencies';

  @override
  String get adminPromoteTitle => 'Promote Companies & Trips';

  @override
  String get adminPromoteSubtitle =>
      'Feature agencies and trips on the home page';

  @override
  String get promoteScreenTitle => 'Homepage Promotions';

  @override
  String get promoteSearchTrips => 'Search trips…';

  @override
  String get promoteSearchAgencies => 'Search agencies…';

  @override
  String get promoteTabTrips => 'Trips';

  @override
  String get promoteTabAgencies => 'Agencies';

  @override
  String get promoteNoTrips => 'No trips found';

  @override
  String get promoteNoAgencies => 'No agencies found';

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
  String get editAgencyProfileBannerLabel => 'Background Image';

  @override
  String get editAgencyProfileBackgroundColorLabel => 'Card Background Color';

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
  String get mealsBreakfast => 'Breakfast';

  @override
  String get mealsHalfBoard => 'Half board';

  @override
  String get mealsFullBoard => 'Full board';

  @override
  String get addEditOfferHotel => 'Hotel';

  @override
  String get addEditOfferHotelName => 'Hotel name';

  @override
  String get addEditOfferHotelNameHint => 'e.g. Conrad Makkah Suites';

  @override
  String get addEditOfferHotelMakkah => 'Hotel in Makkah';

  @override
  String get addEditOfferHotelMakkahHint => 'e.g. Conrad Makkah Suites';

  @override
  String get addEditOfferHotelMadinah => 'Hotel in Madinah';

  @override
  String get addEditOfferHotelMadinahHint => 'e.g. Anwar Al Madinah Mövenpick';

  @override
  String get addEditOfferAirport => 'Departure Airport';

  @override
  String get addEditOfferAirportHint => 'e.g. Erbil International Airport';

  @override
  String get addEditOfferBusStation => 'Departure Bus Station';

  @override
  String get addEditOfferBusStationHint => 'e.g. Sulaymaniyah Bus Terminal';

  @override
  String get offerDetailHotelMakkah => 'Hotel in Makkah';

  @override
  String get offerDetailHotelMadinah => 'Hotel in Madinah';

  @override
  String get airportDeparture => 'Departure Airport';

  @override
  String get busStationPickup => 'Departure Station';

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
  String get addEditOfferPriceUsd => 'Base price (IQD) *';

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

  @override
  String get addEditOfferSavedImageFailed =>
      'Package saved, but the cover photo couldn\'t be uploaded. Check your connection and try again from Edit.';

  @override
  String get authSignInTitle => 'Welcome back';

  @override
  String get authSignUpTitle => 'Create account';

  @override
  String get authSubtitle => 'Sign in to book trips and manage your bookings.';

  @override
  String get authFullName => 'Full name';

  @override
  String get authFullNameHint => 'Your name';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authSignUpBtn => 'Create account';

  @override
  String get authNoAccount => 'New here?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authErrFillAll => 'Please fill in all fields.';

  @override
  String get authConfirmEmailSent =>
      'Account created — check your email to confirm, then sign in.';

  @override
  String get authWelcomeSnack => 'Welcome!';

  @override
  String get profileSignIn => 'Sign in / Create account';

  @override
  String get profileSignInBannerSubtitle =>
      'Book trips, save favorites, and track your bookings.';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignedOut => 'Signed out.';

  @override
  String get profileSignOutConfirmTitle => 'Sign out?';

  @override
  String get profileSignOutConfirmBody =>
      'You can sign back in anytime with your email and password.';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionSupport => 'Support';

  @override
  String get profileGuestBadge => 'Guest';

  @override
  String get profileStatAlerts => 'Alerts';

  @override
  String get profileAccountDetails => 'Account details';

  @override
  String get accountPhoneHint => '+964 750 000 0000';

  @override
  String get accountSaveChanges => 'Save changes';

  @override
  String get accountUpdated => 'Profile updated.';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountNewPassword => 'New password';

  @override
  String get accountNewPasswordHint => 'At least 6 characters';

  @override
  String get accountPasswordUpdated => 'Password updated.';

  @override
  String get accountPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get accountDangerZone => 'Danger zone';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String get accountDeleteHint => 'Permanently removes your account and data.';

  @override
  String get accountDeleteTitle => 'Delete account?';

  @override
  String get accountDeleteBody =>
      'This permanently deletes your account, bookings, and saved data. This cannot be undone.';

  @override
  String get accountDeleteConfirm => 'Yes, delete my account';

  @override
  String get accountDeleted => 'Your account has been deleted.';

  @override
  String get accountDeleteFailed =>
      'Could not delete the account. Please try again.';

  @override
  String get profileAbout => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get aboutTermsOfUse => 'Terms of Use';

  @override
  String get legalPrivacyBody =>
      'Umrah App respects your privacy. We collect only the information needed to operate the service: your name, contact details, and booking requests. This information is shared only with the travel agency you choose to book with, and is never sold to third parties.\n\nYour data is stored securely. You can delete your account at any time from Account details, which permanently removes your profile and personal data from our systems.';

  @override
  String get legalTermsBody =>
      'Umrah App is a marketplace that connects pilgrims with licensed travel agencies. Bookings made through the app are requests: the agency confirms or declines them, and payment is made directly at the agency. Package details, prices, and availability are provided by the agencies and may change.\n\nBy using the app you agree to provide accurate information and to use the service only for personal, lawful purposes. The app is not a travel agency and is not a party to the contract between you and the agency.';

  @override
  String get bookingPayMethod => 'Payment method';

  @override
  String get payCash => 'Cash';

  @override
  String get payCard => 'Card';

  @override
  String get payFib => 'FIB';

  @override
  String get preferredPaymentTitle => 'Payment method';

  @override
  String get preferredPaymentBody =>
      'Choose how you\'d like to pay. Payment always happens in person at the agency — nothing is ever charged in the app.';

  @override
  String get preferredPaymentSaved => 'Preference saved.';

  @override
  String get bookingFailed =>
      'Could not complete the booking. Please try again.';

  @override
  String get bookingsCancelFailed =>
      'Could not cancel this booking — please contact the agency.';

  @override
  String get loadErrorTitle => 'Couldn\'t load data';

  @override
  String get loadErrorBody => 'Check your internet connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get agencyRegisterTitle => 'Register agency';

  @override
  String get agencyRegisterSubtitle =>
      'Create an account to publish your Umrah packages.';

  @override
  String get agencyRegisterBtn => 'Register agency';

  @override
  String get agencyRegisterPrompt => 'New agency?';

  @override
  String get agencyCompanyName => 'Agency name';

  @override
  String get agencyCompanyNameHint => 'e.g. Noor Travel';

  @override
  String get agencyCompanyLocation => 'City / Location';

  @override
  String get agencyCompanyLocationHint => 'e.g. Erbil';

  @override
  String get agencyCompanyAbout => 'About your agency';

  @override
  String get agencyCompanyAboutHint => 'A short description shown to pilgrims';

  @override
  String get agencyCompanySince => 'Founded year';

  @override
  String get agencyCompanySinceHint => 'e.g. 2015';

  @override
  String get agencyCompanyLogo => 'Agency logo';

  @override
  String get agencyLogoAdd => 'Add logo';

  @override
  String get agencyLogoChange => 'Change logo';

  @override
  String get agencyLogoOptional => 'Optional — shown on the Agencies page';

  @override
  String get agencyBannerAdd => 'Add banner';

  @override
  String get agencyBannerChange => 'Change banner';

  @override
  String get agencyNotAgencyAccount => 'This account is not an agency account.';

  @override
  String get addEditOfferSaveFailed =>
      'Could not save the package. Check your connection and try again.';

  @override
  String offerFallbackDayLabel(int n) {
    return 'Day $n';
  }

  @override
  String offerFallbackDayRangeLabel(int a, int b) {
    return 'Days $a–$b';
  }

  @override
  String get offerFallbackFinalDaysLabel => 'Final days';

  @override
  String get offerFallbackDay1Title => 'Arrival & transfer';

  @override
  String get offerFallbackDay1Summary =>
      'Arrive in Jeddah, met by your guide, and transfer to your hotel near the Haram.';

  @override
  String get offerFallbackDay2Title => 'Perform Umrah';

  @override
  String get offerFallbackDay2Summary =>
      'Guided Umrah — Tawaf, Sa\'i and Tahallul accompanied by your group scholar.';

  @override
  String get offerFallbackMakkahTitle => 'Worship in Makkah';

  @override
  String get offerFallbackMakkahSummary =>
      'Prayers at Masjid al-Haram with optional ziyarah to Mina, Arafah and historic sites.';

  @override
  String get offerFallbackMadinahTravelTitle => 'Travel to Madinah';

  @override
  String get offerFallbackMadinahTravelSummary =>
      'High-speed transfer to Madinah and check-in steps from the Prophet\'s Mosque.';

  @override
  String get offerFallbackMadinahReturnTitle => 'Madinah & return';

  @override
  String get offerFallbackMadinahReturnSummary =>
      'Worship at Masjid an-Nabawi, ziyarah tours, then transfer for your homeward journey.';

  @override
  String get offerFallbackWorshipReturnTitle => 'Worship & return';

  @override
  String get offerFallbackWorshipReturnSummary =>
      'Final prayers and Tawaf al-Wada, then transfer to the airport for departure.';

  @override
  String get offerFallbackIncludeVisa => 'Umrah visa & processing';

  @override
  String get offerFallbackIncludeFlights => 'Return international flights';

  @override
  String get offerFallbackIncludeCoach => 'Air-conditioned coach transfers';

  @override
  String offerFallbackIncludeHotel(int acc, String hotel) {
    return '$acc-star hotel — $hotel';
  }

  @override
  String offerFallbackIncludeMeals(String meals) {
    return '$meals dining daily';
  }

  @override
  String get offerFallbackIncludeZiyarah => 'Guided ziyarah tours';

  @override
  String get offerFallbackIncludeGuide => '24/7 multilingual group guide';

  @override
  String get profileAdminDashboardSub =>
      'Manage agencies, ads, and commissions';

  @override
  String get profileAgencyDashboardSub => 'Manage your packages and bookings';

  @override
  String get profileAgencyPortalSub => 'Login as an agency or admin';

  @override
  String get profileAgencyLogout => 'Logout from Agency';

  @override
  String get profileAgencyLogoutTitle => 'Logout from Agency?';

  @override
  String get profileAgencyLogoutBody =>
      'You will be signed out of the agency portal. You can log back in anytime.';

  @override
  String get adminDecline => 'Decline';

  @override
  String get adminDeclineTitle => 'Decline Agency?';

  @override
  String get adminDeclineBody =>
      'This agency will not be approved and their packages will not appear on the platform.';

  @override
  String get adminDeclined => 'Agency declined.';

  @override
  String get agencyLoginInfoNote =>
      'Use the credentials provided by your agency administrator to sign in.';

  @override
  String get editAgencyProfileLocationRequired => 'Location is required.';

  @override
  String get editAgencyProfileYearInvalid =>
      'Please enter a valid year (1900–present).';

  @override
  String get adminDeleteAdTitle => 'Delete this ad?';

  @override
  String get adminDeleteAdBody =>
      'This ad will be permanently removed from the home carousel.';

  @override
  String get adminDeleteAdConfirm => 'Delete';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address and we\'ll send you a verification code to reset your password.';

  @override
  String get forgotPasswordStep2Subtitle =>
      'Enter the 6-digit code sent to your email and choose a new password.';

  @override
  String get forgotPasswordCodeLabel => 'Verification Code';

  @override
  String get forgotPasswordNewPass => 'New Password';

  @override
  String get forgotPasswordConfirmPass => 'Confirm Password';

  @override
  String get forgotPasswordSendCode => 'Send Reset Code';

  @override
  String get forgotPasswordResetBtn => 'Reset Password';

  @override
  String get forgotPasswordResend => 'Didn\'t receive the code? Resend';

  @override
  String get forgotPasswordCodeSent =>
      'A verification code has been sent to your email.';

  @override
  String get forgotPasswordSuccess =>
      'Password reset successfully! Redirecting to login...';

  @override
  String get forgotPasswordErrEmail => 'Please enter your email address.';

  @override
  String get forgotPasswordErrCode => 'Please enter the verification code.';

  @override
  String get forgotPasswordErrShort =>
      'Password must be at least 6 characters.';

  @override
  String get forgotPasswordErrNoMatch => 'Passwords do not match.';

  @override
  String get authNext => 'Next';

  @override
  String get authEnterPassword => 'Enter your password to continue';

  @override
  String get authErrInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authErrEmailEmpty => 'Please enter your email address.';

  @override
  String get authErrEmailSpaces => 'Email address cannot contain spaces.';

  @override
  String get authErrEmailNoAt => 'Email must include an @ symbol.';

  @override
  String get authErrEmailInvalidDomain =>
      'Please enter a valid email domain (e.g., gmail.com).';

  @override
  String get authErrPhoneTooShort =>
      'Phone number is too short. Must be at least 7 digits.';

  @override
  String get authErrPhoneTooLong =>
      'Phone number is too long. Maximum 15 digits.';

  @override
  String get authErrPhoneInvalidChars =>
      'Phone number contains invalid characters.';

  @override
  String get authErrPhoneInvalid => 'Please enter a valid phone number.';

  @override
  String get authErrPasswordEmpty => 'Please enter your password.';

  @override
  String get authErrPasswordShort => 'Password must be at least 6 characters.';

  @override
  String get authErrPasswordNoLetter =>
      'Password must contain at least one letter.';

  @override
  String get authErrPasswordNoDigit =>
      'Password must contain at least one number.';

  @override
  String get authErrNameEmpty => 'Please enter your full name.';

  @override
  String get authErrNameTooShort => 'Name must be at least 2 characters.';

  @override
  String get accountChangeEmail => 'Change';

  @override
  String get accountChangeEmailBody =>
      'Enter your new email address. A confirmation link will be sent to verify the change.';

  @override
  String get accountUpdate => 'Update';

  @override
  String get accountVerifyIdentity => 'Verify Your Identity';

  @override
  String get accountVerifyIdentityBody =>
      'For security, please enter your current password to continue.';

  @override
  String get accountVerify => 'Verify';

  @override
  String get accountWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get accountEmailSameAsCurrent => 'This is already your current email.';

  @override
  String get accountEmailConfirmationTitle => 'Confirmation Sent';

  @override
  String get accountEmailConfirmationBody =>
      'A confirmation link has been sent to your new email address. Please check your inbox and click the link to complete the change.';

  @override
  String get bookingStepRoom => 'Room & pilgrims';

  @override
  String get bookingStepPilgrims => 'Pilgrim info';

  @override
  String get bookingStepPay => 'Payment';

  @override
  String get bookingChooseRoom => 'Choose room type';

  @override
  String get bookingChooseMeal => 'Choose meal type';

  @override
  String get bookingMealPreference => 'Meal preference for this booking';

  @override
  String get bookingRoomDouble => 'Double room';

  @override
  String get bookingRoomTriple => 'Triple room';

  @override
  String get bookingRoomQuad => 'Quad room';

  @override
  String bookingRoomPax(int count) {
    return '$count to a room';
  }

  @override
  String get bookingMostPopular => 'Most popular';

  @override
  String get bookingPilgrimCountTitle => 'Number of pilgrims';

  @override
  String get bookingPilgrimAge => 'Age 12+';

  @override
  String bookingTotalLine(int count, String price) {
    return '$count × $price';
  }

  @override
  String get bookingContinue => 'Continue';

  @override
  String get bookingContinueToPay => 'Continue to payment';

  @override
  String bookingPilgrimN(int n) {
    return 'Pilgrim $n';
  }

  @override
  String get bookingStatusComplete => 'Complete';

  @override
  String get bookingStatusIncomplete => 'Incomplete';

  @override
  String get bookingFullName => 'Full name (as in passport)';

  @override
  String get bookingFullNameHint => 'e.g. Karwan Omar Ahmed';

  @override
  String get bookingPassportNo => 'Passport number';

  @override
  String get bookingDob => 'Date of birth';

  @override
  String get bookingDobHint => 'Select date';

  @override
  String get bookingPhoneLabel => 'Mobile number';

  @override
  String get bookingReviewTitle => 'Review & payment';

  @override
  String get bookingReviewSub => 'Final step';

  @override
  String get bookingSummaryTitle => 'Booking summary';

  @override
  String get bookingSummaryTrip => 'Trip';

  @override
  String get bookingSummaryCompany => 'Company';

  @override
  String get bookingSummaryDeparture => 'Departure';

  @override
  String get bookingSummaryPilgrims => 'Pilgrims';

  @override
  String get bookingSummaryRoom => 'Room';

  @override
  String get bookingSummaryMeal => 'Meals';

  @override
  String get bookingPassportDocuments => 'Traveller passports';

  @override
  String bookingPassportDocumentsBody(int count) {
    return 'Passport details required for all $count travellers';
  }

  @override
  String get bookingPassportPrivacy =>
      'Add passport details separately for each traveller. Images are stored privately for this booking only.';

  @override
  String get bookingPassportRequired =>
      'Upload both passport and selfie photos.';

  @override
  String get bookingPassportSaved => 'Passport details saved.';

  @override
  String get bookingPassportChooseImage => 'Choose passport image';

  @override
  String get bookingPassportImageUploaded => 'Passport image uploaded';

  @override
  String get bookingPhotoExamples => 'Photo examples';

  @override
  String get bookingTakeRequiredPhotos => 'Take selfie and passport photos';

  @override
  String get payFibSub => 'Pay directly in the FIB app';

  @override
  String get payCardSub => 'Visa · Mastercard';

  @override
  String get payCashSub => 'Pay at the agency office';

  @override
  String get bookingConfirmBtn => 'Confirm booking';

  @override
  String get bookingRegisteredTitle => 'Booking registered';

  @override
  String bookingRegisteredBody(String company) {
    return 'Your request was sent to $company. You\'ll be notified as soon as it responds — usually within 24 hours.';
  }

  @override
  String get bookingRefTitle => 'Booking reference';

  @override
  String get bookingAwaitingConfirmation => 'Awaiting confirmation';

  @override
  String get bookingBackHome => 'Back to home';

  @override
  String get bookingViewMyBookings => 'View my bookings';

  @override
  String bookingPilgrimsSummary(int count, String room) {
    return '$count pilgrims · $room';
  }

  @override
  String get workflowSubmitForReview => 'Submit for review';

  @override
  String get workflowSubmitted => 'Submitted for review.';

  @override
  String get workflowSubmitCompanyBody =>
      'Complete your company profile, then submit it for verification.';

  @override
  String get workflowChangesRequired => 'Changes required';

  @override
  String get workflowPackagesToReview => 'Packages to review';

  @override
  String get workflowNoPackagesToReview => 'No packages are waiting for review';

  @override
  String get workflowReasonRequired => 'Reason required';

  @override
  String get workflowReasonHint => 'Explain what must change';

  @override
  String get workflowSendDecision => 'Send decision';

  @override
  String get workflowDecisionSaved => 'Decision saved.';

  @override
  String get workflowAwaitingPayment => 'Awaiting payment';

  @override
  String get workflowReadyToTravel => 'Ready for travel';

  @override
  String get workflowInProgress => 'Trip in progress';

  @override
  String get workflowRejected => 'Rejected';

  @override
  String get workflowExpired => 'Expired';

  @override
  String get workflowMarkReady => 'Mark ready';

  @override
  String get workflowStartTrip => 'Start trip';

  @override
  String get workflowStatusUpdated => 'Booking status updated.';

  @override
  String get workflowCompanyReviewTitle => 'Company verification updated';

  @override
  String workflowCompanyReviewBody(Object status) {
    return 'Your company application is now: $status';
  }

  @override
  String get workflowPackageReviewTitle => 'Package review updated';

  @override
  String workflowPackageReviewBody(Object status) {
    return 'Your package is now: $status';
  }

  @override
  String get workflowConfirmCash => 'Confirm cash received';

  @override
  String get workflowCashConfirmed => 'Cash payment confirmed.';

  @override
  String get workflowDraftSaved => 'Package saved as a draft.';

  @override
  String get workflowCapacity => 'Traveller capacity';

  @override
  String get workflowDepartureDate => 'Departure date';

  @override
  String get workflowReturnDate => 'Return date';

  @override
  String get workflowPayNow => 'Pay now';

  @override
  String get workflowPaymentStartFailed => 'Could not start the payment.';

  @override
  String get workflowFibPaymentTitle => 'Pay with FIB';

  @override
  String get workflowFibPaymentBody =>
      'Open FIB and use this payment code. Your booking confirms automatically after FIB verifies the payment.';

  @override
  String get workflowCopyPayment => 'Copy payment details';

  @override
  String get addEditOfferHotelMakkahDescription => 'Makkah hotel description';

  @override
  String get addEditOfferHotelMadinahDescription => 'Madinah hotel description';

  @override
  String get addEditOfferHotelDescriptionHint =>
      'Describe the location, facilities, service and nearby landmarks';

  @override
  String get addEditOfferAvailableRooms => 'Available room types';

  @override
  String get addEditOfferAvailableRoomsHelper =>
      'Choose every room occupancy clients can book for this package.';

  @override
  String get addEditOfferChooseRoomType =>
      'Choose at least one available room type.';

  @override
  String bookingRoomOccupancy(int count) {
    return '$count-person room';
  }

  @override
  String get offerFormCommercialPolicy => 'Policy & payment';

  @override
  String get offerFormTitleKu => 'Package title (Kurdish)';

  @override
  String get offerFormTitleAr => 'Package title (Arabic)';

  @override
  String get offerFormTitleEn => 'Package title (English)';

  @override
  String get offerFormOverviewKu => 'Overview (Kurdish)';

  @override
  String get offerFormOverviewAr => 'Overview (Arabic)';

  @override
  String get offerFormOverviewEn => 'Overview (English)';

  @override
  String get offerFormOverviewHint =>
      'Describe what makes this package special';

  @override
  String get offerFormPackageTier => 'Package tier';

  @override
  String get offerTierEconomy => 'Economy';

  @override
  String get offerTierStandard => 'Standard';

  @override
  String get offerTierVip => 'VIP';

  @override
  String get offerFormGroupType => 'Group type';

  @override
  String get offerGroupFamily => 'Family';

  @override
  String get offerGroupIndividual => 'Individual';

  @override
  String get offerGroupGroup => 'Group';

  @override
  String get offerFormSeason => 'Season';

  @override
  String get offerSeasonRamadan => 'Ramadan';

  @override
  String get offerSeasonRegular => 'Regular';

  @override
  String get offerSeasonShawwal => 'Shawwal';

  @override
  String get offerSeasonOther => 'Other';

  @override
  String get offerFormDepartureAirport => 'Departure airport';

  @override
  String get offerFormFlightType => 'Flight type';

  @override
  String get offerFlightDirect => 'Direct';

  @override
  String get offerFlightConnecting => 'Connecting';

  @override
  String get offerFormBusBetweenCities =>
      'Bus between Makkah and Madinah included';

  @override
  String get offerFormAirportTransfers => 'Airport transfers included';

  @override
  String get offerFormOccupancyPricing => 'Price per person by room occupancy';

  @override
  String offerFormOccupancyPrice(String room) {
    return '$room price (IQD)';
  }

  @override
  String get offerFormDepositAmount => 'Deposit amount (IQD)';

  @override
  String get offerFormNonRefundableDeposit => 'Deposit is non-refundable';

  @override
  String get offerFormDepositTerms => 'Deposit terms';

  @override
  String get offerFormDepositTermsHint => 'Explain when the balance is due';

  @override
  String get offerFormCancellationPolicy => 'Cancellation and refund policy';

  @override
  String get offerFormCancellationPolicyHint =>
      'Explain cancellation dates, fees and refund timing';

  @override
  String get offerFormAcceptedPayments => 'Accepted payment methods';

  @override
  String get offerFormRequired => 'Required';

  @override
  String get offerFormInvalidValue => 'Enter a valid value.';

  @override
  String get offerFormSelectOne => 'Select at least one option.';

  @override
  String get offerFormReturnDateAfterDeparture =>
      'Return date must be after departure.';

  @override
  String get offerFormFixHighlighted =>
      'Complete the highlighted required fields.';

  @override
  String get offerSoldOut => 'Sold out';

  @override
  String offerFewSeatsLeft(int count) {
    return 'Only $count seats left';
  }

  @override
  String get offerAvailable => 'Available';

  @override
  String get offerOccupancyPricing => 'Room pricing';

  @override
  String get offerTrustAndPolicy => 'Trust, policy & payment';

  @override
  String offerDepositLabel(String amount) {
    return 'Deposit: $amount';
  }

  @override
  String offerAcceptedPaymentsLabel(String methods) {
    return 'Accepted: $methods';
  }

  @override
  String get offerCapacitySoldOut => 'Sold out';

  @override
  String offerCapacityFewLeft(int count) {
    return 'Only $count seats left';
  }

  @override
  String get offerCapacityAvailable => 'Available';

  @override
  String offerCapacityRemaining(int count) {
    return '$count seats remaining';
  }

  @override
  String offerHotelNights(int count) {
    return '$count nights';
  }

  @override
  String offerDepositRequired(String amount) {
    return 'Deposit required: $amount';
  }

  @override
  String get offerDepositNonRefundable => 'The deposit is non-refundable';

  @override
  String offerAcceptedPaymentList(String methods) {
    return 'Accepted payment methods: $methods';
  }

  @override
  String get agencyAccessUnderReviewTitle => 'Your agency is under review';

  @override
  String get agencyAccessUnderReviewBody =>
      'You can sign in while the admin verifies your registration and documents. The dashboard will unlock after approval.';

  @override
  String get agencyAccessRejectedTitle => 'Registration needs attention';

  @override
  String get agencyAccessRejectedBody =>
      'Your registration was not approved. Review the administrator feedback and resubmit your documents.';

  @override
  String get agencyAccessSuspendedTitle => 'Agency access suspended';

  @override
  String get agencyAccessSuspendedBody =>
      'Your offers are hidden while this suspension is reviewed. Contact platform support for details.';

  @override
  String get companyTrustSignals => 'Trust & verification';

  @override
  String companyLicenseNumber(String number) {
    return 'License: $number';
  }

  @override
  String companyPilgrimsServed(int count) {
    return '$count+ pilgrims served';
  }

  @override
  String companyResponseTime(String time) {
    return 'Usually responds within $time';
  }

  @override
  String get companyContactLocation => 'Contact & location';

  @override
  String get companyAgencyReply => 'Agency reply';

  @override
  String get companyReportAgency => 'Report this agency';

  @override
  String get companyReportReason => 'Reason';

  @override
  String get companyReportDetails => 'Details (optional)';

  @override
  String get companyReportSubmit => 'Submit report';

  @override
  String get companyReportSubmitted => 'Report submitted for review';

  @override
  String get adminBookingsPayments => 'Bookings & payments';

  @override
  String get adminNoBookings => 'No bookings found';

  @override
  String get bookingStageRequested => 'Requested';

  @override
  String get bookingStageConfirmed => 'Confirmed';

  @override
  String get bookingStageCompleted => 'Completed';

  @override
  String get bookingStageCancelled => 'Cancelled';

  @override
  String get agencyMessages => 'Messages';

  @override
  String get agencyMessagesEmpty => 'No inquiries yet';

  @override
  String get agencyMessagesEmptyBody =>
      'Client questions will appear here in real time.';

  @override
  String agencyInquiryNumber(int number) {
    return 'Inquiry #$number';
  }

  @override
  String get agencyInquiryNoMessages => 'No messages';

  @override
  String get agencyReplyHint => 'Write a reply…';

  @override
  String get adminAgencyBadges => 'Manual badges';

  @override
  String get badgeVerified => 'Verified';

  @override
  String get badgePremiumPartner => 'Premium Partner';

  @override
  String get agencyDocumentsTitle => 'Documents & verification';

  @override
  String get agencyDocumentsMenuSubtitle => 'Upload or renew license documents';

  @override
  String get agencyDocumentsBody =>
      'Upload clear images of current business documents. The administrator can preview them securely during review.';

  @override
  String get agencyDocumentType => 'Document type';

  @override
  String get agencyDocumentLicense => 'Travel agency license';

  @override
  String get agencyDocumentRegistration => 'Business registration';

  @override
  String get agencyDocumentOffice => 'Office verification';

  @override
  String get agencyDocumentChoose => 'Choose document image';

  @override
  String get agencyDocumentUpload => 'Upload document';

  @override
  String get agencyDocumentUploaded => 'Document uploaded for review';

  @override
  String get agencyDocumentsResubmit => 'Upload or resubmit documents';

  @override
  String get adminNoAgencyDocuments => 'No documents uploaded yet';

  @override
  String get agencyDocumentStatusPending => 'Pending';

  @override
  String get agencyDocumentStatusApproved => 'Approved';

  @override
  String get agencyDocumentStatusRejected => 'Rejected';

  @override
  String get adminRequestMoreInfo => 'Request more information';

  @override
  String get adminMoreInfoRequested => 'Information request sent';

  @override
  String get identityVerification => 'Identity verification';

  @override
  String get identityVerificationTitle => 'Verify your identity';

  @override
  String get identityVerificationBody =>
      'Upload a clear passport photo and a selfie. Your documents are stored securely and reviewed privately.';

  @override
  String get identityPassportPhoto => 'Passport photo';

  @override
  String get identityPassportBody =>
      'A clear image of your passport identification page';

  @override
  String get identitySelfiePhoto => 'Selfie';

  @override
  String get identitySelfieBody =>
      'A clear photo of you looking directly at the camera';

  @override
  String get identityExampleTitle => 'Photo example & instructions';

  @override
  String get identityPassportInstruction1 =>
      'Show the full identification page and all four corners.';

  @override
  String get identityPassportInstruction2 =>
      'Use good lighting and avoid glare or shadows.';

  @override
  String get identityPassportInstruction3 =>
      'Make sure every detail is sharp and readable.';

  @override
  String get identitySelfieInstruction1 =>
      'Look directly at the camera in good lighting.';

  @override
  String get identitySelfieInstruction2 =>
      'Keep your full face visible and centered.';

  @override
  String get identitySelfieInstruction3 =>
      'Do not wear a hat, sunglasses, or face covering.';

  @override
  String get identityClose => 'Close';

  @override
  String get identityContinue => 'Continue';

  @override
  String get identityChooseSource => 'Choose photo source';

  @override
  String get identityCamera => 'Take a photo';

  @override
  String get identityGallery => 'Choose from gallery';

  @override
  String get identityNoPhoto => 'No photo selected';

  @override
  String get identityViewExample => 'View example';

  @override
  String get identityUploadPhoto => 'Upload photo';

  @override
  String get identityChangePhoto => 'Change photo';

  @override
  String get identitySubmit => 'Submit for verification';

  @override
  String get identitySubmitted =>
      'Your identity documents were submitted for review.';

  @override
  String get identitySignInRequired =>
      'Please sign in before submitting identity documents.';

  @override
  String get identityUploadFailed =>
      'The documents could not be uploaded. Please try again.';

  @override
  String get identitySecureTitle => 'Secure verification';

  @override
  String get identitySecureBody =>
      'We ask you to verify your identity to help keep bookings legitimate and comply with travel requirements. Your documents are encrypted and stored securely.';

  @override
  String get identityPassportPlaceholder => 'Passport information page';

  @override
  String get identitySelfiePlaceholder => 'Your selfie photo';

  @override
  String get identitySelfieInstruction4 =>
      'Use a simple, uncluttered background.';

  @override
  String get identityPassportExampleTitle => 'Passport example';

  @override
  String get identitySelfieExampleTitle => 'Selfie example';

  @override
  String get identityPassportExampleCaption =>
      'Make sure all information is clear and readable.';

  @override
  String get identitySelfieExampleCaption =>
      'Look directly at the camera, use good lighting, and do not wear a hat or sunglasses.';

  @override
  String get bookingRoomCount => 'Rooms';

  @override
  String get bookingNotes => 'Notes';

  @override
  String get bookingAmountDueNow => 'Amount due now';

  @override
  String get bookingCancelReason => 'Reason for cancellation';

  @override
  String get bookingCancelReasonHint =>
      'Tell the agency why you need to cancel';

  @override
  String get bookingCancellationPolicy => 'Cancellation policy';

  @override
  String get bookingEstimatedRefund => 'Estimated refund';

  @override
  String bookingExpiresAt(String time) {
    return 'Complete this request before $time';
  }

  @override
  String get agencyBookingDetails => 'Booking details';

  @override
  String get agencyRequestInformation => 'Request information';

  @override
  String get agencyRequestInformationHint =>
      'Explain exactly what the pilgrim needs to provide';

  @override
  String get agencyTravellerDocuments => 'Traveller documents';

  @override
  String get agencyDeclineReason => 'Reason for declining';

  @override
  String get offerFormBothHotelsRequired =>
      'Both hotels need their own name and description.';

  @override
  String offerFormHotelNightsTotal(int nights) {
    return 'Hotel nights must total $nights.';
  }

  @override
  String get offerFormPaymentRequired => 'Choose at least one payment method.';

  @override
  String get offerFormRoomPriceRequired =>
      'Every selected room needs a valid price.';

  @override
  String get offerFormDepositTooHigh =>
      'The deposit cannot be higher than the lowest per-person room price.';

  @override
  String get workflowPauseTrip => 'Pause trip';

  @override
  String get workflowPausedSnack =>
      'Trip paused and removed from the marketplace.';

  @override
  String get offerUnavailable => 'Unavailable';

  @override
  String get agencyTripOverview => 'Overview';

  @override
  String get agencyTripBookings => 'Bookings';

  @override
  String get agencyTripTravellers => 'Travellers';

  @override
  String get agencyTripDocumentsVisa => 'Documents & visa';

  @override
  String get agencyTripOperations => 'Operations';

  @override
  String get agencyTripUpdates => 'Updates';

  @override
  String get agencyTripDuplicate => 'Duplicate trip';

  @override
  String get agencyTripDuplicateBody =>
      'Create a new draft with this trip\'s hotels, prices, itinerary and policies? Dates and capacity can be adjusted before submission.';

  @override
  String get agencyTripDuplicated => 'Trip duplicated as a draft.';

  @override
  String get agencyTripDuplicateFailed => 'The trip could not be duplicated.';

  @override
  String get agencyTripExportFailed =>
      'The passenger file could not be created.';

  @override
  String get agencyTripConfirmedValue => 'Confirmed booking value';

  @override
  String get agencyTripCollected => 'Customer payments collected';

  @override
  String get agencyTripDocumentsMissing => 'Documents needing attention';

  @override
  String get agencyTripVisaPending => 'Visas not approved';

  @override
  String get agencyTripPassengerExports => 'Passenger manifests';

  @override
  String get agencyTripExportExcel => 'Export Excel';

  @override
  String get agencyTripExportPdf => 'Export PDF';

  @override
  String get agencyTripSearchTravellers => 'Search name or passport number';

  @override
  String get agencyTripNoTravellers => 'No travellers in this trip yet';

  @override
  String get agencyDocumentReview => 'Review document';

  @override
  String get agencyDocumentUploads => 'Uploaded traveller documents';

  @override
  String get agencyVisaStatus => 'Visa status';

  @override
  String get agencyVisaReference => 'Visa application reference';

  @override
  String get agencyTripTransportSeat => 'Flight or bus seat';

  @override
  String get agencyTripRooming => 'Rooming';

  @override
  String get agencyTripAddRoom => 'Add room';

  @override
  String get agencyTripNoRooms => 'No rooms have been prepared yet.';

  @override
  String get agencyTripCity => 'City';

  @override
  String get agencyTripMakkah => 'Makkah';

  @override
  String get agencyTripMadinah => 'Madinah';

  @override
  String get agencyTripRoomLabel => 'Room number or label';

  @override
  String get agencyTripRoomPolicy => 'Room group';

  @override
  String get agencyTripRoomFamily => 'Family';

  @override
  String get agencyTripRoomMale => 'Men';

  @override
  String get agencyTripRoomFemale => 'Women';

  @override
  String get agencyTripRoomCreated => 'Room added.';

  @override
  String get agencyTripRoomDeleted => 'Room removed.';

  @override
  String get agencyTripTransport => 'Transportation';

  @override
  String get agencyTripAddTransport => 'Add transport';

  @override
  String get agencyTripNoTransport =>
      'No flight or bus details have been added yet.';

  @override
  String get agencyTripTransportProvider => 'Airline or bus company';

  @override
  String get agencyTripTransportReference => 'Flight, bus or vehicle number';

  @override
  String get agencyTripDeparturePlace => 'Departure place';

  @override
  String get agencyTripMeetingPoint => 'Meeting point';

  @override
  String get agencyTripGuide => 'Assigned guide';

  @override
  String get agencyTripTransportCreated => 'Transportation added.';

  @override
  String get agencyTripTransportDeleted => 'Transportation removed.';

  @override
  String get agencyTripNewAnnouncement => 'New announcement';

  @override
  String get agencyTripAnnouncementTitle => 'Announcement title';

  @override
  String get agencyTripAnnouncementMessage => 'Message';

  @override
  String get agencyTripAudience => 'Recipients';

  @override
  String get agencyTripAudienceUnpaid => 'Travellers with unpaid balances';

  @override
  String get agencyTripSendAnnouncement => 'Send announcement';

  @override
  String get agencyTripAnnouncementSent => 'Announcement sent.';

  @override
  String get agencyTripNoAnnouncements => 'No announcements have been sent yet';

  @override
  String get agencyWalletTitle => 'Wallet & payouts';

  @override
  String get agencyWalletSubtitle =>
      'Online earnings and cash commission in one balance';

  @override
  String get agencyWalletTawafOwesYou => 'Tawaf owes your company';

  @override
  String get agencyWalletYouOweTawaf => 'Your company owes Tawaf';

  @override
  String get agencyWalletSettled => 'Your balance is settled';

  @override
  String get agencyWalletBalanceExplanation =>
      'Online payments add your net earnings. Cash bookings subtract Tawaf\'s commission. Payouts and refunds are recorded automatically.';

  @override
  String get agencyWalletAvailablePayout => 'Available payout';

  @override
  String get agencyWalletPendingPayout => 'Pending payout';

  @override
  String get agencyWalletActivity => 'Wallet activity';

  @override
  String get agencyWalletNoActivity => 'No wallet activity yet';

  @override
  String get agencyWalletNoActivityBody =>
      'Successful customer payments will appear here.';

  @override
  String get agencyWalletPayouts => 'Payout history';

  @override
  String get agencyWalletPaid => 'Paid';

  @override
  String get agencyWalletFailed => 'Failed';

  @override
  String get agencyWalletPending => 'Pending';

  @override
  String get agencyWalletOnlinePayment => 'Online booking earnings';

  @override
  String get agencyWalletCashCommission => 'Commission on cash booking';

  @override
  String get agencyWalletRefund => 'Refund reversal';

  @override
  String get agencyWalletPayout => 'Company payout';

  @override
  String get agencyWalletAdjustment => 'Balance adjustment';

  @override
  String get agencyOverviewUnpaidBookings => 'Bookings with unpaid balances';

  @override
  String get agencyManagementTitle => 'Team, reports & reviews';

  @override
  String get agencyManagementMenuSubtitle =>
      'Performance, customer feedback and staff access';

  @override
  String get agencyManagementReports => 'Reports';

  @override
  String get agencyManagementStaff => 'Staff';

  @override
  String get agencyManagementBookingValue => 'Active booking value';

  @override
  String get agencyManagementOccupancy => 'Seat occupancy';

  @override
  String get agencyManagementCancellationRate => 'Cancellation rate';

  @override
  String get agencyManagementTripPerformance => 'Trip performance';

  @override
  String get agencyManagementNoReportData => 'No trip data is available yet';

  @override
  String get agencyManagementNoReviews => 'No customer reviews yet';

  @override
  String get agencyManagementReplyReview => 'Reply to review';

  @override
  String get agencyManagementReplyReviewHint =>
      'Write a helpful public response';

  @override
  String get agencyManagementReplySent => 'Your public reply was posted.';

  @override
  String get agencyManagementAddStaff => 'Add staff member';

  @override
  String get agencyManagementProfileId => 'User profile ID';

  @override
  String get agencyManagementProfileIdHelp =>
      'Enter the Tawaf profile UUID for this employee';

  @override
  String get agencyManagementRole => 'Role';

  @override
  String get agencyManagementStaffAdded => 'Staff access added.';

  @override
  String get agencyManagementStaffRemoved => 'Staff access removed.';

  @override
  String get agencyManagementNoStaff => 'No staff members added yet';

  @override
  String get agencyManagementNoStaffBody =>
      'Add employees and give each role only the access it needs.';

  @override
  String agencyManagementTripCounts(int bookings, int travellers) {
    return 'Bookings: $bookings · Travellers: $travellers';
  }

  @override
  String get agencyTripAssignRoom => 'Assign room (remaining beds)';

  @override
  String get bookingTripUpdates => 'Trip updates & announcements';

  @override
  String get bookingTripNoUpdates =>
      'The company has not posted any updates yet.';

  @override
  String get bookingAdditionalDocument => 'Upload another document';

  @override
  String get bookingAdditionalDocumentUploaded =>
      'Document uploaded for company review.';

  @override
  String get bookingDocumentNationalId => 'National ID';

  @override
  String get bookingDocumentResidency => 'Residency card';

  @override
  String get bookingDocumentVaccination => 'Vaccination certificate';

  @override
  String get bookingDocumentAgreement => 'Signed agreement';

  @override
  String get bookingDocumentPaymentReceipt => 'Payment receipt';

  @override
  String get bookingDocumentOther => 'Other document';

  @override
  String get bookingPassportName => 'Name exactly as written in passport';

  @override
  String get bookingPassportNameHint => 'Latin passport spelling';

  @override
  String get bookingLocalName => 'Local-language name (optional)';

  @override
  String get bookingLocalNameHint => 'Kurdish or Arabic name';
}
