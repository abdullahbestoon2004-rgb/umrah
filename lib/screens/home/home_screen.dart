import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/offer_model.dart';
import '../../models/company_model.dart';
import '../../models/home_ad_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/company_avatar.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/offer_image.dart';
import '../companies/company_detail_screen.dart';
import '../offers/offer_detail_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/interactive_scale.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/tawaf_loading_spinner.dart';
import '../../widgets/active_booking_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = AppLocalizations.of(context);

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: TawafLoadingSpinner(size: 112)),
      );
    }
    if (provider.loadFailed) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppColors.mutedLight,
              ),
              const SizedBox(height: 14),
              Text(t.loadErrorTitle, style: AppTheme.serif(22)),
              const SizedBox(height: 6),
              Text(
                t.loadErrorBody,
                style: AppTheme.sans(13, color: AppColors.muted),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => provider.loadData(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t.retry,
                    style: AppTheme.sans(
                      13,
                      weight: FontWeight.w700,
                      color: const Color(0xFFF6F2E9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Featured/promoted records lead their sections, but normal eligible
    // records still fill the remaining positions. This keeps the home page
    // useful when the administrator has selected only one promotion.
    final ranked = provider.homeOffers;
    final ads = provider.homeAds;
    final hero = ranked.isEmpty ? null : ranked.first;
    // Without ads the hero card already fills the top slot — don't repeat it.
    final visibleRanked = ads.isEmpty && hero != null ? ranked.skip(1) : ranked;
    final homeOffers = visibleRanked.take(6).toList();
    final homeCompanies = provider.homeCompanies;
    final activeBooking = provider.activeBooking;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const IslamicPattern(opacity: 0.04, isEightFold: true),
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: provider.loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  const SliverToBoxAdapter(child: _PrayerTimesWidget()),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (provider.isSignedIn &&
                      activeBooking == null &&
                      provider.bookingsLoading)
                    const SliverToBoxAdapter(child: ActiveBookingSkeleton())
                  else if (provider.isSignedIn &&
                      activeBooking == null &&
                      provider.bookingsLoadFailed)
                    const SliverToBoxAdapter(child: ActiveBookingLoadError())
                  else if (activeBooking != null)
                    SliverToBoxAdapter(
                      child: ActiveBookingCard(
                        booking: activeBooking,
                        offer: provider.offerById(activeBooking.offerId),
                        company: provider.companyById(activeBooking.companyId),
                      ),
                    ),
                  // Paid agency ads rotate in a carousel; without any, the
                  // strongest eligible offer takes the spot.
                  SliverToBoxAdapter(
                    child: ads.isNotEmpty
                        ? _AdsCarousel(ads: ads)
                        : hero != null
                        ? _HeroCard(offer: hero)
                        : const _EmptyOffersHero(),
                  ),
                  SliverToBoxAdapter(child: _QuickCategories()),
                  if (homeCompanies.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _AgenciesSection(
                        companies: homeCompanies,
                        offers: ranked,
                      ),
                    ),
                  if (homeOffers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _CuratedSection(offers: homeOffers),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Paid ads carousel ─────────────────────────────────────────────────────────

class _AdsCarousel extends StatefulWidget {
  final List<HomeAd> ads;
  const _AdsCarousel({required this.ads});

  @override
  State<_AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<_AdsCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.ads.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.ads.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.ads.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => _AdCard(ad: widget.ads[i]),
            ),
          ),
          if (widget.ads.length > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.ads.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final HomeAd ad;
  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;
    final offer = provider.offerById(ad.packageId);
    final company = provider.companyById(
      ad.companyId ?? offer?.companyId ?? '',
    );

    final tag = offer != null ? 'offer-ad-${offer.id}' : null;
    // A linked trip wins the tap-through; otherwise a company ad opens the
    // company's profile so a paid placement always leads somewhere.
    final VoidCallback? onTap = offer != null
        ? () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OfferDetailScreen(offer: offer, heroTag: tag),
            ),
          )
        : company != null
        ? () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyDetailScreen(company: company),
            ),
          )
        : null;
    final adImage = Image.network(
      ad.imageUrl ?? '',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _CarouselImagePlaceholder();
      },
      errorBuilder: (_, _, _) => const GradientCard(
        colors: [AppColors.primary, AppColors.primaryDark],
        height: 240,
      ),
    );

    return InteractiveScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if ((ad.imageUrl ?? '').isNotEmpty)
              tag != null ? Hero(tag: tag, child: adImage) : adImage
            else if (offer != null)
              OfferImage(offer: offer, height: 240, heroTag: tag)
            else
              const GradientCard(
                colors: [AppColors.primary, AppColors.primaryDark],
                height: 240,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF071C17).withValues(alpha: 0.92),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t.homeSponsored,
                  style: AppTheme.sans(
                    10.5,
                    weight: FontWeight.w800,
                    color: const Color(0xFF1C2317),
                  ).copyWith(letterSpacing: 1),
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
                  if (company != null)
                    Text(
                      company.nameFor(lang),
                      style: AppTheme.sans(
                        11,
                        weight: FontWeight.w700,
                        color: const Color(0xFFE7CF95),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    ad.titleFor(lang),
                    style: AppTheme.serif(25, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (offer != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.homeDaysStarHotel(offer.days, offer.acc),
                            style: AppTheme.sans(
                              12.5,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ),
                        Text(
                          offer.priceFmt,
                          style: AppTheme.serif(
                            18,
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
        ),
      ),
    );
  }
}

/// Keeps the paid-ad slot intentional while a remote banner is downloading.
class _CarouselImagePlaceholder extends StatelessWidget {
  const _CarouselImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.surfaceAlt),
        const IslamicPattern(opacity: 0.10, cell: 40),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TawafLoadingSpinner(
                size: 52,
                semanticLabel: 'Loading carousel image',
              ),
              const SizedBox(height: 14),
              Container(
                width: 92,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 7),
              Container(
                width: 58,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Offer offer;
  const _HeroCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tag = 'offer-hero-${offer.id}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: InteractiveScale(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfferDetailScreen(offer: offer, heroTag: tag),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                OfferImage(offer: offer, height: 240, heroTag: tag),
                // dim overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF071C17).withValues(alpha: 0.92),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                // featured badge
                Positioned(
                  left: 20,
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t.homeFeatured,
                      style: AppTheme.sans(
                        10.5,
                        weight: FontWeight.w800,
                        color: const Color(0xFF1C2317),
                      ).copyWith(letterSpacing: 1),
                    ),
                  ),
                ),
                // info
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context
                                .read<AppProvider>()
                                .companyById(offer.companyId)
                                ?.nameFor(
                                  Localizations.localeOf(context).languageCode,
                                ) ??
                            '',
                        style: AppTheme.sans(
                          11,
                          weight: FontWeight.w700,
                          color: const Color(0xFFE7CF95),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offer.titleFor(
                          Localizations.localeOf(context).languageCode,
                        ),
                        style: AppTheme.serif(25, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.homeDaysStarHotel(offer.days, offer.acc),
                              style: AppTheme.sans(
                                12.5,
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ),
                          Text(
                            offer.priceFmt,
                            style: AppTheme.serif(
                              22,
                              color: const Color(0xFFF3E6C4),
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
        ),
      ),
    );
  }
}

