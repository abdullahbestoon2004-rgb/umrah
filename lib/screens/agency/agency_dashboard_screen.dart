import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/tag_chip.dart';
import '../../l10n/generated/app_localizations.dart';
import 'add_edit_offer_screen.dart';
import 'edit_agency_profile_screen.dart';

class AgencyDashboardScreen extends StatelessWidget {
  const AgencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final company = provider.agencyCompany;
    if (company == null) return const SizedBox.shrink();

    final offers = provider.getCompanyOffers(company.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _DashboardHeader(company: company, provider: provider)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
              child: Row(
                children: [
                  Text(t.agencyDashboardYourPackages(offers.length), style: AppTheme.serif(20)),
                  const Spacer(),
                  if (company.isVerified)
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AddEditOfferScreen(companyId: company.id))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(t.agencyDashboardAddPackage, style: AppTheme.sans(13, weight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (!company.isVerified)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, color: AppColors.gold, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.agencyDashboardVerificationPending, style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.gold)),
                            const SizedBox(height: 3),
                            Text(t.agencyDashboardVerificationPendingBody,
                                style: AppTheme.sans(12, color: const Color(0xFF8A7040))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (offers.isEmpty && company.isVerified)
            const SliverFillRemaining(child: _EmptyPackages()),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: EdgeInsets.fromLTRB(22, 0, 22, i < offers.length - 1 ? 13 : 24),
                child: _PackageCard(offer: offers[i], company: company, provider: provider),
              ),
              childCount: offers.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final dynamic company;
  final AppProvider provider;
  const _DashboardHeader({required this.company, required this.provider});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [company.tint, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(13)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  if (company.isVerified)
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => EditAgencyProfileScreen(company: company))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(t.agencyDashboardEditProfile, style: AppTheme.sans(13, weight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      provider.agencyLogout();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(13)),
                      child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    child: Text(company.mono, style: AppTheme.serif(24, color: company.tint)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(child: Text(company.name, style: AppTheme.serif(22, color: Colors.white))),
                          const SizedBox(width: 6),
                          Icon(
                            company.isVerified ? Icons.verified_rounded : Icons.schedule_rounded,
                            color: company.isVerified ? Colors.white : AppColors.gold,
                            size: 18,
                          ),
                        ]),
                        const SizedBox(height: 3),
                        Text(
                          company.isVerified ? t.agencyDashboardVerifiedAgency : t.agencyDashboardPendingVerification,
                          style: AppTheme.sans(12, color: Colors.white.withOpacity(0.75)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Offer offer;
  final dynamic company;
  final AppProvider provider;
  const _PackageCard({required this.offer, required this.company, required this.provider});

  bool get _isAgencyOwned => provider.agencyCompany?.id == offer.companyId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: Stack(
              children: [
                GradientCard(colors: offer.gradColors, height: 100, borderRadius: BorderRadius.circular(0)),
                Positioned(
                  left: 12, bottom: 10, right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offer.badge.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                          child: Text(offer.badge.toUpperCase(), style: AppTheme.sans(9, weight: FontWeight.w800, color: const Color(0xFF1C2317))),
                        ),
                      Text(offer.title, style: AppTheme.serif(17, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(spacing: 6, runSpacing: 4, children: [
                    InfoChip(label: t.agencyDashboardDaysCount(offer.days)),
                    InfoChip(label: offer.transportLabel),
                    InfoChip(label: '${offer.acc}★'),
                    InfoChip(label: offer.priceFmt),
                  ]),
                ),
                if (company.isVerified && _isAgencyOwned) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AddEditOfferScreen(companyId: company.id, existing: offer))),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 17),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _confirmDelete(context),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.errorRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 17),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.agencyDashboardDeletePackageTitle, style: AppTheme.serif(20)),
        content: Text(t.agencyDashboardDeletePackageBody(offer.title), style: AppTheme.sans(13, color: AppColors.inkLight)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.agencyDashboardCancel, style: AppTheme.sans(13, color: AppColors.muted))),
          TextButton(
            onPressed: () { provider.deleteOffer(offer.id); Navigator.pop(context); },
            child: Text(t.agencyDashboardDelete, style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

class _EmptyPackages extends StatelessWidget {
  const _EmptyPackages();
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: const Color(0xFFEAF1EC), shape: BoxShape.circle),
            child: const Icon(Icons.add_business_rounded, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 16),
          Text(t.agencyDashboardNoPackagesYet, style: AppTheme.serif(22)),
          const SizedBox(height: 5),
          Text(t.agencyDashboardNoPackagesHint, style: AppTheme.sans(13, color: AppColors.muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
