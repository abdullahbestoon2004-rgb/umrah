import 'package:flutter/material.dart';

class Offer {
  final String id;
  final String companyId;
  final String title;
  final String city;
  final String cityCode;
  final String transport;
  final int acc;
  final int days;
  final double price;
  final double original;
  final double rating;
  final int reviews;
  final String hotel;
  final String distance;
  final String room;
  final String meals;
  final String carrier;
  final String badge;
  final List<Color> gradColors;
  final List<ItineraryDay>? customItinerary;
  final List<String>? customIncludes;

  const Offer({
    required this.id,
    required this.companyId,
    required this.title,
    required this.city,
    required this.cityCode,
    required this.transport,
    required this.acc,
    required this.days,
    required this.price,
    required this.original,
    required this.rating,
    required this.reviews,
    required this.hotel,
    required this.distance,
    required this.room,
    required this.meals,
    required this.carrier,
    required this.badge,
    required this.gradColors,
    this.customItinerary,
    this.customIncludes,
  });

  int get nights => days - 1;
  bool get hasDiscount => original > 0;
  bool get isByAir => transport == 'plane';

  String get transportLabel => isByAir ? 'By Air' : 'By Coach';
  String get transportLong => isByAir ? 'Return flights, economy' : 'Luxury air-conditioned coach';

  String get starGlyph {
    return '★' * acc + '☆' * (5 - acc);
  }

  String get priceFmt => '\$${price.round()}';
  String get originalFmt => '\$${original.round()}';

  List<ItineraryDay> buildItinerary() {
    if (customItinerary != null && customItinerary!.isNotEmpty) return customItinerary!;
    final hasTwo = city.contains('·');
    final half = (days / 2).round().clamp(2, days);
    final items = <ItineraryDay>[
      const ItineraryDay('Day 1', 'Arrival & transfer',
          'Arrive in Jeddah, met by your guide, and transfer to your hotel near the Haram.'),
      const ItineraryDay('Day 2', 'Perform Umrah',
          "Guided Umrah — Tawaf, Sa’i and Tahallul accompanied by your group scholar."),
      ItineraryDay('Days 3–$half', 'Worship in Makkah',
          'Prayers at Masjid al-Haram with optional ziyarah to Mina, Arafah and historic sites.'),
    ];
    if (hasTwo) {
      items.add(ItineraryDay('Day ${half + 1}', 'Travel to Madinah',
          "High-speed transfer to Madinah and check-in steps from the Prophet’s Mosque."));
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
