import 'package:flutter_test/flutter_test.dart';

import 'package:umrah_app/models/commission_model.dart';
import 'package:umrah_app/providers/app_provider.dart';

import 'features_test.dart' show FakeService;

/// Tests for the paths where a bug costs somebody real money: the commission
/// ledger, cash/FIB settlement, and cancellation after payment.
void main() {
  group('commission ledger', () {
    test('confirming cash opens a commission the agency owes', () async {
      final shared = FakeService();

      final client = AppProvider(service: shared, autoLoad: false);
      await client.init();
      await client.signIn('client@test.com', 'pass');
      final offer = client.allOffers.first;
      await client.confirmBooking(offer, 2);
      final bookingId = client.bookings.first.id;
      final bookingTotal = client.bookings.first.total;

      final agency = AppProvider(service: shared, autoLoad: false);
      await agency.init();
      await agency.signIn('agency@test.com', 'pass');
      await agency.loadAgencyBookings();
      await agency.respondToBooking(bookingId, confirm: true);

      // No money has changed hands yet, so nothing is owed.
      await agency.loadCommissions();
      expect(agency.commissions, isEmpty);
      expect(agency.commissionsOwed, 0);

      await agency.confirmCashPayment(bookingId);
      await agency.loadCommissions();

      expect(agency.commissions.length, 1);
      expect(agency.commissions.first.bookingId, bookingId);
      expect(agency.commissions.first.status, 'owed');
      expect(agency.commissionsOwed, closeTo(bookingTotal * 0.05, 0.001));
      expect(agency.commissionsCollected, 0);
    });

    test('collecting moves the amount from owed to collected', () async {
      final shared = FakeService();
      final agency = AppProvider(service: shared, autoLoad: false);
      await agency.init();
      await agency.signIn('agency@test.com', 'pass');

      shared.commissions.add(
        Commission(
          id: 'com1',
          bookingId: 'b1',
          companyId: 'c1',
          amount: 250000,
          status: 'owed',
          createdAt: DateTime.now(),
        ),
      );
      await agency.loadCommissions();
      expect(agency.commissionsOwed, 250000);

      final ok = await agency.markCommissionCollected('com1');
      expect(ok, isTrue);
      expect(agency.commissionsOwed, 0);
      expect(agency.commissionsCollected, 250000);
    });

    test('a failed collection leaves the ledger untouched', () async {
      final shared = FakeService();
      final agency = AppProvider(service: shared, autoLoad: false);
      await agency.init();
      await agency.signIn('agency@test.com', 'pass');

      shared.commissions.add(
        Commission(
          id: 'com1',
          bookingId: 'b1',
          companyId: 'c1',
          amount: 250000,
          status: 'owed',
          createdAt: DateTime.now(),
        ),
      );
      await agency.loadCommissions();

      // 'nope' does not exist — the ledger must not silently mark anything paid.
      final ok = await agency.markCommissionCollected('nope');
      expect(ok, isFalse);
      expect(agency.commissionsOwed, 250000);
      expect(agency.commissionsCollected, 0);
    });

    test('an agency only sees its own commissions; admin sees all', () async {
      final shared = FakeService();
      shared.commissions.addAll([
        Commission(
          id: 'com1',
          bookingId: 'b1',
          companyId: 'c1',
          amount: 100000,
          status: 'owed',
          createdAt: DateTime.now(),
        ),
        Commission(
          id: 'com2',
          bookingId: 'b2',
          companyId: 'c2',
          amount: 400000,
          status: 'owed',
          createdAt: DateTime.now(),
        ),
      ]);

      final agency = AppProvider(service: shared, autoLoad: false);
      await agency.init();
      await agency.signIn('agency@test.com', 'pass');
      await agency.loadCommissions();
      expect(agency.commissions.map((c) => c.companyId).toSet(), {'c1'});
      expect(agency.commissionsOwed, 100000);

      final admin = AppProvider(service: shared, autoLoad: false);
      await admin.init();
      await admin.signIn('admin@test.com', 'pass');
      await admin.loadCommissions();
      expect(admin.commissions.length, 2);
      expect(admin.commissionsOwed, 500000);
    });
  });

  group('payment', () {
    test('quote charges per traveller and rounds rooms up', () async {
      final p = AppProvider(service: FakeService(), autoLoad: false);
      await p.init();
      await p.signIn('client@test.com', 'pass');
      final offer = p.allOffers.first;

      final quote = await p.bookingQuote(offer, travelers: 3, roomOccupancy: 2);

      expect(quote.travellers, 3);
      // 3 pilgrims in 2-person rooms needs 2 rooms, not 1.5.
      expect(quote.roomCount, 2);
      expect(quote.totalIqd, quote.unitPriceIqd * 3);
    });

    test(
      'FIB payment returns a reference the client can pay against',
      () async {
        final p = AppProvider(service: FakeService(), autoLoad: false);
        await p.init();
        await p.signIn('client@test.com', 'pass');
        await p.confirmBooking(p.allOffers.first, 1);

        final result = await p.initiateFibPayment(p.bookings.first);
        expect(result, isNotNull);
        expect(result!['payment_id'], isNotNull);
        expect((result['fib'] as Map)['readableCode'], isNotNull);
      },
    );
  });

  group('cancellation', () {
    test('cancelling a paid booking marks it cancelled', () async {
      final shared = FakeService();

      final client = AppProvider(service: shared, autoLoad: false);
      await client.init();
      await client.signIn('client@test.com', 'pass');
      await client.confirmBooking(client.allOffers.first, 2);
      final bookingId = client.bookings.first.id;

      final agency = AppProvider(service: shared, autoLoad: false);
      await agency.init();
      await agency.signIn('agency@test.com', 'pass');
      await agency.loadAgencyBookings();
      await agency.respondToBooking(bookingId, confirm: true);
      await agency.confirmCashPayment(bookingId);

      final err = await client.cancelBooking(bookingId, 'Plans changed');
      expect(err, isNull);
      expect(client.bookings.first.status, 'Cancelled');
    });

    test('cancelling an unknown booking reports an error', () async {
      final p = AppProvider(service: FakeService(), autoLoad: false);
      await p.init();
      await p.signIn('client@test.com', 'pass');

      final err = await p.cancelBooking('does-not-exist', 'oops');
      expect(err, isNotNull);
    });
  });
}
