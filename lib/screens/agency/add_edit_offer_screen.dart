import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';

// ── Holds controllers for one itinerary row ───────────────────────────────────
class _ItineraryEntry {
  final TextEditingController day;
  final TextEditingController title;
  final TextEditingController summary;

  _ItineraryEntry({String d = '', String t = '', String s = ''})
    : day = TextEditingController(text: d),
      title = TextEditingController(text: t),
      summary = TextEditingController(text: s);

  void dispose() {
    day.dispose();
    title.dispose();
    summary.dispose();
  }

  ItineraryDay toModel() =>
      ItineraryDay(day.text.trim(), title.text.trim(), summary.text.trim());
}

// ── Holds controllers for one "What's included" row ──────────────────────────
class _IncludeEntry {
  final TextEditingController ctrl;
  _IncludeEntry({String text = ''}) : ctrl = TextEditingController(text: text);
  void dispose() => ctrl.dispose();
}

class AddEditOfferScreen extends StatefulWidget {
  final String companyId;
  final Offer? existing;
  const AddEditOfferScreen({super.key, required this.companyId, this.existing});

  @override
  State<AddEditOfferScreen> createState() => _AddEditOfferScreenState();
}

class _AddEditOfferScreenState extends State<AddEditOfferScreen> {
  // ── basic fields ─────────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _titleArCtrl = TextEditingController();
  final _titleEnCtrl = TextEditingController();
  final _overviewCtrl = TextEditingController();
  final _overviewArCtrl = TextEditingController();
  final _overviewEnCtrl = TextEditingController();
  final _hotelMakkahCtrl = TextEditingController();
  final _hotelMadinahCtrl = TextEditingController();
  final _hotelMakkahDescCtrl = TextEditingController();
  final _hotelMadinahDescCtrl = TextEditingController();
  final _distCtrl = TextEditingController();
  final _madinahDistCtrl = TextEditingController();
  final _carrierCtrl = TextEditingController();
  final _transportPlaceCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _originalCtrl = TextEditingController();
  final _badgeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _policyCtrl = TextEditingController();
  final _depositTermsCtrl = TextEditingController();
  final Map<int, TextEditingController> _occupancyPrices = {
    2: TextEditingController(),
    3: TextEditingController(),
    4: TextEditingController(),
    5: TextEditingController(),
  };

  String _transport = 'plane';
  int _acc = 4;
  int _days = 10;
  String _meals = 'Breakfast';
  bool _saving = false;
  Uint8List? _imageBytes;
  bool _initialized = false;
  int _step = 0;
  DateTime? _departureDate;
  DateTime? _returnDate;
  final Set<int> _roomOccupancies = {2, 3, 4};
  final Set<String> _paymentMethods = {'cash'};
  String _packageTier = 'standard';
  String _groupType = 'group';
  String _seasonTag = 'regular';
  String? _departureAirport = 'EBL';
  String? _flightType = 'direct';
  bool _busBetweenCities = true;
  bool _airportTransfers = true;
  bool _nonRefundableDeposit = false;
  int _makkahNights = 5;
  int _madinahNights = 4;
  int _makkahStars = 4;
  int _madinahStars = 4;
  final Set<String> _invalidFields = {};

  static const _totalSteps = 7;

  // ── itinerary ─────────────────────────────────────────────────────────────
  final List<_ItineraryEntry> _itinerary = [];

  // ── what's included ───────────────────────────────────────────────────────
  final List<_IncludeEntry> _includes = [];

