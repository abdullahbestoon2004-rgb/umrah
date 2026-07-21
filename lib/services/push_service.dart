import 'dart:io' show Platform;

/// Device-side push notification plumbing.
///
/// The concrete implementation is deliberately behind this seam: the app must
/// build and run without a Firebase configuration (local dev, CI, and tests
/// all run without one), and no screen should care which backend delivers a
/// push. [NoopPushService] is the default in that situation.
abstract class PushService {
  /// Asks the user for permission and returns the device token, or null when
  /// permission was refused or push is unavailable on this build.
  Future<String?> requestToken();

  /// Fires when the backend rotates the device token; the new value must be
  /// re-registered against the signed-in user.
  Stream<String> get onTokenRefresh;

  /// Fires when a push lands while the app is in the foreground, carrying the
  /// message's `data` map. The app refreshes its notification list from this.
  Stream<Map<String, String>> get onForegroundMessage;

  /// Drops the token so a signed-out handset stops receiving pushes.
  Future<void> deleteToken();

  /// 'ios' | 'android' | 'web' — matches the `device_tokens.platform` check.
  static String get platformName {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }
}

/// Used wherever push is not configured. Every method is inert, so the calling
/// code needs no null checks or feature flags.
class NoopPushService implements PushService {
  const NoopPushService();

  @override
  Future<String?> requestToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<Map<String, String>> get onForegroundMessage => const Stream.empty();

  @override
  Future<void> deleteToken() async {}
}
