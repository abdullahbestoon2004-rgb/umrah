-- ============================================================================
-- UMRAH MARKETPLACE — three-role workflow upgrade
-- Apply after schema.sql and the existing patches*.sql files.
-- Safe to re-run. This patch keeps the legacy booking_status enum in sync so
-- older app builds continue to work while operational_stage carries the richer
-- workflow.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Company approval lifecycle
-- ---------------------------------------------------------------------------
alter table companies add column if not exists verification_status text;
alter table companies add column if not exists verification_reason text;
alter table companies add column if not exists submitted_at timestamptz;
alter table companies add column if not exists reviewed_at timestamptz;
alter table companies add column if not exists reviewed_by uuid references profiles(id);

update companies
set verification_status = case when is_verified then 'approved' else 'pending' end
where verification_status is null;

alter table companies alter column verification_status set default 'draft';
alter table companies alter column verification_status set not null;
do $$ begin
  alter table companies add constraint companies_verification_status_check
    check (verification_status in
      ('draft','pending','needs_changes','approved','rejected','suspended'));
exception when duplicate_object then null; end $$;
create index if not exists companies_verification_status_idx
  on companies(verification_status, created_at desc);

-- ---------------------------------------------------------------------------
-- 2. Package lifecycle, dates, and inventory
-- ---------------------------------------------------------------------------
alter table packages add column if not exists lifecycle_status text;
alter table packages add column if not exists review_reason text;
alter table packages add column if not exists capacity int;
alter table packages add column if not exists seats_reserved int not null default 0;
alter table packages add column if not exists departure_date date;
alter table packages add column if not exists return_date date;
alter table packages add column if not exists submitted_at timestamptz;
alter table packages add column if not exists reviewed_at timestamptz;
alter table packages add column if not exists reviewed_by uuid references profiles(id);
alter table packages add column if not exists hotel_makkah_description text;
alter table packages add column if not exists hotel_madinah_description text;
alter table packages add column if not exists room_occupancies int[]
  not null default array[2,3,4];

update packages
set lifecycle_status = case when is_published then 'published' else 'draft' end
where lifecycle_status is null;

