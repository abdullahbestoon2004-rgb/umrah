import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';

class DashboardDestination {
  final IconData icon;
  final String label;
  final int badge;
  const DashboardDestination({
    required this.icon,
    required this.label,
    this.badge = 0,
  });
}

/// Navigation shell shared by both dashboards. Mobile gets the app's bottom
/// nav; widths over 900px get a NavigationRail (extended past 1200px) with the
/// content column capped at 1200 and centered. Pages live in an IndexedStack
/// so each tab keeps its state across switches.
class DashboardShell extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final List<DashboardDestination> destinations;
  final List<Widget> pages;

  const DashboardShell({
    super.key,
    required this.index,
    required this.onSelect,
    required this.destinations,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final body = IndexedStack(index: index, children: pages);
        if (constraints.maxWidth <= 900) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: body,
            bottomNavigationBar: _BottomBar(
              destinations: destinations,
              index: index,
              onSelect: onSelect,
            ),
          );
        }
        final extended = constraints.maxWidth > 1200;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              NavigationRail(
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.primary.withOpacity(0.12),
                extended: extended,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                selectedIndex: index,
                onDestinationSelected: onSelect,
                selectedIconTheme:
                    const IconThemeData(color: AppColors.primary, size: 24),
                unselectedIconTheme:
                    const IconThemeData(color: AppColors.mutedLight, size: 24),
                selectedLabelTextStyle: AppTheme.sans(12.5,
                    weight: FontWeight.w700, color: AppColors.primary),
                unselectedLabelTextStyle: AppTheme.sans(12.5,
                    weight: FontWeight.w600, color: AppColors.muted),
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: _BadgedIcon(destination: d, active: false),
                      selectedIcon: _BadgedIcon(destination: d, active: true),
                      label: Text(d.label),
                    ),
                ],
              ),
              Container(width: 1.5, color: AppColors.border),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Same bottom bar language as the client app's main navigation.
class _BottomBar extends StatelessWidget {
  final List<DashboardDestination> destinations;
  final int index;
  final ValueChanged<int> onSelect;
  const _BottomBar({
    required this.destinations,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.96),
        border: const Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 3, 16, 3),
                          decoration: BoxDecoration(
                            color: i == index
                                ? AppColors.primary.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: _BadgedIcon(
                            destination: destinations[i],
                            active: i == index,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          destinations[i].label,
                          style: AppTheme.sans(10,
                              weight: FontWeight.w700,
                              color: i == index
                                  ? AppColors.primary
                                  : AppColors.mutedLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  final DashboardDestination destination;
  final bool active;
  const _BadgedIcon({required this.destination, required this.active});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      destination.icon,
      color: active ? AppColors.primary : AppColors.mutedLight,
      size: 24,
    );
    if (destination.badge <= 0) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        PositionedDirectional(
          end: -7,
          top: -5,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration:
                const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '${destination.badge}',
              textAlign: TextAlign.center,
              style: AppTheme.sans(9,
                  weight: FontWeight.w800, color: const Color(0xFF1C2317)),
            ),
          ),
        ),
      ],
    );
  }
}
