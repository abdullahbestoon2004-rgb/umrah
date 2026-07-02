import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/offer_model.dart';
import '../../models/company_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/offer_image.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/app_snackbar.dart';
import '../companies/company_detail_screen.dart';
import '../auth/auth_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;
  const OfferDetailScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final saved = provider.isSaved(offer.id);
    final company = provider.companyById(offer.companyId) ??
        Company(id: offer.companyId, name: '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroSection(offer: offer, company: company, saved: saved, provider: provider)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KeyFacts(offer: offer),
                      const SizedBox(height: 16),
                      _RatingRow(offer: offer, company: company),
                      const SizedBox(height: 22),
                      Text(t.offerDetailOverview, style: AppTheme.serif(20)),
                      const SizedBox(height: 8),
                      Text(
                        offer.overview.isNotEmpty
                            ? offer.overview
                            : t.offerDetailOverviewBody(
                                offer.days,
                                offer.transportLabel.toLowerCase(),
                                offer.city,
                                offer.acc,
                                offer.hotel,
                                offer.distance,
                                company.nameFor(Localizations.localeOf(context).languageCode),
                              ),
                        style: AppTheme.sans(13.5, color: const Color(0xFF52605A)).copyWith(height: 1.65),
                      ),
                      const SizedBox(height: 24),
                      _AccommodationSection(offer: offer),
                      const SizedBox(height: 24),
                      _TransportSection(offer: offer),
                      const SizedBox(height: 24),
                      _ItinerarySection(offer: offer),
                      const SizedBox(height: 8),
                      _IncludesSection(offer: offer),
                      const SizedBox(height: 22),
                      _PriceBreakdown(offer: offer),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _StickyBar(offer: offer, company: company),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Offer offer;
  final Company company;
  final bool saved;
  final AppProvider provider;
  const _HeroSection({required this.offer, required this.company, required this.saved, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          OfferImage(offer: offer, height: 280),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, const Color(0xFF071C17).withOpacity(0.85)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => provider.toggleSave(offer.id),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company.nameFor(Localizations.localeOf(context).languageCode),
                    style: AppTheme.sans(12, weight: FontWeight.w700, color: const Color(0xFFE7CF95))),
                const SizedBox(height: 2),
                Text(offer.titleFor(Localizations.localeOf(context).languageCode),
                    style: AppTheme.serif(28, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyFacts extends StatelessWidget {
  final Offer offer;
  const _KeyFacts({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        _FactCard(
          icon: Icons.calendar_today_rounded,
          value: t.offerDetailDaysCount(offer.days),
          sub: t.offerDetailNightsCount(offer.nights),
        ),
        const SizedBox(width: 9),
        _FactCard(
          icon: offer.isByAir ? Icons.flight_rounded : Icons.directions_bus_rounded,
          value: offer.transportLabel,
          sub: offer.carrier,
        ),
        const SizedBox(width: 9),
        _FactCard(
          icon: Icons.hotel_rounded,
          iconColor: AppColors.gold,
          value: t.offerDetailStarCount(offer.acc),
          sub: t.offerDetailHotelLower,
        ),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String value;
  final String sub;
  const _FactCard({required this.icon, this.iconColor, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            const SizedBox(height: 5),
            Text(value, style: AppTheme.sans(14, weight: FontWeight.w700)),
            Text(sub, style: AppTheme.sans(10.5, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final Offer offer;
  final Company company;
  const _RatingRow({required this.offer, required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          StarRating(rating: offer.rating, reviews: offer.reviews, size: 16),
          Text(t.offerDetailPilgrimReviews, style: AppTheme.sans(13, color: AppColors.muted)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: company))),
            child: Text(t.offerDetailViewAgency, style: AppTheme.sans(12.5, weight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _AccommodationSection extends StatelessWidget {
  final Offer offer;
  const _AccommodationSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerDetailAccommodation, style: AppTheme.serif(20)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.hotel, style: AppTheme.sans(15, weight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(offer.starGlyph, style: const TextStyle(color: AppColors.gold, fontSize: 13, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(t.offerDetailDistanceToHaram(offer.distance),
                        style: AppTheme.sans(11, weight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.offerDetailRoom, style: AppTheme.sans(10.5, color: AppColors.muted, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(offer.room, style: AppTheme.sans(13, weight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.offerDetailMeals, style: AppTheme.sans(10.5, color: AppColors.muted, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(offer.meals, style: AppTheme.sans(13, weight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransportSection extends StatelessWidget {
  final Offer offer;
  const _TransportSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerDetailTransportation, style: AppTheme.serif(20)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFEAF1EC), borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Icon(offer.isByAir ? Icons.flight_rounded : Icons.directions_bus_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.transportLong, style: AppTheme.sans(14, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      t.offerDetailCarrierTransfersIncluded(offer.carrier),
                      style: AppTheme.sans(12, color: const Color(0xFF7D8A82)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItinerarySection extends StatelessWidget {
  final Offer offer;
  const _ItinerarySection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final days = offer.buildItinerary();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerDetailItinerary, style: AppTheme.serif(20)),
        const SizedBox(height: 12),
        ...List.generate(days.length, (i) {
          final it = days[i];
          final isLast = i == days.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  child: Column(
                    children: [
                      Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD6E3DA), width: 3),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(width: 2, color: AppColors.primary.withOpacity(0.18)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.day.toUpperCase(),
                          style: AppTheme.sans(11, weight: FontWeight.w800, color: AppColors.gold)
                              .copyWith(letterSpacing: 0.6),
                        ),
                        const SizedBox(height: 2),
                        Text(it.title, style: AppTheme.sans(14, weight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(it.summary,
                            style: AppTheme.sans(12.5, color: const Color(0xFF62706A)).copyWith(height: 1.55)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _IncludesSection extends StatelessWidget {
  final Offer offer;
  const _IncludesSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = offer.buildIncludes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerDetailWhatsIncluded, style: AppTheme.serif(20)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  border: isLast ? null : const Border(bottom: BorderSide(color: Color(0x140F5C4D), width: 1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 11),
                    Expanded(child: Text(e.value, style: AppTheme.sans(13.5, color: const Color(0xFF3C4A43)))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final Offer offer;
  const _PriceBreakdown({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _PriceLine(label: t.offerDetailPackagePerPerson, value: offer.priceFmt),
          const SizedBox(height: 10),
          _PriceLine(label: t.offerDetailVisaProcessing, value: t.offerDetailIncluded),
          const SizedBox(height: 10),
          _PriceLine(label: t.offerDetailTaxesFees, value: t.offerDetailIncluded),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            children: [
              Text(t.offerDetailTotalFrom, style: AppTheme.sans(14, weight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text(offer.priceFmt, style: AppTheme.serif(26, color: const Color(0xFFF3E6C4))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  const _PriceLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTheme.sans(13, color: Colors.white.withOpacity(0.82))),
        const Spacer(),
        Text(value, style: AppTheme.sans(13, color: Colors.white.withOpacity(0.82))),
      ],
    );
  }
}

class _StickyBar extends StatelessWidget {
  final Offer offer;
  final Company company;
  const _StickyBar({required this.offer, required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.96),
        border: const Border(top: BorderSide(color: Color(0x1E0F5C4D), width: 1.5)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.offerDetailFromPerPerson, style: AppTheme.sans(11, color: AppColors.muted)),
              Text(offer.priceFmt, style: AppTheme.serif(25, color: AppColors.primary)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => _showBookingSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 14)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  t.offerDetailBookThisTrip,
                  style: AppTheme.sans(15, weight: FontWeight.w800, color: const Color(0xFFF6F2E9)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: _BookingSheet(offer: offer, company: company),
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final Offer offer;
  final Company company;
  const _BookingSheet({required this.offer, required this.company});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _travelers = 1;
  DateTime? _departureDate;
  String _payMethod = 'cash';
  bool _submitting = false;

  double get _total => widget.offer.price * _travelers;
  String get _totalFmt => fmtIqd(_total);

  Future<void> _confirm() async {
    if (_submitting) return;
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (!provider.isSignedIn) {
      final ok = await Navigator.push<bool>(
          context, MaterialPageRoute(builder: (_) => const AuthScreen()));
      if (ok != true || !mounted) return;
    }

    setState(() => _submitting = true);
    final err = await provider.confirmBooking(
      widget.offer,
      _travelers,
      payMethod: _payMethod,
      departureDate: _departureDate,
    );
    if (!mounted) return;
    if (err == null) {
      Navigator.popUntil(context, (route) => route.isFirst);
      messenger.showSnackBar(appSnack(t.offerDetailBookingConfirmed));
    } else {
      setState(() => _submitting = false);
      messenger.showSnackBar(appSnack(t.bookingFailed, isError: true));
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _departureDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 14, bottom: 6),
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.offerDetailConfirmBooking, style: AppTheme.serif(24)),
                const SizedBox(height: 16),
                // offer summary
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.offer.gradColors,
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.company.nameFor(Localizations.localeOf(context).languageCode),
                                style: AppTheme.sans(10.5, weight: FontWeight.w700, color: AppColors.primary)),
                            Text(widget.offer.titleFor(Localizations.localeOf(context).languageCode),
                                style: AppTheme.serif(18)),
                            const SizedBox(height: 4),
                            Text(
                              t.offerDetailBookingSummaryLine(widget.offer.days, widget.offer.transportLabel, widget.offer.acc),
                              style: AppTheme.sans(11.5, color: const Color(0xFF7D8A82)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // departure date
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.event_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.offerDetailDepartureDate, style: AppTheme.sans(14, weight: FontWeight.w700)),
                              Text(
                                _departureDate == null
                                    ? t.dateToBeScheduled
                                    : '${_departureDate!.day}/${_departureDate!.month}/${_departureDate!.year}',
                                style: AppTheme.sans(11.5, color: _departureDate == null ? AppColors.muted : AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // payment method
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.bookingPayMethod, style: AppTheme.sans(14, weight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _PayOption(label: t.payCash, icon: Icons.payments_outlined, value: 'cash',
                              current: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
                          const SizedBox(width: 8),
                          _PayOption(label: t.payFib, icon: Icons.account_balance_rounded, value: 'fib',
                              current: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
                          const SizedBox(width: 8),
                          _PayOption(label: t.payCard, icon: Icons.credit_card_rounded, value: 'card',
                              current: _payMethod, onTap: (v) => setState(() => _payMethod = v)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // traveler count
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.offerDetailTravelers, style: AppTheme.sans(14, weight: FontWeight.w700)),
                            Text(t.offerDetailPricePerPerson(widget.offer.priceFmt),
                                style: AppTheme.sans(11.5, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      _CounterBtn(
                        icon: Icons.remove_rounded,
                        onTap: () { if (_travelers > 1) setState(() => _travelers--); },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('$_travelers', style: AppTheme.serif(22)),
                      ),
                      _CounterBtn(
                        icon: Icons.add_rounded,
                        onTap: () { if (_travelers < 9) setState(() => _travelers++); },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(t.offerDetailTotal, style: AppTheme.sans(15, weight: FontWeight.w700)),
                    const Spacer(),
                    Text(_totalFmt, style: AppTheme.serif(28, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _confirm,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 30, offset: const Offset(0, 14)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _submitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            t.offerDetailConfirmAndPay(_totalFmt),
                            style: AppTheme.sans(15, weight: FontWeight.w800, color: const Color(0xFFF6F2E9)),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    t.offerDetailFreeCancellation,
                    style: AppTheme.sans(11, color: AppColors.mutedLight),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String current;
  final ValueChanged<String> onTap;
  const _PayOption({
    required this.label, required this.icon, required this.value,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFEEF4F0) : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: active ? AppColors.primary : AppColors.muted),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTheme.sans(11.5,
                      weight: FontWeight.w700,
                      color: active ? AppColors.primary : AppColors.inkLight)),
            ],
          ),
        ),
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
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }
}
