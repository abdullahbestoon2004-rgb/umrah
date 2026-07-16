-- Harden legacy storage policies and function privileges discovered by the
-- Supabase security advisor. Public media remains retrievable through public
-- object URLs; Data API listing and file mutation require ownership.

-- ---------------------------------------------------------------------------
-- 1. Private identity documents and owner-scoped storage mutations
-- ---------------------------------------------------------------------------
update storage.buckets set public = false
where id = 'identity_verifications';

drop policy if exists "public read identity verifications" on storage.objects;
drop policy if exists "users upload identity verifications" on storage.objects;
drop policy if exists "users update identity verifications" on storage.objects;
drop policy if exists "users upload own identity documents" on storage.objects;
drop policy if exists "users read own identity documents" on storage.objects;
drop policy if exists "users replace own identity documents" on storage.objects;

create policy "users upload own identity documents"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'identity_verifications'
  and (storage.foldername(storage.objects.name))[1] = (select auth.uid())::text
);
create policy "users read own identity documents"
on storage.objects for select to authenticated
using (
  bucket_id = 'identity_verifications'
  and (
    (storage.foldername(storage.objects.name))[1] = (select auth.uid())::text
    or is_admin()
  )
);
create policy "users replace own identity documents"
on storage.objects for update to authenticated
using (
  bucket_id = 'identity_verifications'
  and (storage.foldername(storage.objects.name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'identity_verifications'
  and (storage.foldername(storage.objects.name))[1] = (select auth.uid())::text
);

-- Fix outer-column qualification in the original agency document policies.
-- Without storage.objects.name, Postgres can bind `name` to companies.name.
drop policy if exists "agency upload own documents" on storage.objects;
drop policy if exists "agency read own documents" on storage.objects;
drop policy if exists "agency replace own documents" on storage.objects;
create policy "agency upload own documents"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'agency-documents'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'documents')
  )
);
create policy "agency read own documents"
on storage.objects for select to authenticated
using (
  bucket_id = 'agency-documents'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'documents')
  )
);
create policy "agency replace own documents"
on storage.objects for update to authenticated
using (
  bucket_id = 'agency-documents'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'documents')
  )
)
with check (
  bucket_id = 'agency-documents'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'documents')
  )
);

-- Public buckets do not need a broad SELECT policy for public object URLs.
-- Retain SELECT only for owners who need it for Storage upserts.
drop policy if exists "public read agency media" on storage.objects;
drop policy if exists "agency read own media" on storage.objects;
drop policy if exists "agency upload own media" on storage.objects;
drop policy if exists "agency replace own media" on storage.objects;
create policy "agency read own media"
on storage.objects for select to authenticated
using (
  bucket_id = 'agency-media'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'operations')
  )
);
create policy "agency upload own media"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'agency-media'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'operations')
  )
);
create policy "agency replace own media"
on storage.objects for update to authenticated
using (
  bucket_id = 'agency-media'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'operations')
  )
)
with check (
  bucket_id = 'agency-media'
  and exists (
    select 1 from companies c
    where c.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(c.id, 'operations')
  )
);

drop policy if exists "public read offer media" on storage.objects;
drop policy if exists "agency read own offer media" on storage.objects;
drop policy if exists "agency upload own offer media" on storage.objects;
drop policy if exists "agency replace own offer media" on storage.objects;
create policy "agency read own offer media"
on storage.objects for select to authenticated
using (
  bucket_id = 'offer-media'
  and exists (
    select 1 from packages p
    where p.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(p.company_id, 'operations')
  )
);
create policy "agency upload own offer media"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'offer-media'
  and exists (
    select 1 from packages p
    where p.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(p.company_id, 'operations')
  )
);
create policy "agency replace own offer media"
on storage.objects for update to authenticated
using (
  bucket_id = 'offer-media'
  and exists (
    select 1 from packages p
    where p.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(p.company_id, 'operations')
  )
)
with check (
  bucket_id = 'offer-media'
  and exists (
    select 1 from packages p
    where p.id::text = (storage.foldername(storage.objects.name))[1]
      and can_access_company(p.company_id, 'operations')
  )
);

