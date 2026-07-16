import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/booking_model.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/kpi.dart';
import '../../widgets/dashboard/section_header.dart';
import '../../widgets/dashboard/attention_card.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../l10n/generated/app_localizations.dart';
import 'agency_bookings_tab.dart';

/// Agency landing tab: next departure hero, KPI strip, alerts that deep-link
/// into the other tabs, and the latest booking requests.
class AgencyOverviewTab extends StatelessWidget {
  /// Switches the shell to another destination (2 = Bookings).
  final ValueChanged<int> onGoToTab;
  final VoidCallback onOpenMoney;
  const AgencyOverviewTab({
    super.key,
    required this.onGoToTab,
    required this.onOpenMoney,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final company = provider.agencyCompany;
    if (company == null) return const SizedBox.shrink();
    final lang = Localizations.localeOf(context).languageCode;

    final bookings = provider.agencyBookings;
    final pending = provider.pendingBookingCount;
    final confirmed = bookings.where((b) => b.status == 'Confirmed').length;
    final bookingValue = bookings
        .where(
          (booking) => ![
            'cancelled',
            'rejected',
            'expired',
          ].contains(booking.operationalStage),
        )
        .fold(0.0, (s, b) => s + b.total);
    final received = bookings.fold(
      0.0,
      (sum, booking) => sum + booking.amountPaid,
    );
    final unpaid = bookings
        .where(
          (booking) =>
              booking.amountPaid < booking.total &&
              ![
                'cancelled',
                'rejected',
                'expired',
              ].contains(booking.operationalStage),
        )
        .length;
    final wallet = provider.agencyWallet;
    final next = _nextDeparture(bookings);
    final recent = _recent(bookings);

    return DashboardScaffold(
      title: company.nameFor(lang),
      subtitle: company.isVerified
          ? t.agencyDashboardVerifiedAgency
          : t.agencyDashboardPendingVerification,
      leading: DashIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
      onRefresh: () async {
        final p = context.read<AppProvider>();
        await p.loadAgencyBookings();
        await p.loadCommissions();
        await p.loadAgencyWallet();
      },
      slivers: [
        if (!company.isVerified)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                kDashPagePad,
                0,
                kDashPagePad,
                kDashCardGap,
              ),
              child: _VerificationBanner(
                title: company.verificationStatus == 'needs_changes'
                    ? t.workflowChangesRequired
                    : t.agencyDashboardVerificationPending,
                body:
                    company.verificationReason ??
                    (company.verificationStatus == 'draft'
                        ? t.workflowSubmitCompanyBody
                        : t.agencyDashboardVerificationPendingBody),
                actionLabel:
                    [
                      'draft',
                      'needs_changes',
                      'rejected',
                    ].contains(company.verificationStatus)
                    ? t.workflowSubmitForReview
                    : null,
                onAction: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final err = await context
                      .read<AppProvider>()
                      .submitCompanyForReview();
                  messenger.showSnackBar(
                    appSnack(
                      err ?? t.workflowSubmitted,
                      isError: err != null,
                    ),
                  );
                },
              ),
            ),
          ),
        if (next != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                kDashPagePad,
                kDashCardGap,
                kDashPagePad,
                0,
              ),
              child: _NextDepartureCard(
                booking: next,
                onTap: () => onGoToTab(2),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: kDashSectionGap),
            child: KpiRow(
              cards: [
                KpiCard(
                  value: '$pending',
                  label: t.agencyKpiRequests,
                  icon: Icons.mark_email_unread_rounded,
                  color: AppColors.gold,
                  onTap: () => onGoToTab(2),
                ),
                KpiCard(
                  value: '$confirmed',
                  label: t.bookingsStatusConfirmed,
                  icon: Icons.event_available_rounded,
                  color: AppColors.primary,
                  onTap: () => onGoToTab(2),
                ),
                KpiCard(
                  value: compactIqd(bookingValue),
                  label: t.agencyTripConfirmedValue,
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF397C74),
                  onTap: onOpenMoney,
                ),
                KpiCard(
                  value: compactIqd(received),
                  label: t.agencyTripCollected,
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFF8B5F38),
                  onTap: onOpenMoney,
                ),
              ],
            ),
          ),
        ),
        if (pending > 0 ||
            unpaid > 0 ||
            wallet.amountOwedToPlatformIqd > 0) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: t.adminNeedsAttention),
          ),
          SliverToBoxAdapter(
            child: AttentionRow(
              cards: [
                if (pending > 0)
                  AttentionCard(
                    icon: Icons.mark_email_unread_rounded,
                    label: t.agencyKpiRequests,
                    count: pending,
                    color: AppColors.gold,
                    onTap: () => onGoToTab(2),
                  ),
                if (unpaid > 0)
                  AttentionCard(
                    icon: Icons.money_off_csred_outlined,
                    label: t.agencyOverviewUnpaidBookings,
                    count: unpaid,
                    color: const Color(0xFF8B5F38),
                    onTap: () => onGoToTab(2),
                  ),
                if (wallet.amountOwedToPlatformIqd > 0)
                  AttentionCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: t.agencyWalletYouOweTawaf,
                    count: 1,
                    color: AppColors.errorRed,
                    onTap: onOpenMoney,
                  ),
              ],
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: SectionHeader(
            title: t.agencyBookingsTitle,
            onViewAll: () => onGoToTab(2),
          ),
        ),
        if (recent.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: t.agencyBookingsEmptyTitle,
              compact: true,
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
                child: BookingRequestCard(booking: recent[i]),
              ),
              childCount: recent.length,
            ),
          ),
      ],
    );
  }

  Booking? _nextDeparture(List<Booking> bookings) {
    final now = DateTime.now();
    Booking? next;
    for (final b in bookings) {
      if (b.status != 'Confirmed') continue;
      final dep = b.departureDate;
      if (dep == null || dep.isBefore(now)) continue;
      if (next == null || dep.isBefore(next.departureDate!)) next = b;
    }
    return next;
  }

  List<Booking> _recent(List<Booking> bookings) {
    final sorted = List<Booking>.from(bookings)
      ..sort((a, b) {
        const order = {
          'Pending': 0,
          'Confirmed': 1,
          'Completed': 2,
          'Cancelled': 3,
        };
        return (order[a.status] ?? 9).compareTo(order[b.status] ?? 9);
      });
    return sorted.take(5).toList();
  }
}

class _NextDepartureCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;
  const _NextDepartureCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final dep = booking.departureDate!;
    final days = dep.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: booking.gradColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: booking.gradColors.first.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IslamicPattern(opacity: 0.07, cell: 64),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          9,
                          4,
                          9,
                          4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t.agencyNextDeparture,
                          style: AppTheme.sans(
                            10.5,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          9,
                          4,
                          9,
                          4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t.agencyInDaysCount(days < 1 ? 1 : days),
                          style: AppTheme.sans(
                            10.5,
                            weight: FontWeight.w800,
                            color: const Color(0xFF1C2317),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    booking.titleFor(lang),
                    style: AppTheme.serif(20, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${dep.year}/${dep.month}/${dep.day} · ${t.bookingsPaxCount(booking.travelers)}',
                        style: AppTheme.sans(
                          12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _VerificationBanner({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
    ),
    child: Row(
      children: [
        const Icon(Icons.schedule_rounded, color: AppColors.gold, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.sans(
                  13,
                  weight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: AppTheme.sans(12, color: const Color(0xFF8A7040)),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionLabel!,
                    style: AppTheme.sans(
                      12,
                      weight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
