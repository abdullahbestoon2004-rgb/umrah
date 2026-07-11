import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart';
import '../../models/company_model.dart';
import '../../widgets/company_avatar.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/interactive_scale.dart';
import '../../widgets/app_snackbar.dart';
import '../../l10n/generated/app_localizations.dart';

class PromoteScreen extends StatefulWidget {
  /// 0 = trips tab, 1 = agencies tab.
  final int initialTab;
  const PromoteScreen({super.key, this.initialTab = 0});

  @override
  State<PromoteScreen> createState() => _PromoteScreenState();
}

class _PromoteScreenState extends State<PromoteScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final Set<String> _loadingIds = {};

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      setState(() {
        _searchCtrl.clear();
        _searchQuery = '';
      });
    });
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleOfferPromoted(Offer offer) async {
    final id = offer.id;
    if (_loadingIds.contains(id)) return;
    setState(() => _loadingIds.add(id));

    final provider = context.read<AppProvider>();
    final ok = await provider.setOfferFeatured(id, !offer.isFeatured);

    if (mounted) {
      setState(() => _loadingIds.remove(id));
      // A failed save (missing DB patch, RLS, network) must never look like
      // a successful tap that just didn't stick.
      if (!ok) {
        showAppSnack(context, AppLocalizations.of(context).adminActionFailed,
            isError: true);
      }
    }
  }

  Future<void> _toggleCompanyPromoted(Company company) async {
    final id = company.id;
    if (_loadingIds.contains(id)) return;
    setState(() => _loadingIds.add(id));

    final provider = context.read<AppProvider>();
    final ok = await provider.setCompanyPromoted(id, !company.isPromoted);

    if (mounted) {
      setState(() => _loadingIds.remove(id));
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

    // Filter Trips
    final filteredOffers = provider.allOffers.where((offer) {
      final title = offer.titleFor(lang).toLowerCase();
      final company = provider.companyById(offer.companyId)?.nameFor(lang).toLowerCase() ?? '';
      return title.contains(_searchQuery) || company.contains(_searchQuery);
    }).toList();

    // Filter Companies
    final filteredCompanies = provider.companies.where((company) {
      final name = company.nameFor(lang).toLowerCase();
      final location = company.location.toLowerCase();
      return name.contains(_searchQuery) || location.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            const IslamicPattern(opacity: 0.03, isEightFold: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          t.promoteScreenTitle,
                          style: AppTheme.serif(24),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Search Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: AppTheme.sans(14.5),
                      decoration: InputDecoration(
                        hintText: _tabController.index == 0
                            ? t.promoteSearchTrips
                            : t.promoteSearchAgencies,
                        hintStyle: AppTheme.sans(14.5, color: AppColors.mutedLight),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _searchCtrl.clear(),
                                child: const Icon(Icons.clear_rounded, color: AppColors.muted, size: 20),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tab Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.muted,
                      labelStyle: AppTheme.sans(13.5, weight: FontWeight.w700),
                      unselectedLabelStyle: AppTheme.sans(13.5, weight: FontWeight.w600),
                      tabs: [
                        Tab(text: t.promoteTabTrips),
                        Tab(text: t.promoteTabAgencies),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tab Contents ──
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Trips List ──
                      _buildOffersTab(filteredOffers, lang, provider),

                      // ── Companies List ──
                      _buildCompaniesTab(filteredCompanies, lang),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersTab(List<Offer> offers, String lang, AppProvider provider) {
    if (offers.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).promoteNoTrips,
            style: AppTheme.sans(14, color: AppColors.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: offers.length,
      itemBuilder: (context, i) {
        final offer = offers[i];
        final companyName = provider.companyById(offer.companyId)?.nameFor(lang) ?? '';
        final isLoading = _loadingIds.contains(offer.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: offer.isFeatured ? AppColors.gold : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.titleFor(lang),
                        style: AppTheme.sans(14, weight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        companyName.isEmpty
                            ? offer.priceFmt
                            : '$companyName · ${offer.priceFmt}',
                        style: AppTheme.sans(11.5, color: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InteractiveScale(
                  onTap: isLoading ? null : () => _toggleOfferPromoted(offer),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
                          )
                        : Icon(
                            offer.isFeatured ? Icons.star_rounded : Icons.star_border_rounded,
                            color: offer.isFeatured ? AppColors.gold : AppColors.mutedLight,
                            size: 26,
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompaniesTab(List<Company> companies, String lang) {
    if (companies.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context).promoteNoAgencies,
            style: AppTheme.sans(14, color: AppColors.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: companies.length,
      itemBuilder: (context, i) {
        final company = companies[i];
        final isLoading = _loadingIds.contains(company.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: company.isPromoted ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                CompanyAvatar(
                  mono: company.mono,
                  tint: company.tint,
                  logoUrl: company.logoUrl,
                  size: 40,
                  fontSize: 15,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.nameFor(lang),
                        style: AppTheme.sans(14, weight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        company.location,
                        style: AppTheme.sans(11.5, color: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InteractiveScale(
                  onTap: isLoading ? null : () => _toggleCompanyPromoted(company),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                          )
                        : Icon(
                            company.isPromoted ? Icons.star_rounded : Icons.star_border_rounded,
                            color: company.isPromoted ? AppColors.primary : AppColors.mutedLight,
                            size: 26,
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
