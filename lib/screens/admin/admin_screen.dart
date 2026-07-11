import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/company_model.dart';
import '../../models/home_ad_model.dart';
import '../../models/support_message_model.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/tag_chip.dart';
import '../../l10n/generated/app_localizations.dart';
import '../agency/agency_bookings_screen.dart' show CommissionLedger;
import 'promote_screen.dart';

/// Owner-only control panel: approve agencies, manage the paid home-ads
/// carousel, and pick which offers are featured on the home screen.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AppProvider>().loadAdminData());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    if (!provider.isAdminUser) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<AppProvider>().loadAdminData(),
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _AdminHeader(provider: provider)),

          // ── Pending agencies (time-sensitive, so first) ─────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
              child: Text(t.adminPendingAgencies, style: AppTheme.serif(20)),
            ),
          ),
          if (provider.pendingCompanies.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(t.adminNoPending, style: AppTheme.sans(13, color: AppColors.muted)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: _PendingCompanyCard(company: provider.pendingCompanies[i]),
                ),
                childCount: provider.pendingCompanies.length,
              ),
            ),

          // ── Manage: promotions + commissions ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
              child: Text(t.adminSectionManage, style: AppTheme.serif(20)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PromoteScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF16816B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.adminPromoteTitle,
                              style: AppTheme.serif(18, color: Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t.adminPromoteSubtitle,
                              style: AppTheme.sans(11.5, color: Colors.white.withOpacity(0.85)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCommissionsScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.adminCommissionsTitle, style: AppTheme.serif(18)),
                            const SizedBox(height: 3),
                            Text(
                              t.adminCommissionsCardSubtitle,
                              style: AppTheme.sans(11.5, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.muted, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Home ads ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
              child: Row(
                children: [
                  Expanded(child: Text(t.adminHomeAds, style: AppTheme.serif(20))),
                  GestureDetector(
                    onTap: () => _openAddAd(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                          color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(t.adminAddAd,
                            style: AppTheme.sans(13, weight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (provider.allHomeAds.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(t.adminNoAds, style: AppTheme.sans(13, color: AppColors.muted)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: _AdRow(ad: provider.allHomeAds[i]),
                ),
                childCount: provider.allHomeAds.length,
              ),
            ),

          // ── Support messages inbox ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
              child: Row(
                children: [
                  Expanded(child: Text(t.adminSupportInbox, style: AppTheme.serif(20))),
                  if (provider.supportMessages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: Text('${provider.supportMessages.length}',
                          style: AppTheme.sans(11, weight: FontWeight.w700, color: Colors.white)),
                    ),
                ],
              ),
            ),
          ),
          if (provider.supportMessages.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(t.adminSupportEmpty, style: AppTheme.sans(13, color: AppColors.muted)),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
                  child: _SupportRow(message: provider.supportMessages[i]),
                ),
                childCount: provider.supportMessages.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
        ),
      ),
    );
  }

  void _openAddAd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AppProvider>(),
        child: const _AddAdSheet(),
      ),
    );
  }
}

/// Full-height commission ledger for every agency, pushed from the admin
/// dashboard so the list scrolls on its own instead of inside the page scroll.
class AdminCommissionsScreen extends StatefulWidget {
  const AdminCommissionsScreen({super.key});

  @override
  State<AdminCommissionsScreen> createState() => _AdminCommissionsScreenState();
}