-- The legacy package-images policies allowed every signed-in user to replace
-- every package, company, or ad image. Scope all three Storage privileges to
-- the package/company owner or an admin.
drop policy if exists "public read package images" on storage.objects;
drop policy if exists "agencies upload package images" on storage.objects;
drop policy if exists "agencies update package images" on storage.objects;
drop policy if exists "owners read package images" on storage.objects;
drop policy if exists "owners upload package images" on storage.objects;
drop policy if exists "owners update package images" on storage.objects;

create policy "owners read package images"
on storage.objects for select to authenticated
using (
  bucket_id = 'package-images'
  and (
    is_admin()
    or exists (
      select 1 from packages p
      where p.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(p.company_id, 'operations')
    )
    or exists (
      select 1 from companies c
      where c.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(c.id, 'operations')
    )
  )
);
create policy "owners upload package images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'package-images'
  and (
    is_admin()
    or exists (
      select 1 from packages p
      where p.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(p.company_id, 'operations')
    )
    or exists (
      select 1 from companies c
      where c.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(c.id, 'operations')
    )
  )
);
create policy "owners update package images"
on storage.objects for update to authenticated
using (
  bucket_id = 'package-images'
  and (
    is_admin()
    or exists (
      select 1 from packages p
      where p.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(p.company_id, 'operations')
    )
    or exists (
      select 1 from companies c
      where c.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(c.id, 'operations')
    )
  )
)
with check (
  bucket_id = 'package-images'
  and (
    is_admin()
    or exists (
      select 1 from packages p
      where p.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(p.company_id, 'operations')
    )
    or exists (
      select 1 from companies c
      where c.id::text = split_part(storage.filename(storage.objects.name), '.', 1)
        and can_access_company(c.id, 'operations')
    )
  )
);

-- ---------------------------------------------------------------------------
-- 2. RLS and function hardening
-- ---------------------------------------------------------------------------
drop policy if exists "log errors" on error_logs;
create policy "signed-in users log own errors" on error_logs for insert
to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "admins read user roles" on user_roles;
create policy "admins read user roles" on user_roles for select
to authenticated using (is_admin());

alter function public.open_commission() set search_path = public;
alter function public.forbid_ledger_mutation() set search_path = public;
alter function public.protect_company_admin_fields() set search_path = public;
alter function public.occupancy_type_for(integer) set search_path = public;

-- Trigger functions are invoked by their triggers and must not also be public
-- RPC endpoints. This covers current and future SECURITY DEFINER triggers.
do $$
declare trigger_function regprocedure;
begin
  for trigger_function in
    select distinct p.oid::regprocedure
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    join pg_trigger t on t.tgfoid = p.oid and not t.tgisinternal
    where n.nspname = 'public' and p.prosecdef
  loop
    execute 'revoke execute on function ' || trigger_function
      || ' from public, anon, authenticated';
  end loop;
end $$;

-- These callable functions retain authenticated access because their bodies
-- enforce user/admin ownership. Anonymous callers never need them.
revoke execute on function public.add_ledger_adjustment(uuid,bigint,text)
  from public, anon;
revoke execute on function public.create_payout(uuid,bigint,text,date,date)
  from public, anon;
revoke execute on function public.complete_payout(uuid,text)
  from public, anon;
revoke execute on function public.fail_payout(uuid)
  from public, anon;
revoke execute on function public.initiate_payment(uuid,bigint,payment_method,text)
  from public, anon;
revoke execute on function public.refund_booking(uuid,bigint)
  from public, anon;
revoke execute on function public.delete_my_account()
  from public, anon;
grant execute on function public.delete_my_account() to authenticated;
