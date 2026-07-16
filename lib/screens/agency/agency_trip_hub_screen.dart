import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../models/agency_operations_model.dart';
import '../../models/booking_model.dart';
import '../../models/offer_model.dart';
import '../../providers/app_provider.dart';
import '../../services/trip_export_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/status_chip.dart';
import '../../widgets/offer_image.dart';
import 'add_edit_offer_screen.dart';
import 'agency_bookings_tab.dart';

class AgencyTripHubScreen extends StatefulWidget {
  final Offer offer;

  const AgencyTripHubScreen({super.key, required this.offer});

  @override
  State<AgencyTripHubScreen> createState() => _AgencyTripHubScreenState();
}

class _AgencyTripHubScreenState extends State<AgencyTripHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _loading = true;
  List<Booking> _bookings = [];
  List<BookingTraveller> _travellers = [];
  List<TravellerDocument> _documents = [];
  List<TripAnnouncement> _announcements = [];
  List<TripRoom> _rooms = [];
  List<TripTransportSegment> _transport = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    if (mounted) setState(() => _loading = true);
    final provider = context.read<AppProvider>();
    await provider.loadAgencyBookings();
    final bookings = provider.agencyBookings
        .where((booking) => booking.offerId == widget.offer.id)
        .toList();
    final results = await Future.wait<dynamic>([
      provider.tripTravellers(widget.offer.id),
      provider.tripAnnouncements(widget.offer.id),
      provider.tripRooms(widget.offer.id),
      provider.tripTransport(widget.offer.id),
      provider.loadAgencyWallet(),
      Future.wait([
        for (final booking in bookings) provider.travellerDocuments(booking.id),
      ]),
    ]);
    if (!mounted) return;
    setState(() {
      _bookings = bookings;
      _travellers = results[0] as List<BookingTraveller>;
      _announcements = results[1] as List<TripAnnouncement>;
      _rooms = results[2] as List<TripRoom>;
      _transport = results[3] as List<TripTransportSegment>;
      _documents = (results[5] as List<List<TravellerDocument>>)
          .expand((rows) => rows)
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.offer.titleFor(lang),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: t.agencyTripDuplicate,
            onPressed: _duplicate,
            icon: const Icon(Icons.copy_all_outlined),
          ),
          IconButton(
            tooltip: t.addEditOfferEditTitle,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditOfferScreen(
                  companyId: widget.offer.companyId,
                  existing: widget.offer,
                ),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: t.agencyTripOverview),
            Tab(text: t.agencyTripBookings),
            Tab(text: t.agencyTripTravellers),
            Tab(text: t.agencyTripDocumentsVisa),
            Tab(text: t.agencyTripOperations),
            Tab(text: t.agencyTripUpdates),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _OverviewTab(
                    offer: widget.offer,
                    bookings: _bookings,
                    travellers: _travellers,
                    onExportExcel: _exportExcel,
                    onExportPdf: _exportPdf,
                  ),
                  _BookingsTab(bookings: _bookings),
                  _TravellersTab(
                    travellers: _travellers,
                    onOpen: _openTraveller,
                  ),
                  _DocumentsTab(
                    travellers: _travellers,
                    documents: _documents,
                    onOpenTraveller: _openTraveller,
                    onReviewDocument: _reviewDocument,
                  ),
                  _OperationsTab(
                    rooms: _rooms,
                    transport: _transport,
                    onAddRoom: _addRoom,
                    onDeleteRoom: _deleteRoom,
                    onAddTransport: _addTransport,
                    onDeleteTransport: _deleteTransport,
                  ),
                  _AnnouncementsTab(
                    announcements: _announcements,
                    onCreate: _createAnnouncement,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _duplicate() async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.agencyTripDuplicate),
        content: Text(t.agencyTripDuplicateBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.agencyDashboardCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.agencyTripDuplicate),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final result = await context.read<AppProvider>().duplicateOffer(
      widget.offer,
    );
    messenger.showSnackBar(
      appSnack(
        result.$1 ? t.agencyTripDuplicated : t.agencyTripDuplicateFailed,
        isError: !result.$1,
      ),
    );
  }

  Future<void> _exportExcel() async {
    final messenger = ScaffoldMessenger.of(context);
    final t = AppLocalizations.of(context);
    try {
      await TripExportService.shareExcel(
        offer: widget.offer,
        bookings: _bookings,
        travellers: _travellers,
      );
    } catch (error) {
      messenger.showSnackBar(appSnack(t.agencyTripExportFailed, isError: true));
    }
  }

  Future<void> _exportPdf() async {
    final messenger = ScaffoldMessenger.of(context);
    final t = AppLocalizations.of(context);
    try {
      await TripExportService.sharePdf(
        offer: widget.offer,
        bookings: _bookings,
        travellers: _travellers,
      );
    } catch (error) {
      messenger.showSnackBar(appSnack(t.agencyTripExportFailed, isError: true));
    }
  }

  Future<void> _openTraveller(BookingTraveller traveller) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) =>
          _TravellerOperationsSheet(traveller: traveller, rooms: _rooms),
    );
    if (changed == true) await _reload();
  }

  Future<void> _reviewDocument(TravellerDocument document) async {
    final t = AppLocalizations.of(context);
    final previewUrl = await context.read<AppProvider>().travellerDocumentUrl(
      document.storagePath,
    );
    if (!mounted) return;
    final reason = TextEditingController();
    final decision = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.agencyDocumentReview),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (previewUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    previewUrl,
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: reason,
                maxLines: 3,
                decoration: InputDecoration(labelText: t.workflowReasonHint),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'rejected'),
            child: Text(
              t.agencyDocumentStatusRejected,
              style: const TextStyle(color: AppColors.errorRed),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'approved'),
            child: Text(t.agencyDocumentStatusApproved),
          ),
        ],
      ),
    );
    final reasonValue = reason.text.trim();
    reason.dispose();
    if (decision == null || !mounted) return;
    if (decision == 'rejected' && reasonValue.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(appSnack(t.workflowReasonRequired, isError: true));
      return;
    }
    final error = await context.read<AppProvider>().reviewTravellerDocument(
      documentId: document.id,
      status: decision,
      reason: reasonValue,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.workflowStatusUpdated, isError: error != null),
    );
    if (error == null) await _reload();
  }

  Future<void> _addRoom() async {
    final t = AppLocalizations.of(context);
    final label = TextEditingController();
    final capacity = TextEditingController(text: '4');
    var city = 'makkah';
    var gender = 'family';
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(t.agencyTripAddRoom),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: city,
                  decoration: InputDecoration(labelText: t.agencyTripCity),
                  items: [
                    DropdownMenuItem(
                      value: 'makkah',
                      child: Text(t.agencyTripMakkah),
                    ),
                    DropdownMenuItem(
                      value: 'madinah',
                      child: Text(t.agencyTripMadinah),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => city = value ?? city),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: label,
                  decoration: InputDecoration(labelText: t.agencyTripRoomLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: capacity,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.workflowCapacity),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: InputDecoration(
                    labelText: t.agencyTripRoomPolicy,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'family',
                      child: Text(t.agencyTripRoomFamily),
                    ),
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(t.agencyTripRoomMale),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(t.agencyTripRoomFemale),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => gender = value ?? gender),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.agencyDashboardCancel),
            ),
            FilledButton(
              onPressed: () {
                final cap = int.tryParse(capacity.text.trim());
                if (label.text.trim().isEmpty || cap == null || cap < 1) return;
                Navigator.pop(dialogContext, {
                  'city': city,
                  'label': label.text.trim(),
                  'capacity': cap,
                  'gender': gender,
                });
              },
              child: Text(t.addEditOfferSave),
            ),
          ],
        ),
      ),
    );
    label.dispose();
    capacity.dispose();
    if (values == null || !mounted) return;
    final error = await context.read<AppProvider>().createTripRoom(
      packageId: widget.offer.id,
      city: values['city'] as String,
      label: values['label'] as String,
      capacity: values['capacity'] as int,
      genderPolicy: values['gender'] as String,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyTripRoomCreated, isError: error != null),
    );
    if (error == null) await _reload();
  }

  Future<void> _deleteRoom(TripRoom room) async {
    final error = await context.read<AppProvider>().deleteTripRoom(room.id);
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyTripRoomDeleted, isError: error != null),
    );
    if (error == null) await _reload();
  }

  Future<void> _addTransport() async {
    final t = AppLocalizations.of(context);
    final providerCtrl = TextEditingController();
    final reference = TextEditingController();
    final from = TextEditingController();
    final meeting = TextEditingController();
    final guide = TextEditingController();
    var mode = 'flight';
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(t.agencyTripAddTransport),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: mode,
                  decoration: InputDecoration(
                    labelText: t.filterSheetTransportation,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'flight',
                      child: Text(t.offersByAir),
                    ),
                    DropdownMenuItem(
                      value: 'bus',
                      child: Text(t.offersByCoach),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => mode = value ?? mode),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: providerCtrl,
                  decoration: InputDecoration(
                    labelText: t.agencyTripTransportProvider,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reference,
                  decoration: InputDecoration(
                    labelText: t.agencyTripTransportReference,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: from,
                  decoration: InputDecoration(
                    labelText: t.agencyTripDeparturePlace,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: meeting,
                  decoration: InputDecoration(
                    labelText: t.agencyTripMeetingPoint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: guide,
                  decoration: InputDecoration(labelText: t.agencyTripGuide),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.agencyDashboardCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, {
                'mode': mode,
                'provider': providerCtrl.text.trim(),
                'reference_no': reference.text.trim(),
                'departure_place': from.text.trim(),
                'meeting_point': meeting.text.trim(),
                'guide_name': guide.text.trim(),
              }),
              child: Text(t.addEditOfferSave),
            ),
          ],
        ),
      ),
    );
    for (final controller in [providerCtrl, reference, from, meeting, guide]) {
      controller.dispose();
    }
    if (values == null || !mounted) return;
    final error = await context.read<AppProvider>().createTripTransport(
      packageId: widget.offer.id,
      fields: values,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyTripTransportCreated, isError: error != null),
    );
    if (error == null) await _reload();
  }

  Future<void> _deleteTransport(TripTransportSegment segment) async {
    final error = await context.read<AppProvider>().deleteTripTransport(
      segment.id,
    );
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyTripTransportDeleted, isError: error != null),
    );
    if (error == null) await _reload();
  }

  Future<void> _createAnnouncement() async {
    final t = AppLocalizations.of(context);
    final title = TextEditingController();
    final body = TextEditingController();
    var audience = 'all';
    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(t.agencyTripNewAnnouncement),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    labelText: t.agencyTripAnnouncementTitle,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: body,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: t.agencyTripAnnouncementMessage,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: audience,
                  decoration: InputDecoration(labelText: t.agencyTripAudience),
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text(t.adminFilterAll),
                    ),
                    DropdownMenuItem(
                      value: 'confirmed',
                      child: Text(t.bookingsStatusConfirmed),
                    ),
                    DropdownMenuItem(
                      value: 'unpaid',
                      child: Text(t.agencyTripAudienceUnpaid),
                    ),
                    DropdownMenuItem(
                      value: 'documents_missing',
                      child: Text(t.agencyTripDocumentsMissing),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => audience = value ?? audience),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.agencyDashboardCancel),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
                  return;
                }
                Navigator.pop(dialogContext, {
                  'title': title.text.trim(),
                  'body': body.text.trim(),
                  'audience': audience,
                });
              },
              child: Text(t.agencyTripSendAnnouncement),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    body.dispose();
    if (values == null || !mounted) return;
    final error = await context.read<AppProvider>().createTripAnnouncement(
      packageId: widget.offer.id,
      title: values['title']!,
      body: values['body']!,
      audience: values['audience']!,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      appSnack(error ?? t.agencyTripAnnouncementSent, isError: error != null),
    );
    if (error == null) await _reload();
  }
}

