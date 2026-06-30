import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import 'agency_dashboard_screen.dart';

class AgencyLoginScreen extends StatefulWidget {
  const AgencyLoginScreen({super.key});

  @override
  State<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends State<AgencyLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 400));
    final ok = context.read<AppProvider>().agencyLogin(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AgencyDashboardScreen()));
    } else {
      final t = AppLocalizations.of(context);
      setState(() { _error = t.agencyLoginInvalidCredentials; _loading = false; });
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
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.border, width: 1.5)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.business_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),
              Text(t.agencyLoginTitle, style: AppTheme.serif(32)),
              const SizedBox(height: 6),
              Text(t.agencyLoginSubtitle, style: AppTheme.sans(14, color: AppColors.muted)),
              const SizedBox(height: 36),

              _Label(t.agencyLoginEmail),
              const SizedBox(height: 8),
              _Field(
                controller: _emailCtrl,
                hint: 'admin@youragency.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

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
                onSubmit: (_) => _login(),
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

              const SizedBox(height: 28),
              GestureDetector(
                onTap: _loading ? null : _login,
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
                      : Text(t.agencyLoginSignIn, style: AppTheme.sans(15, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
                ),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEAF1EC), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.agencyLoginDemoCredentials, style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 6),
                    Text(t.agencyLoginDemoEmail, style: AppTheme.sans(12, color: AppColors.inkLight)),
                    Text(t.agencyLoginDemoPassword, style: AppTheme.sans(12, color: AppColors.inkLight)),
                    const SizedBox(height: 4),
                    Text(t.agencyLoginDemoHint, style: AppTheme.sans(11, color: AppColors.muted)),
                  ],
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
