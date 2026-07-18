import 'booking_model.dart';

enum BookingBadgeType { success, pending, danger, inactive }

enum BookingActionTarget { payment, documents, visa, travel, booking, message }

class BookingProgressAction {
  const BookingProgressAction(this.labelKey, this.target);

  final String labelKey;
  final BookingActionTarget target;
}

class ClientBookingProgress {
  const ClientBookingProgress({
    required this.currentStage,
    required this.titleKey,
    required this.descriptionKey,
    required this.badgeKey,
    required this.badgeType,
    required this.primaryAction,
    this.secondaryAction,
    required this.requiresClientAction,
  });

  final int currentStage;
  final String titleKey;
  final String descriptionKey;
  final String badgeKey;
  final BookingBadgeType badgeType;
  final BookingProgressAction primaryAction;
  final BookingProgressAction? secondaryAction;
  final bool requiresClientAction;

  List<int> get completedStages =>
      List<int>.generate(currentStage - 1, (index) => index + 1);
}

const activeBookingOperationalStages = <String>{
  'requested',
  'needs_information',
  'awaiting_payment',
  'confirmed',
  'ready',
  'in_progress',
};

bool isActiveBooking(Booking booking) {
  if (const {
    'completed',
    'cancelled',
    'rejected',
    'expired',
  }.contains(booking.operationalStage)) {
    return false;
  }
  if (const {'completed', 'refunded'}.contains(booking.refundStatus)) {
    return false;
  }
  return activeBookingOperationalStages.contains(booking.operationalStage);
}

/// Converts backend workflow and traveller statuses into exactly four
/// client-facing stages. UI widgets should not branch on raw backend statuses.
ClientBookingProgress getClientBookingProgress(Booking booking) {
  if (booking.operationalStage == 'ready' ||
      booking.operationalStage == 'in_progress') {
    final daysUntilDeparture = booking.departureDate == null
        ? null
        : DateTime(
                booking.departureDate!.year,
                booking.departureDate!.month,
                booking.departureDate!.day,
              )
              .difference(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              )
              .inDays;
    return ClientBookingProgress(
      currentStage: 4,
      titleKey: daysUntilDeparture != null && daysUntilDeparture <= 3
          ? 'departureApproaching'
          : 'readyToTravel',
      descriptionKey: daysUntilDeparture != null && daysUntilDeparture <= 3
          ? 'departureApproachingBody'
          : 'readyToTravelBody',
      badgeKey: 'ready',
      badgeType: BookingBadgeType.success,
      primaryAction: const BookingProgressAction(
        'viewTravelDetails',
        BookingActionTarget.travel,
      ),
      requiresClientAction: false,
    );
  }

  if (booking.operationalStage == 'awaiting_payment' ||
      (booking.paymentStatus == 'unpaid' &&
          booking.operationalStage == 'requested' &&
          booking.payMethod == 'fib')) {
    return const ClientBookingProgress(
      currentStage: 1,
      titleKey: 'completePayment',
      descriptionKey: 'completePaymentBody',
      badgeKey: 'paymentRequired',
      badgeType: BookingBadgeType.danger,
      primaryAction: BookingProgressAction(
        'payNow',
        BookingActionTarget.payment,
      ),
      requiresClientAction: true,
    );
  }

  if (booking.operationalStage == 'requested') {
    return const ClientBookingProgress(
      currentStage: 1,
      titleKey: 'waitingConfirmation',
      descriptionKey: 'waitingConfirmationBody',
      badgeKey: 'waiting',
      badgeType: BookingBadgeType.pending,
      primaryAction: BookingProgressAction(
        'viewBooking',
        BookingActionTarget.booking,
      ),
      requiresClientAction: false,
    );
  }

  final documentStatuses = booking.documentStatuses;
  final visaStatuses = booking.visaStatuses;

  if (visaStatuses.contains('rejected')) {
    return const ClientBookingProgress(
      currentStage: 3,
      titleKey: 'visaActionRequired',
      descriptionKey: 'visaActionRequiredBody',
      badgeKey: 'actionRequired',
      badgeType: BookingBadgeType.danger,
      primaryAction: BookingProgressAction(
        'viewDetails',
        BookingActionTarget.visa,
      ),
      secondaryAction: BookingProgressAction(
        'messageCompany',
        BookingActionTarget.message,
      ),
      requiresClientAction: true,
    );
  }
  if (visaStatuses.contains('submitted') ||
      visaStatuses.contains('under_review')) {
    return const ClientBookingProgress(
      currentStage: 3,
      titleKey: 'visaProcessing',
      descriptionKey: 'visaProcessingBody',
      badgeKey: 'processing',
      badgeType: BookingBadgeType.pending,
      primaryAction: BookingProgressAction(
        'viewVisaStatus',
        BookingActionTarget.visa,
      ),
      requiresClientAction: false,
    );
  }
  if (visaStatuses.isNotEmpty &&
      visaStatuses.every((status) => status == 'approved')) {
    return const ClientBookingProgress(
      currentStage: 3,
      titleKey: 'visaApproved',
      descriptionKey: 'visaApprovedBody',
      badgeKey: 'confirmed',
      badgeType: BookingBadgeType.success,
      primaryAction: BookingProgressAction(
        'viewBooking',
        BookingActionTarget.booking,
      ),
      requiresClientAction: false,
    );
  }

  if (documentStatuses.contains('rejected') ||
      booking.operationalStage == 'needs_information') {
    return const ClientBookingProgress(
      currentStage: 2,
      titleKey: 'documentReplacement',
      descriptionKey: 'documentReplacementBody',
      badgeKey: 'actionRequired',
      badgeType: BookingBadgeType.danger,
      primaryAction: BookingProgressAction(
        'fixDocument',
        BookingActionTarget.documents,
      ),
      requiresClientAction: true,
    );
  }
  if (documentStatuses.contains('uploaded') ||
      documentStatuses.contains('under_review')) {
    return const ClientBookingProgress(
      currentStage: 2,
      titleKey: 'documentsReview',
      descriptionKey: 'documentsReviewBody',
      badgeKey: 'processing',
      badgeType: BookingBadgeType.pending,
      primaryAction: BookingProgressAction(
        'viewDocuments',
        BookingActionTarget.documents,
      ),
      requiresClientAction: false,
    );
  }
  if (documentStatuses.isNotEmpty &&
      documentStatuses.every((status) => status == 'approved')) {
    return const ClientBookingProgress(
      currentStage: 2,
      titleKey: 'documentsApproved',
      descriptionKey: 'documentsApprovedBody',
      badgeKey: 'confirmed',
      badgeType: BookingBadgeType.success,
      primaryAction: BookingProgressAction(
        'viewBooking',
        BookingActionTarget.booking,
      ),
      requiresClientAction: false,
    );
  }

  return const ClientBookingProgress(
    currentStage: 2,
    titleKey: 'documentsRequired',
    descriptionKey: 'documentsRequiredBody',
    badgeKey: 'actionRequired',
    badgeType: BookingBadgeType.danger,
    primaryAction: BookingProgressAction(
      'uploadDocuments',
      BookingActionTarget.documents,
    ),
    requiresClientAction: true,
  );
}
