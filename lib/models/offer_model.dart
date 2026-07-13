import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'company_model.dart';

/// Formats an IQD amount with thousands separators, e.g. "2,750,000 IQD".
String fmtIqd(num amount) {
  final s = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '$buf IQD';
}

class OfferPrice {
  final String occupancyType;
  final double priceIqd;
  final double? priceUsd;

  const OfferPrice({
    required this.occupancyType,
    required this.priceIqd,
    this.priceUsd,
  });

  int get occupancy => switch (occupancyType) {
    'double' => 2,
    'triple' => 3,
    'quad' => 4,
    'quintuple' => 5,
    _ => 0,
  };

  factory OfferPrice.fromRow(Map<String, dynamic> row) => OfferPrice(
    occupancyType: (row['occupancy_type'] ?? 'double') as String,
    priceIqd: ((row['price_iqd'] ?? 0) as num).toDouble(),
    priceUsd: (row['price_usd'] as num?)?.toDouble(),
  );
}

class OfferHotel {
  final String city;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final int starRating;
  final int nights;
  final int distanceFromHaramM;
  final List<String> photoUrls;

  const OfferHotel({
    required this.city,
    required this.name,
    this.nameAr,
    this.nameEn,
    required this.starRating,
    required this.nights,
    required this.distanceFromHaramM,
    this.photoUrls = const [],
  });

  String nameFor(String lang) {
    if (lang == 'en' && (nameEn ?? '').isNotEmpty) return nameEn!;
    if (lang == 'ar' && (nameAr ?? '').isNotEmpty) return nameAr!;
    return name;
  }

  factory OfferHotel.fromRow(Map<String, dynamic> row) {
    final nested = row['hotels'];
    final hotel = nested is Map<String, dynamic> ? nested : row;
    return OfferHotel(
      city: (row['city'] ?? hotel['city'] ?? 'makkah') as String,
      name: (hotel['name'] ?? '') as String,
      nameAr: hotel['name_ar'] as String?,
      nameEn: hotel['name_en'] as String?,
      starRating: ((hotel['star_rating'] ?? 3) as num).toInt(),
      nights: ((row['nights'] ?? 0) as num).toInt(),
      distanceFromHaramM: ((row['distance_from_haram_m'] ?? 0) as num).toInt(),
      photoUrls: ((hotel['photo_urls'] ?? const []) as List).cast<String>(),
    );
  }
}

class OfferInclusion {
  final String type;
  final bool included;
  final String details;
  final String? detailsAr;
  final String? detailsEn;

  const OfferInclusion({
    required this.type,
    required this.included,
    this.details = '',
    this.detailsAr,
    this.detailsEn,
  });

  String detailsFor(String lang) {
    if (lang == 'en' && (detailsEn ?? '').isNotEmpty) return detailsEn!;
    if (lang == 'ar' && (detailsAr ?? '').isNotEmpty) return detailsAr!;
    return details;
  }

  factory OfferInclusion.fromRow(Map<String, dynamic> row) => OfferInclusion(
    type: (row['type'] ?? '') as String,
    included: (row['included'] ?? false) as bool,
    details: (row['details'] ?? '') as String,
    detailsAr: row['details_ar'] as String?,
    detailsEn: row['details_en'] as String?,
  );
}

class Offer {
  final String id;
  final String companyId;
  final String title; // Kurdish (base)
  final String? titleAr;
  final String? titleEn;
  final String overview;
  final String city;
  final String cityCode;
  final String transport; // 'plane' | 'bus'
  final int acc;
  final int days;
  final int nights;
  final double price; // IQD per person
  final double original; // 0 = no discount
  final double rating; // company rating (packages have no own rating yet)
  final int reviews;
  final String hotel;
  final String hotelMakkahDescription;
  final String hotelMadinahDescription;
  final String distance;
  final String room;
  final List<int> roomOccupancies;
  final String meals;
  final String carrier;
  final String badge;
  final String? imageUrl;
  final bool isFeatured;
  final String lifecycleStatus;
  final String? reviewReason;
  final int? capacity;
  final int seatsReserved;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final List<Color> gradColors;
  final List<ItineraryDay>? customItinerary;
  final List<String>? customIncludes;
  final String? overviewAr;
  final String? overviewEn;
  final String packageTier;
  final String groupType;
  final String seasonTag;
  final List<OfferPrice> pricing;
  final List<OfferHotel> hotels;
  final List<OfferInclusion> inclusions;
  final String? departureAirport;
  final String? airlineName;
  final String? airlineLogoUrl;
  final String? flightType;
  final bool busBetweenCities;
  final bool airportTransfers;
  final String transportNotes;
  final int? mealsPerDay;
  final List<String> mediaUrls;
  final String? videoUrl;
  final String cancellationPolicy;
  final String? cancellationPolicyAr;
  final String? cancellationPolicyEn;
  final double depositIqd;
  final bool nonRefundableDeposit;
  final String depositTerms;
  final List<String> acceptedPaymentMethods;

