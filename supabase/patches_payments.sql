-- ============================================================================
-- PATCH — Payment & commission system (hybrid marketplace model).
-- Run in: Supabase Dashboard > SQL Editor. Safe to re-run.
--
-- Money model (see PAYMENTS.md for the full story):
--   * Online payments (fib/card): the PLATFORM collects. We owe the agency
--     (total − commission)  →  ledger entry 'booking_credit', POSITIVE.
--   * Cash payments: the AGENCY collects. It owes us the commission
--     →  ledger entry 'cash_commission_debit', NEGATIVE.
--   * One signed running balance per agency, derived from agency_ledger.
--     positive = platform owes agency · negative = agency owes platform.
--   * agency_ledger is APPEND-ONLY. Corrections are new compensating rows.
--   * Commission is earned per successful payment, proportionally, so
--     deposits/partial payments "just work". A fully paid booking ends up
--     with exactly its snapshotted commission_iqd / payout_iqd ledgered.
--
-- Conventions kept from the existing schema:
--   * amounts are bigint IQD (no decimals), rates are numeric.
--   * "agency" = companies row · "trip" = packages row.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. Enum extensions (parsed at runtime only, so safe in this transaction)
-- ----------------------------------------------------------------------------
alter type payment_status add value if not exists 'partially_paid';
alter type payment_status add value if not exists 'failed';

-- ----------------------------------------------------------------------------
-- 1. bookings — financial snapshot additions
--    (unit_price_iqd, total_iqd, commission_rate, commission_iqd, payout_iqd,
--     pay_method, pay_status already exist.)
-- ----------------------------------------------------------------------------
alter table bookings add column if not exists amount_paid_iqd bigint not null default 0;
alter table bookings add column if not exists currency text not null default 'IQD';
-- Widen the rate so 4-decimal rates (e.g. 0.0825) survive the snapshot.
alter table bookings alter column commission_rate type numeric(5,4);

-- ----------------------------------------------------------------------------
-- 2. Commission rate config: per-agency, with optional per-package override.
--    Falls back: package rate → company rate → 0.05 (existing platform default)
-- ----------------------------------------------------------------------------
alter table companies add column if not exists commission_rate numeric(5,4) not null default 0.0500;
alter table packages  add column if not exists commission_rate numeric(5,4);  -- null = use company rate

create or replace function resolve_commission_rate(p_package_id uuid)
returns numeric language sql stable as $$
  select coalesce(p.commission_rate, c.commission_rate, 0.0500)
  from packages p join companies c on c.id = p.company_id
  where p.id = p_package_id;
$$;

-- Recompute booking amounts server-side on insert. Replaces the original
-- fill_booking_amounts: same behaviour, plus the rate is now resolved here
-- (package → company → default) instead of trusting the client's value.
create or replace function fill_booking_amounts()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  pkg_price bigint;
  pkg_company uuid;
begin
  select price_iqd, company_id into pkg_price, pkg_company
  from packages where id = new.package_id;

  new.company_id      := pkg_company;
  new.unit_price_iqd  := pkg_price;
  new.total_iqd       := pkg_price * new.travellers;
  new.commission_rate := resolve_commission_rate(new.package_id);
  new.commission_iqd  := round(new.total_iqd * new.commission_rate);
  new.payout_iqd      := new.total_iqd - new.commission_iqd;
  new.amount_paid_iqd := 0;
  return new;
end; $$;

-- ----------------------------------------------------------------------------
-- 3. payments — one row per payment attempt / transaction
-- ----------------------------------------------------------------------------
create table if not exists payments (
  id                 uuid primary key default gen_random_uuid(),
  booking_id         uuid not null references bookings(id) on delete restrict,
  company_id         uuid not null references companies(id) on delete restrict,
  client_id          uuid not null references profiles(id)  on delete restrict,
  amount_iqd         bigint not null check (amount_iqd > 0),
  refunded_iqd       bigint not null default 0 check (refunded_iqd >= 0),
  method             payment_method not null,
  status             text not null default 'initiated'
                     check (status in ('initiated','succeeded','failed','refunded')),
  provider_reference text,                    -- FIB paymentId / gateway txn id
  idempotency_key    text unique,
  failure_reason     text,
  created_at         timestamptz not null default now(),
  confirmed_at       timestamptz
);
create index if not exists payments_booking_idx  on payments(booking_id);
create index if not exists payments_company_idx  on payments(company_id);
create index if not exists payments_provider_idx on payments(provider_reference);

