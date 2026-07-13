import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../l10n/generated/app_localizations.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _saving = false;
  bool _deleting = false;

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
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final t = AppLocalizations.of(context);
    final name = _nameCtrl.text.trim();

    // Validate name
    final nameErr = Validators.validateFullName(name);
    if (nameErr != null) {
      showAppSnack(context, t.authErrNameEmpty, isError: true);
      return;
    }

    // Validate phone if provided
    final phoneErr = Validators.validatePhone(_phoneCtrl.text);
    if (phoneErr != null) {
      showAppSnack(context, t.authErrPhoneInvalid, isError: true);
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

  /// Professional email change flow:
  /// 1. Ask for current password (re-authentication)
  /// 2. Validate new email format
  /// 3. Send confirmation to new email via Supabase
  Future<void> _changeEmail() async {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final currentEmail = provider.user?.email ?? '';

    // Step 1: Re-authenticate with current password
    final passwordCtrl = TextEditingController();
    bool obscure = true;

    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(t.accountVerifyIdentity, style: AppTheme.serif(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.accountVerifyIdentityBody,
                style: AppTheme.sans(13, color: AppColors.inkLight),
              ),
              const SizedBox(height: 6),
              Text(
                currentEmail,
                style: AppTheme.sans(
                  13,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: TextField(
                  controller: passwordCtrl,
                  obscureText: obscure,
                  style: AppTheme.sans(14),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.muted,
                        size: 20,
                      ),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                t.agencyDashboardCancel,
                style: AppTheme.sans(13, color: AppColors.muted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, passwordCtrl.text),
              child: Text(
                t.accountVerify,
                style: AppTheme.sans(
                  13,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (password == null || password.isEmpty) return;

    // Verify password via reauthentication (doesn't change session state)
    setState(() => _saving = true);
    final authErr = await provider.reauthenticate(password);
    if (!mounted) return;

    if (authErr != null) {
      setState(() => _saving = false);
      showAppSnack(context, t.accountWrongPassword, isError: true);
      return;
    }
    setState(() => _saving = false);

    // Step 2: Ask for new email
    final newEmailCtrl = TextEditingController();
    String? emailFieldError;

    final newEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(t.accountChangeEmail, style: AppTheme.serif(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.accountChangeEmailBody,
                style: AppTheme.sans(13, color: AppColors.inkLight),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: emailFieldError != null
                        ? AppColors.errorRed
                        : AppColors.border,
                    width: emailFieldError != null ? 2 : 1.5,
                  ),
                ),
                child: TextField(
                  controller: newEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTheme.sans(14),
                  decoration: InputDecoration(
                    hintText: 'newemail@example.com',
                    hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (emailFieldError != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        emailFieldError!,
                        style: AppTheme.sans(12, color: AppColors.errorRed),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                t.agencyDashboardCancel,
                style: AppTheme.sans(13, color: AppColors.muted),
              ),
            ),
            TextButton(
              onPressed: () {
                final result = Validators.validateEmail(newEmailCtrl.text);
                if (result != null) {
                  setDialogState(() => emailFieldError = t.authErrInvalidEmail);
                  return;
                }
                if (newEmailCtrl.text.trim() == currentEmail) {
                  setDialogState(
                    () => emailFieldError = t.accountEmailSameAsCurrent,
                  );
                  return;
                }
                Navigator.pop(ctx, newEmailCtrl.text.trim());
              },
              child: Text(
                t.accountUpdate,
                style: AppTheme.sans(
                  13,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (newEmail == null || newEmail.isEmpty) return;

    // Step 3: Send email change request via Supabase
    setState(() => _saving = true);
    final err = await provider.updateEmail(newEmail);
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: Color(0xFF34C759),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.accountEmailConfirmationTitle,
                  style: AppTheme.serif(18),
                ),
              ),
            ],
          ),
          content: Text(
            t.accountEmailConfirmationBody,
            style: AppTheme.sans(13, color: AppColors.inkLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                t.agencyBookingsConfirm,
                style: AppTheme.sans(13, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    } else {
      showAppSnack(context, err, isError: true);
    }
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
        content: Text(
          t.accountDeleteBody,
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
              t.accountDeleteConfirm,
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
            // Email (Editable with re-authentication)
            GestureDetector(
              onTap: _saving ? null : _changeEmail,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.agencyLoginEmail,
                            style: AppTheme.sans(
                              11,
                              color: AppColors.muted,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: AppTheme.sans(14, weight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.accountChangeEmail,
                        style: AppTheme.sans(
                          11,
                          weight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _Field(
              label: t.authFullName,
              controller: _nameCtrl,
              hint: t.authFullNameHint,
            ),
            const SizedBox(height: 18),
            _Field(
              label: t.authPhone,
              controller: _phoneCtrl,
              hint: '+964 750 000 0000',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 22),
            _PrimaryBtn(
              label: t.accountSaveChanges,
              busy: _saving,
              onTap: _save,
            ),
            const SizedBox(height: 32),

            Text(
              t.accountDangerZone,
              style: AppTheme.sans(
                13,
                weight: FontWeight.w800,
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _deleting ? null : _confirmDelete,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.errorRed.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    _deleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.errorRed,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.delete_forever_rounded,
                            color: AppColors.errorRed,
                            size: 22,
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.accountDeleteAccount,
                            style: AppTheme.sans(
                              14,
                              weight: FontWeight.w700,
                              color: AppColors.errorRed,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.accountDeleteHint,
                            style: AppTheme.sans(11.5, color: AppColors.muted),
                          ),
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
  const _PrimaryBtn({
    required this.label,
    required this.busy,
    required this.onTap,
  });

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
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: AppTheme.sans(
                  14,
                  weight: FontWeight.w800,
                  color: const Color(0xFFF6F2E9),
                ),
              ),
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
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
