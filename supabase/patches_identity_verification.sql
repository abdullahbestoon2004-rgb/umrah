-- Private user identity documents and profile references.
-- Safe to re-run in the Supabase SQL editor.

alter table public.profiles
  add column if not exists passport_photo_url text,
  add column if not exists selfie_photo_url text,
  add column if not exists identity_verification_status text not null default 'not_submitted',
  add column if not exists identity_verification_submitted_at timestamptz;

do $$ begin
  alter table public.profiles
    add constraint profiles_identity_verification_status_check
    check (identity_verification_status in
      ('not_submitted', 'pending', 'approved', 'rejected'));
exception when duplicate_object then null;
end $$;

-- Existing ownership RLS still applies. Column grants prevent users from
-- changing role or any unrelated profile field through this feature.
grant update (
  passport_photo_url,
  selfie_photo_url,
  identity_verification_status,
  identity_verification_submitted_at
) on public.profiles to authenticated;

-- A client may submit documents, but may never approve their own identity.
-- Also ensure stored object references always stay inside their own folder.
create or replace function public.protect_identity_verification_fields()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
begin
  if not public.is_admin() then
    if new.passport_photo_url is distinct from old.passport_photo_url
       and new.passport_photo_url not like ((select auth.uid())::text || '/%')
    then
      raise exception 'invalid passport photo path';
    end if;
    if new.selfie_photo_url is distinct from old.selfie_photo_url
       and new.selfie_photo_url not like ((select auth.uid())::text || '/%')
    then
      raise exception 'invalid selfie photo path';
    end if;

    if new.passport_photo_url is distinct from old.passport_photo_url
       or new.selfie_photo_url is distinct from old.selfie_photo_url
    then
      new.identity_verification_status := 'pending';
      new.identity_verification_submitted_at := now();
    else
      new.identity_verification_status := old.identity_verification_status;
      new.identity_verification_submitted_at :=
        old.identity_verification_submitted_at;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_identity_verification_fields on public.profiles;
create trigger protect_identity_verification_fields
before update of passport_photo_url, selfie_photo_url,
  identity_verification_status, identity_verification_submitted_at
on public.profiles
for each row execute function public.protect_identity_verification_fields();

insert into storage.buckets (id, name, public)
values ('identity_verifications', 'identity_verifications', false)
on conflict (id) do update set public = false;

drop policy if exists "users upload own identity documents" on storage.objects;
create policy "users upload own identity documents"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'identity_verifications'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

-- Upsert needs SELECT and UPDATE in addition to INSERT.
drop policy if exists "users read own identity documents" on storage.objects;
create policy "users read own identity documents"
on storage.objects for select
to authenticated
using (
  bucket_id = 'identity_verifications'
  and (
    (storage.foldername(name))[1] = (select auth.uid())::text
    or public.is_admin()
  )
);

drop policy if exists "users replace own identity documents" on storage.objects;
create policy "users replace own identity documents"
on storage.objects for update
to authenticated
using (
  bucket_id = 'identity_verifications'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'identity_verifications'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);
