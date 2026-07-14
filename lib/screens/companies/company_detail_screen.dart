import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/company_model.dart';
import '../../models/offer_model.dart';
import '../../models/review_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/offer_image.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/company_avatar.dart';
import '../../widgets/tag_chip.dart';
import '../offers/offer_detail_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/interactive_scale.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;
  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  Company get company => widget.company;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AppProvider>().loadCompanyReviews(company.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final offers = provider.getCompanyOffers(company.id);
    final reviews = provider.reviewsForCompany(company.id);
    final fromPrice = offers.isEmpty
        ? 0.0
        : offers.map((o) => o.price).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const IslamicPattern(opacity: 0.04, isEightFold: true),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _CompanyHeader(
                  company: company,
                  offerCount: offers.length,
                  fromPrice: fromPrice,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (company
                          .aboutFor(
                            Localizations.localeOf(context).languageCode,
                          )
                          .isNotEmpty) ...[
                        Text(t.companyDetailAbout, style: AppTheme.serif(19)),
                        const SizedBox(height: 7),
                        Text(
                          company.aboutFor(
                            Localizations.localeOf(context).languageCode,
                          ),
                          style: AppTheme.sans(
                            13.5,
                            color: const Color(0xFF52605A),
                          ).copyWith(height: 1.65),
                        ),
                        const SizedBox(height: 18),
                      ] else
                        const SizedBox(height: 6),
                      if (company.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: company.tags
                              .map((tag) => _TagBadge(label: tag))
                              .toList(),
                        ),
                        const SizedBox(height: 22),
                      ],
                      _AgencyTrustCard(company: company),
                      const SizedBox(height: 18),
                      if ((company.officeAddress ?? '').isNotEmpty ||
                          (company.phone ?? '').isNotEmpty ||
                          (company.officeHours ?? '').isNotEmpty) ...[
                        _AgencyContactCard(company: company),
                        const SizedBox(height: 22),
                      ],
                      Text(
                        t.companyDetailPackagesHeader(offers.length),
                        style: AppTheme.serif(19),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      0,
                      22,
                      i < offers.length - 1 ? 13 : 26,
                    ),
                    child: _CompanyOfferCard(offer: offers[i]),
                  ),
                  childCount: offers.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AgencyReviewsSection(company: company, reviews: reviews),
                      const SizedBox(height: 22),
                      if (company
                          .cancellationPolicyFor(
                            Localizations.localeOf(context).languageCode,
                          )
                          .isNotEmpty)
                        _AgencyPolicyCard(company: company),
                      const SizedBox(height: 18),
                      Center(
                        child: TextButton.icon(
                          onPressed: provider.user?.role == 'client'
                              ? () => _showReportDialog(context)
                              : null,
                          icon: const Icon(Icons.flag_outlined, size: 18),
                          label: Text(t.companyReportAgency),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final reason = TextEditingController();
    final details = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.companyReportAgency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reason,
              decoration: InputDecoration(labelText: t.companyReportReason),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: details,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.companyReportDetails),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.agencyDashboardCancel),
          ),
          FilledButton(
            onPressed: () {
              if (reason.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(t.companyReportSubmit),
          ),
        ],
      ),
    );
    if (submitted != true || !context.mounted) {
      reason.dispose();
      details.dispose();
      return;
    }
    final error = await context.read<AppProvider>().reportAgency(
      agencyId: company.id,
      reason: reason.text.trim(),
      details: details.text.trim(),
    );
    reason.dispose();
    details.dispose();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? t.companyReportSubmitted)));
  }
}

class _AgencyTrustCard extends StatelessWidget {
  final Company company;
  const _AgencyTrustCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.companyTrustSignals, style: AppTheme.serif(18)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final badge in company.badges)
                _TagBadge(
                  label: badge.nameFor(
                    Localizations.localeOf(context).languageCode,
                  ),
                ),
              if (company.badges.isEmpty && company.isVerified)
                _TagBadge(label: t.agencyDashboardVerifiedAgency),
            ],
          ),
          if ((company.licenseNumber ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            _TrustLine(
              icon: Icons.badge_outlined,
              text: t.companyLicenseNumber(company.licenseNumber!),
            ),
          ],
          _TrustLine(
            icon: Icons.groups_rounded,
            text: t.companyPilgrimsServed(company.pilgrimsServed),
          ),
          if (company.medianResponseMinutes != null)
            _TrustLine(
              icon: Icons.schedule_rounded,
              text: t.companyResponseTime(company.responseTimeLabel),
            ),
          for (final detail in company.verificationDetails)
            _TrustLine(icon: Icons.verified_user_outlined, text: detail),
        ],
      ),
    );
  }
}

class _TrustLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TrustLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 9),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: AppTheme.sans(12.5))),
      ],
    ),
  );
}

