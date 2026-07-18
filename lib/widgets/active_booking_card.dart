import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking_model.dart';
import '../models/client_booking_progress.dart';
import '../models/company_model.dart';
import '../models/offer_model.dart';
import '../providers/app_provider.dart';
import '../screens/bookings/bookings_screen.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  final String label;
  final BookingBadgeType type;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (type) {
      BookingBadgeType.success => (const Color(0xFFE7F1EC), AppColors.primary),
      BookingBadgeType.pending => (
        const Color(0xFFFFF4D8),
        const Color(0xFF8A6823),
      ),
      BookingBadgeType.danger => (const Color(0xFFF9EAE7), AppColors.errorRed),
      BookingBadgeType.inactive => (const Color(0xFFF0F1EF), AppColors.muted),
    };
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTheme.sans(
            10.5,
            weight: FontWeight.w800,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class BookingProgressSteps extends StatelessWidget {
  const BookingProgressSteps({
    super.key,
    required this.currentStage,
    required this.labels,
  });

  final int currentStage;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return Semantics(
      label:
          '${labels[currentStage - 1]}, ${currentStage.toString()} of ${labels.length}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: 28,
              child: Row(
                children: [
                  for (var index = 0; index < 4; index++) ...[
                    _ProgressDot(stage: index + 1, currentStage: currentStage),
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: index + 1 < currentStage
                              ? AppColors.primary
                              : const Color(0xFFD9DDD9),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                for (final label in labels)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: direction == TextDirection.rtl
                          ? TextAlign.center
                          : TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        10.5,
                        weight: FontWeight.w700,
                        color: AppColors.inkLight,
                      ),
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

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.stage, required this.currentStage});

  final int stage;
  final int currentStage;

  @override
  Widget build(BuildContext context) {
    final completed = stage < currentStage;
    final current = stage == currentStage;
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? AppColors.primary
            : current
            ? AppColors.gold
            : AppColors.surface,
        border: completed || current
            ? null
            : Border.all(color: const Color(0xFFD9DDD9), width: 2),
      ),
      child: completed
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
          : current
          ? const Icon(Icons.circle, color: Colors.white, size: 8)
          : null,
    );
  }
}

class BookingNextAction extends StatelessWidget {
  const BookingNextAction({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final secondary = secondaryLabel == null
          ? null
          : OutlinedButton(
              onPressed: onSecondary,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(secondaryLabel!),
            );
      final primary = FilledButton(
        onPressed: onPrimary,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          primaryLabel,
          style: AppTheme.sans(
            13.5,
            weight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
      if (secondary == null) {
        return SizedBox(width: double.infinity, child: primary);
      }
      if (constraints.maxWidth >= 430) {
        return Row(
          children: [
            Expanded(child: secondary),
            const SizedBox(width: 10),
            Expanded(child: primary),
          ],
        );
      }
      return Column(
        children: [
          SizedBox(width: double.infinity, child: primary),
          const SizedBox(height: 9),
          SizedBox(width: double.infinity, child: secondary),
        ],
      );
    },
  );
}

class ActiveBookingCard extends StatelessWidget {
  const ActiveBookingCard({
    super.key,
    required this.booking,
    this.offer,
    this.company,
  });

  final Booking booking;
  final Offer? offer;
  final Company? company;

  @override
  Widget build(BuildContext context) {
    final copy = BookingProgressCopy.of(context);
    final progress = getClientBookingProgress(booking);
    final returnDate = booking.returnDate ?? offer?.returnDate;
    final companyVerified =
        booking.companyVerified || (company?.isVerified ?? false);
    final dateLine = copy.dateLine(
      booking.departureDate,
      returnDate,
      offer?.days,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 4, 22, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  copy.text('upcomingUmrah'),
                  style: AppTheme.sans(
                    11,
                    weight: FontWeight.w800,
                    color: AppColors.primary,
                  ).copyWith(letterSpacing: 0.4),
                ),
              ),
              const SizedBox(width: 10),
              BookingStatusBadge(
                label: copy.text(progress.badgeKey),
                type: progress.badgeType,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking.titleFor(copy.language),
            style: AppTheme.serif(20, color: AppColors.ink),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Flexible(
                child: Text(
                  booking.companyNameFor(copy.language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.sans(
                    12.5,
                    weight: FontWeight.w700,
                    color: AppColors.inkLight,
                  ),
                ),
              ),
              if (companyVerified) ...[
                const SizedBox(width: 5),
                Semantics(
                  label: copy.text('verifiedCompany'),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
              ],
            ],
          ),
          if (dateLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              dateLine,
              style: AppTheme.sans(11.5, color: AppColors.inkLight),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 17),
            child: Divider(height: 1, color: Color(0x1F0F5C4D)),
          ),
          BookingProgressSteps(
            currentStage: progress.currentStage,
            labels: [
              copy.text('booked'),
              copy.text('documents'),
              copy.text('visa'),
              copy.text('ready'),
            ],
          ),
          const SizedBox(height: 19),
          Text(
            copy.text(progress.titleKey),
            style: AppTheme.sans(16, weight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            progress.titleKey == 'departureApproaching'
                ? copy.departureApproachingBody(booking.departureDate)
                : copy.text(progress.descriptionKey),
            style: AppTheme.sans(
              12.5,
              color: AppColors.inkLight,
            ).copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
          BookingNextAction(
            primaryLabel: copy.text(progress.primaryAction.labelKey),
            onPrimary: () =>
                _performAction(context, progress.primaryAction.target),
            secondaryLabel: progress.secondaryAction == null
                ? null
                : copy.text(progress.secondaryAction!.labelKey),
            onSecondary: progress.secondaryAction == null
                ? null
                : () =>
                      _performAction(context, progress.secondaryAction!.target),
          ),
        ],
      ),
    );
  }

