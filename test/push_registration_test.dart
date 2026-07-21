import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:umrah_app/providers/app_provider.dart';
import 'package:umrah_app/services/push_service.dart';

import 'features_test.dart' show FakeService;

class FakePushService implements PushService {
  FakePushService({this.token = 'device-token-1'});

  final String? token;
  final tokenRefreshes = StreamController<String>.broadcast();
  final foregroundMessages = StreamController<Map<String, String>>.broadcast();
  int requestCount = 0;
  bool deleted = false;

  @override
  Future<String?> requestToken() async {
    requestCount++;
    return token;
  }

  @override
  Stream<String> get onTokenRefresh => tokenRefreshes.stream;

  @override
  Stream<Map<String, String>> get onForegroundMessage =>
      foregroundMessages.stream;

  @override
  Future<void> deleteToken() async {
    deleted = true;
  }
}

void main() {
  test('signing in binds this handset to the account', () async {
    final backend = FakeService();
    final push = FakePushService();
    final p = AppProvider(service: backend, push: push, autoLoad: false);
    await p.init();

    expect(backend.registeredDeviceTokens, isEmpty);

    await p.signIn('client@test.com', 'pass');

    expect(push.requestCount, 1);
    expect(backend.registeredDeviceTokens.keys, contains('device-token-1'));
  });

  test('signing out stops delivery to this handset', () async {
    final backend = FakeService();
    final push = FakePushService();
    final p = AppProvider(service: backend, push: push, autoLoad: false);
    await p.init();
    await p.signIn('client@test.com', 'pass');
    expect(backend.registeredDeviceTokens, isNotEmpty);

    await p.signOut();

    // Otherwise the next person to sign in on a shared phone would keep
    // receiving the previous user's notifications.
    expect(backend.registeredDeviceTokens, isEmpty);
    expect(push.deleted, isTrue);
  });

  test('a rotated token is re-registered', () async {
    final backend = FakeService();
    final push = FakePushService();
    final p = AppProvider(service: backend, push: push, autoLoad: false);
    await p.init();
    await p.signIn('client@test.com', 'pass');

    push.tokenRefreshes.add('device-token-2');
    await Future<void>.delayed(Duration.zero);

    expect(backend.registeredDeviceTokens.keys, contains('device-token-2'));
  });

  test('refusing permission is not an error', () async {
    final backend = FakeService();
    final push = FakePushService(token: null);
    final p = AppProvider(service: backend, push: push, autoLoad: false);
    await p.init();

    await p.signIn('client@test.com', 'pass');

    // The user is still signed in and usable, just without push.
    expect(p.isSignedIn, isTrue);
    expect(backend.registeredDeviceTokens, isEmpty);
  });

  test('the default provider works with no push configured', () async {
    final backend = FakeService();
    final p = AppProvider(service: backend, autoLoad: false);
    await p.init();

    await p.signIn('client@test.com', 'pass');

    expect(p.isSignedIn, isTrue);
    expect(backend.registeredDeviceTokens, isEmpty);
  });
}
