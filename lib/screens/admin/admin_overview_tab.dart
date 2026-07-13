import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart' show fmtIqd;
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/kpi.dart';
import '../../widgets/dashboard/section_header.dart';
import '../../widgets/dashboard/attention_card.dart';
import '../../widgets/dashboard/entity_list_card.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../l10n/generated/app_localizations.dart';
import 'admin_support_screen.dart';

/// Admin landing tab: KPI grid, "needs attention" deep links, and the most
/// recent platform events. Everything is a card that links deeper — no tables.
class AdminOverviewTab extends StatelessWidget {
  /// Switches the shell to another destination (1 = Agencies, 4 = More/ledger).
  final ValueChanged<int> onGoToTab;
  const AdminOverviewTab({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final pending = provider.pendingCompanies.length;
    final support = provider.supportMessages.length;
    final owedRows = provider.commissions
        .where((c) => c.status == 'owed')
        .length;
    final hasAttention = pending + support + owedRows > 0;
    final events = _recentEvents(provider);

    return DashboardScaffold(
      title: t.adminTitle,
      subtitle: provider.user?.email ?? '',
      leading: DashIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
      onRefresh: () => context.read<AppProvider>().loadAdminData(),
      slivers: [
        SliverToBoxAdapter(
          child: KpiGrid(
            cards: [
              KpiCard(
                value: compactIqd(provider.commissionsCollected),
                label: t.adminStatCollected,
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                onTap: () => onGoToTab(4),
              ),
              KpiCard(
                value: compactIqd(provider.commissionsOwed),
                label: t.adminStatOwed,
                icon: Icons.hourglass_bottom_rounded,
                color: AppColors.gold,
                onTap: () => onGoToTab(4),
              ),
              KpiCard(
                value: '${provider.companies.length}',
                label: t.adminMetricAgencies,
                icon: Icons.domain_rounded,
                color: const Color(0xFF397C74),
                onTap: () => onGoToTab(1),
              ),
              KpiCard(
                value: '$pending',
                label: t.adminStatPending,
                icon: Icons.schedule_rounded,
                color: const Color(0xFF8B5F38),
                onTap: () => onGoToTab(1),
              ),
            ],
          ),
        ),
        if (hasAttention) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: t.adminNeedsAttention),
          ),
          SliverToBoxAdapter(
            child: AttentionRow(
              cards: [
                if (pending > 0)
                  AttentionCard(
                    icon: Icons.schedule_rounded,
                    label: t.adminPendingAgencies,
                    count: pending,
                    color: AppColors.gold,
                    onTap: () => onGoToTab(1),
                  ),
                if (support > 0)
                  AttentionCard(
                    icon: Icons.mail_outline_rounded,
                    label: t.adminSupportInbox,
                    count: support,
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminSupportScreen(),
                      ),
                    ),
                  ),
                if (owedRows > 0)
                  AttentionCard(
                    icon: Icons.receipt_long_rounded,
                    label: t.adminCommissionsOwedLabel,
                    count: owedRows,
                    color: const Color(0xFF8B5F38),
                    onTap: () => onGoToTab(4),
                  ),
              ],
            ),
          ),
        ] else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                kDashPagePad,
                kDashSectionGap,
                kDashPagePad,
                0,
              ),
              child: _AllCaughtUp(message: t.adminAllCaughtUp),
            ),
          ),
        SliverToBoxAdapter(
          child: SectionHeader(
            title: t.adminRecentActivity,
            onViewAll: events.isEmpty ? null : () => onGoToTab(4),
          ),
        ),
        if (events.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.history_rounded,
              title: t.adminCommissionsEmptyBody,
              compact: true,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  kDashCardGap,
                ),
                child: _ActivityRow(event: events[i], onGoToTab: onGoToTab),
              ),
              childCount: events.length,
            ),
          ),
      ],
    );
  }

  List<_ActivityEvent> _recentEvents(AppProvider provider) {
    final events = <_ActivityEvent>[
      for (final c in provider.commissions)
        _ActivityEvent.commission(
          c.companyName,
          c.amount,
          c.status,
          c.createdAt,
        ),
      for (final m in provider.supportMessages)
        _ActivityEvent.support(m.email ?? '', m.message, m.createdAt),
    ]..sort((a, b) => b.at.compareTo(a.at));
    return events.take(8).toList();
  }
}

class _ActivityEvent {
  final bool isCommission;
  final String title;
  final String subtitle;
  final String status;
  final DateTime at;
  const _ActivityEvent._(
    this.isCommission,
    this.title,
    this.subtitle,
    this.status,
    this.at,
  );

  factory _ActivityEvent.commission(
    String company,
    double amount,
    String status,
    DateTime at,
  ) => _ActivityEvent._(true, company, fmtIqd(amount), status, at);
  factory _ActivityEvent.support(String email, String message, DateTime at) =>
      _ActivityEvent._(false, email, message, '', at);
}

class _ActivityRow extends StatelessWidget {
  final _ActivityEvent event;
  final ValueChanged<int> onGoToTab;
  const _ActivityRow({required this.event, required this.onGoToTab});

  String _timeAgo(AppLocalizations t) {
    final diff = DateTime.now().difference(event.at);
    if (diff.inMinutes < 1) return t.notifJustNow;
    if (diff.inHours < 1) return t.notifMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return t.notifHoursAgo(diff.inHours);
    return t.notifDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final color = event.isCommission ? AppColors.primary : AppColors.gold;
    return EntityListCard(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          event.isCommission
              ? Icons.receipt_long_rounded
              : Icons.mail_outline_rounded,
          size: 18,
          color: color,
        ),
      ),
      title: event.title.isEmpty ? t.adminSupportAnonymous : event.title,
      subtitle: event.subtitle,
      trailing: Text(
        _timeAgo(t),
        style: AppTheme.sans(11, color: AppColors.mutedLight),
      ),
      onTap: () {
        if (event.isCommission) {
          onGoToTab(4);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminSupportScreen()),
          );
        }
      },
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  final String message;
  const _AllCaughtUp({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.09),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withOpacity(0.24)),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            message,
            style: AppTheme.sans(
              12.5,
              weight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    ),
  );
}
