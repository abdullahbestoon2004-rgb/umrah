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
import '../search/search_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/interactive_scale.dart';
import '../../widgets/islamic_pattern.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = AppLocalizations.of(context);

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (provider.loadFailed || provider.allOffers.isEmpty) {
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

    // Live data: admin-featured packages first, then best-rated.
    final ranked = List<Offer>.from(provider.allOffers)
      ..sort((a, b) {
        if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
    final ads = provider.homeAds;
    final hero = ranked.first;
    final homeOffers = (ads.isEmpty ? ranked.skip(1) : ranked).take(4).toList();
    final companies = provider.companies.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const IslamicPattern(opacity: 0.04, isEightFold: true),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header()),
                const SliverToBoxAdapter(child: _PrayerTimesWidget()),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                // Paid agency ads rotate in a carousel; without any, the
                // best-rated offer takes the spot.
                SliverToBoxAdapter(
                  child: ads.isNotEmpty
                      ? _AdsCarousel(ads: ads)
                      : _HeroCard(offer: hero),
                ),
                SliverToBoxAdapter(child: _SearchBar()),
                SliverToBoxAdapter(child: _QuickCategories()),
                SliverToBoxAdapter(child: _TrustGrid()),
                SliverToBoxAdapter(
                  child: _AgenciesSection(companies: companies),
                ),
                if (homeOffers.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _CuratedSection(offers: homeOffers),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
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
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
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
                          : AppColors.primary.withOpacity(0.25),
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
    return InteractiveScale(
      onTap: offer == null
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfferDetailScreen(offer: offer, heroTag: tag),
              ),
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if ((ad.imageUrl ?? '').isNotEmpty)
              tag != null
                  ? Hero(
                      tag: tag,
                      child: Image.network(
                        ad.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const GradientCard(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          height: 240,
                        ),
                      ),
                    )
                  : Image.network(
                      ad.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const GradientCard(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        height: 240,
                      ),
                    )
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
                    const Color(0xFF071C17).withOpacity(0.92),
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
                  color: AppColors.gold.withOpacity(0.95),
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
                              color: Colors.white.withOpacity(0.82),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    final String displayName =
        provider.isSignedIn && user != null && user.fullName.isNotEmpty
        ? user.fullName
        : t.homeWelcomePilgrim;

    final String initial = provider.isSignedIn && user != null
        ? (user.fullName.isNotEmpty
              ? user.fullName.trim()[0].toUpperCase()
              : user.email[0].toUpperCase())
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.homeGreeting,
                  style: AppTheme.sans(
                    12,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ).copyWith(letterSpacing: 1.4),
                ),
                const SizedBox(height: 2),
                Text(displayName, style: AppTheme.serif(28)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => provider.setTab(4), // Navigate to Profile Tab
            child: InteractiveScale(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: initial.isNotEmpty
                    ? Text(
                        initial,
                        style: AppTheme.serif(
                          19,
                          color: const Color(0xFFF3E6C4),
                        ),
                      )
                    : const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFFF3E6C4),
                        size: 21,
                      ),
              ),
            ),
          ),
        ],
      ),
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
                        const Color(0xFF071C17).withOpacity(0.92),
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
                      color: AppColors.gold.withOpacity(0.95),
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
                                color: Colors.white.withOpacity(0.82),
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

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
      child: InteractiveScale(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F3729).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 11),
              Text(
                t.homeSearchPlaceholder,
                style: AppTheme.sans(14, color: const Color(0xFF7D8A82)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgenciesSection extends StatelessWidget {
  final List<Company> companies;
  const _AgenciesSection({required this.companies});

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
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: companies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 13),
            itemBuilder: (context, i) => _AgencyCard(company: companies[i]),
          ),
        ),
      ],
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final Company company;
  const _AgencyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final offerCount = context
        .watch<AppProvider>()
        .getCompanyOffers(company.id)
        .length;
    return InteractiveScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyDetailScreen(company: company),
        ),
      ),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3729).withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyAvatar(
              mono: company.mono,
              tint: company.tint,
              size: 44,
              fontSize: 19,
              borderRadius: 13,
            ),
            const SizedBox(height: 11),
            Text(
              company.nameFor(Localizations.localeOf(context).languageCode),
              style: AppTheme.sans(13.5, weight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    t.homeRatingOffersCount(company.rating, offerCount),
                    style: AppTheme.sans(
                      11.5,
                      weight: FontWeight.w600,
                      color: const Color(0xFF6B7770),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
          child: Text(t.homeCuratedPackages, style: AppTheme.serif(21)),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: offers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
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
            color: AppColors.primary.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3729).withOpacity(0.06),
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
                      color: Colors.white.withOpacity(0.6),
                    ).copyWith(letterSpacing: 0.8),
                  ),
                ),
                if (offer.rating >= 4.8)
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
                      InfoChip(label: offer.transportLabel),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      StarRating(rating: offer.rating),
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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
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

