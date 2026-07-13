import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart';
import '../../models/company_model.dart';
import '../../widgets/offer_image.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../l10n/generated/app_localizations.dart';
import 'add_edit_offer_screen.dart';

/// The agency's published trips, with add/edit/delete. Unverified agencies
/// see their packages but can't add new ones (matches the old dashboard).
class AgencyTripsTab extends StatelessWidget {
  const AgencyTripsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final company = provider.agencyCompany;
    if (company == null) return const SizedBox.shrink();
    final offers = provider.getCompanyOffers(company.id);

    return DashboardScaffold(
      title: t.agencyDashboardYourPackages(offers.length),
      trailing: company.isVerified
          ? GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditOfferScreen(companyId: company.id),
                ),
              ),
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 9, 14, 9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.agencyDashboardAddPackage,
                      style: AppTheme.sans(
                        13,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      onRefresh: () => context.read<AppProvider>().loadData(),
      slivers: [
        if (offers.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.add_business_rounded,
              title: t.agencyDashboardNoPackagesYet,
              body: t.agencyDashboardNoPackagesHint,
              ctaLabel: company.isVerified ? t.agencyDashboardAddPackage : null,
              onCta: company.isVerified
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddEditOfferScreen(companyId: company.id),
                      ),
                    )
                  : null,
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  kDashPagePad,
                  0,
                  kDashPagePad,
                  13,
                ),
                child: PackageCard(
                  offer: offers[i],
                  company: company,
                  provider: provider,
                ),
              ),
              childCount: offers.length,
            ),
          ),
      ],
    );
  }
}

/// Trip card with cover, key facts and edit/delete for the owner.
class PackageCard extends StatelessWidget {
  final Offer offer;
  final Company company;
  final AppProvider provider;
  const PackageCard({
    super.key,
    required this.offer,
    required this.company,
    required this.provider,
  });

  bool get _isAgencyOwned => provider.agencyCompany?.id == offer.companyId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OfferImage(offer: offer, height: 100),
                ),
                Positioned(
                  left: 12,
                  bottom: 10,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (offer.badge.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            8,
                            3,
                            8,
                            3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            offer.badge.toUpperCase(),
                            style: AppTheme.sans(
                              9,
                              weight: FontWeight.w800,
                              color: const Color(0xFF1C2317),
                            ),
                          ),
                        ),
                      Text(
                        offer.titleFor(
                          Localizations.localeOf(context).languageCode,
                        ),
                        style: AppTheme.serif(17, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 4),
                      decoration: BoxDecoration(
                        color: offer.lifecycleStatus == 'published'
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.lifecycleStatus.replaceAll('_', ' '),
                        style: AppTheme.sans(
                          10.5,
                          weight: FontWeight.w700,
                          color: offer.lifecycleStatus == 'published'
                              ? AppColors.primary
                              : AppColors.gold,
                        ),
                      ),
                    ),
                    if (offer.reviewReason != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          offer.reviewReason!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.sans(11, color: AppColors.errorRed),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          InfoChip(
                            label: t.agencyDashboardDaysCount(offer.days),
                          ),
                          InfoChip(label: offer.transportLabelFor(t)),
                          InfoChip(label: '${offer.acc}★'),
                          InfoChip(label: offer.priceFmt),
                        ],
                      ),
                    ),
                    if (_isAgencyOwned) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditOfferScreen(
                              companyId: company.id,
                              existing: offer,
                            ),
                          ),
                        ),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.primary,
                            size: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.errorRed,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_isAgencyOwned &&
                    company.isVerified &&
                    [
                      'draft',
                      'needs_changes',
                      'rejected',
                      'paused',
                    ].contains(offer.lifecycleStatus)) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final err = await provider.submitOfferForReview(
                          offer.id,
                        );
                        messenger.showSnackBar(
                          appSnack(
                            err == null ? t.workflowSubmitted : err,
                            isError: err != null,
                          ),
                        );
                      },
                      child: Text(t.workflowSubmitForReview),
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
    final messenger = ScaffoldMessenger.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          t.agencyDashboardDeletePackageTitle,
          style: AppTheme.serif(20),
        ),
        content: Text(
          t.agencyDashboardDeletePackageBody(offer.titleFor(lang)),
          style: AppTheme.sans(13, color: AppColors.inkLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              t.agencyDashboardCancel,
              style: AppTheme.sans(13, color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await provider.deleteOffer(offer.id);
              if (!ok) {
                messenger.showSnackBar(
                  appSnack(t.addEditOfferSaveFailed, isError: true),
                );
              }
            },
            child: Text(
              t.agencyDashboardDelete,
              style: AppTheme.sans(
                13,
                weight: FontWeight.w700,
                color: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
