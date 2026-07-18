class ApiConfig {
  ApiConfig._();

  /// Production PHP API uploaded to public_html/tawafbackend.
  ///
  /// Override at build time for local/staging servers with:
  /// flutter run --dart-define=TAWAF_API_URL=https://example.com/api/index.php
  static const String baseUrl = String.fromEnvironment(
    'TAWAF_API_URL',
    defaultValue: 'https://707222.xyz/tawafbackend/api/index.php',
  );
}