  void _performAction(BuildContext context, BookingActionTarget target) {
    if (target == BookingActionTarget.documents ||
        target == BookingActionTarget.visa) {
      openBookingDocuments(context, booking);
      return;
    }
    if (target == BookingActionTarget.payment && booking.payMethod == 'fib') {
      startBookingPayment(context, booking);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingDetailsScreen(booking: booking)),
    );
  }
}

class ActiveBookingSkeleton extends StatelessWidget {
  const ActiveBookingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: BookingProgressCopy.of(context).text('loadingBooking'),
    child: Container(
      margin: const EdgeInsets.fromLTRB(22, 4, 22, 18),
      padding: const EdgeInsets.all(18),
      height: 292,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonLine(width: 120),
          const SizedBox(height: 18),
          const _SkeletonLine(width: 210, height: 22),
          const SizedBox(height: 9),
          const _SkeletonLine(width: 145),
          const Spacer(),
          Row(
            children: List.generate(
              4,
              (_) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _SkeletonLine(width: double.infinity, height: 25),
                ),
              ),
            ),
          ),
          const Spacer(),
          const _SkeletonLine(width: 180),
          const SizedBox(height: 9),
          const _SkeletonLine(width: double.infinity),
          const SizedBox(height: 18),
          const _SkeletonLine(width: double.infinity, height: 48),
        ],
      ),
    ),
  );
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, this.height = 13});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE8EBE7),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

class ActiveBookingLoadError extends StatelessWidget {
  const ActiveBookingLoadError({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = BookingProgressCopy.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 4, 22, 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.errorRed),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              copy.text('loadError'),
              style: AppTheme.sans(12.5, color: AppColors.inkLight),
            ),
          ),
          TextButton(
            onPressed: context.read<AppProvider>().refreshBookings,
            child: Text(copy.text('tryAgain')),
          ),
        ],
      ),
    );
  }
}

class ActiveBookingGuard {
  const ActiveBookingGuard._();

  static Future<void> continueOrExplain(
    BuildContext context, {
    required VoidCallback onAllowed,
  }) async {
    final provider = context.read<AppProvider>();
    final copy = BookingProgressCopy.of(context);
    if (provider.bookingsLoadFailed || provider.bookingsLoading) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(copy.text('bookingUnavailable')),
          content: Text(copy.text('loadError')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(copy.text('close')),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                provider.refreshBookings();
              },
              child: Text(copy.text('tryAgain')),
            ),
          ],
        ),
      );
      return;
    }
    if (provider.activeBooking == null) {
      onAllowed();
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(copy.text('activeBookingTitle')),
        content: Text(copy.text('activeBookingMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(copy.text('close')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BookingDetailsScreen(booking: provider.activeBooking!),
                ),
              );
            },
            child: Text(copy.text('viewCurrentBooking')),
          ),
        ],
      ),
    );
  }
}

