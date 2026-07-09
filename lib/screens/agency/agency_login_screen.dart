import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../utils/validators.dart';
import '../../l10n/generated/app_localizations.dart';
import 'agency_dashboard_screen.dart';
import 'forgot_password_screen.dart';
import '../admin/admin_screen.dart';

class AgencyLoginScreen extends StatefulWidget {
  const AgencyLoginScreen({super.key});

  @override
  State<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends State<AgencyLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _sinceCtrl = TextEditingController();
  Uint8List? _logoBytes;
  bool _register = false;
  /// 0 = email, 1 = password/details
  int _step = 0;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    _sinceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _logoBytes = bytes);
  }

  void _next() {
    final t = AppLocalizations.of(context);
    final emailResult = Validators.validateEmail(_emailCtrl.text);
    if (emailResult != null) {
      setState(() => _error = t.authErrInvalidEmail);
      return;
    }
    setState(() {
      _step = 1;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    
    if (pass.isEmpty || (_register && (_companyCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty))) {
      setState(() => _error = t.authErrFillAll);
      return;
    }
    setState(() { _loading = true; _error = null; });

    String? err;
    if (_register) {
      err = await provider.signUpAgency(
        email: email,
        password: pass,
        fullName: _nameCtrl.text.trim(),
        companyName: _companyCtrl.text.trim(),
        companyLocation: _locationCtrl.text.trim(),
        companyAbout: _aboutCtrl.text.trim(),
        companySince: int.tryParse(_sinceCtrl.text.trim()),
        logoBytes: _logoBytes,
      );
    } else {
      err = await provider.signIn(email, pass);
      if (err == null && !provider.isAgencyUser && !provider.isAdminUser) {
        await provider.signOut();
        err = t.agencyNotAgencyAccount;
      }
    }
    if (!mounted) return;
    if (err == null) {
      final provider2 = context.read<AppProvider>();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => provider2.isAdminUser
                  ? const AdminScreen()
                  : const AgencyDashboardScreen()));
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
              Text(_register ? t.agencyRegisterTitle : t.agencyLoginTitle, style: AppTheme.serif(32)),
              const SizedBox(height: 6),
              Text(_register ? t.agencyRegisterSubtitle : t.agencyLoginSubtitle,
                  style: AppTheme.sans(14, color: AppColors.muted)),
              const SizedBox(height: 32),

              if (_step == 0) ...[
                _Label(t.agencyLoginEmail),
                const SizedBox(height: 8),
                _Field(
                  controller: _emailCtrl,
                  hint: 'admin@youragency.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onSubmit: (_) => _next(),
                ),
              ] else ...[
                // Selected Email Display (Gmail style)
                GestureDetector(
                  onTap: () => setState(() { _step = 0; _error = null; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.account_circle_outlined, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(_emailCtrl.text.trim(), style: AppTheme.sans(13, weight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (_register) ...[
                  _Label(t.authFullName),
                  const SizedBox(height: 8),
                  _Field(controller: _nameCtrl, hint: t.authFullNameHint, icon: Icons.person_outline_rounded),
                  const SizedBox(height: 18),
                  _Label(t.agencyCompanyName),
                  const SizedBox(height: 8),
                  _Field(controller: _companyCtrl, hint: t.agencyCompanyNameHint, icon: Icons.business_outlined),
                  const SizedBox(height: 18),
                  _Label(t.agencyCompanyLocation),
                  const SizedBox(height: 8),
                  _Field(controller: _locationCtrl, hint: t.agencyCompanyLocationHint, icon: Icons.location_on_outlined),
                  const SizedBox(height: 18),
                  _Label(t.agencyCompanySince),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _sinceCtrl,
                    hint: t.agencyCompanySinceHint,
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 18),
                  _Label(t.agencyCompanyAbout),
                  const SizedBox(height: 8),
                  _Field(
                    controller: _aboutCtrl,
                    hint: t.agencyCompanyAboutHint,
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 18),
                  _Label(t.agencyCompanyLogo),
                  const SizedBox(height: 8),
                  _LogoPicker(bytes: _logoBytes, onPick: _pickLogo),
                  const SizedBox(height: 6),
                  Text(t.agencyLogoOptional, style: AppTheme.sans(11.5, color: AppColors.muted)),
                  const SizedBox(height: 18),
                ],

                _Label(t.agencyLoginPassword),
                const SizedBox(height: 8),
                _Field(
                  controller: _passCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  autofocus: true,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.muted, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  onSubmit: (_) => _submit(),
                ),

                if (!_register) ...[  
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(initialEmail: _emailCtrl.text.trim()),
                        ),
                      ),
                      child: Text(
                        t.forgotPasswordLink,
                        style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ],

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
                onTap: _loading ? null : (_step == 0 ? _next : _submit),
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
                      : Text(_step == 0 ? t.authNext : (_register ? t.agencyRegisterBtn : t.agencyLoginSignIn),
                          style: AppTheme.sans(15, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() { _register = !_register; _error = null; }),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: _register ? t.authHaveAccount : t.agencyRegisterPrompt,
                        style: AppTheme.sans(13, color: AppColors.muted),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: _register ? t.agencyLoginSignIn : t.agencyRegisterBtn,
                        style: AppTheme.sans(13, weight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFEAF1EC), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.agencyLoginInfoNote,
                        style: AppTheme.sans(12, color: AppColors.inkLight),
                      ),
                    ),
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

class _LogoPicker extends StatelessWidget {
  final Uint8List? bytes;
  final VoidCallback onPick;
  const _LogoPicker({required this.bytes, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(13),
              ),
              clipBehavior: Clip.antiAlias,
              child: bytes != null
                  ? Image.memory(bytes!, fit: BoxFit.cover, cacheWidth: 108)
                  : const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                bytes != null ? t.agencyLogoChange : t.agencyLogoAdd,
                style: AppTheme.sans(13.5, weight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmit;
  final int maxLines;
  final bool autofocus;

  const _Field({
    required this.controller, required this.hint, required this.icon,
    this.obscure = false, this.keyboardType, this.suffix, this.onSubmit,
    this.maxLines = 1,
    this.autofocus = false,
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
        maxLines: maxLines,
        autofocus: autofocus,
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
