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

-- 5. Real notifications — a pilgrim learns their booking was confirmed or
--    declined even if the agency acted in a completely different session.
create table if not exists notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  type        text not null,   -- matches the app's NotificationType enum name
  arg         text,            -- interpolated into the message (package title)
  booking_id  uuid references bookings(id) on delete cascade,
  read        boolean not null default false,
  created_at  timestamptz not null default now()
);
create index if not exists notifications_user_id_idx on notifications(user_id);

alter table notifications enable row level security;

drop policy if exists "read own notifications" on notifications;
create policy "read own notifications" on notifications for select
  using (user_id = auth.uid());
drop policy if exists "update own notifications" on notifications;
create policy "update own notifications" on notifications for update
  using (user_id = auth.uid());
drop policy if exists "delete own notifications" on notifications;
create policy "delete own notifications" on notifications for delete
  using (user_id = auth.uid());

-- Fires whenever an agency/admin confirms or cancels a booking (the client's
-- own cancel/create actions already give instant local feedback in-app, so
-- this only needs to cover the cross-session case).
create or replace function notify_booking_status_change()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  ntype text;
begin
  if new.status = old.status then
    return new;
  end if;
  if new.status = 'confirmed' then
    ntype := 'bookingConfirmed';
  elsif new.status = 'cancelled' then
    ntype := 'bookingCancelled';
  else
    return new;
  end if;

  insert into notifications (user_id, type, arg, booking_id)
  values (new.client_id, ntype, (select title from packages where id = new.package_id), new.id);
  return new;
end; $$;

drop trigger if exists on_booking_status_change on bookings;
create trigger on_booking_status_change
  after update on bookings
  for each row execute function notify_booking_status_change();

-- 6. Help & Support messages actually go somewhere instead of vanishing —
--    readable by admins so a real person can follow up.
create table if not exists support_messages (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references profiles(id) on delete set null,
  email       text,
  message     text not null,
  created_at  timestamptz not null default now()
);

alter table support_messages enable row level security;

drop policy if exists "send support message" on support_messages;
create policy "send support message" on support_messages for insert
  with check (user_id = auth.uid() or user_id is null);
drop policy if exists "admin read support messages" on support_messages;
create policy "admin read support messages" on support_messages for select
  using (is_admin());

-- 7. Reviews — a pilgrim can rate a completed trip; the company's rating/
--    review count (already-existing columns, shown everywhere in the app)
--    become a real average instead of a static seed number.
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

create or replace function refresh_company_rating()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update companies set
    rating = coalesce((select round(avg(rating)::numeric, 1) from reviews where company_id = new.company_id), 0),
    reviews = (select count(*) from reviews where company_id = new.company_id)
  where id = new.company_id;
  return new;
end; $$;

drop trigger if exists after_review_insert on reviews;
create trigger after_review_insert
  after insert on reviews
  for each row execute function refresh_company_rating();

-- 8. Lightweight, dependency-free crash visibility: uncaught Flutter errors
--    are best-effort logged here instead of only appearing in a connected
--    debugger. Write-only from the app; only admins can read them back.
create table if not exists error_logs (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references profiles(id) on delete set null,
  message     text not null,
  stack       text,
  context     text,
  created_at  timestamptz not null default now()
);

alter table error_logs enable row level security;

drop policy if exists "log errors" on error_logs;
create policy "log errors" on error_logs for insert with check (true);
drop policy if exists "admin read error logs" on error_logs;
create policy "admin read error logs" on error_logs for select using (is_admin());

-- 9. `companies.reviews` already existed as a seed placeholder count; make
--    sure it (and rating) start at a real zero for any company with no
--    reviews yet rather than a stale seeded number.
update companies set rating = 0, reviews = 0
where id not in (select distinct company_id from reviews);

-- 10. Preferred payment method (cash/card/fib), replacing the old fake
--     card-collection form — payment always happens at the agency, so all
--     the app needs to remember is how the pilgrim intends to pay.
--     Must be explicitly granted: patches_admin.sql #2 restricted `profiles`
--     updates to a column allowlist, so a newly-added column is unwritable
--     by users until granted here.
alter table profiles add column if not exists preferred_pay_method text not null default 'cash';
grant update (preferred_pay_method) on profiles to authenticated;

-- 11. Drop the two-factor-auth flag (patches_account_sync.sql) — the app
--     never had a real TOTP/OTP implementation behind it, so the toggle
--     was pure theatre. Removed rather than left half-built and misleading.
alter table profiles drop column if exists two_factor_enabled;

-- 12. Add banner_url column to companies table for background images
alter table companies add column if not exists banner_url text;
