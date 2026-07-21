import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device currently has a usable network interface.
///
/// This is deliberately a thin seam over `connectivity_plus` so widget tests
/// can inject a fake instead of depending on platform channels.
abstract class ConnectivityService {
  /// Emits `true` when the device is online, `false` when it is not.
  Stream<bool> get onStatusChange;

  /// The status right now, for the initial paint before any event arrives.
  Future<bool> isOnline();
}

class PlatformConnectivityService implements ConnectivityService {
  PlatformConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  @override
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_hasConnection).distinct();

  @override
  Future<bool> isOnline() async {
    try {
      return _hasConnection(await _connectivity.checkConnectivity());
    } catch (_) {
      // Never let a platform-channel failure convince the app it is offline —
      // a false "offline" would block screens that would otherwise work.
      return true;
    }
  }
}
