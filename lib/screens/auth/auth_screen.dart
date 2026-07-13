import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/password_strength_indicator.dart';
import '../../utils/validators.dart';
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

  /// Gmail-style multi-step: 0 = email, 1 = password/details
  int _step = 0;

  // Real-time validation state
  String? _emailError;
  String? _phoneError;
  String? _nameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_onEmailChanged);
    _passCtrl.addListener(_onPasswordChanged);
    _phoneCtrl.addListener(_onPhoneChanged);
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (_emailError != null) {
      final result = Validators.validateEmail(_emailCtrl.text);
      if (result == null) setState(() => _emailError = null);
    }
  }

  void _onPasswordChanged() {
    if (_passwordError != null) {
      final result = _signUp
          ? Validators.validatePassword(_passCtrl.text)
          : Validators.validatePasswordLogin(_passCtrl.text);
      if (result == null) setState(() => _passwordError = null);
    }
    if (_signUp) setState(() {}); // Refresh strength indicator
  }

  void _onPhoneChanged() {
    if (_phoneError != null) {
      final result = Validators.validatePhone(_phoneCtrl.text);
      if (result == null) setState(() => _phoneError = null);
    }
  }

  void _onNameChanged() {
    if (_nameError != null) {
      final result = Validators.validateFullName(_nameCtrl.text);
      if (result == null) setState(() => _nameError = null);
    }
  }

  String _mapEmailError(String code, AppLocalizations t) {
    switch (code) {
      case 'email_empty':
        return t.authErrEmailEmpty;
      case 'email_spaces':
        return t.authErrEmailSpaces;
      case 'email_no_at':
        return t.authErrEmailNoAt;
      case 'email_invalid_format':
        return t.authErrInvalidEmail;
      case 'email_invalid_domain':
        return t.authErrEmailInvalidDomain;
      case 'email_invalid_tld':
        return t.authErrEmailInvalidDomain;
      default:
        return t.authErrInvalidEmail;
    }
  }

  String _mapPhoneError(String code, AppLocalizations t) {
    switch (code) {
      case 'phone_too_short':
        return t.authErrPhoneTooShort;
      case 'phone_too_long':
        return t.authErrPhoneTooLong;
      case 'phone_invalid_chars':
        return t.authErrPhoneInvalidChars;
      default:
        return t.authErrPhoneInvalid;
    }
  }

  String _mapPasswordError(String code, AppLocalizations t) {
    switch (code) {
      case 'password_empty':
        return t.authErrPasswordEmpty;
      case 'password_too_short':
        return t.authErrPasswordShort;
      case 'password_no_letter':
        return t.authErrPasswordNoLetter;
      case 'password_no_digit':
        return t.authErrPasswordNoDigit;
      default:
        return t.authErrPasswordShort;
    }
  }

  /// Step 1: Validate email and proceed to step 2
  void _next() {
    final t = AppLocalizations.of(context);
    final emailResult = Validators.validateEmail(_emailCtrl.text);
    if (emailResult != null) {
      setState(() => _emailError = _mapEmailError(emailResult, t));
      return;
    }
    setState(() {
      _step = 1;
      _error = null;
      _emailError = null;
    });
  }

  /// Step 2: Validate all fields and submit
  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();

    // Validate password
    final passResult = _signUp
        ? Validators.validatePassword(_passCtrl.text)
        : Validators.validatePasswordLogin(_passCtrl.text);
    if (passResult != null) {
      setState(() => _passwordError = _mapPasswordError(passResult, t));
      return;
    }

    // For sign-up, validate name and phone
    if (_signUp) {
      final nameResult = Validators.validateFullName(_nameCtrl.text);
      if (nameResult != null) {
        setState(
          () => _nameError = nameResult == 'name_empty'
              ? t.authErrNameEmpty
              : t.authErrNameTooShort,
        );
        return;
      }
      final phoneResult = Validators.validatePhone(_phoneCtrl.text);
      if (phoneResult != null) {
        setState(() => _phoneError = _mapPhoneError(phoneResult, t));
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final err = _signUp
        ? await provider.signUpClient(
            email: email,
            password: pass,
            fullName: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          )
        : await provider.signIn(email, pass);
    if (!mounted) return;
    if (err == null) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(appSnack(t.authWelcomeSnack));
    } else if (err == 'confirm-email') {
      setState(() {
        _loading = false;
        _error = t.authConfirmEmailSent;
      });
    } else {
      setState(() {
        _loading = false;
        _error = err;
      });
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
                onTap: () {
                  if (_step == 1) {
                    setState(() {
                      _step = 0;
                      _error = null;
                      _passwordError = null;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
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
              const SizedBox(height: 28),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _step == 0
                    ? (_signUp ? t.authSignUpTitle : t.authSignInTitle)
                    : (_signUp ? t.authSignUpTitle : t.authSignInTitle),
                style: AppTheme.serif(30),
              ),
              const SizedBox(height: 6),
              Text(
                _step == 0 ? t.authSubtitle : t.authEnterPassword,
                style: AppTheme.sans(14, color: AppColors.muted),
              ),
              const SizedBox(height: 30),

              // ── STEP 0: Email Entry ──────────────────────────────────────
              if (_step == 0) ...[
                _Label(t.agencyLoginEmail),
                const SizedBox(height: 8),
                _ValidatedField(
                  controller: _emailCtrl,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  error: _emailError,
                  onSubmit: (_) => _next(),
                ),
              ]
              // ── STEP 1: Password + Details ───────────────────────────────
              else ...[
                // Email chip (Gmail-style)
                GestureDetector(
                  onTap: () => setState(() {
                    _step = 0;
                    _error = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_circle_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _emailCtrl.text.trim(),
                            style: AppTheme.sans(13, weight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (_signUp) ...[
                  _Label(t.authFullName),
                  const SizedBox(height: 8),
                  _ValidatedField(
                    controller: _nameCtrl,
                    hint: t.authFullNameHint,
                    icon: Icons.person_outline_rounded,
                    error: _nameError,
                  ),
                  const SizedBox(height: 16),
                  _Label(t.authPhone),
                  const SizedBox(height: 8),
                  _ValidatedField(
                    controller: _phoneCtrl,
                    hint: '+964 750 000 0000',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    error: _phoneError,
                  ),
                  const SizedBox(height: 16),
                ],

                _Label(t.agencyLoginPassword),
                const SizedBox(height: 8),
                _ValidatedField(
                  controller: _passCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  error: _passwordError,
                  autofocus: true,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  onSubmit: (_) => _submit(),
                ),
                if (_signUp)
                  PasswordStrengthIndicator(password: _passCtrl.text),
              ],

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

              const SizedBox(height: 26),
              GestureDetector(
                onTap: _loading ? null : (_step == 0 ? _next : _submit),
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
                              ? t.authNext
                              : (_signUp
                                    ? t.authSignUpBtn
                                    : t.agencyLoginSignIn),
                          style: AppTheme.sans(
                            15,
                            weight: FontWeight.w800,
                            color: const Color(0xFFF6F2E9),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _signUp = !_signUp;
                    _error = null;
                    _step = 0;
                  }),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: _signUp ? t.authHaveAccount : t.authNoAccount,
                          style: AppTheme.sans(13, color: AppColors.muted),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: _signUp ? t.agencyLoginSignIn : t.authSignUpBtn,
                          style: AppTheme.sans(
                            13,
                            weight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
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

/// A text field with inline error display (red border + error text below).
class _ValidatedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmit;
  final String? error;
  final bool autofocus;

  const _ValidatedField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.onSubmit,
    this.error,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? AppColors.errorRed : AppColors.border,
              width: hasError ? 2 : 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onSubmitted: onSubmit,
            autofocus: autofocus,
            style: AppTheme.sans(14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
              prefixIcon: Icon(
                icon,
                color: hasError ? AppColors.errorRed : AppColors.primary,
                size: 20,
              ),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (hasError) ...[
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
                  error!,
                  style: AppTheme.sans(12, color: AppColors.errorRed),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
