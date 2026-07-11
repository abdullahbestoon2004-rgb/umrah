import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart' show fmtIqd;
import '../../widgets/commission_widgets.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/filter_chip_bar.dart';
import '../../l10n/generated/app_localizations.dart';

/// Commission center as a first-class destination: sticky status filter,
/// a live summary strip (count + total for the current filter), then the
/// per-booking ledger across every agency.
class AdminFinanceTab extends StatefulWidget {
  const AdminFinanceTab({super.key});

  @override
  State<AdminFinanceTab> createState() => _AdminFinanceTabState();
}

class _AdminFinanceTabState extends State<AdminFinanceTab> {
  String _filter = 'all'; // 'all' | 'owed' | 'collected'

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final commissions = _filter == 'all'
        ? provider.commissions
        : provider.commissions.where((c) => c.status == _filter).toList();
    final total = commissions.fold(0.0, (s, c) => s + c.amount);

    return DashboardScaffold(
      title: t.adminCommissionsTitle,
      onRefresh: () => context.read<AppProvider>().loadCommissions(),
      filterBar: FilterChipBar<String>(
        options: [
          FilterOption('all', t.adminFilterAll),
          FilterOption('owed', t.adminCommissionsOwed),
          FilterOption('collected', t.adminCommissionsCollected),
        ],
        selected: _filter,
        onSelect: (v) => setState(() => _filter = v),
      ),
      filterBarHeight: 46,
      summary: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Text(t.financeRecordsCount(commissions.length),
                style: AppTheme.sans(13, color: AppColors.muted)),
            const Spacer(),
            Text(fmtIqd(total),
                style: AppTheme.serif(18, color: AppColors.primary)),
          ],
        ),
      ),
      slivers: [
        if (_filter == 'all' && provider.commissions.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad, kDashCardGap, kDashPagePad, kDashCardGap),
              child: CommissionSummaryCard(
                label: t.adminCommissionsOwedLabel,
                amount: provider.commissionsOwed,
              ),
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: kDashCardGap)),
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
                    kDashPagePad, 0, kDashPagePad, kDashCardGap),
                child: CommissionRow(commission: commissions[i]),
              ),
              childCount: commissions.length,
            ),
          ),
      ],
    );
  }
}
