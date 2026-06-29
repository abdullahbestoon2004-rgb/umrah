import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'home/home_screen.dart';
import 'companies/companies_screen.dart';
import 'offers/offers_screen.dart';
import 'bookings/bookings_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _screens = [
    HomeScreen(),
    CompaniesScreen(),
    OffersScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tab = context.watch<AppProvider>().currentTab;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: tab, children: _screens),
      bottomNavigationBar: _BottomNav(currentIndex: tab),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
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
              _NavItem(icon: Icons.home_rounded,          label: 'Home',     active: currentIndex == 0, onTap: () => provider.setTab(0)),
              _NavItem(icon: Icons.business_rounded,      label: 'Agencies', active: currentIndex == 1, onTap: () => provider.setTab(1)),
              _NavItem(icon: Icons.local_offer_rounded,   label: 'Offers',   active: currentIndex == 2, onTap: () => provider.setTab(2)),
              _NavItem(icon: Icons.calendar_month_rounded,label: 'Bookings', active: currentIndex == 3, onTap: () => provider.setTab(3)),
              _NavItem(icon: Icons.person_rounded,        label: 'Profile',  active: currentIndex == 4, onTap: () => provider.setTab(4)),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(label, style: AppTheme.sans(10, weight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
