import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/identity_verification_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/islamic_pattern.dart';

enum _IdentityPhotoKind { passport, selfie }

class IdentityVerificationScreen extends StatelessWidget {
  const IdentityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => IdentityVerificationProvider(),
    child: const _IdentityVerificationView(),
  );
}

class _IdentityVerificationView extends StatelessWidget {
  const _IdentityVerificationView();

  Future<bool> _showExample(
    BuildContext context,
    _IdentityPhotoKind kind, {
    required bool beforePicking,
  }) async {
    final t = AppLocalizations.of(context);
    final passport = kind == _IdentityPhotoKind.passport;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.background,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Text(t.identityExampleTitle, style: AppTheme.serif(20)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        passport
                            ? 'assets/images/iraqi_passport_example.jpg'
                            : 'assets/images/man_selfie_example.jpg',
                        height: 320,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 320,
                          width: double.infinity,
                          color: AppColors.surfaceAlt,
                          alignment: Alignment.center,
                          child: Icon(
                            passport
                                ? Icons.badge_outlined
                                : Icons.face_retouching_natural_outlined,
                            size: 40,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...(passport
                            ? [
                                t.identityPassportInstruction1,
                                t.identityPassportInstruction2,
                                t.identityPassportInstruction3,
                              ]
                            : [
                                t.identitySelfieInstruction1,
                                t.identitySelfieInstruction2,
                                t.identitySelfieInstruction3,
                              ])
                        .map(
                          (instruction) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 17,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    instruction,
                                    style: AppTheme.sans(
                                      12.5,
                                      color: AppColors.inkLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(t.identityClose),
              ),
              if (beforePicking)
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(t.identityContinue),
                ),
            ],
          ),
        ) ??
        false;
  }

  Future<ImageSource?> _chooseSource(BuildContext context) {
    final t = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.identityChooseSource, style: AppTheme.serif(20)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: Text(t.identityCamera),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                ),
                title: Text(t.identityGallery),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, _IdentityPhotoKind kind) async {
    final canContinue = await _showExample(context, kind, beforePicking: true);
    if (!canContinue || !context.mounted) return;

    final source = await _chooseSource(context);
    if (source == null || !context.mounted) return;
    final provider = context.read<IdentityVerificationProvider>();
    if (kind == _IdentityPhotoKind.passport) {
      await provider.pickPassport(source);
    } else {
      await provider.pickSelfie(source);
    }
    if (context.mounted && provider.error != null) {
      showAppSnack(context, provider.error!, isError: true);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final t = AppLocalizations.of(context);
    if (!context.read<AppProvider>().isSignedIn) {
      showAppSnack(context, t.identitySignInRequired, isError: true);
      return;
    }
    final provider = context.read<IdentityVerificationProvider>();
    final success = await provider.submit();
    if (!context.mounted) return;
    if (success) {
      showAppSnack(context, t.identitySubmitted);
      Navigator.pop(context, true);
    } else {
      showAppSnack(
        context,
        provider.error ?? t.identityUploadFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = context.watch<IdentityVerificationProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t.identityVerification)),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IslamicPattern(opacity: 0.035, isEightFold: true),
          ),
          SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Text(t.identityVerificationTitle, style: AppTheme.serif(26)),
                const SizedBox(height: 6),
                Text(
                  t.identityVerificationBody,
                  style: AppTheme.sans(13, color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                _UploadSection(
                  title: t.identityPassportPhoto,
                  description: t.identityPassportBody,
                  icon: Icons.badge_outlined,
                  photo: state.passport,
                  onViewExample: () => _showExample(
                    context,
                    _IdentityPhotoKind.passport,
                    beforePicking: false,
                  ),
                  onPick: () => _pick(context, _IdentityPhotoKind.passport),
                ),
                const SizedBox(height: 16),
                _UploadSection(
                  title: t.identitySelfiePhoto,
                  description: t.identitySelfieBody,
                  icon: Icons.face_retouching_natural_outlined,
                  photo: state.selfie,
                  onViewExample: () => _showExample(
                    context,
                    _IdentityPhotoKind.selfie,
                    beforePicking: false,
                  ),
                  onPick: () => _pick(context, _IdentityPhotoKind.selfie),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: state.canSubmit ? () => _submit(context) : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.muted.withValues(
                        alpha: 0.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            t.identitySubmit,
                            style: AppTheme.sans(
                              14,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({
    required this.title,
    required this.description,
    required this.icon,
    required this.photo,
    required this.onViewExample,
    required this.onPick,
  });

  final String title;
  final String description;
  final IconData icon;
  final IdentityPhoto? photo;
  final VoidCallback onViewExample;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.sans(16, weight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(description, style: AppTheme.sans(11.5, color: AppColors.muted)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 170,
              width: double.infinity,
              color: AppColors.surfaceAlt,
              child: photo == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 40, color: AppColors.muted),
                        const SizedBox(height: 8),
                        Text(
                          t.identityNoPhoto,
                          style: AppTheme.sans(12, color: AppColors.muted),
                        ),
                      ],
                    )
                  : Image.memory(photo!.bytes, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewExample,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(t.identityViewExample),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: Text(
                    photo == null
                        ? t.identityUploadPhoto
                        : t.identityChangePhoto,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
