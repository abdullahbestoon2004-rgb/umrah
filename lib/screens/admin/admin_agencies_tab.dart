import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/company_model.dart';
import '../../models/offer_model.dart' show Offer;
import '../../widgets/app_snackbar.dart';
import '../../widgets/company_avatar.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/interactive_scale.dart';
import '../../widgets/offer_image.dart';
import '../../widgets/commission_widgets.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/detail_tab_scaffold.dart';
import '../../widgets/dashboard/entity_list_card.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/filter_chip_bar.dart';
import '../../widgets/dashboard/section_header.dart';
import '../../widgets/dashboard/status_chip.dart';
import '../../l10n/generated/app_localizations.dart';

/// Admin agency directory: search + status filter, with pending approvals
/// pinned above the main list. Rows open the agency detail screen.
class AdminAgenciesTab extends StatefulWidget {
  const AdminAgenciesTab({super.key});

  @override
  State<AdminAgenciesTab> createState() => _AdminAgenciesTabState();
}

class _AdminAgenciesTabState extends State<AdminAgenciesTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _filter = 'all'; // 'all' | 'pending' | 'active'

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _matches(Company c, String lang) =>
      _query.isEmpty ||
      c.nameFor(lang).toLowerCase().contains(_query) ||
      c.location.toLowerCase().contains(_query);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    final pending =
        provider.pendingCompanies.where((c) => _matches(c, lang)).toList();
    final active = provider.companies
        .where((c) => c.isVerified && _matches(c, lang))
        .toList();
    final showPending = _filter != 'active' && pending.isNotEmpty;
    final showActive = _filter != 'pending';

    return DashboardScaffold(
      title: t.navAgencies,
      onRefresh: () => context.read<AppProvider>().loadAdminData(),
      filterBar: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: kDashPagePad),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: AppTheme.sans(14),
                decoration: InputDecoration(
                  hintText: t.promoteSearchAgencies,
                  hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.primary, size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilterChipBar<String>(
            options: [
              FilterOption('all', t.adminFilterAll),
              FilterOption('pending', t.adminStatPending),
              FilterOption('active', t.adminFilterActive),
            ],
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
        ],
      ),
      filterBarHeight: 100,
      slivers: [
        if (showPending) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              title: t.adminPendingAgencies,
              count: pending.length,
              accent: AppColors.gold,
              firstSection: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    kDashPagePad, 0, kDashPagePad, kDashCardGap),
                child: PendingCompanyCard(company: pending[i]),
              ),
              childCount: pending.length,
            ),
          ),
        ],
        if (_filter == 'pending' && pending.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: kDashCardGap),
              child: EmptyState(
                  icon: Icons.schedule_rounded,
                  title: t.adminNoPending,
                  compact: true),
            ),
          ),
        if (showActive) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              title: t.adminFilterActive,
              count: active.length,
              firstSection: !showPending,
            ),
          ),
          if (active.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                  icon: Icons.domain_rounded,
                  title: t.promoteNoAgencies,
                  compact: true),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final company = active[i];
                  final offers = provider.getCompanyOffers(company.id).length;
                  return Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        kDashPagePad, 0, kDashPagePad, kDashCardGap),
                    child: EntityListCard(
                      leading: CompanyAvatar(
                        mono: company.mono,
                        tint: company.tint,
                        logoUrl: company.logoUrl,
                        size: 44,
                        fontSize: 16,
                        borderRadius: 12,
                      ),
                      title: company.nameFor(lang),
                      subtitle:
                          '${company.location} · ${t.packagesCount(offers)}',
                      trailing: company.isPromoted
                          ? const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 20)
                          : null,
                      chevron: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AdminAgencyDetailScreen(companyId: company.id)),
                      ),
                    ),
                  );
                },
                childCount: active.length,
              ),
            ),
        ],
      ],
    );
  }
}

