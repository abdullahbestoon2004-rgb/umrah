import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/agency_operations_model.dart';
import '../../models/offer_model.dart' show fmtIqd;
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/status_chip.dart';

/// The hybrid marketplace wallet. A positive balance means Tawaf owes the
/// agency; a negative balance means the agency owes Tawaf for cash commission.
class AgencyMoneyTab extends StatefulWidget {
  const AgencyMoneyTab({super.key});

  @override
  State<AgencyMoneyTab> createState() => _AgencyMoneyTabState();
}

class _AgencyMoneyTabState extends State<AgencyMoneyTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AppProvider>().loadAgencyWallet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final wallet = context.watch<AppProvider>().agencyWallet;
    return DashboardScaffold(
      title: t.agencyWalletTitle,
      subtitle: t.agencyWalletSubtitle,
      onRefresh: () => context.read<AppProvider>().loadAgencyWallet(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              kDashCardGap,
              kDashPagePad,
              0,
            ),
            child: _BalanceCard(wallet: wallet),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              10,
              kDashPagePad,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _WalletMetric(
                    label: t.agencyWalletAvailablePayout,
                    amount: wallet.availablePayoutIqd,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _WalletMetric(
                    label: t.agencyWalletPendingPayout,
                    amount: wallet.pendingPayoutIqd,
                    icon: Icons.schedule_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad,
              22,
              kDashPagePad,
              10,
            ),
            child: Text(
              t.agencyWalletActivity,
              style: AppTheme.sans(15, weight: FontWeight.w800),
            ),
          ),
        ),
        if (wallet.entries.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: t.agencyWalletNoActivity,
              body: t.agencyWalletNoActivityBody,
              compact: true,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  9,
                ),
                child: _LedgerRow(entry: wallet.entries[index]),
              ),
              childCount: wallet.entries.length,
            ),
          ),
        if (wallet.payouts.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                kDashPagePad,
                22,
                kDashPagePad,
                10,
              ),
              child: Text(
                t.agencyWalletPayouts,
                style: AppTheme.sans(15, weight: FontWeight.w800),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  9,
                ),
                child: _PayoutRow(payout: wallet.payouts[index]),
              ),
              childCount: wallet.payouts.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final AgencyWallet wallet;
  const _BalanceCard({required this.wallet});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final positive = wallet.balanceIqd > 0;
    final negative = wallet.balanceIqd < 0;
    final color = positive
        ? AppColors.primary
        : negative
        ? AppColors.errorRed
        : AppColors.muted;
    final label = positive
        ? t.agencyWalletTawafOwesYou
        : negative
        ? t.agencyWalletYouOweTawaf
        : t.agencyWalletSettled;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance_rounded, color: color),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.sans(13, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            fmtIqd(wallet.balanceIqd.abs()),
            style: AppTheme.serif(27, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            t.agencyWalletBalanceExplanation,
            style: AppTheme.sans(
              11.5,
              color: AppColors.inkLight,
            ).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _WalletMetric extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  const _WalletMetric({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 10),
        Text(fmtIqd(amount), style: AppTheme.serif(15)),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTheme.sans(10.5, color: AppColors.muted),
          maxLines: 2,
        ),
      ],
    ),
  );
}

class _LedgerRow extends StatelessWidget {
  final AgencyLedgerEntry entry;
  const _LedgerRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final incoming = entry.amountIqd > 0;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (incoming ? AppColors.primary : AppColors.errorRed)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              incoming ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: incoming ? AppColors.primary : AppColors.errorRed,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _entryLabel(entry.type, t),
                  style: AppTheme.sans(12.5, weight: FontWeight.w800),
                ),
                if (entry.description.isNotEmpty)
                  Text(
                    entry.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.sans(10.5, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${incoming ? '+' : '−'}${fmtIqd(entry.amountIqd.abs())}',
                style: AppTheme.sans(
                  12.5,
                  weight: FontWeight.w800,
                  color: incoming ? AppColors.primary : AppColors.errorRed,
                ),
              ),
              Text(
                _date(entry.createdAt),
                style: AppTheme.sans(9.5, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutRow extends StatelessWidget {
  final AgencyPayout payout;
  const _PayoutRow({required this.payout});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_outlined, color: AppColors.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fmtIqd(payout.amountIqd),
                  style: AppTheme.sans(13, weight: FontWeight.w800),
                ),
                Text(
                  [
                    payout.method,
                    payout.reference,
                  ].where((value) => value.isNotEmpty).join(' · '),
                  style: AppTheme.sans(10.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          StatusChip(
            kind: payout.status == 'completed'
                ? StatusKind.positive
                : payout.status == 'failed'
                ? StatusKind.negative
                : StatusKind.pending,
            label: payout.status == 'completed'
                ? t.agencyWalletPaid
                : payout.status == 'failed'
                ? t.agencyWalletFailed
                : t.agencyWalletPending,
          ),
        ],
      ),
    );
  }
}

String _entryLabel(String type, AppLocalizations t) => switch (type) {
  'booking_credit' => t.agencyWalletOnlinePayment,
  'cash_commission_debit' => t.agencyWalletCashCommission,
  'refund_reversal' => t.agencyWalletRefund,
  'payout' => t.agencyWalletPayout,
  _ => t.agencyWalletAdjustment,
};

String _date(DateTime value) =>
    '${value.year}/${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';
