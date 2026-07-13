import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../models/offer_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/filter_chip_bar.dart';
import '../../widgets/dashboard/status_chip.dart';
import '../../l10n/generated/app_localizations.dart';

/// Incoming booking requests for the agency, filterable by status.
/// Pending requests sort first so nothing waits unseen.
class AgencyBookingsTab extends StatefulWidget {
  const AgencyBookingsTab({super.key});

  @override
  State<AgencyBookingsTab> createState() => _AgencyBookingsTabState();
}

class _AgencyBookingsTabState extends State<AgencyBookingsTab> {
  String _filter = 'all';

  static const _statusOrder = {
    'requested': 0,
    'needs_information': 1,
    'awaiting_payment': 2,
    'confirmed': 3,
    'ready': 4,
    'in_progress': 5,
    'completed': 6,
    'cancelled': 7,
    'rejected': 8,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final bookings = List<Booking>.from(provider.agencyBookings)
      ..sort(
        (a, b) => (_statusOrder[a.operationalStage] ?? 9).compareTo(
          _statusOrder[b.operationalStage] ?? 9,
        ),
      );
    final filtered = _filter == 'all'
        ? bookings
        : bookings.where((b) => b.operationalStage == _filter).toList();

    return DashboardScaffold(
      title: t.agencyBookingsTitle,
      onRefresh: () => context.read<AppProvider>().loadAgencyBookings(),
      filterBar: FilterChipBar<String>(
        options: [
          FilterOption('all', t.adminFilterAll),
          FilterOption('requested', t.bookingsStatusPending),
          FilterOption('awaiting_payment', t.workflowAwaitingPayment),
          FilterOption('confirmed', t.bookingsStatusConfirmed),
          FilterOption('completed', t.agencyBookingsCompleted),
          FilterOption('cancelled', t.bookingsStatusCancelled),
        ],
        selected: _filter,
        onSelect: (v) => setState(() => _filter = v),
      ),
      filterBarHeight: 46,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: kDashCardGap)),
        if (filtered.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: t.agencyBookingsEmptyTitle,
              body: t.agencyBookingsEmptyBody,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  12,
                ),
                child: BookingRequestCard(booking: filtered[i]),
              ),
              childCount: filtered.length,
            ),
          ),
      ],
    );
  }
}

/// One booking request: trip, reference, pax and amount, with inline
/// confirm/decline while pending and "mark completed" once confirmed.
class BookingRequestCard extends StatelessWidget {
  final Booking booking;
  const BookingRequestCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    String statusLabel() {
      switch (booking.operationalStage) {
        case 'confirmed':
          return t.bookingsStatusConfirmed;
        case 'requested':
          return t.bookingsStatusPending;
        case 'awaiting_payment':
          return t.workflowAwaitingPayment;
        case 'ready':
          return t.workflowReadyToTravel;
        case 'in_progress':
          return t.workflowInProgress;
        case 'rejected':
          return t.workflowRejected;
        case 'cancelled':
          return t.bookingsStatusCancelled;
        case 'completed':
          return t.agencyBookingsCompleted;
        default:
          return booking.status;
      }
    }

    Future<void> respond(bool confirm) async {
      final messenger = ScaffoldMessenger.of(context);
      final err = await provider.respondToBooking(booking.id, confirm: confirm);
      final msg = err == null
          ? (confirm
                ? t.agencyBookingsConfirmedSnack
                : t.agencyBookingsDeclinedSnack)
          : err;
      messenger.showSnackBar(appSnack(msg, isError: err != null));
    }

    Future<void> complete() async {
      final messenger = ScaffoldMessenger.of(context);
      final err = await provider.markBookingCompleted(booking.id);
      final msg = err == null ? t.agencyBookingsCompletedSnack : err;
      messenger.showSnackBar(appSnack(msg, isError: err != null));
    }

    Future<void> advance(String action) async {
      final messenger = ScaffoldMessenger.of(context);
      final err = action == 'ready'
          ? await provider.markBookingReady(booking.id)
          : await provider.startBookingTrip(booking.id);
      messenger.showSnackBar(
        appSnack(
          err == null ? t.workflowStatusUpdated : err,
          isError: err != null,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  booking.titleFor(lang),
                  style: AppTheme.serif(17),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                kind: StatusChip.forBooking(booking.status),
                label: statusLabel(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            t.bookingsRefLabel(booking.ref),
            style: AppTheme.sans(
              11,
              color: AppColors.muted,
            ).copyWith(letterSpacing: 0.5, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 4),
          Text(
            t.bookingsPaxCount(booking.travelers),
            style: AppTheme.sans(12.5, color: const Color(0xFF5E6B63)),
          ),
          if ((booking.roomLabel ?? '').isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              booking.roomLabel!,
              style: AppTheme.sans(
                12.5,
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
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                booking.totalFmt,
                style: AppTheme.serif(18, color: AppColors.primary),
              ),
              const Spacer(),
              if (booking.operationalStage == 'requested') ...[
                GestureDetector(
                  onTap: () => respond(false),
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 9, 14, 9),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.errorRed.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      t.agencyBookingsDecline,
                      style: AppTheme.sans(
                        12.5,
                        weight: FontWeight.w700,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => respond(true),
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 9, 14, 9),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      t.agencyBookingsConfirm,
                      style: AppTheme.sans(
                        12.5,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else if (booking.operationalStage == 'confirmed')
                _ActionButton(
                  label: t.workflowMarkReady,
                  onTap: () => advance('ready'),
                )
              else if (booking.operationalStage == 'awaiting_payment' &&
                  booking.payMethod == 'cash')
                _ActionButton(
                  label: t.workflowConfirmCash,
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final err = await provider.confirmCashPayment(booking.id);
                    messenger.showSnackBar(
                      appSnack(
                        err == null ? t.workflowCashConfirmed : err,
                        isError: err != null,
                      ),
                    );
                  },
                )
              else if (booking.operationalStage == 'ready')
                _ActionButton(
                  label: t.workflowStartTrip,
                  onTap: () => advance('start'),
                )
              else if (booking.operationalStage == 'in_progress')
                GestureDetector(
                  onTap: complete,
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 9, 14, 9),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      t.agencyBookingsMarkCompleted,
                      style: AppTheme.sans(
                        12.5,
                        weight: FontWeight.w700,
                        color: const Color(0xFF1C2317),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 9, 14, 9),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        style: AppTheme.sans(
          12.5,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}