/// Pending approval card with inline approve / decline actions.
class PendingCompanyCard extends StatelessWidget {
  final Company company;
  const PendingCompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                Text(company.nameFor(lang),
                    style: AppTheme.sans(14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(company.location,
                    style: AppTheme.sans(12, color: AppColors.muted)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await provider.approveCompany(company.id);
                  messenger.showSnackBar(
                    appSnack(ok ? t.adminApproved : t.adminActionFailed,
                        isError: !ok),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16, 9, 16, 9),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(t.adminApprove,
                      style: AppTheme.sans(12.5,
                          weight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title:
                          Text(t.adminDeclineTitle, style: AppTheme.serif(20)),
                      content: Text(t.adminDeclineBody,
                          style:
                              AppTheme.sans(13, color: AppColors.inkLight)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: Text(t.agencyDashboardCancel,
                              style:
                                  AppTheme.sans(13, color: AppColors.muted)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: Text(t.adminDecline,
                              style: AppTheme.sans(13,
                                  weight: FontWeight.w700,
                                  color: AppColors.errorRed)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  final ok = await provider.declineCompany(company.id);
                  messenger.showSnackBar(
                    appSnack(ok ? t.adminDeclined : t.adminActionFailed,
                        isError: !ok),
                  );
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.errorRed, size: 17),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Agency detail for the admin: identity header + Info / Trips / Money tabs.
/// The star in the title row toggles homepage promotion; the Money tab is the
/// agency's slice of the commission ledger.
class AdminAgencyDetailScreen extends StatefulWidget {
  final String companyId;
  const AdminAgencyDetailScreen({super.key, required this.companyId});

  @override
  State<AdminAgencyDetailScreen> createState() =>
      _AdminAgencyDetailScreenState();
}

class _AdminAgencyDetailScreenState extends State<AdminAgencyDetailScreen> {
  final Set<String> _loadingIds = {};

  Future<void> _togglePromoted(Company company) async {
    if (_loadingIds.contains(company.id)) return;
    setState(() => _loadingIds.add(company.id));
    final ok = await context
        .read<AppProvider>()
        .setCompanyPromoted(company.id, !company.isPromoted);
    if (mounted) {
      setState(() => _loadingIds.remove(company.id));
      if (!ok) {
        showAppSnack(context, AppLocalizations.of(context).adminActionFailed,
            isError: true);
      }
    }
  }

  Future<void> _toggleFeatured(Offer offer) async {
    if (_loadingIds.contains(offer.id)) return;
    setState(() => _loadingIds.add(offer.id));
    final ok = await context
        .read<AppProvider>()
        .setOfferFeatured(offer.id, !offer.isFeatured);
    if (mounted) {
      setState(() => _loadingIds.remove(offer.id));
      if (!ok) {
        showAppSnack(context, AppLocalizations.of(context).adminActionFailed,
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;
    final company = provider.companyById(widget.companyId);
    if (company == null) return const SizedBox.shrink();

    final offers = provider.getCompanyOffers(company.id);
    final commissions = provider.commissions
        .where((c) => c.companyId == company.id)
        .toList();
    final owed = commissions
        .where((c) => c.status == 'owed')
        .fold(0.0, (s, c) => s + c.amount);

    return DetailTabScaffold(
      title: company.nameFor(lang),
      titleTrailing: InteractiveScale(
        onTap: _loadingIds.contains(company.id)
            ? null
            : () => _togglePromoted(company),
        child: SizedBox(
          width: 42,
          height: 42,
          child: _loadingIds.contains(company.id)
              ? const Center(
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2)))
              : Icon(
                  company.isPromoted
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: company.isPromoted
                      ? AppColors.gold
                      : AppColors.mutedLight,
                  size: 26,
                ),
        ),
      ),
      header: Row(
        children: [
          CompanyAvatar(
            mono: company.mono,
            tint: company.tint,
            logoUrl: company.logoUrl,
            size: 56,
            fontSize: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company.location,
                    style: AppTheme.sans(12.5, color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(
                  children: [
                    StatusChip(
                      kind: company.isVerified
                          ? StatusKind.positive
                          : StatusKind.pending,
                      label: company.isVerified
                          ? t.adminFilterActive
                          : t.adminStatPending,
                    ),
                    const SizedBox(width: 8),
                    StarRating(rating: company.rating, size: 13),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      tabs: [t.adminInfoTab, t.promoteTabTrips, t.adminActionFinance],
      views: [
        // ── Info ──
        ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(
              kDashPagePad, kDashCardGap, kDashPagePad, 24),
          children: [
            if (company.about.isNotEmpty) ...[
              Text(company.about,
                  style: AppTheme.sans(13.5, color: AppColors.inkLight)),
              const SizedBox(height: 14),
            ],
            if (company.tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in company.tags) InfoChip(label: tag),
                ],
              ),
            const SizedBox(height: 14),
            InfoChip(label: '${company.since}'),
          ],
        ),
        // ── Trips ──
        offers.isEmpty
            ? EmptyState(icon: Icons.luggage_rounded, title: t.promoteNoTrips)
            : ListView.separated(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    kDashPagePad, kDashCardGap, kDashPagePad, 24),
                itemCount: offers.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: kDashCardGap),
                itemBuilder: (context, i) {
                  final offer = offers[i];
                  return EntityListCard(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 44,
                        child: OfferImage(offer: offer, height: 44),
                      ),
                    ),
                    title: offer.titleFor(lang),
                    subtitle: offer.priceFmt,
                    trailing: InteractiveScale(
                      onTap: _loadingIds.contains(offer.id)
                          ? null
                          : () => _toggleFeatured(offer),
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: _loadingIds.contains(offer.id)
                            ? const Center(
                                child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: AppColors.gold,
                                        strokeWidth: 2)))
                            : Icon(
                                offer.isFeatured
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: offer.isFeatured
                                    ? AppColors.gold
                                    : AppColors.mutedLight,
                                size: 24,
                              ),
                      ),
                    ),
                  );
                },
              ),
        // ── Money ──
        commissions.isEmpty
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: t.adminCommissionsEmptyTitle,
                body: t.adminCommissionsEmptyBody)
            : ListView(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    kDashPagePad, kDashCardGap, kDashPagePad, 24),
                children: [
                  CommissionSummaryCard(
                      label: t.adminCommissionsOwedLabel, amount: owed),
                  const SizedBox(height: 14),
                  for (final c in commissions)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: kDashCardGap),
                      child:
                          CommissionRow(commission: c, showCompanyName: false),
                    ),
                ],
              ),
      ],
    );
  }
}
