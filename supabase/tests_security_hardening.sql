-- Run after migrations/20260716125153_security_hardening.sql on DEV.
-- Structural security assertions only; no application data is changed.
begin;

do $$
begin
  if exists (
    select 1 from storage.buckets
    where id = 'identity_verifications' and public
  ) then raise exception 'identity verification documents are public'; end if;

  if exists (
    select 1 from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
      and policyname in (
        'public read identity verifications',
        'public read agency media',
        'public read offer media',
        'public read package images'
      )
  ) then raise exception 'a broad storage listing policy remains'; end if;

  if exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'error_logs'
      and cmd = 'INSERT' and with_check = 'true'
  ) then raise exception 'error log inserts are unrestricted'; end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'user_roles'
      and policyname = 'admins read user roles'
  ) then raise exception 'user_roles has no admin read policy'; end if;

  if exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    join pg_trigger t on t.tgfoid = p.oid and not t.tgisinternal
    where n.nspname = 'public' and p.prosecdef
      and (
        has_function_privilege('anon', p.oid, 'execute')
        or has_function_privilege('authenticated', p.oid, 'execute')
      )
  ) then raise exception 'a privileged trigger function is exposed as RPC'; end if;

  if exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'open_commission',
        'forbid_ledger_mutation',
        'protect_company_admin_fields',
        'occupancy_type_for'
      )
      and not coalesce(p.proconfig, '{}') @> array['search_path=public']
  ) then raise exception 'a reviewed function has a mutable search_path'; end if;
end $$;

rollback;
