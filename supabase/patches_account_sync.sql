-- ============================================================================
-- PATCH — account-level sync: saved trips, payment methods, preferences.
-- Run once in: Supabase Dashboard > SQL Editor > New query
-- (after schema.sql + patches.sql). Safe to re-run.
-- ============================================================================

-- 1. Saved / favourited packages — follow the account across devices.
create table if not exists saved_offers (
  client_id   uuid not null references profiles(id) on delete cascade,
  package_id  uuid not null references packages(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (client_id, package_id)
);
alter table saved_offers enable row level security;

drop policy if exists "client manage own saved offers" on saved_offers;
create policy "client manage own saved offers" on saved_offers for all
  using (client_id = auth.uid())
  with check (client_id = auth.uid());

-- 2. Saved payment methods. Only masked data is ever stored (last 4 digits,
--    expiry, brand) — never a full card number. In a real production build
--    this table would instead hold a payment-processor token.
create table if not exists payment_cards (
  id          uuid primary key default gen_random_uuid(),
  client_id   uuid not null references profiles(id) on delete cascade,
  holder      text not null,
  last4       text not null,
  expiry      text not null,
  brand       text not null,
  is_default  boolean not null default false,
  created_at  timestamptz not null default now()
);
alter table payment_cards enable row level security;

drop policy if exists "client manage own cards" on payment_cards;
create policy "client manage own cards" on payment_cards for all
  using (client_id = auth.uid())
  with check (client_id = auth.uid());

-- 3. Account-wide preferences (as opposed to biometric lock, which is
--    deliberately per-device and stays local-only).
alter table profiles add column if not exists marketing_emails boolean not null default true;
alter table profiles add column if not exists two_factor_enabled boolean not null default false;
alter table profiles add column if not exists share_activity boolean not null default false;
