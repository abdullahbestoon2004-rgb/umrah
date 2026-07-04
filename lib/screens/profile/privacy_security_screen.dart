import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../services/biometric_service.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';
import 'account_details_screen.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

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
                  Expanded(child: Text(t.privacyTitle, style: AppTheme.serif(26))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(t.privacySectionSecurity,
                      style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.fingerprint_rounded,
                    label: t.privacyBiometric,
                    sub: t.privacyBiometricSub,
                    value: provider.biometricLock,
                    onChanged: (v) => _toggleBiometric(context, provider, v),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.password_rounded,
                    label: t.privacyChangePassword,
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const AccountDetailsScreen())),
                  ),
                  const SizedBox(height: 22),
                  Text(t.privacySectionPrivacy,
                      style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.mark_email_read_outlined,
                    label: t.privacyMarketing,
                    sub: t.privacyMarketingSub,
                    value: provider.marketingEmails,
                    onChanged: (v) => provider.setSecuritySetting('marketing', v),
                  ),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.analytics_outlined,
                    label: t.privacyActivity,
                    sub: t.privacyActivitySub,
                    value: provider.shareActivity,
                    onChanged: (v) => provider.setSecuritySetting('activity', v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBiometric(BuildContext context, AppProvider provider, bool enable) async {
    final t = AppLocalizations.of(context);
    if (!enable) {
      provider.setSecuritySetting('biometric', false);
      return;
    }
    if (!BiometricService.isSupported) {
      showAppSnack(context, t.privacyBiometricMobileOnly, isError: true);
      return;
    }
    if (!await BiometricService.canAuthenticate()) {
      if (context.mounted) showAppSnack(context, t.privacyBiometricUnavailable, isError: true);
      return;
    }
    // Prove the user can actually unlock before locking them out.
    final ok = await BiometricService.authenticate(t.lockReason);
    if (ok) provider.setSecuritySetting('biometric', true);
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon, required this.label, required this.sub,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border, width: 1.5),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.sans(14, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(sub, style: AppTheme.sans(11.5, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border, width: 1.5),
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
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFC1C8BF), size: 20),
          ],
        ),
      ),
    );
  }
}
