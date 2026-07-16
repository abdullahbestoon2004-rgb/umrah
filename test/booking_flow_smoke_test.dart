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

  testWidgets('full 3-step booking flow reaches the confirmation ticket', (
    tester,
  ) async {
    final p = AppProvider(service: FakeService(), autoLoad: false);
    await p.init();
    await p.signIn('client@test.com', 'pass');
    final offer = p.allOffers.first;
    final company = p.companyById(offer.companyId)!;

    await tester.pumpWidget(
      wrap(BookingFlowScreen(offer: offer, company: company), p),
    );
    await tester.pumpAndSettle();

    // ── Step 1: room + count ──
    expect(find.text('Choose room type'), findsOneWidget);
    await tester.tap(find.text('Double room'));
    await tester.pump();
    // The meal is fixed by the published offer, not freely selectable.
    await tester.ensureVisible(find.text('Full board'));
    // add a second pilgrim
    await tester.ensureVisible(find.byIcon(Icons.add_rounded));
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

    // Passport data is deliberately collected after booking, per traveller.
    expect(find.text('Passport number'), findsNothing);
    // Fill both pilgrims: name + DOB only.
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Karwan Omar');
    await tester.pump();
    // pilgrim 1 DOB
    await tester.ensureVisible(find.text('Select date').first);
    await tester.tap(find.text('Select date').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // pilgrim 2 (field order: passportName1, localName1, phone1,
    // passportName2, localName2, phone2)
    await tester.enterText(textFields.at(3), 'Zhyan Mohammed');
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
    expect(find.text('Full board'), findsOneWidget);
    await tester.ensureVisible(find.text('Pay directly in the FIB app'));
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
    expect(p.bookings.first.mealPreference, 'Full board');
  });
}
