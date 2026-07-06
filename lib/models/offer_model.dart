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
  final String distance;
  final String room;
  final String meals;
  final String carrier;
  final String badge;
  final String? imageUrl;
  final bool isFeatured;
  final List<Color> gradColors;
  final List<ItineraryDay>? customItinerary;
  final List<String>? customIncludes;

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
    this.distance = '',
    this.room = '',
    this.meals = '',
    this.carrier = '',
    this.badge = '',
    this.imageUrl,
    this.isFeatured = false,
    required this.gradColors,
    this.customItinerary,
    this.customIncludes,
  }) : nights = nights ?? days - 1;

  String titleFor(String lang) {
    if (lang == 'en' && (titleEn ?? '').isNotEmpty) return titleEn!;
    if (lang == 'ar' && (titleAr ?? '').isNotEmpty) return titleAr!;
    return title;
  }

  bool get hasDiscount => original > 0;
  bool get isByAir => transport == 'plane';

  String transportLabelFor(AppLocalizations t) => isByAir ? t.offersByAir : t.offersByCoach;
  String transportLongFor(AppLocalizations t) =>
      isByAir ? t.offerDetailReturnFlightsEconomy : t.offerDetailLuxuryCoach;

  String mealsLabelFor(AppLocalizations t) => mealsLabel(meals, t);

  // `meals` is stored as one of a fixed set of English values (see
  // add_edit_offer_screen.dart's meal options) — translate the known ones,
  // and fall back to the raw value for anything else (e.g. legacy/free text).
  static String mealsLabel(String meals, AppLocalizations t) {
    switch (meals) {
      case 'Breakfast': return t.mealsBreakfast;
      case 'Half board': return t.mealsHalfBoard;
      case 'Full board': return t.mealsFullBoard;
      default: return meals;
    }
  }

  String get starGlyph => '★' * acc + '☆' * (5 - acc);

  String get priceFmt => fmtIqd(price);
  String get originalFmt => fmtIqd(original);

  Offer copyWith({String? imageUrl}) => Offer(
        id: id, companyId: companyId, title: title, titleAr: titleAr, titleEn: titleEn,
        overview: overview, city: city, cityCode: cityCode, transport: transport,
        acc: acc, days: days, nights: nights, price: price, original: original,
        rating: rating, reviews: reviews, hotel: hotel, distance: distance, room: room,
        meals: meals, carrier: carrier, badge: badge, imageUrl: imageUrl ?? this.imageUrl,
        isFeatured: isFeatured, gradColors: gradColors, customItinerary: customItinerary,
        customIncludes: customIncludes,
      );

  factory Offer.fromRow(Map<String, dynamic> r, {Company? company}) {
    final tint = company?.tint ?? const Color(0xFF0F5C4D);
    final dark = Color.alphaBlend(Colors.black.withOpacity(0.55), tint);
    final itinRows = (r['itinerary_days'] as List?) ?? const [];
    final itinerary = itinRows
        .map((d) => MapEntry((d['day_no'] ?? 0) as int, d as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Offer(
      id: r['id'] as String,
      companyId: r['company_id'] as String,
      title: (r['title'] ?? '') as String,
      titleAr: r['title_ar'] as String?,
      titleEn: r['title_en'] as String?,
      overview: (r['overview'] ?? '') as String,
      transport: (r['transport'] ?? 'plane') as String,
      acc: (r['acc_stars'] ?? 3) as int,
      days: (r['days'] ?? 7) as int,
      nights: (r['nights'] ?? ((r['days'] ?? 7) as int) - 1) as int,
      price: ((r['price_iqd'] ?? 0) as num).toDouble(),
      original: ((r['original_iqd'] ?? 0) as num?)?.toDouble() ?? 0,
      rating: company?.rating ?? 0,
      reviews: company?.reviews ?? 0,
      hotel: (r['hotel'] ?? '') as String,
      distance: (r['distance_haram'] ?? '') as String,
      room: (r['room'] ?? '') as String,
      meals: (r['meals'] ?? '') as String,
      carrier: (r['carrier'] ?? '') as String,
      badge: (r['badge'] ?? '') as String,
      imageUrl: r['image_url'] as String?,
      isFeatured: (r['is_featured'] ?? false) as bool,
      gradColors: [tint, dark],
      customItinerary: itinerary.isEmpty
          ? null
          : itinerary
              .map((e) => ItineraryDay(
                    'Day ${e.key}',
                    (e.value['title'] ?? '') as String,
                    (e.value['summary'] ?? '') as String,
                  ))
              .toList(),
      customIncludes: ((r['includes'] ?? const []) as List).cast<String>(),
    );
  }

  List<ItineraryDay> buildItinerary(AppLocalizations t) {
    if (customItinerary != null && customItinerary!.isNotEmpty) return customItinerary!;
    final hasTwo = city.contains('·');
    final half = (days / 2).round().clamp(2, days);
    final items = <ItineraryDay>[
      ItineraryDay(t.offerFallbackDayLabel(1), t.offerFallbackDay1Title, t.offerFallbackDay1Summary),
      ItineraryDay(t.offerFallbackDayLabel(2), t.offerFallbackDay2Title, t.offerFallbackDay2Summary),
      ItineraryDay(t.offerFallbackDayRangeLabel(3, half), t.offerFallbackMakkahTitle, t.offerFallbackMakkahSummary),
    ];
    if (hasTwo) {
      items.add(ItineraryDay(
          t.offerFallbackDayLabel(half + 1), t.offerFallbackMadinahTravelTitle, t.offerFallbackMadinahTravelSummary));
      items.add(ItineraryDay(
          t.offerFallbackFinalDaysLabel, t.offerFallbackMadinahReturnTitle, t.offerFallbackMadinahReturnSummary));
    } else {
      items.add(ItineraryDay(
          t.offerFallbackFinalDaysLabel, t.offerFallbackWorshipReturnTitle, t.offerFallbackWorshipReturnSummary));
    }
    return items;
  }

  List<String> buildIncludes(AppLocalizations t) {
    if (customIncludes != null && customIncludes!.isNotEmpty) return customIncludes!;
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