-- ----------------------------------------------------------------------------
-- 4. agency_ledger — the single source of financial truth. APPEND-ONLY.
-- ----------------------------------------------------------------------------
create table if not exists agency_ledger (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid not null references companies(id) on delete restrict,
  booking_id  uuid references bookings(id),
  payment_id  uuid references payments(id),
  payout_id   uuid,                           -- fk added below (payouts follows)
  entry_type  text not null check (entry_type in
              ('booking_credit','cash_commission_debit','payout',
               'refund_reversal','adjustment')),
  -- SIGNED: positive = platform owes agency · negative = agency owes platform
  amount_iqd  bigint not null check (amount_iqd <> 0),
  description text,
  created_at  timestamptz not null default now()
);
create index if not exists ledger_company_idx on agency_ledger(company_id, created_at desc);
create index if not exists ledger_booking_idx on agency_ledger(booking_id);
-- Idempotency guards: one earning entry per payment, one entry per payout.
create unique index if not exists ledger_payment_once
  on agency_ledger(payment_id, entry_type) where payment_id is not null;
create unique index if not exists ledger_payout_once
  on agency_ledger(payout_id) where payout_id is not null;

-- Append-only, enforced at the database level: even security-definer functions
-- cannot update or delete ledger rows. Corrections are compensating entries.
create or replace function forbid_ledger_mutation()
returns trigger language plpgsql as $$
begin
  raise exception 'agency_ledger is append-only — insert a compensating entry instead';
end; $$;
drop trigger if exists ledger_no_update_delete on agency_ledger;
create trigger ledger_no_update_delete
  before update or delete on agency_ledger
  for each row execute function forbid_ledger_mutation();

revoke update, delete on agency_ledger from anon, authenticated;

-- ----------------------------------------------------------------------------
-- 5. payouts — money actually transferred to an agency
-- ----------------------------------------------------------------------------
create table if not exists payouts (
  id           uuid primary key default gen_random_uuid(),
  company_id   uuid not null references companies(id) on delete restrict,
  amount_iqd   bigint not null check (amount_iqd > 0),
  method       text,                          -- 'bank', 'fib', 'cash', ...
  reference    text,                          -- transfer receipt / txn id
  status       text not null default 'pending'
               check (status in ('pending','completed','failed')),
  period_start date,
  period_end   date,
  created_at   timestamptz not null default now(),
  completed_at timestamptz
);
create index if not exists payouts_company_idx on payouts(company_id);

-- Now that payouts exists, wire the ledger fk.
do $$ begin
  alter table agency_ledger
    add constraint agency_ledger_payout_id_fkey
    foreign key (payout_id) references payouts(id);
exception when duplicate_object then null; end $$;

-- ----------------------------------------------------------------------------
-- 6. agency_balances — a VIEW, never a stored number.
--    security_invoker: agencies only see their own row through ledger RLS.
-- ----------------------------------------------------------------------------
create or replace view agency_balances
with (security_invoker = true) as
select company_id, coalesce(sum(amount_iqd), 0)::bigint as balance_iqd
from agency_ledger
group by company_id;
grant select on agency_balances to authenticated;

-- ============================================================================
-- CORE MONEY FUNCTIONS
-- All money mutations go through these security-definer functions. Clients and
-- agencies never write financial columns directly (RLS gives them no path).
-- ============================================================================

-- Internal: post one ledger row (skips zero-amount no-ops).
create or replace function post_ledger_entry(
  p_company uuid, p_booking uuid, p_payment uuid, p_payout uuid,
  p_type text, p_amount bigint, p_description text
) returns void language plpgsql security definer set search_path = public as $$
begin
  if p_amount = 0 then return; end if;
  insert into agency_ledger (company_id, booking_id, payment_id, payout_id,
                             entry_type, amount_iqd, description)
  values (p_company, p_booking, p_payment, p_payout, p_type, p_amount, p_description);
end; $$;
revoke execute on function post_ledger_entry(uuid,uuid,uuid,uuid,text,bigint,text)
  from public, anon, authenticated;

-- Internal: after a booking's paid amount changed, bring its ledgered earnings
-- to the exact proportional target. True-up (target − already ledgered) makes
-- every call idempotent and immune to rounding drift: a fully paid booking is
-- ledgered for exactly payout_iqd (online) / −commission_iqd (cash).
create or replace function true_up_booking_ledger(p_booking_id uuid, p_payment_id uuid, p_type_hint text)
returns void language plpgsql security definer set search_path = public as $$
declare
  b bookings%rowtype;
  is_cash boolean;
  target bigint;
  ledgered bigint;
  delta bigint;
