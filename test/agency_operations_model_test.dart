import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_app/models/agency_operations_model.dart';
import 'package:umrah_app/models/booking_model.dart';

void main() {
  group('AgencyWallet', () {
    test('reserves pending payouts from the available balance', () {
      final wallet = AgencyWallet(
        balanceIqd: 1000000,
        payouts: [
          AgencyPayout(
            id: 'pending',
            amountIqd: 250000,
            status: 'pending',
            createdAt: DateTime(2026),
          ),
          AgencyPayout(
            id: 'paid',
            amountIqd: 100000,
            status: 'completed',
            createdAt: DateTime(2026),
          ),
        ],
      );

      expect(wallet.pendingPayoutIqd, 250000);
      expect(wallet.availablePayoutIqd, 750000);
      expect(wallet.amountOwedToPlatformIqd, 0);
    });

    test('represents a negative balance as money owed to Tawaf', () {
      const wallet = AgencyWallet(balanceIqd: -175000);

      expect(wallet.availablePayoutIqd, 0);
      expect(wallet.amountOwedToPlatformIqd, 175000);
    });
  });

  test('BookingTraveller keeps identity, document, visa, and seat tracks', () {
    final traveller = BookingTraveller.fromRow({
      'id': 'traveller-1',
      'booking_id': 'booking-1',
      'full_name': 'KARWAN OMAR',
      'local_name': 'کاروان عومەر',
      'date_of_birth': '1990-04-20',
      'passport_expiry_date': '2030-05-01',
      'document_status': 'approved',
      'visa_status': 'submitted',
      'visa_reference': 'VISA-123',
      'transport_seat': '12A',
    });

    expect(traveller.fullName, 'KARWAN OMAR');
    expect(traveller.localName, 'کاروان عومەر');
    expect(traveller.documentStatus, 'approved');
    expect(traveller.visaStatus, 'submitted');
    expect(traveller.visaReference, 'VISA-123');
    expect(traveller.transportSeat, '12A');
    expect(traveller.passportExpiryDate, DateTime(2030, 5, 1));
  });
}