class _TrustGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final lang = provider.lang;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
      child: Row(
        children: [
          Expanded(
            child: _TrustCard(
              label: _trustLabel('verified', lang),
              icon: Icons.verified_user_outlined,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TrustCard(
              label: _trustLabel('secure', lang),
              icon: Icons.lock_outline_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TrustCard(
              label: _trustLabel('support', lang),
              icon: Icons.support_agent_rounded,
            ),
          ),
        ],
      ),
    );
  }

  String _trustLabel(String key, String lang) {
    if (lang == 'ar') {
      switch (key) {
        case 'verified':
          return 'وكالات موثقة';
        case 'secure':
          return 'دفع آمن';
        case 'support':
          return 'دعم متواصل';
        default:
          return '';
      }
    } else if (lang == 'ku') {
      switch (key) {
        case 'verified':
          return 'بریکاری باوەڕپێکراو';
        case 'secure':
          return 'پارەدانی پارێزراو';
        case 'support':
          return 'پشتیوانی ٢٤/٧';
        default:
          return '';
      }
    } else {
      switch (key) {
        case 'verified':
          return 'Verified Agencies';
        case 'secure':
          return 'Secure Payments';
        case 'support':
          return '24/7 Support';
        default:
          return '';
      }
    }
  }
}

class _TrustCard extends StatelessWidget {
  final String label;
  final IconData icon;

  const _TrustCard({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3729).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTheme.sans(
              10.5,
              weight: FontWeight.w700,
              color: AppColors.ink,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
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
          final timings = data['timings'];
          final hijri = data['date']['hijri'];
          final lang = Localizations.localeOf(context).languageCode;
          final hijriMonth = lang == 'ar'
              ? hijri['month']['ar']
              : hijri['month']['en'];

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
      setState(() {
        _hijriDate = "19 Muharram 1448";
        _nextPrayer = _calculateNextPrayer(_timings);
        _loading = false;
      });
    }
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

  String _countdownText(
    String nextPrayerName,
    Map<String, String> timings,
    String lang,
  ) {
    final now = DateTime.now();
    final nextTime = _nextPrayerDateTime(timings);
    final diff = nextTime.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;

    final prName = _prayerName(nextPrayerName, lang);

    if (lang == 'ar') {
      return "الصلاة القادمة: $prName بعد ${h > 0 ? '$hس ' : ''}${m}د";
    } else if (lang == 'ku') {
      return "نوێژی داهاتوو: $prName دوای ${h > 0 ? '$hک ' : ''}${m}خ";
    } else {
      return "Next: $prName in ${h > 0 ? '${h}h ' : ''}${m}m";
    }
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

    final bool isRtl = lang != 'en';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(
            0xFF0D2D22,
          ), // Deep premium emerald solid color matching app theme
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3729).withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row: Location & Hijri Date
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
            const SizedBox(height: 8),
            Align(
              alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                _countdownText(_nextPrayer, _timings, lang),
                style: AppTheme.serif(
                  15.5,
                  color: AppColors.gold,
                  weight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0xFF194637), height: 1),
            ),
            // Bottom row: Timings row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _timings.entries.map((e) {
                final isNext = e.key == _nextPrayer;
                return _PrayerTimeCol(
                  name: _prayerName(e.key, lang),
                  time: _format12Hour(e.value, lang),
                  isNext: isNext,
                );
              }).toList(),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isNext ? AppColors.gold : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: AppTheme.sans(
              10.5,
              weight: isNext ? FontWeight.w800 : FontWeight.w600,
              color: isNext ? const Color(0xFF1C2317) : const Color(0xFF9FBBA9),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            time,
            style: AppTheme.serif(
              14,
              color: isNext ? const Color(0xFF1C2317) : Colors.white,
              weight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
