import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/company_model.dart';
import '../../models/offer_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/tag_chip.dart';
import '../offers/offer_detail_screen.dart';
import '../../l10n/generated/app_localizations.dart';

class CompanyDetailScreen extends StatelessWidget {
  final Company company;
  const CompanyDetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final offers = provider.getCompanyOffers(company.id);
    final fromPrice = offers.isEmpty ? 0.0 : offers.map((o) => o.price).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _CompanyHeader(company: company, offerCount: offers.length, fromPrice: fromPrice)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.companyDetailAbout, style: AppTheme.serif(19)),
                  const SizedBox(height: 7),
                  Text(company.about, style: AppTheme.sans(13.5, color: const Color(0xFF52605A)).copyWith(height: 1.65)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: company.tags.map((tag) => _TagBadge(label: tag)).toList(),
                  ),
                  const SizedBox(height: 22),
                  Text(t.companyDetailPackagesHeader(offers.length), style: AppTheme.serif(19)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: EdgeInsets.fromLTRB(22, 0, 22, i < offers.length - 1 ? 13 : 26),
                child: _CompanyOfferCard(offer: offers[i]),
              ),
              childCount: offers.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final Company company;
  final int offerCount;
  final double fromPrice;
  const _CompanyHeader({required this.company, required this.offerCount, required this.fromPrice});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [company.tint, const Color(0xFF0A3F35)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(company.mono, style: AppTheme.serif(26, color: company.tint)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(company.name, style: AppTheme.serif(24, color: Colors.white))),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t.companyDetailLocationSince(company.location, company.since),
                              style: AppTheme.sans(12.5, color: Colors.white.withOpacity(0.78)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatBox(value: '★ ${company.rating}', label: t.companyDetailReviewsCount(company.reviews)),
                      const SizedBox(width: 22),
                      _StatBox(value: '$offerCount', label: t.companyDetailPackagesLabel),
                      const SizedBox(width: 22),
                      _StatBox(value: fromPrice > 0 ? '\$${fromPrice.round()}' : '—', label: t.companyDetailStartingLabel),
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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTheme.serif(21, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.sans(11, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  const _TagBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1EC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
      ),
      child: Text(label, style: AppTheme.sans(11.5, weight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}

class _CompanyOfferCard extends StatelessWidget {
  final Offer offer;
  const _CompanyOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer))),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F3729).withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            GradientCard(colors: offer.gradColors, height: 88, width: 88, borderRadius: BorderRadius.circular(13)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.title, style: AppTheme.serif(17), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    children: [
                      InfoChip(label: '${offer.days}d'),
                      InfoChip(label: offer.transportLabel),
                      InfoChip(label: '${offer.acc}★'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('★ ${offer.rating}', style: AppTheme.sans(11.5, weight: FontWeight.w700)),
                      const Spacer(),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(text: t.companyDetailFromPrefix, style: AppTheme.sans(11, color: AppColors.muted)),
                          TextSpan(text: offer.priceFmt, style: AppTheme.serif(16, color: AppColors.primary)),
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
