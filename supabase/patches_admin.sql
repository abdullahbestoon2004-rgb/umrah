-- ============================================================================
-- PATCH — admin features: home ads carousel, featured offers, and two
-- security fixes. Run once in: Supabase Dashboard > SQL Editor. Safe to re-run.
-- ============================================================================

-- 1. SECURITY FIX: sign-up metadata could self-assign the 'admin' role.
--    Only 'client' and 'agency' may come from the client; admin is granted
--    manually (step 5 below).
create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, role, full_name, phone)
  values (
    new.id,
    case new.raw_user_meta_data->>'role'
      when 'agency' then 'agency'::user_role
      else 'client'::user_role
    end,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone'
  );
  return new;
end; $$;

-- 2. SECURITY FIX: the "update own profile" policy let users change any
--    column — including role. Restrict updates to safe columns only.
--    (two_factor_enabled intentionally omitted — patches.sql #11 drops that
--    column; the 2FA toggle was removed as it never had a real implementation.
--    preferred_pay_method, added by patches.sql #10, is granted there too —
--    not repeated here so this file has no ordering dependency on patches.sql.)
revoke update on profiles from authenticated;
grant update (full_name, phone, marketing_emails, share_activity)
  on profiles to authenticated;

-- 3. Home ads carousel — paid agency placements, managed by the admin.
create table if not exists home_ads (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid references companies(id) on delete cascade,
  package_id  uuid references packages(id) on delete set null,
  title       text not null,
  title_ar    text,
  title_en    text,
  image_url   text,
  sort_order  int not null default 0,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);
alter table home_ads enable row level security;

drop policy if exists "public read active ads" on home_ads;
create policy "public read active ads" on home_ads for select
  using (is_active or is_admin());

drop policy if exists "admin manage ads" on home_ads;
create policy "admin manage ads" on home_ads for all
  using (is_admin())
  with check (is_admin());

-- 4. Featured offers — admin picks what shows first on the home screen.
alter table packages add column if not exists is_featured boolean not null default false;

-- 5. Promote YOUR account to admin (your existing app login).
update profiles set role = 'admin'
where id = (select id from auth.users where email = 'abdullahbestoon2004@gmail.com');

-- 6. SECURITY FIX: "agency update own company" only checks owner_id, so any
--    agency could PATCH its own is_verified/is_active straight to true and
--    skip vetting entirely — column grants can't stop this because admins
--    update the same is_verified column through the same authenticated role
--    (verifyCompany() in supabase_service.dart), so the fix has to live in a
--    trigger that can tell the two apart via is_admin(), not a blanket grant.
create or replace function protect_company_admin_fields()
returns trigger language plpgsql as $$
begin
  if not is_admin() then
    new.is_verified := old.is_verified;
    new.is_active   := old.is_active;
    new.rating      := old.rating;
    new.owner_id    := old.owner_id;
  end if;
  return new;
end; $$;

drop trigger if exists before_company_update on companies;
create trigger before_company_update
  before update on companies
  for each row execute function protect_company_admin_fields();
