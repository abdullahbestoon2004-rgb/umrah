import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/identity_verification_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../../widgets/app_snackbar.dart';

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

  Future<void> _showExample(
    BuildContext context,
    _IdentityPhotoKind kind,
  ) async {
    final t = AppLocalizations.of(context);
    final isPassport = kind == _IdentityPhotoKind.passport;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.background,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390, maxHeight: 690),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isPassport
                            ? t.identityPassportExampleTitle
                            : t.identitySelfieExampleTitle,
                        style: AppTheme.sans(19, weight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: t.identityClose,
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: AppColors.surface,
                      child: Image.asset(
                        isPassport
                            ? 'assets/images/iraqi_passport_example.jpg'
                            : 'assets/images/man_selfie_example.jpg',
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => SizedBox(
                          height: 360,
                          child: Center(
                            child: Icon(
                              isPassport
                                  ? Icons.menu_book_rounded
                                  : Icons.face_rounded,
                              size: 52,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isPassport
                      ? t.identityPassportExampleCaption
                      : t.identitySelfieExampleCaption,
                  textAlign: TextAlign.center,
                  style: AppTheme.sans(
                    12.5,
                    color: AppColors.inkLight,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<ImageSource?> _chooseSource(BuildContext context) {
    final t = AppLocalizations.of(context);
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.identityChooseSource,
                style: AppTheme.sans(19, weight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                ),
                title: Text(t.identityCamera),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 56,
        title: Text(
          t.identityVerification,
          style: AppTheme.sans(20, weight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        children: [
          _SecurityNotice(text: t.identitySecureBody),
          const SizedBox(height: 24),
          _UploadSection(
            step: 1,
            title: t.identityPassportPhoto,
            instructions: [
              t.identityPassportInstruction1,
              t.identityPassportInstruction2,
              t.identityPassportInstruction3,
            ],
            placeholder: t.identityPassportPlaceholder,
            icon: Icons.menu_book_rounded,
            photo: state.passport,
            onViewExample: () =>
                _showExample(context, _IdentityPhotoKind.passport),
            onPick: () => _pick(context, _IdentityPhotoKind.passport),
          ),
          const SizedBox(height: 24),
          _UploadSection(
            step: 2,
            title: t.identitySelfiePhoto,
            instructions: [
              t.identitySelfieInstruction1,
              t.identitySelfieInstruction2,
              t.identitySelfieInstruction3,
              t.identitySelfieInstruction4,
            ],
            placeholder: t.identitySelfiePlaceholder,
            icon: Icons.face_rounded,
            photo: state.selfie,
            onViewExample: () =>
                _showExample(context, _IdentityPhotoKind.selfie),
            onPick: () => _pick(context, _IdentityPhotoKind.selfie),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 18,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: state.canSubmit ? () => _submit(context) : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFE1E5DE),
                disabledForegroundColor: AppColors.muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
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
                        color: state.canSubmit ? Colors.white : AppColors.muted,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.security_rounded, color: Color(0xFF09836E), size: 30),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).identitySecureTitle,
                style: AppTheme.sans(15, weight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: AppTheme.sans(
                  11.5,
                  color: AppColors.inkLight,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({
    required this.step,
    required this.title,
    required this.instructions,
    required this.placeholder,
    required this.icon,
    required this.photo,
    required this.onViewExample,
    required this.onPick,
  });

  final int step;
  final String title;
  final List<String> instructions;
  final String placeholder;
  final IconData icon;
  final IdentityPhoto? photo;
  final VoidCallback onViewExample;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final stepLabel = language == 'en' ? '$step' : (step == 1 ? '١' : '٢');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$stepLabel. $title',
            style: AppTheme.sans(17, weight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          ...instructions.map(
            (instruction) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.inkLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instruction,
                      style: AppTheme.sans(
                        11.5,
                        color: AppColors.inkLight,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 23),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCE1D8)),
            ),
            clipBehavior: Clip.antiAlias,
            child: photo == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 38, color: AppColors.mutedLight),
                      const SizedBox(height: 10),
                      Text(
                        placeholder,
                        style: AppTheme.sans(
                          12,
                          color: AppColors.muted,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Image.memory(photo!.bytes, fit: BoxFit.cover),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewExample,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: Color(0xFFE1E5DF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(
                    t.identityViewExample,
                    style: AppTheme.sans(12, weight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPick,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: Text(
                    photo == null
                        ? t.identityUploadPhoto
                        : t.identityChangePhoto,
                    style: AppTheme.sans(
                      12,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
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
