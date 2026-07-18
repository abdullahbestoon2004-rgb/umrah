-- One client may have only one active booking. The advisory lock serializes
-- concurrent RPC calls; the partial unique index also protects other writers.
create unique index if not exists bookings_one_active_per_client_uidx
  on public.bookings(client_id)
  where operational_stage in
    ('requested','needs_information','awaiting_payment','confirmed','ready','in_progress')
    and refund_status <> 'refunded';

create or replace function public.create_booking_request(
  p_package_id uuid,
  p_travellers int,
  p_pay_method text,
  p_room_occupancy int,
  p_contact_phone text default null,
  p_note text default null,
  p_pilgrims jsonb default '[]'::jsonb,
  p_request_key text default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare booking_id uuid;
declare pilgrim jsonb;
declare pilgrim_count int;
declare lead_count int;
declare caller_role text;
declare existing_booking_id uuid;
begin
  if auth.uid() is null then raise exception 'sign-in required'; end if;
  select role::text into caller_role
  from public.profiles where id = auth.uid();
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

  perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text, 0));

  if nullif(btrim(p_request_key), '') is not null then
    select id into existing_booking_id from public.bookings
    where client_id = auth.uid() and request_key = btrim(p_request_key);
    if existing_booking_id is not null then return existing_booking_id; end if;
  end if;

  select id into existing_booking_id
  from public.bookings
  where client_id = auth.uid()
    and operational_stage in
      ('requested','needs_information','awaiting_payment','confirmed','ready','in_progress')
    and refund_status <> 'refunded'
  limit 1;
  if existing_booking_id is not null then
    raise exception 'You already have an active Umrah booking. You must complete or cancel your current booking before booking another trip.';
  end if;

  insert into public.bookings(
    package_id, company_id, client_id, travellers, unit_price_iqd, total_iqd,
    commission_iqd, payout_iqd, pay_method, contact_phone, note,
    room_occupancy, request_key
  ) values (
    p_package_id, (select company_id from public.packages where id = p_package_id),
    auth.uid(), p_travellers, 0, 0, 0, 0, p_pay_method::public.payment_method,
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
    insert into public.booking_travellers(
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

revoke execute on function public.create_booking_request(uuid,int,text,int,text,text,jsonb,text)
  from public, anon;
grant execute on function public.create_booking_request(uuid,int,text,int,text,text,jsonb,text)
  to authenticated;