class BookingProgressCopy {
  BookingProgressCopy(this.language);

  final String language;

  factory BookingProgressCopy.of(BuildContext context) =>
      BookingProgressCopy(Localizations.localeOf(context).languageCode);

  static const _en = <String, String>{
    'upcomingUmrah': 'YOUR UPCOMING UMRAH',
    'booked': 'Booked',
    'documents': 'Documents',
    'visa': 'Visa',
    'ready': 'Ready',
    'paymentRequired': 'Payment Required',
    'waiting': 'Waiting',
    'confirmed': 'Confirmed',
    'actionRequired': 'Action Required',
    'processing': 'Processing',
    'completePayment': 'Complete your payment',
    'completePaymentBody':
        'Pay the required amount before the deadline to keep your reservation.',
    'waitingConfirmation': 'Waiting for company confirmation',
    'waitingConfirmationBody':
        'Your request was received. The company is reviewing your booking.',
    'documentsRequired': 'Documents required',
    'documentsRequiredBody':
        'Upload the missing documents to continue your Umrah application.',
    'documentsReview': 'Documents under review',
    'documentsReviewBody':
        'The company is currently checking your uploaded documents.',
    'documentReplacement': 'Document needs replacement',
    'documentReplacementBody':
        'One of your documents was rejected. Upload a new copy to continue.',
    'documentsApproved': 'Documents approved',
    'documentsApprovedBody':
        'All required documents have been approved. Your visa process can now begin.',
    'visaProcessing': 'Visa processing',
    'visaProcessingBody':
        'Your visa application has been submitted and is currently being processed.',
    'visaApproved': 'Visa approved',
    'visaApprovedBody':
        'Your visa has been approved. Complete any remaining requirements before departure.',
    'visaActionRequired': 'Visa action required',
    'visaActionRequiredBody':
        'There is an issue with your visa application. Check the details or contact the company.',
    'readyToTravel': 'You are ready to travel',
    'readyToTravelBody':
        'Your Umrah booking is complete. Review your departure and meeting details.',
    'departureApproaching': 'Departure is approaching',
    'departureApproachingBody':
        'Your trip departs soon. Check your meeting point, baggage, and travel documents.',
    'payNow': 'Pay Now',
    'uploadDocuments': 'Upload Documents',
    'fixDocument': 'Fix Document',
    'viewDocuments': 'View Documents',
    'viewVisaStatus': 'View Visa Status',
    'viewTravelDetails': 'View Travel Details',
    'viewBooking': 'View Booking',
    'viewDetails': 'View Details',
    'messageCompany': 'Message Company',
    'verifiedCompany': 'Verified company',
    'loadingBooking': 'Loading your current booking',
    'loadError': 'We could not load your current booking.',
    'tryAgain': 'Try Again',
    'bookingUnavailable': 'Booking status unavailable',
    'activeBookingTitle': 'Active booking',
    'activeBookingMessage':
        'You already have an active Umrah booking. You must complete or cancel your current booking before booking another trip.',
    'viewCurrentBooking': 'View Current Booking',
    'close': 'Close',
    'days': 'days',
  };

