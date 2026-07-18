import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../models/offer_model.dart';
import '../../providers/app_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/app_snackbar.dart';

void openBookingDocuments(BuildContext context, Booking booking) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(),
    builder: (_) => _PassportDocumentsSheet(booking: booking),
  );
}

Future<void> startBookingPayment(BuildContext context, Booking booking) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final data = await context.read<AppProvider>().initiateFibPayment(booking);
  if (!context.mounted) return;
  if (data == null) {
    messenger.showSnackBar(
      appSnack(t.workflowPaymentStartFailed, isError: true),
    );
    return;
  }
  final fib = data['fib'] is Map
      ? Map<String, dynamic>.from(data['fib'] as Map)
      : <String, dynamic>{};
  final code =
      (fib['readableCode'] ?? fib['paymentId'] ?? data['payment_id'] ?? '')
          .toString();
  final link = (fib['personalAppLink'] ?? '').toString();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.workflowFibPaymentTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.workflowFibPaymentBody),
          const SizedBox(height: 12),
          SelectableText(
            code,
            style: AppTheme.serif(20, color: AppColors.primary),
          ),
          if (link.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              link,
              style: AppTheme.sans(11, color: AppColors.muted),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(
              ClipboardData(text: link.isNotEmpty ? link : code),
            );
            Navigator.pop(dialogContext);
          },
          child: Text(t.workflowCopyPayment),
        ),
      ],
    ),
  );
}

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bookings = context.watch<AppProvider>().bookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const IslamicPattern(opacity: 0.04, isEightFold: true),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.bookingsTitle, style: AppTheme.serif(30)),
                        const SizedBox(height: 3),
                        Text(
                          t.bookingsTripCount(bookings.length),
                          style: AppTheme.sans(
                            13,
                            color: const Color(0xFF7D8A82),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (bookings.isEmpty)
                  SliverFillRemaining(child: _EmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: EdgeInsets.fromLTRB(
                          22,
                          0,
                          22,
                          i < bookings.length - 1 ? 14 : 24,
                        ),
                        child: _BookingCard(booking: bookings[i]),
                      ),
                      childCount: bookings.length,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: Text(t.bookingsTitle, style: AppTheme.serif(20)),
      ),
      body: Stack(
        children: [
          const IslamicPattern(opacity: 0.04, isEightFold: true),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
            child: _BookingCard(booking: booking),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  String _statusLabel(AppLocalizations t) {
    switch (booking.operationalStage) {
      case 'confirmed':
        return t.bookingsStatusConfirmed;
      case 'requested':
        return t.bookingsStatusPending;
      case 'needs_information':
        return t.workflowChangesRequired;
      case 'awaiting_payment':
        return t.workflowAwaitingPayment;
      case 'ready':
        return t.workflowReadyToTravel;
      case 'in_progress':
        return t.workflowInProgress;
      case 'rejected':
        return t.workflowRejected;
      case 'expired':
        return t.workflowExpired;
      case 'cancelled':
        return t.bookingsStatusCancelled;
      case 'completed':
        return t.bookingsStatusCompleted;
      default:
        return booking.status;
    }
  }

  String _dateLabel(AppLocalizations t) {
    final d = booking.departureDate;
    if (d == null) return t.dateToBeScheduled;
    return '${d.day}/${d.month}/${d.year}';
  }

  void _openReviewDialog(BuildContext context) {
    final t = AppLocalizations.of(context);
    int rating = 5;
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(t.reviewDialogTitle, style: AppTheme.serif(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < rating;
                  return GestureDetector(
                    onTap: () => setDialogState(() => rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: AppColors.gold,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                style: AppTheme.sans(13.5),
                decoration: InputDecoration(
                  hintText: t.reviewCommentHint,
                  hintStyle: AppTheme.sans(13, color: AppColors.mutedLight),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                t.agencyDashboardCancel,
                style: AppTheme.sans(13, color: AppColors.muted),
              ),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final provider = context.read<AppProvider>();
                Navigator.pop(dialogCtx);
                final err = await provider.submitReview(
                  booking.id,
                  booking.companyId,
                  rating,
                  comment: commentCtrl.text.trim(),
                );
                messenger.showSnackBar(
                  err == null
                      ? appSnack(t.reviewSubmitted)
                      : appSnack(t.reviewFailed, isError: true),
                );
              },
              child: Text(
                t.reviewSubmit,
                style: AppTheme.sans(
                  13,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final reasonController = TextEditingController();
    final withheld = booking.nonRefundableDepositSnapshot
        ? (booking.depositIqdSnapshot * booking.travelers).clamp(
            0,
            booking.amountPaid,
          )
        : 0;
    final estimatedRefund = (booking.amountPaid - withheld).clamp(
      0,
      booking.amountPaid,
    );
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        String? reasonError;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(t.bookingsCancelTitle, style: AppTheme.serif(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.bookingsCancelBody(booking.titleFor(lang)),
                    style: AppTheme.sans(13, color: AppColors.inkLight),
                  ),
                  if (booking.cancellationPolicySnapshot.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      t.bookingCancellationPolicy,
                      style: AppTheme.sans(12, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.cancellationPolicySnapshot,
                      style: AppTheme.sans(12, color: AppColors.muted),
                    ),
                  ],
                  if (booking.amountPaid > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      '${t.bookingEstimatedRefund}: ${fmtIqd(estimatedRefund)}',
                      style: AppTheme.sans(
                        12.5,
                        weight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: t.bookingCancelReason,
                      hintText: t.bookingCancelReasonHint,
                      errorText: reasonError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  t.bookingsKeepBooking,
                  style: AppTheme.sans(13, color: AppColors.muted),
                ),
              ),
              TextButton(
                onPressed: () {
                  final value = reasonController.text.trim();
                  if (value.isEmpty) {
                    setDialogState(() => reasonError = t.bookingCancelReason);
                    return;
                  }
                  Navigator.pop(dialogCtx, value);
                },
                child: Text(
                  t.bookingsConfirmCancel,
                  style: AppTheme.sans(
                    13,
                    weight: FontWeight.w700,
                    color: AppColors.errorRed,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    reasonController.dispose();
    if (reason == null || !context.mounted) return;
    final err = await provider.cancelBooking(booking.id, reason);
    messenger.showSnackBar(
      err == null
          ? appSnack(t.bookingsCancelledSnack)
          : appSnack(t.bookingsCancelFailed, isError: true),
    );
  }

  Future<void> _startFibPayment(BuildContext context) async {
    await startBookingPayment(context, booking);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3729).withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: booking.gradColors,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              booking.titleFor(
                                Localizations.localeOf(context).languageCode,
                              ),
                              style: AppTheme.serif(17),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: booking.statusBg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              _statusLabel(t),
                              style: AppTheme.sans(
                                10.5,
                                weight: FontWeight.w700,
                                color: booking.statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        booking.companyNameFor(
                          Localizations.localeOf(context).languageCode,
                        ),
                        style: AppTheme.sans(
                          11.5,
                          color: const Color(0xFF7D8A82),
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Text(
                            _dateLabel(t),
                            style: AppTheme.sans(
                              11.5,
                              color: const Color(0xFF5E6B63),
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(color: Color(0xFF5E6B63)),
                          ),
                          Text(
                            t.bookingsPaxCount(booking.travelers),
                            style: AppTheme.sans(
                              11.5,
                              color: const Color(0xFF5E6B63),
                            ),
                          ),
                        ],
                      ),
                      if ((booking.roomLabel ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          booking.roomLabel!,
                          style: AppTheme.sans(
                            11.5,
                            color: AppColors.primary,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if ((booking.mealPreference ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${t.bookingSummaryMeal}: ${Offer.mealsLabel(booking.mealPreference!, t)}',
                          style: AppTheme.sans(11.5, color: AppColors.muted),
                        ),
                      ],
                      if ((booking.statusReason ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          booking.statusReason!,
                          style: AppTheme.sans(11.5, color: AppColors.errorRed),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (booking.operationalStage == 'awaiting_payment')
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  Text(
                    t.bookingAmountDueNow,
                    style: AppTheme.sans(11.5, color: AppColors.muted),
                  ),
                  const Spacer(),
                  Text(
                    fmtIqd(
                      (booking.amountDueNow - booking.amountPaid).clamp(
                        0,
                        booking.total,
                      ),
                    ),
                    style: AppTheme.sans(
                      12.5,
                      weight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          if (booking.expiresAt != null &&
              [
                'requested',
                'needs_information',
                'awaiting_payment',
              ].contains(booking.operationalStage))
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                t.bookingExpiresAt(
                  '${booking.expiresAt!.toLocal().day}/${booking.expiresAt!.toLocal().month} '
                  '${booking.expiresAt!.toLocal().hour.toString().padLeft(2, '0')}:'
                  '${booking.expiresAt!.toLocal().minute.toString().padLeft(2, '0')}',
                ),
                style: AppTheme.sans(11.5, color: AppColors.gold),
              ),
            ),
          if (booking.refundStatus == 'pending')
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                '${t.bookingEstimatedRefund}: ${fmtIqd(booking.refundDue)}',
                style: AppTheme.sans(
                  12,
                  weight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _PassportDocumentsButton(booking: booking),
          ),
          if (![
            'cancelled',
            'rejected',
            'expired',
          ].contains(booking.operationalStage))
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: _TripAnnouncementsButton(booking: booking),
            ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAF8F2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(19)),
              border: Border(
                top: BorderSide(
                  color: Color(0x260F5C4D),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.bookingsRefLabel(booking.ref),
                    style: AppTheme.sans(
                      11,
                      color: AppColors.muted,
                    ).copyWith(letterSpacing: 0.5, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if ([
                  'requested',
                  'needs_information',
                  'awaiting_payment',
                  'confirmed',
                  'ready',
                ].contains(booking.operationalStage)) ...[
                  if (booking.operationalStage == 'awaiting_payment' &&
                      booking.payMethod == 'fib') ...[
                    GestureDetector(
                      onTap: () => _startFibPayment(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t.workflowPayNow,
                          style: AppTheme.sans(
                            11,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: () => _confirmCancel(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.errorRed.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        t.bookingsCancelBooking,
                        style: AppTheme.sans(
                          11,
                          weight: FontWeight.w700,
                          color: AppColors.errorRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else if (booking.operationalStage == 'completed' &&
                    !context.watch<AppProvider>().hasReviewed(booking.id)) ...[
                  GestureDetector(
                    onTap: () => _openReviewDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.bookingsRateThisTrip,
                            style: AppTheme.sans(
                              11,
                              weight: FontWeight.w700,
                              color: const Color(0xFF8A7040),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  booking.totalFmt,
                  style: AppTheme.serif(18, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportDocumentsButton extends StatelessWidget {
  final Booking booking;
  const _PassportDocumentsButton({required this.booking});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => openBookingDocuments(context, booking),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/attention.png', width: 25, height: 25),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.bookingPassportDocuments,
                    style: AppTheme.sans(12.5, weight: FontWeight.w700),
                  ),
                  Text(
                    t.bookingPassportDocumentsBody(booking.travelers),
                    style: AppTheme.sans(10.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _TripAnnouncementsButton extends StatelessWidget {
  final Booking booking;
  const _TripAnnouncementsButton({required this.booking});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        backgroundColor: AppColors.background,
        builder: (sheetContext) => FutureBuilder(
          future: context.read<AppProvider>().tripAnnouncements(
            booking.offerId,
          ),
          builder: (context, snapshot) {
            final announcements = snapshot.data ?? const [];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.bookingTripUpdates, style: AppTheme.serif(21)),
                  const SizedBox(height: 14),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (announcements.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          t.bookingTripNoUpdates,
                          style: AppTheme.sans(13, color: AppColors.muted),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: announcements.length,
                        itemBuilder: (_, index) {
                          final announcement = announcements[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announcement.title,
                                    style: AppTheme.sans(
                                      13,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    announcement.body,
                                    style: AppTheme.sans(
                                      12,
                                      color: AppColors.inkLight,
                                    ).copyWith(height: 1.45),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: AppColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.bookingTripUpdates,
                style: AppTheme.sans(12.5, weight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}

enum _TravellerPhotoKind { passport, selfie }

class _PassportDocumentsSheet extends StatefulWidget {
  final Booking booking;
  const _PassportDocumentsSheet({required this.booking});

  @override
  State<_PassportDocumentsSheet> createState() =>
      _PassportDocumentsSheetState();
}

class _PassportDocumentsSheetState extends State<_PassportDocumentsSheet> {
  late Future<List<BookingTraveller>> _future;
  final Map<String, Uint8List> _passportImages = {};
  final Map<String, Uint8List> _selfies = {};
  final Set<String> _saving = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<AppProvider>().bookingTravellers(widget.booking.id);
  }

  Future<void> _showExample(_TravellerPhotoKind kind) async {
    final t = AppLocalizations.of(context);
    final passport = kind == _TravellerPhotoKind.passport;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.background,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390, maxHeight: 690),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        passport
                            ? t.identityPassportExampleTitle
                            : t.identitySelfieExampleTitle,
                        style: AppTheme.sans(19, weight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: t.identityClose,
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: Image.asset(
                        passport
                            ? 'assets/images/iraqi_passport_example.jpg'
                            : 'assets/images/man_selfie_example.jpg',
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  passport
                      ? t.identityPassportExampleCaption
                      : t.identitySelfieExampleCaption,
                  textAlign: TextAlign.center,
                  style: AppTheme.sans(
                    12.5,
                    color: AppColors.inkLight,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<ImageSource?> _chooseSource() {
    final t = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.identityChooseSource, style: AppTheme.serif(20)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: Text(t.identityCamera),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(t.identityGallery),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(
    BookingTraveller traveller,
    _TravellerPhotoKind kind,
  ) async {
    final source = await _chooseSource();
    if (source == null || !mounted) return;

    XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1800,
      );
    } catch (_) {
      if (mounted) {
        _showMessage(
          source == ImageSource.camera
              ? 'Camera is unavailable. Please use a physical device with camera access.'
              : 'Could not open the photo library.',
        );
      }
      return;
    }
    if (file == null || !mounted) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      if (kind == _TravellerPhotoKind.passport) {
        _passportImages[traveller.id] = bytes;
      } else {
        _selfies[traveller.id] = bytes;
      }
    });
  }

  Future<void> _save(BookingTraveller traveller) async {
    final t = AppLocalizations.of(context);
    final passport = _passportImages[traveller.id];
    final selfie = _selfies[traveller.id];
    if (passport == null || selfie == null) {
      _showMessage(t.bookingPassportRequired);
      return;
    }
    setState(() => _saving.add(traveller.id));
    final error = await context.read<AppProvider>().saveTravellerPassport(
      travellerId: traveller.id,
      bookingId: traveller.bookingId,
      passportBytes: passport,
      selfieBytes: selfie,
    );
    if (!mounted) return;
    setState(() => _saving.remove(traveller.id));
    if (error != null) {
      _showMessage(error);
      return;
    }
    setState(_reload);
  }

  Future<void> _uploadAdditional(BookingTraveller traveller) async {
    final t = AppLocalizations.of(context);
    const kinds = [
      'national_id',
      'residency_card',
      'vaccination',
      'agreement',
      'payment_receipt',
      'other',
    ];
    final kind = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
          children: [
            Text(t.bookingAdditionalDocument, style: AppTheme.serif(20)),
            const SizedBox(height: 10),
            for (final value in kinds)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(_documentKindLabel(value, t)),
                onTap: () => Navigator.pop(sheetContext, value),
              ),
          ],
        ),
      ),
    );
    if (kind == null || !mounted) return;
    final source = await _chooseSource();
    if (source == null || !mounted) return;
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (file == null || !mounted) return;
    final key = '${traveller.id}-additional';
    setState(() => _saving.add(key));
    final error = await context.read<AppProvider>().uploadTravellerDocument(
      travellerId: traveller.id,
      bookingId: traveller.bookingId,
      companyId: widget.booking.companyId,
      kind: kind,
      bytes: await file.readAsBytes(),
      fileName: file.name,
    );
    if (!mounted) return;
    setState(() => _saving.remove(key));
    if (error != null) {
      _showMessage(error);
      return;
    }
    _showMessage(t.bookingAdditionalDocumentUploaded);
    setState(_reload);
  }

  // Snackbars render behind this modal sheet, so feedback that must be seen
  // while it is open goes through a dialog instead.
  void _showMessage(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: Column(
            children: [
              SizedBox(
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      t.identityVerification,
                      style: AppTheme.sans(20, weight: FontWeight.w800),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: BackButton(
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              _BookingSecurityNotice(text: t.identitySecureBody),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<BookingTraveller>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final traveller = snapshot.data![index];
                        final passportBytes = _passportImages[traveller.id];
                        final selfieBytes = _selfies[traveller.id];
                        final hasPassport =
                            passportBytes != null ||
                            (traveller.passportImagePath ?? '').isNotEmpty;
                        final hasSelfie =
                            selfieBytes != null ||
                            (traveller.selfieImagePath ?? '').isNotEmpty;
                        final canSave =
                            passportBytes != null && selfieBytes != null;
                        return Container(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${t.bookingPilgrimN(index + 1)} · ${traveller.fullName}',
                                style: AppTheme.sans(
                                  14,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _TravellerPhotoTile(
                                step: 1,
                                title: t.identityPassportPhoto,
                                instructions: [
                                  t.identityPassportInstruction1,
                                  t.identityPassportInstruction2,
                                  t.identityPassportInstruction3,
                                ],
                                placeholder: t.identityPassportPlaceholder,
                                icon: Icons.menu_book_outlined,
                                bytes: passportBytes,
                                uploaded: hasPassport,
                                onViewExample: () =>
                                    _showExample(_TravellerPhotoKind.passport),
                                onPick: () => _pick(
                                  traveller,
                                  _TravellerPhotoKind.passport,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _TravellerPhotoTile(
                                step: 2,
                                title: t.identitySelfiePhoto,
                                instructions: [
                                  t.identitySelfieInstruction1,
                                  t.identitySelfieInstruction2,
                                  t.identitySelfieInstruction3,
                                  t.identitySelfieInstruction4,
                                ],
                                placeholder: t.identitySelfiePlaceholder,
                                icon: Icons.face_retouching_natural_outlined,
                                bytes: selfieBytes,
                                uploaded: hasSelfie,
                                onViewExample: () =>
                                    _showExample(_TravellerPhotoKind.selfie),
                                onPick: () => _pick(
                                  traveller,
                                  _TravellerPhotoKind.selfie,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed:
                                      canSave && !_saving.contains(traveller.id)
                                      ? () => _save(traveller)
                                      : null,
                                  child: _saving.contains(traveller.id)
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(t.accountSaveChanges),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _saving.contains(
                                        '${traveller.id}-additional',
                                      )
                                      ? null
                                      : () => _uploadAdditional(traveller),
                                  icon: const Icon(Icons.upload_file_outlined),
                                  label: Text(t.bookingAdditionalDocument),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _documentKindLabel(String kind, AppLocalizations t) => switch (kind) {
  'national_id' => t.bookingDocumentNationalId,
  'residency_card' => t.bookingDocumentResidency,
  'vaccination' => t.bookingDocumentVaccination,
  'agreement' => t.bookingDocumentAgreement,
  'payment_receipt' => t.bookingDocumentPaymentReceipt,
  _ => t.bookingDocumentOther,
};

class _BookingSecurityNotice extends StatelessWidget {
  const _BookingSecurityNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.security_rounded, color: Color(0xFF09836E), size: 30),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).identitySecureTitle,
                style: AppTheme.sans(15, weight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: AppTheme.sans(
                  11.5,
                  color: AppColors.inkLight,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TravellerPhotoTile extends StatelessWidget {
  const _TravellerPhotoTile({
    required this.step,
    required this.title,
    required this.instructions,
    required this.placeholder,
    required this.icon,
    required this.bytes,
    required this.uploaded,
    required this.onViewExample,
    required this.onPick,
  });

  final int step;
  final String title;
  final List<String> instructions;
  final String placeholder;
  final IconData icon;
  final Uint8List? bytes;
  final bool uploaded;
  final VoidCallback onViewExample;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final stepLabel = language == 'en' ? '$step' : (step == 1 ? '١' : '٢');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepLabel. $title',
            style: AppTheme.sans(17, weight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          ...instructions.map(
            (instruction) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.inkLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instruction,
                      style: AppTheme.sans(
                        11.5,
                        color: AppColors.inkLight,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 13),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCE1D8)),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes != null
                ? Image.memory(bytes!, fit: BoxFit.cover)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        uploaded ? Icons.check_circle_outline : icon,
                        size: 38,
                        color: uploaded
                            ? AppColors.primary
                            : AppColors.mutedLight,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        uploaded ? t.bookingPassportImageUploaded : placeholder,
                        style: AppTheme.sans(
                          12,
                          color: AppColors.muted,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewExample,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: Color(0xFFE1E5DF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(
                    t.identityViewExample,
                    style: AppTheme.sans(12, weight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPick,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: Text(
                    bytes == null && !uploaded
                        ? t.identityUploadPhoto
                        : t.identityChangePhoto,
                    style: AppTheme.sans(
                      12,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFECF0E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(t.bookingsEmptyTitle, style: AppTheme.serif(22)),
          const SizedBox(height: 5),
          Text(
            t.bookingsEmptyBody,
            style: AppTheme.sans(13, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () async {
              final provider = context.read<AppProvider>();
              await provider.loadData();
              if (context.mounted) provider.setTab(2);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              t.bookingsBrowseOffers,
              style: AppTheme.sans(
                13,
                weight: FontWeight.w700,
                color: const Color(0xFFF6F2E9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
