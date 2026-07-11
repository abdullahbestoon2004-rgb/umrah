import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/home_ad_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/company_avatar.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/entity_list_card.dart';
import '../../widgets/dashboard/empty_state.dart';
import '../../widgets/dashboard/section_header.dart';
import '../../l10n/generated/app_localizations.dart';
import 'promote_screen.dart';
import 'home_preview_screen.dart';

/// Everything the client home screen shows, in the home screen's visual
/// order: the paid ads carousel, then promoted agencies, then featured trips.
/// The floating preview button renders the real client home in any language.
class AdminContentTab extends StatelessWidget {
  const AdminContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;
    final promoted =
        provider.companies.where((c) => c.isPromoted).toList();
    final featured =
        provider.allOffers.where((o) => o.isFeatured).toList();

    return DashboardScaffold(
      title: t.tabContent,
      onRefresh: () => context.read<AppProvider>().loadAdminData(),
      floatingAction: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HomePreviewScreen())),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 13, 18, 13),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(t.contentPreviewHome,
                  style: AppTheme.sans(13,
                      weight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
      slivers: [
        // ── Carousel ads ──
        SliverToBoxAdapter(
          child: SectionHeader(
            title: t.adminHomeAds,
            count: provider.allHomeAds.length,
            firstSection: true,
            trailing: GestureDetector(
              onTap: () => _openAddAd(context),
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 9, 14, 9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(t.adminAddAd,
                        style: AppTheme.sans(13,
                            weight: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (provider.allHomeAds.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
                icon: Icons.campaign_rounded,
                title: t.adminNoAds,
                compact: true),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    kDashPagePad, 0, kDashPagePad, kDashCardGap),
                child: AdRow(ad: provider.allHomeAds[i]),
              ),
              childCount: provider.allHomeAds.length,
            ),
          ),

        // ── Promoted agencies (home "Top Agencies" strip) ──
        SliverToBoxAdapter(
          child: SectionHeader(
            title: t.homeTopAgencies,
            count: promoted.length,
            onViewAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PromoteScreen(initialTab: 1))),
          ),
        ),
        if (promoted.isEmpty)
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
                final company = promoted[i];
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      kDashPagePad, 0, kDashPagePad, kDashCardGap),
                  child: EntityListCard(
                    leading: CompanyAvatar(
                      mono: company.mono,
                      tint: company.tint,
                      logoUrl: company.logoUrl,
                      size: 40,
                      fontSize: 15,
                      borderRadius: 10,
                    ),
                    title: company.nameFor(lang),
                    subtitle: company.location,
                    trailing: const Icon(Icons.star_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                );
              },
              childCount: promoted.length,
            ),
          ),

        // ── Featured trips (home featured strip) ──
        SliverToBoxAdapter(
          child: SectionHeader(
            title: t.promoteTabTrips,
            count: featured.length,
            accent: AppColors.gold,
            onViewAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PromoteScreen(initialTab: 0))),
          ),
        ),
        if (featured.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
                icon: Icons.auto_awesome_rounded,
                title: t.promoteNoTrips,
                compact: true),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final offer = featured[i];
                final companyName =
                    provider.companyById(offer.companyId)?.nameFor(lang) ?? '';
                return Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      kDashPagePad, 0, kDashPagePad, kDashCardGap),
                  child: EntityListCard(
                    title: offer.titleFor(lang),
                    subtitle: companyName.isEmpty
                        ? offer.priceFmt
                        : '$companyName · ${offer.priceFmt}',
                    trailing: const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 22),
                  ),
                );
              },
              childCount: featured.length,
            ),
          ),
      ],
    );
  }

  void _openAddAd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: const AddAdSheet(),
      ),
    );
  }
}

