import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../models/commission_model.dart';
import '../../models/offer_model.dart' show fmtIqd;
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/islamic_pattern.dart';
import '../../l10n/generated/app_localizations.dart';

/// Agency-side view of incoming booking requests (confirm/decline, then mark
/// a confirmed trip completed once it's over) and the commission ledger for
/// their own company.
class AgencyBookingsScreen extends StatefulWidget {
  const AgencyBookingsScreen({super.key});

  @override
  State<AgencyBookingsScreen> createState() => _AgencyBookingsScreenState();
}

class _AgencyBookingsScreenState extends State<AgencyBookingsScreen> {
  int _tab = 0; // 0 = requests, 1 = commissions

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AppProvider>();
      p.loadAgencyBookings();
      p.loadCommissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final bookings = List<Booking>.from(provider.agencyBookings)
      ..sort((a, b) {
        const order = {'Pending': 0, 'Confirmed': 1, 'Completed': 2, 'Cancelled': 3};
        return (order[a.status] ?? 9).compareTo(order[b.status] ?? 9);
      });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: IslamicPattern(opacity: 0.04, isEightFold: true)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(t.agencyBookingsTitle, style: AppTheme.serif(26))),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Expanded(child: _TabBtn(label: t.agencyBookingsRequests, active: _tab == 0, onTap: () => setState(() => _tab = 0))),
                      const SizedBox(width: 10),
                      Expanded(child: _TabBtn(label: t.adminCommissionsTitle, active: _tab == 1, onTap: () => setState(() => _tab = 1))),
                    ],
                  ),
                ),
                Expanded(
                  child: _tab == 0
                      ? (bookings.isEmpty
                          ? _EmptyState(icon: Icons.inbox_outlined, title: t.agencyBookingsEmptyTitle, body: t.agencyBookingsEmptyBody)
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: bookings.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, i) => _RequestCard(booking: bookings[i]),
                            ))
                      : CommissionLedger(commissions: provider.commissions, showCompanyName: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: AppTheme.sans(13, weight: FontWeight.w700, color: active ? Colors.white : AppColors.ink)),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Booking booking;
  const _RequestCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    String statusLabel() {
      switch (booking.status) {
        case 'Confirmed': return t.bookingsStatusConfirmed;
        case 'Pending': return t.bookingsStatusPending;
        case 'Cancelled': return t.bookingsStatusCancelled;
        case 'Completed': return t.agencyBookingsCompleted;
        default: return booking.status;
      }
    }

    Future<void> respond(bool confirm) async {
      final messenger = ScaffoldMessenger.of(context);
      final ok = await provider.respondToBooking(booking.id, confirm: confirm);
      messenger.showSnackBar(appSnack(
          ok ? (confirm ? t.agencyBookingsConfirmedSnack : t.agencyBookingsDeclinedSnack) : t.actionFailedGeneric,
          isError: !ok));
    }

    Future<void> complete() async {
      final messenger = ScaffoldMessenger.of(context);
      final ok = await provider.markBookingCompleted(booking.id);
      messenger.showSnackBar(appSnack(ok ? t.agencyBookingsCompletedSnack : t.actionFailedGeneric, isError: !ok));
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(booking.titleFor(lang), style: AppTheme.serif(17), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: booking.statusBg, borderRadius: BorderRadius.circular(7)),
                child: Text(statusLabel(), style: AppTheme.sans(10.5, weight: FontWeight.w700, color: booking.statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(t.bookingsRefLabel(booking.ref), style: AppTheme.sans(11, color: AppColors.muted).copyWith(letterSpacing: 0.5, fontFamily: 'monospace')),
          const SizedBox(height: 4),
          Text(t.bookingsPaxCount(booking.travelers), style: AppTheme.sans(12.5, color: const Color(0xFF5E6B63))),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(booking.totalFmt, style: AppTheme.serif(18, color: AppColors.primary)),
              const Spacer(),
              if (booking.status == 'Pending') ...[
                GestureDetector(
                  onTap: () => respond(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.errorRed.withOpacity(0.25), width: 1),
                    ),
                    child: Text(t.agencyBookingsDecline, style: AppTheme.sans(12.5, weight: FontWeight.w700, color: AppColors.errorRed)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => respond(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(11)),
                    child: Text(t.agencyBookingsConfirm, style: AppTheme.sans(12.5, weight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ] else if (booking.status == 'Confirmed')
                GestureDetector(
                  onTap: complete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(11)),
                    child: Text(t.agencyBookingsMarkCompleted,
                        style: AppTheme.sans(12.5, weight: FontWeight.w700, color: const Color(0xFF1C2317))),
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
  final IconData icon;
  final String title;
  final String body;
  const _EmptyState({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: Color(0xFFECF0E9), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTheme.serif(20)),
          const SizedBox(height: 5),
          Text(body, style: AppTheme.sans(13, color: AppColors.muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Shared commission ledger list — used both by the agency (own commissions
/// only) and the admin (every agency, with company names shown).
class CommissionLedger extends StatelessWidget {
  final List<Commission> commissions;
  final bool showCompanyName;
  const CommissionLedger({super.key, required this.commissions, this.showCompanyName = true});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final owed = commissions.where((c) => c.status == 'owed').fold(0.0, (s, c) => s + c.amount);

    if (commissions.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: t.adminCommissionsEmptyTitle,
        body: t.adminCommissionsEmptyBody,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.adminCommissionsOwedLabel, style: AppTheme.sans(12, color: Colors.white.withOpacity(0.8))),
                    const SizedBox(height: 4),
                    Text(fmtIqd(owed), style: AppTheme.serif(24, color: Colors.white)),
                  ],
                ),
              ),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 32),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final c in commissions) _CommissionRow(commission: c, showCompanyName: showCompanyName),
      ],
    );
  }
}

class _CommissionRow extends StatelessWidget {
  final Commission commission;
  final bool showCompanyName;
  const _CommissionRow({required this.commission, required this.showCompanyName});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final owed = commission.status == 'owed';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCompanyName)
                    Text(commission.companyName, style: AppTheme.sans(13, weight: FontWeight.w700)),
                  Text(fmtIqd(commission.amount),
                      style: AppTheme.serif(16, color: AppColors.primary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: owed ? const Color(0xFFFFF8E8) : const Color(0xFFEAF1EC),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                owed ? t.adminCommissionsOwed : t.adminCommissionsCollected,
                style: AppTheme.sans(10.5, weight: FontWeight.w700, color: owed ? AppColors.gold : AppColors.primary),
              ),
            ),
            if (owed) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await context.read<AppProvider>().markCommissionCollected(commission.id);
                  if (!ok) messenger.showSnackBar(appSnack(t.actionFailedGeneric, isError: true));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
