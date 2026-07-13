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

  void _confirmCancel(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.bookingsCancelTitle, style: AppTheme.serif(20)),
        content: Text(
          t.bookingsCancelBody(booking.titleFor(lang)),
          style: AppTheme.sans(13, color: AppColors.inkLight),
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
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final err = await provider.cancelBooking(booking.id);
              messenger.showSnackBar(
                err == null
                    ? appSnack(t.bookingsCancelledSnack)
                    : appSnack(t.bookingsCancelFailed, isError: true),
              );
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
  }

  Future<void> _startFibPayment(BuildContext context) async {
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
      builder: (dialogCtx) => AlertDialog(
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
              Navigator.pop(dialogCtx);
            },
            child: Text(t.workflowCopyPayment),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3729).withOpacity(0.06),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _PassportDocumentsButton(booking: booking),
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
                        color: AppColors.errorRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.errorRed.withOpacity(0.25),
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
                        color: AppColors.gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.4),
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
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.background,
        builder: (_) => _PassportDocumentsSheet(booking: booking),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.16)),
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
  final Map<String, TextEditingController> _controllers = {};
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

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _showExample(
    _TravellerPhotoKind kind, {
    required bool beforePicking,
  }) async {
    final t = AppLocalizations.of(context);
    final passport = kind == _TravellerPhotoKind.passport;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.background,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(t.identityExampleTitle, style: AppTheme.serif(20)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        passport
                            ? 'assets/images/iraqi_passport_example.jpg'
                            : 'assets/images/man_selfie_example.jpg',
                        height: 320,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 320,
                          width: double.infinity,
                          color: AppColors.surfaceAlt,
                          alignment: Alignment.center,
                          child: Icon(
                            passport
                                ? Icons.badge_outlined
                                : Icons.face_retouching_natural_outlined,
                            size: 40,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...(passport
                            ? [
                                t.identityPassportInstruction1,
                                t.identityPassportInstruction2,
                                t.identityPassportInstruction3,
                              ]
                            : [
                                t.identitySelfieInstruction1,
                                t.identitySelfieInstruction2,
                                t.identitySelfieInstruction3,
                              ])
                        .map(
                          (instruction) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 17,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    instruction,
                                    style: AppTheme.sans(
                                      12.5,
                                      color: AppColors.inkLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(t.identityClose),
              ),
              if (beforePicking)
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(t.identityContinue),
                ),
            ],
          ),
        ) ??
        false;
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
    final canContinue = await _showExample(kind, beforePicking: true);
    if (!canContinue || !mounted) return;

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
    final passportNo = _controllers[traveller.id]!.text.trim();
    final passport = _passportImages[traveller.id];
    final selfie = _selfies[traveller.id];
    if (passportNo.isEmpty || passport == null || selfie == null) {
      _showMessage(t.bookingPassportRequired);
      return;
    }
    setState(() => _saving.add(traveller.id));
    final error = await context.read<AppProvider>().saveTravellerPassport(
      travellerId: traveller.id,
      bookingId: traveller.bookingId,
      passportNo: passportNo,
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
          20,
          18,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.86,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.bookingPassportDocuments, style: AppTheme.serif(22)),
              const SizedBox(height: 4),
              Text(
                t.bookingPassportPrivacy,
                style: AppTheme.sans(12, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<BookingTraveller>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.separated(
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final traveller = snapshot.data![index];
                        final controller = _controllers.putIfAbsent(
                          traveller.id,
                          () => TextEditingController(
                            text: traveller.passportNo ?? '',
                          ),
                        );
                        final passportBytes = _passportImages[traveller.id];
                        final selfieBytes = _selfies[traveller.id];
                        final hasPassport =
                            passportBytes != null ||
                            (traveller.passportImagePath ?? '').isNotEmpty;
                        final hasSelfie =
                            selfieBytes != null ||
                            (traveller.selfieImagePath ?? '').isNotEmpty;
                        final canSave =
                            controller.text.trim().isNotEmpty &&
                            passportBytes != null &&
                            selfieBytes != null;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
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
                              const SizedBox(height: 10),
                              TextField(
                                controller: controller,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: t.bookingPassportNo,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _TravellerPhotoTile(
                                title: t.identityPassportPhoto,
                                icon: Icons.badge_outlined,
                                bytes: passportBytes,
                                uploaded: hasPassport,
                                onViewExample: () => _showExample(
                                  _TravellerPhotoKind.passport,
                                  beforePicking: false,
                                ),
                                onPick: () => _pick(
                                  traveller,
                                  _TravellerPhotoKind.passport,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _TravellerPhotoTile(
                                title: t.identitySelfiePhoto,
                                icon: Icons.face_retouching_natural_outlined,
                                bytes: selfieBytes,
                                uploaded: hasSelfie,
                                onViewExample: () => _showExample(
                                  _TravellerPhotoKind.selfie,
                                  beforePicking: false,
                                ),
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

class _TravellerPhotoTile extends StatelessWidget {
  const _TravellerPhotoTile({
    required this.title,
    required this.icon,
    required this.bytes,
    required this.uploaded,
    required this.onViewExample,
    required this.onPick,
  });

  final String title;
  final IconData icon;
  final Uint8List? bytes;
  final bool uploaded;
  final VoidCallback onViewExample;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.sans(13, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 140,
              width: double.infinity,
              color: AppColors.surface,
              child: bytes != null
                  ? Image.memory(bytes!, fit: BoxFit.cover)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          uploaded ? Icons.check_circle_outline : icon,
                          size: 34,
                          color: uploaded ? AppColors.primary : AppColors.muted,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          uploaded
                              ? t.bookingPassportImageUploaded
                              : t.identityNoPhoto,
                          style: AppTheme.sans(11.5, color: AppColors.muted),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewExample,
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: Text(t.identityViewExample),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 17),
                  label: Text(
                    bytes == null && !uploaded
                        ? t.identityUploadPhoto
                        : t.identityChangePhoto,
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
          GestureDetector(
            onTap: () => context.read<AppProvider>().setTab(2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
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
          ),
        ],
      ),
    );
  }
}
