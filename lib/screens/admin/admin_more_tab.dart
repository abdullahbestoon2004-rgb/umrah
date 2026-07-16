import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/entity_list_card.dart';
import '../../widgets/dashboard/section_header.dart';
import '../../l10n/generated/app_localizations.dart';
import 'admin_support_screen.dart';
import 'promote_screen.dart';
import 'home_preview_screen.dart';
import 'admin_finance_tab.dart';

/// Grouped menu of the secondary admin destinations, organized under
/// People / Content / System headers.
class AdminMoreTab extends StatelessWidget {
  const AdminMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final supportCount = provider.supportMessages.length;

    return DashboardScaffold(
      title: t.tabMore,
      slivers: [
        SliverToBoxAdapter(
          child: SectionHeader(title: t.moreGroupPeople, firstSection: true),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              0,
              kDashPagePad,
              kDashCardGap,
            ),
            child: EntityListCard(
              leading: _MenuIcon(
                icon: Icons.mail_outline_rounded,
                color: AppColors.primary,
              ),
              title: t.adminSupportInbox,
              subtitle: t.moreSupportSubtitle,
              trailing: supportCount > 0
                  ? Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(9, 3, 9, 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$supportCount',
                        style: AppTheme.sans(
                          11,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSupportScreen()),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader(title: t.tabContent)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              0,
              kDashPagePad,
              kDashCardGap,
            ),
            child: EntityListCard(
              leading: const _MenuIcon(
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
              title: t.adminCommissionsTitle,
              subtitle: t.adminCommissionsOwedLabel,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminFinanceTab()),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              0,
              kDashPagePad,
              kDashCardGap,
            ),
            child: EntityListCard(
              leading: _MenuIcon(
                icon: Icons.auto_awesome_rounded,
                color: AppColors.gold,
              ),
              title: t.adminPromoteTitle,
              subtitle: t.adminPromoteSubtitle,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PromoteScreen()),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              0,
              kDashPagePad,
              kDashCardGap,
            ),
            child: EntityListCard(
              leading: const _MenuIcon(
                icon: Icons.remove_red_eye_outlined,
                color: Color(0xFF397C74),
              ),
              title: t.contentPreviewHome,
              subtitle: t.morePreviewSubtitle,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePreviewScreen()),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader(title: t.moreGroupSystem)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              0,
              kDashPagePad,
              kDashCardGap,
            ),
            child: EntityListCard(
              leading: const _MenuIcon(
                icon: Icons.logout_rounded,
                color: AppColors.errorRed,
              ),
              title: t.adminSignOut,
              onTap: () {
                context.read<AppProvider>().signOut();
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MenuIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 20),
  );
}
