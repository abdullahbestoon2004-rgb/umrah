-- ============================================================================
-- UMRAH MARKETPLACE — Supabase schema
-- Run this in: Supabase Dashboard > SQL Editor > New query
-- ============================================================================
-- Roles: 'client'  (browses & books)
--        'agency'  (publishes packages, sees their bookings + commission owed)
--        'admin'   (you — sees everything, reconciles commission)
--
-- Commission: platform takes 5% of every booking. Stored per booking so you
-- can change the rate later without rewriting history.
-- ============================================================================

-- ---------- ENUM TYPES ----------
create type user_role        as enum ('client', 'agency', 'admin');
create type transport_kind   as enum ('plane', 'bus');
create type booking_status   as enum ('pending', 'confirmed', 'cancelled', 'completed');
create type payment_method   as enum ('cash', 'card', 'fib');
create type payment_status   as enum ('unpaid', 'paid', 'refunded');
create type commission_status as enum ('owed', 'collected', 'waived');

-- ============================================================================
-- PROFILES  (1 row per auth user, holds their role)
-- ============================================================================
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  role        user_role not null default 'client',
  full_name   text,
  phone       text,
  created_at  timestamptz not null default now()
);

-- Auto-create a profile row whenever a new auth user signs up.
-- The role is read from the sign-up metadata (defaults to 'client').
create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, role, full_name, phone)
  values (
    new.id,
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'client'),
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone'
  );
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ============================================================================
-- COMPANIES  (an agency's public profile; one per agency account)
-- ============================================================================
create table companies (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid not null references profiles(id) on delete cascade,
  name         text not null,
  name_ar      text,
  name_en      text,
  location     text,
  logo_url     text,
  banner_url   text,
  tint         text default '#0f5c4d',   -- brand colour for the avatar tile
  rating       numeric(2,1) default 0,
  since        int,                        -- year founded
  is_verified  boolean default false,      -- you flip this to true after vetting
  is_active    boolean default true,
  created_at   timestamptz not null default now()
);
create index on companies(owner_id);

-- ============================================================================
-- PACKAGES  (an Umrah trip an agency publishes)
-- ============================================================================
create table packages (
  id             uuid primary key default gen_random_uuid(),
  company_id     uuid not null references companies(id) on delete cascade,
  title          text not null,
  title_ar       text,
  title_en       text,
  overview       text,
  overview_ar    text,
  overview_en    text,
  price_iqd      bigint not null,          -- price per person, in IQD (no decimals)
  original_iqd   bigint,                   -- optional was-price for a discount badge
  days           int not null,
  nights         int not null,
  transport      transport_kind not null,
  carrier        text,                     -- "Iraqi Airways", "Deluxe Coach"...
  transfer_note  text,
  acc_stars      int not null check (acc_stars between 1 and 5),
  hotel          text,
  distance_haram text,                     -- "250m to Haram"
  room           text,                     -- "Quad sharing"
  meals          text,                     -- "Breakfast & dinner"
  includes       text[] default '{}',      -- ["Visa","Transfers",...]
  badge          text,                     -- "Best value" / null
  image_url      text,
  is_published   boolean default false,
  created_at     timestamptz not null default now()
);
create index on packages(company_id);
create index on packages(is_published);
create index on packages(price_iqd);

-- ============================================================================
-- ITINERARY  (day-by-day rows for a package)
-- ============================================================================
create table itinerary_days (
  id          uuid primary key default gen_random_uuid(),
  package_id  uuid not null references packages(id) on delete cascade,
  day_no      int not null,
  title       text not null,
  title_ar    text,
  title_en    text,
  summary     text,
  summary_ar  text,
  summary_en  text
);
create index on itinerary_days(package_id);

-- ============================================================================
-- BOOKINGS  (a client buys a package)
-- ============================================================================
create table bookings (
  id              uuid primary key default gen_random_uuid(),
  package_id      uuid not null references packages(id) on delete restrict,
  company_id      uuid not null references companies(id) on delete restrict,
  client_id       uuid not null references profiles(id)  on delete restrict,
  travellers      int not null default 1 check (travellers > 0),
  unit_price_iqd  bigint not null,           -- snapshot of price at booking time
  total_iqd       bigint not null,           -- unit_price * travellers
  commission_rate numeric(4,3) not null default 0.05,   -- 5%
  commission_iqd  bigint not null,           -- platform's cut
  payout_iqd      bigint not null,           -- what the agency receives (total - commission)
  pay_method      payment_method not null,
  pay_status      payment_status not null default 'unpaid',
  status          booking_status not null default 'pending',
  contact_phone   text,
  note            text,
  created_at      timestamptz not null default now()
);
create index on bookings(company_id);
create index on bookings(client_id);
create index on bookings(status);

-- Compute commission/total automatically so the client app can't fake the maths.
create or replace function fill_booking_amounts()
returns trigger language plpgsql as $$
declare
  pkg_price bigint;
  pkg_company uuid;
begin
  select price_iqd, company_id into pkg_price, pkg_company
  from packages where id = new.package_id;

  new.company_id     := pkg_company;
  new.unit_price_iqd := pkg_price;
  new.total_iqd      := pkg_price * new.travellers;
  new.commission_iqd := round(new.total_iqd * new.commission_rate);
  new.payout_iqd     := new.total_iqd - new.commission_iqd;
  return new;
end; $$;

create trigger before_booking_insert
  before insert on bookings
  for each row execute function fill_booking_amounts();

-- ============================================================================
-- COMMISSIONS  (ledger: what each agency owes you, esp. for cash bookings)
-- ============================================================================
create table commissions (
  id           uuid primary key default gen_random_uuid(),
  booking_id   uuid not null references bookings(id) on delete cascade,
  company_id   uuid not null references companies(id) on delete cascade,
  amount_iqd   bigint not null,
  status       commission_status not null default 'owed',
  collected_at timestamptz,
  created_at   timestamptz not null default now()
);
create index on commissions(company_id);
create index on commissions(status);

-- Open a commission ledger row for every confirmed booking.
create or replace function open_commission()
returns trigger language plpgsql as $$
begin
  if new.status = 'confirmed' and (old.status is distinct from 'confirmed') then
    insert into commissions (booking_id, company_id, amount_iqd, status)
    values (new.id, new.company_id, new.commission_iqd,
            (case when new.pay_method = 'cash' then 'owed' else 'collected' end)::commission_status);
  end if;
  return new;
end; $$;

create trigger after_booking_confirmed
  after update on bookings
  for each row execute function open_commission();

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table profiles       enable row level security;
alter table companies      enable row level security;
alter table packages       enable row level security;
alter table itinerary_days enable row level security;
alter table bookings       enable row level security;
alter table commissions    enable row level security;

-- helper: is the current user an admin?
create or replace function is_admin() returns boolean language sql stable as $$
  select exists(select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

-- helper: does the current user own this company?
create or replace function owns_company(cid uuid) returns boolean language sql stable as $$
  select exists(select 1 from companies where id = cid and owner_id = auth.uid());
$$;

-- ---- profiles ----
create policy "read own profile"   on profiles for select using (id = auth.uid() or is_admin());
create policy "update own profile" on profiles for update using (id = auth.uid());

-- ---- companies ----  (anyone can browse active+verified; owners/admin manage)
create policy "public read companies" on companies for select
  using ((is_active and is_verified) or owner_id = auth.uid() or is_admin());
create policy "agency insert own company" on companies for insert
  with check (owner_id = auth.uid());
create policy "agency update own company" on companies for update
  using (owner_id = auth.uid() or is_admin());

-- ---- packages ----  (public sees published; owners/admin manage their own)
create policy "public read packages" on packages for select
  using (is_published or owns_company(company_id) or is_admin());
create policy "agency manage packages" on packages for all
  using (owns_company(company_id) or is_admin())
  with check (owns_company(company_id) or is_admin());

-- ---- itinerary ---- (follows its package)
create policy "read itinerary" on itinerary_days for select
  using (exists(select 1 from packages p where p.id = package_id
               and (p.is_published or owns_company(p.company_id) or is_admin())));
create policy "manage itinerary" on itinerary_days for all
  using (exists(select 1 from packages p where p.id = package_id
               and (owns_company(p.company_id) or is_admin())))
  with check (exists(select 1 from packages p where p.id = package_id
               and (owns_company(p.company_id) or is_admin())));

-- ---- bookings ----  (client sees own; agency sees bookings for their company)
create policy "client read own bookings" on bookings for select
  using (client_id = auth.uid() or owns_company(company_id) or is_admin());
create policy "client create booking" on bookings for insert
  with check (client_id = auth.uid());
create policy "agency or admin update booking" on bookings for update
  using (owns_company(company_id) or is_admin());

-- ---- commissions ----  (agency sees own; only admin collects)
create policy "agency read commissions" on commissions for select
  using (owns_company(company_id) or is_admin());
create policy "admin update commissions" on commissions for update
  using (is_admin());
