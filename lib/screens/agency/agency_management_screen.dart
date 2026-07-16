import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/agency_operations_model.dart';
import '../../models/booking_model.dart';
import '../../models/offer_model.dart';
import '../../models/review_model.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/status_chip.dart';

class AgencyManagementScreen extends StatefulWidget {
  const AgencyManagementScreen({super.key});

  @override
  State<AgencyManagementScreen> createState() => _AgencyManagementScreenState();
}

class _AgencyManagementScreenState extends State<AgencyManagementScreen> {
  bool _loading = true;
  List<AgencyStaffMember> _staff = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    if (mounted) setState(() => _loading = true);
    final provider = context.read<AppProvider>();
    final companyId = provider.agencyCompany?.id;
    await Future.wait([
      provider.loadAgencyBookings(),
      if (companyId != null) provider.loadCompanyReviews(companyId),
    ]);
    final staff = await provider.agencyStaff();
    if (!mounted) return;
    setState(() {
      _staff = staff;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final company = provider.agencyCompany;
    if (company == null) return const SizedBox.shrink();
    final offers = provider.getCompanyOffers(company.id);
    final reviews = provider.reviewsForCompany(company.id);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(t.agencyManagementTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: t.agencyManagementReports),
              Tab(text: t.profileStatReviews),
              Tab(text: t.agencyManagementStaff),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _ReportsTab(
                    bookings: provider.agencyBookings,
                    offers: offers,
                  ),
                  _ReviewsTab(reviews: reviews, onReply: _replyToReview),
                  _StaffTab(
                    staff: _staff,
                    onAdd: _addStaff,
                    onRemove: _removeStaff,
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _replyToReview(Review review) async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.agencyManagementReplyReview),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: t.agencyManagementReplyReviewHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.agencyDashboardCancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(t.agencyReplyHint),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reply == null || !mounted) return;
    final error = await context.read<AppProvider>().replyToReview(
      review.id,
      reply,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyManagementReplySent, isError: error != null),
    );
    if (error == null) await _reload();
  }

  Future<void> _addStaff() async {
    final t = AppLocalizations.of(context);
    final profileId = TextEditingController();
    var role = 'booking';
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(t.agencyManagementAddStaff),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: profileId,
                decoration: InputDecoration(
                  labelText: t.agencyManagementProfileId,
                  helperText: t.agencyManagementProfileIdHelp,
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(labelText: t.agencyManagementRole),
                items:
                    const [
                          'manager',
                          'booking',
                          'accountant',
                          'visa',
                          'guide',
                          'support',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_titleCase(value)),
                          ),
                        )
                        .toList(),
                onChanged: (value) =>
                    setDialogState(() => role = value ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.agencyDashboardCancel),
            ),
            FilledButton(
              onPressed: () {
                if (profileId.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, {
                  'user_id': profileId.text.trim(),
                  'role': role,
                });
              },
              child: Text(t.agencyManagementAddStaff),
            ),
          ],
        ),
      ),
    );
    profileId.dispose();
    if (values == null || !mounted) return;
    final roleValue = values['role']!;
    final error = await context.read<AppProvider>().addAgencyStaff(
      userId: values['user_id']!,
      role: roleValue,
      permissions: _rolePermissions(roleValue),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyManagementStaffAdded, isError: error != null),
    );
    if (error == null) await _reload();
  }

  Future<void> _removeStaff(AgencyStaffMember staff) async {
    final t = AppLocalizations.of(context);
    final error = await context.read<AppProvider>().removeAgencyStaff(staff.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyManagementStaffRemoved, isError: error != null),
    );
    if (error == null) await _reload();
  }
}

