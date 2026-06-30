import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku'),
  ];

  /// App name shown in OS task switcher
  ///
  /// In en, this message translates to:
  /// **'Umrah'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAgencies.
  ///
  /// In en, this message translates to:
  /// **'Agencies'**
  String get navAgencies;

  /// No description provided for @navOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get navOffers;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageKurdish.
  ///
  /// In en, this message translates to:
  /// **'Kurdish'**
  String get languageKurdish;

  /// No description provided for @chooseLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguageTitle;

  /// No description provided for @profileSavedTrips.
  ///
  /// In en, this message translates to:
  /// **'Saved trips'**
  String get profileSavedTrips;

  /// No description provided for @profileMyBookings.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get profileMyBookings;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profilePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get profilePaymentMethods;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profilePrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get profilePrivacySecurity;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get profileHelpSupport;

  /// No description provided for @profileAgencyDivider.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get profileAgencyDivider;

  /// No description provided for @profileAgencyDashboardWithName.
  ///
  /// In en, this message translates to:
  /// **'Agency Dashboard · {name}'**
  String profileAgencyDashboardWithName(String name);

  /// No description provided for @profileAgencyPortal.
  ///
  /// In en, this message translates to:
  /// **'Agency Portal'**
  String get profileAgencyPortal;

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon.'**
  String get comingSoonBody;

  /// No description provided for @profilePilgrim.
  ///
  /// In en, this message translates to:
  /// **'Pilgrim'**
  String get profilePilgrim;

  /// No description provided for @profileGoldMember.
  ///
  /// In en, this message translates to:
  /// **'★ Gold Member'**
  String get profileGoldMember;

  /// No description provided for @profileStatTrips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get profileStatTrips;

  /// No description provided for @profileStatSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileStatSaved;

  /// No description provided for @profileStatReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profileStatReviews;

  /// No description provided for @savedTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Trips'**
  String get savedTripsTitle;

  /// No description provided for @savedTripsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved trips yet'**
  String get savedTripsEmptyTitle;

  /// No description provided for @savedTripsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any offer to save it.'**
  String get savedTripsEmptyBody;

  /// No description provided for @priceFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'from '**
  String get priceFromPrefix;

  /// No description provided for @offerDetailOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get offerDetailOverview;

  /// No description provided for @offerDetailOverviewBody.
  ///
  /// In en, this message translates to:
  /// **'A {days}-day {transport} journey to {city}, staying at the {acc}-star {hotel}, just {distance} from the Haram. Includes {company}\'s signature group guidance, daily worship support and full ziyarah.'**
  String offerDetailOverviewBody(
    int days,
    String transport,
    String city,
    int acc,
    String hotel,
    String distance,
    String company,
  );

  /// No description provided for @offerDetailDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String offerDetailDaysCount(int days);

  /// No description provided for @offerDetailNightsCount.
  ///
  /// In en, this message translates to:
  /// **'{nights} nights'**
  String offerDetailNightsCount(int nights);

  /// No description provided for @offerDetailStarCount.
  ///
  /// In en, this message translates to:
  /// **'{acc}-Star'**
  String offerDetailStarCount(int acc);

  /// No description provided for @offerDetailHotelLower.
  ///
  /// In en, this message translates to:
  /// **'hotel'**
  String get offerDetailHotelLower;

  /// No description provided for @offerDetailPilgrimReviews.
  ///
  /// In en, this message translates to:
  /// **' pilgrim reviews'**
  String get offerDetailPilgrimReviews;

  /// No description provided for @offerDetailViewAgency.
  ///
  /// In en, this message translates to:
  /// **'View agency →'**
  String get offerDetailViewAgency;

  /// No description provided for @offerDetailAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get offerDetailAccommodation;

  /// No description provided for @offerDetailDistanceToHaram.
  ///
  /// In en, this message translates to:
  /// **'{distance} to Haram'**
  String offerDetailDistanceToHaram(String distance);

  /// No description provided for @offerDetailRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get offerDetailRoom;

  /// No description provided for @offerDetailMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get offerDetailMeals;

  /// No description provided for @offerDetailTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get offerDetailTransportation;

  /// No description provided for @offerDetailCarrierTransfersIncluded.
  ///
  /// In en, this message translates to:
  /// **'{carrier} · All ground transfers included'**
  String offerDetailCarrierTransfersIncluded(String carrier);

  /// No description provided for @offerDetailItinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get offerDetailItinerary;

  /// No description provided for @offerDetailWhatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s Included'**
  String get offerDetailWhatsIncluded;

  /// No description provided for @offerDetailPackagePerPerson.
  ///
  /// In en, this message translates to:
  /// **'Package (per person)'**
  String get offerDetailPackagePerPerson;

  /// No description provided for @offerDetailVisaProcessing.
  ///
  /// In en, this message translates to:
  /// **'Visa & processing'**
  String get offerDetailVisaProcessing;

  /// No description provided for @offerDetailIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get offerDetailIncluded;

  /// No description provided for @offerDetailTaxesFees.
  ///
  /// In en, this message translates to:
  /// **'Taxes & fees'**
  String get offerDetailTaxesFees;

  /// No description provided for @offerDetailTotalFrom.
  ///
  /// In en, this message translates to:
  /// **'Total from'**
  String get offerDetailTotalFrom;

  /// No description provided for @offerDetailFromPerPerson.
  ///
  /// In en, this message translates to:
  /// **'from / person'**
  String get offerDetailFromPerPerson;

  /// No description provided for @offerDetailBookThisTrip.
  ///
  /// In en, this message translates to:
  /// **'Book this trip'**
  String get offerDetailBookThisTrip;

  /// No description provided for @offerDetailConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get offerDetailConfirmBooking;

  /// No description provided for @offerDetailBookingSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{days} days · {transport} · {acc}★'**
  String offerDetailBookingSummaryLine(int days, String transport, int acc);

  /// No description provided for @offerDetailTravelers.
  ///
  /// In en, this message translates to:
  /// **'Travelers'**
  String get offerDetailTravelers;

  /// No description provided for @offerDetailPricePerPerson.
  ///
  /// In en, this message translates to:
  /// **'{price} per person'**
  String offerDetailPricePerPerson(String price);

  /// No description provided for @offerDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get offerDetailTotal;

  /// No description provided for @offerDetailBookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed!'**
  String get offerDetailBookingConfirmed;

  /// No description provided for @offerDetailConfirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & pay {total}'**
  String offerDetailConfirmAndPay(String total);

  /// No description provided for @offerDetailFreeCancellation.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation up to 30 days before departure'**
  String get offerDetailFreeCancellation;

  /// No description provided for @offersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offersTitle;

  /// No description provided for @offersPackagesMatch.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} package matches} other{{count} packages match}}'**
  String offersPackagesMatch(int count);

  /// No description provided for @offersFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get offersFilters;

  /// No description provided for @offersAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get offersAll;

  /// No description provided for @offersByAir.
  ///
  /// In en, this message translates to:
  /// **'By Air'**
  String get offersByAir;

  /// No description provided for @offersByCoach.
  ///
  /// In en, this message translates to:
  /// **'By Coach'**
  String get offersByCoach;

  /// No description provided for @offers5Star.
  ///
  /// In en, this message translates to:
  /// **'5 Star'**
  String get offers5Star;

  /// No description provided for @offers4Star.
  ///
  /// In en, this message translates to:
  /// **'4 Star'**
  String get offers4Star;

  /// No description provided for @offersSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get offersSort;

  /// No description provided for @offersPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get offersPopular;

  /// No description provided for @offersPriceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get offersPriceLowToHigh;

  /// No description provided for @offersPriceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
  String get offersPriceHighToLow;

  /// No description provided for @offersNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get offersNoMatches;

  /// No description provided for @offersTryWideningFilters.
  ///
  /// In en, this message translates to:
  /// **'Try widening your filters.'**
  String get offersTryWideningFilters;

  /// No description provided for @offersResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get offersResetFilters;

  /// No description provided for @offersDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} day} other{{count} days}}'**
  String offersDaysCount(int count);

  /// No description provided for @offersStarCount.
  ///
  /// In en, this message translates to:
  /// **'{count}-Star'**
  String offersStarCount(int count);

  /// No description provided for @offersFromPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get offersFromPricePrefix;

  /// No description provided for @filterSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterSheetTitle;

  /// No description provided for @filterSheetReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterSheetReset;

  /// No description provided for @filterSheetMaxPricePerPerson.
  ///
  /// In en, this message translates to:
  /// **'Max price / person'**
  String get filterSheetMaxPricePerPerson;

  /// No description provided for @filterSheetTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get filterSheetTransportation;

  /// No description provided for @filterSheetAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterSheetAll;

  /// No description provided for @filterSheetByAir.
  ///
  /// In en, this message translates to:
  /// **'By Air'**
  String get filterSheetByAir;

  /// No description provided for @filterSheetByCoach.
  ///
  /// In en, this message translates to:
  /// **'By Coach'**
  String get filterSheetByCoach;

  /// No description provided for @filterSheetAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get filterSheetAccommodation;

  /// No description provided for @filterSheetAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filterSheetAny;

  /// No description provided for @filterSheetTripDuration.
  ///
  /// In en, this message translates to:
  /// **'Trip duration'**
  String get filterSheetTripDuration;

  /// No description provided for @filterSheetDuration7to9.
  ///
  /// In en, this message translates to:
  /// **'7–9 days'**
  String get filterSheetDuration7to9;

  /// No description provided for @filterSheetDuration10to14.
  ///
  /// In en, this message translates to:
  /// **'10–14 days'**
  String get filterSheetDuration10to14;

  /// No description provided for @filterSheetDuration15Plus.
  ///
  /// In en, this message translates to:
  /// **'15+ days'**
  String get filterSheetDuration15Plus;

  /// No description provided for @filterSheetAgencyRating.
  ///
  /// In en, this message translates to:
  /// **'Agency rating'**
  String get filterSheetAgencyRating;

  /// No description provided for @filterSheetShowPackages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show {count} package} other{Show {count} packages}}'**
  String filterSheetShowPackages(int count);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'السلام عليكم'**
  String get homeGreeting;

  /// No description provided for @homeWelcomePilgrim.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Pilgrim'**
  String get homeWelcomePilgrim;

  /// No description provided for @homeFeatured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get homeFeatured;

  /// No description provided for @homeDaysStarHotel.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{days} day} other{{days} days}} · {acc}-Star Hotel'**
  String homeDaysStarHotel(int days, int acc);

  /// No description provided for @homeSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search Umrah packages…'**
  String get homeSearchPlaceholder;

  /// No description provided for @homeTopAgencies.
  ///
  /// In en, this message translates to:
  /// **'Top Agencies'**
  String get homeTopAgencies;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeRatingOffersCount.
  ///
  /// In en, this message translates to:
  /// **'{rating} · {count, plural, =1{{count} offer} other{{count} offers}}'**
  String homeRatingOffersCount(double rating, int count);

  /// No description provided for @homeCuratedPackages.
  ///
  /// In en, this message translates to:
  /// **'Curated Packages'**
  String get homeCuratedPackages;

  /// No description provided for @homeDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{days} day} other{{days} days}}'**
  String homeDaysCount(int days);

  /// No description provided for @homeFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'from '**
  String get homeFromPrefix;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search packages, agencies, cities…'**
  String get searchHint;

  /// No description provided for @searchPopularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular searches'**
  String get searchPopularSearches;

  /// No description provided for @searchSuggestionPremiumPackages.
  ///
  /// In en, this message translates to:
  /// **'Premium packages'**
  String get searchSuggestionPremiumPackages;

  /// No description provided for @searchSuggestionByAir.
  ///
  /// In en, this message translates to:
  /// **'By Air'**
  String get searchSuggestionByAir;

  /// No description provided for @searchSuggestionByCoach.
  ///
  /// In en, this message translates to:
  /// **'By Coach'**
  String get searchSuggestionByCoach;

  /// No description provided for @searchSuggestionRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get searchSuggestionRamadan;

  /// No description provided for @searchSuggestionFiveStar.
  ///
  /// In en, this message translates to:
  /// **'5-Star'**
  String get searchSuggestionFiveStar;

  /// No description provided for @searchSuggestionMadinah.
  ///
  /// In en, this message translates to:
  /// **'Madinah'**
  String get searchSuggestionMadinah;

  /// No description provided for @searchSuggestionFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get searchSuggestionFamily;

  /// No description provided for @searchNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResultsFor(String query);

  /// No description provided for @searchTryDifferentTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different name, city, or hotel.'**
  String get searchTryDifferentTerm;

  /// No description provided for @searchFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'from '**
  String get searchFromPrefix;

  /// No description provided for @companiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Agencies'**
  String get companiesTitle;

  /// No description provided for @companiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} verified Umrah operator} other{{count} verified Umrah operators}}'**
  String companiesSubtitle(int count);

  /// No description provided for @companiesVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get companiesVerifiedBadge;

  /// No description provided for @companiesLocationEst.
  ///
  /// In en, this message translates to:
  /// **'{location} · est. {since}'**
  String companiesLocationEst(String location, int since);

  /// No description provided for @companiesPackageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} package} other{{count} packages}}'**
  String companiesPackageCount(int count);

  /// No description provided for @companiesFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'from '**
  String get companiesFromPrefix;

  /// No description provided for @companyDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get companyDetailAbout;

  /// No description provided for @companyDetailPackagesHeader.
  ///
  /// In en, this message translates to:
  /// **'Packages ({count})'**
  String companyDetailPackagesHeader(int count);

  /// No description provided for @companyDetailLocationSince.
  ///
  /// In en, this message translates to:
  /// **'{location} · since {since}'**
  String companyDetailLocationSince(String location, int since);

  /// No description provided for @companyDetailReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} review} other{{count} reviews}}'**
  String companyDetailReviewsCount(int count);

  /// No description provided for @companyDetailPackagesLabel.
  ///
  /// In en, this message translates to:
  /// **'packages'**
  String get companyDetailPackagesLabel;

  /// No description provided for @companyDetailStartingLabel.
  ///
  /// In en, this message translates to:
  /// **'starting'**
  String get companyDetailStartingLabel;

  /// No description provided for @companyDetailFromPrefix.
  ///
  /// In en, this message translates to:
  /// **'from '**
  String get companyDetailFromPrefix;

  /// No description provided for @bookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get bookingsTitle;

  /// No description provided for @bookingsTripCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} trip} other{{count} trips}}'**
  String bookingsTripCount(int count);

  /// No description provided for @bookingsPaxCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} pax} other{{count} pax}}'**
  String bookingsPaxCount(int count);

  /// No description provided for @bookingsRefLabel.
  ///
  /// In en, this message translates to:
  /// **'REF {ref}'**
  String bookingsRefLabel(String ref);

  /// No description provided for @bookingsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get bookingsEmptyTitle;

  /// No description provided for @bookingsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your confirmed trips will appear here.'**
  String get bookingsEmptyBody;

  /// No description provided for @bookingsBrowseOffers.
  ///
  /// In en, this message translates to:
  /// **'Browse offers'**
  String get bookingsBrowseOffers;

  /// No description provided for @agencyLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Agency Portal'**
  String get agencyLoginTitle;

  /// No description provided for @agencyLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your packages and profile.'**
  String get agencyLoginSubtitle;

  /// No description provided for @agencyLoginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get agencyLoginEmail;

  /// No description provided for @agencyLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get agencyLoginPassword;

  /// No description provided for @agencyLoginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Try: admin@alsafwah.com / pass123'**
  String get agencyLoginInvalidCredentials;

  /// No description provided for @agencyLoginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get agencyLoginSignIn;

  /// No description provided for @agencyLoginDemoCredentials.
  ///
  /// In en, this message translates to:
  /// **'Demo credentials'**
  String get agencyLoginDemoCredentials;

  /// No description provided for @agencyLoginDemoEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: admin@alsafwah.com'**
  String get agencyLoginDemoEmail;

  /// No description provided for @agencyLoginDemoPassword.
  ///
  /// In en, this message translates to:
  /// **'Password: pass123'**
  String get agencyLoginDemoPassword;

  /// No description provided for @agencyLoginDemoHint.
  ///
  /// In en, this message translates to:
  /// **'(Use admin@noorharamain.com etc. for other agencies)'**
  String get agencyLoginDemoHint;

  /// No description provided for @agencyDashboardYourPackages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No Packages} =1{Your Packages (1)} other{Your Packages ({count})}}'**
  String agencyDashboardYourPackages(int count);

  /// No description provided for @agencyDashboardAddPackage.
  ///
  /// In en, this message translates to:
  /// **'Add Package'**
  String get agencyDashboardAddPackage;

  /// No description provided for @agencyDashboardVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get agencyDashboardVerificationPending;

  /// No description provided for @agencyDashboardVerificationPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is under review. Once verified you can publish packages and edit your profile.'**
  String get agencyDashboardVerificationPendingBody;

  /// No description provided for @agencyDashboardEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get agencyDashboardEditProfile;

  /// No description provided for @agencyDashboardVerifiedAgency.
  ///
  /// In en, this message translates to:
  /// **'Verified Agency'**
  String get agencyDashboardVerifiedAgency;

  /// No description provided for @agencyDashboardPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get agencyDashboardPendingVerification;

  /// No description provided for @agencyDashboardDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String agencyDashboardDaysCount(int count);

  /// No description provided for @agencyDashboardDeletePackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete package?'**
  String get agencyDashboardDeletePackageTitle;

  /// No description provided for @agencyDashboardDeletePackageBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove \"{title}\".'**
  String agencyDashboardDeletePackageBody(String title);

  /// No description provided for @agencyDashboardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get agencyDashboardCancel;

  /// No description provided for @agencyDashboardDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get agencyDashboardDelete;

  /// No description provided for @agencyDashboardNoPackagesYet.
  ///
  /// In en, this message translates to:
  /// **'No packages yet'**
  String get agencyDashboardNoPackagesYet;

  /// No description provided for @agencyDashboardNoPackagesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Package\" to publish your first Umrah offer.'**
  String get agencyDashboardNoPackagesHint;

  /// No description provided for @editAgencyProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editAgencyProfileTitle;

  /// No description provided for @editAgencyProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editAgencyProfileSave;

  /// No description provided for @editAgencyProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get editAgencyProfileUpdated;

  /// No description provided for @editAgencyProfileSinceReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Since {since} · Read-only fields above'**
  String editAgencyProfileSinceReadOnly(int since);

  /// No description provided for @editAgencyProfileLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location / City'**
  String get editAgencyProfileLocationLabel;

  /// No description provided for @editAgencyProfileLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Riyadh, KSA'**
  String get editAgencyProfileLocationHint;

  /// No description provided for @editAgencyProfileAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About your agency'**
  String get editAgencyProfileAboutLabel;

  /// No description provided for @editAgencyProfileAboutHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your agency, specialisations, history…'**
  String get editAgencyProfileAboutHint;

  /// No description provided for @editAgencyProfileTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma-separated)'**
  String get editAgencyProfileTagsLabel;

  /// No description provided for @editAgencyProfileTagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Govt. licensed, Family specialist'**
  String get editAgencyProfileTagsHint;

  /// No description provided for @editAgencyProfileTagsBadgeHint.
  ///
  /// In en, this message translates to:
  /// **'Tags appear on your agency profile as badges.'**
  String get editAgencyProfileTagsBadgeHint;

  /// No description provided for @addEditOfferEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Package'**
  String get addEditOfferEditTitle;

  /// No description provided for @addEditOfferNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Package'**
  String get addEditOfferNewTitle;

  /// No description provided for @addEditOfferSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addEditOfferSave;

  /// No description provided for @addEditOfferAddCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Add cover image'**
  String get addEditOfferAddCoverImage;

  /// No description provided for @addEditOfferChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get addEditOfferChangeImage;

  /// No description provided for @addEditOfferPackageDetails.
  ///
  /// In en, this message translates to:
  /// **'Package details'**
  String get addEditOfferPackageDetails;

  /// No description provided for @addEditOfferTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get addEditOfferTitleField;

  /// No description provided for @addEditOfferTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Premium Makkah & Madinah'**
  String get addEditOfferTitleHint;

  /// No description provided for @addEditOfferCitiesRoute.
  ///
  /// In en, this message translates to:
  /// **'Cities / Route'**
  String get addEditOfferCitiesRoute;

  /// No description provided for @addEditOfferCitiesRouteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Makkah · Madinah'**
  String get addEditOfferCitiesRouteHint;

  /// No description provided for @addEditOfferBadgeOptional.
  ///
  /// In en, this message translates to:
  /// **'Badge (optional)'**
  String get addEditOfferBadgeOptional;

  /// No description provided for @addEditOfferBadgeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bestseller, Ramadan'**
  String get addEditOfferBadgeHint;

  /// No description provided for @addEditOfferTransportStay.
  ///
  /// In en, this message translates to:
  /// **'Transport & stay'**
  String get addEditOfferTransportStay;

  /// No description provided for @addEditOfferTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get addEditOfferTransport;

  /// No description provided for @addEditOfferByAir.
  ///
  /// In en, this message translates to:
  /// **'By Air'**
  String get addEditOfferByAir;

  /// No description provided for @addEditOfferByCoach.
  ///
  /// In en, this message translates to:
  /// **'By Coach'**
  String get addEditOfferByCoach;

  /// No description provided for @addEditOfferDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get addEditOfferDays;

  /// No description provided for @addEditOfferStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get addEditOfferStars;

  /// No description provided for @addEditOfferMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get addEditOfferMeals;

  /// No description provided for @addEditOfferHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get addEditOfferHotel;

  /// No description provided for @addEditOfferHotelName.
  ///
  /// In en, this message translates to:
  /// **'Hotel name'**
  String get addEditOfferHotelName;

  /// No description provided for @addEditOfferHotelNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Conrad Makkah Suites'**
  String get addEditOfferHotelNameHint;

  /// No description provided for @addEditOfferDistanceToHaram.
  ///
  /// In en, this message translates to:
  /// **'Distance to Haram'**
  String get addEditOfferDistanceToHaram;

  /// No description provided for @addEditOfferDistanceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 200m'**
  String get addEditOfferDistanceHint;

  /// No description provided for @addEditOfferRoomType.
  ///
  /// In en, this message translates to:
  /// **'Room type'**
  String get addEditOfferRoomType;

  /// No description provided for @addEditOfferRoomTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Deluxe Twin'**
  String get addEditOfferRoomTypeHint;

  /// No description provided for @addEditOfferCarrierCoach.
  ///
  /// In en, this message translates to:
  /// **'Carrier / Coach'**
  String get addEditOfferCarrierCoach;

  /// No description provided for @addEditOfferCarrierHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Saudia, Flynas'**
  String get addEditOfferCarrierHint;

  /// No description provided for @addEditOfferPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get addEditOfferPricing;

  /// No description provided for @addEditOfferPriceUsd.
  ///
  /// In en, this message translates to:
  /// **'Price (USD) *'**
  String get addEditOfferPriceUsd;

  /// No description provided for @addEditOfferOriginalPrice.
  ///
  /// In en, this message translates to:
  /// **'Original price'**
  String get addEditOfferOriginalPrice;

  /// No description provided for @addEditOfferOriginalPriceHint.
  ///
  /// In en, this message translates to:
  /// **'0 (optional)'**
  String get addEditOfferOriginalPriceHint;

  /// No description provided for @addEditOfferItinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get addEditOfferItinerary;

  /// No description provided for @addEditOfferItineraryHelper.
  ///
  /// In en, this message translates to:
  /// **'Add day-by-day breakdown of the trip.'**
  String get addEditOfferItineraryHelper;

  /// No description provided for @addEditOfferAddItineraryDay.
  ///
  /// In en, this message translates to:
  /// **'Add itinerary day'**
  String get addEditOfferAddItineraryDay;

  /// No description provided for @addEditOfferDayOneHint.
  ///
  /// In en, this message translates to:
  /// **'Day 1'**
  String get addEditOfferDayOneHint;

  /// No description provided for @addEditOfferDayTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Day title…'**
  String get addEditOfferDayTitleHint;

  /// No description provided for @addEditOfferDaySummaryHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happens on this day…'**
  String get addEditOfferDaySummaryHint;

  /// No description provided for @addEditOfferDayN.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String addEditOfferDayN(int n);

  /// No description provided for @addEditOfferWhatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get addEditOfferWhatsIncluded;

  /// No description provided for @addEditOfferWhatsIncludedHelper.
  ///
  /// In en, this message translates to:
  /// **'List everything included in the package.'**
  String get addEditOfferWhatsIncludedHelper;

  /// No description provided for @addEditOfferIncludeItemHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Return flights, Visa processing…'**
  String get addEditOfferIncludeItemHint;

  /// No description provided for @addEditOfferAddIncludedItem.
  ///
  /// In en, this message translates to:
  /// **'Add included item'**
  String get addEditOfferAddIncludedItem;

  /// No description provided for @addEditOfferFillTitlePrice.
  ///
  /// In en, this message translates to:
  /// **'Please fill in title and a valid price.'**
  String get addEditOfferFillTitlePrice;

  /// No description provided for @addEditOfferUpdated.
  ///
  /// In en, this message translates to:
  /// **'Package updated!'**
  String get addEditOfferUpdated;

  /// No description provided for @addEditOfferPublished.
  ///
  /// In en, this message translates to:
  /// **'Package published!'**
  String get addEditOfferPublished;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
