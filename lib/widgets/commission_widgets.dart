import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import '../models/commission_model.dart';
import '../models/offer_model.dart' show fmtIqd;
import '../providers/app_provider.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_snackbar.dart';
import 'dashboard/status_chip.dart';

/// One commission ledger row: amount + status chip, with a one-tap
/// "mark collected" action while it is still owed. Used by the admin Finance
/// tab (with company names) and the agency Money tab (without).
class CommissionRow extends StatelessWidget {
  final Commission commission;
  final bool showCompanyName;
  const CommissionRow({
    super.key,
    required this.commission,
    this.showCompanyName = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final owed = commission.status == 'owed';
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCompanyName)
                  Text(
                    commission.companyName,
                    style: AppTheme.sans(13, weight: FontWeight.w700),
                  ),
                Text(
                  fmtIqd(commission.amount),
                  style: AppTheme.serif(16, color: AppColors.primary),
                ),
              ],
            ),
          ),
          StatusChip(
            kind: StatusChip.forCommission(commission.status),
            label: owed ? t.adminCommissionsOwed : t.adminCommissionsCollected,
          ),
          if (owed) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await context
                    .read<AppProvider>()
                    .markCommissionCollected(commission.id);
                if (!ok) {
                  messenger.showSnackBar(
                    appSnack(t.actionFailedGeneric, isError: true),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The gradient "total owed" banner shown above commission ledgers.
class CommissionSummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  const CommissionSummaryCard({
    super.key,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.sans(
                  12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fmtIqd(amount),
                style: AppTheme.serif(24, color: Colors.white),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.account_balance_wallet_outlined,
          color: Colors.white,
          size: 32,
        ),
      ],
    ),
  );
}
