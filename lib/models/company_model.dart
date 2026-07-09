import 'package:flutter/material.dart';

class Company {
  final String id;
  final String ownerId;
  final String name; // Kurdish (base)
  final String? nameAr;
  final String? nameEn;
  String location;
  int since;
  final double rating;
  final int reviews;
  String about;
  List<String> tags;
  final bool isVerified;
  final Color tint;
  String? logoUrl;
  String? bannerUrl;

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
    this.bannerUrl,
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

  // Agency tints come straight from the database with no in-app color
  // picker to constrain them. Snapping to the nearest of these curated,
  // brand-harmonious hues keeps every company card in tune with the
  // emerald/gold palette instead of risking an arbitrary clashing color.
  static const List<Color> curatedTints = [
    Color(0xFF0F5C4D), // emerald (default)
    Color(0xFF1F6E8C), // teal-blue
    Color(0xFF3D5A3D), // olive green
    Color(0xFF6B4226), // warm brown
    Color(0xFF8C6A1F), // antique gold-brown
    Color(0xFF7A3B69), // muted plum
    Color(0xFF7A3B3B), // muted brick red
  ];

  static Color parseTint(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF0F5C4D);
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    final parsed = Color(int.tryParse(h, radix: 16) ?? 0xFF0F5C4D);
    return _nearestCuratedTint(parsed);
  }

  static Color _nearestCuratedTint(Color color) {
    var closest = curatedTints.first;
    var bestDist = double.infinity;
    for (final c in curatedTints) {
      final dr = c.r - color.r;
      final dg = c.g - color.g;
      final db = c.b - color.b;
      final dist = dr * dr + dg * dg + db * db;
      if (dist < bestDist) {
        bestDist = dist;
        closest = c;
      }
    }
    return closest;
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
        bannerUrl: r['banner_url'] as String?,
      );
}
