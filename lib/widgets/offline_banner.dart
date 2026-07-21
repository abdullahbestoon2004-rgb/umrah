import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// A slim strip pinned under the status bar while the device has no network.
///
/// It sits above the app's content rather than replacing it: cached trips and
/// bookings stay readable offline, and this only explains why they may be
/// stale. It disappears on its own once connectivity returns.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOffline = context.select<AppProvider, bool>(
      (provider) => provider.isOffline,
    );
    final t = AppLocalizations.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: !isOffline
          ? const SizedBox.shrink()
          : Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  color: const Color(0xFF3C4A43),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 16,
                        color: Color(0xFFF6F2E9),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.offlineBannerTitle,
                              style: AppTheme.sans(
                                12.5,
                                weight: FontWeight.w700,
                                color: const Color(0xFFF6F2E9),
                              ),
                            ),
                            Text(
                              t.offlineBannerBody,
                              style: AppTheme.sans(
                                11,
                                color: const Color(0xFFF6F2E9),
                              ).copyWith(height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.read<AppProvider>().loadData(),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(
                          t.retry,
                          style: AppTheme.sans(
                            12,
                            weight: FontWeight.w700,
                            color: AppColors.gold,
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
}