alter table packages alter column lifecycle_status set default 'draft';
alter table packages alter column lifecycle_status set not null;
do $$ begin
  alter table packages add constraint packages_lifecycle_status_check
    check (lifecycle_status in
      ('draft','pending_review','needs_changes','published','paused',
       'sold_out','expired','rejected'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_capacity_check
    check (capacity is null or capacity > 0);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_seats_reserved_check
    check (seats_reserved >= 0 and (capacity is null or seats_reserved <= capacity));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_dates_check
    check (return_date is null or departure_date is null or return_date >= departure_date);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table packages add constraint packages_room_occupancies_check
    check (
      cardinality(room_occupancies) > 0
      and room_occupancies <@ array[1,2,3,4,5,6]
    );
exception when duplicate_object then null; end $$;
create index if not exists packages_lifecycle_idx
  on packages(lifecycle_status, departure_date);

-- ---------------------------------------------------------------------------
-- 3. Booking operations and structured traveller data
-- ---------------------------------------------------------------------------
alter table bookings add column if not exists operational_stage text;
alter table bookings add column if not exists status_reason text;
alter table bookings add column if not exists departure_date date;
alter table bookings add column if not exists room_label text;
alter table bookings add column if not exists room_occupancy int;
alter table bookings add column if not exists meal_preference text
  check (meal_preference in ('Breakfast', 'Half board', 'Full board'));
alter table bookings add column if not exists expires_at timestamptz;
alter table bookings add column if not exists accepted_at timestamptz;
alter table bookings add column if not exists ready_at timestamptz;
alter table bookings add column if not exists started_at timestamptz;
alter table bookings add column if not exists completed_at timestamptz;
alter table bookings add column if not exists cancelled_at timestamptz;
alter table bookings add column if not exists cancelled_by uuid references profiles(id);

update bookings
set operational_stage = case status::text
  when 'confirmed' then 'confirmed'
  when 'cancelled' then 'cancelled'
  when 'completed' then 'completed'
  else 'requested'
end
where operational_stage is null;

alter table bookings alter column operational_stage set default 'requested';
alter table bookings alter column operational_stage set not null;
do $$ begin
  alter table bookings add constraint bookings_operational_stage_check
    check (operational_stage in
      ('requested','needs_information','awaiting_payment','confirmed','ready',
       'in_progress','completed','rejected','expired','cancelled','no_show'));
exception when duplicate_object then null; end $$;
create index if not exists bookings_operational_stage_idx
  on bookings(company_id, operational_stage, created_at desc);

create table if not exists booking_travellers (
  id            uuid primary key default gen_random_uuid(),
  booking_id    uuid not null references bookings(id) on delete cascade,
  client_id     uuid not null references profiles(id) on delete cascade,
  full_name     text not null,
  passport_no   text,
  passport_image_path text,
  selfie_image_path text,
  date_of_birth date,
  phone         text,
  is_lead       boolean not null default false,
  created_at    timestamptz not null default now(),
  unique (booking_id, passport_no)
);
alter table booking_travellers alter column passport_no drop not null;
alter table booking_travellers
  add column if not exists passport_image_path text;
alter table booking_travellers
  add column if not exists selfie_image_path text;
create index if not exists booking_travellers_booking_idx
  on booking_travellers(booking_id);
alter table booking_travellers enable row level security;

-- ---------------------------------------------------------------------------
-- 4. Support queue and immutable audit trail
-- ---------------------------------------------------------------------------
alter table support_messages add column if not exists status text not null default 'open';
alter table support_messages add column if not exists assigned_to uuid references profiles(id);
alter table support_messages add column if not exists resolution_note text;
alter table support_messages add column if not exists resolved_at timestamptz;
do $$ begin
  alter table support_messages add constraint support_messages_status_check
    check (status in ('open','assigned','waiting','resolved','closed'));
exception when duplicate_object then null; end $$;

create table if not exists audit_logs (
  id          bigint generated always as identity primary key,
  actor_id    uuid references profiles(id) on delete set null,
  actor_role  text,
  entity_type text not null,
  entity_id   uuid not null,
  action      text not null,
  old_state   jsonb not null default '{}'::jsonb,
  new_state   jsonb not null default '{}'::jsonb,
  reason      text,
  created_at  timestamptz not null default now()
);
create index if not exists audit_logs_entity_idx
  on audit_logs(entity_type, entity_id, created_at desc);
alter table audit_logs enable row level security;

-- ---------------------------------------------------------------------------
-- 5. Visibility and ownership policies
-- ---------------------------------------------------------------------------
drop policy if exists "public read companies" on companies;
create policy "public read companies" on companies for select
to anon, authenticated
using (
  (is_active and is_verified and verification_status = 'approved')
  or owner_id = (select auth.uid())
  or is_admin()
);

drop policy if exists "public read packages" on packages;
drop policy if exists "read visible offers" on packages;
create policy "public read packages" on packages for select
to anon, authenticated
using (
  (
    is_published
    and lifecycle_status = 'published'
    and (departure_date is null or departure_date >= current_date)
    and exists (
      select 1 from companies c
      where c.id = packages.company_id
        and c.is_active
        and c.is_verified
        and c.verification_status = 'approved'
    )
  )
  or owns_company(company_id)
  or is_admin()
);

drop policy if exists "client cancel own booking" on bookings;
drop policy if exists "agency or admin update booking" on bookings;
drop policy if exists "client create booking" on bookings;
create policy "client create booking" on bookings for insert
to authenticated
with check (
  client_id = (select auth.uid())
  and exists (select 1 from profiles p
              where p.id = (select auth.uid()) and p.role = 'client')
);
-- Direct booking updates are intentionally disabled. All transitions use the
-- role-aware transition_booking() function below.

drop policy if exists "read booking travellers" on booking_travellers;
create policy "read booking travellers" on booking_travellers for select
to authenticated
using (
  client_id = (select auth.uid())
  or exists (
    select 1 from bookings b
    where b.id = booking_id and (owns_company(b.company_id) or is_admin())
  )
);
drop policy if exists "client add own booking travellers" on booking_travellers;
create policy "client add own booking travellers" on booking_travellers for insert
to authenticated
with check (
  client_id = (select auth.uid())
  and exists (
    select 1 from bookings b
    where b.id = booking_id and b.client_id = (select auth.uid())
      and b.operational_stage in ('requested','needs_information')
  )
);
drop policy if exists "client update own booking travellers" on booking_travellers;
create policy "client update own booking travellers" on booking_travellers for update
to authenticated
using (
  client_id = (select auth.uid())
  and exists (select 1 from bookings b where b.id = booking_id
              and b.client_id = (select auth.uid()))
)
with check (
  client_id = (select auth.uid())
  and exists (select 1 from bookings b where b.id = booking_id
              and b.client_id = (select auth.uid()))
);

drop policy if exists "admin read audit logs" on audit_logs;
create policy "admin read audit logs" on audit_logs for select
to authenticated using (is_admin());

-- New Supabase projects do not expose new tables automatically.
grant select, insert on booking_travellers to authenticated;
grant update (passport_no, passport_image_path, selfie_image_path)
  on booking_travellers to authenticated;

insert into storage.buckets (id, name, public)
values ('booking-passports', 'booking-passports', false)
on conflict (id) do update set public = false;

drop policy if exists "client upload booking passports" on storage.objects;
create policy "client upload booking passports" on storage.objects for insert
to authenticated with check (
  bucket_id = 'booking-passports'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and b.client_id = (select auth.uid())
  )
);
drop policy if exists "client replace booking passports" on storage.objects;
create policy "client replace booking passports" on storage.objects for update
to authenticated using (
  bucket_id = 'booking-passports'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and b.client_id = (select auth.uid())
  )
) with check (
  bucket_id = 'booking-passports'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and b.client_id = (select auth.uid())
  )
);
drop policy if exists "booking parties read passports" on storage.objects;
create policy "booking parties read passports" on storage.objects for select
to authenticated using (
  bucket_id = 'booking-passports'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and (b.client_id = (select auth.uid())
           or owns_company(b.company_id) or is_admin())
  )
);
grant select on audit_logs to authenticated;
grant usage, select on sequence audit_logs_id_seq to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Shared workflow helpers
-- ---------------------------------------------------------------------------
create or replace function write_audit(
  p_entity_type text, p_entity_id uuid, p_action text,
  p_old jsonb, p_new jsonb, p_reason text default null
) returns void language plpgsql security definer set search_path = public as $$
declare role_name text;
begin
  select role::text into role_name from profiles where id = auth.uid();
  insert into audit_logs(actor_id, actor_role, entity_type, entity_id, action,
                         old_state, new_state, reason)
  values (auth.uid(), role_name, p_entity_type, p_entity_id, p_action,
          coalesce(p_old, '{}'::jsonb), coalesce(p_new, '{}'::jsonb), p_reason);