class _EmptyOffersHero extends StatelessWidget {
  const _EmptyOffersHero();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 240,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IslamicPattern(opacity: 0.08, cell: 46),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.gold,
                      size: 30,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.homeNoTripsTitle,
                      style: AppTheme.serif(21, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.homeNoTripsBody,
                      style: AppTheme.sans(
                        12,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgenciesSection extends StatelessWidget {
  final List<Company> companies;
  final List<Offer> offers;
  const _AgenciesSection({required this.companies, required this.offers});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
          child: Row(
            children: [
              Text(t.homeTopAgencies, style: AppTheme.serif(21)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<AppProvider>().setTab(1),
                child: Text(
                  t.homeViewAll,
                  style: AppTheme.sans(
                    13,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 236,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: companies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final company = companies[i];
              return _AgencyCard(
                company: company,
                offers: offers
                    .where((offer) => offer.companyId == company.id)
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final Company company;
  final List<Offer> offers;
  const _AgencyCard({required this.company, required this.offers});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final offerCount = offers.length;
    final fromPrice = offers.isEmpty
        ? 0.0
        : offers.map((o) => o.price).reduce((a, b) => a < b ? a : b);
    return InteractiveScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyDetailScreen(company: company),
        ),
      ),
      child: Container(
        width: 208,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3729).withValues(alpha: 0.07),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(21),
                  ),
                  child: SizedBox(
                    height: 84,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if ((company.bannerUrl ?? '').isNotEmpty) ...[
                          Image.network(company.bannerUrl!, fit: BoxFit.cover),
                          Container(
                            color: company.tint.withValues(alpha: 0.42),
                          ),
                        ] else ...[
                          Container(color: company.tint),
                          const IslamicPattern(opacity: 0.10, cell: 40),
                        ],
                        PositionedDirectional(
                          top: 10,
                          end: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: company.reviews > 0
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.gold,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        company.rating.toStringAsFixed(1),
                                        style: AppTheme.sans(
                                          11.5,
                                          weight: FontWeight.w800,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: AppColors.primary,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        t.homeNewVerified,
                                        style: AppTheme.sans(
                                          10,
                                          weight: FontWeight.w800,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -26,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CompanyAvatar(
                      mono: company.mono,
                      tint: company.tint,
                      logoUrl: company.logoUrl,
                      size: 48,
                      fontSize: 19,
                      borderRadius: 24,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 34, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.nameFor(
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: AppTheme.sans(14, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    t.companiesLocationEst(company.location, company.since),
                    style: AppTheme.sans(11, color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          offerCount > 0
                              ? t.companiesPackageCount(offerCount)
                              : t.homeNoActivePackages,
                          style: AppTheme.sans(
                            11,
                            weight: FontWeight.w600,
                            color: const Color(0xFF6B7770),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (fromPrice > 0)
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: t.companiesFromPrefix,
                                  style: AppTheme.sans(
                                    10.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                                TextSpan(
                                  text: fmtIqd(fromPrice),
                                  style: AppTheme.serif(
                                    13.5,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
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

class _CuratedSection extends StatelessWidget {
  final List<Offer> offers;
  const _CuratedSection({required this.offers});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
          child: Row(
            children: [
              Text(t.homeCuratedPackages, style: AppTheme.serif(21)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<AppProvider>().setTab(2),
                child: Text(
                  t.homeViewAll,
                  style: AppTheme.sans(
                    13,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: offers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) => _CuratedOfferCard(offer: offers[i]),
        ),
      ],
    );
  }
}

class _CuratedOfferCard extends StatelessWidget {
  final Offer offer;
  const _CuratedOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final company = context.read<AppProvider>().companyById(offer.companyId);

    final tag = 'offer-curated-${offer.id}';

    return InteractiveScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OfferDetailScreen(offer: offer, heroTag: tag),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3729).withValues(alpha: 0.06),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                OfferImage(
                  offer: offer,
                  height: 96,
                  width: 96,
                  borderRadius: BorderRadius.circular(15),
                  heroTag: tag,
                ),
                Positioned(
                  left: 8,
                  bottom: 7,
                  child: Text(
                    offer.cityCode,
                    style: AppTheme.sans(
                      8,
                      color: Colors.white.withValues(alpha: 0.6),
                    ).copyWith(letterSpacing: 0.8),
                  ),
                ),
                if (offer.reviews >= 3 && offer.rating >= 4.8)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _topRatedLabel(
                          Localizations.localeOf(context).languageCode,
                        ),
                        style: AppTheme.sans(
                          8,
                          weight: FontWeight.w800,
                          color: const Color(0xFF1C2317),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company?.nameFor(
                          Localizations.localeOf(context).languageCode,
                        ) ??
                        '',
                    style: AppTheme.sans(
                      10.5,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    offer.titleFor(
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: AppTheme.serif(17.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 7,
                    children: [
                      InfoChip(label: t.homeDaysCount(offer.days)),
                      InfoChip(label: offer.transportLabelFor(t)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      if (offer.reviews > 0)
                        StarRating(rating: offer.rating, reviews: offer.reviews)
                      else
                        Text(
                          t.homeNewOffer,
                          style: AppTheme.sans(
                            11,
                            weight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: t.homeFromPrefix,
                              style: AppTheme.sans(11, color: AppColors.muted),
                            ),
                            TextSpan(
                              text: offer.priceFmt,
                              style: AppTheme.serif(
                                17,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
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

String _topRatedLabel(String lang) {
  if (lang == 'ar') return 'الأعلى تقييماً';
  if (lang == 'ku') return 'بەرزترین نرخاندن';
  return 'Top Rated';
}

class _QuickCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final f = provider.filters;
    final t = AppLocalizations.of(context);

    final items = [
      _CategoryItem(
        label: t.offersAll,
        icon: Icons.explore_outlined,
        onTap: () {
          provider.updateFilters(OfferFilters(sort: f.sort));
          provider.setTab(2);
        },
      ),
      _CategoryItem(
        label: t.offersByAir,
        icon: Icons.flight_rounded,
        onTap: () {
          provider.updateFilters(f.copyWith(transport: 'plane'));
          provider.setTab(2);
        },
      ),
      _CategoryItem(
        label: t.offersByCoach,
        icon: Icons.directions_bus_rounded,
        onTap: () {
          provider.updateFilters(f.copyWith(transport: 'bus'));
          provider.setTab(2);
        },
      ),
      _CategoryItem(
        label: t.offers5Star,
        icon: Icons.star_rounded,
        onTap: () {
          provider.updateFilters(f.copyWith(acc: '5'));
          provider.setTab(2);
        },
      ),
      _CategoryItem(
        label: t.offers4Star,
        icon: Icons.star_border_rounded,
        onTap: () {
          provider.updateFilters(f.copyWith(acc: '4'));
          provider.setTab(2);
        },
      ),
    ];

    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          return TagChip(
            label: item.label,
            icon: item.icon,
            active: false,
            onTap: item.onTap,
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _PrayerTimesWidget extends StatefulWidget {
  const _PrayerTimesWidget();

  @override
  State<_PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<_PrayerTimesWidget> {
  bool _loading = true;
  String _city = 'Makkah';
  String _country = 'Saudi Arabia';
  String _hijriDate = '';
  Map<String, String> _timings = {
    'Fajr': '04:45',
    'Dhuhr': '12:25',
    'Asr': '15:40',
    'Maghrib': '19:05',
    'Isha': '20:35',
  };
  String _nextPrayer = 'Fajr';
  bool _expanded = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted && !_loading) {
        setState(() {
          _nextPrayer = _calculateNextPrayer(_timings);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      // 1. Get IP-based location
      final locRes = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 4));
      double lat = 21.4225;
      double lon = 39.8262;
      String city = 'Makkah';
      String country = 'Saudi Arabia';

      if (locRes.statusCode == 200) {
        final locData = json.decode(locRes.body);
        if (locData['latitude'] != null && locData['longitude'] != null) {
          lat = (locData['latitude'] as num).toDouble();
          lon = (locData['longitude'] as num).toDouble();
          city = locData['city'] ?? 'Makkah';
          country = locData['country_name'] ?? 'Saudi Arabia';
        }
      }

      // 2. Get Prayer times for this lat/lon
      final now = DateTime.now();
      final dateStr = "${now.day}-${now.month}-${now.year}";
      final prayerRes = await http
          .get(
            Uri.parse(
              'https://api.aladhan.com/v1/timings/$dateStr?latitude=$lat&longitude=$lon',
            ),
          )
          .timeout(const Duration(seconds: 4));

      if (prayerRes.statusCode == 200) {
        final prayerData = json.decode(prayerRes.body);
        final data = prayerData['data'];
        if (data != null) {
          if (!mounted) return;
          final timings = data['timings'];
          final hijri = data['date']['hijri'];
          final lang = Localizations.localeOf(context).languageCode;
          // The API only gives month names in ar/en — Kurdish needs its own
          // lookup by month number rather than falling back to English.
          final String hijriMonth;
          if (lang == 'ar') {
            hijriMonth = hijri['month']['ar'];
          } else if (lang == 'ku') {
            hijriMonth = _hijriMonthKu(
              (hijri['month']['number'] as num).toInt(),
            );
          } else {
            hijriMonth = hijri['month']['en'];
          }

          if (mounted) {
            setState(() {
              _city = city;
              _country = country;
              _hijriDate = "${hijri['day']} $hijriMonth ${hijri['year']}";
              _timings = {
                'Fajr': timings['Fajr'] ?? '04:45',
                'Dhuhr': timings['Dhuhr'] ?? '12:25',
                'Asr': timings['Asr'] ?? '15:40',
                'Maghrib': timings['Maghrib'] ?? '19:05',
                'Isha': timings['Isha'] ?? '20:35',
              };
              _nextPrayer = _calculateNextPrayer(_timings);
              _loading = false;
            });
          }
          return;
        }
      }
    } catch (_) {
      // Fallback to Makkah if anything fails
    }

    if (mounted) {
      final lang = Localizations.localeOf(context).languageCode;
      final fallbackMonth = lang == 'ar'
          ? 'محرم'
          : (lang == 'ku' ? _hijriMonthKu(1) : 'Muharram');
      setState(() {
        _hijriDate = "19 $fallbackMonth 1448";
        _nextPrayer = _calculateNextPrayer(_timings);
        _loading = false;
      });
    }
  }

  String _hijriMonthKu(int month) {
    const names = [
      'موحەڕەم',
      'سەفەر',
      'ڕەبیعەلئەوەل',
      'ڕەبیعەلئاخر',
      'جومادەلئوولا',
      'جومادەلئاخرە',
      'ڕەجەب',
      'شەعبان',
      'ڕەمەزان',
      'شەووال',
      'زوولقەعدە',
      'زوولحیجە',
    ];
    if (month < 1 || month > 12) return names[0];
    return names[month - 1];
  }

  DateTime _nextPrayerDateTime(Map<String, String> timings) {
    final now = DateTime.now();
    final list = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (final name in list) {
      final tStr = timings[name];
      if (tStr != null) {
        final parts = tStr.split(':');
        final t = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        if (t.isAfter(now)) {
          return t;
        }
      }
    }

    final fajrStr = timings['Fajr'] ?? '04:45';
    final parts = fajrStr.split(':');
    final tomorrow = now.add(const Duration(days: 1));
    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _calculateNextPrayer(Map<String, String> timings) {
    final now = DateTime.now();
    final list = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final name in list) {
      final tStr = timings[name];
      if (tStr != null) {
        final parts = tStr.split(':');
        final t = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        if (t.isAfter(now)) {
          return name;
        }
      }
    }
    return 'Fajr';
  }

  // Just the "in 26m" part of _countdownText, for the compact header.
  String _durationShort(String lang) {
    final now = DateTime.now();
    final nextTime = _nextPrayerDateTime(_timings);
    final diff = nextTime.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (lang == 'ar') return "بعد ${h > 0 ? '$hس ' : ''}$mد";
    if (lang == 'ku') return "دوای ${h > 0 ? '$hک ' : ''}$mخ";
    return "in ${h > 0 ? '${h}h ' : ''}${m}m";
  }

  String _nowTimeText(String lang) {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return _format12Hour('$hh:$mm', lang);
  }

  String _nextPrayerLabel(String lang) {
    if (lang == 'ar') return 'الصلاة القادمة';
    if (lang == 'ku') return 'نوێژی داهاتوو';
    return 'NEXT PRAYER';
  }

  // The one "next prayer" text — sits beside the icon when collapsed, and
  // is repositioned below it when expanded (see build()). Never shown twice.
  Widget _nextPrayerText(String lang) {
    final goldBold = AppTheme.serif(
      15,
      color: AppColors.gold,
      weight: FontWeight.bold,
    );
    final duration = _durationShort(lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _nextPrayerLabel(lang),
          style: AppTheme.sans(
            10,
            weight: FontWeight.w700,
            color: const Color(0xFF9FBBA9),
          ).copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_prayerName(_nextPrayer, lang)} · ', style: goldBold),
            // Only the counting-down part animates — a little roll-down
            // whenever the minute ticks over, so the update reads as
            // motion rather than a jump cut.
            ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => ClipRect(
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.6),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                ),
                child: Text(duration, key: ValueKey(duration), style: goldBold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final lang = provider.lang;

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF0D2D22),
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.gold,
            ),
          ),
        ),
      );
    }

    final String localizedCity;
    if (_city == 'Makkah') {
      localizedCity = lang == 'ar'
          ? 'مكة المكرمة'
          : (lang == 'ku' ? 'مەککەی پیرۆز' : _city);
    } else {
      localizedCity = _city;
    }

    final String localizedCountry;
    if (_country == 'Saudi Arabia') {
      localizedCountry = lang == 'ar'
          ? 'المملكة العربية السعودية'
          : (lang == 'ku' ? 'عەرەبستانی سعوودی' : _country);
    } else {
      localizedCountry = _country;
    }
    final String locationText = "$localizedCity, $localizedCountry";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(
              0xFF0D2D22,
            ), // Deep premium emerald solid color matching app theme
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F3729).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header: icon always here; the "next prayer" text sits beside
              // it by default and drops below it once expanded, rather than
              // being shown a second time in the expanded detail below.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.dark_mode_rounded,
                      color: AppColors.gold,
                      size: 17,
                    ),
                  ),
                  if (!_expanded) ...[
                    const SizedBox(width: 12),
                    Expanded(child: _nextPrayerText(lang)),
                  ] else
                    const Spacer(),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _nowTimeText(lang),
                        style: AppTheme.sans(
                          13.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizedCity,
                        style: AppTheme.sans(
                          10.5,
                          weight: FontWeight.w600,
                          color: const Color(0xFF9FBBA9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: _nextPrayerText(lang),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  locationText,
                                  style: AppTheme.sans(
                                    11.5,
                                    weight: FontWeight.w700,
                                    color: const Color(0xFFE5D5BA),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _hijriDate,
                                style: AppTheme.sans(
                                  11.5,
                                  weight: FontWeight.w600,
                                  color: const Color(0xFF9FBBA9),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Color(0xFF194637), height: 1),
                          ),
                          Row(
                            children: _timings.entries.map((e) {
                              final isNext = e.key == _nextPrayer;
                              // Expanded so 5 columns always share the
                              // available width instead of overflowing (and
                              // silently clipping one off-screen) on narrow
                              // phones.
                              return Expanded(
                                child: _PrayerTimeCol(
                                  name: _prayerName(e.key, lang),
                                  time: _format12Hour(e.value, lang),
                                  isNext: isNext,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format12Hour(String time24, String lang) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final isPm = hour >= 12;

      hour = hour % 12;
      if (hour == 0) hour = 12;

      final String suffix;
      if (lang == 'ar') {
        suffix = isPm ? 'م' : 'ص';
      } else if (lang == 'ku') {
        suffix = isPm ? 'د.ن' : 'ب.ن';
      } else {
        suffix = isPm ? 'PM' : 'AM';
      }

      return "$hour:$minute $suffix";
    } catch (_) {
      return time24;
    }
  }

  String _prayerName(String name, String lang) {
    if (lang == 'ar') {
      switch (name) {
        case 'Fajr':
          return 'الفجر';
        case 'Dhuhr':
          return 'الظهر';
        case 'Asr':
          return 'العصر';
        case 'Maghrib':
          return 'المغرب';
        case 'Isha':
          return 'العشاء';
        default:
          return name;
      }
    } else if (lang == 'ku') {
      switch (name) {
        case 'Fajr':
          return 'بەیانی';
        case 'Dhuhr':
          return 'نیوەڕۆ';
        case 'Asr':
          return 'عەسر';
        case 'Maghrib':
          return 'مەغریب';
        case 'Isha':
          return 'خەوتنان';
        default:
          return name;
      }
    } else {
      return name;
    }
  }
}

class _PrayerTimeCol extends StatelessWidget {
  final String name;
  final String time;
  final bool isNext;

  const _PrayerTimeCol({
    required this.name,
    required this.time,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isNext ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.sans(
              10,
              weight: isNext ? FontWeight.w800 : FontWeight.w600,
              color: isNext ? const Color(0xFF1C2317) : const Color(0xFF9FBBA9),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.serif(
              13,
              color: isNext ? const Color(0xFF1C2317) : Colors.white,
              weight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