  static const _ar = <String, String>{
    'upcomingUmrah': 'عمرتك القادمة',
    'booked': 'الحجز',
    'documents': 'المستندات',
    'visa': 'التأشيرة',
    'ready': 'جاهز',
    'paymentRequired': 'الدفع مطلوب',
    'waiting': 'بانتظار التأكيد',
    'confirmed': 'مؤكد',
    'actionRequired': 'إجراء مطلوب',
    'processing': 'قيد المعالجة',
    'completePayment': 'أكمل عملية الدفع',
    'completePaymentBody':
        'ادفع المبلغ المطلوب قبل الموعد النهائي للحفاظ على حجزك.',
    'waitingConfirmation': 'بانتظار تأكيد الشركة',
    'waitingConfirmationBody': 'تم استلام طلبك والشركة تراجع حجزك حالياً.',
    'documentsRequired': 'المستندات مطلوبة',
    'documentsRequiredBody': 'ارفع المستندات الناقصة لمتابعة طلب العمرة.',
    'documentsReview': 'المستندات قيد المراجعة',
    'documentsReviewBody': 'تتحقق الشركة حالياً من المستندات التي رفعتها.',
    'documentReplacement': 'يجب استبدال مستند',
    'documentReplacementBody': 'تم رفض أحد مستنداتك. ارفع نسخة جديدة للمتابعة.',
    'documentsApproved': 'تمت الموافقة على المستندات',
    'documentsApprovedBody':
        'تمت الموافقة على جميع المستندات ويمكن بدء إجراءات التأشيرة.',
    'visaProcessing': 'التأشيرة قيد المعالجة',
    'visaProcessingBody': 'تم تقديم طلب التأشيرة وهو قيد المعالجة حالياً.',
    'visaApproved': 'تمت الموافقة على التأشيرة',
    'visaApprovedBody':
        'تمت الموافقة على تأشيرتك. أكمل أي متطلبات متبقية قبل المغادرة.',
    'visaActionRequired': 'إجراء مطلوب للتأشيرة',
    'visaActionRequiredBody':
        'توجد مشكلة في طلب التأشيرة. راجع التفاصيل أو تواصل مع الشركة.',
    'readyToTravel': 'أنت جاهز للسفر',
    'readyToTravelBody': 'اكتمل حجز العمرة. راجع تفاصيل المغادرة ونقطة التجمع.',
    'departureApproaching': 'موعد المغادرة يقترب',
    'departureApproachingBody':
        'ستغادر رحلتك قريباً. راجع نقطة التجمع والأمتعة ووثائق السفر.',
    'payNow': 'ادفع الآن',
    'uploadDocuments': 'رفع المستندات',
    'fixDocument': 'استبدال المستند',
    'viewDocuments': 'عرض المستندات',
    'viewVisaStatus': 'عرض حالة التأشيرة',
    'viewTravelDetails': 'عرض تفاصيل السفر',
    'viewBooking': 'عرض الحجز',
    'viewDetails': 'عرض التفاصيل',
    'messageCompany': 'مراسلة الشركة',
    'verifiedCompany': 'شركة موثقة',
    'loadingBooking': 'جارٍ تحميل حجزك الحالي',
    'loadError': 'تعذر تحميل حجزك الحالي.',
    'tryAgain': 'إعادة المحاولة',
    'bookingUnavailable': 'حالة الحجز غير متاحة',
    'activeBookingTitle': 'حجز نشط',
    'activeBookingMessage':
        'لديك حجز عمرة نشط بالفعل. يجب إكمال حجزك الحالي أو إلغاؤه قبل حجز رحلة أخرى.',
    'viewCurrentBooking': 'عرض الحجز الحالي',
    'close': 'إغلاق',
    'days': 'أيام',
  };