begin
  select * into b from bookings where id = p_booking_id for update;
  is_cash := (b.pay_method = 'cash');

  if is_cash then
    target := -round(b.commission_iqd * b.amount_paid_iqd::numeric / b.total_iqd);
  else
    target := round(b.payout_iqd * b.amount_paid_iqd::numeric / b.total_iqd);
  end if;

  select coalesce(sum(amount_iqd), 0) into ledgered
  from agency_ledger
  where booking_id = p_booking_id
    and entry_type in ('booking_credit','cash_commission_debit','refund_reversal');

  delta := target - ledgered;
  perform post_ledger_entry(
    b.company_id, b.id, p_payment_id, null,
    case
      when p_type_hint = 'refund_reversal' then 'refund_reversal'
      when is_cash then 'cash_commission_debit'
      else 'booking_credit'
    end,
    delta,
    case
      when p_type_hint = 'refund_reversal' then 'Refund reversal'
      when is_cash then 'Commission owed on cash payment'
      else 'Agency share of online payment'
    end);
end; $$;
revoke execute on function true_up_booking_ledger(uuid,uuid,text)
  from public, anon, authenticated;

-- Client initiates a payment attempt on their own booking (online methods),
-- or the flow functions below create the row themselves (cash).
-- Idempotent on p_idempotency_key: re-calling returns the existing payment.
create or replace function initiate_payment(
  p_booking_id uuid, p_amount_iqd bigint, p_method payment_method, p_idempotency_key text
) returns uuid language plpgsql security definer set search_path = public as $$
declare
  b bookings%rowtype;
  existing uuid;
  pid uuid;
begin
  select id into existing from payments where idempotency_key = p_idempotency_key;
  if existing is not null then return existing; end if;

  select * into b from bookings where id = p_booking_id for update;
  if b.id is null then raise exception 'booking not found'; end if;
  if b.client_id <> auth.uid() and not is_admin() then
    raise exception 'not your booking';
  end if;
  if b.status = 'cancelled' then raise exception 'booking is cancelled'; end if;
  if p_amount_iqd <= 0 or b.amount_paid_iqd + p_amount_iqd > b.total_iqd then
    raise exception 'invalid amount: % (paid % of %)', p_amount_iqd, b.amount_paid_iqd, b.total_iqd;
  end if;
  -- v1: no mixing of cash and online money on one booking.
  if (p_method = 'cash') <> (b.pay_method = 'cash') then
    raise exception 'payment method does not match booking method';
  end if;

  insert into payments (booking_id, company_id, client_id, amount_iqd, method, idempotency_key)
  values (b.id, b.company_id, b.client_id, p_amount_iqd, p_method, p_idempotency_key)
  returning id into pid;
  return pid;
end; $$;

-- Internal core: flip a payment to succeeded and roll it up into the booking
-- + ledger. Idempotent: a payment already succeeded is a no-op.
create or replace function apply_successful_payment(p_payment_id uuid, p_provider_reference text)
returns void language plpgsql security definer set search_path = public as $$
declare
  p payments%rowtype;
  b bookings%rowtype;
begin
  select * into p from payments where id = p_payment_id for update;
  if p.id is null then raise exception 'payment not found'; end if;
  if p.status = 'succeeded' then return; end if;      -- idempotent
  if p.status <> 'initiated' then
    raise exception 'payment % is %, cannot succeed', p.id, p.status;
  end if;

  update payments
     set status = 'succeeded',
         confirmed_at = now(),
         provider_reference = coalesce(p_provider_reference, provider_reference)
   where id = p.id;

  select * into b from bookings where id = p.booking_id for update;
  update bookings
     set amount_paid_iqd = b.amount_paid_iqd + p.amount_iqd,
         pay_status = case when b.amount_paid_iqd + p.amount_iqd >= b.total_iqd
                           then 'paid' else 'partially_paid' end::payment_status
   where id = b.id;

  perform true_up_booking_ledger(b.id, p.id, null);
end; $$;
revoke execute on function apply_successful_payment(uuid,text)
  from public, anon, authenticated;

-- Webhook entry point (service role only — the Flutter client can NEVER call
-- this): the Edge Function verifies the gateway callback, then records it.
create or replace function record_payment_success(p_payment_id uuid, p_provider_reference text)
returns void language plpgsql security definer set search_path = public as $$
begin
  perform apply_successful_payment(p_payment_id, p_provider_reference);
end; $$;
revoke execute on function record_payment_success(uuid,text)
  from public, anon, authenticated;
grant execute on function record_payment_success(uuid,text) to service_role;