class _OverviewTab extends StatelessWidget {
  final Offer offer;
  final List<Booking> bookings;
  final List<BookingTraveller> travellers;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;

  const _OverviewTab({
    required this.offer,
    required this.bookings,
    required this.travellers,
    required this.onExportExcel,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final confirmedValue = bookings
        .where(
          (booking) => ![
            'cancelled',
            'rejected',
            'expired',
          ].contains(booking.operationalStage),
        )
        .fold(0.0, (sum, booking) => sum + booking.total);
    final paid = bookings.fold(0.0, (sum, booking) => sum + booking.amountPaid);
    final missing = travellers
        .where((traveller) => traveller.documentStatus != 'approved')
        .length;
    final visaPending = travellers
        .where((traveller) => traveller.visaStatus != 'approved')
        .length;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              OfferImage(offer: offer, height: 160),
              PositionedDirectional(
                start: 14,
                end: 14,
                bottom: 14,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DarkBadge(label: _titleCase(offer.lifecycleStatus)),
                    if (offer.departureDate != null)
                      _DarkBadge(
                        label: offer.departureDate!.toIso8601String().substring(
                          0,
                          10,
                        ),
                      ),
                    if (offer.remainingSeats != null)
                      _DarkBadge(
                        label: t.offerCapacityRemaining(offer.remainingSeats!),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: [
            _MetricCard(
              label: t.agencyTripConfirmedValue,
              value: fmtIqd(confirmedValue),
              icon: Icons.receipt_long_outlined,
            ),
            _MetricCard(
              label: t.agencyTripCollected,
              value: fmtIqd(paid),
              icon: Icons.payments_outlined,
            ),
            _MetricCard(
              label: t.agencyTripDocumentsMissing,
              value: '$missing',
              icon: Icons.folder_off_outlined,
              alert: missing > 0,
            ),
            _MetricCard(
              label: t.agencyTripVisaPending,
              value: '$visaPending',
              icon: Icons.approval_outlined,
              alert: visaPending > 0,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          t.agencyTripPassengerExports,
          style: AppTheme.sans(14, weight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: travellers.isEmpty ? null : onExportExcel,
                icon: const Icon(Icons.table_view_outlined),
                label: Text(t.agencyTripExportExcel),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: travellers.isEmpty ? null : onExportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(t.agencyTripExportPdf),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookingsTab extends StatelessWidget {
  final List<Booking> bookings;
  const _BookingsTab({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (bookings.isEmpty) {
      return ListView(
        children: [
          EmptyState(
            icon: Icons.inbox_outlined,
            title: t.agencyBookingsEmptyTitle,
            body: t.agencyBookingsEmptyBody,
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => BookingRequestCard(booking: bookings[index]),
    );
  }
}

class _TravellersTab extends StatefulWidget {
  final List<BookingTraveller> travellers;
  final ValueChanged<BookingTraveller> onOpen;
  const _TravellersTab({required this.travellers, required this.onOpen});

  @override
  State<_TravellersTab> createState() => _TravellersTabState();
}

class _TravellersTabState extends State<_TravellersTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final rows = widget.travellers.where((traveller) {
      final query = _query.toLowerCase();
      return traveller.fullName.toLowerCase().contains(query) ||
          (traveller.localName ?? '').toLowerCase().contains(query) ||
          (traveller.passportNo ?? '').toLowerCase().contains(query);
    }).toList();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: t.agencyTripSearchTravellers,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        const SizedBox(height: 14),
        if (rows.isEmpty)
          EmptyState(
            icon: Icons.groups_outlined,
            title: t.agencyTripNoTravellers,
          )
        else
          for (final traveller in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TravellerCard(
                traveller: traveller,
                onTap: () => widget.onOpen(traveller),
              ),
            ),
      ],
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  final List<BookingTraveller> travellers;
  final List<TravellerDocument> documents;
  final ValueChanged<BookingTraveller> onOpenTraveller;
  final ValueChanged<TravellerDocument> onReviewDocument;

  const _DocumentsTab({
    required this.travellers,
    required this.documents,
    required this.onOpenTraveller,
    required this.onReviewDocument,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        for (final traveller in travellers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TravellerCard(
              traveller: traveller,
              onTap: () => onOpenTraveller(traveller),
            ),
          ),
        if (travellers.isEmpty)
          EmptyState(
            icon: Icons.folder_off_outlined,
            title: t.agencyTripNoTravellers,
          ),
        if (documents.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            t.agencyDocumentUploads,
            style: AppTheme.sans(14, weight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final document in documents)
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(_titleCase(document.kind)),
                subtitle: Text(_titleCase(document.status)),
                trailing: document.status == 'under_review'
                    ? TextButton(
                        onPressed: () => onReviewDocument(document),
                        child: Text(t.agencyDocumentReview),
                      )
                    : null,
              ),
            ),
        ],
      ],
    );
  }
}

class _OperationsTab extends StatelessWidget {
  final List<TripRoom> rooms;
  final List<TripTransportSegment> transport;
  final VoidCallback onAddRoom;
  final ValueChanged<TripRoom> onDeleteRoom;
  final VoidCallback onAddTransport;
  final ValueChanged<TripTransportSegment> onDeleteTransport;

  const _OperationsTab({
    required this.rooms,
    required this.transport,
    required this.onAddRoom,
    required this.onDeleteRoom,
    required this.onAddTransport,
    required this.onDeleteTransport,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _SectionTitle(
          title: t.agencyTripRooming,
          action: t.agencyTripAddRoom,
          onAction: onAddRoom,
        ),
        if (rooms.isEmpty)
          _InlineEmpty(text: t.agencyTripNoRooms)
        else
          for (final room in rooms)
            Card(
              child: ListTile(
                leading: const Icon(Icons.bed_outlined),
                title: Text(room.label),
                subtitle: Text(
                  '${_titleCase(room.city)} · ${room.assignedCount}/${room.capacity} · ${_titleCase(room.genderPolicy)}',
                ),
                trailing: IconButton(
                  onPressed: () => onDeleteRoom(room),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
        const SizedBox(height: 22),
        _SectionTitle(
          title: t.agencyTripTransport,
          action: t.agencyTripAddTransport,
          onAction: onAddTransport,
        ),
        if (transport.isEmpty)
          _InlineEmpty(text: t.agencyTripNoTransport)
        else
          for (final segment in transport)
            Card(
              child: ListTile(
                leading: Icon(
                  segment.mode == 'flight'
                      ? Icons.flight_takeoff_outlined
                      : Icons.directions_bus_outlined,
                ),
                title: Text(
                  [
                    segment.provider,
                    segment.referenceNo,
                  ].where((value) => value.isNotEmpty).join(' · '),
                ),
                subtitle: Text(
                  [
                    segment.departurePlace,
                    segment.meetingPoint,
                  ].where((value) => value.isNotEmpty).join(' · '),
                ),
                trailing: IconButton(
                  onPressed: () => onDeleteTransport(segment),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
      ],
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final List<TripAnnouncement> announcements;
  final VoidCallback onCreate;

  const _AnnouncementsTab({
    required this.announcements,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.campaign_outlined),
          label: Text(t.agencyTripNewAnnouncement),
        ),
        const SizedBox(height: 14),
        if (announcements.isEmpty)
          EmptyState(
            icon: Icons.notifications_none_outlined,
            title: t.agencyTripNoAnnouncements,
          )
        else
          for (final announcement in announcements)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: AppTheme.sans(14, weight: FontWeight.w800),
                          ),
                        ),
                        StatusChip(
                          kind: StatusKind.neutral,
                          label: _titleCase(announcement.audience),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.body,
                      style: AppTheme.sans(
                        12.5,
                        color: AppColors.inkLight,
                      ).copyWith(height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _TravellerOperationsSheet extends StatefulWidget {
  final BookingTraveller traveller;
  final List<TripRoom> rooms;
  const _TravellerOperationsSheet({
    required this.traveller,
    required this.rooms,
  });

  @override
  State<_TravellerOperationsSheet> createState() =>
      _TravellerOperationsSheetState();
}

class _TravellerOperationsSheetState extends State<_TravellerOperationsSheet> {
  late String _documents = widget.traveller.documentStatus;
  late String _visa = widget.traveller.visaStatus;
  late final TextEditingController _documentReason = TextEditingController(
    text: widget.traveller.documentReason,
  );
  late final TextEditingController _visaReference = TextEditingController(
    text: widget.traveller.visaReference,
  );
  late final TextEditingController _visaReason = TextEditingController(
    text: widget.traveller.visaReason,
  );
  late final TextEditingController _seat = TextEditingController(
    text: widget.traveller.transportSeat,
  );
  bool _saving = false;
  String? _roomId;

  @override
  void dispose() {
    _documentReason.dispose();
    _visaReference.dispose();
    _visaReason.dispose();
    _seat.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.traveller.fullName, style: AppTheme.serif(22)),
              if ((widget.traveller.localName ?? '').isNotEmpty)
                Text(
                  widget.traveller.localName!,
                  style: AppTheme.sans(13, color: AppColors.muted),
                ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: _documents,
                decoration: InputDecoration(
                  labelText: t.agencyTravellerDocuments,
                ),
                items:
                    const [
                          'missing',
                          'uploaded',
                          'under_review',
                          'approved',
                          'rejected',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_titleCase(value)),
                          ),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _documents = value ?? _documents),
              ),
              if (_documents == 'rejected') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _documentReason,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: t.workflowReasonRequired,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _visa,
                decoration: InputDecoration(labelText: t.agencyVisaStatus),
                items:
                    const [
                          'not_started',
                          'documents_missing',
                          'ready_to_apply',
                          'submitted',
                          'under_review',
                          'approved',
                          'rejected',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(_titleCase(value)),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _visa = value ?? _visa),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _visaReference,
                decoration: InputDecoration(labelText: t.agencyVisaReference),
              ),
              if (_visa == 'rejected') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _visaReason,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: t.workflowReasonRequired,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _seat,
                decoration: InputDecoration(
                  labelText: t.agencyTripTransportSeat,
                ),
              ),
              if (widget.rooms.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _roomId,
                  decoration: InputDecoration(
                    labelText: t.agencyTripAssignRoom,
                  ),
                  items: [
                    for (final room in widget.rooms)
                      DropdownMenuItem(
                        value: room.id,
                        child: Text(
                          '${_titleCase(room.city)} · ${room.label} (${room.remaining})',
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _roomId = value),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(t.addEditOfferSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    if (_documents == 'rejected' && _documentReason.text.trim().isEmpty ||
        _visa == 'rejected' && _visaReason.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(appSnack(t.workflowReasonRequired, isError: true));
      return;
    }
    setState(() => _saving = true);
    final error = await context.read<AppProvider>().updateTravellerOperations(
      travellerId: widget.traveller.id,
      documentStatus: _documents,
      documentReason: _documentReason.text.trim(),
      visaStatus: _visa,
      visaReference: _visaReference.text.trim(),
      visaReason: _visaReason.text.trim(),
      transportSeat: _seat.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(appSnack(error, isError: true));
      return;
    }
    if (_roomId != null) {
      final roomError = await context.read<AppProvider>().assignTravellerRoom(
        roomId: _roomId!,
        travellerId: widget.traveller.id,
      );
      if (!mounted) return;
      if (roomError != null) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(appSnack(roomError, isError: true));
        return;
      }
    }
    Navigator.pop(context, true);
  }
}

class _TravellerCard extends StatelessWidget {
  final BookingTraveller traveller;
  final VoidCallback onTap;
  const _TravellerCard({required this.traveller, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              child: Text(
                traveller.fullName.isEmpty
                    ? '?'
                    : traveller.fullName.characters.first.toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    traveller.fullName,
                    style: AppTheme.sans(13.5, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      StatusChip(
                        kind: _statusKind(traveller.documentStatus),
                        label: _titleCase(traveller.documentStatus),
                      ),
                      StatusChip(
                        kind: _statusKind(traveller.visaStatus),
                        label: _titleCase(traveller.visaStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool alert;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: alert ? AppColors.gold : AppColors.primary, size: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: AppTheme.serif(16)),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.sans(10.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DarkBadge extends StatelessWidget {
  final String label;
  const _DarkBadge({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: AppTheme.sans(10.5, weight: FontWeight.w700, color: Colors.white),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: AppTheme.sans(15, weight: FontWeight.w800)),
      ),
      TextButton.icon(
        onPressed: onAction,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(action),
      ),
    ],
  );
}

class _InlineEmpty extends StatelessWidget {
  final String text;
  const _InlineEmpty({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(text, style: AppTheme.sans(12.5, color: AppColors.muted)),
  );
}

StatusKind _statusKind(String value) {
  if (value == 'approved') return StatusKind.positive;
  if (value == 'rejected' || value == 'documents_missing') {
    return StatusKind.negative;
  }
  if (value == 'missing' || value == 'under_review' || value == 'submitted') {
    return StatusKind.pending;
  }
  return StatusKind.neutral;
}

String _titleCase(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
