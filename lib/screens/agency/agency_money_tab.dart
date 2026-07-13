import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/commission_model.dart';
import '../../models/offer_model.dart' show fmtIqd;
import '../../widgets/commission_widgets.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/status_chip.dart';
import '../../l10n/generated/app_localizations.dart';

/// The agency's money view: net balance owed to the platform on top, then
/// the commission ledger grouped by month, each group collapsible with its
/// own subtotal.
class AgencyMoneyTab extends StatelessWidget {
  const AgencyMoneyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final commissions = provider.commissions;
    final owed = provider.commissionsOwed;
    final groups = _groupByMonth(commissions);

    return DashboardScaffold(
      title: t.adminActionFinance,
      onRefresh: () => context.read<AppProvider>().loadCommissions(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              kDashCardGap,
              kDashPagePad,
              0,
            ),
            child: owed > 0
                ? CommissionSummaryCard(
                    label: t.agencyMoneyYouOwe,
                    amount: owed,
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            t.agencyMoneySettled,
                            style: AppTheme.sans(
                              12.5,
                              weight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (commissions.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: t.adminCommissionsEmptyTitle,
              body: t.adminCommissionsEmptyBody,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  kDashCardGap,
                  kDashPagePad,
                  0,
                ),
                child: _MonthGroup(
                  label: _monthLabel(groups[i].month),
                  commissions: groups[i].rows,
                  initiallyExpanded: i == 0,
                ),
              ),
              childCount: groups.length,
            ),
          ),
      ],
    );
  }

  List<({DateTime month, List<Commission> rows})> _groupByMonth(
    List<Commission> commissions,
  ) {
    final map = <String, List<Commission>>{};
    for (final c in commissions) {
      final key =
          '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(c);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final k in keys)
        (
          month: DateTime(
            int.parse(k.split('-')[0]),
            int.parse(k.split('-')[1]),
          ),
          rows: map[k]!,
        ),
    ];
  }

  // Numeric year/month keeps this locale-proof (intl has no Sorani data).
  String _monthLabel(DateTime month) =>
      '${month.year} / ${month.month.toString().padLeft(2, '0')}';
}

class _MonthGroup extends StatefulWidget {
  final String label;
  final List<Commission> commissions;
  final bool initiallyExpanded;
  const _MonthGroup({
    required this.label,
    required this.commissions,
    this.initiallyExpanded = false,
  });

  @override
  State<_MonthGroup> createState() => _MonthGroupState();
}

class _MonthGroupState extends State<_MonthGroup> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final subtotal = widget.commissions.fold(0.0, (s, c) => s + c.amount);
    final owedCount = widget.commissions
        .where((c) => c.status == 'owed')
        .length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(
                    widget.label,
                    style: AppTheme.sans(13.5, weight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  if (owedCount > 0)
                    StatusChip(
                      kind: StatusKind.pending,
                      label: '$owedCount ${t.adminCommissionsOwed}',
                    ),
                  const Spacer(),
                  Text(
                    fmtIqd(subtotal),
                    style: AppTheme.serif(15, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
              child: Column(
                children: [
                  for (final c in widget.commissions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CommissionRow(
                        commission: c,
                        showCompanyName: false,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