  static const _ku = <String, String>{
    'upcomingUmrah': 'عومرەی داهاتووت',
    'booked': 'حجز',
    'documents': 'بەڵگەنامەکان',
    'visa': 'ڤیزا',
    'ready': 'ئامادە',
    'paymentRequired': 'پارەدان پێویستە',
    'waiting': 'چاوەڕوان',
    'confirmed': 'پشتڕاستکراوە',
    'actionRequired': 'کردار پێویستە',
    'processing': 'لە پرۆسەدایە',
    'completePayment': 'پارەدانەکەت تەواو بکە',
    'completePaymentBody':
        'بڕی داواکراو پێش کاتی دیاریکراو بدە بۆ پاراستنی حجزەکەت.',
    'waitingConfirmation': 'چاوەڕوانی پشتڕاستکردنەوەی کۆمپانیا',
    'waitingConfirmationBody':
        'داواکارییەکەت وەرگیرا و کۆمپانیا حجزەکەت پێداچوونەوە دەکات.',
    'documentsRequired': 'بەڵگەنامە پێویستە',
    'documentsRequiredBody':
        'بەڵگەنامە کەمەکان باربکە بۆ بەردەوامبوونی داواکاری عومرە.',
    'documentsReview': 'بەڵگەنامەکان پێداچوونەوەیان بۆ دەکرێت',
    'documentsReviewBody': 'کۆمپانیا ئێستا بەڵگەنامە بارکراوەکانت دەبینی.',
    'documentReplacement': 'بەڵگەنامەیەک پێویستی بە گۆڕینە',
    'documentReplacementBody':
        'یەکێک لە بەڵگەنامەکانت ڕەتکرایەوە. وێنەیەکی نوێ باربکە.',
    'documentsApproved': 'بەڵگەنامەکان پەسەندکران',
    'documentsApprovedBody':
        'هەموو بەڵگەنامەکان پەسەندکران و پرۆسەی ڤیزا دەتوانێت دەستپێبکات.',
    'visaProcessing': 'ڤیزا لە پرۆسەدایە',
    'visaProcessingBody': 'داواکاری ڤیزاکەت نێردراوە و ئێستا لە پرۆسەدایە.',
    'visaApproved': 'ڤیزا پەسەندکرا',
    'visaApprovedBody':
        'ڤیزاکەت پەسەندکرا. پێداویستییە ماوەکان پێش گەشت تەواو بکە.',
    'visaActionRequired': 'کردار بۆ ڤیزا پێویستە',
    'visaActionRequiredBody':
        'کێشەیەک لە داواکاری ڤیزاکەت هەیە. وردەکاری ببینە یان پەیوەندی بکە.',
    'readyToTravel': 'ئامادەی گەشتیت',
    'readyToTravelBody':
        'حجزی عومرەکەت تەواوە. وردەکاری ڕۆیشتن و شوێنی کۆبوونەوە ببینە.',
    'departureApproaching': 'کاتی ڕۆیشتن نزیکە',
    'departureApproachingBody':
        'گەشتەکەت بەم زووانەیە. شوێنی کۆبوونەوە و بەڵگەنامەکان بپشکنە.',
    'payNow': 'ئێستا پارە بدە',
    'uploadDocuments': 'بەڵگەنامە باربکە',
    'fixDocument': 'بەڵگەنامە چاکبکە',
    'viewDocuments': 'بەڵگەنامەکان ببینە',
    'viewVisaStatus': 'دۆخی ڤیزا ببینە',
    'viewTravelDetails': 'وردەکاری گەشت ببینە',
    'viewBooking': 'حجز ببینە',
    'viewDetails': 'وردەکاری ببینە',
    'messageCompany': 'نامە بۆ کۆمپانیا',
    'verifiedCompany': 'کۆمپانیای پشتڕاستکراو',
    'loadingBooking': 'حجزەکەت بار دەکرێت',
    'loadError': 'نەتوانرا حجزی ئێستات باربکرێت.',
    'tryAgain': 'هەوڵی دووبارە',
    'bookingUnavailable': 'دۆخی حجز بەردەست نییە',
    'activeBookingTitle': 'حجزی چالاک',
    'activeBookingMessage':
        'پێشتر حجزی عومرەیەکی چالاکت هەیە. پێویستە حجزی ئێستات تەواو یان هەڵبوەشێنیتەوە پێش حجزی گەشتێکی تر.',
    'viewCurrentBooking': 'حجزی ئێستا ببینە',
    'close': 'داخستن',
    'days': 'ڕۆژ',
  };

  String text(String key) =>
      (language == 'ar'
          ? _ar
          : language == 'ku'
          ? _ku
          : _en)[key] ??
      _en[key] ??
      key;

  String dateLine(DateTime? departure, DateTime? returning, int? fallbackDays) {
    if (departure == null) return '';
    final days = returning == null
        ? fallbackDays
        : returning.difference(departure).inDays;
    final range = returning == null
        ? _date(departure)
        : '${_date(departure)} – ${_date(returning)}';
    return days == null ? range : '$range · $days ${text('days')}';
  }

  String departureApproachingBody(DateTime? departure) {
    if (departure == null) return text('departureApproachingBody');
    final days = departure.difference(DateTime.now()).inDays.clamp(0, 3);
    if (language == 'ar') {
      return 'تغادر رحلتك خلال $days أيام. راجع نقطة التجمع والأمتعة ووثائق السفر.';
    }
    if (language == 'ku') {
      return 'گەشتەکەت لە ماوەی $days ڕۆژدا دەڕوات. شوێنی کۆبوونەوە و بەڵگەنامەکان بپشکنە.';
    }
    return 'Your trip departs in $days days. Check your meeting point, baggage, and travel documents.';
  }

  String _date(DateTime date) {
    const enMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${enMonths[date.month - 1]} ${date.year}';
  }
}
