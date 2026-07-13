import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Uploads identity documents to a private bucket and stores their stable
/// object paths on the signed-in user's profile.
class IdentityVerificationService {
  IdentityVerificationService([this._client]);

  final SupabaseClient? _client;

  SupabaseClient get _c => _client ?? Supabase.instance.client;

  Future<String?> submit({
    required Uint8List passportBytes,
    required String passportExtension,
    required String passportContentType,
    required Uint8List selfieBytes,
    required String selfieExtension,
    required String selfieContentType,
  }) async {
    final user = _c.auth.currentUser;
    if (user == null) return 'You must be signed in to verify your identity.';

    final passportPath =
        '${user.id}/passport.${_safeExtension(passportExtension)}';
    final selfiePath = '${user.id}/selfie.${_safeExtension(selfieExtension)}';

    try {
      final bucket = _c.storage.from('identity_verifications');
      await bucket.uploadBinary(
        passportPath,
        passportBytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: passportContentType,
        ),
      );
      await bucket.uploadBinary(
        selfiePath,
        selfieBytes,
        fileOptions: FileOptions(upsert: true, contentType: selfieContentType),
      );

      // These are private Storage object paths, not public URLs. They remain
      // stable and can be exchanged for short-lived signed URLs by trusted UI.
      await _c
          .from('profiles')
          .update({
            'passport_photo_url': passportPath,
            'selfie_photo_url': selfiePath,
          })
          .eq('id', user.id);
      return null;
    } on StorageException catch (error) {
      return error.message;
    } on PostgrestException catch (error) {
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
