-- Three-role workflow tests. Run on a DEV project after patches_workflow.sql.
-- Every fixture and function override is rolled back.
begin;

create or replace function is_admin() returns boolean language sql stable as $$
  select true
$$;

insert into auth.users (id, email)
values ('88888888-0000-0000-0000-000000000001', 'workflow-test@local')
on conflict (id) do nothing;
insert into profiles (id, role, full_name)
values ('88888888-0000-0000-0000-000000000001', 'agency', 'Workflow Owner')
on conflict (id) do nothing;

insert into companies (
  id, owner_id, name, is_verified, is_active, verification_status
) values (
  '88888888-aaaa-0000-0000-000000000001',
  '88888888-0000-0000-0000-000000000001',
  'Workflow Agency', false, true, 'pending'
);

select review_company_application(
  '88888888-aaaa-0000-0000-000000000001', 'approved', null
);

do $$ begin
  assert (select verification_status = 'approved' and is_verified
    from companies where id = '88888888-aaaa-0000-0000-000000000001'),
    'company approval must synchronize the public verification flag';
end $$;

insert into packages (
  id, company_id, title, price_iqd, days, nights, transport, acc_stars,
  capacity, departure_date, return_date, lifecycle_status, is_published
) values (
  '88888888-aaaa-1111-0000-000000000001',
  '88888888-aaaa-0000-0000-000000000001',
  'Workflow Trip', 1000000, 5, 4, 'plane', 4, 3,
  current_date, current_date + 4, 'pending_review', false
);

select review_package(
  '88888888-aaaa-1111-0000-000000000001', 'published', null
);

do $$ begin
  assert (select lifecycle_status = 'published' and is_published
    from packages where id = '88888888-aaaa-1111-0000-000000000001'),
    'package publication must synchronize is_published';
end $$;

insert into bookings (
  id, package_id, company_id, client_id, travellers, unit_price_iqd,
  total_iqd, commission_iqd, payout_iqd, pay_method
) values (
  '88888888-aaaa-2222-0000-000000000001',
  '88888888-aaaa-1111-0000-000000000001',
  '88888888-aaaa-0000-0000-000000000001',
  '88888888-0000-0000-0000-000000000001',
  2, 0, 0, 0, 0, 'cash'
);

do $$ begin
  assert (select operational_stage = 'requested' and room_occupancy = 2
    from bookings
    where id = '88888888-aaaa-2222-0000-000000000001'),
    'new booking must start requested with a valid configured room';
  assert (select seats_reserved = 2 from packages
    where id = '88888888-aaaa-1111-0000-000000000001'),
    'booking must reserve seats atomically';
end $$;

select transition_booking(
  '88888888-aaaa-2222-0000-000000000001', 'accept', null
);
update bookings set pay_status = 'paid'
where id = '88888888-aaaa-2222-0000-000000000001';

do $$ begin
  assert (select operational_stage = 'confirmed' and status = 'confirmed'
    from bookings where id = '88888888-aaaa-2222-0000-000000000001'),
    'paid accepted booking must become confirmed';
end $$;

select transition_booking('88888888-aaaa-2222-0000-000000000001', 'ready', null);
select transition_booking('88888888-aaaa-2222-0000-000000000001', 'start', null);
select transition_booking('88888888-aaaa-2222-0000-000000000001', 'complete', null);

do $$ begin
  assert (select operational_stage = 'completed' and status = 'completed'
    from bookings where id = '88888888-aaaa-2222-0000-000000000001'),
    'fulfilment stages must end completed';
  assert (select count(*) >= 5 from audit_logs
    where entity_id = '88888888-aaaa-2222-0000-000000000001'),
    'booking transitions must be audited';
end $$;

insert into support_messages (id, user_id, email, message)
values (
  '88888888-aaaa-3333-0000-000000000001',
  '88888888-0000-0000-0000-000000000001',
  'workflow-test@local', 'Please help'
);
select resolve_support_message(
  '88888888-aaaa-3333-0000-000000000001', 'Resolved in test'
);

do $$ begin
  assert (select status = 'resolved' and resolved_at is not null
    from support_messages where id = '88888888-aaaa-3333-0000-000000000001'),
    'support messages must be resolved, not deleted';
end $$;

do $$ begin
  raise notice 'ALL WORKFLOW TESTS PASSED';
end $$;

rollback;
