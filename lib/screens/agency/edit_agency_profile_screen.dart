import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../models/company_model.dart';

class EditAgencyProfileScreen extends StatefulWidget {
  final Company company;
  const EditAgencyProfileScreen({super.key, required this.company});

  @override
  State<EditAgencyProfileScreen> createState() => _EditAgencyProfileScreenState();
}

class _EditAgencyProfileScreenState extends State<EditAgencyProfileScreen> {
  late final TextEditingController _locationCtrl;
  late final TextEditingController _aboutCtrl;
  late final TextEditingController _tagsCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _locationCtrl = TextEditingController(text: widget.company.location);
    _aboutCtrl    = TextEditingController(text: widget.company.about);
    _tagsCtrl     = TextEditingController(text: widget.company.tags.join(', '));
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _saving = true);
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    context.read<AppProvider>().updateCompanyProfile(
      widget.company.id,
      location: _locationCtrl.text.trim(),
      about:    _aboutCtrl.text.trim(),
      tags:     tags,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile updated!', style: AppTheme.sans(13, weight: FontWeight.w600)),
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close_rounded, color: AppColors.ink),
        ),
        title: Text('Edit Profile', style: AppTheme.serif(22)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Save', style: AppTheme.sans(13, weight: FontWeight.w800, color: Colors.white)),
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
            // Identity (read-only)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: widget.company.tint, borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center,
                    child: Text(widget.company.mono, style: AppTheme.serif(22, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.company.name, style: AppTheme.sans(16, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('Since ${widget.company.since} · Read-only fields above', style: AppTheme.sans(11.5, color: AppColors.muted)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _Field(label: 'Location / City', controller: _locationCtrl, hint: 'e.g. Riyadh, KSA'),
            const SizedBox(height: 18),
            _Field(
              label: 'About your agency',
              controller: _aboutCtrl,
              hint: 'Describe your agency, specialisations, history…',
              maxLines: 5,
            ),
            const SizedBox(height: 18),
            _Field(
              label: 'Tags (comma-separated)',
              controller: _tagsCtrl,
              hint: 'e.g. Govt. licensed, Family specialist',
            ),
            const SizedBox(height: 8),
            Text('Tags appear on your agency profile as badges.',
                style: AppTheme.sans(11.5, color: AppColors.muted)),
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
  const _Field({required this.label, required this.controller, required this.hint, this.maxLines = 1});

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
            style: AppTheme.sans(14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTheme.sans(14, color: AppColors.mutedLight),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}