create or replace function record_payment_failure(p_payment_id uuid, p_reason text)
returns void language plpgsql security definer set search_path = public as $$
declare
  p payments%rowtype;
begin
  select * into p from payments where id = p_payment_id for update;
  if p.id is null then raise exception 'payment not found'; end if;
  if p.status in ('failed','refunded') then return; end if;  -- idempotent
  if p.status = 'succeeded' then
    raise exception 'payment % already succeeded — refund it instead', p.id;
  end if;

  update payments set status = 'failed', failure_reason = p_reason where id = p.id;
  -- Only surface 'failed' on the booking if no money has landed on it.
  update bookings set pay_status = 'failed'
   where id = p.booking_id and amount_paid_iqd = 0 and pay_status <> 'refunded';
end; $$;
revoke execute on function record_payment_failure(uuid,text)
  from public, anon, authenticated;
grant execute on function record_payment_failure(uuid,text) to service_role;

-- Agency confirms cash received at the office (their own bookings only).
-- Creates the cash payment row and applies it — which posts the negative
-- commission ledger entry. Defaults to the full remaining amount.
create or replace function confirm_cash_received(p_booking_id uuid, p_amount_iqd bigint default null)
returns uuid language plpgsql security definer set search_path = public as $$
declare
  b bookings%rowtype;
  amt bigint;
  pid uuid;
  idem text;
begin
  select * into b from bookings where id = p_booking_id for update;
  if b.id is null then raise exception 'booking not found'; end if;
  if not (owns_company(b.company_id) or is_admin()) then
    raise exception 'not your booking';
  end if;
  if b.pay_method <> 'cash' then raise exception 'not a cash booking'; end if;
  if b.status = 'cancelled' then raise exception 'booking is cancelled'; end if;

  -- Double-tap on an already fully-collected booking: harmless no-op.
  if p_amount_iqd is null and b.amount_paid_iqd >= b.total_iqd then
    select id into pid from payments
     where booking_id = b.id and method = 'cash' and status = 'succeeded'
     order by confirmed_at desc limit 1;
    return pid;
  end if;

  amt := coalesce(p_amount_iqd, b.total_iqd - b.amount_paid_iqd);
  if amt <= 0 or b.amount_paid_iqd + amt > b.total_iqd then
    raise exception 'invalid amount: % (paid % of %)', amt, b.amount_paid_iqd, b.total_iqd;
  end if;

  -- Deterministic per booking-state, so a double-tap can't record cash twice:
  -- the second call finds the row and just re-applies (which is a no-op).
  idem := 'cash-' || b.id || '-' || b.amount_paid_iqd;
  select id into pid from payments where idempotency_key = idem;
  if pid is null then
    insert into payments (booking_id, company_id, client_id, amount_iqd, method,
                          idempotency_key)
    values (b.id, b.company_id, b.client_id, amt, 'cash', idem)
    returning id into pid;
  end if;

  perform apply_successful_payment(pid, null);
  return pid;
end; $$;

-- Refund (admin only for v1). Defaults to a full refund of what was paid.
-- Partial refunds reverse commission/credit proportionally via the true-up.
-- Payments rows are marked refunded newest-first.
create or replace function refund_booking(p_booking_id uuid, p_amount_iqd bigint default null)
returns void language plpgsql security definer set search_path = public as $$
declare
  b bookings%rowtype;
  amt bigint;
  remaining bigint;
  pay record;
  slice bigint;
begin
  if not is_admin() then raise exception 'admin only'; end if;

  select * into b from bookings where id = p_booking_id for update;
  if b.id is null then raise exception 'booking not found'; end if;

  amt := coalesce(p_amount_iqd, b.amount_paid_iqd);
  if amt <= 0 or amt > b.amount_paid_iqd then
    raise exception 'invalid refund: % (paid %)', amt, b.amount_paid_iqd;
  end if;

  -- Mark payment rows refunded, newest first.
  remaining := amt;
  for pay in
    select * from payments
    where booking_id = b.id and status = 'succeeded'
    order by confirmed_at desc
    for update
  loop
    exit when remaining <= 0;
    slice := least(remaining, pay.amount_iqd - pay.refunded_iqd);
    if slice > 0 then
      update payments
         set refunded_iqd = refunded_iqd + slice,
             status = case when refunded_iqd + slice >= amount_iqd
                           then 'refunded' else status end
       where id = pay.id;
      remaining := remaining - slice;
    end if;
  end loop;

  update bookings
     set amount_paid_iqd = amount_paid_iqd - amt,
         pay_status = case
           when amount_paid_iqd - amt = 0 then 'refunded'
           else 'partially_paid' end::payment_status
   where id = b.id;

  perform true_up_booking_ledger(b.id, null, 'refund_reversal');
