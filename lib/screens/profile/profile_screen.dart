import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/offer_model.dart';
import '../../widgets/offer_image.dart';
import '../../widgets/islamic_pattern.dart';
import '../../widgets/star_rating.dart';
import '../../l10n/generated/app_localizations.dart';
import '../agency/agency_login_screen.dart';
import '../agency/agency_dashboard_screen.dart';
import '../offers/offer_detail_screen.dart';
import 'notifications_screen.dart';
import 'payment_methods_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';
import '../auth/auth_screen.dart';
import '../../widgets/app_snackbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _ProfileHeader(provider: provider)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!provider.isSignedIn) ...[
                  _SignInBanner(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                  ),
                  const SizedBox(height: 18),
                ],
                _MenuCard(
                  icon: Icons.favorite_border_rounded,
                  label: t.profileSavedTrips,
                  badge: provider.saved.isEmpty ? null : '${provider.saved.length}',
                  onTap: () => _openSaved(context, provider),
                ),
                const SizedBox(height: 10),
                _MenuCard(
                  icon: Icons.calendar_month_rounded,
                  label: t.profileMyBookings,
                  badge: provider.bookings.isEmpty ? null : '${provider.bookings.length}',
                  onTap: () => provider.setTab(3),
                ),
                const SizedBox(height: 10),
                _MenuCard(
                  icon: Icons.notifications_outlined,
                  label: t.profileNotifications,
                  badge: provider.unreadNotifications == 0 ? null : '${provider.unreadNotifications}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
                const SizedBox(height: 10),
                _MenuCard(
                  icon: Icons.credit_card_rounded,
                  label: t.profilePaymentMethods,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                ),
                const SizedBox(height: 10),
                _MenuCard(
                  icon: Icons.language_rounded,
                  label: t.profileLanguage,
                  onTap: () => _openLanguagePicker(context, provider),
                ),
                const SizedBox(height: 10),
                _MenuCard(
                  icon: Icons.lock_outline_rounded,
                  label: t.profilePrivacySecurity,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen())),
                ),
                const SizedBox(height: 10),
                _MenuCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: t.profileHelpSupport,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                ),
                if (provider.isSignedIn) ...[
                  const SizedBox(height: 10),
                  _MenuCard(
                    icon: Icons.logout_rounded,
                    label: t.profileSignOut,
                    tint: AppColors.errorRed,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await provider.signOut();
                      messenger.showSnackBar(appSnack(t.profileSignedOut));
                    },
                  ),
                ],
                const SizedBox(height: 18),
                // Agency portal divider
                Row(children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t.profileAgencyDivider, style: AppTheme.sans(11, weight: FontWeight.w700, color: AppColors.muted)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ]),
                const SizedBox(height: 14),
                _MenuCard(
                  icon: Icons.business_center_rounded,
                  label: provider.isAgencyLoggedIn
                      ? t.profileAgencyDashboardWithName(provider.agencyCompany?.name ?? '')
                      : t.profileAgencyPortal,
                  tint: AppColors.primary,
                  onTap: () {
                    if (provider.isAgencyLoggedIn) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AgencyDashboardScreen()));
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AgencyLoginScreen()));
                    }
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openSaved(BuildContext context, AppProvider provider) {
    final saved = provider.savedOffers;
    Navigator.push(context, MaterialPageRoute(builder: (_) => _SavedScreen(offers: saved)));
  }

  void _openLanguagePicker(BuildContext context, AppProvider provider) {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(t.chooseLanguageTitle, style: AppTheme.serif(22)),
            const SizedBox(height: 16),
            _LanguageOption(label: t.languageKurdish, code: 'ku', provider: provider),
            const SizedBox(height: 10),
            _LanguageOption(label: t.languageArabic, code: 'ar', provider: provider),
            const SizedBox(height: 10),
            _LanguageOption(label: t.languageEnglish, code: 'en', provider: provider),
          ],
        ),
      ),
    );
  }

}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final AppProvider provider;
  const _LanguageOption({required this.label, required this.code, required this.provider});

  @override
  Widget build(BuildContext context) {
    final active = provider.locale.languageCode == code;
    return GestureDetector(
      onTap: () {
        provider.setLocale(Locale(code));
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTheme.sans(15, weight: FontWeight.w700, color: active ? AppColors.primary : AppColors.ink))),
            if (active) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SignInBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SignInBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.profileSignIn, style: AppTheme.sans(15.5, weight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(t.profileSignInBannerSubtitle,
                      style: AppTheme.sans(12, color: Colors.white.withOpacity(0.82)), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppProvider provider;
  const _ProfileHeader({required this.provider});

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
              padding: const EdgeInsets.fromLTRB(22, 30, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 66, height: 66,
                        decoration: BoxDecoration(color: const Color(0xFFF3E6C4), borderRadius: BorderRadius.circular(20)),
                        alignment: Alignment.center,
                        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.user?.fullName.isNotEmpty == true
                                  ? provider.user!.fullName
                                  : t.profilePilgrim,
                              style: AppTheme.serif(24, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            if (provider.isSignedIn)
                              Text(provider.user!.email,
                                  style: AppTheme.sans(12, color: Colors.white.withOpacity(0.8)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis)
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.95), borderRadius: BorderRadius.circular(8)),
                                child: Text(t.profileGuestBadge, style: AppTheme.sans(11, weight: FontWeight.w800, color: const Color(0xFF1C2317)).copyWith(letterSpacing: 0.4)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        _StatCell(value: '${provider.bookings.length}', label: t.profileStatTrips),
                        _Div(),
                        _StatCell(value: '${provider.saved.length}', label: t.profileStatSaved),
                        _Div(),
                        _StatCell(value: '${provider.unreadNotifications}', label: t.profileStatAlerts),
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

class _StatCell extends StatelessWidget {
  final String value, label;
  const _StatCell({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(children: [
        Text(value, style: AppTheme.serif(22, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.sans(11, color: Colors.white.withOpacity(0.7))),
      ]),
    ),
  );
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.15));
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? tint;
  final VoidCallback onTap;
  const _MenuCard({required this.icon, required this.label, this.badge, this.tint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor = tint ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: tint != null ? tint!.withOpacity(0.25) : AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label, style: AppTheme.sans(14, weight: FontWeight.w600, color: const Color(0xFF1F2D26)), overflow: TextOverflow.ellipsis)),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text(badge!, style: AppTheme.sans(11, weight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, color: const Color(0xFFC1C8BF), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Saved Offers Screen ───────────────────────────────────────────────────────

class _SavedScreen extends StatelessWidget {
  final List<Offer> offers;
  const _SavedScreen({required this.offers});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 22, 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.border, width: 1.5)),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(t.savedTripsTitle, style: AppTheme.serif(26))),
                ],
              ),
            ),
            Expanded(
              child: offers.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.mutedLight),
                        const SizedBox(height: 14),
                        Text(t.savedTripsEmptyTitle, style: AppTheme.serif(20)),
                        const SizedBox(height: 6),
                        Text(t.savedTripsEmptyBody, style: AppTheme.sans(13, color: AppColors.muted)),
                      ]),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: offers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 13),
                      itemBuilder: (context, i) => _SavedCard(offer: offers[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final Offer offer;
  const _SavedCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final t = AppLocalizations.of(context);
    final company = provider.companyById(offer.companyId);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer))),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            OfferImage(offer: offer, height: 88, width: 88, borderRadius: BorderRadius.circular(13)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company?.nameFor(Localizations.localeOf(context).languageCode) ?? '', style: AppTheme.sans(10.5, weight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(offer.titleFor(Localizations.localeOf(context).languageCode), style: AppTheme.serif(16), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    StarRating(rating: offer.rating),
                    const Spacer(),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: t.priceFromPrefix, style: AppTheme.sans(11, color: AppColors.muted)),
                      TextSpan(text: offer.priceFmt, style: AppTheme.serif(16, color: AppColors.primary)),
                    ])),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () { provider.toggleSave(offer.id); if (provider.savedOffers.isEmpty) Navigator.pop(context); },
              child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
