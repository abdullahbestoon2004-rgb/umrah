import 'package:flutter/material.dart';

class Company {
  final String id;
  final String ownerId;
  final String name; // Kurdish (base)
  final String? nameAr;
  final String? nameEn;
  String location;
  final int since;
  final double rating;
  final int reviews;
  String about;
  List<String> tags;
  final bool isVerified;
  final Color tint;
  final String? logoUrl;

  Company({
    required this.id,
    this.ownerId = '',
    required this.name,
    this.nameAr,
    this.nameEn,
    this.location = '',
    this.since = 2020,
    this.rating = 0,
    this.reviews = 0,
    this.about = '',
    this.tags = const [],
    this.isVerified = false,
    this.tint = const Color(0xFF0F5C4D),
    this.logoUrl,
  });

  String nameFor(String lang) {
    if (lang == 'en' && (nameEn ?? '').isNotEmpty) return nameEn!;
    if (lang == 'ar' && (nameAr ?? '').isNotEmpty) return nameAr!;
    return name;
  }

  /// Two-letter monogram for the avatar tile, from the English name when
  /// available so it renders in any locale.
  String get mono {
    final source = (nameEn ?? '').isNotEmpty ? nameEn! : name;
    final words = source.trim().split(RegExp(r'\s+'));
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return source.substring(0, source.length >= 2 ? 2 : 1).toUpperCase();
  }

  static Color parseTint(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF0F5C4D);
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.tryParse(h, radix: 16) ?? 0xFF0F5C4D);
  }

  factory Company.fromRow(Map<String, dynamic> r) => Company(
        id: r['id'] as String,
        ownerId: (r['owner_id'] ?? '') as String,
        name: (r['name'] ?? '') as String,
        nameAr: r['name_ar'] as String?,
        nameEn: r['name_en'] as String?,
        location: (r['location'] ?? '') as String,
        since: (r['since'] ?? 2020) as int,
        rating: ((r['rating'] ?? 0) as num).toDouble(),
        about: (r['about'] ?? '') as String,
        tags: ((r['tags'] ?? const []) as List).cast<String>(),
        isVerified: (r['is_verified'] ?? false) as bool,
        tint: parseTint(r['tint'] as String?),
        logoUrl: r['logo_url'] as String?,
      );
}
