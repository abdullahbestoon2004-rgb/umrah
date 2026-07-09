import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../l10n/generated/app_localizations.dart';
import 'home/home_screen.dart';
import 'companies/companies_screen.dart';
import 'offers/offers_screen.dart';
import 'bookings/bookings_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/reset_password_overlay.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PageController _pageController;
  late final AppProvider _provider;
  bool _isProgrammaticScroll = false;

  static const _screens = [
    HomeScreen(),
    CompaniesScreen(),
    OffersScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _provider = context.read<AppProvider>();
    _pageController = PageController(initialPage: _provider.currentTab);
    _provider.addListener(_onProviderTabChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderTabChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onProviderTabChanged() {
    final tab = _provider.currentTab;
    if (_pageController.hasClients && _pageController.page?.round() != tab) {
      _isProgrammaticScroll = true;
      _pageController
          .animateToPage(
            tab,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          )
          .then((_) => _isProgrammaticScroll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.needsPasswordReset) {
      return const ResetPasswordOverlay();
    }
    final tab = provider.currentTab;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (!_isProgrammaticScroll) {
            context.read<AppProvider>().setTab(index);
          }
        },
        children: _screens.map((s) => _KeepAlivePage(child: s)).toList(),
      ),
      bottomNavigationBar: _BottomNav(currentIndex: tab),
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final t = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.96),
        border: const Border(top: BorderSide(color: Color(0x1A0F5C4D), width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded,          label: t.navHome,     active: currentIndex == 0, onTap: () => provider.setTab(0)),
              _NavItem(icon: Icons.business_rounded,      label: t.navAgencies, active: currentIndex == 1, onTap: () => provider.setTab(1)),
              _NavItem(icon: Icons.local_offer_rounded,   label: t.navOffers,   active: currentIndex == 2, onTap: () => provider.setTab(2)),
              _NavItem(icon: Icons.calendar_month_rounded,label: t.navBookings, active: currentIndex == 3, onTap: () => provider.setTab(3)),
              _NavItem(icon: Icons.person_rounded,        label: t.navProfile,  active: currentIndex == 4, onTap: () => provider.setTab(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.mutedLight;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: active ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 3),
            Text(label, style: AppTheme.sans(10, weight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