/// One carousel ad: thumbnail, title, live toggle, delete.
class AdRow extends StatelessWidget {
  final HomeAd ad;
  const AdRow({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 44,
              child: (ad.imageUrl ?? '').isNotEmpty
                  ? Image.network(
                      ad.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: AppColors.primary.withOpacity(0.15)),
                    )
                  : Container(
                      color: AppColors.primary.withOpacity(0.12),
                      child: const Icon(Icons.campaign_rounded,
                          color: AppColors.primary, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ad.titleFor(lang),
              style: AppTheme.sans(13.5, weight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            value: ad.isActive,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: (v) async {
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.setAdActive(ad.id, v);
              if (!ok) {
                messenger.showSnackBar(
                  appSnack(t.adminActionFailed, isError: true),
                );
              }
            },
          ),
          GestureDetector(
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(t.adminDeleteAdTitle, style: AppTheme.serif(20)),
                  content: Text(t.adminDeleteAdBody,
                      style: AppTheme.sans(13, color: AppColors.inkLight)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, false),
                      child: Text(t.agencyDashboardCancel,
                          style: AppTheme.sans(13, color: AppColors.muted)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      child: Text(t.adminDeleteAdConfirm,
                          style: AppTheme.sans(13,
                              weight: FontWeight.w700,
                              color: AppColors.errorRed)),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              final ok = await provider.deleteHomeAd(ad.id);
              if (!ok) {
                messenger.showSnackBar(
                  appSnack(t.adminActionFailed, isError: true),
                );
              }
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.errorRed, size: 17),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add-ad sheet ──────────────────────────────────────────────────────────────

class AddAdSheet extends StatefulWidget {
  const AddAdSheet({super.key});

  @override
  State<AddAdSheet> createState() => _AddAdSheetState();
}

class _AddAdSheetState extends State<AddAdSheet> {
  final _titleCtrl = TextEditingController();
  String? _packageId;
  String? _companyId;
  Uint8List? _imageBytes;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _imageBytes = bytes);
  }

  Future<void> _save() async {
    if (_saving) return;
    final t = AppLocalizations.of(context);
    if (_titleCtrl.text.trim().isEmpty) {
      showAppSnack(context, t.authErrFillAll, isError: true);
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<AppProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.createHomeAd(
      title: _titleCtrl.text.trim(),
      packageId: _packageId,
      companyId: _companyId,
      imageBytes: _imageBytes,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false);
      messenger.showSnackBar(appSnack(t.adminActionFailed, isError: true));
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(appSnack(t.adminAdCreated));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(22, 14, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(t.adminAddAd, style: AppTheme.serif(24)),
            const SizedBox(height: 18),

            Text(t.adminAdTitle,
                style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: TextField(
                controller: _titleCtrl,
                style: AppTheme.sans(14),
                decoration: InputDecoration(
                  hintText: t.adminAdTitleHint,
                  hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
                  prefixIcon: const Icon(Icons.campaign_rounded,
                      color: AppColors.primary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(t.adminLinkPackage,
                style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsetsDirectional.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _packageId,
                  isExpanded: true,
                  style: AppTheme.sans(14),
                  dropdownColor: AppColors.background,
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(t.adminNoLink,
                          style: AppTheme.sans(14, color: AppColors.muted)),
                    ),
                    for (final o in provider.allOffers)
                      DropdownMenuItem<String?>(
                        value: o.id,
                        child: Text(o.titleFor(lang),
                            style: AppTheme.sans(14),
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  // An ad leads to one place, so picking a trip clears any
                  // chosen company and vice versa.
                  onChanged: (v) => setState(() {
                    _packageId = v;
                    if (v != null) _companyId = null;
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(t.adminLinkCompany,
                style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsetsDirectional.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _companyId,
                  isExpanded: true,
                  style: AppTheme.sans(14),
                  dropdownColor: AppColors.background,
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(t.adminNoLink,
                          style: AppTheme.sans(14, color: AppColors.muted)),
                    ),
                    for (final c in provider.companies)
                      DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.nameFor(lang),
                            style: AppTheme.sans(14),
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() {
                    _companyId = v;
                    if (v != null) _packageId = null;
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(t.adminAdImage,
                style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.primary, size: 28),
                          const SizedBox(height: 6),
                          Text(t.adminPickImage,
                              style: AppTheme.sans(12,
                                  color: AppColors.muted)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 22),
            GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(t.adminAddAd,
                        style: AppTheme.sans(14,
                            weight: FontWeight.w800,
                            color: const Color(0xFFF6F2E9))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
