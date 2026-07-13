import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/booking_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/entity_list_card.dart';
import '../../widgets/dashboard/filter_chip_bar.dart';
import '../../widgets/dashboard/status_chip.dart';

class AdminBookingsTab extends StatefulWidget {
  const AdminBookingsTab({super.key});

  @override
  State<AdminBookingsTab> createState() => _AdminBookingsTabState();
}

class _AdminBookingsTabState extends State<AdminBookingsTab> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final bookings = _filter == 'all'
        ? provider.adminBookings
        : provider.adminBookings
              .where((booking) => booking.operationalStage == _filter)
              .toList();
    return DashboardScaffold(
      title: t.adminBookingsPayments,
      onRefresh: provider.loadAdminData,
      filterBar: FilterChipBar<String>(
        options: [
          FilterOption('all', t.adminFilterAll),
          FilterOption('requested', t.bookingStageRequested),
          FilterOption('confirmed', t.bookingStageConfirmed),
          FilterOption('completed', t.bookingStageCompleted),
          FilterOption('cancelled', t.bookingStageCancelled),
        ],
        selected: _filter,
        onSelect: (value) => setState(() => _filter = value),
      ),
      filterBarHeight: 46,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: kDashCardGap)),
        if (bookings.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: t.adminNoBookings,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  kDashCardGap,
                ),
                child: _BookingRow(booking: bookings[index]),
              ),
              childCount: bookings.length,
            ),
          ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  final Booking booking;
  const _BookingRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return EntityListCard(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: booking.statusBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.receipt_long_rounded, color: booking.statusColor),
      ),
      title: booking.titleFor(lang),
      subtitle:
          '${booking.companyNameFor(lang)} · ${booking.totalFmt}\n${booking.payMethod.toUpperCase()} · ${booking.paymentStatus}',
      trailing: StatusChip(
        kind:
            booking.operationalStage == 'completed' ||
                booking.operationalStage == 'confirmed'
            ? StatusKind.positive
            : booking.operationalStage == 'cancelled'
            ? StatusKind.negative
            : StatusKind.pending,
        label: _stageLabel(t, booking.operationalStage),
      ),
    );
  }

  String _stageLabel(AppLocalizations t, String stage) => switch (stage) {
    'confirmed' => t.bookingStageConfirmed,
    'completed' => t.bookingStageCompleted,
    'cancelled' => t.bookingStageCancelled,
    _ => t.bookingStageRequested,
  };
}
