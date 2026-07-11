-- ============================================================================
-- PATCH — Reviews fix. Run in: Supabase Dashboard > SQL Editor. Safe to re-run.
--
-- Fixes two bugs that made "rate this trip" fail / do nothing:
--
-- 1. schema.sql never created `companies.reviews`, but patches.sql §9 updates
--    it — so running patches.sql as one query FAILED and rolled back the
--    whole file, including the `reviews` table. Result: every review insert
--    errored with "relation reviews does not exist".
--    → This file is self-contained: it creates the column, the table, the
--      policies and the triggers, so reviews work even if patches.sql §7–9
--      never landed.
--
-- 2. `protect_company_admin_fields` resets `rating` on every non-admin
--    update. The review trigger recalculates the company rating *in the
--    client's session*, so the recalculated value was silently thrown away.
--    → System triggers now announce themselves via a transaction-local flag
--      (`app.system_update`) which the protect trigger respects.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. The missing columns (harmless if they already exist). is_promoted is
--    included so this file never depends on patches_promote.sql having run.
-- ---------------------------------------------------------------------------
alter table companies add column if not exists reviews int not null default 0;
alter table companies add column if not exists is_promoted boolean not null default false;

-- ---------------------------------------------------------------------------
-- 2. Reviews table + RLS (same definitions as patches.sql §7, idempotent).
-- ---------------------------------------------------------------------------
create table if not exists reviews (
  id          uuid primary key default gen_random_uuid(),
  booking_id  uuid not null references bookings(id) on delete cascade,
  company_id  uuid not null references companies(id) on delete cascade,
  client_id   uuid not null references profiles(id) on delete cascade,
  rating      int not null check (rating between 1 and 5),
  comment     text default '',
  created_at  timestamptz not null default now(),
  unique (booking_id)
);
create index if not exists reviews_company_id_idx on reviews(company_id);

alter table reviews enable row level security;

drop policy if exists "public read reviews" on reviews;
create policy "public read reviews" on reviews for select using (true);
drop policy if exists "client review own completed booking" on reviews;
create policy "client review own completed booking" on reviews for insert
  with check (
    client_id = auth.uid()
    and exists(select 1 from bookings b where b.id = booking_id
               and b.client_id = auth.uid() and b.status = 'completed')
  );

-- ---------------------------------------------------------------------------
-- 3. Rating recalc that actually sticks: mark the update as system-made so
--    the protect trigger lets rating/reviews through.
-- ---------------------------------------------------------------------------
create or replace function refresh_company_rating()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  perform set_config('app.system_update', 'on', true);  -- transaction-local
  update companies set
    rating  = coalesce((select round(avg(rating)::numeric, 1) from reviews
                        where company_id = new.company_id), 0),
    reviews = (select count(*) from reviews where company_id = new.company_id)
  where id = new.company_id;
  perform set_config('app.system_update', '', true);
  return new;
end; $$;

drop trigger if exists after_review_insert on reviews;
create trigger after_review_insert
  after insert on reviews
  for each row execute function refresh_company_rating();

-- ---------------------------------------------------------------------------
-- 4. Latest protect_company_admin_fields (supersedes the versions in
--    patches_admin.sql and patches_promote.sql): still blocks non-admin
--    self-service on the protected fields, but honours the system flag.
-- ---------------------------------------------------------------------------
create or replace function protect_company_admin_fields()
returns trigger language plpgsql as $$
begin
  if coalesce(current_setting('app.system_update', true), '') = 'on' then
    return new;                       -- trusted trigger/function update
  end if;
  if not is_admin() then
    new.is_verified := old.is_verified;
    new.is_active   := old.is_active;
    new.is_promoted := old.is_promoted;
    new.rating      := old.rating;
    new.reviews     := old.reviews;
    new.owner_id    := old.owner_id;
  end if;
  return new;
end; $$;

drop trigger if exists before_company_update on companies;
create trigger before_company_update
  before update on companies
  for each row execute function protect_company_admin_fields();

-- ---------------------------------------------------------------------------
-- 5. The statement that broke patches.sql, now safe to apply: zero out
--    seeded placholder ratings for companies with no real reviews.
-- ---------------------------------------------------------------------------
update companies set rating = 0, reviews = 0
where id not in (select distinct company_id from reviews);
