-- Run after migrations/20260716114346_company_trip_operations.sql on DEV.
-- These structural assertions are rolled back and do not mutate application
-- data.
begin;

do $$
declare target_table text;
begin
  foreach target_table in array array[
    'agency_staff',
    'traveller_documents',
    'trip_announcements',
    'trip_rooms',
    'trip_room_assignments',
    'trip_transport_segments',
    'trip_transport_assignments'
  ] loop
    if to_regclass('public.' || target_table) is null then
      raise exception '%.% is missing', 'public', target_table;
    end if;
    if not exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = target_table
        and c.relrowsecurity
    ) then
      raise exception 'RLS is not enabled on public.%', target_table;
    end if;
  end loop;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'booking_travellers'
      and column_name = 'local_name'
  ) then raise exception 'booking_travellers.local_name is missing'; end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'booking_travellers'
      and column_name = 'document_status'
  ) then raise exception 'booking_travellers.document_status is missing'; end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'booking_travellers'
      and column_name = 'visa_status'
  ) then raise exception 'booking_travellers.visa_status is missing'; end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'can_access_company'
      and p.prosecdef
  ) then raise exception 'secure company permission helper is missing'; end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'assign_traveller_room'
      and p.prosecdef
  ) then raise exception 'secure room assignment RPC is missing'; end if;

  if not exists (
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'review_traveller_document'
      and p.prosecdef
  ) then raise exception 'secure document-review RPC is missing'; end if;

  if has_function_privilege(
    'anon', 'public.assign_traveller_room(uuid,uuid)', 'execute'
  ) then raise exception 'anon can assign travellers to rooms'; end if;

  if has_function_privilege(
    'anon', 'public.review_traveller_document(uuid,text,text,date)', 'execute'
  ) then raise exception 'anon can review traveller documents'; end if;

  if has_table_privilege(
    'authenticated', 'public.trip_room_assignments', 'insert'
  ) then raise exception 'room assignment invariants can be bypassed'; end if;

  if has_table_privilege(
    'authenticated', 'public.trip_transport_assignments', 'insert'
  ) then raise exception 'transport assignment writes are exposed prematurely'; end if;

  if not has_table_privilege(
    'authenticated', 'public.trip_announcements', 'select'
  ) then raise exception 'authenticated users lack announcement Data API access'; end if;

  if not exists (
    select 1 from storage.buckets where id = 'traveller-documents' and not public
  ) then raise exception 'private traveller document bucket is missing'; end if;

  if not exists (
    select 1 from pg_trigger
    where tgname = 'before_mark_legacy_passport_under_review'
      and not tgisinternal
  ) then raise exception 'legacy passport review trigger is missing'; end if;
end $$;

rollback;
