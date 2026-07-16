import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/offer_model.dart';
import '../../models/company_model.dart';
import '../../models/booking_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/islamic_pattern.dart';
import '../auth/auth_screen.dart';
import '../../l10n/generated/app_localizations.dart';

/// Three-step booking flow: room & pilgrim count → per-pilgrim details →
/// review & payment method, ending on a full-screen confirmation ticket.
class BookingFlowScreen extends StatefulWidget {
  final Offer offer;
  final Company company;
  const BookingFlowScreen({
    super.key,
    required this.offer,
    required this.company,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

/// Controllers for one pilgrim's details card.
class _PilgrimFields {
  final name = TextEditingController();
  final localName = TextEditingController();
  final phone = TextEditingController();
  DateTime? dob;

  void dispose() {
    name.dispose();
    localName.dispose();
    phone.dispose();
  }

  bool get complete => name.text.trim().isNotEmpty && dob != null;

  PilgrimInfo toInfo() => PilgrimInfo(
    fullName: name.text.trim(),
    localName: localName.text.trim(),
    dateOfBirth: dob,
    phone: phone.text.trim(),
  );
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _step = 0;
  late int _roomOccupancy;
  int _travelers = 1;
  DateTime? _departureDate;
  String _mealPreference = '';
  late String _payMethod;
  bool _submitting = false;
  BookingQuote? _quote;
  String? _quoteError;
  bool _quoteLoading = false;
  late final String _requestKey;

  final List<_PilgrimFields> _pilgrims = [];

  double get _unitPrice => widget.offer.priceForOccupancy(_roomOccupancy);
  double get _total => _quote?.totalIqd ?? _unitPrice * _travelers;
  double get _amountDueNow =>
      _quote?.amountDueNowIqd ??
      (widget.offer.depositIqd > 0
          ? (widget.offer.depositIqd * _travelers).clamp(0, _total)
          : _total);
  int get _roomCount =>
      _quote?.roomCount ?? (_travelers / _roomOccupancy).ceil();
  List<String> get _supportedPaymentMethods =>
      (_quote?.acceptedPaymentMethods ?? widget.offer.acceptedPaymentMethods)
          .where((method) => method == 'fib' || method == 'cash')
          .toList();
  String get _totalFmt => fmtIqd(_total);

  @override
  void initState() {
    super.initState();
    _requestKey = '${widget.offer.id}-${DateTime.now().microsecondsSinceEpoch}';
    final provider = context.read<AppProvider>();
    final supportedMethods = widget.offer.acceptedPaymentMethods
        .where((method) => method == 'fib' || method == 'cash')
        .toList();
    _payMethod = supportedMethods.contains(provider.preferredPayMethod)
        ? provider.preferredPayMethod
        : (supportedMethods.isEmpty ? 'cash' : supportedMethods.first);
    final availableRooms = widget.offer.availableRoomOccupancies;
    _roomOccupancy = availableRooms.first;
    // Preserve the legacy package preference when it is still available.
    final room = widget.offer.room.toLowerCase();
    if ((room.contains('triple') || room.contains('3')) &&
        availableRooms.contains(3)) {
      _roomOccupancy = 3;
    } else if ((room.contains('double') || room.contains('2')) &&
        availableRooms.contains(2)) {
      _roomOccupancy = 2;
    } else if ((room.contains('quad') || room.contains('4')) &&
        availableRooms.contains(4)) {
      _roomOccupancy = 4;
    }
    _departureDate = widget.offer.departureDate;
    _mealPreference = widget.offer.meals;
    _syncPilgrims();
    Future<void>.microtask(_refreshQuote);
  }

  @override
  void dispose() {
    for (final p in _pilgrims) {
      p.dispose();
    }
    super.dispose();
  }

  void _syncPilgrims() {
    while (_pilgrims.length < _travelers) {
      final entry = _PilgrimFields();
      entry.name.addListener(_onFieldChanged);
      // The lead pilgrim's phone starts from the account's phone number.
      if (_pilgrims.isEmpty) {
        entry.phone.text = context.read<AppProvider>().user?.phone ?? '';
      }
      _pilgrims.add(entry);
    }
    while (_pilgrims.length > _travelers) {
      _pilgrims.removeLast().dispose();
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _allPilgrimsComplete => _pilgrims.every((p) => p.complete);

  String _roomOptionLabel(AppLocalizations t, int occupancy) {
    switch (occupancy) {
      case 2:
        return t.bookingRoomDouble;
      case 3:
        return t.bookingRoomTriple;
      case 4:
        return t.bookingRoomQuad;
      default:
        return t.bookingRoomOccupancy(occupancy);
    }
  }

  String _roomLabel(AppLocalizations t) => _roomOptionLabel(t, _roomOccupancy);

  String _mealLabel(AppLocalizations t) => Offer.mealsLabel(_mealPreference, t);

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _refreshQuote() async {
    final requestedTravellers = _travelers;
    final requestedOccupancy = _roomOccupancy;
    if (mounted) {
      setState(() {
        _quoteLoading = true;
        _quoteError = null;
      });
    }
    try {
      final quote = await context.read<AppProvider>().bookingQuote(
        widget.offer,
        travelers: requestedTravellers,
        roomOccupancy: requestedOccupancy,
      );
      if (!mounted ||
          requestedTravellers != _travelers ||
          requestedOccupancy != _roomOccupancy) {
        return;
      }
      setState(() {
        _quote = quote;
        _quoteLoading = false;
        _departureDate = quote.departureDate;
        if (quote.meal.isNotEmpty) _mealPreference = quote.meal;
        if (!quote.acceptedPaymentMethods.contains(_payMethod)) {
          final supported = quote.acceptedPaymentMethods
              .where((method) => method == 'fib' || method == 'cash')
              .toList();
          if (supported.isNotEmpty) _payMethod = supported.first;
        }
      });
    } catch (error) {
      if (!mounted ||
          requestedTravellers != _travelers ||
          requestedOccupancy != _roomOccupancy) {
        return;
      }
      setState(() {
        _quote = null;
        _quoteLoading = false;
        _quoteError = error.toString();
      });
    }
  }

  Future<void> _pickDob(_PilgrimFields entry) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: entry.dob ?? DateTime(now.year - 30),
      firstDate: DateTime(1930),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => entry.dob = picked);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!provider.isSignedIn) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (ok != true || !mounted) return;
    }

    await _refreshQuote();
    if (!mounted) return;
    if (_quote == null || _quoteError != null) {
      messenger.showSnackBar(
        appSnack(_quoteError ?? t.bookingFailed, isError: true),
      );
      return;
    }

    setState(() => _submitting = true);
    final err = await provider.confirmBooking(
      widget.offer,
      _travelers,
      payMethod: _payMethod,
      departureDate: _departureDate,
      roomLabel: _roomLabel(t),
      roomOccupancy: _roomOccupancy,
      mealPreference: _mealPreference,
      pilgrims: _pilgrims.map((p) => p.toInfo()).toList(),
      requestKey: _requestKey,
    );
    if (!mounted) return;
    if (err == null) {
      // The freshest booking carries the real reference for the ticket.
      final booking = provider.bookings.isNotEmpty
          ? provider.bookings.first
          : null;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            offer: widget.offer,
            company: widget.company,
            booking: booking,
            travelers: _travelers,
            roomLabel: _roomLabel(t),
            departureDate: _departureDate,
            payMethod: _payMethod,
            total: _total,
          ),
        ),
      );
    } else {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        appSnack('${t.bookingFailed} ($err)', isError: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;

    final String title;
    final String subtitle;
    switch (_step) {
      case 1:
        title = t.bookingStepPilgrims;
        subtitle = t.bookingPilgrimsSummary(_travelers, _roomLabel(t));
      case 2:
        title = t.bookingReviewTitle;
        subtitle = t.bookingReviewSub;
      default:
        title = t.bookingStepRoom;
        subtitle =
            '${widget.offer.titleFor(lang)} — ${widget.company.nameFor(lang)}';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const IslamicPattern(opacity: 0.04, isEightFold: true),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _back,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTheme.serif(24)),
                            const SizedBox(height: 1),
                            Text(
                              subtitle,
                              style: AppTheme.sans(12, color: AppColors.muted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
                  child: _Stepper(current: _step),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: SingleChildScrollView(
                      key: ValueKey(_step),
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                      child: switch (_step) {
                        1 => _buildPilgrimsStep(t),
                        2 => _buildReviewStep(t, lang),
                        _ => _buildRoomStep(t),
                      },
                    ),
                  ),
                ),
                _buildBottomBar(t),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 1: room type + pilgrim count ─────────────────────────────────────

  Widget _buildRoomStep(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.bookingChooseRoom,
          style: AppTheme.sans(14, weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        for (
          var i = 0;
          i < widget.offer.availableRoomOccupancies.length;
          i++
        ) ...[
          _RoomCard(
            label: _roomOptionLabel(
              t,
              widget.offer.availableRoomOccupancies[i],
            ),
            sub:
                '${t.bookingRoomPax(widget.offer.availableRoomOccupancies[i])} · ${fmtIqd(widget.offer.priceForOccupancy(widget.offer.availableRoomOccupancies[i]))}',
            badge: widget.offer.availableRoomOccupancies[i] == 3
                ? t.bookingMostPopular
                : null,
            selected:
                _roomOccupancy == widget.offer.availableRoomOccupancies[i],
            onTap: () {
              setState(
                () => _roomOccupancy = widget.offer.availableRoomOccupancies[i],
              );
              _refreshQuote();
            },
          ),
          if (i < widget.offer.availableRoomOccupancies.length - 1)
            const SizedBox(height: 12),
        ],
        const SizedBox(height: 22),
        if (_mealPreference.isNotEmpty) ...[
          Text(
            t.bookingChooseMeal,
            style: AppTheme.sans(14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _RoomCard(
            label: Offer.mealsLabel(_mealPreference, t),
            sub: t.bookingMealPreference,
            selected: true,
            onTap: () {},
          ),
          const SizedBox(height: 22),
        ],
        Text(
          t.bookingPilgrimCountTitle,
          style: AppTheme.sans(14, weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.offerDetailTravelers,
                      style: AppTheme.sans(14, weight: FontWeight.w700),
                    ),
                    Text(
                      t.bookingPilgrimAge,
                      style: AppTheme.sans(11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              _CounterBtn(
                icon: Icons.remove_rounded,
                onTap: () {
                  if (_travelers > 1) {
                    setState(() {
                      _travelers--;
                      _syncPilgrims();
                    });
                    _refreshQuote();
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('$_travelers', style: AppTheme.serif(22)),
              ),
              _CounterBtn(
                icon: Icons.add_rounded,
                onTap: () {
                  final remaining = widget.offer.remainingSeats ?? 50;
                  if (_travelers < remaining && _travelers < 50) {
                    setState(() {
                      _travelers++;
                      _syncPilgrims();
                    });
                    _refreshQuote();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // departure date
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.offerDetailDepartureDate,
                      style: AppTheme.sans(14, weight: FontWeight.w700),
                    ),
                    Text(
                      _departureDate == null
                          ? t.dateToBeScheduled
                          : _fmtDate(_departureDate!),
                      style: AppTheme.sans(
                        11.5,
                        color: _departureDate == null
                            ? AppColors.muted
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ),
        if (_quoteError != null) ...[
          const SizedBox(height: 10),
          Text(
            _quoteError!,
            style: AppTheme.sans(12, color: AppColors.errorRed),
          ),
        ],
        const SizedBox(height: 18),
        // running total on deep emerald, gold total — echoes the prayer card
        Container(
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2D22),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.bookingTotalLine(_travelers, fmtIqd(_unitPrice)),
                      style: AppTheme.sans(
                        12,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  Text(
                    _totalFmt,
                    style: AppTheme.sans(
                      12,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Color(0xFF194637), height: 1),
              ),
              Row(
                children: [
                  Text(
                    t.offerDetailTotal,
                    style: AppTheme.sans(
                      14,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _totalFmt,
                    style: AppTheme.serif(22, color: const Color(0xFFF3E6C4)),
                  ),
                ],
              ),
              if (_amountDueNow < _total) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      t.offerFormDepositAmount,
                      style: AppTheme.sans(
                        12,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      fmtIqd(_amountDueNow),
                      style: AppTheme.sans(
                        12,
                        weight: FontWeight.w700,
                        color: const Color(0xFFF3E6C4),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 2: pilgrim details ───────────────────────────────────────────────

  Widget _buildPilgrimsStep(AppLocalizations t) {
    return Column(
      children: [
        for (var i = 0; i < _pilgrims.length; i++) ...[
          _PilgrimCard(
            index: i,
            entry: _pilgrims[i],
            showPhone: i == 0,
            onPickDob: () => _pickDob(_pilgrims[i]),
          ),
          if (i < _pilgrims.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  // ── STEP 3: review + payment ──────────────────────────────────────────────

  Widget _buildReviewStep(AppLocalizations t, String lang) {
    final names = _pilgrims
        .map((p) => p.name.text.trim())
        .where((n) => n.isNotEmpty)
        .join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.bookingSummaryTitle, style: AppTheme.serif(18)),
              const SizedBox(height: 12),
              _SummaryRow(
                label: t.bookingSummaryTrip,
                value: widget.offer.titleFor(lang),
              ),
              _SummaryRow(
                label: t.bookingSummaryCompany,
                value: widget.company.nameFor(lang),
              ),
              _SummaryRow(
                label: t.bookingSummaryDeparture,
                value: _departureDate == null
                    ? t.dateToBeScheduled
                    : _fmtDate(_departureDate!),
              ),
              if (names.isNotEmpty)
                _SummaryRow(label: t.bookingSummaryPilgrims, value: names),
              _SummaryRow(label: t.bookingSummaryRoom, value: _roomLabel(t)),
              _SummaryRow(label: t.bookingRoomCount, value: '$_roomCount'),
              _SummaryRow(label: t.bookingSummaryMeal, value: _mealLabel(t)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: _DashedLine(),
              ),
              Row(
                children: [
                  Text(
                    t.offerDetailTotal,
                    style: AppTheme.sans(14, weight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    _totalFmt,
                    style: AppTheme.serif(22, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          t.bookingPayMethod,
          style: AppTheme.sans(14, weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (_supportedPaymentMethods.contains('fib')) ...[
          _PayCard(
            label: t.payFib,
            sub: t.payFibSub,
            selected: _payMethod == 'fib',
            onTap: () => setState(() => _payMethod = 'fib'),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16324F),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Text(
                'FIB',
                style: AppTheme.sans(
                  11,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (_supportedPaymentMethods.contains('cash'))
            const SizedBox(height: 10),
        ],
        if (_supportedPaymentMethods.contains('cash'))
          _PayCard(
            label: t.payCash,
            sub: t.payCashSub,
            selected: _payMethod == 'cash',
            onTap: () => setState(() => _payMethod = 'cash'),
            leading: _PayIconTile(icon: Icons.payments_outlined),
          ),
      ],
    );
  }

  // ── bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(AppLocalizations t) {
    final Widget bar;
    if (_step == 0) {
      bar = _PrimaryButton(
        label: t.bookingContinue,
        enabled: !_quoteLoading && _quoteError == null && _quote != null,
        onTap: () => setState(() => _step = 1),
      );
    } else if (_step == 1) {
      bar = _PrimaryButton(
        label: t.bookingContinueToPay,
        enabled: _allPilgrimsComplete,
        onTap: () => setState(() => _step = 2),
      );
    } else {
      bar = Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.offerDetailTotal,
                style: AppTheme.sans(11, color: AppColors.muted),
              ),
              Text(
                _totalFmt,
                style: AppTheme.serif(21, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _PrimaryButton(
              label: t.bookingConfirmBtn,
              loading: _submitting,
              onTap: _confirm,
            ),
          ),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: Color(0x1E0F5C4D), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: bar,
    );
  }
}

// ── shared pieces ─────────────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  final int current;
  const _Stepper({required this.current});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final labels = [t.bookingStepRoom, t.bookingStepPilgrims, t.bookingStepPay];
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              _StepNode(index: i, current: current),
              if (i < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: i < current
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 3; i++)
              Text(
                labels[i],
                style: AppTheme.sans(
                  10.5,
                  weight: i == current ? FontWeight.w800 : FontWeight.w600,
                  color: i <= current
                      ? AppColors.primary
                      : AppColors.mutedLight,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  final int index;
  final int current;
  const _StepNode({required this.index, required this.current});

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: done || active ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: done || active ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
          : Text(
              '${index + 1}',
              style: AppTheme.sans(
                12,
                weight: FontWeight.w800,
                color: active ? Colors.white : AppColors.mutedLight,
              ),
            ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final String label;
  final String sub;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;
  const _RoomCard({
    required this.label,
    required this.sub,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0F3729).withValues(alpha: 0.1),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.mutedLight,
                      width: selected ? 6.5 : 2,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTheme.sans(14, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: AppTheme.sans(11.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            PositionedDirectional(
              top: -9,
              start: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  badge!,
                  style: AppTheme.sans(
                    9.5,
                    weight: FontWeight.w800,
                    color: const Color(0xFF1C2317),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}

class _PilgrimCard extends StatelessWidget {
  final int index;
  final _PilgrimFields entry;
  final bool showPhone;
  final VoidCallback onPickDob;
  const _PilgrimCard({
    required this.index,
    required this.entry,
    required this.showPhone,
    required this.onPickDob,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final complete = entry.complete;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: complete ? AppColors.primary : AppColors.chipBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTheme.sans(
                    12,
                    weight: FontWeight.w800,
                    color: complete ? Colors.white : AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.bookingPilgrimN(index + 1),
                  style: AppTheme.sans(14.5, weight: FontWeight.w700),
                ),
              ),
              if (complete) ...[
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  t.bookingStatusComplete,
                  style: AppTheme.sans(
                    11.5,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ] else
                Text(
                  t.bookingStatusIncomplete,
                  style: AppTheme.sans(
                    11.5,
                    weight: FontWeight.w700,
                    color: AppColors.errorRed,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _FieldLabel(t.bookingPassportName),
          _InputBox(controller: entry.name, hint: t.bookingPassportNameHint),
          const SizedBox(height: 12),
          _FieldLabel(t.bookingLocalName),
          _InputBox(controller: entry.localName, hint: t.bookingLocalNameHint),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel(t.bookingDob),
              GestureDetector(
                onTap: onPickDob,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.dob == null
                              ? t.bookingDobHint
                              : '${entry.dob!.day}/${entry.dob!.month}/${entry.dob!.year}',
                          style: AppTheme.sans(
                            13,
                            color: entry.dob == null
                                ? AppColors.mutedLight
                                : AppColors.ink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.event_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showPhone) ...[
            const SizedBox(height: 12),
            _FieldLabel(t.bookingPhoneLabel),
            _InputBox(
              controller: entry.phone,
              hint: '+964 750 000 0000',
              keyboardType: TextInputType.phone,
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: AppTheme.sans(
          12,
          weight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _InputBox({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTheme.sans(13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.sans(13, color: AppColors.mutedLight),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.sans(12.5, color: AppColors.muted)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTheme.sans(13, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: 4.5,
              height: 1.3,
              color: const Color(0x330F5C4D),
            ),
          ),
        );
      },
    );
  }
}

class _PayIconTile extends StatelessWidget {
  final IconData icon;
  const _PayIconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _PayCard extends StatelessWidget {
  final String label;
  final String sub;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;
  const _PayCard({
    required this.label,
    required this.sub,
    required this.leading,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.mutedLight,
                  width: selected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.sans(14, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(sub, style: AppTheme.sans(11.5, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && !loading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : const Color(0xFFDDD9CC),
          borderRadius: BorderRadius.circular(15),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 28,
                    offset: const Offset(0, 13),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: AppTheme.sans(
                  15,
                  weight: FontWeight.w800,
                  color: enabled ? const Color(0xFFF6F2E9) : AppColors.muted,
                ),
              ),
      ),
    );
  }
}

// ── confirmation screen ───────────────────────────────────────────────────────

/// Full-screen deep-emerald success page with a ticket-style booking card.
class BookingConfirmationScreen extends StatelessWidget {
  final Offer offer;
  final Company company;
  final Booking? booking;
  final int travelers;
  final String roomLabel;
  final DateTime? departureDate;
  final String payMethod;
  final double total;
  const BookingConfirmationScreen({
    super.key,
    required this.offer,
    required this.company,
    required this.booking,
    required this.travelers,
    required this.roomLabel,
    required this.departureDate,
    required this.payMethod,
    required this.total,
  });

  String _payLabel(AppLocalizations t) {
    switch (payMethod) {
      case 'fib':
        return t.payFib;
      case 'card':
        return t.payCard;
      default:
        return t.payCash;
    }
  }

  void _goHome(BuildContext context) {
    context.read<AppProvider>().setTab(0);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _goBookings(BuildContext context) {
    context.read<AppProvider>().setTab(3);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final dateText = departureDate == null
        ? t.dateToBeScheduled
        : '${departureDate!.day}/${departureDate!.month}/${departureDate!.year}';

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          const Positioned.fill(child: IslamicPattern(opacity: 0.06, cell: 72)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const Spacer(),
                  // gold check with a soft glow ring
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF1C2317),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    t.bookingRegisteredTitle,
                    style: AppTheme.serif(26, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.bookingRegisteredBody(company.nameFor(lang)),
                    style: AppTheme.sans(
                      13,
                      color: Colors.white.withValues(alpha: 0.72),
                    ).copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  // ── ticket card ──
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      t.bookingAwaitingConfirmation,
                                      style: AppTheme.sans(
                                        10.5,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFF8A7040),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    t.bookingRefTitle,
                                    style: AppTheme.sans(
                                      11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              if (booking != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  booking!.ref,
                                  style: AppTheme.serif(
                                    22,
                                  ).copyWith(letterSpacing: 1),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                offer.titleFor(lang),
                                style: AppTheme.serif(17),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$dateText · ${t.bookingPilgrimsSummary(travelers, roomLabel)}',
                                style: AppTheme.sans(
                                  11.5,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // dashed divider with ticket notches
                        SizedBox(
                          height: 22,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18),
                                  child: Center(child: _DashedLine()),
                                ),
                              ),
                              PositionedDirectional(
                                start: -9,
                                top: 2,
                                child: _TicketNotch(),
                              ),
                              PositionedDirectional(
                                end: -9,
                                top: 2,
                                child: _TicketNotch(),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.offerDetailTotal,
                                    style: AppTheme.sans(
                                      10.5,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Text(
                                    fmtIqd(total),
                                    style: AppTheme.serif(
                                      18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.chipBg,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  _payLabel(t),
                                  style: AppTheme.sans(
                                    11.5,
                                    weight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _goHome(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              t.bookingBackHome,
                              style: AppTheme.sans(
                                13.5,
                                weight: FontWeight.w800,
                                color: const Color(0xFF1C2317),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _goBookings(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.28),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              t.bookingViewMyBookings,
                              style: AppTheme.sans(
                                13.5,
                                weight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketNotch extends StatelessWidget {
  const _TicketNotch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        shape: BoxShape.circle,
      ),
    );
  }
}
