import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import 'dashboard_scaffold.dart';

/// One "needs attention" alert: count + label on a softly tinted card that
/// deep-links to the list it summarizes. Same tint language as the old
/// admin attention banner.
class AttentionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const AttentionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.color = AppColors.gold,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: AppTheme.serif(18)),
                Text(
                  label,
                  style: AppTheme.sans(
                    11,
                    weight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.muted,
            size: 13,
          ),
        ],
      ),
    ),
  );
}

/// Horizontal strip of attention cards.
class AttentionRow extends StatelessWidget {
  final List<AttentionCard> cards;
  const AttentionRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 86,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: kDashPagePad),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(width: kDashCardGap),
      itemBuilder: (_, i) => cards[i],
    ),
  );
}
