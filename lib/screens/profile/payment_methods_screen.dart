import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';

/// Payment always happens in person at the agency (no in-app payments in
/// Iraq) — this screen just remembers how the pilgrim prefers to pay, shown
/// to the agency alongside their booking request.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(t.preferredPaymentTitle, style: AppTheme.serif(26))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(t.preferredPaymentBody, style: AppTheme.sans(13, color: AppColors.muted).copyWith(height: 1.5)),
                  const SizedBox(height: 18),
                  _MethodTile(
                    icon: Icons.payments_outlined,
                    label: t.payCash,
                    value: 'cash',
                    current: provider.preferredPayMethod,
                    onTap: () => _select(context, provider, 'cash'),
                  ),
                  const SizedBox(height: 10),
                  _MethodTile(
                    icon: Icons.credit_card_rounded,
                    label: t.payCard,
                    value: 'card',
                    current: provider.preferredPayMethod,
                    onTap: () => _select(context, provider, 'card'),
                  ),
                  const SizedBox(height: 10),
                  _MethodTile(
                    icon: Icons.account_balance_outlined,
                    label: t.payFib,
                    value: 'fib',
                    current: provider.preferredPayMethod,
                    onTap: () => _select(context, provider, 'fib'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, AppProvider provider, String method) {
    provider.setPreferredPayMethod(method);
    showAppSnack(context, AppLocalizations.of(context).preferredPaymentSaved);
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String current;
  final VoidCallback onTap;
  const _MethodTile({
    required this.icon, required this.label, required this.value,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: AppTheme.sans(14, weight: FontWeight.w600))),
            Icon(
              active ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: active ? AppColors.primary : AppColors.mutedLight,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
