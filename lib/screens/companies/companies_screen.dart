import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../models/company_model.dart';
import '../../models/offer_model.dart';
import '../../providers/app_provider.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/company_avatar.dart';
import 'company_detail_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/interactive_scale.dart';
import '../../widgets/tag_chip.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () =>
          setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Company company, String lang, AppProvider provider) {
    final matchesQuery =
        _query.isEmpty ||
        company.nameFor(lang).toLowerCase().contains(_query) ||
        company.location.toLowerCase().contains(_query);
    if (!matchesQuery) return false;

    switch (_filter) {
      case 'verified':
        return company.isVerified;
      case 'topRated':
        return company.rating >= 4.5;
      case 'promoted':
        return company.isPromoted;
      case 'packages':
        return provider.getCompanyOffers(company.id).isNotEmpty;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;
    final companies = provider.companies
        .where((company) => _matches(company, lang, provider))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const IslamicPattern(opacity: 0.04, isEightFold: true),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                t.companiesTitle,
                                style: AppTheme.serif(30),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showFilters(context, t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.tune_rounded,
                                      color: Color(0xFFF6F2E9),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      t.offersFilters,
                                      style: AppTheme.sans(
                                        13,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFFF6F2E9),
                                      ),
                                    ),
                                    if (_filter != 'all') ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold,
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: Text(
                                          '1',
                                          style: AppTheme.sans(
                                            11,
                                            weight: FontWeight.w800,
                                            color: const Color(0xFF1C2317),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t.companiesSubtitle(companies.length),
                          style: AppTheme.sans(
                            13,
                            color: const Color(0xFF7D8A82),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTheme.sans(14),
                            decoration: InputDecoration(
                              hintText: t.companiesSearchHint,
                              hintStyle: AppTheme.sans(
                                14,
                                color: AppColors.mutedLight,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: _searchController.clear,
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.muted,
                                        size: 18,
                                      ),
                                    ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                    14,
                                    13,
                                    14,
                                    13,
                                  ),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        22,
                        5,
                        22,
                        7,
                      ),
                      children: [
                        _CompanyFilterChip(
                          label: t.offersAll,
                          active: _filter == 'all',
                          onTap: () => setState(() => _filter = 'all'),
                        ),
                        _CompanyFilterChip(
                          label: t.companiesFilterVerified,
                          icon: Icons.verified_rounded,
                          active: _filter == 'verified',
                          onTap: () => setState(() => _filter = 'verified'),
                        ),
                        _CompanyFilterChip(
                          label: t.companiesFilterTopRated,
                          icon: Icons.star_rounded,
                          active: _filter == 'topRated',
                          onTap: () => setState(() => _filter = 'topRated'),
                        ),
                        _CompanyFilterChip(
                          label: t.companiesFilterPromoted,
                          icon: Icons.workspace_premium_rounded,
                          active: _filter == 'promoted',
                          onTap: () => setState(() => _filter = 'promoted'),
                        ),
                        _CompanyFilterChip(
                          label: t.companiesFilterWithPackages,
                          icon: Icons.luggage_rounded,
                          active: _filter == 'packages',
                          onTap: () => setState(() => _filter = 'packages'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (companies.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 38,
                              color: AppColors.mutedLight,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t.companiesNoMatches,
                              style: AppTheme.serif(21),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              t.companiesTryDifferentSearch,
                              textAlign: TextAlign.center,
                              style: AppTheme.sans(13, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          22,
                          0,
                          22,
                          i < companies.length - 1 ? 13 : 24,
                        ),
                        child: _CompanyListCard(company: companies[i]),
                      );
                    }, childCount: companies.length),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context, AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CompanyFilterSheet(
        selected: _filter,
        labels: {
          'all': t.offersAll,
          'verified': t.companiesFilterVerified,
          'topRated': t.companiesFilterTopRated,
          'promoted': t.companiesFilterPromoted,
          'packages': t.companiesFilterWithPackages,
        },
        onSelect: (filter) {
          setState(() => _filter = filter);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }
}

class _CompanyFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _CompanyFilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 9),
    child: TagChip(label: label, icon: icon, active: active, onTap: onTap),
  );
}

class _CompanyFilterSheet extends StatelessWidget {
  final String selected;
  final Map<String, String> labels;
  final ValueChanged<String> onSelect;

  const _CompanyFilterSheet({
    required this.selected,
    required this.labels,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppLocalizations.of(context).offersFilters,
            style: AppTheme.serif(24),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: labels.entries
                .map(
                  (entry) => TagChip(
                    label: entry.value,
                    active: entry.key == selected,
                    onTap: () => onSelect(entry.key),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ),
  );
}

class _CompanyListCard extends StatelessWidget {
  final Company company;
  const _CompanyListCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final offers = context.watch<AppProvider>().getCompanyOffers(company.id);
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
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── brand-colour / photo header ──────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(21),
              ),
              child: SizedBox(
                height: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: company.tint),
                    if ((company.bannerUrl ?? '').isNotEmpty)
                      Image.network(company.bannerUrl!, fit: BoxFit.cover),
                    // Keep the agency brand colour visible even when a
                    // background photo has been added.
                    if ((company.bannerUrl ?? '').isNotEmpty)
                      Container(color: company.tint.withValues(alpha: 0.48)),
                    const IslamicPattern(opacity: 0.08, cell: 46),
                    // A uniform scrim preserves contrast without changing
                    // the selected background into a gradient.
                    Container(color: Colors.black.withValues(alpha: 0.16)),
                    // verified badge — top left
                    if (company.isVerified)
                      Positioned(
                        left: 14,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 10,
                                color: Color(0xFF1C2317),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t.companiesVerifiedBadge,
                                style: AppTheme.sans(
                                  9,
                                  weight: FontWeight.w800,
                                  color: const Color(0xFF1C2317),
                                ).copyWith(letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // logo (or mono fallback) — top right
                    Positioned(
                      top: 12,
                      right: 14,
                      child: (company.logoUrl ?? '').isNotEmpty
                          ? CompanyAvatar(
                              mono: company.mono,
                              tint: company.tint,
                              logoUrl: company.logoUrl,
                              size: 44,
                              fontSize: 20,
                              borderRadius: 13,
                            )
                          : Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Center(
                                child: Text(
                                  company.mono,
                                  style: AppTheme.sans(
                                    20,
                                    weight: FontWeight.w800,
                                    color: company.tint,
                                  ),
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
                            company.nameFor(
                              Localizations.localeOf(context).languageCode,
                            ),
                            style: AppTheme.serif(21, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            t.companiesLocationEst(
                              company.location,
                              company.since,
                            ),
                            style: AppTheme.sans(
                              10.5,
                              weight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.78),
                            ),
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
                  Text(
                    '${company.rating}',
                    style: AppTheme.sans(
                      12.5,
                      weight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '·',
                    style: AppTheme.sans(13, color: AppColors.mutedLight),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.companiesPackageCount(offerCount),
                    style: AppTheme.sans(
                      12.5,
                      weight: FontWeight.w600,
                      color: AppColors.inkLight,
                    ),
                  ),
                  const Spacer(),
                  if (fromPrice > 0) ...[
                    Text(
                      t.companiesFromPrefix,
                      style: AppTheme.sans(11, color: AppColors.muted),
                    ),
                    Text(
                      fmtIqd(fromPrice),
                      style: AppTheme.serif(17, color: AppColors.primary),
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
