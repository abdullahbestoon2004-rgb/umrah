import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../data/sample_data.dart';
import '../../models/offer_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/tag_chip.dart';
import 'offer_detail_screen.dart';
import 'filter_sheet.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _OffersHeader(),
            _QuickChips(),
            _SortRow(),
            Expanded(child: _OffersList()),
          ],
        ),
      ),
    );
  }
}

class _OffersHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final count = provider.getFilteredOffers().length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Offers', style: AppTheme.serif(30)),
                Text('$count packages match', style: AppTheme.sans(13, color: const Color(0xFF7D8A82))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ChangeNotifierProvider.value(value: provider, child: const FilterSheet()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, color: Color(0xFFF6F2E9), size: 16),
                  const SizedBox(width: 7),
                  Text('Filters', style: AppTheme.sans(13, weight: FontWeight.w700, color: const Color(0xFFF6F2E9))),
                  if (provider.filters.hasActiveFilters) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${provider.filters.activeCount}',
                        style: AppTheme.sans(11, weight: FontWeight.w800, color: const Color(0xFF1C2317)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final f = provider.filters;

    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
        children: [
          TagChip(label: 'All', active: f.transport == 'all' && f.acc == 'all', onTap: () => provider.resetFilters()),
          const SizedBox(width: 9),
          TagChip(
            label: 'By Air',
            icon: Icons.flight_rounded,
            active: f.transport == 'plane',
            onTap: () => provider.updateFilters(f.copyWith(transport: f.transport == 'plane' ? 'all' : 'plane')),
          ),
          const SizedBox(width: 9),
          TagChip(
            label: 'By Coach',
            icon: Icons.directions_bus_rounded,
            active: f.transport == 'bus',
            onTap: () => provider.updateFilters(f.copyWith(transport: f.transport == 'bus' ? 'all' : 'bus')),
          ),
          const SizedBox(width: 9),
          TagChip(
            label: '5 Star',
            icon: Icons.star_rounded,
            active: f.acc == '5',
            onTap: () => provider.updateFilters(f.copyWith(acc: f.acc == '5' ? 'all' : '5')),
          ),
          const SizedBox(width: 9),
          TagChip(
            label: '4 Star',
            icon: Icons.star_rounded,
            active: f.acc == '4',
            onTap: () => provider.updateFilters(f.copyWith(acc: f.acc == '4' ? 'all' : '4')),
          ),
        ],
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final sort = provider.filters.sort;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 4),
      child: Row(
        children: [
          Text('Sort', style: AppTheme.sans(12, weight: FontWeight.w600, color: AppColors.muted)),
          const SizedBox(width: 8),
          _SortBtn(label: 'Popular', value: 'popular', current: sort,
              onTap: () => provider.updateFilters(provider.filters.copyWith(sort: 'popular'))),
          const SizedBox(width: 6),
          _SortBtn(label: 'Price ↑', value: 'low', current: sort,
              onTap: () => provider.updateFilters(provider.filters.copyWith(sort: 'low'))),
          const SizedBox(width: 6),
          _SortBtn(label: 'Price ↓', value: 'high', current: sort,
              onTap: () => provider.updateFilters(provider.filters.copyWith(sort: 'high'))),
        ],
      ),
    );
  }
}

class _SortBtn extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final VoidCallback onTap;
  const _SortBtn({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEF4F0) : AppColors.chipBg,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? AppColors.primary.withOpacity(0.3) : AppColors.primary.withOpacity(0.12),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.sans(12, weight: FontWeight.w700, color: active ? AppColors.primary : AppColors.ink),
        ),
      ),
    );
  }
}

class _OffersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final offers = provider.getFilteredOffers();

    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No matches', style: AppTheme.serif(22)),
            const SizedBox(height: 6),
            Text('Try widening your filters.', style: AppTheme.sans(13, color: AppColors.muted)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => provider.resetFilters(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: Text('Reset filters', style: AppTheme.sans(13, weight: FontWeight.w700, color: const Color(0xFFF6F2E9))),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 15),
      itemBuilder: (context, i) => OfferCard(offer: offers[i]),
    );
  }
}

class OfferCard extends StatelessWidget {
  final Offer offer;
  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final saved = provider.isSaved(offer.id);
    final company = sampleCompanies.firstWhere((c) => c.id == offer.companyId);

    final imageBytes = provider.getOfferImage(offer.id);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F3729).withOpacity(0.07), blurRadius: 30, offset: const Offset(0, 14)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
              child: SizedBox(
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageBytes != null)
                      Image.memory(imageBytes, fit: BoxFit.cover)
                    else
                      GradientCard(
                        colors: offer.gradColors,
                        height: 140,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, const Color(0xFF071C17).withOpacity(0.55)],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    if (offer.badge.isNotEmpty)
                      Positioned(
                        left: 14,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            offer.badge.toUpperCase(),
                            style: AppTheme.sans(10, weight: FontWeight.w800, color: const Color(0xFF1C2317))
                                .copyWith(letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: GestureDetector(
                        onTap: () => provider.toggleSave(offer.id),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: AppColors.primary,
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 11,
                      right: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(company.name,
                              style: AppTheme.sans(10.5, weight: FontWeight.w700, color: const Color(0xFFE7CF95))),
                          const SizedBox(height: 1),
                          Text(offer.title, style: AppTheme.serif(21, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // details
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      InfoChip(
                        label: '${offer.days} days',
                        icon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 13),
                      ),
                      InfoChip(label: offer.transportLabel),
                      InfoChip(label: '${offer.acc}-Star'),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StarRating(rating: offer.rating, reviews: offer.reviews),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (offer.hasDiscount)
                            Text(
                              offer.originalFmt,
                              style: AppTheme.sans(12, color: AppColors.errorRed)
                                  .copyWith(decoration: TextDecoration.lineThrough),
                            ),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(text: 'from ', style: AppTheme.sans(11, color: AppColors.muted)),
                              TextSpan(text: offer.priceFmt, style: AppTheme.serif(23, color: AppColors.primary)),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