end; $$;
revoke execute on function write_audit(text,uuid,text,jsonb,jsonb,text)
  from public, anon, authenticated;

create or replace function notify_company_owner(
  p_company_id uuid, p_type text, p_arg text, p_booking_id uuid default null
) returns void language plpgsql security definer set search_path = public as $$
declare owner uuid;
begin
  select owner_id into owner from companies where id = p_company_id;
  if owner is not null then
    insert into notifications(user_id, type, arg, booking_id)
    values (owner, p_type, p_arg, p_booking_id);
  end if;
end; $$;
revoke execute on function notify_company_owner(uuid,text,text,uuid)
  from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- 7. Company and package transitions
-- ---------------------------------------------------------------------------
create or replace function submit_company_application(p_company_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare old_row companies%rowtype;
begin
  select * into old_row from companies where id = p_company_id for update;
  if old_row.id is null or old_row.owner_id <> auth.uid() then
    raise exception 'not your company';
  end if;
  if old_row.verification_status not in ('draft','needs_changes','rejected') then
    raise exception 'company cannot be submitted from %', old_row.verification_status;
  end if;
  update companies set verification_status = 'pending', verification_reason = null,
    submitted_at = now(), is_verified = false where id = p_company_id;
  perform write_audit('company', p_company_id, 'submitted',
    jsonb_build_object('status', old_row.verification_status),
    jsonb_build_object('status', 'pending'), null);
end; $$;

create or replace function review_company_application(
  p_company_id uuid, p_decision text, p_reason text default null
) returns void language plpgsql security definer set search_path = public as $$
declare old_row companies%rowtype;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  if p_decision not in ('approved','needs_changes','rejected','suspended') then
    raise exception 'invalid company decision';
  end if;
  if p_decision <> 'approved' and nullif(btrim(p_reason), '') is null then
    raise exception 'a reason is required';
  end if;
  select * into old_row from companies where id = p_company_id for update;
  if old_row.id is null then raise exception 'company not found'; end if;
  update companies set verification_status = p_decision,
    verification_reason = nullif(btrim(p_reason), ''), reviewed_at = now(),
    reviewed_by = auth.uid(), is_verified = (p_decision = 'approved'),
    is_active = (p_decision <> 'suspended') where id = p_company_id;
  perform write_audit('company', p_company_id, 'reviewed',
    jsonb_build_object('status', old_row.verification_status),
    jsonb_build_object('status', p_decision), p_reason);
  insert into notifications(user_id, type, arg)
  values (old_row.owner_id, 'companyReview', p_decision);
end; $$;

create or replace function submit_package(p_package_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare old_row packages%rowtype;
declare company_ok boolean;
begin
  select * into old_row from packages where id = p_package_id for update;
  if old_row.id is null or not owns_company(old_row.company_id) then
    raise exception 'not your package';
  end if;
  select verification_status = 'approved' and is_active into company_ok
    from companies where id = old_row.company_id;
  if not coalesce(company_ok, false) then raise exception 'company is not approved'; end if;
  if old_row.lifecycle_status not in ('draft','needs_changes','rejected','paused') then
    raise exception 'package cannot be submitted from %', old_row.lifecycle_status;
  end if;
  update packages set lifecycle_status = 'pending_review', is_published = false,
    review_reason = null, submitted_at = now() where id = p_package_id;
  perform write_audit('package', p_package_id, 'submitted',
    jsonb_build_object('status', old_row.lifecycle_status),
    jsonb_build_object('status', 'pending_review'), null);
end; $$;

create or replace function review_package(
  p_package_id uuid, p_decision text, p_reason text default null
) returns void language plpgsql security definer set search_path = public as $$
declare old_row packages%rowtype;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  if p_decision not in ('published','needs_changes','rejected','paused') then
    raise exception 'invalid package decision';
  end if;
  if p_decision <> 'published' and nullif(btrim(p_reason), '') is null then
    raise exception 'a reason is required';
  end if;
  select * into old_row from packages where id = p_package_id for update;
  if old_row.id is null then raise exception 'package not found'; end if;
  update packages set lifecycle_status = p_decision,
    is_published = (p_decision = 'published'), review_reason = nullif(btrim(p_reason), ''),
    reviewed_at = now(), reviewed_by = auth.uid() where id = p_package_id;
  perform write_audit('package', p_package_id, 'reviewed',
    jsonb_build_object('status', old_row.lifecycle_status),
    jsonb_build_object('status', p_decision), p_reason);
  perform notify_company_owner(old_row.company_id, 'packageReview', p_decision, null);
end; $$;

-- ---------------------------------------------------------------------------
-- 8. Booking creation validation, inventory, and transitions
-- ---------------------------------------------------------------------------
create or replace function validate_new_booking()
returns trigger language plpgsql security definer set search_path = public as $$
declare pkg packages%rowtype;
declare company_ok boolean;
begin
  select * into pkg from packages where id = new.package_id for update;
  if pkg.id is null or pkg.lifecycle_status <> 'published' or not pkg.is_published then
    raise exception 'package is not available';
  end if;
  select verification_status = 'approved' and is_active into company_ok
    from companies where id = pkg.company_id;
  if not coalesce(company_ok, false) then raise exception 'company is not available'; end if;
  if pkg.departure_date is not null and pkg.departure_date < current_date then
    raise exception 'package has departed';
  end if;
  if pkg.capacity is not null and pkg.seats_reserved + new.travellers > pkg.capacity then
    raise exception 'not enough seats';
  end if;
  new.operational_stage := 'requested';
  new.status := 'pending';
  if new.room_occupancy is null then
    new.room_occupancy := pkg.room_occupancies[1];
  end if;
  if not (new.room_occupancy = any(pkg.room_occupancies)) then
    raise exception 'selected room type is not available';
  end if;
  new.departure_date := coalesce(new.departure_date, pkg.departure_date);
  new.expires_at := now() + interval '24 hours';
  update packages set seats_reserved = seats_reserved + new.travellers
    where id = pkg.id;
  return new;
end; $$;
drop trigger if exists before_validate_new_booking on bookings;
create trigger before_validate_new_booking
  before insert on bookings for each row execute function validate_new_booking();

create or replace function after_new_booking_notify_company()
returns trigger language plpgsql security definer set search_path = public as $$
declare package_title text;
begin
  select title into package_title from packages where id = new.package_id;
  perform notify_company_owner(new.company_id, 'bookingRequested', package_title, new.id);
  return new;
end; $$;
drop trigger if exists after_new_booking_notify_company on bookings;
create trigger after_new_booking_notify_company
  after insert on bookings for each row execute function after_new_booking_notify_company();

create or replace function transition_booking(
  p_booking_id uuid, p_action text, p_reason text default null
) returns void language plpgsql security definer set search_path = public as $$
declare b bookings%rowtype;
declare actor_role text;
declare next_stage text;
declare next_legacy booking_status;
declare release_seats boolean := false;
begin
  select * into b from bookings where id = p_booking_id for update;
  if b.id is null then raise exception 'booking not found'; end if;
  select role::text into actor_role from profiles where id = auth.uid();

  if p_action = 'accept' then
    if not (owns_company(b.company_id) or is_admin()) or b.operational_stage <> 'requested' then
      raise exception 'booking cannot be accepted';
    end if;
    next_stage := case when b.pay_status::text = 'paid' then 'confirmed' else 'awaiting_payment' end;
    next_legacy := case when next_stage = 'confirmed' then 'confirmed' else 'pending' end;
  elsif p_action = 'request_information' then
    if not (owns_company(b.company_id) or is_admin()) or b.operational_stage <> 'requested' then
      raise exception 'information cannot be requested';
    end if;
    if nullif(btrim(p_reason), '') is null then raise exception 'a reason is required'; end if;
    next_stage := 'needs_information'; next_legacy := 'pending';
  elsif p_action = 'reject' then
    if not (owns_company(b.company_id) or is_admin())
       or b.operational_stage not in ('requested','needs_information','awaiting_payment') then
      raise exception 'booking cannot be rejected';
    end if;
    if nullif(btrim(p_reason), '') is null then raise exception 'a reason is required'; end if;
    next_stage := 'rejected'; next_legacy := 'cancelled'; release_seats := true;
  elsif p_action = 'cancel' then
    if not (b.client_id = auth.uid() or owns_company(b.company_id) or is_admin())
       or b.operational_stage not in
          ('requested','needs_information','awaiting_payment','confirmed','ready') then
      raise exception 'booking cannot be cancelled';
    end if;
    if b.operational_stage in ('confirmed','ready')
       and nullif(btrim(p_reason), '') is null then raise exception 'a reason is required'; end if;
    next_stage := 'cancelled'; next_legacy := 'cancelled'; release_seats := true;
  elsif p_action = 'ready' then
    if not (owns_company(b.company_id) or is_admin()) or b.operational_stage <> 'confirmed' then
      raise exception 'booking cannot be marked ready';
    end if;
    next_stage := 'ready'; next_legacy := 'confirmed';
  elsif p_action = 'start' then
    if not (owns_company(b.company_id) or is_admin())
       or b.operational_stage not in ('confirmed','ready') then
      raise exception 'booking cannot be started';
    end if;
    next_stage := 'in_progress'; next_legacy := 'confirmed';
  elsif p_action = 'complete' then
    if not (owns_company(b.company_id) or is_admin())
       or b.operational_stage not in ('confirmed','ready','in_progress') then
      raise exception 'booking cannot be completed';
    end if;
    if b.departure_date is not null and b.departure_date > current_date then
      raise exception 'a future trip cannot be completed';
    end if;
    next_stage := 'completed'; next_legacy := 'completed';
  else
    raise exception 'invalid booking action';
  end if;

  update bookings set operational_stage = next_stage, status = next_legacy,
    status_reason = nullif(btrim(p_reason), ''),
    accepted_at = case when p_action = 'accept' then now() else accepted_at end,
    ready_at = case when p_action = 'ready' then now() else ready_at end,
    started_at = case when p_action = 'start' then now() else started_at end,
    completed_at = case when p_action = 'complete' then now() else completed_at end,
    cancelled_at = case when p_action in ('cancel','reject') then now() else cancelled_at end,
    cancelled_by = case when p_action in ('cancel','reject') then auth.uid() else cancelled_by end
  where id = p_booking_id;

  if release_seats then
    update packages set seats_reserved = greatest(0, seats_reserved - b.travellers)
      where id = b.package_id;
  end if;
  perform write_audit('booking', p_booking_id, p_action,
    jsonb_build_object('stage', b.operational_stage),
    jsonb_build_object('stage', next_stage), p_reason);
end; $$;

-- Successful payment confirms an accepted booking. The existing payment
-- functions update pay_status; this trigger only advances operations.
create or replace function confirm_booking_after_payment()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.pay_status::text = 'paid' and old.pay_status::text is distinct from 'paid'
     and new.operational_stage = 'awaiting_payment' then
    update bookings set operational_stage = 'confirmed', status = 'confirmed'
      where id = new.id;
  end if;
  return new;
end; $$;
drop trigger if exists after_booking_paid_confirm on bookings;
create trigger after_booking_paid_confirm
  after update of pay_status on bookings
  for each row execute function confirm_booking_after_payment();

-- ---------------------------------------------------------------------------
-- 9. Support state transition
-- ---------------------------------------------------------------------------
create or replace function resolve_support_message(
  p_message_id uuid, p_resolution_note text default null
) returns void language plpgsql security definer set search_path = public as $$
declare old_status text;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  select status into old_status from support_messages where id = p_message_id for update;
  if old_status is null then raise exception 'message not found'; end if;
  update support_messages set status = 'resolved', assigned_to = auth.uid(),
    resolution_note = nullif(btrim(p_resolution_note), ''), resolved_at = now()
  where id = p_message_id;
  perform write_audit('support_message', p_message_id, 'resolved',
    jsonb_build_object('status', old_status), jsonb_build_object('status', 'resolved'),
    p_resolution_note);
end; $$;

create or replace function admin_set_company_promoted(p_company_id uuid, p_value boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not is_admin() then raise exception 'admin only'; end if;
  update companies set is_promoted = p_value where id = p_company_id;
  if not found then raise exception 'company not found'; end if;
  perform write_audit('company', p_company_id, 'promotion_changed', '{}'::jsonb,
    jsonb_build_object('is_promoted', p_value), null);
end; $$;

create or replace function admin_set_package_featured(p_package_id uuid, p_value boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not is_admin() then raise exception 'admin only'; end if;
  update packages set is_featured = p_value where id = p_package_id;
  if not found then raise exception 'package not found'; end if;
  perform write_audit('package', p_package_id, 'featured_changed', '{}'::jsonb,
    jsonb_build_object('is_featured', p_value), null);
end; $$;

-- SECURITY DEFINER functions are explicit APIs: revoke PUBLIC, then grant only
-- to authenticated users. Every function also checks ownership/role internally.
revoke execute on function submit_company_application(uuid) from public, anon;
revoke execute on function review_company_application(uuid,text,text) from public, anon;
revoke execute on function submit_package(uuid) from public, anon;
revoke execute on function review_package(uuid,text,text) from public, anon;
revoke execute on function transition_booking(uuid,text,text) from public, anon;
revoke execute on function resolve_support_message(uuid,text) from public, anon;
revoke execute on function admin_set_company_promoted(uuid,boolean) from public, anon;
revoke execute on function admin_set_package_featured(uuid,boolean) from public, anon;
grant execute on function submit_company_application(uuid) to authenticated;
grant execute on function review_company_application(uuid,text,text) to authenticated;
grant execute on function submit_package(uuid) to authenticated;
grant execute on function review_package(uuid,text,text) to authenticated;
grant execute on function transition_booking(uuid,text,text) to authenticated;
grant execute on function resolve_support_message(uuid,text) to authenticated;
grant execute on function admin_set_company_promoted(uuid,boolean) to authenticated;
grant execute on function admin_set_package_featured(uuid,boolean) to authenticated;

-- Column privileges close the gaps that row policies cannot express. Companies
-- may edit public profile fields but never approve themselves; agencies may edit
-- package content but lifecycle decisions only move through the RPCs above.
revoke update on companies from authenticated;
grant update (name, name_ar, name_en, location, logo_url, banner_url, tint,
              since, about, tags)
  on companies to authenticated;
revoke update on packages from authenticated;
grant update (title, title_ar, title_en, overview, overview_ar, overview_en,
              price_iqd, original_iqd, days, nights, transport, carrier,
              transfer_note, acc_stars, hotel, distance_haram, room, meals,
              includes, badge, image_url, capacity, departure_date, return_date,
              hotel_makkah_description, hotel_madinah_description,
              room_occupancies, package_tier, group_type, season_tag,
              departure_airport, airline_name, airline_logo_url, flight_type,
              bus_between_cities, airport_transfers, transport_notes,
              meals_per_day, video_url, cancellation_policy,
              cancellation_policy_ar, cancellation_policy_en, deposit_iqd,
              non_refundable_deposit, deposit_terms,
              accepted_payment_methods)
  on packages to authenticated;

revoke insert on companies from authenticated;
grant insert (owner_id, name, name_ar, name_en, location, logo_url, banner_url,
              tint, since, about, tags)
  on companies to authenticated;
revoke insert on packages from authenticated;
grant insert (company_id, title, title_ar, title_en, overview, overview_ar,
              overview_en, price_iqd, original_iqd, days, nights, transport,
              carrier, transfer_note, acc_stars, hotel, distance_haram, room,
              meals, includes, badge, image_url, capacity, departure_date,
              return_date, hotel_makkah_description,
              hotel_madinah_description, room_occupancies, package_tier,
              group_type, season_tag, departure_airport, airline_name,
              airline_logo_url, flight_type, bus_between_cities,
              airport_transfers, transport_notes, meals_per_day, video_url,
              cancellation_policy, cancellation_policy_ar,
              cancellation_policy_en, deposit_iqd, non_refundable_deposit,
              deposit_terms, accepted_payment_methods)
  on packages to authenticated;
revoke insert on bookings from authenticated;
grant insert (package_id, client_id, travellers, pay_method, contact_phone,
              note, departure_date, room_label, room_occupancy, meal_preference)
  on bookings to authenticated;
revoke delete on support_messages from authenticated;
