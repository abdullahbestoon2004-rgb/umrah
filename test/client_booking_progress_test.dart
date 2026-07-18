import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_app/models/booking_model.dart';
import 'package:umrah_app/models/client_booking_progress.dart';

Booking booking({
  String stage = 'confirmed',
  String paymentStatus = 'paid',
  String refundStatus = 'none',
  List<String> documents = const [],
  List<String> visas = const [],
}) => Booking(
  id: 'booking-id',
  offerId: 'offer-id',
  companyId: 'company-id',
  title: 'Umrah',
  companyName: 'Travel Co',
  gradColors: const [Colors.green, Colors.black],
  departureDate: DateTime(2030, 3, 8),
  returnDate: DateTime(2030, 3, 18),
  travelers: 1,
  status: 'Confirmed',
  operationalStage: stage,
  paymentStatus: paymentStatus,
  ref: 'UM-TEST',
  total: 100,
  refundStatus: refundStatus,
  documentStatuses: documents,
  visaStatuses: visas,
);

void main() {
  group('getClientBookingProgress', () {
    test('maps awaiting payment to booking and a payment action', () {
      final result = getClientBookingProgress(
        booking(stage: 'awaiting_payment', paymentStatus: 'unpaid'),
      );

      expect(result.currentStage, 1);
      expect(result.titleKey, 'completePayment');
      expect(result.primaryAction.target, BookingActionTarget.payment);
      expect(result.requiresClientAction, isTrue);
    });

    test('maps rejected documents to the documents stage', () {
      final result = getClientBookingProgress(
        booking(documents: const ['approved', 'rejected']),
      );

      expect(result.currentStage, 2);
      expect(result.titleKey, 'documentReplacement');
      expect(result.primaryAction.target, BookingActionTarget.documents);
    });

    test('maps submitted visa to visa processing', () {
      final result = getClientBookingProgress(
        booking(documents: const ['approved'], visas: const ['under_review']),
      );

      expect(result.currentStage, 3);
      expect(result.completedStages, [1, 2]);
      expect(result.titleKey, 'visaProcessing');
    });

    test('maps ready backend state to the fourth stage', () {
      final result = getClientBookingProgress(booking(stage: 'ready'));

      expect(result.currentStage, 4);
      expect(result.completedStages, [1, 2, 3]);
      expect(result.primaryAction.target, BookingActionTarget.travel);
    });
  });

  group('isActiveBooking', () {
    test('includes every in-flight operational state', () {
      for (final stage in activeBookingOperationalStages) {
        expect(isActiveBooking(booking(stage: stage)), isTrue, reason: stage);
      }
    });

    test('allows a new booking after terminal or fully refunded states', () {
      for (final stage in ['completed', 'cancelled', 'rejected', 'expired']) {
        expect(isActiveBooking(booking(stage: stage)), isFalse, reason: stage);
      }
      expect(
        isActiveBooking(booking(stage: 'confirmed', refundStatus: 'refunded')),
        isFalse,
      );
    });
  });
}
