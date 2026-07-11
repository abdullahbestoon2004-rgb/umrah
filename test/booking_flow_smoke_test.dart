// End-to-end test of the 3-step booking flow: room & pilgrim count →
// per-pilgrim details (with completion gating) → review & payment,
// finishing on the confirmation ticket.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umrah_app/providers/app_provider.dart';
import 'package:umrah_app/screens/offers/booking_flow_screen.dart';
import 'package:umrah_app/l10n/generated/app_localizations.dart';

import 'features_test.dart' show FakeService;

Widget wrap(Widget child, AppProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('full 3-step booking flow reaches the confirmation ticket',
      (tester) async {
    final p = AppProvider(service: FakeService(), autoLoad: false);
    await p.init();
    await p.signIn('client@test.com', 'pass');
    final offer = p.allOffers.first;
    final company = p.companyById(offer.companyId)!;

    await tester.pumpWidget(
        wrap(BookingFlowScreen(offer: offer, company: company), p));
    await tester.pumpAndSettle();

    // ── Step 1: room + count ──
    expect(find.text('Choose room type'), findsOneWidget);
    await tester.tap(find.text('Double room'));
    await tester.pump();
    // add a second pilgrim
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // ── Step 2: pilgrim details ──
    expect(find.text('Pilgrim 1'), findsOneWidget);
    expect(find.text('Pilgrim 2'), findsOneWidget);
    // continue button must be disabled while incomplete
    await tester.tap(find.text('Continue to payment'));
    await tester.pumpAndSettle();
    expect(find.text('Booking summary'), findsNothing);

    // fill both pilgrims: name + passport, pick DOB via the picker
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Karwan Omar');
    await tester.enterText(textFields.at(1), 'A1234567');
    await tester.pump();
    // pilgrim 1 DOB
    await tester.ensureVisible(find.text('Select date').first);
    await tester.tap(find.text('Select date').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // pilgrim 2 (field order: name1, passport1, phone1, name2, passport2)
    await tester.enterText(textFields.at(3), 'Zhyan Mohammed');
    await tester.enterText(textFields.at(4), 'B7654321');
    await tester.pump();
    await tester.ensureVisible(find.text('Select date').first);
    await tester.tap(find.text('Select date').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Incomplete'), findsNothing);
    await tester.tap(find.text('Continue to payment'));
    await tester.pumpAndSettle();

    // ── Step 3: review + pay ──
    expect(find.text('Booking summary'), findsOneWidget);
    expect(find.text('Karwan Omar · Zhyan Mohammed'), findsOneWidget);
    expect(find.text('Double room'), findsOneWidget);
    await tester.tap(find.text('Pay directly in the FIB app'));
    await tester.pump();
    await tester.tap(find.text('Confirm booking'));
    await tester.pumpAndSettle();

    // ── Confirmation ticket ──
    expect(find.text('Booking registered'), findsOneWidget);
    expect(find.text('UM-TEST'), findsOneWidget);
    expect(p.bookings.length, 1);
    expect(p.bookings.first.payMethod, 'fib');
    expect(p.bookings.first.travelers, 2);
  });
}
