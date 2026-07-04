-- ============================================================================
-- PATCHES — run once in: Supabase Dashboard > SQL Editor > New query
-- (after schema.sql). Safe to re-run.
-- ============================================================================

-- 1. Let clients cancel their own bookings (the app's "Cancel booking" button).
--    Without this, only agencies/admins can update bookings.
drop policy if exists "client cancel own booking" on bookings;
create policy "client cancel own booking" on bookings for update
  using (client_id = auth.uid())
  with check (client_id = auth.uid() and status = 'cancelled');

-- 2. Agency profile text: about + tags shown on the agency page.
alter table companies add column if not exists about text default '';
alter table companies add column if not exists tags text[] default '{}';

-- 3. Storage bucket for package cover images uploaded by agencies.
insert into storage.buckets (id, name, public)
values ('package-images', 'package-images', true)
on conflict (id) do nothing;

drop policy if exists "agencies upload package images" on storage.objects;
create policy "agencies upload package images" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'package-images');

drop policy if exists "agencies update package images" on storage.objects;
create policy "agencies update package images" on storage.objects
  for update to authenticated
  using (bucket_id = 'package-images');

drop policy if exists "public read package images" on storage.objects;
create policy "public read package images" on storage.objects
  for select using (bucket_id = 'package-images');

-- 4. Self-service account deletion (required by the app stores).
--    Runs as definer so the signed-in user can delete their own auth row;
--    profiles/companies/bookings cascade from auth.users.
create or replace function delete_my_account()
returns void language sql security definer set search_path = public as $$
  delete from auth.users where id = auth.uid();
$$;
revoke execute on function delete_my_account() from anon;
