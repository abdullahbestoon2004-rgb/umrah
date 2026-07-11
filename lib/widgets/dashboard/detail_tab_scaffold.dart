import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import 'dashboard_scaffold.dart';

/// Detail-screen anatomy shared by agency/trip/booking details: back row +
/// title, an optional header block, then a pill TabBar with its views —
/// the same pill tab styling the promote screen already uses.
class DetailTabScaffold extends StatelessWidget {
  final String title;
  final Widget? header;
  final Widget? titleTrailing;
  final List<String> tabs;
  final List<Widget> views;

  const DetailTabScaffold({
    super.key,
    required this.title,
    this.header,
    this.titleTrailing,
    required this.tabs,
    required this.views,
  }) : assert(tabs.length == views.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DefaultTabController(
          length: tabs.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
                child: Row(
                  children: [
                    DashIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(title,
                          style: AppTheme.serif(24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (titleTrailing != null) titleTrailing!,
                  ],
                ),
              ),
              if (header != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      kDashPagePad, 10, kDashPagePad, 0),
                  child: header!,
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    kDashPagePad, 16, kDashPagePad, 0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.muted,
                    labelStyle:
                        AppTheme.sans(13.5, weight: FontWeight.w700),
                    unselectedLabelStyle:
                        AppTheme.sans(13.5, weight: FontWeight.w600),
                    tabs: [for (final label in tabs) Tab(text: label)],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: TabBarView(children: views)),
            ],
          ),
        ),
      ),
    );
  }
}
