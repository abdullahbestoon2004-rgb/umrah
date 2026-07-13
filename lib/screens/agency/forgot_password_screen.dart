import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;
  String? _success;

  /// 0 = enter email, 1 = enter code + new password
  int _step = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    final t = AppLocalizations.of(context);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = t.forgotPasswordErrEmail);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    final provider = context.read<AppProvider>();
    final err = await provider.sendPasswordResetCode(email);

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
    } else {
      setState(() {
        _loading = false;
        _step = 1;
        _success = t.forgotPasswordCodeSent;
        _error = null;
      });
    }
  }

  Future<void> _resetPassword() async {
    final t = AppLocalizations.of(context);
    final code = _codeCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (code.isEmpty) {
      setState(() => _error = t.forgotPasswordErrCode);
      return;
    }
    if (newPass.length < 6) {
      setState(() => _error = t.forgotPasswordErrShort);
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _error = t.forgotPasswordErrNoMatch);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    final provider = context.read<AppProvider>();
    final err = await provider.resetPasswordWithCode(
      email: _emailCtrl.text.trim(),
      code: code,
      newPassword: newPass,
    );

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
    } else {
      setState(() {
        _loading = false;
        _success = t.forgotPasswordSuccess;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ──
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Icon ──
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              // ── Title ──
              Text(t.forgotPasswordTitle, style: AppTheme.serif(32)),
              const SizedBox(height: 6),
              Text(
                _step == 0
                    ? t.forgotPasswordSubtitle
                    : t.forgotPasswordStep2Subtitle,
                style: AppTheme.sans(14, color: AppColors.muted),
              ),
              const SizedBox(height: 32),

              // ── Step 0: Email ──
              if (_step == 0) ...[
                _Label(t.agencyLoginEmail),
                const SizedBox(height: 8),
                _InputField(
                  controller: _emailCtrl,
                  hint: 'admin@youragency.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onSubmit: (_) => _sendResetCode(),
                ),
              ],

              // ── Step 1: Code + New Password ──
              if (_step == 1) ...[
                // Email (read-only)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _emailCtrl.text.trim(),
                        style: AppTheme.sans(13.5, color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                _Label(t.forgotPasswordCodeLabel),
                const SizedBox(height: 8),
                _InputField(
                  controller: _codeCtrl,
                  hint: '123456',
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),

                _Label(t.forgotPasswordNewPass),
                const SizedBox(height: 8),
                _InputField(
                  controller: _newPassCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureNew,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                const SizedBox(height: 18),

                _Label(t.forgotPasswordConfirmPass),
                const SizedBox(height: 8),
                _InputField(
                  controller: _confirmPassCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  onSubmit: (_) => _resetPassword(),
                ),
              ],

              // ── Error message ──
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.errorRed.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.errorRed,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTheme.sans(12.5, color: AppColors.errorRed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── Success message ──
              if (_success != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _success!,
                          style: AppTheme.sans(12.5, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Action button ──
              GestureDetector(
                onTap: _loading
                    ? null
                    : (_step == 0 ? _sendResetCode : _resetPassword),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _step == 0
                              ? t.forgotPasswordSendCode
                              : t.forgotPasswordResetBtn,
                          style: AppTheme.sans(
                            15,
                            weight: FontWeight.w800,
                            color: const Color(0xFFF6F2E9),
                          ),
                        ),
                ),
              ),

              // ── Resend code link (step 1 only) ──
              if (_step == 1) ...[
                const SizedBox(height: 18),
                Center(
                  child: GestureDetector(
                    onTap: _loading ? null : _sendResetCode,
                    child: Text(
                      t.forgotPasswordResend,
                      style: AppTheme.sans(
                        13,
                        weight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.sans(13, weight: FontWeight.w700));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmit;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onSubmitted: onSubmit,
        style: AppTheme.sans(14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
