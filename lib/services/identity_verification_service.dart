import 'dart:typed_data';

import 'api_client.dart';

/// Uploads identity documents to private storage through the PHP API.
class IdentityVerificationService {
  IdentityVerificationService([ApiClient? client])
    : _client = client ?? ApiClient.shared;

  final ApiClient _client;

  Future<String?> submit({
    required Uint8List passportBytes,
    required String passportExtension,
    required String passportContentType,
    required Uint8List selfieBytes,
    required String selfieExtension,
    required String selfieContentType,
  }) async {
    try {
      await _client.multipart(
        'identity/submit',
        fields: const {},
        files: {'passport': passportBytes, 'selfie': selfieBytes},
        fileNames: {
          'passport': 'passport.${_safeExtension(passportExtension)}',
          'selfie': 'selfie.${_safeExtension(selfieExtension)}',
        },
      );
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (error) {
      return error.toString();
    }
  }

  String _safeExtension(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return const {'jpg', 'jpeg', 'png', 'webp', 'heic'}.contains(normalized)
        ? normalized
        : 'jpg';
  }
}