end; $$;

-- Cancelling a booking automatically reverses any money already ledgered.
create or replace function on_booking_cancelled()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.status = 'cancelled' and old.status is distinct from 'cancelled'
     and new.amount_paid_iqd > 0 then
    -- Same reversal path as an admin refund, bypassing the admin check
    -- (the cancel itself is already permission-gated by bookings RLS).
    update payments set refunded_iqd = amount_iqd, status = 'refunded'
     where booking_id = new.id and status = 'succeeded';
    update bookings set amount_paid_iqd = 0, pay_status = 'refunded'
     where id = new.id;
    perform true_up_booking_ledger(new.id, null, 'refund_reversal');
  end if;
  return new;
end; $$;
drop trigger if exists after_booking_cancelled on bookings;
create trigger after_booking_cancelled
  after update on bookings
  for each row execute function on_booking_cancelled();

-- Manual admin correction — the only way to post an 'adjustment'.
create or replace function add_ledger_adjustment(
  p_company_id uuid, p_amount_iqd bigint, p_description text
) returns void language plpgsql security definer set search_path = public as $$
begin
  if not is_admin() then raise exception 'admin only'; end if;
  if p_amount_iqd = 0 then raise exception 'amount must be non-zero'; end if;
  perform post_ledger_entry(p_company_id, null, null, null,
                            'adjustment', p_amount_iqd, p_description);
end; $$;

-- ----------------------------------------------------------------------------
-- Payouts (admin-triggered, v1)
-- ----------------------------------------------------------------------------
create or replace function create_payout(
  p_company_id uuid, p_amount_iqd bigint,
  p_method text default 'bank', p_period_start date default null, p_period_end date default null
) returns uuid language plpgsql security definer set search_path = public as $$
declare
  bal bigint;
  pid uuid;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  if p_amount_iqd <= 0 then raise exception 'amount must be positive'; end if;

  -- Serialise per company so two concurrent payouts can't both pass the check.
  perform pg_advisory_xact_lock(hashtext('payout-' || p_company_id::text));

  select coalesce(sum(amount_iqd), 0) into bal
  from agency_ledger where company_id = p_company_id;
  -- Pending payouts count as already spoken for.
  bal := bal - coalesce((select sum(amount_iqd) from payouts
                         where company_id = p_company_id and status = 'pending'), 0);
  if p_amount_iqd > bal then
    raise exception 'payout % exceeds available balance %', p_amount_iqd, bal;
  end if;

  insert into payouts (company_id, amount_iqd, method, period_start, period_end)
  values (p_company_id, p_amount_iqd, p_method, p_period_start, p_period_end)
  returning id into pid;
  return pid;
end; $$;

create or replace function complete_payout(p_payout_id uuid, p_reference text)
returns void language plpgsql security definer set search_path = public as $$
declare
  po payouts%rowtype;
begin
  if not is_admin() then raise exception 'admin only'; end if;
  select * into po from payouts where id = p_payout_id for update;
  if po.id is null then raise exception 'payout not found'; end if;
  if po.status = 'completed' then return; end if;      -- idempotent
  if po.status <> 'pending' then raise exception 'payout is %', po.status; end if;

  update payouts
     set status = 'completed', reference = p_reference, completed_at = now()
   where id = po.id;

  perform post_ledger_entry(po.company_id, null, null, po.id,
                            'payout', -po.amount_iqd,
                            'Payout to agency (' || coalesce(p_reference, po.id::text) || ')');
end; $$;

create or replace function fail_payout(p_payout_id uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not is_admin() then raise exception 'admin only'; end if;
  update payouts set status = 'failed'
   where id = p_payout_id and status = 'pending';
end; $$;

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================
alter table payments      enable row level security;
alter table agency_ledger enable row level security;
alter table payouts       enable row level security;

-- payments: client sees own, agency sees their company's, admin sees all.
-- No insert/update/delete policies — every write goes through the functions.
drop policy if exists "read own payments" on payments;
create policy "read own payments" on payments for select
  using (client_id = auth.uid() or owns_company(company_id) or is_admin());

-- agency_ledger: read own rows only. Writes only via functions (definer).
drop policy if exists "agency read own ledger" on agency_ledger;
create policy "agency read own ledger" on agency_ledger for select
  using (owns_company(company_id) or is_admin());

-- payouts: read own, admin manages via functions.
drop policy if exists "agency read own payouts" on payouts;
create policy "agency read own payouts" on payouts for select
  using (owns_company(company_id) or is_admin());
