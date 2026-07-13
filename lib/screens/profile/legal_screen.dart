import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';

enum LegalKind { privacy, terms }

class LegalScreen extends StatelessWidget {
  final LegalKind kind;
  const LegalScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final title = kind == LegalKind.privacy
        ? t.aboutPrivacyPolicy
        : t.aboutTermsOfUse;
    final body = kind == LegalKind.privacy
        ? t.legalPrivacyBody
        : t.legalTermsBody;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 22, 4),
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
                  Expanded(child: Text(title, style: AppTheme.serif(24))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Text(
                    body,
                    style: AppTheme.sans(
                      13.5,
                      color: AppColors.inkLight,
                    ).copyWith(height: 1.7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
