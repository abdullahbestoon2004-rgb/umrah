-- Run after migrations/20260715073147_marketplace_trip_integrity.sql on DEV.
-- Structural assertions are rolled back and do not mutate production data.
begin;

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'hotels'
      and column_name = 'description'
  ) then raise exception 'hotels.description is missing'; end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'bookings'
      and column_name = 'quote_snapshot'
  ) then raise exception 'bookings.quote_snapshot is missing'; end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'quote_offer'
  ) then raise exception 'quote_offer is missing'; end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'create_booking_request'
  ) then raise exception 'create_booking_request is missing'; end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'update_offer_bundle'
  ) then raise exception 'transactional offer bundle RPC is missing'; end if;

  if has_function_privilege(
    'anon', 'public.create_booking_request(uuid,int,text,int,text,text,jsonb,text)',
    'execute'
  ) then raise exception 'anon can create booking requests'; end if;

  if has_function_privilege(
    'authenticated', 'public.expire_stale_bookings()', 'execute'
  ) then raise exception 'clients can expire booking inventory'; end if;

  if not exists (
    select 1 from pg_indexes
    where schemaname = 'public' and indexname = 'bookings_expiry_active_idx'
  ) then raise exception 'active booking expiry index is missing'; end if;

  if not exists (
    select 1 from pg_trigger
    where tgname = 'before_protect_published_offer_edits' and not tgisinternal
  ) then raise exception 'published offer edit guard is missing'; end if;

  if not exists (
    select 1 from pg_trigger
    where tgname = 'before_protect_package_delete' and not tgisinternal
  ) then raise exception 'package delete guard is missing'; end if;

  if not exists (
    select 1 from pg_trigger
    where tgname = 'before_protect_package_publication' and not tgisinternal
  ) then raise exception 'package publication completeness guard is missing'; end if;
end $$;

rollback;
