import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/islamic_pattern.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shown at launch when the biometric app lock is enabled.
/// The app stays hidden until fingerprint/face auth succeeds.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    // Prompt immediately on launch.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryUnlock());
  }

  Future<void> _tryUnlock() async {
    final t = AppLocalizations.of(context);
    final ok = await context.read<AppProvider>().unlock(t.lockReason);
    if (!ok && mounted) setState(() => _failed = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          const Positioned.fill(child: IslamicPattern(opacity: 0.05, cell: 84)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      color: Color(0xFFF3E6C4),
                      size: 46,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.lockTitle,
                    style: AppTheme.serif(28, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.lockSubtitle,
                    style: AppTheme.sans(
                      14,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 36),
                  GestureDetector(
                    onTap: _tryUnlock,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E6C4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        t.lockUnlock,
                        style: AppTheme.sans(
                          15,
                          weight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  if (_failed) ...[
                    const SizedBox(height: 18),
                    Text(
                      t.lockFailed,
                      style: AppTheme.sans(
                        12.5,
                        color: const Color(0xFFF3C4B4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
