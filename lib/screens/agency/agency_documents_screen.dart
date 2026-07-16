import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';

class AgencyDocumentsScreen extends StatefulWidget {
  const AgencyDocumentsScreen({super.key});

  @override
  State<AgencyDocumentsScreen> createState() => _AgencyDocumentsScreenState();
}

class _AgencyDocumentsScreenState extends State<AgencyDocumentsScreen> {
  String _type = 'license';
  Uint8List? _bytes;
  String _fileName = '';
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final company = context.watch<AppProvider>().agencyCompany;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t.agencyDocumentsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            t.agencyDocumentsBody,
            style: AppTheme.sans(
              13,
              color: AppColors.muted,
            ).copyWith(height: 1.5),
          ),
          if ((company?.verificationReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                company!.verificationReason!,
                style: AppTheme.sans(12.5, color: AppColors.inkLight),
              ),
            ),
          ],
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: InputDecoration(labelText: t.agencyDocumentType),
            items: [
              DropdownMenuItem(
                value: 'license',
                child: Text(t.agencyDocumentLicense),
              ),
              DropdownMenuItem(
                value: 'registration',
                child: Text(t.agencyDocumentRegistration),
              ),
              DropdownMenuItem(
                value: 'office',
                child: Text(t.agencyDocumentOffice),
              ),
            ],
            onChanged: (value) => setState(() => _type = value ?? 'license'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pick,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(_fileName.isEmpty ? t.agencyDocumentChoose : _fileName),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _bytes == null || _uploading ? null : _upload,
            icon: _uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(t.agencyDocumentUpload),
          ),
        ],
      ),
    );
  }

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _fileName = file.name;
    });
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    final error = await context.read<AppProvider>().uploadAgencyDocument(
      documentType: _type,
      bytes: _bytes!,
      fileName: _fileName,
    );
    if (!mounted) return;
    setState(() => _uploading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? AppLocalizations.of(context).agencyDocumentUploaded,
        ),
      ),
    );
    if (error == null) {
      setState(() {
        _bytes = null;
        _fileName = '';
      });
    }
  }
}
