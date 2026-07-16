import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/company_avatar.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/entity_list_card.dart';
import '../../widgets/dashboard/section_header.dart';
import '../../widgets/dashboard/status_chip.dart';
import '../../l10n/generated/app_localizations.dart';
import '../companies/company_detail_screen.dart';
import 'edit_agency_profile_screen.dart';
import 'agency_money_tab.dart';
import 'agency_documents_screen.dart';
import 'agency_management_screen.dart';

/// Agency profile tab: identity card, public-profile actions (edit +
/// "preview my card" as clients see it), and account actions.
class AgencyProfileTab extends StatelessWidget {
  const AgencyProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final company = provider.agencyCompany;
    if (company == null) return const SizedBox.shrink();
    final lang = Localizations.localeOf(context).languageCode;

    return DashboardScaffold(
      title: t.navProfile,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              kDashCardGap,
              kDashPagePad,
              0,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  CompanyAvatar(
                    mono: company.mono,
                    tint: company.tint,
                    logoUrl: company.logoUrl,
                    size: 56,
                    fontSize: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.nameFor(lang),
                          style: AppTheme.serif(20),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            StatusChip(
                              kind: company.isVerified
                                  ? StatusKind.positive
                                  : StatusKind.pending,
                              label: company.isVerified
                                  ? t.agencyDashboardVerifiedAgency
                                  : t.agencyDashboardPendingVerification,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
                icon: Icons.verified_user_outlined,
                color: Color(0xFF397C74),
              ),
              title: t.agencyDocumentsTitle,
              subtitle: t.agencyDocumentsMenuSubtitle,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AgencyDocumentsScreen(),
                ),
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
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
              ),
              title: t.adminActionFinance,
              subtitle: t.agencyWalletSubtitle,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AgencyMoneyTab()),
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
                icon: Icons.insights_outlined,
                color: Color(0xFF397C74),
              ),
              title: t.agencyManagementTitle,
              subtitle: t.agencyManagementMenuSubtitle,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AgencyManagementScreen(),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionHeader(title: t.agencyDashboardEditProfile),
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
                icon: Icons.edit_outlined,
                color: AppColors.primary,
              ),
              title: t.agencyDashboardEditProfile,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAgencyProfileScreen(company: company),
                ),
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
              title: t.profilePreviewCard,
              chevron: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompanyDetailScreen(company: company),
                ),
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
              title: t.profileAgencyLogout,
              onTap: () => _confirmLogout(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.profileAgencyLogoutTitle, style: AppTheme.serif(20)),
        content: Text(
          t.profileAgencyLogoutBody,
          style: AppTheme.sans(13, color: AppColors.inkLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              t.agencyDashboardCancel,
              style: AppTheme.sans(13, color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              t.profileAgencyLogout,
              style: AppTheme.sans(
                13,
                weight: FontWeight.w700,
                color: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await provider.agencyLogout();
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
