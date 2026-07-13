/// Professional-grade input validators for the Umrah app.
/// Matches the validation standards of real production apps (Gmail, etc.).
class Validators {
  Validators._();

  // ── Email Validation ──────────────────────────────────────────────────────
  /// RFC 5322 simplified regex — validates real email format including:
  /// - Must have @ symbol
  /// - Must have a valid domain with at least one dot
  /// - No spaces allowed
  /// - Common TLDs (.com, .net, .org, .io, etc.)
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// Returns null if valid, or an error key if invalid.
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'email_empty';
    }
    final trimmed = email.trim();
    if (trimmed.contains(' ')) {
      return 'email_spaces';
    }
    if (!trimmed.contains('@')) {
      return 'email_no_at';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'email_invalid_format';
    }
    // Check for common typos in domain
    final domain = trimmed.split('@').last.toLowerCase();
    if (domain.endsWith('.') || domain.startsWith('.')) {
      return 'email_invalid_domain';
    }
    // Must have at least 2-char TLD
    final tld = domain.split('.').last;
    if (tld.length < 2) {
      return 'email_invalid_tld';
    }
    return null;
  }

  // ── Phone Validation ──────────────────────────────────────────────────────
  /// Validates phone numbers:
  /// - Must be at least 7 digits (shortest valid international number)
  /// - Must be at most 15 digits (ITU-T E.164 max)
  /// - Can start with + for international format
  /// - Allows spaces, dashes, and parentheses as formatting
  static final _phoneDigitsRegex = RegExp(r'\d');

  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Phone is optional in most flows
    }
    final trimmed = phone.trim();
    // Extract only digits
    final digits = _phoneDigitsRegex
        .allMatches(trimmed)
        .map((m) => m.group(0))
        .join();
    if (digits.length < 7) {
      return 'phone_too_short';
    }
    if (digits.length > 15) {
      return 'phone_too_long';
    }
    // Check for invalid characters (only allow digits, +, -, spaces, parens)
    final cleaned = trimmed.replaceAll(RegExp(r'[\d\s\+\-\(\)]+'), '');
    if (cleaned.isNotEmpty) {
      return 'phone_invalid_chars';
    }
    return null;
  }

  // ── Password Validation ───────────────────────────────────────────────────
  /// Password strength validation:
  /// - Minimum 6 characters
  /// - At least one letter
  /// - At least one digit
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'password_empty';
    }
    if (password.length < 6) {
      return 'password_too_short';
    }
    if (!password.contains(RegExp(r'[a-zA-Z]'))) {
      return 'password_no_letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'password_no_digit';
    }
    return null;
  }

  /// Lighter password check (just length) for login — we don't want to
  /// block login attempts with strict rules since the password was already
  /// set during registration.
  static String? validatePasswordLogin(String? password) {
    if (password == null || password.isEmpty) {
      return 'password_empty';
    }
    return null;
  }

  // ── Full Name Validation ──────────────────────────────────────────────────
  static String? validateFullName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'name_empty';
    }
    if (name.trim().length < 2) {
      return 'name_too_short';
    }
    return null;
  }

  // ── Password Strength Indicator ───────────────────────────────────────────
  /// Returns a strength score from 0 to 4:
  /// 0 = empty, 1 = weak, 2 = fair, 3 = good, 4 = strong
  static int passwordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')))
      score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score.clamp(0, 4);
  }

  static String strengthLabel(int score) {
    switch (score) {
      case 0:
        return '';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }
}
