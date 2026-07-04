import 'package:flutter/material.dart';
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

  String get transportLabel => isByAir ? 'By Air' : 'By Coach';
  String get transportLong => isByAir ? 'Return flights, economy' : 'Luxury air-conditioned coach';

  String get starGlyph => '★' * acc + '☆' * (5 - acc);

  String get priceFmt => fmtIqd(price);
  String get originalFmt => fmtIqd(original);

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

  List<ItineraryDay> buildItinerary() {
    if (customItinerary != null && customItinerary!.isNotEmpty) return customItinerary!;
    final hasTwo = city.contains('·');
    final half = (days / 2).round().clamp(2, days);
    final items = <ItineraryDay>[
      const ItineraryDay('Day 1', 'Arrival & transfer',
          'Arrive in Jeddah, met by your guide, and transfer to your hotel near the Haram.'),
      const ItineraryDay('Day 2', 'Perform Umrah',
          "Guided Umrah — Tawaf, Sa'i and Tahallul accompanied by your group scholar."),
      ItineraryDay('Days 3–$half', 'Worship in Makkah',
          'Prayers at Masjid al-Haram with optional ziyarah to Mina, Arafah and historic sites.'),
    ];
    if (hasTwo) {
      items.add(ItineraryDay('Day ${half + 1}', 'Travel to Madinah',
          "High-speed transfer to Madinah and check-in steps from the Prophet's Mosque."));
      items.add(const ItineraryDay('Final days', 'Madinah & return',
          'Worship at Masjid an-Nabawi, ziyarah tours, then transfer for your homeward journey.'));
    } else {
      items.add(const ItineraryDay('Final days', 'Worship & return',
          'Final prayers and Tawaf al-Wada, then transfer to the airport for departure.'));
    }
    return items;
  }

  List<String> buildIncludes() {
    if (customIncludes != null && customIncludes!.isNotEmpty) return customIncludes!;
    return [
      'Umrah visa & processing',
      isByAir ? 'Return international flights' : 'Air-conditioned coach transfers',
      '$acc-star hotel — $hotel',
      '$meals dining daily',
      'Guided ziyarah tours',
      '24/7 multilingual group guide',
    ];
  }
}

class ItineraryDay {
  final String day;
  final String title;
  final String summary;
  const ItineraryDay(this.day, this.title, this.summary);
}
