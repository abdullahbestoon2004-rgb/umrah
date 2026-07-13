-- ============================================================================
-- UMRAH MARKETPLACE — offers, public agency profiles, badges and moderation
-- Apply after patches_workflow.sql and patches_payments.sql.
--
-- This is additive and preserves the legacy `companies` / `packages` names
-- used by the Flutter app. In product language those tables are Agencies and
-- Offers. All new public-schema tables have RLS enabled explicitly.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Public agency profile and approval state
-- ---------------------------------------------------------------------------
alter table companies add column if not exists status text;
alter table companies add column if not exists first_offer_approved boolean not null default false;
alter table companies add column if not exists license_number text;
alter table companies add column if not exists about_ar text;
alter table companies add column if not exists about_en text;
alter table companies add column if not exists office_address text;
alter table companies add column if not exists phone text;
alter table companies add column if not exists whatsapp text;
alter table companies add column if not exists office_hours text;
alter table companies add column if not exists branches jsonb not null default '[]'::jsonb;
alter table companies add column if not exists gallery_urls text[] not null default '{}';
alter table companies add column if not exists intro_video_url text;
alter table companies add column if not exists cancellation_policy text;
alter table companies add column if not exists cancellation_policy_ar text;
alter table companies add column if not exists cancellation_policy_en text;
alter table companies add column if not exists accepted_payment_methods text[] not null default array['cash'];
alter table companies add column if not exists pilgrims_served int not null default 0;
alter table companies add column if not exists median_response_minutes int;
alter table companies add column if not exists verification_details text[] not null default '{}';

update companies
set status = case verification_status
  when 'approved' then 'active'
  when 'suspended' then 'suspended'
  when 'rejected' then 'rejected'
  else 'pending'
end
where status is null;

