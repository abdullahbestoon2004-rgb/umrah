-- ============================================================================
-- LEDGER MATH TESTS — run in SQL Editor on a DEV project AFTER
-- patches_payments.sql. Everything runs in one transaction and ROLLS BACK,
-- so no test data survives. Each scenario raises if an expectation fails;
-- if the script reaches the final NOTICE, all tests passed.
--
-- NOTE ON auth CHECKS: the money functions gate on auth.uid()/is_admin().
-- Tests run as the SQL-editor superuser, so we stub is_admin() to true and
-- call the internal apply/true-up path where a client identity would be
-- required. The maths under test is identical.
-- ============================================================================
begin;

-- Test stubs: run "as admin" (rolled back with everything else).
create or replace function is_admin() returns boolean language sql stable as $$ select true $$;

-- ---------------------------------------------------------------------------
-- Fixtures: one owner profile, two agencies (A: 8%, B: 5%), one package each.
-- ---------------------------------------------------------------------------
insert into auth.users (id, email)
values ('99999999-0000-0000-0000-000000000001', 'ledger-test@local')
on conflict (id) do nothing;
insert into profiles (id, role, full_name)
values ('99999999-0000-0000-0000-000000000001', 'agency', 'Ledger Test Owner')
on conflict (id) do nothing;

insert into companies (id, owner_id, name, commission_rate, is_verified, is_active) values
('99999999-aaaa-0000-0000-000000000001','99999999-0000-0000-0000-000000000001','Test Agency A', 0.0800, true, true),
('99999999-bbbb-0000-0000-000000000001','99999999-0000-0000-0000-000000000001','Test Agency B', 0.0500, true, true);

insert into packages (id, company_id, title, price_iqd, days, nights, transport, acc_stars, is_published) values
('99999999-aaaa-1111-0000-000000000001','99999999-aaaa-0000-0000-000000000001','Test Trip A', 1000000, 5, 4, 'plane', 4, true),
('99999999-bbbb-1111-0000-000000000001','99999999-bbbb-0000-0000-000000000001','Test Trip B', 2000000, 5, 4, 'bus',   4, true);

-- Bookings insert normally so the fill_booking_amounts trigger snapshots.
insert into bookings (id, package_id, company_id, client_id, travellers, unit_price_iqd,
                      total_iqd, commission_iqd, payout_iqd, pay_method) values
('99999999-aaaa-2222-0000-000000000001','99999999-aaaa-1111-0000-000000000001',
 '99999999-aaaa-0000-0000-000000000001','99999999-0000-0000-0000-000000000001',
 1, 0, 0, 0, 0, 'fib'),                                       -- online, agency A
('99999999-aaaa-2222-0000-000000000002','99999999-aaaa-1111-0000-000000000001',
 '99999999-aaaa-0000-0000-000000000001','99999999-0000-0000-0000-000000000001',
 1, 0, 0, 0, 0, 'cash'),                                      -- cash, agency A
('99999999-bbbb-2222-0000-000000000001','99999999-bbbb-1111-0000-000000000001',
 '99999999-bbbb-0000-0000-000000000001','99999999-0000-0000-0000-000000000001',
 3, 0, 0, 0, 0, 'fib');                                       -- online ×3, agency B

-- ---------------------------------------------------------------------------
-- T1. Snapshot: rate resolution (agency A = 8%) and derived amounts.
-- ---------------------------------------------------------------------------
do $$
declare b bookings%rowtype;
begin
  select * into b from bookings where id = '99999999-aaaa-2222-0000-000000000001';
  assert b.commission_rate = 0.0800, 'T1: rate should come from the company (8%)';
  assert b.total_iqd = 1000000,      'T1: total snapshot';
  assert b.commission_iqd = 80000,   'T1: commission = 8% of 1,000,000';
  assert b.payout_iqd = 920000,      'T1: agency net';
end $$;

-- ---------------------------------------------------------------------------
-- T2. Online full payment → booking_credit = +payout_iqd, booking 'paid'.
--     Applying the same payment twice must NOT double-post (idempotency).
-- ---------------------------------------------------------------------------
do $$
declare pid uuid; bal bigint; st payment_status;
begin
  insert into payments (booking_id, company_id, client_id, amount_iqd, method, idempotency_key)
  values ('99999999-aaaa-2222-0000-000000000001','99999999-aaaa-0000-0000-000000000001',
          '99999999-0000-0000-0000-000000000001', 1000000, 'fib', 't2-key')
  returning id into pid;

  perform apply_successful_payment(pid, 'FIB-T2');
  perform apply_successful_payment(pid, 'FIB-T2');   -- replayed webhook

  select coalesce(sum(amount_iqd),0) into bal from agency_ledger
   where booking_id = '99999999-aaaa-2222-0000-000000000001';
  assert bal = 920000, format('T2: ledger should be +920,000, got %s', bal);

  select pay_status into st from bookings where id = '99999999-aaaa-2222-0000-000000000001';
  assert st = 'paid', 'T2: booking should be paid';
end $$;

-- ---------------------------------------------------------------------------
-- T3. Cash confirmation → cash_commission_debit = −commission_iqd.
--     Netting: agency A balance = online credit − cash commission.
-- ---------------------------------------------------------------------------
do $$
declare pid uuid; bal bigint;
begin
  pid := confirm_cash_received('99999999-aaaa-2222-0000-000000000002', null);
  pid := confirm_cash_received('99999999-aaaa-2222-0000-000000000002', null); -- double-tap: raises or no-ops? deterministic key → same payment, no-op

  select coalesce(sum(amount_iqd),0) into bal from agency_ledger
   where booking_id = '99999999-aaaa-2222-0000-000000000002';
  assert bal = -80000, format('T3: cash debit should be −80,000, got %s', bal);

  select balance_iqd into bal from agency_balances
   where company_id = '99999999-aaaa-0000-0000-000000000001';
  assert bal = 840000, format('T3: netted balance should be 840,000 (920k − 80k), got %s', bal);
