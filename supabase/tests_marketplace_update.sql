-- Run after patches_marketplace_update.sql in a staging/local database.
-- Every assertion raises on failure and the transaction is rolled back.
begin;

do $$
declare table_name text;
declare rls_enabled boolean;
begin
  foreach table_name in array array[
    'agency_status_history','agency_documents','agency_reports','badges',
    'agency_badges','agency_media','offer_pricing','hotels','offer_hotels',
    'offer_inclusions','offer_media','inquiries','inquiry_messages',
    'carousel_requests','agency_commercial_settings','offer_commercial_settings'
  ] loop
    select c.relrowsecurity into rls_enabled
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public' and c.relname = table_name;
    if rls_enabled is distinct from true then
      raise exception 'RLS is not enabled on %', table_name;
    end if;
  end loop;
end $$;

do $$ begin
  if not exists(select 1 from badges where key = 'verified' and type = 'manual') then
    raise exception 'Verified badge is missing';
  end if;
  if not exists(select 1 from badges where key = 'top_rated' and type = 'auto') then
    raise exception 'Top Rated badge is missing';
  end if;
  if has_table_privilege('anon', 'public.agency_commercial_settings', 'select') then
    raise exception 'anon can read agency commercial settings';
  end if;
  if has_table_privilege('anon', 'public.offer_commercial_settings', 'select') then
    raise exception 'anon can read offer commercial settings';
  end if;
  if has_function_privilege('anon', 'public.admin_set_agency_badge(uuid,text,boolean)', 'execute') then
    raise exception 'anon can call admin_set_agency_badge';
  end if;
  if has_function_privilege('anon', 'public.admin_force_unpublish_offer(uuid,text)', 'execute') then
    raise exception 'anon can call admin_force_unpublish_offer';
  end if;
  if not exists(select 1 from storage.buckets where id = 'agency-documents' and not public) then
    raise exception 'private agency-documents bucket is missing';
  end if;
  if not exists(select 1 from storage.buckets where id = 'offer-media' and public) then
    raise exception 'public offer-media bucket is missing';
  end if;
end $$;

do $$ begin
  if not exists(
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'packages'
      and column_name = 'package_tier'
  ) then raise exception 'packages.package_tier is missing'; end if;
  if not exists(
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'companies'
      and column_name = 'first_offer_approved'
  ) then raise exception 'companies.first_offer_approved is missing'; end if;
end $$;

rollback;