class _ReportsTab extends StatelessWidget {
  final List<Booking> bookings;
  final List<Offer> offers;
  const _ReportsTab({required this.bookings, required this.offers});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final active = bookings
        .where(
          (booking) => ![
            'cancelled',
            'rejected',
            'expired',
          ].contains(booking.operationalStage),
        )
        .toList();
    final cancelled = bookings.length - active.length;
    final totalValue = active.fold(0.0, (sum, booking) => sum + booking.total);
    final collected = bookings.fold(
      0.0,
      (sum, booking) => sum + booking.amountPaid,
    );
    final totalCapacity = offers.fold(
      0,
      (sum, offer) => sum + (offer.capacity ?? 0),
    );
    final reserved = offers.fold(0, (sum, offer) => sum + offer.seatsReserved);
    final occupancy = totalCapacity == 0 ? 0 : reserved / totalCapacity;
    final cancellationRate = bookings.isEmpty ? 0 : cancelled / bookings.length;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _ReportMetric(
              label: t.agencyManagementBookingValue,
              value: fmtIqd(totalValue),
            ),
            _ReportMetric(
              label: t.agencyTripCollected,
              value: fmtIqd(collected),
            ),
            _ReportMetric(
              label: t.agencyManagementOccupancy,
              value: '${(occupancy * 100).round()}%',
            ),
            _ReportMetric(
              label: t.agencyManagementCancellationRate,
              value: '${(cancellationRate * 100).round()}%',
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          t.agencyManagementTripPerformance,
          style: AppTheme.sans(15, weight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (offers.isEmpty)
          EmptyState(
            icon: Icons.query_stats_outlined,
            title: t.agencyManagementNoReportData,
            compact: true,
          )
        else
          for (final offer in offers)
            _TripReportRow(
              offer: offer,
              bookings: bookings
                  .where((booking) => booking.offerId == offer.id)
                  .toList(),
            ),
      ],
    );
  }
}

class _TripReportRow extends StatelessWidget {
  final Offer offer;
  final List<Booking> bookings;
  const _TripReportRow({required this.offer, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final booked = bookings
        .where(
          (booking) => ![
            'cancelled',
            'rejected',
            'expired',
          ].contains(booking.operationalStage),
        )
        .fold(0, (sum, booking) => sum + booking.travelers);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.titleFor(lang),
                  style: AppTheme.sans(12.5, weight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  t.agencyManagementTripCounts(bookings.length, booked),
                  style: AppTheme.sans(10.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            offer.capacity == null ? '—' : '$booked/${offer.capacity}',
            style: AppTheme.serif(14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final List<Review> reviews;
  final ValueChanged<Review> onReply;
  const _ReviewsTab({required this.reviews, required this.onReply});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (reviews.isEmpty) {
      return ListView(
        children: [
          EmptyState(
            icon: Icons.reviews_outlined,
            title: t.agencyManagementNoReviews,
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${'★' * review.rating}${'☆' * (5 - review.rating)}',
                      style: const TextStyle(color: AppColors.gold),
                    ),
                    const Spacer(),
                    StatusChip(
                      kind: review.moderationStatus == 'visible'
                          ? StatusKind.positive
                          : StatusKind.pending,
                      label: _titleCase(review.moderationStatus),
                    ),
                  ],
                ),
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(review.comment, style: AppTheme.sans(12.5)),
                ],
                if (review.publicReply.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${t.companyAgencyReply}: ${review.publicReply}',
                    style: AppTheme.sans(12, color: AppColors.primary),
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => onReply(review),
                      child: Text(t.agencyManagementReplyReview),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StaffTab extends StatelessWidget {
  final List<AgencyStaffMember> staff;
  final VoidCallback onAdd;
  final ValueChanged<AgencyStaffMember> onRemove;
  const _StaffTab({
    required this.staff,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(t.agencyManagementAddStaff),
        ),
        const SizedBox(height: 14),
        if (staff.isEmpty)
          EmptyState(
            icon: Icons.badge_outlined,
            title: t.agencyManagementNoStaff,
            body: t.agencyManagementNoStaffBody,
          )
        else
          for (final member in staff)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(member.name.isEmpty ? member.userId : member.name),
                subtitle: Text(_titleCase(member.role)),
                trailing: IconButton(
                  onPressed: () => onRemove(member),
                  icon: const Icon(Icons.person_remove_outlined),
                ),
              ),
            ),
      ],
    );
  }
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;
  const _ReportMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: AppTheme.serif(17)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.sans(10.5, color: AppColors.muted),
          maxLines: 2,
        ),
      ],
    ),
  );
}

List<String> _rolePermissions(String role) => switch (role) {
  'manager' => const ['manage_all'],
  'booking' => const ['bookings', 'operations'],
  'accountant' => const ['finance'],
  'visa' => const ['bookings', 'documents'],
  'guide' => const ['operations', 'announcements'],
  _ => const ['bookings', 'announcements'],
};

String _titleCase(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
