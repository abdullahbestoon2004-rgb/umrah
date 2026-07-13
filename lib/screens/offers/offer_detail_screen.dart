import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/offer_model.dart';
import '../../models/company_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/offer_image.dart';
import '../../widgets/star_rating.dart';
import '../companies/company_detail_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/islamic_pattern.dart';
import 'booking_flow_screen.dart';

class OfferDetailScreen extends StatelessWidget {
  final Offer offer;
  final String? heroTag;
  const OfferDetailScreen({super.key, required this.offer, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final saved = provider.isSaved(offer.id);
    final company =
        provider.companyById(offer.companyId) ??
        Company(id: offer.companyId, name: '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const IslamicPattern(opacity: 0.04, isEightFold: true),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeroSection(
                  offer: offer,
                  company: company,
                  saved: saved,
                  provider: provider,
                  heroTag: heroTag,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KeyFacts(offer: offer),
                      const SizedBox(height: 16),
                      _OfferClassification(offer: offer),
                      const SizedBox(height: 16),
                      _RatingRow(offer: offer, company: company),
                      const SizedBox(height: 22),
                      Text(t.offerDetailOverview, style: AppTheme.serif(20)),
                      const SizedBox(height: 8),
                      Text(
                        offer
                                .overviewFor(
                                  Localizations.localeOf(context).languageCode,
                                )
                                .isNotEmpty
                            ? offer.overviewFor(
                                Localizations.localeOf(context).languageCode,
                              )
                            : t.offerDetailOverviewBody(
                                offer.days,
                                offer.transportLabelFor(t).toLowerCase(),
                                offer.city,
                                offer.acc,
                                offer.hotel,
                                offer.distance,
                                company.nameFor(
                                  Localizations.localeOf(context).languageCode,
                                ),
                              ),
                        style: AppTheme.sans(
                          13.5,
                          color: const Color(0xFF52605A),
                        ).copyWith(height: 1.65),
                      ),
                      const SizedBox(height: 24),
                      if (offer.pricing.isNotEmpty) ...[
                        _OccupancyPricingSection(offer: offer),
                        const SizedBox(height: 24),
                      ],
                      _AccommodationSection(offer: offer),
                      const SizedBox(height: 24),
                      _TransportSection(offer: offer),
                      const SizedBox(height: 24),
                      _ItinerarySection(offer: offer),
                      const SizedBox(height: 8),
                      _IncludesSection(offer: offer),
                      const SizedBox(height: 22),
                      _PolicyPaymentSection(offer: offer),
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
  final String? heroTag;
  const _HeroSection({
    required this.offer,
    required this.company,
    required this.saved,
    required this.provider,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          OfferImage(offer: offer, height: 280, heroTag: heroTag),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF071C17).withOpacity(0.85),
                ],
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
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
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
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        company.nameFor(
                          Localizations.localeOf(context).languageCode,
                        ),
                        style: AppTheme.sans(
                          12,
                          weight: FontWeight.w700,
                          color: const Color(0xFFE7CF95),
                        ),
                      ),
                    ),
                    for (final badge in company.badges.take(3)) ...[
                      const SizedBox(width: 5),
                      Tooltip(
                        message: badge.nameFor(
                          Localizations.localeOf(context).languageCode,
                        ),
                        child: Icon(
                          badge.key == 'top_rated'
                              ? Icons.star_rounded
                              : badge.key == 'premium_partner'
                              ? Icons.workspace_premium_rounded
                              : badge.key == 'fast_responder'
                              ? Icons.schedule_rounded
                              : Icons.verified_rounded,
                          color: const Color(0xFFE7CF95),
                          size: 15,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  offer.titleFor(Localizations.localeOf(context).languageCode),
                  style: AppTheme.serif(28, color: Colors.white),
                ),
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
          icon: offer.isByAir
              ? Icons.flight_rounded
              : Icons.directions_bus_rounded,
          value: offer.transportLabelFor(t),
          sub: offer.carrierName,
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
  const _FactCard({
    required this.icon,
    this.iconColor,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
            const SizedBox(height: 5),
            Text(value, style: AppTheme.sans(14, weight: FontWeight.w700)),
            Text(
              sub,
              style: AppTheme.sans(10.5, color: AppColors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferClassificationLegacy extends StatelessWidget {
  final Offer offer;
  const _OfferClassificationLegacy({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final remaining = offer.remainingSeats;
    final statusLabel = switch (offer.capacityState) {
      'sold_out' => t.offerSoldOut,
      'few_left' => t.offerFewSeatsLeft(remaining ?? 0),
      _ => t.offerAvailable,
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DetailPillLegacy(
          icon: Icons.workspace_premium_outlined,
          label: switch (offer.packageTier) {
            'economy' => t.offerTierEconomy,
            'vip' => t.offerTierVip,
            _ => t.offerTierStandard,
          },
        ),
        _DetailPillLegacy(
          icon: Icons.groups_2_outlined,
          label: switch (offer.groupType) {
            'family' => t.offerGroupFamily,
            'individual' => t.offerGroupIndividual,
            _ => t.offerGroupGroup,
          },
        ),
        _DetailPillLegacy(
          icon: Icons.event_available_outlined,
          label: statusLabel,
          danger: offer.capacityState == 'sold_out',
        ),
      ],
    );
  }
}

class _DetailPillLegacy extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  const _DetailPillLegacy({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: danger
          ? AppColors.errorRed.withOpacity(0.08)
          : AppColors.primary.withOpacity(0.07),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: danger ? AppColors.errorRed : AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.sans(
            11.5,
            weight: FontWeight.w700,
            color: danger ? AppColors.errorRed : AppColors.primary,
          ),
        ),
      ],
    ),
  );
}

class _OccupancyPricingSectionLegacy extends StatelessWidget {
  final Offer offer;
  const _OccupancyPricingSectionLegacy({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerOccupancyPricing, style: AppTheme.serif(20)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < offer.pricing.length; i++)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: i == offer.pricing.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(color: Color(0x140F5C4D)),
                          ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bed_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.bookingRoomOccupancy(offer.pricing[i].occupancy),
                          style: AppTheme.sans(13.5, weight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        fmtIqd(offer.pricing[i].priceIqd),
                        style: AppTheme.serif(16, color: AppColors.primary),
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

class _OfferClassification extends StatelessWidget {
  final Offer offer;
  const _OfferClassification({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final remaining = offer.remainingSeats;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DetailPill(
          icon: Icons.workspace_premium_outlined,
          label: switch (offer.packageTier) {
            'economy' => t.offerTierEconomy,
            'vip' => t.offerTierVip,
            _ => t.offerTierStandard,
          },
        ),
        _DetailPill(
          icon: Icons.groups_2_outlined,
          label: switch (offer.groupType) {
            'family' => t.offerGroupFamily,
            'individual' => t.offerGroupIndividual,
            _ => t.offerGroupGroup,
          },
        ),
        _DetailPill(
          icon: Icons.brightness_2_outlined,
          label: switch (offer.seasonTag) {
            'ramadan' => t.offerSeasonRamadan,
            'shawwal' => t.offerSeasonShawwal,
            'other' => t.offerSeasonOther,
            _ => t.offerSeasonRegular,
          },
        ),
        _DetailPill(
          icon: offer.capacityState == 'sold_out'
              ? Icons.event_busy_outlined
              : Icons.airline_seat_recline_normal_rounded,
          label: switch (offer.capacityState) {
            'sold_out' => t.offerCapacitySoldOut,
            'few_left' => t.offerCapacityFewLeft(remaining ?? 0),
            _ =>
              remaining == null
                  ? t.offerCapacityAvailable
                  : t.offerCapacityRemaining(remaining),
          },
          warning: offer.capacityState != 'available',
        ),
      ],
    );
  }
}

class _DetailPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool warning;
  const _DetailPill({
    required this.icon,
    required this.label,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: warning
          ? AppColors.gold.withOpacity(0.12)
          : AppColors.primary.withOpacity(0.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: warning
            ? AppColors.gold.withOpacity(0.45)
            : AppColors.primary.withOpacity(0.15),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: warning ? AppColors.gold : AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.sans(11.5, weight: FontWeight.w700)),
      ],
    ),
  );
}

class _OccupancyPricingSection extends StatelessWidget {
  final Offer offer;
  const _OccupancyPricingSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerFormOccupancyPricing, style: AppTheme.serif(20)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < offer.pricing.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    border: i == offer.pricing.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(color: Color(0x140F5C4D)),
                          ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bed_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        t.bookingRoomOccupancy(offer.pricing[i].occupancy),
                        style: AppTheme.sans(13.5, weight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        fmtIqd(offer.pricing[i].priceIqd),
                        style: AppTheme.serif(16, color: AppColors.primary),
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
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          StarRating(rating: offer.rating, reviews: offer.reviews, size: 16),
          Text(
            t.offerDetailPilgrimReviews,
            style: AppTheme.sans(13, color: AppColors.muted),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompanyDetailScreen(company: company),
              ),
            ),
            child: Text(
              t.offerDetailViewAgency,
              style: AppTheme.sans(
                12.5,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
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
    final makkah = offer.hotelMakkah;
    final madinah = offer.hotelMadinah;
    final hasTwoHotels = madinah.isNotEmpty;

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
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (offer.hotels.isNotEmpty) ...[
                for (var i = 0; i < offer.hotels.length; i++) ...[
                  _buildHotelRow(
                    context,
                    title: offer.hotels[i].city == 'makkah'
                        ? t.offerDetailHotelMakkah
                        : t.offerDetailHotelMadinah,
                    hotelName: offer.hotels[i].nameFor(
                      Localizations.localeOf(context).languageCode,
                    ),
                    description: t.offerHotelNights(offer.hotels[i].nights),
                    distance: '${offer.hotels[i].distanceFromHaramM}m',
                    starGlyph:
                        '★' * offer.hotels[i].starRating +
                        '☆' * (5 - offer.hotels[i].starRating),
                    icon: Icons.hotel_rounded,
                  ),
                  if (i < offer.hotels.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFEAF1EC)),
                    ),
                ],
              ] else if (hasTwoHotels) ...[
                _buildHotelRow(
                  context,
                  title: t.offerDetailHotelMakkah,
                  hotelName: makkah,
                  description: offer.hotelMakkahDescription,
                  distance: offer.distance,
                  starGlyph: offer.starGlyph,
                  icon: Icons.hotel_rounded,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFEAF1EC)),
                ),
                _buildHotelRow(
                  context,
                  title: t.offerDetailHotelMadinah,
                  hotelName: madinah,
                  description: offer.hotelMadinahDescription,
                  distance: '',
                  starGlyph: offer.starGlyph,
                  icon: Icons.hotel_rounded,
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.hotel,
                            style: AppTheme.sans(15, weight: FontWeight.w700),
                          ),
                          if (offer.hotelMakkahDescription.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              offer.hotelMakkahDescription,
                              style: AppTheme.sans(12, color: AppColors.muted),
                            ),
                          ],
                          const SizedBox(height: 3),
                          Text(
                            offer.starGlyph,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF1EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.offerDetailDistanceToHaram(offer.distance),
                        style: AppTheme.sans(
                          11,
                          weight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.offerDetailRoom,
                            style: AppTheme.sans(
                              10.5,
                              color: AppColors.muted,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              for (final occupancy
                                  in offer.availableRoomOccupancies)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF1EC),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    t.bookingRoomOccupancy(occupancy),
                                    style: AppTheme.sans(
                                      10.5,
                                      weight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.offerDetailMeals,
                            style: AppTheme.sans(
                              10.5,
                              color: AppColors.muted,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offer.mealsLabelFor(t),
                            style: AppTheme.sans(13, weight: FontWeight.w700),
                          ),
                        ],
                      ),
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

  Widget _buildHotelRow(
    BuildContext context, {
    required String title,
    required String hotelName,
    required String description,
    required String distance,
    required String starGlyph,
    required IconData icon,
  }) {
    final t = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.sans(
                  11,
                  color: AppColors.muted,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hotelName,
                style: AppTheme.sans(15, weight: FontWeight.w700),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.sans(12, color: AppColors.muted),
                ),
              ],
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    starGlyph,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  if (distance.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: AppColors.muted.withOpacity(0.5)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.offerDetailDistanceToHaram(distance),
                      style: AppTheme.sans(
                        11,
                        color: AppColors.primary,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
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
    final place = offer.transportPlace;

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
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      offer.isByAir
                          ? Icons.flight_rounded
                          : Icons.directions_bus_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.transportLongFor(t),
                          style: AppTheme.sans(14, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.offerDetailCarrierTransfersIncluded(
                            offer.carrierName,
                          ),
                          style: AppTheme.sans(
                            12,
                            color: const Color(0xFF7D8A82),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (offer.departureAirport != null ||
                  offer.flightType != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFEAF1EC)),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (offer.departureAirport != null)
                      _DetailPill(
                        icon: Icons.flight_takeoff_rounded,
                        label: offer.departureAirport!,
                      ),
                    if (offer.flightType != null)
                      _DetailPill(
                        icon: Icons.route_outlined,
                        label: offer.flightType == 'direct'
                            ? t.offerFlightDirect
                            : t.offerFlightConnecting,
                      ),
                    if (offer.busBetweenCities)
                      _DetailPill(
                        icon: Icons.directions_bus_outlined,
                        label: t.offerFormBusBetweenCities,
                      ),
                    if (offer.airportTransfers)
                      _DetailPill(
                        icon: Icons.airport_shuttle_outlined,
                        label: t.offerFormAirportTransfers,
                      ),
                  ],
                ),
              ],
              if (place.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFEAF1EC)),
                ),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F7F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        offer.isByAir
                            ? Icons.local_airport_rounded
                            : Icons.pin_drop_rounded,
                        color: AppColors.gold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.isByAir
                                ? t.airportDeparture
                                : t.busStationPickup,
                            style: AppTheme.sans(
                              11,
                              color: AppColors.muted,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place,
                            style: AppTheme.sans(14, weight: FontWeight.w700),
                          ),
                        ],
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
}

class _ItinerarySection extends StatelessWidget {
  final Offer offer;
  const _ItinerarySection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final days = offer.buildItinerary(t);
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
                          border: Border.all(
                            color: const Color(0xFFD6E3DA),
                            width: 3,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: AppColors.primary.withOpacity(0.18),
                          ),
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
                          style: AppTheme.sans(
                            11,
                            weight: FontWeight.w800,
                            color: AppColors.gold,
                          ).copyWith(letterSpacing: 0.6),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          it.title,
                          style: AppTheme.sans(14, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          it.summary,
                          style: AppTheme.sans(
                            12.5,
                            color: const Color(0xFF62706A),
                          ).copyWith(height: 1.55),
                        ),
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
    final lang = Localizations.localeOf(context).languageCode;
    final structured = offer.inclusions;
    final items = structured.isEmpty
        ? offer
              .buildIncludes(t)
              .map(
                (text) =>
                    OfferInclusion(type: text, included: true, details: text),
              )
              .toList()
        : structured;
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
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(
                            color: Color(0x140F5C4D),
                            width: 1,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    Icon(
                      e.value.included
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      color: e.value.included
                          ? AppColors.primary
                          : AppColors.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        e.value.detailsFor(lang).isNotEmpty
                            ? e.value.detailsFor(lang)
                            : e.value.type,
                        style: AppTheme.sans(
                          13.5,
                          color: const Color(0xFF3C4A43),
                        ),
                      ),
                    ),
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

class _PolicyPaymentSection extends StatelessWidget {
  final Offer offer;
  const _PolicyPaymentSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final policy = offer.cancellationPolicyFor(lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerTrustAndPolicy, style: AppTheme.serif(20)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (policy.isNotEmpty) ...[
                Text(
                  t.offerFormCancellationPolicy,
                  style: AppTheme.sans(12, weight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  policy,
                  style: AppTheme.sans(12.5, color: AppColors.inkLight),
                ),
                const SizedBox(height: 12),
              ],
              if (offer.depositIqd > 0) ...[
                _PolicyLine(
                  icon: Icons.savings_outlined,
                  label: t.offerDepositLabel(fmtIqd(offer.depositIqd)),
                ),
                if (offer.nonRefundableDeposit)
                  _PolicyLine(
                    icon: Icons.info_outline_rounded,
                    label: t.offerFormNonRefundableDeposit,
                    danger: true,
                  ),
              ],
              _PolicyLine(
                icon: Icons.payments_outlined,
                label: t.offerAcceptedPaymentsLabel(
                  offer.acceptedPaymentMethods
                      .map(
                        (method) => method == 'fib'
                            ? 'FIB'
                            : method == 'card'
                            ? t.payCard
                            : t.payCash,
                      )
                      .join(' · '),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PolicyLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  const _PolicyLine({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: danger ? AppColors.errorRed : AppColors.primary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: AppTheme.sans(
              12.5,
              color: danger ? AppColors.errorRed : AppColors.inkLight,
            ),
          ),
        ),
      ],
    ),
  );
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
          _PriceLine(
            label: t.offerDetailPackagePerPerson,
            value: offer.priceFmt,
          ),
          const SizedBox(height: 10),
          _PriceLine(
            label: t.offerDetailVisaProcessing,
            value: t.offerDetailIncluded,
          ),
          const SizedBox(height: 10),
          _PriceLine(
            label: t.offerDetailTaxesFees,
            value: t.offerDetailIncluded,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            children: [
              Text(
                t.offerDetailTotalFrom,
                style: AppTheme.sans(
                  14,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                offer.priceFmt,
                style: AppTheme.serif(26, color: const Color(0xFFF3E6C4)),
              ),
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
        Text(
          label,
          style: AppTheme.sans(13, color: Colors.white.withOpacity(0.82)),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTheme.sans(13, color: Colors.white.withOpacity(0.82)),
        ),
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
        border: const Border(
          top: BorderSide(color: Color(0x1E0F5C4D), width: 1.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.offerDetailFromPerPerson,
                style: AppTheme.sans(11, color: AppColors.muted),
              ),
              Text(
                offer.priceFmt,
                style: AppTheme.serif(25, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BookingFlowScreen(offer: offer, company: company),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  t.offerDetailBookThisTrip,
                  style: AppTheme.sans(
                    15,
                    weight: FontWeight.w800,
                    color: const Color(0xFFF6F2E9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
