import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import 'dashboard_scaffold.dart';

/// Standard empty state for dashboard lists. `compact` renders a single muted
/// line for sections that sit inside a longer scroll view; the full variant
/// fills the viewport with the icon-circle layout used across the app.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.ctaLabel,
    this.onCta,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: kDashPagePad,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.mutedLight),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTheme.sans(13, color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFECF0E9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.serif(20), textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: 5),
              Text(
                body!,
                style: AppTheme.sans(13, color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onCta,
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 13, 24, 13),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    ctaLabel!,
                    style: AppTheme.sans(
                      13,
                      weight: FontWeight.w700,
                      color: const Color(0xFFF6F2E9),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
