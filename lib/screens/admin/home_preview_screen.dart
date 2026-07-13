import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/tag_chip.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/home_screen.dart';

/// Full-screen render of the client home screen with a language switcher, so
/// the admin can check carousel/featured content in all three locales without
/// changing the app language.
class HomePreviewScreen extends StatefulWidget {
  const HomePreviewScreen({super.key});

  @override
  State<HomePreviewScreen> createState() => _HomePreviewScreenState();
}

class _HomePreviewScreenState extends State<HomePreviewScreen> {
  String? _lang;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = _lang ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      t.contentPreviewHome,
                      style: AppTheme.serif(20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TagChip(
                    label: 'کوردی',
                    active: lang == 'ku',
                    onTap: () => setState(() => _lang = 'ku'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                  ),
                  const SizedBox(width: 5),
                  TagChip(
                    label: 'عربي',
                    active: lang == 'ar',
                    onTap: () => setState(() => _lang = 'ar'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                  ),
                  const SizedBox(width: 5),
                  TagChip(
                    label: 'En',
                    active: lang == 'en',
                    onTap: () => setState(() => _lang = 'en'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1.5, color: AppColors.border),
            Expanded(
              child: Localizations.override(
                context: context,
                locale: Locale(lang),
                child: Directionality(
                  textDirection: lang == 'en'
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  child: const HomeScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
