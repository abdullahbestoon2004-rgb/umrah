/// A paid agency placement shown in the home-screen carousel.
class HomeAd {
  final String id;
  final String? companyId;
  final String? packageId; // tapping the ad opens this offer, when set
  final String title; // Kurdish (base)
  final String? titleAr;
  final String? titleEn;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const HomeAd({
    required this.id,
    this.companyId,
    this.packageId,
    required this.title,
    this.titleAr,
    this.titleEn,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  String titleFor(String lang) {
    if (lang == 'en' && (titleEn ?? '').isNotEmpty) return titleEn!;
    if (lang == 'ar' && (titleAr ?? '').isNotEmpty) return titleAr!;
    return title;
  }

  factory HomeAd.fromRow(Map<String, dynamic> r) => HomeAd(
    id: r['id'] as String,
    companyId: r['company_id'] as String?,
    packageId: r['package_id'] as String?,
    title: (r['title'] ?? '') as String,
    titleAr: r['title_ar'] as String?,
    titleEn: r['title_en'] as String?,
    imageUrl: r['image_url'] as String?,
    sortOrder: (r['sort_order'] ?? 0) as int,
    isActive: (r['is_active'] ?? true) as bool,
  );
}