  const Offer({
    required this.id,
    required this.companyId,
    required this.title,
    this.titleAr,
    this.titleEn,
    this.overview = '',
    this.city = 'Makkah · Madinah',
    this.cityCode = 'MAKKAH',
    required this.transport,
    required this.acc,
    required this.days,
    int? nights,
    required this.price,
    this.original = 0,
    this.rating = 0,
    this.reviews = 0,
    this.hotel = '',
    this.hotelMakkahDescription = '',
    this.hotelMadinahDescription = '',
    this.distance = '',
    this.room = '',
    this.roomOccupancies = const [2, 3, 4],
    this.meals = '',
    this.carrier = '',
    this.badge = '',
    this.imageUrl,
    this.isFeatured = false,
    this.lifecycleStatus = 'draft',
    this.reviewReason,
    this.capacity,
    this.seatsReserved = 0,
    this.departureDate,
    this.returnDate,
    required this.gradColors,
    this.customItinerary,
    this.customIncludes,
    this.overviewAr,
    this.overviewEn,
    this.packageTier = 'standard',
    this.groupType = 'group',
    this.seasonTag = 'regular',
    this.pricing = const [],
    this.hotels = const [],
    this.inclusions = const [],
    this.departureAirport,
    this.airlineName,
    this.airlineLogoUrl,
    this.flightType,
    this.busBetweenCities = false,
    this.airportTransfers = false,
    this.transportNotes = '',
    this.mealsPerDay,
    this.mediaUrls = const [],
    this.videoUrl,
    this.cancellationPolicy = '',
    this.cancellationPolicyAr,
    this.cancellationPolicyEn,
    this.depositIqd = 0,
    this.nonRefundableDeposit = false,
    this.depositTerms = '',
    this.acceptedPaymentMethods = const ['cash'],
  }) : nights = nights ?? days - 1;

  String titleFor(String lang) {
    if (lang == 'en' && (titleEn ?? '').isNotEmpty) return titleEn!;
    if (lang == 'ar' && (titleAr ?? '').isNotEmpty) return titleAr!;
    return title;
  }

  String overviewFor(String lang) {
    if (lang == 'en' && (overviewEn ?? '').isNotEmpty) return overviewEn!;
    if (lang == 'ar' && (overviewAr ?? '').isNotEmpty) return overviewAr!;
    return overview;
  }

  String cancellationPolicyFor(String lang) {
    if (lang == 'en' && (cancellationPolicyEn ?? '').isNotEmpty) {
      return cancellationPolicyEn!;
    }
    if (lang == 'ar' && (cancellationPolicyAr ?? '').isNotEmpty) {
      return cancellationPolicyAr!;
    }
    return cancellationPolicy;
  }

  bool get hasDiscount => original > 0;
  bool get isByAir => transport == 'plane';
  int? get remainingSeats =>
      capacity == null ? null : (capacity! - seatsReserved).clamp(0, capacity!);
  String get capacityState {
    final remaining = remainingSeats;
    if (remaining == null) return 'available';
    if (remaining == 0 || lifecycleStatus == 'sold_out') return 'sold_out';
    if (remaining <= 5) return 'few_left';
    return 'available';
  }

  double priceForOccupancy(int occupancy) {
    for (final item in pricing) {
      if (item.occupancy == occupancy) return item.priceIqd;
    }
    return price;
  }

  List<int> get availableRoomOccupancies =>
      roomOccupancies.isEmpty ? const [2, 3, 4] : roomOccupancies;

  String get hotelMakkah {
    final parts = hotel.split('|');
    return parts.isNotEmpty ? parts[0].trim() : '';
  }

