import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../l10n/generated/app_localizations.dart';

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
                    onChanged: (v) => provider.setSecuritySetting('biometric', v),
                  ),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.verified_user_outlined,
                    label: t.privacyTwoFactor,
                    sub: t.privacyTwoFactorSub,
                    value: provider.twoFactorAuth,
                    onChanged: (v) => provider.setSecuritySetting('twoFactor', v),
                  ),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.password_rounded,
                    label: t.privacyChangePassword,
                    onTap: () => _openChangePassword(context),
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

  void _openChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
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

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final t = AppLocalizations.of(context);
    String? err;
    if (_currentCtrl.text.isEmpty) {
      err = t.privacyErrCurrentRequired;
    } else if (_newCtrl.text.length < 6) {
      err = t.privacyErrTooShort;
    } else if (_newCtrl.text != _confirmCtrl.text) {
      err = t.privacyErrNoMatch;
    }
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
      content: Text(t.privacyPasswordChanged, style: AppTheme.sans(13, weight: FontWeight.w600)),
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42, height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(t.privacyChangePassword, style: AppTheme.serif(24)),
            const SizedBox(height: 18),
            _PasswordField(controller: _currentCtrl, label: t.privacyCurrentPassword),
            const SizedBox(height: 14),
            _PasswordField(controller: _newCtrl, label: t.privacyNewPassword),
            const SizedBox(height: 14),
            _PasswordField(controller: _confirmCtrl, label: t.privacyConfirmPassword),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: AppTheme.sans(12.5, color: AppColors.errorRed))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: Text(t.privacyUpdatePassword,
                    style: AppTheme.sans(14, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const _PasswordField({required this.controller, required this.label});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTheme.sans(13, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscure,
            style: AppTheme.sans(14),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.muted, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
