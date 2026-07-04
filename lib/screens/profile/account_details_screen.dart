import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  final _passCtrl = TextEditingController();
  bool _saving = false;
  bool _changingPass = false;
  bool _deleting = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final t = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showAppSnack(context, t.authErrFillAll, isError: true);
      return;
    }
    setState(() => _saving = true);
    final err = await context.read<AppProvider>().updateAccountDetails(
          fullName: name,
          phone: _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    showAppSnack(context, err ?? t.accountUpdated, isError: err != null);
  }

  Future<void> _changePassword() async {
    if (_changingPass) return;
    final t = AppLocalizations.of(context);
    final pass = _passCtrl.text;
    if (pass.length < 6) {
      showAppSnack(context, t.accountPasswordTooShort, isError: true);
      return;
    }
    setState(() => _changingPass = true);
    final err = await context.read<AppProvider>().changePassword(pass);
    if (!mounted) return;
    setState(() => _changingPass = false);
    if (err == null) _passCtrl.clear();
    showAppSnack(context, err ?? t.accountPasswordUpdated, isError: err != null);
  }

  Future<void> _confirmDelete() async {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.accountDeleteTitle, style: AppTheme.serif(20)),
        content: Text(t.accountDeleteBody, style: AppTheme.sans(13, color: AppColors.inkLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(t.agencyDashboardCancel, style: AppTheme.sans(13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(t.accountDeleteConfirm,
                style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final err = await provider.deleteAccount();
    if (err != null) {
      if (mounted) setState(() => _deleting = false);
      messenger.showSnackBar(appSnack(t.accountDeleteFailed, isError: true));
      return;
    }
    navigator.popUntil((r) => r.isFirst);
    messenger.showSnackBar(appSnack(t.accountDeleted));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AppProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded, color: AppColors.ink),
        ),
        title: Text(t.profileAccountDetails, style: AppTheme.serif(22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email (read-only — it's the account identifier)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(user?.email ?? '',
                        style: AppTheme.sans(14, weight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _Field(label: t.authFullName, controller: _nameCtrl, hint: t.authFullNameHint),
            const SizedBox(height: 18),
            _Field(
              label: t.authPhone,
              controller: _phoneCtrl,
              hint: t.accountPhoneHint,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 22),
            _PrimaryBtn(
              label: t.accountSaveChanges,
              busy: _saving,
              onTap: _save,
            ),
            const SizedBox(height: 32),

            Text(t.accountChangePassword, style: AppTheme.serif(19)),
            const SizedBox(height: 12),
            _Field(
              label: t.accountNewPassword,
              controller: _passCtrl,
              hint: t.accountNewPasswordHint,
              obscure: _obscure,
              suffix: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.muted, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 14),
            _PrimaryBtn(
              label: t.accountChangePassword,
              busy: _changingPass,
              onTap: _changePassword,
            ),
            const SizedBox(height: 36),

            Text(t.accountDangerZone,
                style: AppTheme.sans(13, weight: FontWeight.w800, color: AppColors.errorRed)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _deleting ? null : _confirmDelete,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.errorRed.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    _deleting
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: AppColors.errorRed, strokeWidth: 2.5))
                        : const Icon(Icons.delete_forever_rounded, color: AppColors.errorRed, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.accountDeleteAccount,
                              style: AppTheme.sans(14, weight: FontWeight.w700, color: AppColors.errorRed)),
                          const SizedBox(height: 2),
                          Text(t.accountDeleteHint,
                              style: AppTheme.sans(11.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: busy
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label,
                style: AppTheme.sans(14, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  const _Field({
    required this.label, required this.controller, required this.hint,
    this.obscure = false, this.keyboardType, this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.sans(13, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: AppTheme.sans(14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}
