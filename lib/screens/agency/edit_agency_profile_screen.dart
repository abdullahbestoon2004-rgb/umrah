import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/company_model.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/company_avatar.dart';
import '../../l10n/generated/app_localizations.dart';

class EditAgencyProfileScreen extends StatefulWidget {
  final Company company;
  const EditAgencyProfileScreen({super.key, required this.company});

  @override
  State<EditAgencyProfileScreen> createState() =>
      _EditAgencyProfileScreenState();
}

class _EditAgencyProfileScreenState extends State<EditAgencyProfileScreen> {
  late final TextEditingController _locationCtrl;
  late final TextEditingController _aboutCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _sinceCtrl;
  Uint8List? _logoBytes;
  Uint8List? _bannerBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _locationCtrl = TextEditingController(text: widget.company.location);
    _aboutCtrl = TextEditingController(text: widget.company.about);
    _tagsCtrl = TextEditingController(text: widget.company.tags.join(', '));
    _sinceCtrl = TextEditingController(text: '${widget.company.since}');
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    _tagsCtrl.dispose();
    _sinceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _logoBytes = bytes);
  }

  Future<void> _pickBanner() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _bannerBytes = bytes);
  }

  Future<void> _save() async {
    if (_saving) return;
    final t = AppLocalizations.of(context);

    // Validate required fields
    if (_locationCtrl.text.trim().isEmpty) {
      showAppSnack(context, t.editAgencyProfileLocationRequired, isError: true);
      return;
    }
    final sinceYear = int.tryParse(_sinceCtrl.text.trim());
    if (_sinceCtrl.text.trim().isNotEmpty &&
        (sinceYear == null ||
            sinceYear < 1900 ||
            sinceYear > DateTime.now().year)) {
      showAppSnack(context, t.editAgencyProfileYearInvalid, isError: true);
      return;
    }

    setState(() => _saving = true);
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final err = await context.read<AppProvider>().updateCompanyProfile(
      widget.company.id,
      location: _locationCtrl.text.trim(),
      about: _aboutCtrl.text.trim(),
      tags: tags,
      since: int.tryParse(_sinceCtrl.text.trim()),
      logoBytes: _logoBytes,
      bannerBytes: _bannerBytes,
    );

    if (!mounted) return;
    if (err != null) {
      setState(() => _saving = false);
      showAppSnack(context, err, isError: true);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(appSnack(t.editAgencyProfileUpdated));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded, color: AppColors.ink),
        ),
        title: Text(t.editAgencyProfileTitle, style: AppTheme.serif(22)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        t.editAgencyProfileSave,
                        style: AppTheme.sans(
                          13,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identity — name is read-only; tap the avatar to change the logo
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    _logoBytes != null
                        ? Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.memory(
                              _logoBytes!,
                              fit: BoxFit.cover,
                              cacheWidth: 104,
                            ),
                          )
                        : CompanyAvatar(
                            mono: widget.company.mono,
                            tint: widget.company.tint,
                            logoUrl: widget.company.logoUrl,
                            size: 52,
                            fontSize: 22,
                            borderRadius: 14,
                          ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.company.name,
                            style: AppTheme.sans(16, weight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (_logoBytes != null ||
                                    (widget.company.logoUrl ?? '').isNotEmpty)
                                ? t.agencyLogoChange
                                : t.agencyLogoAdd,
                            style: AppTheme.sans(
                              11.5,
                              weight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Background Banner Picker
            Text(
              t.editAgencyProfileBannerLabel,
              style: AppTheme.sans(13, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickBanner,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _bannerBytes != null
                    ? Image.memory(_bannerBytes!, fit: BoxFit.cover)
                    : (widget.company.bannerUrl ?? '').isNotEmpty
                    ? Image.network(
                        widget.company.bannerUrl!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (_bannerBytes != null ||
                                      (widget.company.bannerUrl ?? '')
                                          .isNotEmpty)
                                  ? t.agencyBannerChange
                                  : t.agencyBannerAdd,
                              style: AppTheme.sans(
                                12,
                                weight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _Field(
              label: t.editAgencyProfileLocationLabel,
              controller: _locationCtrl,
              hint: t.editAgencyProfileLocationHint,
            ),
            const SizedBox(height: 18),
            _Field(
              label: t.agencyCompanySince,
              controller: _sinceCtrl,
              hint: t.agencyCompanySinceHint,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            _Field(
              label: t.editAgencyProfileAboutLabel,
              controller: _aboutCtrl,
              hint: t.editAgencyProfileAboutHint,
              maxLines: 5,
            ),
            const SizedBox(height: 18),
            _Field(
              label: t.editAgencyProfileTagsLabel,
              controller: _tagsCtrl,
              hint: t.editAgencyProfileTagsHint,
            ),
            const SizedBox(height: 8),
            Text(
              t.editAgencyProfileTagsBadgeHint,
              style: AppTheme.sans(11.5, color: AppColors.muted),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.sans(13, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: AppTheme.sans(14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
