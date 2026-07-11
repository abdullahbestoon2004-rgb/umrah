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
      : day     = TextEditingController(text: d),
        title   = TextEditingController(text: t),
        summary = TextEditingController(text: s);

  void dispose() { day.dispose(); title.dispose(); summary.dispose(); }

  ItineraryDay toModel() => ItineraryDay(day.text.trim(), title.text.trim(), summary.text.trim());
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
  final _titleCtrl           = TextEditingController();
  final _hotelMakkahCtrl     = TextEditingController();
  final _hotelMadinahCtrl    = TextEditingController();
  final _distCtrl            = TextEditingController();
  final _roomCtrl            = TextEditingController();
  final _carrierCtrl         = TextEditingController();
  final _transportPlaceCtrl  = TextEditingController();
  final _priceCtrl           = TextEditingController();
  final _originalCtrl        = TextEditingController();
  final _badgeCtrl           = TextEditingController();

  String     _transport = 'plane';
  int        _acc       = 4;
  int        _days      = 10;
  String     _meals     = 'Breakfast';
  bool       _saving    = false;
  Uint8List? _imageBytes;
  bool       _initialized = false;
  int        _step      = 0;

  static const _totalSteps = 6;

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
      _titleCtrl.text          = o.title;
      _hotelMakkahCtrl.text    = o.hotelMakkah;
      _hotelMadinahCtrl.text   = o.hotelMadinah;
      _distCtrl.text           = o.distance;
      _roomCtrl.text           = o.room;
      _carrierCtrl.text        = o.carrierName;
      _transportPlaceCtrl.text = o.transportPlace;
      _priceCtrl.text          = o.price.toStringAsFixed(0);
      _originalCtrl.text       = o.original > 0 ? o.original.toStringAsFixed(0) : '';
      _badgeCtrl.text          = o.badge;
      _transport         = o.transport;
      _acc               = o.acc;
      _days              = o.days;
      _meals             = o.meals;
      _imageBytes        = context.read<AppProvider>().getOfferImage(o.id);
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
          _itinerary.add(_ItineraryEntry(d: it.day, t: it.title, s: it.summary));
        }
        _includes.clear();
        for (final inc in o.buildIncludes(t)) {
          _includes.add(_IncludeEntry(text: inc));
        }
      } else {
        _itinerary.clear();
        _includes.clear();
        _seedDefaultItinerary(t);
        _seedDefaultIncludes(t);
      }
      _initialized = true;
    }
  }

  void _seedDefaultItinerary(AppLocalizations t) {
    _itinerary.addAll([
      _ItineraryEntry(d: t.offerFallbackDayLabel(1), t: t.offerFallbackDay1Title, s: t.offerFallbackDay1Summary),
      _ItineraryEntry(d: t.offerFallbackDayLabel(2), t: t.offerFallbackDay2Title, s: t.offerFallbackDay2Summary),
      _ItineraryEntry(d: t.offerFallbackDayRangeLabel(3, 5), t: t.offerFallbackMakkahTitle, s: t.offerFallbackMakkahSummary),
      _ItineraryEntry(d: t.offerFallbackFinalDaysLabel, t: t.offerFallbackWorshipReturnTitle, s: t.offerFallbackWorshipReturnSummary),
    ]);
  }

  void _seedDefaultIncludes(AppLocalizations t) {
    _includes.addAll([
      _IncludeEntry(text: t.offerFallbackIncludeVisa),
      _IncludeEntry(text: t.offerFallbackIncludeFlights),
      _IncludeEntry(text: t.offerDetailAccommodation),
      _IncludeEntry(text: t.offerFallbackIncludeMeals(t.mealsBreakfast)),
      _IncludeEntry(text: t.offerFallbackIncludeZiyarah),
      _IncludeEntry(text: t.offerFallbackIncludeGuide),
    ]);
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _hotelMakkahCtrl, _hotelMadinahCtrl, _distCtrl, _roomCtrl,
                     _carrierCtrl, _transportPlaceCtrl, _priceCtrl, _originalCtrl, _badgeCtrl]) {
      c.dispose();
    }
    for (final e in _itinerary) e.dispose();
    for (final e in _includes) e.dispose();
    super.dispose();
  }

  void _addItineraryDay() {
    final t = AppLocalizations.of(context);
    setState(() => _itinerary.add(_ItineraryEntry(d: t.addEditOfferDayN(_itinerary.length + 1))));
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
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  Future<void> _save() async {
    if (_saving) return;
    final t = AppLocalizations.of(context);
    final title = _titleCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim().replaceAll(',', '')) ?? 0;
    if (title.isEmpty || price <= 0) {
      showAppSnack(context, t.addEditOfferFillTitlePrice, isError: true);
      return;
    }
    setState(() => _saving = true);

    final itinerary = _itinerary
        .where((e) => e.title.text.trim().isNotEmpty)
        .map((e) => e.toModel())
        .toList();

    final includes = _includes
        .where((e) => e.ctrl.text.trim().isNotEmpty)
        .map((e) => e.ctrl.text.trim())
        .toList();

    final provider = context.read<AppProvider>();
    final company = provider.companyById(widget.companyId);

    final offer = Offer(
      id: _isEdit ? widget.existing!.id : '',
      companyId: widget.companyId,
      title:      title,
      transport:  _transport,
      acc:        _acc,
      days:       _days,
      price:      price,
      original:   double.tryParse(_originalCtrl.text.trim().replaceAll(',', '')) ?? 0,
      rating:     company?.rating ?? 0,
      hotel:      '${_hotelMakkahCtrl.text.trim()} | ${_hotelMadinahCtrl.text.trim()}',
      distance:   _distCtrl.text.trim(),
      room:       _roomCtrl.text.trim(),
      meals:      _meals,
      carrier:    '${_carrierCtrl.text.trim()} | ${_transportPlaceCtrl.text.trim()}',
      badge:      _badgeCtrl.text.trim(),
      gradColors: [
        company?.tint ?? AppColors.primary,
        Color.alphaBlend(Colors.black.withOpacity(0.55), company?.tint ?? AppColors.primary),
      ],
      customItinerary: itinerary.isEmpty ? null : itinerary,
      customIncludes:  includes.isEmpty  ? null : includes,
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
    messenger.showSnackBar(appSnack(
      imageFailed
          ? t.addEditOfferSavedImageFailed
          : (_isEdit ? t.addEditOfferUpdated : t.addEditOfferPublished),
      isError: imageFailed,
    ));
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
        title: Text(_isEdit ? t.addEditOfferEditTitle : t.addEditOfferNewTitle, style: AppTheme.serif(22)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(t.addEditOfferSave, style: AppTheme.sans(13, weight: FontWeight.w800, color: Colors.white)),
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
      case 0: return t.addEditOfferPackageDetails;
      case 1: return t.addEditOfferTransportStay;
      case 2: return t.addEditOfferHotel;
      case 3: return t.addEditOfferPricing;
      case 4: return t.addEditOfferItinerary;
      default: return t.addEditOfferWhatsIncluded;
    }
  }

  /// Mirrors the validation _save applies, but at the step that owns the
  /// field, so mistakes surface before the reviewer reaches the end.
  void _nextStep() {
    final t = AppLocalizations.of(context);
    if (_step == 0 && _titleCtrl.text.trim().isEmpty) {
      showAppSnack(context, t.addEditOfferFillTitlePrice, isError: true);
      return;
    }
    if (_step == 3) {
      final price = double.tryParse(_priceCtrl.text.trim().replaceAll(',', '')) ?? 0;
      if (price <= 0) {
        showAppSnack(context, t.addEditOfferFillTitlePrice, isError: true);
        return;
      }
    }
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
                    child: Text(t.commonBack,
                        style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.ink)),
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
                          width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isLast ? t.addEditOfferSave : t.authNext,
                          style: AppTheme.sans(13, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
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
              final tint = context.read<AppProvider>().companyById(widget.companyId)?.tint ?? AppColors.primary;
              return [tint, Color.alphaBlend(Colors.black.withOpacity(0.55), tint)];
            }(),
            onPick: _pickImage,
            onRemove: () => setState(() => _imageBytes = null),
          ),
          const SizedBox(height: 20),
          _Field(label: t.addEditOfferTitleField, controller: _titleCtrl, hint: t.addEditOfferTitleHint),
          const SizedBox(height: 14),
          _Field(label: t.addEditOfferBadgeOptional, controller: _badgeCtrl, hint: t.addEditOfferBadgeHint),
        ];

      // ── Transport & stay ────────────────────────────────────────────────
      case 1:
        return [
          _SegmentRow(
            label: t.addEditOfferTransport,
            options: [t.addEditOfferByAir, t.addEditOfferByCoach],
            icons: const [Icons.flight_rounded, Icons.directions_bus_rounded],
            values: const ['plane', 'bus'],
            selected: _transport,
            onSelect: (v) => setState(() => _transport = v),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _Stepper(label: t.addEditOfferDays, value: _days, min: 3, max: 30, onChanged: (v) => setState(() => _days = v))),
            const SizedBox(width: 14),
            Expanded(child: _Stepper(label: t.addEditOfferStars, value: _acc, min: 1, max: 5, onChanged: (v) => setState(() => _acc = v))),
          ]),
          const SizedBox(height: 16),
          _DropdownField(
            label: t.addEditOfferMeals,
            value: _meals,
            items: _mealOptions,
            labelBuilder: (v) => Offer.mealsLabel(v, t),
            onChanged: (v) => setState(() => _meals = v!),
          ),
        ];

      // ── Hotels & transport details ──────────────────────────────────────
      case 2:
        return [
          Row(children: [
            Expanded(child: _Field(label: t.addEditOfferHotelMakkah, controller: _hotelMakkahCtrl, hint: t.addEditOfferHotelMakkahHint)),
            const SizedBox(width: 14),
            Expanded(child: _Field(label: t.addEditOfferHotelMadinah, controller: _hotelMadinahCtrl, hint: t.addEditOfferHotelMadinahHint)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _Field(label: t.addEditOfferDistanceToHaram, controller: _distCtrl, hint: t.addEditOfferDistanceHint)),
            const SizedBox(width: 14),
            Expanded(child: _Field(label: t.addEditOfferRoomType, controller: _roomCtrl, hint: t.addEditOfferRoomTypeHint)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _Field(label: t.addEditOfferCarrierCoach, controller: _carrierCtrl, hint: t.addEditOfferCarrierHint)),
            const SizedBox(width: 14),
            Expanded(
              child: _Field(
                label: _transport == 'plane' ? t.addEditOfferAirport : t.addEditOfferBusStation,
                controller: _transportPlaceCtrl,
                hint: _transport == 'plane' ? t.addEditOfferAirportHint : t.addEditOfferBusStationHint,
              ),
            ),
          ]),
        ];

      // ── Pricing ─────────────────────────────────────────────────────────
      case 3:
        return [
          Row(children: [
            Expanded(child: _Field(label: t.addEditOfferPriceUsd, controller: _priceCtrl, hint: '0', numeric: true)),
            const SizedBox(width: 14),
            Expanded(child: _Field(label: t.addEditOfferOriginalPrice, controller: _originalCtrl, hint: t.addEditOfferOriginalPriceHint, numeric: true)),
          ]),
        ];

      // ── Itinerary ───────────────────────────────────────────────────────
      case 4:
        return [
          Text(t.addEditOfferItineraryHelper,
              style: AppTheme.sans(12.5, color: AppColors.muted)),
          const SizedBox(height: 16),
          ..._itinerary.asMap().entries.map((e) => _ItineraryRow(
            index: e.key,
            entry: e.value,
            isLast: e.key == _itinerary.length - 1,
            onRemove: () => _removeItineraryDay(e.key),
            onChanged: () => setState(() {}),
          )),
          GestureDetector(
            onTap: _addItineraryDay,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(t.addEditOfferAddItineraryDay, style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ];

      // ── What's included ─────────────────────────────────────────────────
      default:
        return [
          Text(t.addEditOfferWhatsIncludedHelper,
              style: AppTheme.sans(12.5, color: AppColors.muted)),
          const SizedBox(height: 16),
          ..._includes.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: e.value.ctrl,
                      style: AppTheme.sans(13.5),
                      decoration: InputDecoration(
                        hintText: t.addEditOfferIncludeItemHint,
                        hintStyle: AppTheme.sans(13.5, color: AppColors.mutedLight),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _removeInclude(e.key),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(Icons.remove_rounded, color: AppColors.errorRed, size: 18),
                  ),
                ),
              ],
            ),
          )),
          GestureDetector(
            onTap: _addInclude,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(t.addEditOfferAddIncludedItem, style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ];
    }
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
                      color: i <= current ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: i < current
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text('${i + 1}',
                          style: AppTheme.sans(11,
                              weight: FontWeight.w800,
                              color: i <= current ? Colors.white : AppColors.muted)),
                ),
                if (i < total - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < current
                          ? AppColors.primary.withOpacity(0.45)
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
                child: Text(title,
                    style: AppTheme.serif(18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Text(stepLabel,
                  style: AppTheme.sans(11.5, color: AppColors.muted)),
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

  const _ItineraryRow({
    required this.index,
    required this.entry,
    required this.isLast,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      decoration: !isLast ? BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 2),
        ),
      ) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timeline dot
          Transform.translate(
            offset: const Offset(-7, 13),
            child: Container(
              width: 14, height: 14,
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
                          style: AppTheme.sans(11, weight: FontWeight.w800, color: AppColors.gold)
                              .copyWith(letterSpacing: 0.5),
                          onChanged: onChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close_rounded, size: 14, color: AppColors.errorRed),
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
                  ),
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
                        hintStyle: AppTheme.sans(13, color: AppColors.mutedLight),
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

  const _InlineField({required this.controller, required this.hint, required this.style, this.onChanged});

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
        border: InputBorder.none,
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
              Container(color: Colors.black.withOpacity(imageBytes != null ? 0.28 : 0.18)),

              // pick prompt
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
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
                      imageBytes != null ? t.addEditOfferChangeImage : t.addEditOfferAddCoverImage,
                      style: AppTheme.sans(13, weight: FontWeight.w700, color: Colors.white),
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
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Colors.black87),
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
  const _Field({required this.label, required this.controller, required this.hint, this.numeric = false});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.inkLight)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: TextField(
          controller: controller,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          style: AppTheme.sans(14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ),
    ]);
  }
}

