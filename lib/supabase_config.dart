class SupabaseConfig {
  SupabaseConfig._();

  /// This is a public client key. RLS protects database data; never use a
  /// service-role key in the mobile app.
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wvgrdmzezwdwcyicwgev.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_fWEEQyog0S7DsOcL4Z3STg_Wux8TKvz',
  );
}
