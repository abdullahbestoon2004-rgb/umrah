import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:umrah_app/main.dart';
import 'package:umrah_app/providers/app_provider.dart';

import 'features_test.dart' show FakeService;

void main() {
  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(UmrahApp(
      createProvider: () => AppProvider(service: FakeService()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
