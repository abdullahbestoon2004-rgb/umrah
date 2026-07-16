-- Company trip operations: staff permissions, traveller document/visa review,
-- rooming, transport manifests, announcements, and the Data API grants needed
-- by new Supabase projects. This migration is additive and preserves the
-- booking/passport and append-only wallet structures already in production.

-- ---------------------------------------------------------------------------
-- 1. Company staff and permission-aware access
-- ---------------------------------------------------------------------------
create table if not exists agency_staff (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references companies(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  role        text not null check (role in
              ('manager','booking','accountant','visa','guide','support')),
  permissions text[] not null default '{}',
  status      text not null default 'active'
              check (status in ('invited','active','suspended')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (company_id, user_id)
);
create index if not exists agency_staff_user_idx
  on agency_staff(user_id, company_id) where status = 'active';
alter table agency_staff enable row level security;

create or replace function can_access_company(
  p_company_id uuid,
  p_permission text default 'operations'
) returns boolean
language sql stable security definer set search_path = public as $$
  select
    owns_company(p_company_id)
    or is_admin()
    or exists (
      select 1 from agency_staff s
      where s.company_id = p_company_id
        and s.user_id = (select auth.uid())
        and s.status = 'active'
        and (
          'manage_all' = any(s.permissions)
          or p_permission = 'membership'
          or p_permission = any(s.permissions)
          or (p_permission = 'operations' and s.role in ('manager','booking','visa','guide','support'))
          or (p_permission = 'bookings' and s.role in ('manager','booking','visa','support'))
          or (p_permission = 'documents' and s.role in ('manager','booking','visa'))
          or (p_permission = 'announcements' and s.role in ('manager','guide','support'))
          or (p_permission = 'finance' and s.role in ('manager','accountant'))
        )
    );
$$;
revoke execute on function can_access_company(uuid,text) from public, anon;
grant execute on function can_access_company(uuid,text) to authenticated;

drop policy if exists "owner manages agency staff" on agency_staff;
create policy "owner manages agency staff" on agency_staff for all
to authenticated
using (owns_company(company_id) or is_admin())
with check (owns_company(company_id) or is_admin());
drop policy if exists "staff read own membership" on agency_staff;
create policy "staff read own membership" on agency_staff for select
to authenticated
using (user_id = (select auth.uid()));

create or replace function validate_agency_staff_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not exists (
    select 1 from profiles p where p.id = new.user_id and p.role::text = 'agency'
  ) then
    raise exception 'company staff must use an agency account';
  end if;
  new.updated_at := now();
  return new;
end; $$;
drop trigger if exists before_validate_agency_staff_user on agency_staff;
create trigger before_validate_agency_staff_user
before insert or update on agency_staff
for each row execute function validate_agency_staff_user();

drop policy if exists "company owners read assigned staff profiles" on profiles;
create policy "company owners read assigned staff profiles" on profiles for select
to authenticated
using (
  exists (
    select 1 from agency_staff s
    where s.user_id = profiles.id
      and (owns_company(s.company_id) or is_admin())
  )
);

drop policy if exists "staff read assigned company" on companies;
create policy "staff read assigned company" on companies for select
to authenticated
using (can_access_company(id, 'membership'));
drop policy if exists "staff read assigned trips" on packages;
create policy "staff read assigned trips" on packages for select
to authenticated
using (can_access_company(company_id, 'operations'));

-- Staff with the booking permission need the same read boundary as the owner.
drop policy if exists "client read own bookings" on bookings;
create policy "booking parties read bookings" on bookings for select
to authenticated
using (
  client_id = (select auth.uid())
  or can_access_company(company_id, 'bookings')
);

drop policy if exists "read booking travellers" on booking_travellers;
create policy "read booking travellers" on booking_travellers for select
to authenticated
using (
  client_id = (select auth.uid())
  or exists (
    select 1 from bookings b
    where b.id = booking_id
      and can_access_company(b.company_id, 'bookings')
  )
);

-- Keep finance invisible to guides, support staff, and booking-only staff.
drop policy if exists "read own payments" on payments;
create policy "read own payments" on payments for select
to authenticated
using (
  client_id = (select auth.uid())
  or can_access_company(company_id, 'finance')
);
drop policy if exists "agency read own ledger" on agency_ledger;
create policy "agency read own ledger" on agency_ledger for select
to authenticated using (can_access_company(company_id, 'finance'));
drop policy if exists "agency read own payouts" on payouts;
create policy "agency read own payouts" on payouts for select
to authenticated using (can_access_company(company_id, 'finance'));

-- ---------------------------------------------------------------------------
-- 2. Separate traveller identity, document, and visa status tracks
-- ---------------------------------------------------------------------------
alter table booking_travellers add column if not exists local_name text;
alter table booking_travellers add column if not exists gender text;
alter table booking_travellers add column if not exists nationality text;
alter table booking_travellers add column if not exists passport_expiry_date date;
alter table booking_travellers add column if not exists national_id text;
alter table booking_travellers add column if not exists emergency_contact text;
alter table booking_travellers add column if not exists medical_notes text;
alter table booking_travellers add column if not exists accessibility_notes text;
alter table booking_travellers add column if not exists document_status text not null default 'missing';
alter table booking_travellers add column if not exists document_reason text;
alter table booking_travellers add column if not exists visa_status text not null default 'not_started';
alter table booking_travellers add column if not exists visa_reference text;
alter table booking_travellers add column if not exists visa_reason text;
alter table booking_travellers add column if not exists visa_updated_at timestamptz;
alter table booking_travellers add column if not exists transport_seat text;

do $$ begin
  alter table booking_travellers add constraint booking_travellers_gender_check
    check (gender is null or gender in ('male','female'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table booking_travellers add constraint booking_travellers_document_status_check
    check (document_status in ('missing','uploaded','under_review','approved','rejected'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table booking_travellers add constraint booking_travellers_visa_status_check
    check (visa_status in
      ('not_started','documents_missing','ready_to_apply','submitted',
       'under_review','approved','rejected'));
exception when duplicate_object then null; end $$;

-- Preserve the exact Latin passport spelling separately from the optional
-- local Kurdish/Arabic display name while keeping booking creation atomic.
create or replace function create_booking_request(
  p_package_id uuid,
  p_travellers int,
  p_pay_method text,
  p_room_occupancy int,
  p_contact_phone text default null,
  p_note text default null,
  p_pilgrims jsonb default '[]'::jsonb,
  p_request_key text default null
) returns uuid
language plpgsql security definer set search_path = public as $$
declare booking_id uuid;
declare pilgrim jsonb;
declare pilgrim_count int;
declare lead_count int;
declare caller_role text;
declare existing_booking_id uuid;
begin
  if auth.uid() is null then raise exception 'sign-in required'; end if;
  select role::text into caller_role from profiles where id = auth.uid();
  if caller_role <> 'client' then raise exception 'client account required'; end if;
  if p_travellers < 1 or p_travellers > 50 then raise exception 'invalid traveller count'; end if;
  if p_pay_method not in ('cash','fib') then raise exception 'unsupported payment method'; end if;
  if p_request_key is not null and length(btrim(p_request_key)) not between 8 and 120 then
    raise exception 'invalid booking request key';
  end if;
  if jsonb_typeof(coalesce(p_pilgrims, '[]'::jsonb)) <> 'array' then
    raise exception 'pilgrims must be an array';
  end if;
  pilgrim_count := jsonb_array_length(coalesce(p_pilgrims, '[]'::jsonb));
  if pilgrim_count <> p_travellers then
    raise exception 'traveller details do not match traveller count';
  end if;
  select count(*) into lead_count
  from jsonb_array_elements(coalesce(p_pilgrims, '[]'::jsonb)) traveller
  where coalesce((traveller->>'is_lead')::boolean, false);
  if lead_count <> 1 then raise exception 'exactly one lead traveller is required'; end if;

  if nullif(btrim(p_request_key), '') is not null then
    perform pg_advisory_xact_lock(
      hashtextextended(auth.uid()::text || ':' || btrim(p_request_key), 0)
    );
    select id into existing_booking_id from bookings
    where client_id = auth.uid() and request_key = btrim(p_request_key);
    if existing_booking_id is not null then return existing_booking_id; end if;
  end if;

  insert into bookings(
    package_id, company_id, client_id, travellers, unit_price_iqd, total_iqd,
    commission_iqd, payout_iqd, pay_method, contact_phone, note,
    room_occupancy, request_key
  ) values (
    p_package_id, (select company_id from packages where id = p_package_id),
    auth.uid(), p_travellers, 0, 0, 0, 0, p_pay_method::payment_method,
    nullif(btrim(p_contact_phone), ''), nullif(btrim(p_note), ''),
    p_room_occupancy, nullif(btrim(p_request_key), '')
  ) returning id into booking_id;

  for pilgrim in select value from jsonb_array_elements(p_pilgrims) loop
    if nullif(btrim(pilgrim->>'full_name'), '') is null
       or nullif(pilgrim->>'date_of_birth', '') is null then
      raise exception 'each traveller needs a passport name and date of birth';
    end if;
    if (pilgrim->>'date_of_birth')::date > current_date then
      raise exception 'traveller date of birth cannot be in the future';
    end if;
    insert into booking_travellers(
      booking_id, client_id, full_name, local_name, passport_no,
      date_of_birth, phone, is_lead
    ) values (
      booking_id, auth.uid(), btrim(pilgrim->>'full_name'),
      nullif(btrim(pilgrim->>'local_name'), ''),
      nullif(btrim(pilgrim->>'passport_no'), ''),
      (pilgrim->>'date_of_birth')::date,
      nullif(btrim(pilgrim->>'phone'), ''),
      coalesce((pilgrim->>'is_lead')::boolean, false)
    );
  end loop;
  return booking_id;
end; $$;
revoke execute on function create_booking_request(uuid,int,text,int,text,text,jsonb,text)
  from public, anon;
grant execute on function create_booking_request(uuid,int,text,int,text,text,jsonb,text)
  to authenticated;

create table if not exists traveller_documents (
  id             uuid primary key default gen_random_uuid(),
  traveller_id   uuid not null references booking_travellers(id) on delete cascade,
  booking_id     uuid not null references bookings(id) on delete cascade,
  company_id     uuid not null references companies(id) on delete cascade,
  kind           text not null check (kind in
                 ('passport','personal_photo','national_id','residency_card',
                  'vaccination','visa','agreement','payment_receipt','other')),
  storage_path   text not null,
  status         text not null default 'under_review'
                 check (status in ('under_review','approved','rejected')),
  rejection_reason text,
  expires_on     date,
  reviewed_by    uuid references profiles(id),
  reviewed_at    timestamptz,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  unique (traveller_id, kind, storage_path)
);
create index if not exists traveller_documents_booking_idx
  on traveller_documents(booking_id, status, created_at desc);
create index if not exists traveller_documents_company_idx
  on traveller_documents(company_id, status);
alter table traveller_documents enable row level security;

create or replace function validate_traveller_document_links()
returns trigger language plpgsql security invoker set search_path = public as $$
declare t booking_travellers%rowtype;
declare b bookings%rowtype;
begin
  select * into t from booking_travellers where id = new.traveller_id;
  if t.id is null or t.booking_id <> new.booking_id then
    raise exception 'traveller does not belong to booking';
  end if;
  select * into b from bookings where id = new.booking_id;
  if b.id is null or b.company_id <> new.company_id then
    raise exception 'booking does not belong to company';
  end if;
  return new;
end; $$;
drop trigger if exists before_validate_traveller_document on traveller_documents;
create trigger before_validate_traveller_document
before insert or update on traveller_documents
for each row execute function validate_traveller_document_links();

create or replace function mark_traveller_document_uploaded()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update booking_travellers set document_status = 'under_review',
    document_reason = null
  where id = new.traveller_id;
  return new;
end; $$;
drop trigger if exists after_traveller_document_uploaded on traveller_documents;
create trigger after_traveller_document_uploaded
after insert on traveller_documents
for each row execute function mark_traveller_document_uploaded();

-- Legacy passport/selfie uploads predate traveller_documents. Keep their
-- aggregate review state in the same workflow when both images are present.
create or replace function mark_legacy_passport_under_review()
returns trigger language plpgsql security invoker set search_path = public as $$
begin
  if nullif(new.passport_image_path, '') is not null
     and nullif(new.selfie_image_path, '') is not null then
    new.document_status := 'under_review';
    new.document_reason := null;
  end if;
  return new;
end; $$;
drop trigger if exists before_mark_legacy_passport_under_review on booking_travellers;
create trigger before_mark_legacy_passport_under_review
before update of passport_image_path, selfie_image_path on booking_travellers
for each row execute function mark_legacy_passport_under_review();

drop policy if exists "booking parties read traveller documents" on traveller_documents;
create policy "booking parties read traveller documents" on traveller_documents for select
to authenticated
using (
  can_access_company(company_id, 'documents')
  or exists (
    select 1 from bookings b
    where b.id = booking_id and b.client_id = (select auth.uid())
  )
);
drop policy if exists "client uploads traveller documents" on traveller_documents;
create policy "client uploads traveller documents" on traveller_documents for insert
to authenticated
with check (
  status = 'under_review'
  and reviewed_by is null
  and exists (
    select 1 from bookings b
    where b.id = booking_id and b.client_id = (select auth.uid())
      and b.operational_stage not in ('completed','cancelled','rejected','expired')
  )
);

create or replace function update_traveller_operations(
  p_traveller_id uuid,
  p_document_status text default null,
  p_document_reason text default null,
  p_visa_status text default null,
  p_visa_reference text default null,
  p_visa_reason text default null,
  p_transport_seat text default null
) returns void
language plpgsql security definer set search_path = public as $$
declare t booking_travellers%rowtype;
declare b bookings%rowtype;
begin
  select * into t from booking_travellers where id = p_traveller_id for update;
  if t.id is null then raise exception 'traveller not found'; end if;
  select * into b from bookings where id = t.booking_id;
  if not can_access_company(b.company_id, 'documents') then
    raise exception 'not allowed';
  end if;
  if p_document_status is not null and p_document_status not in
     ('missing','uploaded','under_review','approved','rejected') then
    raise exception 'invalid document status';
  end if;
  if p_visa_status is not null and p_visa_status not in
     ('not_started','documents_missing','ready_to_apply','submitted',
      'under_review','approved','rejected') then
    raise exception 'invalid visa status';
  end if;
  if p_document_status = 'rejected' and nullif(btrim(p_document_reason), '') is null then
    raise exception 'a document rejection reason is required';
  end if;
  if p_visa_status = 'rejected' and nullif(btrim(p_visa_reason), '') is null then
    raise exception 'a visa rejection reason is required';
  end if;
  update booking_travellers set
    document_status = coalesce(p_document_status, document_status),
    document_reason = case
      when p_document_status is null then document_reason
      when p_document_status = 'rejected' then nullif(btrim(p_document_reason), '')
      else null end,
    visa_status = coalesce(p_visa_status, visa_status),
    visa_reference = case
      when p_visa_status is null then visa_reference
      else nullif(btrim(p_visa_reference), '') end,
    visa_reason = case
      when p_visa_status is null then visa_reason
      when p_visa_status = 'rejected' then nullif(btrim(p_visa_reason), '')
      else null end,
    visa_updated_at = case when p_visa_status is null then visa_updated_at else now() end,
    transport_seat = case
      when p_transport_seat is null then transport_seat
      else nullif(btrim(p_transport_seat), '') end
  where id = p_traveller_id;
  perform write_audit('booking_traveller', p_traveller_id, 'operations_updated',
    jsonb_build_object('document_status', t.document_status, 'visa_status', t.visa_status),
    jsonb_build_object(
      'document_status', coalesce(p_document_status, t.document_status),
      'visa_status', coalesce(p_visa_status, t.visa_status)
    ), coalesce(p_document_reason, p_visa_reason));
end; $$;
revoke execute on function update_traveller_operations(uuid,text,text,text,text,text,text)
  from public, anon;
grant execute on function update_traveller_operations(uuid,text,text,text,text,text,text)
  to authenticated;

create or replace function review_traveller_document(
  p_document_id uuid,
  p_status text,
  p_reason text default null,
  p_expires_on date default null
) returns void
language plpgsql security definer set search_path = public as $$
declare d traveller_documents%rowtype;
begin
  select * into d from traveller_documents where id = p_document_id for update;
  if d.id is null then raise exception 'document not found'; end if;
  if not can_access_company(d.company_id, 'documents') then raise exception 'not allowed'; end if;
  if p_status not in ('approved','rejected') then raise exception 'invalid review status'; end if;
  if p_status = 'rejected' and nullif(btrim(p_reason), '') is null then
    raise exception 'a rejection reason is required';
  end if;
  update traveller_documents set status = p_status,
    rejection_reason = case when p_status = 'rejected' then btrim(p_reason) else null end,
    expires_on = p_expires_on, reviewed_by = auth.uid(), reviewed_at = now(),
    updated_at = now()
  where id = p_document_id;
  update booking_travellers set
    document_status = case
      when exists (
        select 1 from traveller_documents
        where traveller_id = d.traveller_id and status = 'rejected'
      ) then 'rejected'
      when exists (
        select 1 from traveller_documents
        where traveller_id = d.traveller_id and status = 'under_review'
      ) then 'under_review'
      else 'approved'
    end,
    document_reason = case when p_status = 'rejected'
      then btrim(p_reason) else null end
  where id = d.traveller_id;
end; $$;
revoke execute on function review_traveller_document(uuid,text,text,date)
  from public, anon;
grant execute on function review_traveller_document(uuid,text,text,date)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 3. Trip announcements, rooming, and transport manifests
-- ---------------------------------------------------------------------------
create table if not exists trip_announcements (
  id          uuid primary key default gen_random_uuid(),
  package_id  uuid not null references packages(id) on delete cascade,
  company_id  uuid not null references companies(id) on delete cascade,
  created_by  uuid not null references profiles(id),
  title       text not null,
  body        text not null,
  audience    text not null default 'all'
              check (audience in ('all','confirmed','unpaid','documents_missing')),
  created_at  timestamptz not null default now()
);
create index if not exists trip_announcements_package_idx
  on trip_announcements(package_id, created_at desc);
alter table trip_announcements enable row level security;

create table if not exists trip_rooms (
  id            uuid primary key default gen_random_uuid(),
  package_id    uuid not null references packages(id) on delete cascade,
  company_id    uuid not null references companies(id) on delete cascade,
  city          text not null check (city in ('makkah','madinah')),
  label         text not null,
  capacity      int not null check (capacity between 1 and 20),
  gender_policy text not null default 'family'
                check (gender_policy in ('male','female','family')),
  created_at    timestamptz not null default now(),
  unique (package_id, city, label)
);
alter table trip_rooms enable row level security;

create table if not exists trip_room_assignments (
  room_id      uuid not null references trip_rooms(id) on delete cascade,
  traveller_id uuid not null references booking_travellers(id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (room_id, traveller_id)
);
alter table trip_room_assignments enable row level security;

create table if not exists trip_transport_segments (
  id             uuid primary key default gen_random_uuid(),
  package_id     uuid not null references packages(id) on delete cascade,
  company_id     uuid not null references companies(id) on delete cascade,
  mode           text not null check (mode in ('flight','bus')),
  provider       text,
  reference_no   text,
  vehicle_no     text,
  driver_name    text,
  driver_phone   text,
  guide_name     text,
  departure_place text,
  departure_at   timestamptz,
  arrival_place  text,
  arrival_at     timestamptz,
  baggage        text,
  meeting_point  text,
  created_at     timestamptz not null default now()
);
alter table trip_transport_segments enable row level security;

create table if not exists trip_transport_assignments (
  segment_id   uuid not null references trip_transport_segments(id) on delete cascade,
  traveller_id uuid not null references booking_travellers(id) on delete cascade,
  seat_no      text,
  pickup_point text,
  created_at   timestamptz not null default now(),
  primary key (segment_id, traveller_id)
);
alter table trip_transport_assignments enable row level security;

create or replace function validate_trip_company()
returns trigger language plpgsql security invoker set search_path = public as $$
begin
  if not exists (
    select 1 from packages p
    where p.id = new.package_id and p.company_id = new.company_id
  ) then raise exception 'trip does not belong to company'; end if;
  return new;
end; $$;
drop trigger if exists before_announcement_trip_company on trip_announcements;
create trigger before_announcement_trip_company before insert or update on trip_announcements
for each row execute function validate_trip_company();
drop trigger if exists before_room_trip_company on trip_rooms;
create trigger before_room_trip_company before insert or update on trip_rooms
for each row execute function validate_trip_company();
drop trigger if exists before_transport_trip_company on trip_transport_segments;
create trigger before_transport_trip_company before insert or update on trip_transport_segments
for each row execute function validate_trip_company();

drop policy if exists "trip parties read announcements" on trip_announcements;
create policy "trip parties read announcements" on trip_announcements for select
to authenticated
using (
  can_access_company(company_id, 'announcements')
  or exists (
    select 1 from bookings b
    where b.package_id = package_id and b.client_id = (select auth.uid())
      and b.operational_stage not in ('cancelled','rejected','expired')
      and (
        audience = 'all'
        or (audience = 'confirmed'
            and b.operational_stage in ('confirmed','ready','in_progress','completed'))
        or (audience = 'unpaid' and b.amount_paid_iqd < b.total_iqd)
        or (audience = 'documents_missing' and exists (
          select 1 from booking_travellers t
          where t.booking_id = b.id and t.document_status <> 'approved'
        ))
      )
  )
);
drop policy if exists "company creates announcements" on trip_announcements;
create policy "company creates announcements" on trip_announcements for insert
to authenticated
with check (
  created_by = (select auth.uid())
  and can_access_company(company_id, 'announcements')
);

drop policy if exists "company manages rooms" on trip_rooms;
create policy "company manages rooms" on trip_rooms for all
to authenticated
using (can_access_company(company_id, 'operations'))
with check (can_access_company(company_id, 'operations'));
drop policy if exists "company manages transport" on trip_transport_segments;
create policy "company manages transport" on trip_transport_segments for all
to authenticated
using (can_access_company(company_id, 'operations'))
with check (can_access_company(company_id, 'operations'));

drop policy if exists "company manages room assignments" on trip_room_assignments;
create policy "company manages room assignments" on trip_room_assignments for all
to authenticated
using (exists (
  select 1 from trip_rooms r
  where r.id = room_id and can_access_company(r.company_id, 'operations')
))
with check (exists (
  select 1 from trip_rooms r
  where r.id = room_id and can_access_company(r.company_id, 'operations')
));
drop policy if exists "company manages transport assignments" on trip_transport_assignments;
create policy "company manages transport assignments" on trip_transport_assignments for all
to authenticated
using (exists (
  select 1 from trip_transport_segments s
  where s.id = segment_id and can_access_company(s.company_id, 'operations')
))
with check (exists (
  select 1 from trip_transport_segments s
  where s.id = segment_id and can_access_company(s.company_id, 'operations')
));

create or replace function assign_traveller_room(
  p_room_id uuid,
  p_traveller_id uuid
) returns void
language plpgsql security definer set search_path = public as $$
declare r trip_rooms%rowtype;
declare t booking_travellers%rowtype;
declare b bookings%rowtype;
declare occupied int;
begin
  select * into r from trip_rooms where id = p_room_id for update;
  if r.id is null then raise exception 'room not found'; end if;
  if not can_access_company(r.company_id, 'operations') then raise exception 'not allowed'; end if;
  select * into t from booking_travellers where id = p_traveller_id;
  if t.id is null then raise exception 'traveller not found'; end if;
  select * into b from bookings where id = t.booking_id;
  if b.package_id <> r.package_id or b.company_id <> r.company_id then
    raise exception 'traveller is not part of this trip';
  end if;
  if r.gender_policy in ('male','female') and t.gender is not null
     and t.gender <> r.gender_policy then
    raise exception 'traveller does not match the room group';
  end if;
  select count(*) into occupied from trip_room_assignments where room_id = r.id;
  if occupied >= r.capacity
     and not exists (
       select 1 from trip_room_assignments
       where room_id = r.id and traveller_id = t.id
     ) then raise exception 'room is full'; end if;

  -- A traveller may have one room per city, but a different room in Makkah
  -- and Madinah.
  delete from trip_room_assignments a
  using trip_rooms existing
  where a.room_id = existing.id
    and a.traveller_id = t.id
    and existing.package_id = r.package_id
    and existing.city = r.city;
  insert into trip_room_assignments(room_id, traveller_id)
  values (r.id, t.id)
  on conflict do nothing;
  perform write_audit('booking_traveller', t.id, 'room_assigned', null,
    jsonb_build_object('room_id', r.id, 'city', r.city), null);
end; $$;
revoke execute on function assign_traveller_room(uuid,uuid) from public, anon;
grant execute on function assign_traveller_room(uuid,uuid) to authenticated;

-- Extend the existing role-aware transition API to booking staff without
-- weakening the client-side transition rules or bypassing inventory locks.
create or replace function transition_booking(
  p_booking_id uuid, p_action text, p_reason text default null
) returns void language plpgsql security definer set search_path = public as $$
declare b bookings%rowtype;
declare package_id_value uuid;
declare next_stage text;
declare next_legacy booking_status;
declare release_seats boolean := false;
begin
  select package_id into package_id_value from bookings where id = p_booking_id;
  if package_id_value is null then raise exception 'booking not found'; end if;
  perform 1 from packages where id = package_id_value for update;
  select * into b from bookings where id = p_booking_id for update;
  if b.operational_stage in ('requested','needs_information','awaiting_payment')
     and b.expires_at is not null and b.expires_at <= now() then
    raise exception 'booking request has expired';
  end if;

  if p_action = 'accept' then
    if not can_access_company(b.company_id, 'bookings')
       or b.operational_stage <> 'requested' then
      raise exception 'booking cannot be accepted';
    end if;
    next_stage := case when b.amount_paid_iqd >= b.amount_due_now_iqd
      then 'confirmed' else 'awaiting_payment' end;
    next_legacy := case when next_stage = 'confirmed'
      then 'confirmed' else 'pending' end;
  elsif p_action = 'request_information' then
    if not can_access_company(b.company_id, 'bookings')
       or b.operational_stage not in ('requested','needs_information') then
      raise exception 'information cannot be requested';
    end if;
    if nullif(btrim(p_reason), '') is null then raise exception 'a reason is required'; end if;
    next_stage := 'needs_information'; next_legacy := 'pending';
  elsif p_action = 'reject' then
    if not can_access_company(b.company_id, 'bookings')
       or b.operational_stage not in ('requested','needs_information','awaiting_payment') then
      raise exception 'booking cannot be rejected';
    end if;
    if nullif(btrim(p_reason), '') is null then raise exception 'a reason is required'; end if;
    next_stage := 'rejected'; next_legacy := 'cancelled'; release_seats := true;
  elsif p_action = 'cancel' then
    if not (b.client_id = (select auth.uid())
            or can_access_company(b.company_id, 'bookings'))
       or b.operational_stage not in
          ('requested','needs_information','awaiting_payment','confirmed','ready') then
      raise exception 'booking cannot be cancelled';
    end if;
    if nullif(btrim(p_reason), '') is null then
      raise exception 'a cancellation reason is required';
    end if;
    next_stage := 'cancelled'; next_legacy := 'cancelled'; release_seats := true;
  elsif p_action = 'ready' then
    if not can_access_company(b.company_id, 'bookings')
       or b.operational_stage <> 'confirmed' then
      raise exception 'booking cannot be marked ready';
    end if;
    next_stage := 'ready'; next_legacy := 'confirmed';
  elsif p_action = 'start' then
    if not can_access_company(b.company_id, 'bookings')
       or b.operational_stage not in ('confirmed','ready') then
      raise exception 'booking cannot be started';
    end if;
    next_stage := 'in_progress'; next_legacy := 'confirmed';
  elsif p_action = 'complete' then
    if not can_access_company(b.company_id, 'bookings')
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
    cancelled_by = case when p_action in ('cancel','reject') then auth.uid() else cancelled_by end,
    expires_at = case
      when p_action = 'accept' and next_stage = 'awaiting_payment'
        then now() + case when b.pay_method = 'fib'
          then interval '30 minutes' else interval '24 hours' end
      when next_stage in ('confirmed','ready','in_progress','completed','cancelled','rejected')
        then null
      else expires_at
    end
  where id = p_booking_id;
  if release_seats then
    update packages set seats_reserved = greatest(0, seats_reserved - b.travellers)
    where id = b.package_id;
  end if;
  perform write_audit('booking', p_booking_id, p_action,
    jsonb_build_object('stage', b.operational_stage),
    jsonb_build_object('stage', next_stage), p_reason);
end; $$;
revoke execute on function transition_booking(uuid,text,text) from public, anon;
grant execute on function transition_booking(uuid,text,text) to authenticated;

create or replace function confirm_cash_received(
  p_booking_id uuid, p_amount_iqd bigint default null
) returns uuid language plpgsql security definer set search_path = public as $$
declare b bookings%rowtype;
declare amt bigint;
declare pid uuid;
declare idem text;
begin
  select * into b from bookings where id = p_booking_id for update;
  if b.id is null then raise exception 'booking not found'; end if;
  if not can_access_company(b.company_id, 'bookings') then
    raise exception 'not your booking';
  end if;
  if b.pay_method <> 'cash' then raise exception 'not a cash booking'; end if;
  if b.status = 'cancelled' then raise exception 'booking is cancelled'; end if;
  if p_amount_iqd is null and b.amount_paid_iqd >= b.total_iqd then
    select id into pid from payments
    where booking_id = b.id and method = 'cash' and status = 'succeeded'
    order by confirmed_at desc limit 1;
    return pid;
  end if;
  amt := coalesce(p_amount_iqd, b.total_iqd - b.amount_paid_iqd);
  if amt <= 0 or b.amount_paid_iqd + amt > b.total_iqd then
    raise exception 'invalid payment amount';
  end if;
  idem := 'cash-' || b.id || '-' || b.amount_paid_iqd;
  select id into pid from payments where idempotency_key = idem;
  if pid is null then
    insert into payments(booking_id, company_id, client_id, amount_iqd, method,
                         idempotency_key)
    values(b.id, b.company_id, b.client_id, amt, 'cash', idem)
    returning id into pid;
  end if;
  perform apply_successful_payment(pid, null);
  return pid;
end; $$;
revoke execute on function confirm_cash_received(uuid,bigint) from public, anon;
grant execute on function confirm_cash_received(uuid,bigint) to authenticated;

-- ---------------------------------------------------------------------------
-- 4. Private traveller-document storage
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('traveller-documents', 'traveller-documents', false)
on conflict (id) do update set public = false;

drop policy if exists "client upload traveller document files" on storage.objects;
create policy "client upload traveller document files" on storage.objects for insert
to authenticated
with check (
  bucket_id = 'traveller-documents'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and b.client_id = (select auth.uid())
  )
);
drop policy if exists "client replace traveller document files" on storage.objects;
create policy "client replace traveller document files" on storage.objects for update
to authenticated
using (
  bucket_id = 'traveller-documents'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and b.client_id = (select auth.uid())
  )
)
with check (
  bucket_id = 'traveller-documents'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and b.client_id = (select auth.uid())
  )
);
drop policy if exists "booking parties read traveller document files" on storage.objects;
create policy "booking parties read traveller document files" on storage.objects for select
to authenticated
using (
  bucket_id = 'traveller-documents'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and (
        b.client_id = (select auth.uid())
        or can_access_company(b.company_id, 'documents')
      )
  )
);

-- Staff document readers can also inspect legacy passport/selfie files.
drop policy if exists "booking parties read passports" on storage.objects;
create policy "booking parties read passports" on storage.objects for select
to authenticated
using (
  bucket_id = 'booking-passports'
  and exists (
    select 1 from bookings b
    where b.id::text = (storage.foldername(name))[1]
      and (
        b.client_id = (select auth.uid())
        or can_access_company(b.company_id, 'documents')
      )
  )
);

-- ---------------------------------------------------------------------------
-- 5. Explicit Data API privileges and realtime
-- ---------------------------------------------------------------------------
grant select on agency_staff, traveller_documents, trip_announcements,
  trip_rooms, trip_room_assignments, trip_transport_segments,
  trip_transport_assignments to authenticated;
grant insert on agency_staff, traveller_documents, trip_announcements,
  trip_rooms, trip_room_assignments, trip_transport_segments,
  trip_transport_assignments to authenticated;
grant update on agency_staff, trip_rooms, trip_transport_segments,
  trip_room_assignments, trip_transport_assignments to authenticated;
grant delete on agency_staff, trip_rooms, trip_room_assignments,
  trip_transport_segments, trip_transport_assignments to authenticated;

-- Assignment invariants (trip membership, room capacity, gender, one room per
-- city) are enforced by RPCs. Direct writes would bypass those checks.
-- Transport-assignment writes remain closed until their validation RPC exists.
revoke insert, update, delete on trip_room_assignments,
  trip_transport_assignments from authenticated;

grant select (local_name, gender, nationality, passport_expiry_date,
  national_id, emergency_contact, medical_notes, accessibility_notes,
  document_status, document_reason, visa_status, visa_reference, visa_reason,
  visa_updated_at, transport_seat) on booking_travellers to authenticated;

do $$ begin
  alter publication supabase_realtime add table trip_announcements;
exception when duplicate_object then null; end $$;
