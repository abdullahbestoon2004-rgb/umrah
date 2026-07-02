import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';

/// Client sign-in / sign-up. Pops with `true` after a successful auth.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _signUp = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty || (_signUp && _nameCtrl.text.trim().isEmpty)) {
      setState(() => _error = t.authErrFillAll);
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = _signUp
        ? await provider.signUpClient(
            email: email, password: pass,
            fullName: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim())
        : await provider.signIn(email, pass);
    if (!mounted) return;
    if (err == null) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(appSnack(t.authWelcomeSnack));
    } else if (err == 'confirm-email') {
      setState(() { _loading = false; _error = t.authConfirmEmailSent; });
    } else {
      setState(() { _loading = false; _error = err; });
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
              const SizedBox(height: 28),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 18),
              Text(_signUp ? t.authSignUpTitle : t.authSignInTitle, style: AppTheme.serif(30)),
              const SizedBox(height: 6),
              Text(t.authSubtitle, style: AppTheme.sans(14, color: AppColors.muted)),
              const SizedBox(height: 30),

              if (_signUp) ...[
                _Label(t.authFullName),
                const SizedBox(height: 8),
                _Field(controller: _nameCtrl, hint: t.authFullNameHint, icon: Icons.person_outline_rounded),
                const SizedBox(height: 16),
                _Label(t.authPhone),
                const SizedBox(height: 8),
                _Field(
                  controller: _phoneCtrl,
                  hint: '0750 000 0000',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
              ],

              _Label(t.agencyLoginEmail),
              const SizedBox(height: 8),
              _Field(
                controller: _emailCtrl,
                hint: 'you@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _Label(t.agencyLoginPassword),
              const SizedBox(height: 8),
              _Field(
                controller: _passCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.muted, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                onSubmit: (_) => _submit(),
              ),

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
                      Expanded(child: Text(_error!, style: AppTheme.sans(12.5, color: AppColors.errorRed))),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 26),
              GestureDetector(
                onTap: _loading ? null : _submit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  alignment: Alignment.center,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(_signUp ? t.authSignUpBtn : t.agencyLoginSignIn,
                          style: AppTheme.sans(15, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() { _signUp = !_signUp; _error = null; }),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: _signUp ? t.authHaveAccount : t.authNoAccount,
                        style: AppTheme.sans(13, color: AppColors.muted),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: _signUp ? t.agencyLoginSignIn : t.authSignUpBtn,
                        style: AppTheme.sans(13, weight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ]),
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
  Widget build(BuildContext context) =>
      Text(text, style: AppTheme.sans(13, weight: FontWeight.w700));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmit;

  const _Field({
    required this.controller, required this.hint, required this.icon,
    this.obscure = false, this.keyboardType, this.suffix, this.onSubmit,
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