  static const _mealOptions = ['Breakfast', 'Half board', 'Full board'];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final o = widget.existing;
    if (o != null) {
      OfferHotel? makkahHotel;
      OfferHotel? madinahHotel;
      for (final hotel in o.hotels) {
        if (hotel.city == 'makkah') makkahHotel = hotel;
        if (hotel.city == 'madinah') madinahHotel = hotel;
      }
      _titleCtrl.text = o.title;
      _titleArCtrl.text = o.titleAr ?? '';
      _titleEnCtrl.text = o.titleEn ?? '';
      _overviewCtrl.text = o.overview;
      _overviewArCtrl.text = o.overviewAr ?? '';
      _overviewEnCtrl.text = o.overviewEn ?? '';
      _hotelMakkahCtrl.text = makkahHotel?.name ?? o.hotelMakkah;
      _hotelMadinahCtrl.text = madinahHotel?.name ?? o.hotelMadinah;
      _hotelMakkahDescCtrl.text =
          makkahHotel?.description ?? o.hotelMakkahDescription;
      _hotelMadinahDescCtrl.text =
          madinahHotel?.description ?? o.hotelMadinahDescription;
      _distCtrl.text = makkahHotel == null
          ? o.distance
          : makkahHotel.distanceFromHaramM.toString();
      _madinahDistCtrl.text = madinahHotel?.distanceFromHaramM.toString() ?? '';
      _makkahNights = makkahHotel?.nights ?? (o.nights / 2).ceil();
      _madinahNights = madinahHotel?.nights ?? (o.nights - _makkahNights);
      _makkahStars = makkahHotel?.starRating ?? o.acc;
      _madinahStars = madinahHotel?.starRating ?? o.acc;
      _roomOccupancies
        ..clear()
        ..addAll(
          o.roomOccupancies.isEmpty ? const [2, 3, 4] : o.roomOccupancies,
        );
      _carrierCtrl.text = o.carrierName;
      _transportPlaceCtrl.text = o.transportPlace;
      _priceCtrl.text = o.price.toStringAsFixed(0);
      _originalCtrl.text = o.original > 0 ? o.original.toStringAsFixed(0) : '';
      _badgeCtrl.text = o.badge;
      _capacityCtrl.text = o.capacity?.toString() ?? '';
      _depositCtrl.text = o.depositIqd > 0
          ? o.depositIqd.toStringAsFixed(0)
          : '';
      _policyCtrl.text = o.cancellationPolicy;
      _depositTermsCtrl.text = o.depositTerms;
      _packageTier = o.packageTier;
      _groupType = o.groupType;
      _seasonTag = o.seasonTag;
      _departureAirport = o.departureAirport ?? 'EBL';
      _flightType = o.flightType ?? 'direct';
      _busBetweenCities = o.busBetweenCities;
      _airportTransfers = o.airportTransfers;
      _nonRefundableDeposit = o.nonRefundableDeposit;
      _paymentMethods
        ..clear()
        ..addAll(
          o.acceptedPaymentMethods.where(
            (method) => method == 'cash' || method == 'fib',
          ),
        );
      if (_paymentMethods.isEmpty) _paymentMethods.add('cash');
      for (final occupancy in _occupancyPrices.keys) {
        _occupancyPrices[occupancy]!.text = o
            .priceForOccupancy(occupancy)
            .toStringAsFixed(0);
      }
      _departureDate = o.departureDate;
      _returnDate = o.returnDate;
      _transport = o.transport;
      _acc = o.acc;
      _days = o.days;
      _meals = o.meals;
      _imageBytes = context.read<AppProvider>().getOfferImage(o.id);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final o = widget.existing;
      final t = AppLocalizations.of(context);
      if (o != null) {
        _itinerary.clear();
        for (final it in o.buildItinerary(t)) {
          _itinerary.add(
            _ItineraryEntry(d: it.day, t: it.title, s: it.summary),
          );
        }
        _includes.clear();
        for (final inc in o.buildIncludes(t)) {
          _includes.add(_IncludeEntry(text: inc));
        }
      } else {
        _itinerary.clear();
        _includes.clear();
        _itinerary.add(_ItineraryEntry());
        _includes.add(_IncludeEntry());
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _titleArCtrl,
      _titleEnCtrl,
      _overviewCtrl,
      _overviewArCtrl,
      _overviewEnCtrl,
      _hotelMakkahCtrl,
      _hotelMadinahCtrl,
      _hotelMakkahDescCtrl,
      _hotelMadinahDescCtrl,
      _distCtrl,
      _madinahDistCtrl,
      _carrierCtrl,
      _transportPlaceCtrl,
      _priceCtrl,
      _originalCtrl,
      _badgeCtrl,
      _capacityCtrl,
      _depositCtrl,
      _policyCtrl,
      _depositTermsCtrl,
    ]) {
      c.dispose();
    }
    for (final controller in _occupancyPrices.values) {
      controller.dispose();
    }
    for (final e in _itinerary) {
      e.dispose();
    }
    for (final e in _includes) {
      e.dispose();
    }
    super.dispose();
  }

  void _addItineraryDay() {
    final t = AppLocalizations.of(context);
    setState(
      () => _itinerary.add(
        _ItineraryEntry(d: t.addEditOfferDayN(_itinerary.length + 1)),
      ),
    );
  }

  void _removeItineraryDay(int i) {
    final e = _itinerary.removeAt(i);
    e.dispose();
    setState(() {});
  }

  void _addInclude() => setState(() => _includes.add(_IncludeEntry()));
  void _removeInclude(int i) {
    final e = _includes.removeAt(i);
    e.dispose();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  Future<void> _pickWorkflowDate(bool departure) async {
    final initial = departure
        ? (_departureDate ?? DateTime.now().add(const Duration(days: 30)))
        : (_returnDate ??
              _departureDate?.add(Duration(days: _days)) ??
              DateTime.now().add(const Duration(days: 40)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (departure) {
        _departureDate = picked;
        _invalidFields.remove('departureDate');
        if (_returnDate != null && !_returnDate!.isAfter(picked)) {
          _returnDate = picked.add(Duration(days: _days));
        }
      } else {
        _returnDate = picked;
      }
      _invalidFields.remove('returnDate');
    });
  }

  Set<String> _fieldKeysForStep(int step) => switch (step) {
    0 => {'title', 'overview'},
    1 => {'capacity', 'departureDate', 'returnDate'},
    2 => {
      'makkahHotel',
      'madinahHotel',
      'makkahDescription',
      'madinahDescription',
      'hotelNights',
      'roomOccupancies',
    },
    3 => {
      'price',
      for (final occupancy in _roomOccupancies) 'price_$occupancy',
    },
    4 => {'itinerary'},
    5 => {'inclusions'},
    _ => {'deposit', 'cancellationPolicy', 'paymentMethods'},
  };

  void _clearFieldError(String key) {
    if (_invalidFields.contains(key)) {
      setState(() => _invalidFields.remove(key));
    }
  }

  String? _errorFor(String key, AppLocalizations t) {
    if (!_invalidFields.contains(key)) return null;
    if (key == 'paymentMethods' || key == 'roomOccupancies') {
      return t.offerFormSelectOne;
    }
    if (key == 'returnDate') return t.offerFormReturnDateAfterDeparture;
    if (key == 'capacity' ||
        key == 'deposit' ||
        key == 'price' ||
        key.startsWith('price_')) {
      return t.offerFormInvalidValue;
    }
    return t.offerFormRequired;
  }

  bool _validateStep(int step) {
    final errors = <String>{};
    final t = AppLocalizations.of(context);

    switch (step) {
      case 0:
        if (_titleCtrl.text.trim().isEmpty) errors.add('title');
        if (_overviewCtrl.text.trim().isEmpty) errors.add('overview');
        break;
      case 1:
        final capacity = int.tryParse(_capacityCtrl.text.trim());
        if (capacity == null || capacity <= 0) errors.add('capacity');
        if (_departureDate == null) errors.add('departureDate');
        if (_returnDate == null ||
            (_departureDate != null &&
                !_returnDate!.isAfter(_departureDate!))) {
          errors.add('returnDate');
        }
        break;
      case 2:
        if (_hotelMakkahCtrl.text.trim().isEmpty) errors.add('makkahHotel');
        if (_hotelMadinahCtrl.text.trim().isEmpty) errors.add('madinahHotel');
        if (_hotelMakkahDescCtrl.text.trim().isEmpty) {
          errors.add('makkahDescription');
        }
        if (_hotelMadinahDescCtrl.text.trim().isEmpty) {
          errors.add('madinahDescription');
        }
        if (_makkahNights + _madinahNights != _days - 1) {
          errors.add('hotelNights');
        }
        if (_roomOccupancies.isEmpty) errors.add('roomOccupancies');
        break;
      case 3:
        final price =
            double.tryParse(_priceCtrl.text.trim().replaceAll(',', '')) ?? 0;
        if (price <= 0) errors.add('price');
        for (final occupancy in _roomOccupancies) {
          final occupancyPrice =
              double.tryParse(
                _occupancyPrices[occupancy]!.text.trim().replaceAll(',', ''),
              ) ??
              0;
          if (occupancyPrice <= 0) errors.add('price_$occupancy');
        }
        break;
      case 4:
        if (_itinerary.isEmpty ||
            _itinerary.any((entry) => entry.title.text.trim().isEmpty)) {
          errors.add('itinerary');
        }
        break;
      case 5:
        if (!_includes.any((entry) => entry.ctrl.text.trim().isNotEmpty)) {
          errors.add('inclusions');
        }
        break;
      case 6:
        final depositText = _depositCtrl.text.trim().replaceAll(',', '');
        final deposit = depositText.isEmpty ? 0 : double.tryParse(depositText);
        final prices = [
          for (final occupancy in _roomOccupancies)
            double.tryParse(
                  _occupancyPrices[occupancy]!.text.trim().replaceAll(',', ''),
                ) ??
                0,
        ];
        final lowestRoomPrice = prices.isEmpty
            ? 0
            : prices.reduce((a, b) => a < b ? a : b);
        if (deposit == null || deposit < 0 || deposit > lowestRoomPrice) {
          errors.add('deposit');
        }
        if (_policyCtrl.text.trim().isEmpty) {
          errors.add('cancellationPolicy');
        }
        if (_paymentMethods.isEmpty) errors.add('paymentMethods');
        break;
    }

    setState(() {
      _invalidFields.removeAll(_fieldKeysForStep(step));
      _invalidFields.addAll(errors);
    });
    if (errors.isNotEmpty) {
      showAppSnack(context, t.offerFormFixHighlighted, isError: true);
      return false;
    }
    return true;
  }

  bool _validateAllSteps() {
    for (var step = 0; step < _totalSteps; step++) {
      if (!_validateStep(step)) {
        if (_step != step) setState(() => _step = step);
        return false;
      }
    }
    return true;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_validateAllSteps()) return;
    final t = AppLocalizations.of(context);
    final title = _titleCtrl.text.trim();
    final price =
        double.tryParse(_priceCtrl.text.trim().replaceAll(',', '')) ?? 0;

    final itinerary = _itinerary
        .where((e) => e.title.text.trim().isNotEmpty)
        .map((e) => e.toModel())
        .toList();

    final includes = _includes
        .where((e) => e.ctrl.text.trim().isNotEmpty)
        .map((e) => e.ctrl.text.trim())
        .toList();

    final occupancyPricing = <OfferPrice>[
      for (final occupancy in (_roomOccupancies.toList()..sort()))
        OfferPrice(
          occupancyType: switch (occupancy) {
            2 => 'double',
            3 => 'triple',
            4 => 'quad',
            _ => 'quintuple',
          },
          priceIqd:
              double.tryParse(
                _occupancyPrices[occupancy]!.text.replaceAll(',', ''),
              ) ??
              price,
        ),
    ];
    final minimumPrice = occupancyPricing
        .map((item) => item.priceIqd)
        .reduce((a, b) => a < b ? a : b);
    final deposit =
        double.tryParse(_depositCtrl.text.trim().replaceAll(',', '')) ?? 0;
    setState(() => _saving = true);

    final provider = context.read<AppProvider>();
    final company = provider.companyById(widget.companyId);

    final offer = Offer(
      id: _isEdit ? widget.existing!.id : '',
      companyId: widget.companyId,
      title: title,
      titleAr: _titleArCtrl.text.trim().isEmpty
          ? null
          : _titleArCtrl.text.trim(),
      titleEn: _titleEnCtrl.text.trim().isEmpty
          ? null
          : _titleEnCtrl.text.trim(),
      overview: _overviewCtrl.text.trim(),
      overviewAr: _overviewArCtrl.text.trim().isEmpty
          ? null
          : _overviewArCtrl.text.trim(),
      overviewEn: _overviewEnCtrl.text.trim().isEmpty
          ? null
          : _overviewEnCtrl.text.trim(),
      transport: _transport,
      acc: [_makkahStars, _madinahStars].reduce((a, b) => a < b ? a : b),
      days: _days,
      price: minimumPrice,
      original:
          double.tryParse(_originalCtrl.text.trim().replaceAll(',', '')) ?? 0,
      rating: company?.rating ?? 0,
      hotel:
          '${_hotelMakkahCtrl.text.trim()} | ${_hotelMadinahCtrl.text.trim()}',
      hotelMakkahDescription: _hotelMakkahDescCtrl.text.trim(),
      hotelMadinahDescription: _hotelMadinahDescCtrl.text.trim(),
      distance: _distCtrl.text.trim(),
      room: (_roomOccupancies.toList()..sort())
          .map((occupancy) => '$occupancy-person room')
          .join(', '),
      roomOccupancies: _roomOccupancies.toList()..sort(),
      meals: _meals,
      carrier:
          '${_carrierCtrl.text.trim()} | ${_transportPlaceCtrl.text.trim()}',
      badge: _badgeCtrl.text.trim(),
      gradColors: [
        company?.tint ?? AppColors.primary,
        Color.alphaBlend(
          Colors.black.withValues(alpha: 0.55),
          company?.tint ?? AppColors.primary,
        ),
      ],
      customItinerary: itinerary.isEmpty ? null : itinerary,
      customIncludes: includes.isEmpty ? null : includes,
      lifecycleStatus: widget.existing?.lifecycleStatus ?? 'draft',
      reviewReason: widget.existing?.reviewReason,
      capacity: int.tryParse(_capacityCtrl.text.trim()),
      seatsReserved: widget.existing?.seatsReserved ?? 0,
      departureDate: _departureDate,
      returnDate: _returnDate,
      packageTier: _packageTier,
      groupType: _groupType,
      seasonTag: _seasonTag,
      departureAirport: _transport == 'plane' ? _departureAirport : null,
      airlineName: _transport == 'plane' ? _carrierCtrl.text.trim() : null,
      flightType: _transport == 'plane' ? _flightType : null,
      busBetweenCities: _busBetweenCities,
      airportTransfers: _airportTransfers,
      pricing: occupancyPricing,
      hotels: [
        OfferHotel(
          city: 'makkah',
          name: _hotelMakkahCtrl.text.trim(),
          description: _hotelMakkahDescCtrl.text.trim(),
          starRating: _makkahStars,
          nights: _makkahNights,
          distanceFromHaramM:
              int.tryParse(
                RegExp(r'\d+').firstMatch(_distCtrl.text)?.group(0) ?? '',
              ) ??
              0,
        ),
        OfferHotel(
          city: 'madinah',
          name: _hotelMadinahCtrl.text.trim(),
          description: _hotelMadinahDescCtrl.text.trim(),
          starRating: _madinahStars,
          nights: _madinahNights,
          distanceFromHaramM:
              int.tryParse(
                RegExp(r'\d+').firstMatch(_madinahDistCtrl.text)?.group(0) ??
                    '',
              ) ??
              0,
        ),
      ],
      cancellationPolicy: _policyCtrl.text.trim(),
      depositIqd: deposit,
      nonRefundableDeposit: _nonRefundableDeposit,
      depositTerms: _depositTermsCtrl.text.trim(),
      acceptedPaymentMethods: _paymentMethods.toList()..sort(),
    );

    final (ok, imageFailed) = _isEdit
        ? await provider.updateOffer(offer, imageBytes: _imageBytes)
        : await provider.addOffer(offer, imageBytes: _imageBytes);

    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false);
      showAppSnack(context, t.addEditOfferSaveFailed, isError: true);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      appSnack(
        imageFailed
            ? t.addEditOfferSavedImageFailed
            : (_isEdit ? t.addEditOfferUpdated : t.workflowDraftSaved),
        isError: imageFailed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded, color: AppColors.ink),
        ),
        title: Text(
          _isEdit ? t.addEditOfferEditTitle : t.addEditOfferNewTitle,
          style: AppTheme.serif(22),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        t.addEditOfferSave,
                        style: AppTheme.sans(
                          13,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      // Numbered stepper: same fields as the old single-scroll form, one
      // section per step, with a persistent progress header and per-step
      // validation. Controllers live on the State so values survive moving
      // between steps; the AppBar save still publishes from any step.
      body: Column(
        children: [
          _StepHeader(
            current: _step,
            total: _totalSteps,
            title: _stepTitle(t),
            stepLabel: t.stepOf(_step + 1, _totalSteps),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(22, 8, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _stepContent(t),
              ),
            ),
          ),
          _stepNavBar(t),
        ],
      ),
    );
  }

  String _stepTitle(AppLocalizations t) {
    switch (_step) {
      case 0:
        return t.addEditOfferPackageDetails;
      case 1:
        return t.addEditOfferTransportStay;
      case 2:
        return t.addEditOfferHotel;
      case 3:
        return t.addEditOfferPricing;
      case 4:
        return t.addEditOfferItinerary;
      case 5:
        return t.addEditOfferWhatsIncluded;
      default:
        return t.offerFormCommercialPolicy;
    }
  }

  void _nextStep() {
    if (!_validateStep(_step)) return;
    setState(() => _step++);
  }

  Widget _stepNavBar(AppLocalizations t) {
    final isLast = _step == _totalSteps - 1;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(22, 10, 22, 12),
        child: Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _step--),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t.commonBack,
                      style: AppTheme.sans(
                        13,
                        weight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isLast ? (_saving ? null : _save) : _nextStep,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: _saving && isLast
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isLast ? t.addEditOfferSave : t.authNext,
                          style: AppTheme.sans(
                            13,
                            weight: FontWeight.w800,
                            color: const Color(0xFFF6F2E9),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Each step reuses the exact fields of the old single-scroll form; only
  // the container changed.
  List<Widget> _stepContent(AppLocalizations t) {
    switch (_step) {
      // ── Basics: cover image, title, badge ──────────────────────────────
      case 0:
        return [
          _CoverImagePicker(
            imageBytes: _imageBytes,
            gradColors: () {
              final tint =
                  context
                      .read<AppProvider>()
                      .companyById(widget.companyId)
                      ?.tint ??
                  AppColors.primary;
              return [
                tint,
                Color.alphaBlend(Colors.black.withValues(alpha: 0.55), tint),
              ];
            }(),
            onPick: _pickImage,
            onRemove: () => setState(() => _imageBytes = null),
          ),
          const SizedBox(height: 20),
          _Field(
            label: t.offerFormTitleKu,
            controller: _titleCtrl,
            hint: t.addEditOfferTitleHint,
            isRequired: true,
            errorText: _errorFor('title', t),
            onChanged: (_) => _clearFieldError('title'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: t.offerFormTitleAr,
                  controller: _titleArCtrl,
                  hint: t.offerFormTitleAr,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Field(
                  label: t.offerFormTitleEn,
                  controller: _titleEnCtrl,
                  hint: t.offerFormTitleEn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Field(
            label: t.offerFormOverviewKu,
            controller: _overviewCtrl,
            hint: t.offerFormOverviewHint,
            maxLines: 3,
            isRequired: true,
            errorText: _errorFor('overview', t),
            onChanged: (_) => _clearFieldError('overview'),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Field(
                  label: t.offerFormOverviewAr,
                  controller: _overviewArCtrl,
                  hint: t.offerFormOverviewHint,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Field(
                  label: t.offerFormOverviewEn,
                  controller: _overviewEnCtrl,
                  hint: t.offerFormOverviewHint,
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Field(
            label: t.addEditOfferBadgeOptional,
            controller: _badgeCtrl,
            hint: t.addEditOfferBadgeHint,
          ),
        ];

      // ── Transport & stay ────────────────────────────────────────────────
      case 1:
        return [
          _DropdownField(
            label: t.offerFormPackageTier,
            value: _packageTier,
            items: const ['economy', 'standard', 'vip'],
            labelBuilder: (value) => switch (value) {
              'economy' => t.offerTierEconomy,
              'vip' => t.offerTierVip,
              _ => t.offerTierStandard,
            },
            onChanged: (value) => setState(() => _packageTier = value!),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DropdownField(
                  label: t.offerFormGroupType,
                  value: _groupType,
                  items: const ['family', 'individual', 'group'],
                  labelBuilder: (value) => switch (value) {
                    'family' => t.offerGroupFamily,
                    'individual' => t.offerGroupIndividual,
                    _ => t.offerGroupGroup,
                  },
                  onChanged: (value) => setState(() => _groupType = value!),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _DropdownField(
                  label: t.offerFormSeason,
                  value: _seasonTag,
                  items: const ['regular', 'ramadan', 'shawwal', 'other'],
                  labelBuilder: (value) => switch (value) {
                    'ramadan' => t.offerSeasonRamadan,
                    'shawwal' => t.offerSeasonShawwal,
                    'other' => t.offerSeasonOther,
                    _ => t.offerSeasonRegular,
                  },
                  onChanged: (value) => setState(() => _seasonTag = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SegmentRow(
            label: t.addEditOfferTransport,
            options: [t.addEditOfferByAir, t.addEditOfferByCoach],
            icons: const [Icons.flight_rounded, Icons.directions_bus_rounded],
            values: const ['plane', 'bus'],
            selected: _transport,
            onSelect: (v) => setState(() => _transport = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stepper(
                  label: t.addEditOfferDays,
                  value: _days,
                  min: 3,
                  max: 30,
                  onChanged: (v) => setState(() => _days = v),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Stepper(
                  label: t.addEditOfferStars,
                  value: _acc,
                  min: 1,
                  max: 5,
                  onChanged: (v) => setState(() {
                    _acc = v;
                    _makkahStars = v;
                    _madinahStars = v;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DropdownField(
            label: t.addEditOfferMeals,
            value: _meals,
            items: _mealOptions,
            labelBuilder: (v) => Offer.mealsLabel(v, t),
            onChanged: (v) => setState(() => _meals = v!),
          ),
          const SizedBox(height: 16),
          _Field(
            label: t.workflowCapacity,
            controller: _capacityCtrl,
            hint: '40',
            numeric: true,
            isRequired: true,
            errorText: _errorFor('capacity', t),
            onChanged: (_) => _clearFieldError('capacity'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WorkflowDateField(
                  label: t.workflowDepartureDate,
                  value: _departureDate,
                  onTap: () => _pickWorkflowDate(true),
                  isRequired: true,
                  errorText: _errorFor('departureDate', t),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _WorkflowDateField(
                  label: t.workflowReturnDate,
                  value: _returnDate,
                  onTap: () => _pickWorkflowDate(false),
                  isRequired: true,
                  errorText: _errorFor('returnDate', t),
                ),
              ),
            ],
          ),
        ];

      // ── Hotels & transport details ──────────────────────────────────────
      case 2:
        return [
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: t.addEditOfferHotelMakkah,
                  controller: _hotelMakkahCtrl,
                  hint: t.addEditOfferHotelMakkahHint,
                  isRequired: true,
                  errorText: _errorFor('makkahHotel', t),
                  onChanged: (_) => _clearFieldError('makkahHotel'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Field(
                  label: t.addEditOfferHotelMadinah,
                  controller: _hotelMadinahCtrl,
                  hint: t.addEditOfferHotelMadinahHint,
                  isRequired: true,
                  errorText: _errorFor('madinahHotel', t),
                  onChanged: (_) => _clearFieldError('madinahHotel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Field(
            label: t.addEditOfferHotelMakkahDescription,
            controller: _hotelMakkahDescCtrl,
            hint: t.addEditOfferHotelDescriptionHint,
            maxLines: 3,
            isRequired: true,
            errorText: _errorFor('makkahDescription', t),
            onChanged: (_) => _clearFieldError('makkahDescription'),
          ),
          const SizedBox(height: 14),
          _Field(
            label: t.addEditOfferHotelMadinahDescription,
            controller: _hotelMadinahDescCtrl,
            hint: t.addEditOfferHotelDescriptionHint,
            maxLines: 3,
            isRequired: true,
            errorText: _errorFor('madinahDescription', t),
            onChanged: (_) => _clearFieldError('madinahDescription'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label:
                      '${t.offerDetailHotelMakkah} — ${t.addEditOfferDistanceToHaram}',
                  controller: _distCtrl,
                  hint: '250',
                  numeric: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Field(
                  label:
                      '${t.offerDetailHotelMadinah} — ${t.addEditOfferDistanceToHaram}',
                  controller: _madinahDistCtrl,
                  hint: '500',
                  numeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Stepper(
                  label: '${t.offerDetailHotelMakkah} — ${t.addEditOfferStars}',
                  value: _makkahStars,
                  min: 1,
                  max: 5,
                  onChanged: (value) => setState(() => _makkahStars = value),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Stepper(
                  label:
                      '${t.offerDetailHotelMadinah} — ${t.addEditOfferStars}',
                  value: _madinahStars,
                  min: 1,
                  max: 5,
                  onChanged: (value) => setState(() => _madinahStars = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Stepper(
                  label:
                      '${t.offerDetailHotelMakkah} — ${t.offerDetailNightsCount(_makkahNights)}',
                  value: _makkahNights,
                  min: 0,
                  max: 30,
                  onChanged: (value) => setState(() {
                    _makkahNights = value;
                    _invalidFields.remove('hotelNights');
                  }),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Stepper(
                  label:
                      '${t.offerDetailHotelMadinah} — ${t.offerDetailNightsCount(_madinahNights)}',
                  value: _madinahNights,
                  min: 0,
                  max: 30,
                  onChanged: (value) => setState(() {
                    _madinahNights = value;
                    _invalidFields.remove('hotelNights');
                  }),
                ),
              ),
            ],
          ),
          if (_errorFor('hotelNights', t) != null)
            _FieldError(text: t.offerFormHotelNightsTotal(_days - 1)),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                t.addEditOfferAvailableRooms,
                style: AppTheme.sans(
                  12,
                  weight: FontWeight.w700,
                  color: AppColors.inkLight,
                ),
              ),
              Text(
                '*',
                style: AppTheme.sans(
                  15,
                  weight: FontWeight.w800,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.addEditOfferAvailableRoomsHelper,
            style: AppTheme.sans(11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var occupancy = 2; occupancy <= 5; occupancy++)
                FilterChip(
                  label: Text(t.bookingRoomOccupancy(occupancy)),
                  selected: _roomOccupancies.contains(occupancy),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _roomOccupancies.add(occupancy)
                        : _roomOccupancies.remove(occupancy);
                    _invalidFields.remove('roomOccupancies');
                  }),
                  selectedColor: AppColors.primary.withValues(alpha: 0.13),
                  checkmarkColor: AppColors.primary,
                  side: BorderSide(
                    color: _roomOccupancies.contains(occupancy)
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  labelStyle: AppTheme.sans(
                    12,
                    weight: FontWeight.w700,
                    color: _roomOccupancies.contains(occupancy)
                        ? AppColors.primary
                        : AppColors.ink,
                  ),
                ),
            ],
          ),
          if (_errorFor('roomOccupancies', t) != null)
            _FieldError(text: _errorFor('roomOccupancies', t)!),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: t.addEditOfferCarrierCoach,
                  controller: _carrierCtrl,
                  hint: t.addEditOfferCarrierHint,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Field(
                  label: _transport == 'plane'
                      ? t.addEditOfferAirport
                      : t.addEditOfferBusStation,
                  controller: _transportPlaceCtrl,
                  hint: _transport == 'plane'
                      ? t.addEditOfferAirportHint
                      : t.addEditOfferBusStationHint,
                ),
              ),
            ],
          ),
          if (_transport == 'plane') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DropdownField(
                    label: t.offerFormDepartureAirport,
                    value: _departureAirport ?? 'EBL',
                    items: const ['EBL', 'BGW', 'ISU'],
                    labelBuilder: (value) => value,
                    onChanged: (value) =>
                        setState(() => _departureAirport = value),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DropdownField(
                    label: t.offerFormFlightType,
                    value: _flightType ?? 'direct',
                    items: const ['direct', 'connecting'],
                    labelBuilder: (value) => value == 'direct'
                        ? t.offerFlightDirect
                        : t.offerFlightConnecting,
                    onChanged: (value) => setState(() => _flightType = value),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              t.offerFormBusBetweenCities,
              style: AppTheme.sans(13.5),
            ),
            value: _busBetweenCities,
            onChanged: (value) => setState(() => _busBetweenCities = value),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              t.offerFormAirportTransfers,
              style: AppTheme.sans(13.5),
            ),
            value: _airportTransfers,
            onChanged: (value) => setState(() => _airportTransfers = value),
          ),
        ];

      // ── Pricing ─────────────────────────────────────────────────────────
      case 3:
        return [
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: t.addEditOfferPriceUsd,
                  controller: _priceCtrl,
                  hint: '0',
                  numeric: true,
                  isRequired: true,
                  errorText: _errorFor('price', t),
                  onChanged: (_) => _clearFieldError('price'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Field(
                  label: t.addEditOfferOriginalPrice,
                  controller: _originalCtrl,
                  hint: t.addEditOfferOriginalPriceHint,
                  numeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            t.offerFormOccupancyPricing,
            style: AppTheme.sans(13, weight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final occupancy in (_roomOccupancies.toList()..sort()))
            if (occupancy >= 2 && occupancy <= 5)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _Field(
                  label: t.offerFormOccupancyPrice(
                    t.bookingRoomOccupancy(occupancy),
                  ),
                  controller: _occupancyPrices[occupancy]!,
                  hint: _priceCtrl.text.isEmpty ? '0' : _priceCtrl.text,
                  numeric: true,
                  isRequired: true,
                  errorText: _errorFor('price_$occupancy', t),
                  onChanged: (_) => _clearFieldError('price_$occupancy'),
                ),
              ),
        ];

      // ── Itinerary ───────────────────────────────────────────────────────
      case 4:
        return [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.addEditOfferItineraryHelper,
                  style: AppTheme.sans(12.5, color: AppColors.muted),
                ),
              ),
              Text(
                '*',
                style: AppTheme.sans(
                  15,
                  weight: FontWeight.w800,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._itinerary.asMap().entries.map(
            (e) => _ItineraryRow(
              index: e.key,
              entry: e.value,
              isLast: e.key == _itinerary.length - 1,
              onRemove: () => _removeItineraryDay(e.key),
              onChanged: () => _clearFieldError('itinerary'),
              titleError: _errorFor('itinerary', t),
            ),
          ),
          GestureDetector(
            onTap: _addItineraryDay,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.addEditOfferAddItineraryDay,
                    style: AppTheme.sans(
                      13,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];

      // ── What's included ─────────────────────────────────────────────────
      case 5:
        return [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.addEditOfferWhatsIncludedHelper,
                  style: AppTheme.sans(12.5, color: AppColors.muted),
                ),
              ),
              Text(
                '*',
                style: AppTheme.sans(
                  15,
                  weight: FontWeight.w800,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._includes.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _errorFor('inclusions', t) != null
                              ? AppColors.errorRed
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: e.value.ctrl,
                        style: AppTheme.sans(13.5),
                        onChanged: (_) => _clearFieldError('inclusions'),
                        decoration: InputDecoration(
                          hintText: t.addEditOfferIncludeItemHint,
                          hintStyle: AppTheme.sans(
                            13.5,
                            color: AppColors.mutedLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removeInclude(e.key),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        color: AppColors.errorRed,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_errorFor('inclusions', t) != null)
            _FieldError(text: _errorFor('inclusions', t)!),
          GestureDetector(
            onTap: _addInclude,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.addEditOfferAddIncludedItem,
                    style: AppTheme.sans(
                      13,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      default:
        return [
          _Field(
            label: t.offerFormDepositAmount,
            controller: _depositCtrl,
            hint: '0',
            numeric: true,
            errorText: _errorFor('deposit', t),
            onChanged: (_) => _clearFieldError('deposit'),
          ),
          const SizedBox(height: 14),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              t.offerFormNonRefundableDeposit,
              style: AppTheme.sans(13.5),
            ),
            value: _nonRefundableDeposit,
            onChanged: (value) => setState(() => _nonRefundableDeposit = value),
          ),
          _Field(
            label: t.offerFormDepositTerms,
            controller: _depositTermsCtrl,
            hint: t.offerFormDepositTermsHint,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          _Field(
            label: t.offerFormCancellationPolicy,
            controller: _policyCtrl,
            hint: t.offerFormCancellationPolicyHint,
            maxLines: 4,
            isRequired: true,
            errorText: _errorFor('cancellationPolicy', t),
            onChanged: (_) => _clearFieldError('cancellationPolicy'),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                t.offerFormAcceptedPayments,
                style: AppTheme.sans(13, weight: FontWeight.w800),
              ),
              Text(
                '*',
                style: AppTheme.sans(
                  15,
                  weight: FontWeight.w800,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final method in const ['fib', 'cash'])
                FilterChip(
                  label: Text(switch (method) {
                    'fib' => 'FIB',
                    _ => t.payCash,
                  }),
                  selected: _paymentMethods.contains(method),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _paymentMethods.add(method)
                        : _paymentMethods.remove(method);
                    _invalidFields.remove('paymentMethods');
                  }),
                ),
            ],
          ),
          if (_errorFor('paymentMethods', t) != null)
            _FieldError(text: _errorFor('paymentMethods', t)!),
        ];
    }
  }
}

class _WorkflowDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool isRequired;
  final String? errorText;
  const _WorkflowDateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError ? AppColors.errorRed : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: AppTheme.sans(11, color: AppColors.muted),
                      ),
                    ),
                    if (isRequired)
                      Text(
                        '*',
                        style: AppTheme.sans(
                          15,
                          weight: FontWeight.w800,
                          color: AppColors.errorRed,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  value == null
                      ? '—'
                      : '${value!.day}/${value!.month}/${value!.year}',
                  style: AppTheme.sans(13, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        if (hasError) _FieldError(text: errorText!),
      ],
    );
  }
}

/// Persistent stepper progress header: numbered dots with connectors,
/// the current step's title and a "Step x of y" counter.
class _StepHeader extends StatelessWidget {
  final int current;
  final int total;
  final String title;
  final String stepLabel;
  const _StepHeader({
    required this.current,
    required this.total,
    required this.title,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(22, 8, 22, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: i <= current ? AppColors.primary : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i <= current
                          ? AppColors.primary
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: i < current
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : Text(
                          '${i + 1}',
                          style: AppTheme.sans(
                            11,
                            weight: FontWeight.w800,
                            color: i <= current
                                ? Colors.white
                                : AppColors.muted,
                          ),
                        ),
                ),
                if (i < total - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < current
                          ? AppColors.primary.withValues(alpha: 0.45)
                          : AppColors.border,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.serif(18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                stepLabel,
                style: AppTheme.sans(11.5, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Itinerary row widget ──────────────────────────────────────────────────────
class _ItineraryRow extends StatelessWidget {
  final int index;
  final _ItineraryEntry entry;
  final bool isLast;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final String? titleError;

  const _ItineraryRow({
    required this.index,
    required this.entry,
    required this.isLast,
    required this.onRemove,
    required this.onChanged,
    this.titleError,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      decoration: !isLast
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timeline dot
          Transform.translate(
            offset: const Offset(-7, 13),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD6E3DA), width: 3),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // fields
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // day label + delete
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _InlineField(
                          controller: entry.day,
                          hint: t.addEditOfferDayOneHint,
                          style: AppTheme.sans(
                            11,
                            weight: FontWeight.w800,
                            color: AppColors.gold,
                          ).copyWith(letterSpacing: 0.5),
                          onChanged: onChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // title
                  _InlineField(
                    controller: entry.title,
                    hint: t.addEditOfferDayTitleHint,
                    style: AppTheme.sans(14, weight: FontWeight.w700),
                    onChanged: onChanged,
                    hasError: titleError != null,
                  ),
                  if (titleError != null) _FieldError(text: titleError!),
                  const SizedBox(height: 6),
                  // description
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: entry.summary,
                      maxLines: 3,
                      style: AppTheme.sans(13, color: AppColors.inkLight),
                      onChanged: (_) => onChanged(),
                      decoration: InputDecoration(
                        hintText: t.addEditOfferDaySummaryHint,
                        hintStyle: AppTheme.sans(
                          13,
                          color: AppColors.mutedLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextStyle style;
  final VoidCallback? onChanged;
  final bool hasError;

  const _InlineField({
    required this.controller,
    required this.hint,
    required this.style,
    this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: style,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: AppColors.mutedLight),
        isDense: true,
        contentPadding: EdgeInsets.zero,
        enabledBorder: hasError
            ? const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.errorRed),
              )
            : InputBorder.none,
        focusedBorder: hasError
            ? const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.errorRed, width: 1.5),
              )
            : InputBorder.none,
      ),
    );
  }
}

// ── Cover image picker ────────────────────────────────────────────────────────

class _CoverImagePicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final List<Color> gradColors;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _CoverImagePicker({
    required this.imageBytes,
    required this.gradColors,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onPick,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // background: real image or gradient placeholder
              if (imageBytes != null)
                Image.memory(imageBytes!, fit: BoxFit.cover)
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradColors,
                    ),
                  ),
                ),

              // dark overlay
              Container(
                color: Colors.black.withValues(
                  alpha: imageBytes != null ? 0.28 : 0.18,
                ),
              ),

              // pick prompt
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        imageBytes != null
                            ? Icons.edit_rounded
                            : Icons.add_photo_alternate_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      imageBytes != null
                          ? t.addEditOfferChangeImage
                          : t.addEditOfferAddCoverImage,
                      style: AppTheme.sans(
                        13,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // remove button
              if (imageBytes != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onRemove,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared form widgets ────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool numeric;
  final int maxLines;
  final bool isRequired;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.numeric = false,
    this.maxLines = 1,
    this.isRequired = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.sans(
                  12,
                  weight: FontWeight.w700,
                  color: AppColors.inkLight,
                ),
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: AppTheme.sans(
                  15,
                  weight: FontWeight.w800,
                  color: AppColors.errorRed,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.errorRed : AppColors.border,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: numeric ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            style: AppTheme.sans(14),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
        if (hasError) _FieldError(text: errorText!),
      ],
    );
  }
}

class _FieldError extends StatelessWidget {
  final String text;
  const _FieldError({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 14,
          color: AppColors.errorRed,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: AppTheme.sans(
              11.5,
              weight: FontWeight.w700,
              color: AppColors.errorRed,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SegmentRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<IconData> icons;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelect;
  const _SegmentRow({
    required this.label,
    required this.options,
    required this.icons,
    required this.values,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.sans(
            12,
            weight: FontWeight.w700,
            color: AppColors.inkLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(options.length, (i) {
            final active = values[i] == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(values[i]),
                child: Container(
                  margin: EdgeInsets.only(
                    right: i < options.length - 1 ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[i],
                        size: 16,
                        color: active ? Colors.white : AppColors.ink,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        options[i],
                        style: AppTheme.sans(
                          13,
                          weight: FontWeight.w700,
                          color: active ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.sans(
            12,
            weight: FontWeight.w700,
            color: AppColors.inkLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded, size: 18),
                color: AppColors.primary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: value > min ? () => onChanged(value - 1) : null,
              ),
              Text('$value', style: AppTheme.serif(20)),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 18),
                color: AppColors.primary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? labelBuilder;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final list = List<String>.from(items);
    if (value.isNotEmpty && !list.contains(value)) {
      list.add(value);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.sans(
            12,
            weight: FontWeight.w700,
            color: AppColors.inkLight,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty
                  ? null
                  : (list.contains(value) ? value : null),
              isExpanded: true,
              style: AppTheme.sans(14),
              items: list
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(labelBuilder?.call(e) ?? e),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