alter table companies alter column status set default 'pending';
alter table companies alter column status set not null;
update companies c set first_offer_approved = true
where exists(select 1 from packages p where p.company_id = c.id and p.is_published);
do $$ begin
  alter table companies add constraint companies_status_check
    check (status in ('pending','active','rejected','suspended'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table companies add constraint companies_payment_methods_check
    check (accepted_payment_methods <@ array['fib','card','cash']);
exception when duplicate_object then null; end $$;
create index if not exists companies_status_idx on companies(status, created_at desc);

create table if not exists agency_status_history (
  id          bigint generated always as identity primary key,
  agency_id   uuid not null references companies(id) on delete cascade,
  old_status  text,
  new_status  text not null check (new_status in ('pending','active','rejected','suspended')),
  changed_by  uuid references profiles(id) on delete set null,
  reason      text,
  created_at  timestamptz not null default now()
);
create index if not exists agency_status_history_agency_idx
  on agency_status_history(agency_id, created_at desc);
alter table agency_status_history enable row level security;

create table if not exists agency_documents (
  id             uuid primary key default gen_random_uuid(),
  agency_id      uuid not null references companies(id) on delete cascade,
  document_type  text not null,
  storage_path   text not null,
  file_name      text,
  mime_type      text,
  expires_on     date,
  status         text not null default 'pending'
                 check (status in ('pending','approved','rejected','expired')),
  admin_feedback text,
  created_at     timestamptz not null default now(),
  reviewed_at    timestamptz,
  reviewed_by    uuid references profiles(id) on delete set null
);
create index if not exists agency_documents_agency_idx
  on agency_documents(agency_id, created_at desc);
alter table agency_documents enable row level security;

create table if not exists agency_media (
  id          uuid primary key default gen_random_uuid(),
  agency_id   uuid not null references companies(id) on delete cascade,
  media_type  text not null default 'photo' check (media_type in ('photo','video')),
  url         text not null,
  caption     text,
  caption_ar  text,
  caption_en  text,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);
alter table agency_media enable row level security;

create table if not exists agency_reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid not null references profiles(id) on delete restrict,
  agency_id    uuid not null references companies(id) on delete restrict,
  reason       text not null,
  details      text,
  status       text not null default 'open'
               check (status in ('open','reviewing','resolved')),
  resolution   text,
  resolved_by  uuid references profiles(id) on delete set null,
  created_at   timestamptz not null default now(),
  resolved_at  timestamptz
);
create index if not exists agency_reports_queue_idx
  on agency_reports(status, created_at desc);
alter table agency_reports enable row level security;

-- ---------------------------------------------------------------------------
-- 2. Badge catalogue and assignments
-- ---------------------------------------------------------------------------
create table if not exists badges (
  id       uuid primary key default gen_random_uuid(),
  key      text not null unique,
  name_ku  text not null,
  name_ar  text not null,
  name_en  text not null,
  icon     text not null,
  type     text not null check (type in ('manual','auto'))
);
alter table badges enable row level security;

create table if not exists agency_badges (
  agency_id   uuid not null references companies(id) on delete cascade,
  badge_id    uuid not null references badges(id) on delete cascade,
  assigned_by uuid references profiles(id) on delete set null,
  assigned_at timestamptz not null default now(),
  primary key (agency_id, badge_id)
);
create index if not exists agency_badges_agency_idx on agency_badges(agency_id);
alter table agency_badges enable row level security;

insert into badges(key, name_ku, name_ar, name_en, icon, type) values
  ('verified', 'پشتڕاستکراو', 'موثّقة', 'Verified', 'verified', 'manual'),
  ('premium_partner', 'هاوبەشی پلەبەرز', 'شريك مميز', 'Premium Partner', 'workspace_premium', 'manual'),
  ('top_rated', 'باشترین هەڵسەنگاندن', 'الأعلى تقييماً', 'Top Rated', 'star', 'auto'),
  ('fast_responder', 'وەڵامدەرەوەی خێرا', 'سريع الاستجابة', 'Fast Responder', 'schedule', 'auto'),
  ('new', 'نوێ', 'جديدة', 'New', 'new_releases', 'auto')
on conflict (key) do update set
  name_ku = excluded.name_ku, name_ar = excluded.name_ar,
  name_en = excluded.name_en, icon = excluded.icon, type = excluded.type;

insert into agency_badges(agency_id, badge_id)
select c.id, b.id from companies c cross join badges b
where c.status = 'active' and c.is_verified and b.key = 'verified'
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- 3. Rich offer content
-- ---------------------------------------------------------------------------
alter table packages add column if not exists package_tier text not null default 'standard';
alter table packages add column if not exists group_type text not null default 'group';
alter table packages add column if not exists season_tag text not null default 'regular';
alter table packages add column if not exists departure_airport text;
alter table packages add column if not exists airline_name text;
alter table packages add column if not exists airline_logo_url text;
alter table packages add column if not exists flight_type text;
alter table packages add column if not exists bus_between_cities boolean not null default false;
alter table packages add column if not exists airport_transfers boolean not null default false;
alter table packages add column if not exists transport_notes text;
alter table packages add column if not exists meals_per_day int;
alter table packages add column if not exists video_url text;
alter table packages add column if not exists cancellation_policy text;
alter table packages add column if not exists cancellation_policy_ar text;
alter table packages add column if not exists cancellation_policy_en text;
alter table packages add column if not exists deposit_iqd bigint not null default 0;
alter table packages add column if not exists non_refundable_deposit boolean not null default false;
alter table packages add column if not exists deposit_terms text;
alter table packages add column if not exists deposit_terms_ar text;
alter table packages add column if not exists deposit_terms_en text;
alter table packages add column if not exists accepted_payment_methods text[] not null default array['cash'];
alter table packages add column if not exists force_unpublish_reason text;

do $$ begin
  alter table packages add constraint packages_tier_check
    check (package_tier in ('economy','standard','vip'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_group_type_check
    check (group_type in ('family','individual','group'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_season_tag_check
    check (season_tag in ('ramadan','regular','shawwal','other'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_airport_check
    check (departure_airport is null or departure_airport in ('EBL','BGW','ISU'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_flight_type_check
    check (flight_type is null or flight_type in ('direct','connecting'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_deposit_check
    check (deposit_iqd >= 0 and deposit_iqd <= price_iqd);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_offer_payment_methods_check
    check (accepted_payment_methods <@ array['fib','card','cash']);
exception when duplicate_object then null; end $$;

create table if not exists offer_pricing (
  offer_id       uuid not null references packages(id) on delete cascade,
  occupancy_type text not null check (occupancy_type in ('double','triple','quad','quintuple')),
  price_iqd      bigint not null check (price_iqd > 0),
  price_usd      numeric(10,2) check (price_usd is null or price_usd > 0),
  primary key (offer_id, occupancy_type)
);
alter table offer_pricing enable row level security;

-- Backfill the legacy single price without changing existing client results.
insert into offer_pricing(offer_id, occupancy_type, price_iqd)
select id, case
  when 2 = any(room_occupancies) then 'double'
  when 3 = any(room_occupancies) then 'triple'
  when 4 = any(room_occupancies) then 'quad'
  else 'double' end,
  price_iqd
from packages
on conflict (offer_id, occupancy_type) do nothing;

create table if not exists hotels (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  name_ar     text,
  name_en     text,
  city        text not null check (city in ('makkah','madinah')),
  star_rating int not null check (star_rating between 1 and 5),
  photo_urls  text[] not null default '{}',
  created_by  uuid references profiles(id) on delete set null,
  created_at  timestamptz not null default now()
);
create index if not exists hotels_city_name_idx on hotels(city, name);
alter table hotels enable row level security;

create table if not exists offer_hotels (
  offer_id               uuid not null references packages(id) on delete cascade,
  hotel_id               uuid not null references hotels(id) on delete restrict,
  city                   text not null check (city in ('makkah','madinah')),
  nights                 int not null check (nights >= 0),
  distance_from_haram_m  int not null check (distance_from_haram_m >= 0),
  primary key (offer_id, city)
);
alter table offer_hotels enable row level security;

create table if not exists offer_inclusions (
  id          uuid primary key default gen_random_uuid(),
  offer_id    uuid not null references packages(id) on delete cascade,
  type        text not null,
  included    boolean not null,
  details     text,
  details_ar  text,
  details_en  text,
  sort_order  int not null default 0,
  unique (offer_id, type)
);
alter table offer_inclusions enable row level security;

create table if not exists offer_media (
  id          uuid primary key default gen_random_uuid(),
  offer_id    uuid not null references packages(id) on delete cascade,
  media_type  text not null default 'photo' check (media_type in ('photo','video')),
  url         text not null,
  caption     text,
  caption_ar  text,
  caption_en  text,
  sort_order  int not null default 0
);
alter table offer_media enable row level security;

-- ---------------------------------------------------------------------------
-- 4. Inquiries, carousel requests and review moderation
-- ---------------------------------------------------------------------------
create table if not exists inquiries (
  id                 uuid primary key default gen_random_uuid(),
  client_id          uuid not null references profiles(id) on delete restrict,
  agency_id          uuid not null references companies(id) on delete restrict,
  offer_id           uuid references packages(id) on delete set null,
  status             text not null default 'open' check (status in ('open','closed')),
  first_agency_reply_at timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
alter table inquiries enable row level security;

create table if not exists inquiry_messages (
  id          uuid primary key default gen_random_uuid(),
  inquiry_id  uuid not null references inquiries(id) on delete cascade,
  sender_id   uuid not null references profiles(id) on delete restrict,
  body        text not null check (length(btrim(body)) > 0),
  created_at  timestamptz not null default now()
);
create index if not exists inquiry_messages_thread_idx
  on inquiry_messages(inquiry_id, created_at);
alter table inquiry_messages enable row level security;

create table if not exists carousel_requests (
  id                 uuid primary key default gen_random_uuid(),
  agency_id          uuid not null references companies(id) on delete restrict,
  offer_id           uuid references packages(id) on delete set null,
  requested_start    date not null,
  requested_end      date not null,
  scheduled_start    date,
  scheduled_end      date,
  slot_order         int,
  amount_iqd         bigint not null check (amount_iqd >= 0),
  payment_method     text check (payment_method in ('fib','card')),
  payment_status     text not null default 'unpaid'
                     check (payment_status in ('unpaid','paid','refunded')),
  status             text not null default 'requested'
                     check (status in ('requested','paid','approved','live','completed','rejected')),
  rejection_reason   text,
  created_at         timestamptz not null default now(),
  reviewed_at        timestamptz,
  reviewed_by        uuid references profiles(id) on delete set null,
  check (requested_end >= requested_start),
  check (scheduled_end is null or scheduled_start is null or scheduled_end >= scheduled_start)
);
create index if not exists carousel_requests_queue_idx
  on carousel_requests(status, requested_start);
alter table carousel_requests enable row level security;

alter table reviews add column if not exists public_reply text;
alter table reviews add column if not exists replied_at timestamptz;
alter table reviews add column if not exists moderation_status text not null default 'visible';
alter table reviews add column if not exists flagged_reason text;
do $$ begin
  alter table reviews add constraint reviews_moderation_status_check
    check (moderation_status in ('visible','flagged','removed'));
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------------
-- 5. Internal commercial configuration (never exposed to clients)
-- ---------------------------------------------------------------------------
create table if not exists agency_commercial_settings (
  agency_id       uuid primary key references companies(id) on delete cascade,
  commission_tier text not null default 'standard'
                  check (commission_tier in ('standard','preferred','custom')),
  commission_rate numeric(5,4) not null default 0.0500
                  check (commission_rate >= 0 and commission_rate <= 1),
  updated_by      uuid references profiles(id) on delete set null,
  updated_at      timestamptz not null default now()
);
alter table agency_commercial_settings enable row level security;

create table if not exists offer_commercial_settings (
  offer_id         uuid primary key references packages(id) on delete cascade,
  commission_rate numeric(5,4) check (commission_rate is null or (commission_rate >= 0 and commission_rate <= 1)),
  updated_by       uuid references profiles(id) on delete set null,
  updated_at       timestamptz not null default now()
);
alter table offer_commercial_settings enable row level security;

insert into agency_commercial_settings(agency_id, commission_rate)
select id, commission_rate from companies
on conflict (agency_id) do nothing;
insert into offer_commercial_settings(offer_id, commission_rate)
select id, commission_rate from packages where commission_rate is not null
on conflict (offer_id) do nothing;

-- Values remain as compatibility placeholders in legacy public columns; the
-- resolver below reads only the protected settings tables.
update companies set commission_rate = 0.0500;
update packages set commission_rate = null;

create or replace function resolve_commission_rate(p_package_id uuid)
returns numeric language sql stable security definer set search_path = public as $$
  select coalesce(os.commission_rate, acs.commission_rate, 0.0500)
  from packages p
  left join offer_commercial_settings os on os.offer_id = p.id
  left join agency_commercial_settings acs on acs.agency_id = p.company_id
  where p.id = p_package_id;
$$;
revoke execute on function resolve_commission_rate(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 6. RLS policies
-- ---------------------------------------------------------------------------
create or replace function can_read_offer(p_offer_id uuid)
returns boolean language sql stable security invoker set search_path = public as $$
  select exists (
    select 1 from packages p join companies c on c.id = p.company_id
    where p.id = p_offer_id and (
      (p.lifecycle_status = 'published' and p.is_published
       and (p.departure_date is null or p.departure_date >= current_date)
       and c.status = 'active' and c.is_active and c.is_verified)
      or owns_company(p.company_id) or is_admin()
    )
  );
$$;

create or replace function can_manage_offer(p_offer_id uuid)
returns boolean language sql stable security invoker set search_path = public as $$
  select exists(select 1 from packages p where p.id = p_offer_id
                and (owns_company(p.company_id) or is_admin()));
$$;

drop policy if exists "public read companies" on companies;
create policy "public read active agencies" on companies for select
to anon, authenticated
using ((status = 'active' and is_active and is_verified)
       or owner_id = (select auth.uid()) or is_admin());

drop policy if exists "public read packages" on packages;
drop policy if exists "read visible offers" on packages;
create policy "read visible offers" on packages for select
to anon, authenticated using (
  lifecycle_status = 'published'
  and is_published
  and (departure_date is null or departure_date >= current_date)
  and exists (
    select 1 from companies c
    where c.id = packages.company_id
      and c.status = 'active'
      and c.is_active
      and c.is_verified
  )
);

create policy "read badges" on badges for select to anon, authenticated using (true);
create policy "read visible agency badges" on agency_badges for select to anon, authenticated
using (exists(select 1 from companies c where c.id = agency_id
              and ((c.status = 'active' and c.is_active and c.is_verified)
                   or c.owner_id = (select auth.uid()) or is_admin())));
create policy "admin assign badges" on agency_badges for insert to authenticated
with check (is_admin());
create policy "admin remove badges" on agency_badges for delete to authenticated
using (is_admin());

create policy "owner and admin read status history" on agency_status_history for select
to authenticated using (owns_company(agency_id) or is_admin());
create policy "owner and admin read documents" on agency_documents for select
to authenticated using (owns_company(agency_id) or is_admin());
create policy "owner upload documents" on agency_documents for insert
to authenticated with check (owns_company(agency_id));
create policy "admin review documents" on agency_documents for update
to authenticated using (is_admin()) with check (is_admin());

create policy "read public agency media" on agency_media for select to anon, authenticated
using (exists(select 1 from companies c where c.id = agency_id
              and ((c.status = 'active' and c.is_active and c.is_verified)
                   or c.owner_id = (select auth.uid()) or is_admin())));
create policy "owner manage agency media" on agency_media for all to authenticated
using (owns_company(agency_id) or is_admin())
with check (owns_company(agency_id) or is_admin());

create policy "client create agency report" on agency_reports for insert to authenticated
with check (reporter_id = (select auth.uid())
  and exists(select 1 from profiles p where p.id = (select auth.uid()) and p.role = 'client'));
create policy "reporter or admin read report" on agency_reports for select to authenticated
using (reporter_id = (select auth.uid()) or is_admin());
create policy "admin resolve reports" on agency_reports for update to authenticated
using (is_admin()) with check (is_admin());

create policy "read offer pricing" on offer_pricing for select to anon, authenticated
using (can_read_offer(offer_id));
create policy "manage own offer pricing" on offer_pricing for all to authenticated
using (can_manage_offer(offer_id)) with check (can_manage_offer(offer_id));
create policy "read hotels" on hotels for select to anon, authenticated
using (exists(select 1 from offer_hotels oh where oh.hotel_id = id and can_read_offer(oh.offer_id))
       or is_admin());
create policy "agency create hotels" on hotels for insert to authenticated
with check (created_by = (select auth.uid()) and exists(
  select 1 from profiles p where p.id = (select auth.uid()) and p.role = 'agency'));
create policy "admin manage hotels" on hotels for all to authenticated
using (is_admin()) with check (is_admin());
create policy "read offer hotels" on offer_hotels for select to anon, authenticated
using (can_read_offer(offer_id));
create policy "manage own offer hotels" on offer_hotels for all to authenticated
using (can_manage_offer(offer_id)) with check (can_manage_offer(offer_id));
create policy "read offer inclusions" on offer_inclusions for select to anon, authenticated
using (can_read_offer(offer_id));
create policy "manage own offer inclusions" on offer_inclusions for all to authenticated
using (can_manage_offer(offer_id)) with check (can_manage_offer(offer_id));
create policy "read offer media" on offer_media for select to anon, authenticated
using (can_read_offer(offer_id));
create policy "manage own offer media" on offer_media for all to authenticated
using (can_manage_offer(offer_id)) with check (can_manage_offer(offer_id));

create policy "participants read inquiries" on inquiries for select to authenticated
using (client_id = (select auth.uid()) or owns_company(agency_id) or is_admin());
create policy "client starts inquiry" on inquiries for insert to authenticated
with check (client_id = (select auth.uid()) and exists(
  select 1 from profiles p where p.id = (select auth.uid()) and p.role = 'client'));
create policy "participants update inquiries" on inquiries for update to authenticated
using (client_id = (select auth.uid()) or owns_company(agency_id) or is_admin())
with check (client_id = (select auth.uid()) or owns_company(agency_id) or is_admin());
create policy "participants read inquiry messages" on inquiry_messages for select to authenticated
using (exists(select 1 from inquiries i where i.id = inquiry_id
  and (i.client_id = (select auth.uid()) or owns_company(i.agency_id) or is_admin())));
create policy "participants send inquiry messages" on inquiry_messages for insert to authenticated
with check (sender_id = (select auth.uid()) and exists(
  select 1 from inquiries i where i.id = inquiry_id
  and (i.client_id = (select auth.uid()) or owns_company(i.agency_id) or is_admin())));

create policy "owner read carousel requests" on carousel_requests for select to authenticated
using (owns_company(agency_id) or is_admin());
create policy "owner request carousel" on carousel_requests for insert to authenticated
with check (owns_company(agency_id) and status = 'requested' and payment_status = 'unpaid');
create policy "admin manage carousel requests" on carousel_requests for update to authenticated
using (is_admin()) with check (is_admin());

create policy "agency read own commercial settings" on agency_commercial_settings for select
to authenticated using (owns_company(agency_id) or is_admin());
create policy "admin manage agency commercial settings" on agency_commercial_settings for all
to authenticated using (is_admin()) with check (is_admin());
create policy "agency read own offer commercial settings" on offer_commercial_settings for select
to authenticated using (can_manage_offer(offer_id));
create policy "admin manage offer commercial settings" on offer_commercial_settings for all
to authenticated using (is_admin()) with check (is_admin());

-- Hide moderated reviews from public readers while preserving owner/admin access.
drop policy if exists "public read reviews" on reviews;
create policy "read visible reviews" on reviews for select to anon, authenticated
using (moderation_status = 'visible' or owns_company(company_id) or is_admin());
create policy "agency reply to own reviews" on reviews for update to authenticated
using (owns_company(company_id) or is_admin())
with check (owns_company(company_id) or is_admin());

create or replace function protect_review_reply_and_moderation()
returns trigger language plpgsql security invoker set search_path = public as $$
begin
  if not is_admin() then
    new.moderation_status := old.moderation_status;
    new.flagged_reason := old.flagged_reason;
    new.rating := old.rating;
    new.comment := old.comment;
    if nullif(old.public_reply, '') is not null
       and new.public_reply is distinct from old.public_reply then
      raise exception 'an agency reply cannot be edited';
    end if;
  end if;
  return new;
end; $$;
drop trigger if exists before_review_update_protect on reviews;
create trigger before_review_update_protect before update on reviews
for each row execute function protect_review_reply_and_moderation();
revoke update on reviews from authenticated;

-- ---------------------------------------------------------------------------
-- 7. Privileged workflow APIs and automatic state
-- ---------------------------------------------------------------------------
create or replace function review_company_application(
  p_company_id uuid, p_decision text, p_reason text default null
) returns void language plpgsql security definer set search_path = public as $$
declare c companies%rowtype;
declare new_public_status text;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  if p_decision not in ('approved','needs_changes','rejected','suspended','reinstated') then
    raise exception 'invalid company decision';
  end if;
  if p_decision not in ('approved','reinstated') and nullif(btrim(p_reason), '') is null then
    raise exception 'a reason is required';
  end if;
  select * into c from companies where id = p_company_id for update;
  if c.id is null then raise exception 'company not found'; end if;
  new_public_status := case
    when p_decision in ('approved','reinstated') then 'active'
    when p_decision = 'suspended' then 'suspended'
    when p_decision = 'rejected' then 'rejected'
    else 'pending' end;
  update companies set
    verification_status = case when p_decision = 'reinstated' then 'approved' else p_decision end,
    status = new_public_status,
    verification_reason = nullif(btrim(p_reason), ''), reviewed_at = now(),
    reviewed_by = auth.uid(), is_verified = (new_public_status = 'active'),
    is_active = (new_public_status = 'active')
  where id = p_company_id;
  insert into agency_status_history(agency_id, old_status, new_status, changed_by, reason)
  values (c.id, c.status, new_public_status, auth.uid(), nullif(btrim(p_reason), ''));
  if new_public_status = 'active' then
    insert into agency_badges(agency_id, badge_id, assigned_by)
      select c.id, id, auth.uid() from badges where key in ('verified','new')
      on conflict do nothing;
  elsif new_public_status = 'suspended' then
    update packages set is_published = false, lifecycle_status = 'paused',
      force_unpublish_reason = coalesce(nullif(btrim(p_reason), ''), 'Agency suspended')
    where company_id = c.id and lifecycle_status = 'published';
  end if;
  perform write_audit('company', c.id, p_decision,
    jsonb_build_object('status', c.status), jsonb_build_object('status', new_public_status), p_reason);
  insert into notifications(user_id, type, arg)
    values (c.owner_id, 'companyReview', coalesce(p_reason, p_decision));
end; $$;

create or replace function submit_package(p_package_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare p packages%rowtype;
declare first_already_approved boolean;
declare next_status text;
begin
  select * into p from packages where id = p_package_id for update;
  if p.id is null or not owns_company(p.company_id) then raise exception 'not your package'; end if;
  select first_offer_approved into first_already_approved from companies
    where id = p.company_id and status = 'active' and is_active and is_verified;
  if first_already_approved is null then raise exception 'company is not active'; end if;
  if p.lifecycle_status not in ('draft','needs_changes','rejected','paused') then
    raise exception 'package cannot be submitted from %', p.lifecycle_status;
  end if;
  next_status := case when first_already_approved then 'published' else 'pending_review' end;
  update packages set lifecycle_status = next_status,
    is_published = (next_status = 'published'), review_reason = null, submitted_at = now()
  where id = p_package_id;
  perform write_audit('package', p.id, 'submitted',
    jsonb_build_object('status', p.lifecycle_status), jsonb_build_object('status', next_status), null);
end; $$;

create or replace function review_package(
  p_package_id uuid, p_decision text, p_reason text default null
) returns void language plpgsql security definer set search_path = public as $$
declare p packages%rowtype;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  if p_decision not in ('published','needs_changes','rejected','paused') then
    raise exception 'invalid package decision';
  end if;
  if p_decision <> 'published' and nullif(btrim(p_reason), '') is null then
    raise exception 'a reason is required';
  end if;
  select * into p from packages where id = p_package_id for update;
  if p.id is null then raise exception 'package not found'; end if;
  update packages set lifecycle_status = p_decision,
    is_published = (p_decision = 'published'), review_reason = nullif(btrim(p_reason), ''),
    reviewed_at = now(), reviewed_by = auth.uid() where id = p_package_id;
  if p_decision = 'published' then
    update companies set first_offer_approved = true where id = p.company_id;
  end if;
  perform write_audit('package', p.id, 'reviewed',
    jsonb_build_object('status', p.lifecycle_status), jsonb_build_object('status', p_decision), p_reason);
  perform notify_company_owner(p.company_id, 'packageReview', coalesce(p_reason, p_decision), null);
end; $$;

create or replace function admin_set_agency_badge(
  p_agency_id uuid, p_badge_key text, p_enabled boolean
) returns void language plpgsql security definer set search_path = public as $$
declare bid uuid;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  select id into bid from badges where key = p_badge_key and type = 'manual';
  if bid is null then raise exception 'manual badge not found'; end if;
  if p_enabled then
    insert into agency_badges(agency_id, badge_id, assigned_by)
      values (p_agency_id, bid, auth.uid()) on conflict do nothing;
  else
    delete from agency_badges where agency_id = p_agency_id and badge_id = bid;
  end if;
  perform write_audit('company', p_agency_id, 'badge_changed', '{}'::jsonb,
    jsonb_build_object('badge', p_badge_key, 'enabled', p_enabled), null);
end; $$;

create or replace function admin_force_unpublish_offer(
  p_offer_id uuid, p_reason text
) returns void language plpgsql security definer set search_path = public as $$
declare p packages%rowtype;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  if nullif(btrim(p_reason), '') is null then raise exception 'a reason is required'; end if;
  select * into p from packages where id = p_offer_id for update;
  if p.id is null then raise exception 'offer not found'; end if;
  update packages set lifecycle_status = 'paused', is_published = false,
    force_unpublish_reason = btrim(p_reason), review_reason = btrim(p_reason)
  where id = p_offer_id;
  perform write_audit('package', p_offer_id, 'force_unpublished',
    jsonb_build_object('status', p.lifecycle_status),
    jsonb_build_object('status', 'paused'), p_reason);
  perform notify_company_owner(p.company_id, 'packageReview', p_reason, null);
end; $$;

create or replace function recompute_auto_badges(p_agency_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c companies%rowtype;
begin
  select * into c from companies where id = p_agency_id;
  if c.id is null then return; end if;
  delete from agency_badges ab using badges b
    where ab.badge_id = b.id and ab.agency_id = c.id and b.type = 'auto';
  insert into agency_badges(agency_id, badge_id)
    select c.id, b.id from badges b where
      (b.key = 'top_rated' and c.rating >= 4.5 and c.reviews >= 10)
      or (b.key = 'fast_responder' and c.median_response_minutes is not null
          and c.median_response_minutes < 120)
      or (b.key = 'new' and c.status = 'active'
          and coalesce(c.reviewed_at, c.created_at) >= now() - interval '3 months')
  on conflict do nothing;
end; $$;
revoke execute on function recompute_auto_badges(uuid) from public, anon, authenticated;

create or replace function refresh_all_auto_badges()
returns void language plpgsql security definer set search_path = public as $$
declare agency record;
begin
  for agency in select id from companies loop
    perform recompute_auto_badges(agency.id);
  end loop;
end; $$;
revoke execute on function refresh_all_auto_badges() from public, anon, authenticated;

-- pg_cron is enabled from the Supabase dashboard on projects that want daily
-- expiry/new-badge maintenance. The dynamic call keeps this patch portable to
-- environments where the extension is not enabled yet.
do $$ begin
  if exists(select 1 from pg_namespace where nspname = 'cron') then
    execute $cron$select cron.schedule(
      'umrah-refresh-auto-badges', '15 2 * * *',
      'select public.refresh_all_auto_badges()'
    )$cron$;
  end if;
end $$;

create or replace function after_review_recompute_badges()
returns trigger language plpgsql security definer set search_path = public as $$
begin perform recompute_auto_badges(new.company_id); return new; end; $$;
drop trigger if exists after_review_badges on reviews;
create trigger after_review_badges after insert or update of rating on reviews
for each row execute function after_review_recompute_badges();

create or replace function maintain_offer_status()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.capacity is not null and new.seats_reserved >= new.capacity then
    new.lifecycle_status := 'sold_out'; new.is_published := false;
  elsif new.departure_date is not null and new.departure_date < current_date
        and new.lifecycle_status not in ('expired','draft') then
    new.lifecycle_status := 'expired'; new.is_published := false;
  elsif tg_op = 'UPDATE' and old.lifecycle_status = 'sold_out'
        and new.seats_reserved < coalesce(new.capacity, 2147483647) then
    new.lifecycle_status := 'published'; new.is_published := true;
  end if;
  return new;
end; $$;
drop trigger if exists before_packages_maintain_status on packages;
create trigger before_packages_maintain_status
before insert or update of seats_reserved, capacity, departure_date on packages
for each row execute function maintain_offer_status();

create or replace function after_inquiry_message_metrics()
returns trigger language plpgsql security definer set search_path = public as $$
declare iq inquiries%rowtype;
begin
  select * into iq from inquiries where id = new.inquiry_id for update;
  if iq.id is null then return new; end if;
  update inquiries set updated_at = now(),
    first_agency_reply_at = case
      when first_agency_reply_at is null and owns_company(iq.agency_id)
      then new.created_at else first_agency_reply_at end
  where id = iq.id;
  if owns_company(iq.agency_id) then
    update companies c set median_response_minutes = x.median_minutes
    from (
      select percentile_cont(0.5) within group (
        order by extract(epoch from (first_agency_reply_at - created_at)) / 60
      )::int as median_minutes
      from inquiries where agency_id = iq.agency_id and first_agency_reply_at is not null
    ) x where c.id = iq.agency_id;
    perform recompute_auto_badges(iq.agency_id);
  end if;
  return new;
end; $$;
drop trigger if exists after_inquiry_message_metrics on inquiry_messages;
create trigger after_inquiry_message_metrics after insert on inquiry_messages
for each row execute function after_inquiry_message_metrics();

create or replace function after_completed_booking_pilgrims()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.operational_stage = 'completed' and old.operational_stage is distinct from 'completed' then
    update companies set pilgrims_served = pilgrims_served + new.travellers where id = new.company_id;
  end if;
  return new;
end; $$;
drop trigger if exists after_completed_booking_pilgrims on bookings;
create trigger after_completed_booking_pilgrims after update of operational_stage on bookings
for each row execute function after_completed_booking_pilgrims();

-- Explicit RPC permissions. Every definer API checks auth/ownership internally.
revoke execute on function review_company_application(uuid,text,text) from public, anon;
revoke execute on function submit_package(uuid) from public, anon;
revoke execute on function review_package(uuid,text,text) from public, anon;
revoke execute on function admin_set_agency_badge(uuid,text,boolean) from public, anon;
revoke execute on function admin_force_unpublish_offer(uuid,text) from public, anon;
grant execute on function review_company_application(uuid,text,text) to authenticated;
grant execute on function submit_package(uuid) to authenticated;
grant execute on function review_package(uuid,text,text) to authenticated;
grant execute on function admin_set_agency_badge(uuid,text,boolean) to authenticated;
grant execute on function admin_force_unpublish_offer(uuid,text) to authenticated;

-- Expose the new Data API objects explicitly; RLS remains the row boundary.
grant select on badges, agency_badges, agency_status_history, agency_documents,
  agency_media, agency_reports, offer_pricing, hotels, offer_hotels,
  offer_inclusions, offer_media, inquiries, inquiry_messages, carousel_requests,
  agency_commercial_settings, offer_commercial_settings to authenticated;
grant select on badges, agency_badges, agency_media, offer_pricing, hotels,
  offer_hotels, offer_inclusions, offer_media to anon;
grant insert on agency_documents, agency_reports, agency_media, offer_pricing,
  hotels, offer_hotels, offer_inclusions, offer_media, inquiries,
  inquiry_messages, carousel_requests to authenticated;
grant update on agency_documents, agency_reports, agency_media, offer_pricing,
  offer_hotels, offer_inclusions, offer_media, inquiries, carousel_requests,
  agency_commercial_settings, offer_commercial_settings to authenticated;
grant delete on agency_media, offer_pricing, offer_hotels, offer_inclusions,
  offer_media, agency_badges to authenticated;
grant insert on agency_badges, agency_commercial_settings,
  offer_commercial_settings to authenticated;
grant usage, select on sequence agency_status_history_id_seq to authenticated;

-- Agencies may update rich public content, but not trust, lifecycle, badge, or
-- commercial columns. The workflow patch already revoked broad updates.
grant update (about_ar, about_en, license_number, office_address, phone,
  whatsapp, office_hours, branches, gallery_urls, intro_video_url,
  cancellation_policy, cancellation_policy_ar, cancellation_policy_en,
  accepted_payment_methods) on companies to authenticated;
grant insert (about_ar, about_en, license_number, office_address, phone,
  whatsapp, office_hours, branches, gallery_urls, intro_video_url,
  cancellation_policy, cancellation_policy_ar, cancellation_policy_en,
  accepted_payment_methods) on companies to authenticated;
grant update (package_tier, group_type, season_tag, departure_airport,
  airline_name, airline_logo_url, flight_type, bus_between_cities,
  airport_transfers, transport_notes, meals_per_day, video_url,
  cancellation_policy, cancellation_policy_ar, cancellation_policy_en,
  deposit_iqd, non_refundable_deposit, deposit_terms, deposit_terms_ar,
  deposit_terms_en, accepted_payment_methods) on packages to authenticated;
grant update (public_reply, replied_at) on reviews to authenticated;
grant insert (package_tier, group_type, season_tag, departure_airport,
  airline_name, airline_logo_url, flight_type, bus_between_cities,
  airport_transfers, transport_notes, meals_per_day, video_url,
  cancellation_policy, cancellation_policy_ar, cancellation_policy_en,
  deposit_iqd, non_refundable_deposit, deposit_terms, deposit_terms_ar,
  deposit_terms_en, accepted_payment_methods) on packages to authenticated;

-- ---------------------------------------------------------------------------
-- 8. Storage buckets and object ownership
-- ---------------------------------------------------------------------------
insert into storage.buckets(id, name, public) values
  ('agency-documents', 'agency-documents', false),
  ('agency-media', 'agency-media', true),
  ('offer-media', 'offer-media', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists "agency upload own documents" on storage.objects;
create policy "agency upload own documents" on storage.objects for insert
to authenticated with check (
  bucket_id = 'agency-documents' and exists(
    select 1 from companies c
    where c.id::text = (storage.foldername(name))[1]
      and c.owner_id = (select auth.uid())
  )
);
drop policy if exists "agency read own documents" on storage.objects;
create policy "agency read own documents" on storage.objects for select
to authenticated using (
  bucket_id = 'agency-documents' and (
    exists(select 1 from companies c
      where c.id::text = (storage.foldername(name))[1]
        and c.owner_id = (select auth.uid())) or is_admin()
  )
);
drop policy if exists "agency replace own documents" on storage.objects;
create policy "agency replace own documents" on storage.objects for update
to authenticated using (
  bucket_id = 'agency-documents' and exists(
    select 1 from companies c
    where c.id::text = (storage.foldername(name))[1]
      and c.owner_id = (select auth.uid())
  )
) with check (
  bucket_id = 'agency-documents' and exists(
    select 1 from companies c
    where c.id::text = (storage.foldername(name))[1]
      and c.owner_id = (select auth.uid())
  )
);

drop policy if exists "public read agency media" on storage.objects;
create policy "public read agency media" on storage.objects for select
to anon, authenticated using (bucket_id = 'agency-media');
drop policy if exists "agency upload own media" on storage.objects;
create policy "agency upload own media" on storage.objects for insert
to authenticated with check (
  bucket_id = 'agency-media' and exists(
    select 1 from companies c
    where c.id::text = (storage.foldername(name))[1]
      and c.owner_id = (select auth.uid())
  )
);
drop policy if exists "agency replace own media" on storage.objects;
create policy "agency replace own media" on storage.objects for update
to authenticated using (
  bucket_id = 'agency-media' and exists(
    select 1 from companies c
    where c.id::text = (storage.foldername(name))[1]
      and c.owner_id = (select auth.uid())
  )
) with check (
  bucket_id = 'agency-media' and exists(
    select 1 from companies c
    where c.id::text = (storage.foldername(name))[1]
      and c.owner_id = (select auth.uid())
  )
);

drop policy if exists "public read offer media" on storage.objects;
create policy "public read offer media" on storage.objects for select
to anon, authenticated using (bucket_id = 'offer-media');
drop policy if exists "agency upload own offer media" on storage.objects;
create policy "agency upload own offer media" on storage.objects for insert
to authenticated with check (
  bucket_id = 'offer-media' and exists(
    select 1 from packages p
    where p.id::text = (storage.foldername(name))[1]
      and owns_company(p.company_id)
  )
);
drop policy if exists "agency replace own offer media" on storage.objects;
create policy "agency replace own offer media" on storage.objects for update
to authenticated using (
  bucket_id = 'offer-media' and exists(
    select 1 from packages p
    where p.id::text = (storage.foldername(name))[1]
      and owns_company(p.company_id)
  )
) with check (
  bucket_id = 'offer-media' and exists(
    select 1 from packages p
    where p.id::text = (storage.foldername(name))[1]
      and owns_company(p.company_id)
  )
);

-- Realtime publication is idempotent only through this guarded block.
do $$ begin
  alter publication supabase_realtime add table notifications;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table bookings;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table inquiries;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table inquiry_messages;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table agency_reports;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table carousel_requests;
exception when duplicate_object then null; end $$;