exception when others then
  raise exception 'T3 failed: %', sqlerrm;
end $$;

-- ---------------------------------------------------------------------------
-- T4. Partial payments (agency B, 3 × 2,000,000 = 6,000,000 total, 5%):
--     two deposits of 2,500,000 + 3,500,000. Proportional credits must sum
--     to exactly payout_iqd (5,700,000) with no rounding drift.
-- ---------------------------------------------------------------------------
do $$
declare p1 uuid; p2 uuid; bal bigint; st payment_status;
begin
  insert into payments (booking_id, company_id, client_id, amount_iqd, method, idempotency_key)
  values ('99999999-bbbb-2222-0000-000000000001','99999999-bbbb-0000-0000-000000000001',
          '99999999-0000-0000-0000-000000000001', 2500000, 'fib', 't4-key-1')
  returning id into p1;
  perform apply_successful_payment(p1, 'FIB-T4-1');

  select pay_status into st from bookings where id = '99999999-bbbb-2222-0000-000000000001';
  assert st = 'partially_paid', 'T4: deposit should leave booking partially_paid';

  select coalesce(sum(amount_iqd),0) into bal from agency_ledger
   where booking_id = '99999999-bbbb-2222-0000-000000000001';
  assert bal = round(5700000 * 2500000::numeric / 6000000),
    format('T4: first credit should be proportional, got %s', bal);

  insert into payments (booking_id, company_id, client_id, amount_iqd, method, idempotency_key)
  values ('99999999-bbbb-2222-0000-000000000001','99999999-bbbb-0000-0000-000000000001',
          '99999999-0000-0000-0000-000000000001', 3500000, 'fib', 't4-key-2')
  returning id into p2;
  perform apply_successful_payment(p2, 'FIB-T4-2');

  select coalesce(sum(amount_iqd),0) into bal from agency_ledger
   where booking_id = '99999999-bbbb-2222-0000-000000000001';
  assert bal = 5700000, format('T4: fully paid must ledger exactly payout_iqd, got %s', bal);

  select pay_status into st from bookings where id = '99999999-bbbb-2222-0000-000000000001';
  assert st = 'paid', 'T4: booking should now be paid';
end $$;

-- ---------------------------------------------------------------------------
-- T5. Partial refund (agency B): refund 1,500,000 of 6,000,000 (25% of paid)
--     → reversal restores ledger to 75% of payout, payments marked, booking
--     partially_paid again. Then full cancel → everything reversed to zero.
-- ---------------------------------------------------------------------------
do $$
declare bal bigint; st payment_status; bst booking_status;
begin
  perform refund_booking('99999999-bbbb-2222-0000-000000000001', 1500000);

  select coalesce(sum(amount_iqd),0) into bal from agency_ledger
   where booking_id = '99999999-bbbb-2222-0000-000000000001';
  assert bal = round(5700000 * 4500000::numeric / 6000000),
    format('T5: after 25%% refund ledger should be 75%% of payout, got %s', bal);

  select pay_status into st from bookings where id = '99999999-bbbb-2222-0000-000000000001';
  assert st = 'partially_paid', 'T5: partial refund → partially_paid';

  -- Cancel reverses the rest via the trigger.
  update bookings set status = 'cancelled' where id = '99999999-bbbb-2222-0000-000000000001';

  select coalesce(sum(amount_iqd),0) into bal from agency_ledger
   where booking_id = '99999999-bbbb-2222-0000-000000000001';
  assert bal = 0, format('T5: cancelled booking must net to zero, got %s', bal);

  select pay_status into st from bookings where id = '99999999-bbbb-2222-0000-000000000001';
  assert st = 'refunded', 'T5: cancelled booking → refunded';
end $$;

-- ---------------------------------------------------------------------------
-- T6. Payouts: cannot exceed balance; completing posts the negative entry
--     exactly once (idempotent).
-- ---------------------------------------------------------------------------
do $$
declare pid uuid; bal bigint; failed boolean := false;
begin
  -- Agency A balance is 840,000 (from T2+T3).
  begin
    pid := create_payout('99999999-aaaa-0000-0000-000000000001', 900000);
  exception when others then failed := true;
  end;
  assert failed, 'T6: payout above balance must be rejected';

  pid := create_payout('99999999-aaaa-0000-0000-000000000001', 500000);
  perform complete_payout(pid, 'BANK-REF-1');
  perform complete_payout(pid, 'BANK-REF-1');   -- retry must be a no-op

  select balance_iqd into bal from agency_balances
   where company_id = '99999999-aaaa-0000-0000-000000000001';
  assert bal = 340000, format('T6: balance after payout should be 340,000, got %s', bal);
end $$;

-- ---------------------------------------------------------------------------
-- T7. Ledger is append-only even for privileged code.
-- ---------------------------------------------------------------------------
do $$
declare blocked boolean := false;
begin
  begin
    update agency_ledger set amount_iqd = 1 where amount_iqd <> 1;
  exception when others then blocked := true;
  end;
  assert blocked, 'T7: ledger UPDATE must be impossible';

  blocked := false;
  begin
    delete from agency_ledger;
  exception when others then blocked := true;
  end;
  assert blocked, 'T7: ledger DELETE must be impossible';
end $$;

do $$ begin raise notice '✅ ALL LEDGER TESTS PASSED'; end $$;

rollback;