class _AdminCommissionsScreenState extends State<AdminCommissionsScreen> {
  String _filter = 'all'; // 'all' | 'owed' | 'collected'

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final commissions = _filter == 'all'
        ? provider.commissions
        : provider.commissions.where((c) => c.status == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(t.adminCommissionsTitle, style: AppTheme.serif(24)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TagChip(
                    label: t.adminFilterAll,
                    active: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  TagChip(
                    label: t.adminCommissionsOwed,
                    active: _filter == 'owed',
                    onTap: () => setState(() => _filter = 'owed'),
                  ),
                  const SizedBox(width: 8),
                  TagChip(
                    label: t.adminCommissionsCollected,
                    active: _filter == 'collected',
                    onTap: () => setState(() => _filter = 'collected'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<AppProvider>().loadCommissions(),
                child: CommissionLedger(
                  commissions: commissions,
                  // The "total owed" banner only makes sense over the full list.
                  showSummary: _filter == 'all',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final AppProvider provider;
  const _AdminHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned.fill(child: IslamicPattern(opacity: 0.06, cell: 72)),
            Padding(
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
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(13)),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          provider.signOut();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(13)),
                          child: const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.adminTitle, style: AppTheme.serif(24, color: Colors.white)),
                            const SizedBox(height: 3),
                            Text(provider.user?.email ?? '',
                                style: AppTheme.sans(12, color: Colors.white.withOpacity(0.75)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        _AdminStat(
                            value: '${provider.pendingCompanies.length}',
                            label: t.adminStatPending),
                        _AdminStatDivider(),
                        _AdminStat(
                            value: _compactIqd(provider.commissionsOwed),
                            label: t.adminStatOwed,
                            onTap: () => _openCommissions(context)),
                        _AdminStatDivider(),
                        _AdminStat(
                            value: _compactIqd(provider.commissionsCollected),
                            label: t.adminStatCollected,
                            onTap: () => _openCommissions(context)),
                      ],
                    ),
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

/// Compact IQD for the small header stat cells: 1_200_000 → "1.2M", 45_000 → "45K".
String _compactIqd(double n) {
  if (n >= 1000000) {
    final m = n / 1000000;
    return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
  }
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
  return n.toStringAsFixed(0);
}

void _openCommissions(BuildContext context) => Navigator.push(
    context, MaterialPageRoute(builder: (_) => const AdminCommissionsScreen()));

class _AdminStat extends StatelessWidget {
  final String value, label;
  final VoidCallback? onTap;
  const _AdminStat({required this.value, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Column(children: [
              Text(value, style: AppTheme.serif(21, color: Colors.white)),
              const SizedBox(height: 2),
              Text(label,
                  style: AppTheme.sans(10.5, color: Colors.white.withOpacity(0.7)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ),
      );
}

class _AdminStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: Colors.white.withOpacity(0.15));
}

class _PendingCompanyCard extends StatelessWidget {
  final Company company;
  const _PendingCompanyCard({required this.company});

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
                Text(company.nameFor(lang), style: AppTheme.sans(14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(company.location, style: AppTheme.sans(12, color: AppColors.muted)),
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
                  messenger.showSnackBar(appSnack(
                      ok ? t.adminApproved : t.adminActionFailed,
                      isError: !ok));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                      color: AppColors.primary, borderRadius: BorderRadius.circular(11)),
                  child: Text(t.adminApprove,
                      style: AppTheme.sans(12.5, weight: FontWeight.w700, color: Colors.white)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(t.adminDeclineTitle, style: AppTheme.serif(20)),
                      content: Text(t.adminDeclineBody, style: AppTheme.sans(13, color: AppColors.inkLight)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: Text(t.agencyDashboardCancel, style: AppTheme.sans(13, color: AppColors.muted)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: Text(t.adminDecline,
                              style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.errorRed)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  final ok = await provider.declineCompany(company.id);
                  messenger.showSnackBar(appSnack(
                      ok ? t.adminDeclined : t.adminActionFailed,
                      isError: !ok));
                },
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
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

class _AdRow extends StatelessWidget {
  final HomeAd ad;
  const _AdRow({required this.ad});

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
              width: 64, height: 44,
              child: (ad.imageUrl ?? '').isNotEmpty
                  ? Image.network(ad.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.primary.withOpacity(0.15)))
                  : Container(
                      color: AppColors.primary.withOpacity(0.12),
                      child: const Icon(Icons.campaign_rounded,
                          color: AppColors.primary, size: 22),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(ad.titleFor(lang),
                style: AppTheme.sans(13.5, weight: FontWeight.w700),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          Switch(
            value: ad.isActive,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            onChanged: (v) => provider.setAdActive(ad.id, v),
          ),
          GestureDetector(
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(t.adminDeleteAdTitle, style: AppTheme.serif(20)),
                  content: Text(t.adminDeleteAdBody, style: AppTheme.sans(13, color: AppColors.inkLight)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, false),
                      child: Text(t.agencyDashboardCancel, style: AppTheme.sans(13, color: AppColors.muted)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx, true),
                      child: Text(t.adminDeleteAdConfirm,
                          style: AppTheme.sans(13, weight: FontWeight.w700, color: AppColors.errorRed)),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              final ok = await provider.deleteHomeAd(ad.id);
              if (!ok) messenger.showSnackBar(appSnack(t.adminActionFailed, isError: true));
            },
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.errorRed, size: 17),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportRow extends StatelessWidget {
  final SupportMessage message;
  const _SupportRow({required this.message});

  String _timeAgo(AppLocalizations t) {
    final diff = DateTime.now().difference(message.createdAt);
    if (diff.inMinutes < 1) return t.notifJustNow;
    if (diff.inHours < 1) return t.notifMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return t.notifHoursAgo(diff.inHours);
    return t.notifDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final email = message.email ?? '';
    final sender = email.isNotEmpty ? email : t.adminSupportAnonymous;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                // The sender's address is the only way to reply, so make it
                // grabbable: tap copies it to the clipboard.
                child: GestureDetector(
                  onTap: email.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: email));
                          showAppSnack(context, t.emailCopied);
                        },
                  child: Text(sender,
                      style: AppTheme.sans(12.5, weight: FontWeight.w700, color: AppColors.primary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
              Text(_timeAgo(t), style: AppTheme.sans(11, color: AppColors.mutedLight)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await context
                      .read<AppProvider>()
                      .deleteSupportMessage(message.id);
                  messenger.showSnackBar(appSnack(
                      ok ? t.adminSupportResolved : t.adminActionFailed,
                      isError: !ok));
                },
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.primary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message.message, style: AppTheme.sans(13.5, color: AppColors.ink)),
        ],
      ),
    );
  }
}

// ── Add-ad sheet ──────────────────────────────────────────────────────────────

class _AddAdSheet extends StatefulWidget {
  const _AddAdSheet();

  @override
  State<_AddAdSheet> createState() => _AddAdSheetState();
}

class _AddAdSheetState extends State<_AddAdSheet> {
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
    final xfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42, height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(t.adminAddAd, style: AppTheme.serif(24)),
            const SizedBox(height: 18),

            Text(t.adminAdTitle, style: AppTheme.sans(13, weight: FontWeight.w700)),
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
                  prefixIcon: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(t.adminLinkPackage, style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
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
                      child: Text(t.adminNoLink, style: AppTheme.sans(14, color: AppColors.muted)),
                    ),
                    for (final o in provider.allOffers)
                      DropdownMenuItem<String?>(
                        value: o.id,
                        child: Text(o.titleFor(lang),
                            style: AppTheme.sans(14), overflow: TextOverflow.ellipsis),
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
            Text(t.adminLinkCompany, style: AppTheme.sans(13, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
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
                      child: Text(t.adminNoLink, style: AppTheme.sans(14, color: AppColors.muted)),
                    ),
                    for (final c in provider.companies)
                      DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.nameFor(lang),
                            style: AppTheme.sans(14), overflow: TextOverflow.ellipsis),
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
            Text(t.adminAdImage, style: AppTheme.sans(13, weight: FontWeight.w700)),
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
                              style: AppTheme.sans(12, color: AppColors.muted)),
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
                    color: AppColors.primary, borderRadius: BorderRadius.circular(15)),
                alignment: Alignment.center,
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(t.adminAddAd,
                        style: AppTheme.sans(14, weight: FontWeight.w800, color: const Color(0xFFF6F2E9))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
