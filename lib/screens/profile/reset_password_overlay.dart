import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/app_snackbar.dart';

class ResetPasswordOverlay extends StatefulWidget {
  const ResetPasswordOverlay({super.key});

  @override
  State<ResetPasswordOverlay> createState() => _ResetPasswordOverlayState();
}

class _ResetPasswordOverlayState extends State<ResetPasswordOverlay> {
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final t = AppLocalizations.of(context);
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

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
    });

    final provider = context.read<AppProvider>();
    final err = await provider.changePassword(newPass);

    if (!mounted) return;

    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
    } else {
      showAppSnack(context, t.forgotPasswordSuccess);
      // Turn off recovery mode so the normal main screen resumes
      provider.needsPasswordReset = false;
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
              const SizedBox(height: 32),
              // ── Icon ──
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),

              // ── Title ──
              Text(t.forgotPasswordTitle, style: AppTheme.serif(32)),
              const SizedBox(height: 6),
              Text(
                t.forgotPasswordStep2Subtitle,
                style: AppTheme.sans(14, color: AppColors.muted),
              ),
              const SizedBox(height: 32),

              _Label(t.forgotPasswordNewPass),
              const SizedBox(height: 8),
              _InputField(
                controller: _newPassCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureNew,
                suffix: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                    _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                onSubmit: (_) => _resetPassword(),
              ),

              // ── Error message ──
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_error!, style: AppTheme.sans(12.5, color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // ── Submit Button ──
              GestureDetector(
                onTap: _loading ? null : _resetPassword,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          t.forgotPasswordResetBtn,
                          style: AppTheme.sans(15, weight: FontWeight.w700, color: const Color(0xFFF6F2E9)),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.sans(12.5, weight: FontWeight.w700, color: AppColors.muted),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onSubmit;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppTheme.sans(14.5),
        onSubmitted: onSubmit,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.sans(14.5, color: AppColors.mutedLight),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}
