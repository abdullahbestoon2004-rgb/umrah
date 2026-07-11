import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import 'dashboard_scaffold.dart';

/// Dashboard section title: serif title + optional count pill + optional
/// "View all" link or custom trailing action. Owns the standard section
/// spacing so every screen separates sections identically.
class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Color accent;
  final VoidCallback? onViewAll;
  final Widget? trailing;
  final bool firstSection;

  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.accent = AppColors.primary,
    this.onViewAll,
    this.trailing,
    this.firstSection = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          kDashPagePad, firstSection ? kDashCardGap : kDashSectionGap,
          kDashPagePad, kDashCardGap),
      child: Row(
        children: [
          Flexible(
            child: Text(title,
                style: AppTheme.serif(20),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          if ((count ?? 0) > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(9, 3, 9, 3),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: AppTheme.sans(11,
                      weight: FontWeight.w800, color: accent)),
            ),
          ],
          const Spacer(),
          if (trailing != null)
            trailing!
          else if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              behavior: HitTestBehavior.opaque,
              child: Text(t.homeViewAll,
                  style: AppTheme.sans(12.5,
                      weight: FontWeight.w700, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}