class _SegmentRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<IconData> icons;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelect;
  const _SegmentRow({required this.label, required this.options, required this.icons, required this.values, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.inkLight)),
      const SizedBox(height: 8),
      Row(children: List.generate(options.length, (i) {
        final active = values[i] == selected;
        return Expanded(child: GestureDetector(
          onTap: () => onSelect(values[i]),
          child: Container(
            margin: EdgeInsets.only(right: i < options.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icons[i], size: 16, color: active ? Colors.white : AppColors.ink),
              const SizedBox(width: 7),
              Text(options[i], style: AppTheme.sans(13, weight: FontWeight.w700, color: active ? Colors.white : AppColors.ink)),
            ]),
          ),
        ));
      })),
    ]);
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.label, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.inkLight)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.remove_rounded, size: 18), color: AppColors.primary,
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              onPressed: value > min ? () => onChanged(value - 1) : null),
          Text('$value', style: AppTheme.serif(20)),
          IconButton(icon: const Icon(Icons.add_rounded, size: 18), color: AppColors.primary,
              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              onPressed: value < max ? () => onChanged(value + 1) : null),
        ]),
      ),
    ]);
  }
}

class _DropdownField extends StatelessWidget {
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String)? labelBuilder;
  const _DropdownField({
    required this.label, required this.value, required this.items, required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final list = List<String>.from(items);
    if (value.isNotEmpty && !list.contains(value)) {
      list.add(value);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.sans(12, weight: FontWeight.w700, color: AppColors.inkLight)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1.5)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value.isEmpty ? null : (list.contains(value) ? value : null),
            isExpanded: true,
            style: AppTheme.sans(14),
            items: list.map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder?.call(e) ?? e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }
}
