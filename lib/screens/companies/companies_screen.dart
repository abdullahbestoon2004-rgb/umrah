import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../data/sample_data.dart';
import '../../models/company_model.dart';
import '../../providers/app_provider.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agencies', style: AppTheme.serif(30)),
                    const SizedBox(height: 3),
                    Text(
                      '${sampleCompanies.length} verified Umrah operators',
                      style: AppTheme.sans(13, color: const Color(0xFF7D8A82)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, i < sampleCompanies.length - 1 ? 13 : 24),
                  child: _CompanyListCard(company: sampleCompanies[i]),
                ),
                childCount: sampleCompanies.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyListCard extends StatelessWidget {
  final Company company;
  const _CompanyListCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final offers = context.watch<AppProvider>().getCompanyOffers(company.id);
    final offerCount = offers.length;
    final fromPrice = offers.isEmpty ? 0.0 : offers.map((o) => o.price).reduce((a, b) => a < b ? a : b);

    final gradDark = Color.alphaBlend(Colors.black.withOpacity(0.35), company.tint);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: company))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F3729).withOpacity(0.07), blurRadius: 30, offset: const Offset(0, 14)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── gradient header ──────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
              child: SizedBox(
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // gradient background from tint colour
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [company.tint, gradDark],
                        ),
                      ),
                    ),
                    // bottom scrim for text legibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.52)],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                    // verified badge — top left
                    if (company.isVerified)
                      Positioned(
                        left: 14,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 10, color: Color(0xFF1C2317)),
                              const SizedBox(width: 4),
                              Text(
                                'VERIFIED',
                                style: AppTheme.sans(9, weight: FontWeight.w800, color: const Color(0xFF1C2317))
                                    .copyWith(letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // mono logo — top right
                    Positioned(
                      top: 12,
                      right: 14,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(
                          child: Text(
                            company.mono,
                            style: AppTheme.sans(20, weight: FontWeight.w800, color: company.tint),
                          ),
                        ),
                      ),
                    ),
                    // company name + location — bottom left
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: AppTheme.serif(21, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${company.location} · est. ${company.since}',
                            style: AppTheme.sans(10.5, weight: FontWeight.w600, color: Colors.white.withOpacity(0.78)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── detail row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                  const SizedBox(width: 4),
                  Text('${company.rating}', style: AppTheme.sans(12.5, weight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(width: 6),
                  Text('·', style: AppTheme.sans(13, color: AppColors.mutedLight)),
                  const SizedBox(width: 6),
                  Text(
                    '$offerCount package${offerCount != 1 ? "s" : ""}',
                    style: AppTheme.sans(12.5, weight: FontWeight.w600, color: AppColors.inkLight),
                  ),
                  const Spacer(),
                  if (fromPrice > 0) ...[
                    Text('from ', style: AppTheme.sans(11, color: AppColors.muted)),
                    Text('\$${fromPrice.round()}', style: AppTheme.serif(22, color: AppColors.primary)),
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
