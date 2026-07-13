import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';

// ── Spacing tokens ────────────────────────────────────────────────────────────
// Every dashboard screen derives its rhythm from these three values instead of
// ad-hoc SizedBoxes: page edge inset, gap between sections, gap between cards.
const double kDashPagePad = 22;
const double kDashSectionGap = 26;
const double kDashCardGap = 10;

/// Standard dashboard page anatomy shared by the admin and agency dashboards:
/// title row (title + optional leading/trailing action) → optional pinned
/// filter bar → optional summary strip → body slivers, with pull-to-refresh.
class DashboardScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? filterBar;
  final double filterBarHeight;
  final Widget? summary;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  final Widget? floatingAction;

  const DashboardScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.filterBar,
    this.filterBarHeight = 46,
    this.summary,
    this.slivers = const [],
    this.onRefresh,
    this.floatingAction,
  });

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              14,
              kDashPagePad,
              12,
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 14)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.serif(24)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: AppTheme.sans(12, color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        if (filterBar != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedBar(height: filterBarHeight, child: filterBar!),
          ),
        if (summary != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                kDashPagePad,
                kDashCardGap,
                kDashPagePad,
                0,
              ),
              child: summary!,
            ),
          ),
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 90)),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingAction,
      body: SafeArea(
        bottom: false,
        child: onRefresh == null
            ? scroll
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: onRefresh!,
                child: scroll,
              ),
      ),
    );
  }
}

/// Round bordered icon button used in dashboard title rows (back, actions) —
/// same 42×42 surface tile used across the existing screens.
class DashIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const DashIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Icon(icon, size: 18, color: AppColors.ink),
    ),
  );
}

class _PinnedBar extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _PinnedBar({required this.height, required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      Container(
        color: AppColors.background,
        alignment: AlignmentDirectional.centerStart,
        child: child,
      );

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant _PinnedBar old) =>
      old.height != height || old.child != child;
}