  String get hotelMadinah {
    final parts = hotel.split('|');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  String get carrierName {
    final parts = carrier.split('|');
    return parts.isNotEmpty ? parts[0].trim() : '';
  }

  String get transportPlace {
    final parts = carrier.split('|');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  String transportLabelFor(AppLocalizations t) =>
      isByAir ? t.offersByAir : t.offersByCoach;
  String transportLongFor(AppLocalizations t) =>
      isByAir ? t.offerDetailReturnFlightsEconomy : t.offerDetailLuxuryCoach;

  String mealsLabelFor(AppLocalizations t) => mealsLabel(meals, t);

  // `meals` is stored as one of a fixed set of English values (see
  // add_edit_offer_screen.dart's meal options) — translate the known ones,
  // and fall back to the raw value for anything else (e.g. legacy/free text).
  static String mealsLabel(String meals, AppLocalizations t) {
    switch (meals) {
      case 'Breakfast':
        return t.mealsBreakfast;
      case 'Half board':
        return t.mealsHalfBoard;
      case 'Full board':
        return t.mealsFullBoard;
      default:
        return meals;
    }
  }

  String get starGlyph => '★' * acc + '☆' * (5 - acc);

  String get priceFmt => fmtIqd(price);
  String get originalFmt => fmtIqd(original);

  Offer copyWith({String? imageUrl}) => Offer(
    id: id,
    companyId: companyId,
    title: title,
    titleAr: titleAr,
    titleEn: titleEn,
    overview: overview,
    city: city,
    cityCode: cityCode,
    transport: transport,
    acc: acc,
    days: days,
    nights: nights,
    price: price,
    original: original,
    rating: rating,
    reviews: reviews,
    hotel: hotel,
    hotelMakkahDescription: hotelMakkahDescription,
    hotelMadinahDescription: hotelMadinahDescription,
    distance: distance,
    room: room,
    roomOccupancies: roomOccupancies,
    meals: meals,
    carrier: carrier,
    badge: badge,
    imageUrl: imageUrl ?? this.imageUrl,
    isFeatured: isFeatured,
    gradColors: gradColors,
    customItinerary: customItinerary,
    customIncludes: customIncludes,
    overviewAr: overviewAr,
    overviewEn: overviewEn,
    packageTier: packageTier,
    groupType: groupType,
    seasonTag: seasonTag,
    pricing: pricing,
    hotels: hotels,
    inclusions: inclusions,
    departureAirport: departureAirport,
    airlineName: airlineName,
    airlineLogoUrl: airlineLogoUrl,
    flightType: flightType,
    busBetweenCities: busBetweenCities,
    airportTransfers: airportTransfers,
    transportNotes: transportNotes,
    mealsPerDay: mealsPerDay,
    mediaUrls: mediaUrls,
    videoUrl: videoUrl,
    cancellationPolicy: cancellationPolicy,
    cancellationPolicyAr: cancellationPolicyAr,
    cancellationPolicyEn: cancellationPolicyEn,
    depositIqd: depositIqd,
    nonRefundableDeposit: nonRefundableDeposit,
    depositTerms: depositTerms,
    acceptedPaymentMethods: acceptedPaymentMethods,
    lifecycleStatus: lifecycleStatus,
    reviewReason: reviewReason,
    capacity: capacity,
    seatsReserved: seatsReserved,
    departureDate: departureDate,
    returnDate: returnDate,
  );

  Offer asDuplicateDraft() => Offer(
    id: '',
    companyId: companyId,
    title: title,
    titleAr: titleAr,
    titleEn: titleEn,
    overview: overview,
    overviewAr: overviewAr,
    overviewEn: overviewEn,
    city: city,
    cityCode: cityCode,
    transport: transport,
    acc: acc,
    days: days,
    nights: nights,
    price: price,
    original: original,
    rating: rating,
    reviews: reviews,
    hotel: hotel,
    hotelMakkahDescription: hotelMakkahDescription,
    hotelMadinahDescription: hotelMadinahDescription,
    distance: distance,
    room: room,
    roomOccupancies: roomOccupancies,
    meals: meals,
    carrier: carrier,
    badge: badge,
    imageUrl: imageUrl,
    gradColors: gradColors,
    customItinerary: customItinerary,
    customIncludes: customIncludes,
    lifecycleStatus: 'draft',
    packageTier: packageTier,
    groupType: groupType,
    seasonTag: seasonTag,
    pricing: pricing,
    hotels: hotels,
    inclusions: inclusions,
    departureAirport: departureAirport,
    airlineName: airlineName,
    airlineLogoUrl: airlineLogoUrl,
    flightType: flightType,
    busBetweenCities: busBetweenCities,
    airportTransfers: airportTransfers,
    transportNotes: transportNotes,
    mealsPerDay: mealsPerDay,
    mediaUrls: mediaUrls,
    videoUrl: videoUrl,
    cancellationPolicy: cancellationPolicy,
    cancellationPolicyAr: cancellationPolicyAr,
    cancellationPolicyEn: cancellationPolicyEn,
    depositIqd: depositIqd,
    nonRefundableDeposit: nonRefundableDeposit,
    depositTerms: depositTerms,
    acceptedPaymentMethods: acceptedPaymentMethods,
  );

  factory Offer.fromRow(Map<String, dynamic> r, {Company? company}) {
    final tint = company?.tint ?? const Color(0xFF0F5C4D);
    final dark = Color.alphaBlend(Colors.black.withOpacity(0.55), tint);
    final itinRows = (r['itinerary_days'] as List?) ?? const [];
    final itinerary =
        itinRows
            .map(
              (d) => MapEntry(
                (d['day_no'] ?? 0) as int,
                d as Map<String, dynamic>,
              ),
            )
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final pricing =
        ((r['offer_pricing'] as List?) ?? const [])
            .map((row) => OfferPrice.fromRow(row as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.occupancy.compareTo(b.occupancy));
    final hotels = ((r['offer_hotels'] as List?) ?? const [])
        .map((row) => OfferHotel.fromRow(row as Map<String, dynamic>))
        .toList();
    final inclusions = ((r['offer_inclusions'] as List?) ?? const [])
        .map((row) => OfferInclusion.fromRow(row as Map<String, dynamic>))
        .toList();
    final media = ((r['offer_media'] as List?) ?? const [])
        .where((row) => (row as Map<String, dynamic>)['media_type'] == 'photo')
        .map((row) => (row as Map<String, dynamic>)['url'] as String)
        .toList();
    return Offer(
      id: r['id'] as String,
      companyId: r['company_id'] as String,
      title: (r['title'] ?? '') as String,
      titleAr: r['title_ar'] as String?,
      titleEn: r['title_en'] as String?,
      overview: (r['overview'] ?? '') as String,
      overviewAr: r['overview_ar'] as String?,
      overviewEn: r['overview_en'] as String?,
      transport: (r['transport'] ?? 'plane') as String,
      acc: (r['acc_stars'] ?? 3) as int,
      days: (r['days'] ?? 7) as int,
      nights: (r['nights'] ?? ((r['days'] ?? 7) as int) - 1) as int,
      price: ((r['price_iqd'] ?? 0) as num).toDouble(),
      original: ((r['original_iqd'] ?? 0) as num?)?.toDouble() ?? 0,
      rating: company?.rating ?? 0,
      reviews: company?.reviews ?? 0,
      hotel: (r['hotel'] ?? '') as String,
      hotelMakkahDescription: (r['hotel_makkah_description'] ?? '') as String,
      hotelMadinahDescription: (r['hotel_madinah_description'] ?? '') as String,
      distance: (r['distance_haram'] ?? '') as String,
      room: (r['room'] ?? '') as String,
      roomOccupancies:
          ((r['room_occupancies'] ?? const [2, 3, 4]) as List)
              .map((value) => (value as num).toInt())
              .toList()
            ..sort(),
      meals: (r['meals'] ?? '') as String,
      carrier: (r['carrier'] ?? '') as String,
      badge: (r['badge'] ?? '') as String,
      imageUrl: r['image_url'] as String?,
      isFeatured: (r['is_featured'] ?? false) as bool,
      lifecycleStatus:
          (r['lifecycle_status'] ??
                  ((r['is_published'] ?? false) == true
                      ? 'published'
                      : 'draft'))
              as String,
      reviewReason: r['review_reason'] as String?,
      capacity: (r['capacity'] as num?)?.toInt(),
      seatsReserved: ((r['seats_reserved'] ?? 0) as num).toInt(),
      departureDate: r['departure_date'] == null
          ? null
          : DateTime.tryParse(r['departure_date'] as String),
      returnDate: r['return_date'] == null
          ? null
          : DateTime.tryParse(r['return_date'] as String),
      gradColors: [tint, dark],
      customItinerary: itinerary.isEmpty
          ? null
          : itinerary
                .map(
                  (e) => ItineraryDay(
                    'Day ${e.key}',
                    (e.value['title'] ?? '') as String,
                    (e.value['summary'] ?? '') as String,
                  ),
                )
                .toList(),
      customIncludes: ((r['includes'] ?? const []) as List).cast<String>(),
      packageTier: (r['package_tier'] ?? 'standard') as String,
      groupType: (r['group_type'] ?? 'group') as String,
      seasonTag: (r['season_tag'] ?? 'regular') as String,
      pricing: pricing,
      hotels: hotels,
      inclusions: inclusions,
      departureAirport: r['departure_airport'] as String?,
      airlineName: r['airline_name'] as String?,
      airlineLogoUrl: r['airline_logo_url'] as String?,
      flightType: r['flight_type'] as String?,
      busBetweenCities: (r['bus_between_cities'] ?? false) as bool,
      airportTransfers: (r['airport_transfers'] ?? false) as bool,
      transportNotes: (r['transport_notes'] ?? '') as String,
      mealsPerDay: (r['meals_per_day'] as num?)?.toInt(),
      mediaUrls: media,
      videoUrl: r['video_url'] as String?,
      cancellationPolicy: (r['cancellation_policy'] ?? '') as String,
      cancellationPolicyAr: r['cancellation_policy_ar'] as String?,
      cancellationPolicyEn: r['cancellation_policy_en'] as String?,
      depositIqd: ((r['deposit_iqd'] ?? 0) as num).toDouble(),
      nonRefundableDeposit: (r['non_refundable_deposit'] ?? false) as bool,
      depositTerms: (r['deposit_terms'] ?? '') as String,
      acceptedPaymentMethods:
          ((r['accepted_payment_methods'] ?? const ['cash']) as List)
              .cast<String>(),
    );
  }

  List<ItineraryDay> buildItinerary(AppLocalizations t) {
    if (customItinerary != null && customItinerary!.isNotEmpty)
      return customItinerary!;
    final hasTwo = city.contains('·');
    final half = (days / 2).round().clamp(2, days);
    final items = <ItineraryDay>[
      ItineraryDay(
        t.offerFallbackDayLabel(1),
        t.offerFallbackDay1Title,
        t.offerFallbackDay1Summary,
      ),
      ItineraryDay(
        t.offerFallbackDayLabel(2),
        t.offerFallbackDay2Title,
        t.offerFallbackDay2Summary,
      ),
      ItineraryDay(
        t.offerFallbackDayRangeLabel(3, half),
        t.offerFallbackMakkahTitle,
        t.offerFallbackMakkahSummary,
      ),
    ];
    if (hasTwo) {
      items.add(
        ItineraryDay(
          t.offerFallbackDayLabel(half + 1),
          t.offerFallbackMadinahTravelTitle,
          t.offerFallbackMadinahTravelSummary,
        ),
      );
      items.add(
        ItineraryDay(
          t.offerFallbackFinalDaysLabel,
          t.offerFallbackMadinahReturnTitle,
          t.offerFallbackMadinahReturnSummary,
        ),
      );
    } else {
      items.add(
        ItineraryDay(
          t.offerFallbackFinalDaysLabel,
          t.offerFallbackWorshipReturnTitle,
          t.offerFallbackWorshipReturnSummary,
        ),
      );
    }
    return items;
  }

  List<String> buildIncludes(AppLocalizations t) {
    if (customIncludes != null && customIncludes!.isNotEmpty)
      return customIncludes!;
    return [
      t.offerFallbackIncludeVisa,
      isByAir ? t.offerFallbackIncludeFlights : t.offerFallbackIncludeCoach,
      t.offerFallbackIncludeHotel(acc, hotel),
      t.offerFallbackIncludeMeals(mealsLabelFor(t)),
      t.offerFallbackIncludeZiyarah,
      t.offerFallbackIncludeGuide,
    ];
  }
}

class ItineraryDay {
  final String day;
  final String title;
  final String summary;
  const ItineraryDay(this.day, this.title, this.summary);
}
