import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/dashboard/dashboard_shell.dart';
import '../../l10n/generated/app_localizations.dart';
import 'agency_overview_tab.dart';
import 'agency_trips_tab.dart';
import 'agency_bookings_tab.dart';
import 'agency_profile_tab.dart';
import 'agency_messages_tab.dart';
import 'agency_documents_screen.dart';

/// Agency control panel, restructured as a 5-tab shell:
/// Overview · Trips · Bookings · Money · Profile.
class AgencyDashboardScreen extends StatefulWidget {
  const AgencyDashboardScreen({super.key});

  @override
  State<AgencyDashboardScreen> createState() => _AgencyDashboardScreenState();
}

class _AgencyDashboardScreenState extends State<AgencyDashboardScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<AppProvider>();
      p.loadAgencyBookings();
      p.loadCommissions();
      p.loadAgencyInquiries();
    });
  }

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final company = provider.agencyCompany;
    if (company == null) return _NoCompanyState(provider: provider);
    if (!company.isActive) {
      return _AgencyAccessState(companyStatus: company.status);
    }

    return DashboardShell(
      index: _index,
      onSelect: _goToTab,
      destinations: [
        DashboardDestination(
          icon: Icons.space_dashboard_rounded,
          label: t.tabOverview,
        ),
        DashboardDestination(
          icon: Icons.luggage_rounded,
          label: t.promoteTabTrips,
        ),
        DashboardDestination(
          icon: Icons.receipt_long_outlined,
          label: t.navBookings,
          badge: provider.pendingBookingCount,
        ),
        DashboardDestination(
          icon: Icons.forum_outlined,
          label: t.agencyMessages,
        ),
        DashboardDestination(icon: Icons.more_horiz_rounded, label: t.tabMore),
      ],
      pages: [
        AgencyOverviewTab(onGoToTab: _goToTab),
        const AgencyTripsTab(),
        const AgencyBookingsTab(),
        const AgencyMessagesTab(),
        const AgencyProfileTab(),
      ],
    );
  }
}

class _AgencyAccessState extends StatelessWidget {
  final String companyStatus;
  const _AgencyAccessState({required this.companyStatus});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final provider = context.read<AppProvider>();
    final isRejected = companyStatus == 'rejected';
    final isSuspended = companyStatus == 'suspended';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color:
                        (isRejected || isSuspended
                                ? AppColors.errorRed
                                : AppColors.gold)
                            .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuspended
                        ? Icons.block_rounded
                        : isRejected
                        ? Icons.error_outline_rounded
                        : Icons.hourglass_top_rounded,
                    size: 34,
                    color: isRejected || isSuspended
                        ? AppColors.errorRed
                        : AppColors.gold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isSuspended
                      ? t.agencyAccessSuspendedTitle
                      : isRejected
                      ? t.agencyAccessRejectedTitle
                      : t.agencyAccessUnderReviewTitle,
                  style: AppTheme.serif(24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  isSuspended
                      ? t.agencyAccessSuspendedBody
                      : isRejected
                      ? t.agencyAccessRejectedBody
                      : t.agencyAccessUnderReviewBody,
                  style: AppTheme.sans(
                    13.5,
                    color: AppColors.muted,
                  ).copyWith(height: 1.55),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AgencyDocumentsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(t.agencyDocumentsResubmit),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: provider.retryAgencyCompany,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(t.retry),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: provider.agencyLogout,
                  child: Text(t.profileAgencyLogout),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shown instead of a blank screen when a logged-in agency user has no
// company row yet — happens when email confirmation delayed their first
// session past the original sign-up call. Retry re-reads the sign-up
// metadata and creates it without requiring a fresh sign-out/in.
class _NoCompanyState extends StatefulWidget {
  final AppProvider provider;
  const _NoCompanyState({required this.provider});

  @override
  State<_NoCompanyState> createState() => _NoCompanyStateState();
}

class _NoCompanyStateState extends State<_NoCompanyState> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    await widget.provider.retryAgencyCompany();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.provider.lang;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.business_center_outlined,
                  size: 48,
                  color: AppColors.mutedLight,
                ),
                const SizedBox(height: 16),
                Text(
                  _title(lang),
                  style: AppTheme.serif(20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _body(lang),
                  style: AppTheme.sans(13, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _retrying ? null : _retry,
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      24,
                      13,
                      24,
                      13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: _retrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _retryLabel(lang),
                            style: AppTheme.sans(
                              13,
                              weight: FontWeight.w700,
                              color: const Color(0xFFF6F2E9),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: widget.provider.agencyLogout,
                  child: Text(
                    _signOutLabel(lang),
                    style: AppTheme.sans(
                      13,
                      weight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _title(String lang) {
    if (lang == 'ar') return 'ملفك التجاري غير مكتمل بعد';
    if (lang == 'ku') return 'پرۆفایلی کۆمپانیاکەت هێشتا تەواو نییە';
    return "Your company profile isn't set up yet";
  }

  String _body(String lang) {
    if (lang == 'ar') {
      return 'إذا قمت بتأكيد بريدك الإلكتروني للتو، اضغط إعادة المحاولة لإكمال إعداد حسابك.';
    }
    if (lang == 'ku') {
      return 'ئەگەر تازە ئیمەیلەکەت پشتڕاست کردووەتەوە، دووبارە هەوڵبدەرەوە بۆ تەواوکردنی هەژمارەکەت.';
    }
    return "If you just confirmed your email, tap retry to finish setting up your account.";
  }

  String _retryLabel(String lang) {
    if (lang == 'ar') return 'إعادة المحاولة';
    if (lang == 'ku') return 'دووبارە هەوڵدانەوە';
    return 'Retry';
  }

  String _signOutLabel(String lang) {
    if (lang == 'ar') return 'تسجيل الخروج';
    if (lang == 'ku') return 'چوونەدەرەوە';
    return 'Sign out';
  }
}
