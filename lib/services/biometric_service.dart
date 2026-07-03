import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around local_auth. Biometrics only exist on mobile —
/// on web every check reports unsupported and authenticate succeeds
/// so the lock never engages there.
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static bool get isSupported => !kIsWeb;

  static Future<bool> canAuthenticate() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported() || await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate(String reason) async {
    if (kIsWeb) return true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
