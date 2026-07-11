import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/dashboard/dashboard_shell.dart';
import '../../l10n/generated/app_localizations.dart';
import 'admin_overview_tab.dart';
import 'admin_agencies_tab.dart';
import 'admin_finance_tab.dart';
import 'admin_content_tab.dart';
import 'admin_more_tab.dart';

/// Owner-only control panel, restructured as a 5-destination shell:
/// Overview · Agencies · Finance · Content · More. Each tab keeps its own
/// state across switches; secondary screens (support inbox, promotions,
/// home preview) hang off the More menu.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AppProvider>().loadAdminData(),
    );
  }

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    if (!provider.isAdminUser) return const SizedBox.shrink();

    return DashboardShell(
      index: _index,
      onSelect: _goToTab,
      destinations: [
        DashboardDestination(
            icon: Icons.space_dashboard_rounded, label: t.tabOverview),
        DashboardDestination(
          icon: Icons.domain_rounded,
          label: t.navAgencies,
          badge: provider.pendingCompanies.length,
        ),
        DashboardDestination(
            icon: Icons.receipt_long_rounded, label: t.adminActionFinance),
        DashboardDestination(
            icon: Icons.campaign_rounded, label: t.tabContent),
        DashboardDestination(
          icon: Icons.more_horiz_rounded,
          label: t.tabMore,
          badge: provider.supportMessages.length,
        ),
      ],
      pages: [
        AdminOverviewTab(onGoToTab: _goToTab),
        const AdminAgenciesTab(),
        const AdminFinanceTab(),
        const AdminContentTab(),
        const AdminMoreTab(),
      ],
    );
  }
}
