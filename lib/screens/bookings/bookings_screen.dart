import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bookings = context.watch<AppProvider>().bookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.bookingsTitle, style: AppTheme.serif(30)),
                    const SizedBox(height: 3),
                    Text(t.bookingsTripCount(bookings.length),
                        style: AppTheme.sans(13, color: const Color(0xFF7D8A82))),
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
                    padding: EdgeInsets.fromLTRB(22, 0, 22, i < bookings.length - 1 ? 14 : 24),
                    child: _BookingCard(booking: bookings[i]),
                  ),
                  childCount: bookings.length,
                ),
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
    switch (booking.status) {
      case 'Confirmed': return t.bookingsStatusConfirmed;
      case 'Pending': return t.bookingsStatusPending;
      case 'Cancelled': return t.bookingsStatusCancelled;
      default: return booking.status;
    }
  }

  String _dateLabel(AppLocalizations t) {
    final d = booking.departureDate;
    if (d == null) return t.dateToBeScheduled;
    return '${d.day}/${d.month}/${d.year}';
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
        content: Text(t.bookingsCancelBody(booking.titleFor(lang)), style: AppTheme.sans(13, color: AppColors.inkLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(t.bookingsKeepBooking, style: AppTheme.sans(13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final err = await provider.cancelBooking(booking.id);
              messenger.showSnackBar(err == null
                  ? appSnack(t.bookingsCancelledSnack)
                  : appSnack(t.bookingsCancelFailed, isError: true));
            },
            child: Text(t.bookingsConfirmCancel, style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.errorRed)),
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
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F3729).withOpacity(0.06), blurRadius: 28, offset: const Offset(0, 12)),
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
                            child: Text(booking.titleFor(Localizations.localeOf(context).languageCode),
                                style: AppTheme.serif(17)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: booking.statusBg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              _statusLabel(t),
                              style: AppTheme.sans(10.5, weight: FontWeight.w700, color: booking.statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(booking.companyNameFor(Localizations.localeOf(context).languageCode),
                          style: AppTheme.sans(11.5, color: const Color(0xFF7D8A82), weight: FontWeight.w600)),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Text(_dateLabel(t), style: AppTheme.sans(11.5, color: const Color(0xFF5E6B63))),
                          const Text(' · ', style: TextStyle(color: Color(0xFF5E6B63))),
                          Text(t.bookingsPaxCount(booking.travelers), style: AppTheme.sans(11.5, color: const Color(0xFF5E6B63))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFAF8F2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(19)),
              border: Border(top: BorderSide(color: Color(0x260F5C4D), width: 1.5, style: BorderStyle.solid)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.bookingsRefLabel(booking.ref),
                    style: AppTheme.sans(11, color: AppColors.muted).copyWith(letterSpacing: 0.5, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (booking.status == 'Confirmed' || booking.status == 'Pending') ...[
                  GestureDetector(
                    onTap: () => _confirmCancel(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.errorRed.withOpacity(0.25), width: 1),
                      ),
                      child: Text(
                        t.bookingsCancelBooking,
                        style: AppTheme.sans(11, weight: FontWeight.w700, color: AppColors.errorRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(booking.totalFmt, style: AppTheme.serif(18, color: AppColors.primary)),
              ],
            ),
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
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(t.bookingsEmptyTitle, style: AppTheme.serif(22)),
          const SizedBox(height: 5),
          Text(t.bookingsEmptyBody, style: AppTheme.sans(13, color: AppColors.muted)),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => context.read<AppProvider>().setTab(2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
              child: Text(t.bookingsBrowseOffers, style: AppTheme.sans(13, weight: FontWeight.w700, color: const Color(0xFFF6F2E9))),
            ),
          ),
        ],
      ),
    );
  }
}
