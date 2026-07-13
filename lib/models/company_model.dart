import 'package:flutter/material.dart';

class AgencyBadge {
  final String key;
  final String nameKu;
  final String nameAr;
  final String nameEn;
  final String icon;
  final String type;

  const AgencyBadge({
    required this.key,
    required this.nameKu,
    required this.nameAr,
    required this.nameEn,
    required this.icon,
    required this.type,
  });

  String nameFor(String lang) {
    if (lang == 'en') return nameEn;
    if (lang == 'ar') return nameAr;
    return nameKu;
  }

  factory AgencyBadge.fromRow(Map<String, dynamic> row) => AgencyBadge(
    key: (row['key'] ?? '') as String,
    nameKu: (row['name_ku'] ?? row['name_en'] ?? '') as String,
    nameAr: (row['name_ar'] ?? row['name_en'] ?? '') as String,
    nameEn: (row['name_en'] ?? '') as String,
    icon: (row['icon'] ?? 'verified') as String,
    type: (row['type'] ?? 'auto') as String,
  );
}

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
  String? aboutAr;
  String? aboutEn;
  List<String> tags;
  final bool isVerified;
  final bool isPromoted;
  final String verificationStatus;
  final String? verificationReason;
  final Color tint;
  String? logoUrl;
  String? bannerUrl;
  final String status;
  final bool firstOfferApproved;
  final String? licenseNumber;
  final String? officeAddress;
  final String? phone;
  final String? whatsapp;
  final String? officeHours;
  final List<String> branches;
  final List<String> galleryUrls;
  final String? introVideoUrl;
  final String cancellationPolicy;
  final String? cancellationPolicyAr;
  final String? cancellationPolicyEn;
  final List<String> acceptedPaymentMethods;
  final int pilgrimsServed;
  final int? medianResponseMinutes;
  final List<String> verificationDetails;
  final DateTime? createdAt;
  final List<AgencyBadge> badges;

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
    this.aboutAr,
    this.aboutEn,
    this.tags = const [],
    this.isVerified = false,
    this.isPromoted = false,
    this.verificationStatus = 'draft',
    this.verificationReason,
    this.tint = const Color(0xFF0F5C4D),
    this.logoUrl,
    this.bannerUrl,
    this.status = 'pending',
    this.firstOfferApproved = false,
    this.licenseNumber,
    this.officeAddress,
    this.phone,
    this.whatsapp,
    this.officeHours,
    this.branches = const [],
    this.galleryUrls = const [],
    this.introVideoUrl,
    this.cancellationPolicy = '',
    this.cancellationPolicyAr,
    this.cancellationPolicyEn,
    this.acceptedPaymentMethods = const ['cash'],
    this.pilgrimsServed = 0,
    this.medianResponseMinutes,
    this.verificationDetails = const [],
    this.createdAt,
    this.badges = const [],
  });

  String nameFor(String lang) {
    if (lang == 'en' && (nameEn ?? '').isNotEmpty) return nameEn!;
    if (lang == 'ar' && (nameAr ?? '').isNotEmpty) return nameAr!;
    return name;
  }

  String aboutFor(String lang) {
    if (lang == 'en' && (aboutEn ?? '').isNotEmpty) return aboutEn!;
    if (lang == 'ar' && (aboutAr ?? '').isNotEmpty) return aboutAr!;
    return about;
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

  bool get isActive =>
      isVerified && status != 'suspended' && status != 'rejected';

  String get responseTimeLabel {
    final minutes = medianResponseMinutes;
    if (minutes == null) return '';
    if (minutes < 60) return '$minutes min';
    return '${(minutes / 60).ceil()} h';
  }

  /// Two-letter monogram for the avatar tile, from the English name when
  /// available so it renders in any locale.
  String get mono {
    final source = (nameEn ?? '').isNotEmpty ? nameEn! : name;
    if (source.trim().isEmpty) return '—';
    final words = source.trim().split(RegExp(r'\s+'));
    if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return source.substring(0, source.length >= 2 ? 2 : 1).toUpperCase();
  }

  static const List<Color> curatedTints = [
    Color(0xFF0F5C4D),
    Color(0xFF1F6E8C),
    Color(0xFF3D5A3D),
    Color(0xFF6B4226),
    Color(0xFF8C6A1F),
    Color(0xFF7A3B69),
    Color(0xFF7A3B3B),
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

  factory Company.fromRow(Map<String, dynamic> r) {
    final badgeRows = (r['agency_badges'] as List?) ?? const [];
    final parsedBadges = badgeRows
        .map((entry) {
          final row = entry as Map<String, dynamic>;
          final nested = row['badges'];
          return AgencyBadge.fromRow(
            nested is Map<String, dynamic> ? nested : row,
          );
        })
        .where((badge) => badge.key.isNotEmpty)
        .toList();
    return Company(
      id: r['id'] as String,
      ownerId: (r['owner_id'] ?? '') as String,
      name: (r['name'] ?? '') as String,
      nameAr: r['name_ar'] as String?,
      nameEn: r['name_en'] as String?,
      location: (r['location'] ?? '') as String,
      since: ((r['since'] ?? 2020) as num).toInt(),
      rating: ((r['rating'] ?? 0) as num).toDouble(),
      reviews: ((r['reviews'] ?? 0) as num).toInt(),
      about: (r['about'] ?? '') as String,
      aboutAr: r['about_ar'] as String?,
      aboutEn: r['about_en'] as String?,
      tags: ((r['tags'] ?? const []) as List).cast<String>(),
      isVerified: (r['is_verified'] ?? false) as bool,
      isPromoted: (r['is_promoted'] ?? false) as bool,
      verificationStatus:
          (r['verification_status'] ??
                  ((r['is_verified'] ?? false) == true
                      ? 'approved'
                      : 'pending'))
              as String,
      verificationReason: r['verification_reason'] as String?,
      tint: parseTint(r['tint'] as String?),
      logoUrl: r['logo_url'] as String?,
      bannerUrl: r['banner_url'] as String?,
      status:
          (r['status'] ??
                  ((r['verification_status'] ?? '') == 'approved'
                      ? 'active'
                      : 'pending'))
              as String,
      firstOfferApproved: (r['first_offer_approved'] ?? false) as bool,
      licenseNumber: r['license_number'] as String?,
      officeAddress: r['office_address'] as String?,
      phone: r['phone'] as String?,
      whatsapp: r['whatsapp'] as String?,
      officeHours: r['office_hours'] as String?,
      branches: ((r['branches'] ?? const []) as List)
          .map((value) => value is String ? value : value.toString())
          .toList(),
      galleryUrls: ((r['gallery_urls'] ?? const []) as List).cast<String>(),
      introVideoUrl: r['intro_video_url'] as String?,
      cancellationPolicy: (r['cancellation_policy'] ?? '') as String,
      cancellationPolicyAr: r['cancellation_policy_ar'] as String?,
      cancellationPolicyEn: r['cancellation_policy_en'] as String?,
      acceptedPaymentMethods:
          ((r['accepted_payment_methods'] ?? const ['cash']) as List)
              .cast<String>(),
      pilgrimsServed: ((r['pilgrims_served'] ?? 0) as num).toInt(),
      medianResponseMinutes: (r['median_response_minutes'] as num?)?.toInt(),
      verificationDetails: ((r['verification_details'] ?? const []) as List)
          .cast<String>(),
      createdAt: r['created_at'] == null
          ? null
          : DateTime.tryParse(r['created_at'] as String),
      badges: parsedBadges,
    );
  }
}
