import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../data/sample_data.dart';
import '../../models/company_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/company_avatar.dart';
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
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(company: company))),
      child: Container(
        padding: const EdgeInsets.all(15),
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
            CompanyAvatar(mono: company.mono, tint: company.tint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(company.name, style: AppTheme.sans(16, weight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${company.location} · since ${company.since}',
                    style: AppTheme.sans(12, color: const Color(0xFF7D8A82)),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.gold, size: 13),
                      const SizedBox(width: 4),
                      Text('${company.rating}', style: AppTheme.sans(12, weight: FontWeight.w600, color: const Color(0xFF5E6B63))),
                      const SizedBox(width: 8),
                      Text('|', style: AppTheme.sans(12, color: const Color(0xFFCDD3CB))),
                      const SizedBox(width: 8),
                      Text('$offerCount offers', style: AppTheme.sans(12, weight: FontWeight.w600, color: const Color(0xFF5E6B63))),
                      const SizedBox(width: 8),
                      Text('|', style: AppTheme.sans(12, color: const Color(0xFFCDD3CB))),
                      const SizedBox(width: 8),
                      Text(
                        fromPrice > 0 ? 'from \$${fromPrice.round()}' : '',
                        style: AppTheme.sans(12, weight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: const Color(0xFFB9C1B8), size: 22),
          ],
        ),
      ),
    );
  }
}
