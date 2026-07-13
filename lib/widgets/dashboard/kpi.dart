import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import 'dashboard_scaffold.dart';

/// Compact IQD for tight stat cells: 1_200_000 → "1.2M", 45_000 → "45K".
String compactIqd(double n) {
  if (n >= 1000000) {
    final m = n / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
  return n.toStringAsFixed(0);
}

/// One dashboard metric: icon chip + value + label. Visual copy of the
/// existing admin overview tiles so nothing changes stylistically.
class KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.25),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTheme.serif(20),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppTheme.sans(
                    10.5,
                    weight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Responsive KPI grid: 2 columns on mobile, 4 across when the content area
/// is wide enough (≥700px inside the 1200px cap).
class KpiGrid extends StatelessWidget {
  final List<KpiCard> cards;
  const KpiGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: kDashPagePad),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = constraints.maxWidth >= 700 ? 4 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              childAspectRatio: 1.85,
              crossAxisSpacing: kDashCardGap,
              mainAxisSpacing: kDashCardGap,
            ),
            itemBuilder: (_, i) => cards[i],
          );
        },
      ),
    );
  }
}

/// Horizontally scrolling KPI strip (used on the agency overview where the
/// prompt calls for a swipeable row on mobile).
class KpiRow extends StatelessWidget {
  final List<KpiCard> cards;
  const KpiRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: kDashPagePad,
        ),
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: kDashCardGap),
        itemBuilder: (_, i) => SizedBox(width: 168, child: cards[i]),
      ),
    );
  }
}
