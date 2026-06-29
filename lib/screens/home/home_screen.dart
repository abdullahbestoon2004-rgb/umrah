import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../data/sample_data.dart';
import '../../models/offer_model.dart';
import '../../models/company_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/company_avatar.dart';
import '../../widgets/tag_chip.dart';
import '../companies/company_detail_screen.dart';
import '../offers/offer_detail_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hero = sampleOffers.first;
    final companies = sampleCompanies.take(4).toList();
    final homeOffers = sampleOffers.skip(1).take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: _HeroCard(offer: hero)),
            SliverToBoxAdapter(child: _SearchBar()),
            SliverToBoxAdapter(child: _AgenciesSection(companies: companies)),
            SliverToBoxAdapter(child: _CuratedSection(offers: homeOffers)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السلام عليكم',
                  style: AppTheme.sans(
                    12,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ).copyWith(letterSpacing: 1.4),
                ),
                const SizedBox(height: 2),
                Text('Welcome, Pilgrim', style: AppTheme.serif(28)),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.primary.withOpacity(0.18), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text('P', style: AppTheme.serif(19, color: const Color(0xFFF3E6C4))),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GradientCard(
                  colors: offer.gradColors,
                  height: 240,
                  borderRadius: BorderRadius.circular(26),
                ),
                // dim overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, const Color(0xFF071C17).withOpacity(0.92)],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                // featured badge
                Positioned(
                  left: 20,
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'FEATURED',
                      style: AppTheme.sans(10.5, weight: FontWeight.w800, color: const Color(0xFF1C2317))
                          .copyWith(letterSpacing: 1),
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
                        sampleCompanies.firstWhere((c) => c.id == offer.companyId).name,
                        style: AppTheme.sans(11, weight: FontWeight.w700, color: const Color(0xFFE7CF95)),
                      ),
                      const SizedBox(height: 2),
                      Text(offer.title, style: AppTheme.serif(25, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${offer.days} days · ${offer.acc}-Star Hotel',
                              style: AppTheme.sans(12.5, color: Colors.white.withOpacity(0.82)),
                            ),
                          ),
                          Text(offer.priceFmt, style: AppTheme.serif(22, color: const Color(0xFFF3E6C4))),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1.5),
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
                'Search Umrah packages…',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
          child: Row(
            children: [
              Text('Top Agencies', style: AppTheme.serif(21)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<AppProvider>().setTab(1),
                child: Text('View all', style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.primary)),
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
    final offerCount = context.watch<AppProvider>().getCompanyOffers(company.id).length;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: company))),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F3729).withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyAvatar(mono: company.mono, tint: company.tint, size: 44, fontSize: 19, borderRadius: 13),
            const SizedBox(height: 11),
            Text(company.name, style: AppTheme.sans(13.5, weight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${company.rating} · $offerCount offers',
                    style: AppTheme.sans(11.5, weight: FontWeight.w600, color: const Color(0xFF6B7770)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
          child: Text('Curated Packages', style: AppTheme.serif(21)),
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
    final company = sampleCompanies.firstWhere((c) => c.id == offer.companyId);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer))),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F3729).withOpacity(0.06), blurRadius: 26, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                GradientCard(colors: offer.gradColors, height: 96, width: 96, borderRadius: BorderRadius.circular(15)),
                Positioned(
                  left: 8,
                  bottom: 7,
                  child: Text(
                    offer.cityCode,
                    style: AppTheme.sans(8, color: Colors.white.withOpacity(0.6)).copyWith(letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company.name,
                      style: AppTheme.sans(10.5, weight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 1),
                  Text(offer.title, style: AppTheme.serif(17.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 7,
                    children: [
                      InfoChip(label: '${offer.days} days'),
                      InfoChip(label: offer.transportLabel),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      StarRating(rating: offer.rating),
                      const Spacer(),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: 'from ',
                              style: AppTheme.sans(11, color: AppColors.muted)),
                          TextSpan(
                              text: offer.priceFmt,
                              style: AppTheme.serif(17, color: AppColors.primary)),
                        ]),
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