class _AgencyContactCard extends StatelessWidget {
  final Company company;
  const _AgencyContactCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.companyContactLocation, style: AppTheme.serif(19)),
        const SizedBox(height: 10),
        if ((company.officeAddress ?? '').isNotEmpty)
          _TrustLine(
            icon: Icons.location_on_outlined,
            text: company.officeAddress!,
          ),
        if ((company.phone ?? '').isNotEmpty)
          _TrustLine(icon: Icons.phone_outlined, text: company.phone!),
        if ((company.whatsapp ?? '').isNotEmpty)
          _TrustLine(icon: Icons.chat_outlined, text: company.whatsapp!),
        if ((company.officeHours ?? '').isNotEmpty)
          _TrustLine(
            icon: Icons.access_time_rounded,
            text: company.officeHours!,
          ),
        for (final branch in company.branches)
          _TrustLine(icon: Icons.store_mall_directory_outlined, text: branch),
      ],
    );
  }
}

class _AgencyReviewsSection extends StatelessWidget {
  final Company company;
  final List<Review> reviews;
  const _AgencyReviewsSection({required this.company, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.profileStatReviews, style: AppTheme.serif(19)),
        const SizedBox(height: 10),
        for (var stars = 5; stars >= 1; stars--)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('$stars★', style: AppTheme.sans(11)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: reviews.isEmpty
                        ? 0
                        : reviews
                                  .where((review) => review.rating == stars)
                                  .length /
                              reviews.length,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(8),
                    backgroundColor: AppColors.border,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        for (final review in reviews.take(5))
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'★' * review.rating}${'☆' * (5 - review.rating)}',
                  style: const TextStyle(color: AppColors.gold),
                ),
                if (review.comment.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(review.comment, style: AppTheme.sans(12.5)),
                ],
                if (review.publicReply.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${t.companyAgencyReply}: ${review.publicReply}',
                      style: AppTheme.sans(12, color: AppColors.inkLight),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _AgencyPolicyCard extends StatelessWidget {
  final Company company;
  const _AgencyPolicyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.offerTrustAndPolicy, style: AppTheme.serif(19)),
        const SizedBox(height: 9),
        Text(
          company.cancellationPolicyFor(lang),
          style: AppTheme.sans(
            12.5,
            color: AppColors.inkLight,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 9),
        Text(
          t.offerAcceptedPaymentList(
            company.acceptedPaymentMethods
                .map((method) => method == 'fib' ? 'FIB' : method.toUpperCase())
                .join(' · '),
          ),
          style: AppTheme.sans(
            12,
            weight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  final Company company;
  final int offerCount;
  final double fromPrice;
  const _CompanyHeader({
    required this.company,
    required this.offerCount,
    required this.fromPrice,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: company.tint,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            if ((company.bannerUrl ?? '').isNotEmpty)
              Positioned.fill(
                child: Image.network(company.bannerUrl!, fit: BoxFit.cover),
              ),
            if ((company.bannerUrl ?? '').isNotEmpty)
              Positioned.fill(
                child: Container(color: company.tint.withOpacity(0.42)),
              ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.16)),
            ),
            const Positioned.fill(
              child: IslamicPattern(opacity: 0.06, cell: 72),
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      (company.logoUrl ?? '').isNotEmpty
                          ? CompanyAvatar(
                              mono: company.mono,
                              tint: company.tint,
                              logoUrl: company.logoUrl,
                              size: 62,
                              fontSize: 26,
                              borderRadius: 18,
                            )
                          : Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                company.mono,
                                style: AppTheme.serif(26, color: company.tint),
                              ),
                            ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    company.nameFor(
                                      Localizations.localeOf(
                                        context,
                                      ).languageCode,
                                    ),
                                    style: AppTheme.serif(
                                      24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (company.isVerified)
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t.companyDetailLocationSince(
                                company.location,
                                company.since,
                              ),
                              style: AppTheme.sans(
                                12.5,
                                color: Colors.white.withOpacity(0.78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _StatBox(
                        value: '★ ${company.rating}',
                        label: t.companyDetailReviewsCount(company.reviews),
                      ),
                      const SizedBox(width: 22),
                      _StatBox(
                        value: '$offerCount',
                        label: t.companyDetailPackagesLabel,
                      ),
                      const SizedBox(width: 22),
                      _StatBox(
                        value: fromPrice > 0 ? fmtIqd(fromPrice) : '—',
                        label: t.companyDetailStartingLabel,
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
        Text(
          label,
          style: AppTheme.sans(11, color: Colors.white.withOpacity(0.7)),
        ),
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
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTheme.sans(
          11.5,
          weight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _CompanyOfferCard extends StatelessWidget {
  final Offer offer;
  const _CompanyOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final tag = 'offer-company-${offer.id}';
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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F3729).withOpacity(0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            OfferImage(
              offer: offer,
              height: 88,
              width: 88,
              borderRadius: BorderRadius.circular(13),
              heroTag: tag,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.titleFor(
                      Localizations.localeOf(context).languageCode,
                    ),
                    style: AppTheme.serif(17),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    children: [
                      InfoChip(label: t.offersDaysCount(offer.days)),
                      InfoChip(label: offer.transportLabelFor(t)),
                      InfoChip(label: '${offer.acc}★'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '★ ${offer.rating}',
                        style: AppTheme.sans(11.5, weight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: t.companyDetailFromPrefix,
                              style: AppTheme.sans(11, color: AppColors.muted),
                            ),
                            TextSpan(
                              text: offer.priceFmt,
                              style: AppTheme.serif(
                                16,
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
