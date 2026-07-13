import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../services/identity_verification_service.dart';

class IdentityPhoto {
  const IdentityPhoto({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
}

class IdentityVerificationProvider extends ChangeNotifier {
  IdentityVerificationProvider({
    ImagePicker? picker,
    IdentityVerificationService? service,
  }) : _picker = picker ?? ImagePicker(),
       _service = service ?? IdentityVerificationService();

  final ImagePicker _picker;
  final IdentityVerificationService _service;

  IdentityPhoto? _passport;
  IdentityPhoto? _selfie;
  bool _submitting = false;
  String? _error;

  IdentityPhoto? get passport => _passport;
  IdentityPhoto? get selfie => _selfie;
  bool get isSubmitting => _submitting;
  String? get error => _error;
  bool get canSubmit => _passport != null && _selfie != null && !_submitting;

  Future<void> pickPassport(ImageSource source) => _pick(source, true);
  Future<void> pickSelfie(ImageSource source) => _pick(source, false);

  Future<void> _pick(ImageSource source, bool isPassport) async {
    _error = null;
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );
      if (file == null) return;

      final extension = _extensionOf(file.name);
      final photo = IdentityPhoto(
        bytes: await file.readAsBytes(),
        extension: extension,
        contentType: file.mimeType ?? _contentTypeFor(extension),
      );
      if (isPassport) {
        _passport = photo;
      } else {
        _selfie = photo;
      }
    } catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!canSubmit) return false;
    _submitting = true;
    _error = null;
    notifyListeners();

    final error = await _service.submit(
      passportBytes: _passport!.bytes,
      passportExtension: _passport!.extension,
      passportContentType: _passport!.contentType,
      selfieBytes: _selfie!.bytes,
      selfieExtension: _selfie!.extension,
      selfieContentType: _selfie!.contentType,
    );
    _error = error;
    _submitting = false;
    notifyListeners();
    return error == null;
  }

  String _extensionOf(String name) {
    final dot = name.lastIndexOf('.');
    return dot >= 0 ? name.substring(dot + 1).toLowerCase() : 'jpg';
  }

  String _contentTypeFor(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
