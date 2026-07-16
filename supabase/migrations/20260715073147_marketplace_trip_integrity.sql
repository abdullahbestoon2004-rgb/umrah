-- Marketplace trip integrity: authoritative quotes, atomic booking creation,
-- offer versioning, expiry, and per-hotel descriptions.

-- ---------------------------------------------------------------------------
-- 1. Structured offer content and immutable booking snapshots
-- ---------------------------------------------------------------------------
alter table hotels add column if not exists description text;
alter table hotels add column if not exists description_ar text;
alter table hotels add column if not exists description_en text;

alter table packages add column if not exists content_version int not null default 1;
alter table packages add column if not exists updated_at timestamptz not null default now();

alter table bookings add column if not exists room_count int not null default 1;
alter table bookings add column if not exists amount_due_now_iqd bigint not null default 0;
alter table bookings add column if not exists quote_version int not null default 1;
alter table bookings add column if not exists quote_snapshot jsonb not null default '{}'::jsonb;
alter table bookings add column if not exists cancellation_policy_snapshot text;
alter table bookings add column if not exists deposit_iqd_snapshot bigint not null default 0;
alter table bookings add column if not exists non_refundable_deposit_snapshot boolean not null default false;
alter table bookings add column if not exists refund_due_iqd bigint not null default 0;
alter table bookings add column if not exists refund_status text not null default 'none';
alter table bookings add column if not exists request_key text;

update bookings set
  room_count = greatest(
    1,
    ceil(travellers::numeric / greatest(coalesce(room_occupancy, 2), 1))::int
  ),
  amount_due_now_iqd = total_iqd,
  quote_version = 1,
  quote_snapshot = jsonb_build_object(
    'version', 1,
    'unit_price_iqd', unit_price_iqd,
    'travellers', travellers,
    'total_iqd', total_iqd,
    'legacy_snapshot', true
  )
where amount_due_now_iqd = 0;

do $$ begin
  alter table bookings add constraint bookings_room_count_check check (room_count > 0);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table bookings add constraint bookings_due_now_check
    check (amount_due_now_iqd >= 0 and amount_due_now_iqd <= total_iqd);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table bookings add constraint bookings_refund_due_check check (refund_due_iqd >= 0);
exception when duplicate_object then null; end $$;
do $$ begin
  alter table bookings add constraint bookings_refund_status_check
    check (refund_status in ('none','pending','processing','refunded','rejected'));
exception when duplicate_object then null; end $$;
do $$ begin
  alter table bookings add constraint bookings_request_key_length_check
    check (request_key is null or length(request_key) between 8 and 120);
exception when duplicate_object then null; end $$;

create index if not exists bookings_expiry_active_idx
  on bookings(expires_at, package_id)
  where operational_stage in ('requested','needs_information','awaiting_payment');
create unique index if not exists bookings_client_request_key_uidx
  on bookings(client_id, request_key) where request_key is not null;

-- Owners must be able to see their drafts and review states. Public readers
-- still see only live, approved offers.
drop policy if exists "read visible offers" on packages;
create policy "read visible offers" on packages for select
to anon, authenticated using (
  (
    lifecycle_status = 'published'
    and is_published
    and departure_date >= current_date
    and exists (
      select 1 from companies c
      where c.id = packages.company_id
        and c.status = 'active' and c.is_active and c.is_verified
    )
  )
  or owns_company(company_id)
  or is_admin()
);

-- ---------------------------------------------------------------------------
-- 2. Helpers used by both the quote endpoint and booking trigger
-- ---------------------------------------------------------------------------
create or replace function occupancy_type_for(p_occupancy int)
returns text language sql immutable parallel safe as $$
  select case p_occupancy
    when 2 then 'double'
    when 3 then 'triple'
    when 4 then 'quad'
    when 5 then 'quintuple'
    else null
  end;
$$;
revoke execute on function occupancy_type_for(int) from public, anon, authenticated;

create or replace function quote_offer(
  p_offer_id uuid,
  p_travellers int,
  p_room_occupancy int
) returns jsonb
language plpgsql security definer set search_path = public as $$
declare
  p packages%rowtype;
  unit_price bigint;
  total_price bigint;
  due_now bigint;
  rooms int;
begin
  if p_travellers < 1 or p_travellers > 50 then
    raise exception 'traveller count must be between 1 and 50';
  end if;

  select * into p from packages where id = p_offer_id;
  if p.id is null or not can_read_offer(p.id) then
    raise exception 'offer is not available';
  end if;
  if p.lifecycle_status <> 'published' or not p.is_published
     or p.departure_date is null or p.departure_date < current_date then
    raise exception 'offer is not available';
  end if;
  if p.capacity is not null and p.seats_reserved + p_travellers > p.capacity then
    raise exception 'not enough seats';
  end if;
  if p_room_occupancy is null
     or not (p_room_occupancy = any(p.room_occupancies)) then
    raise exception 'selected room type is not available';
  end if;
  if not (p.accepted_payment_methods && array['fib','cash']) then
    raise exception 'offer has no supported payment method';
  end if;

  select op.price_iqd into unit_price
  from offer_pricing op
  where op.offer_id = p.id
    and op.occupancy_type = occupancy_type_for(p_room_occupancy);
  if unit_price is null then
    raise exception 'selected room price is not configured';
  end if;

  total_price := unit_price * p_travellers;
  rooms := ceil(p_travellers::numeric / p_room_occupancy)::int;
  due_now := case
    when p.deposit_iqd > 0 then least(total_price, p.deposit_iqd * p_travellers)
    else total_price
  end;

  return jsonb_build_object(
    'offer_id', p.id,
    'version', p.content_version,
    'travellers', p_travellers,
    'room_occupancy', p_room_occupancy,
    'room_count', rooms,
    'unit_price_iqd', unit_price,
    'total_iqd', total_price,
    'amount_due_now_iqd', due_now,
    'currency', 'IQD',
    'departure_date', p.departure_date,
    'return_date', p.return_date,
    'meal', p.meals,
    'deposit_iqd_per_person', p.deposit_iqd,
    'non_refundable_deposit', p.non_refundable_deposit,
    'cancellation_policy', p.cancellation_policy,
    'accepted_payment_methods', p.accepted_payment_methods,
    'expires_in_minutes', 30
  );
end;
$$;
revoke execute on function quote_offer(uuid,int,int) from public;
grant execute on function quote_offer(uuid,int,int) to anon, authenticated;

-- The server, never the device, selects the occupancy price and snapshots all
-- commercial terms used for this booking.
create or replace function fill_booking_amounts()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  p packages%rowtype;
  c companies%rowtype;
  selected_price bigint;
begin
  select * into p from packages where id = new.package_id;
  if p.id is null then raise exception 'package not found'; end if;
  select * into c from companies where id = p.company_id;

  select price_iqd into selected_price
  from offer_pricing
  where offer_id = p.id
    and occupancy_type = occupancy_type_for(new.room_occupancy);
  if selected_price is null then
    raise exception 'selected room price is not configured';
  end if;

  new.company_id := p.company_id;
  new.unit_price_iqd := selected_price;
  new.total_iqd := selected_price * new.travellers;
  new.room_count := ceil(new.travellers::numeric / new.room_occupancy)::int;
  new.commission_rate := resolve_commission_rate(new.package_id);
  new.commission_iqd := round(new.total_iqd * new.commission_rate);
  new.payout_iqd := new.total_iqd - new.commission_iqd;
  new.amount_paid_iqd := 0;
  new.amount_due_now_iqd := case
    when p.deposit_iqd > 0 then least(new.total_iqd, p.deposit_iqd * new.travellers)
    else new.total_iqd
  end;
  new.quote_version := p.content_version;
  new.cancellation_policy_snapshot := p.cancellation_policy;
  new.deposit_iqd_snapshot := p.deposit_iqd;
  new.non_refundable_deposit_snapshot := p.non_refundable_deposit;
  new.quote_snapshot := jsonb_build_object(
    'version', p.content_version,
    'offer_title', p.title,
    'offer_title_ar', p.title_ar,
    'offer_title_en', p.title_en,
    'company_name', c.name,
    'company_name_ar', c.name_ar,
    'company_name_en', c.name_en,
    'unit_price_iqd', selected_price,
    'travellers', new.travellers,
    'room_occupancy', new.room_occupancy,
    'room_count', new.room_count,
    'total_iqd', new.total_iqd,
    'amount_due_now_iqd', new.amount_due_now_iqd,
    'departure_date', p.departure_date,
    'return_date', p.return_date,
    'meal', p.meals,
    'accepted_payment_methods', p.accepted_payment_methods,
    'hotels', coalesce((
      select jsonb_agg(jsonb_build_object(
        'city', oh.city,
        'name', h.name,
        'name_ar', h.name_ar,
        'name_en', h.name_en,
        'description', h.description,
        'description_ar', h.description_ar,
        'description_en', h.description_en,
        'nights', oh.nights,
        'distance_from_haram_m', oh.distance_from_haram_m,
        'star_rating', h.star_rating
      ) order by oh.city)
      from offer_hotels oh join hotels h on h.id = oh.hotel_id
      where oh.offer_id = p.id
    ), '[]'::jsonb)
  );
  return new;
end;
$$;

create or replace function validate_new_booking()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  p packages%rowtype;
  company_ok boolean;
begin
  select * into p from packages where id = new.package_id for update;
  if p.id is null or p.lifecycle_status <> 'published' or not p.is_published then
    raise exception 'package is not available';
  end if;
  select status = 'active' and is_active and is_verified into company_ok
  from companies where id = p.company_id;
  if not coalesce(company_ok, false) then raise exception 'company is not available'; end if;
  if p.departure_date is null or p.departure_date < current_date then
    raise exception 'package departure is not available';
  end if;
  if new.departure_date is not null and new.departure_date <> p.departure_date then
    raise exception 'selected departure does not belong to this package';
  end if;
  if p.capacity is not null and p.seats_reserved + new.travellers > p.capacity then
    raise exception 'not enough seats';
  end if;
  if new.room_occupancy is null or not (new.room_occupancy = any(p.room_occupancies)) then
    raise exception 'selected room type is not available';
  end if;
  if occupancy_type_for(new.room_occupancy) is null then
    raise exception 'unsupported room occupancy';
  end if;
  if not (new.pay_method::text = any(p.accepted_payment_methods)) then
    raise exception 'selected payment method is not accepted';
  end if;
  if new.pay_method::text = 'card' then
    raise exception 'card payments are not available yet';
  end if;
  if nullif(p.meals, '') is not null
     and new.meal_preference is not null
     and new.meal_preference <> p.meals then
    raise exception 'selected meal does not belong to this package';
  end if;

  new.operational_stage := 'requested';
  new.status := 'pending';
  new.departure_date := p.departure_date;
  new.meal_preference := case
    when p.meals in ('Breakfast','Half board','Full board') then p.meals
    else null
  end;
  new.expires_at := now() + interval '24 hours';
  update packages set seats_reserved = seats_reserved + new.travellers where id = p.id;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Atomic booking request (booking + all travellers)
-- ---------------------------------------------------------------------------
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
declare
  booking_id uuid;
  pilgrim jsonb;
  pilgrim_count int;
  lead_count int;
  caller_role text;
  existing_booking_id uuid;
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
  if lead_count <> 1 then
    raise exception 'exactly one lead traveller is required';
  end if;

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
      raise exception 'each traveller needs a name and date of birth';
    end if;
    if (pilgrim->>'date_of_birth')::date > current_date then
      raise exception 'traveller date of birth cannot be in the future';
    end if;
    insert into booking_travellers(
      booking_id, client_id, full_name, passport_no, date_of_birth, phone, is_lead
    ) values (
      booking_id, auth.uid(), btrim(pilgrim->>'full_name'),
      nullif(btrim(pilgrim->>'passport_no'), ''),
      (pilgrim->>'date_of_birth')::date,
      nullif(btrim(pilgrim->>'phone'), ''),
      coalesce((pilgrim->>'is_lead')::boolean, false)
    );
  end loop;
  return booking_id;
end;
$$;
revoke execute on function create_booking_request(uuid,int,text,int,text,text,jsonb,text)
  from public, anon;
grant execute on function create_booking_request(uuid,int,text,int,text,text,jsonb,text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 4. Transactional child-detail replacement and publish completeness
-- ---------------------------------------------------------------------------
create or replace function save_offer_details(
  p_offer_id uuid,
  p_itinerary jsonb,
  p_pricing jsonb,
  p_hotels jsonb,
  p_inclusions jsonb
) returns void
language plpgsql security definer set search_path = public as $$
declare
  p packages%rowtype;
  item jsonb;
  city_value text;
  hotel_id_value uuid;
  keep_cities text[] := '{}';
begin
  select * into p from packages where id = p_offer_id for update;
  if p.id is null or not (owns_company(p.company_id) or is_admin()) then
    raise exception 'not your package';
  end if;
  if jsonb_typeof(coalesce(p_itinerary, '[]')) <> 'array'
     or jsonb_typeof(coalesce(p_pricing, '[]')) <> 'array'
     or jsonb_typeof(coalesce(p_hotels, '[]')) <> 'array'
     or jsonb_typeof(coalesce(p_inclusions, '[]')) <> 'array' then
    raise exception 'offer details must be arrays';
  end if;

  delete from itinerary_days where package_id = p_offer_id;
  for item in select value from jsonb_array_elements(coalesce(p_itinerary, '[]')) loop
    insert into itinerary_days(package_id, day_no, title, summary)
    values (
      p_offer_id, coalesce((item->>'day_no')::int, 1),
      btrim(item->>'title'), nullif(btrim(item->>'summary'), '')
    );
  end loop;

  delete from offer_pricing where offer_id = p_offer_id;
  for item in select value from jsonb_array_elements(coalesce(p_pricing, '[]')) loop
    insert into offer_pricing(offer_id, occupancy_type, price_iqd, price_usd)
    values (
      p_offer_id, item->>'occupancy_type', (item->>'price_iqd')::bigint,
      nullif(item->>'price_usd', '')::numeric
    );
  end loop;

  delete from offer_inclusions where offer_id = p_offer_id;
  for item in select value from jsonb_array_elements(coalesce(p_inclusions, '[]')) loop
    insert into offer_inclusions(
      offer_id, type, included, details, details_ar, details_en, sort_order
    ) values (
      p_offer_id, item->>'type', coalesce((item->>'included')::boolean, false),
      nullif(btrim(item->>'details'), ''), nullif(btrim(item->>'details_ar'), ''),
      nullif(btrim(item->>'details_en'), ''), coalesce((item->>'sort_order')::int, 0)
    );
  end loop;

  for item in select value from jsonb_array_elements(coalesce(p_hotels, '[]')) loop
    city_value := item->>'city';
    if city_value not in ('makkah','madinah') then raise exception 'invalid hotel city'; end if;
    if city_value = any(keep_cities) then raise exception 'only one hotel per city is allowed'; end if;
    keep_cities := array_append(keep_cities, city_value);

    select hotel_id into hotel_id_value from offer_hotels
    where offer_id = p_offer_id and city = city_value;
    if hotel_id_value is null then
      insert into hotels(
        name, name_ar, name_en, description, description_ar, description_en,
        city, star_rating, photo_urls, created_by
      ) values (
        btrim(item->>'name'), nullif(btrim(item->>'name_ar'), ''),
        nullif(btrim(item->>'name_en'), ''), nullif(btrim(item->>'description'), ''),
        nullif(btrim(item->>'description_ar'), ''),
        nullif(btrim(item->>'description_en'), ''), city_value,
        (item->>'star_rating')::int,
        coalesce(array(select jsonb_array_elements_text(item->'photo_urls')), '{}'),
        auth.uid()
      ) returning id into hotel_id_value;
    else
      update hotels set
        name = btrim(item->>'name'),
        name_ar = nullif(btrim(item->>'name_ar'), ''),
        name_en = nullif(btrim(item->>'name_en'), ''),
        description = nullif(btrim(item->>'description'), ''),
        description_ar = nullif(btrim(item->>'description_ar'), ''),
        description_en = nullif(btrim(item->>'description_en'), ''),
        star_rating = (item->>'star_rating')::int,
        photo_urls = coalesce(array(select jsonb_array_elements_text(item->'photo_urls')), '{}')
      where id = hotel_id_value;
    end if;
    insert into offer_hotels(offer_id, hotel_id, city, nights, distance_from_haram_m)
    values (
      p_offer_id, hotel_id_value, city_value, (item->>'nights')::int,
      (item->>'distance_from_haram_m')::int
    ) on conflict (offer_id, city) do update set
      hotel_id = excluded.hotel_id, nights = excluded.nights,
      distance_from_haram_m = excluded.distance_from_haram_m;
  end loop;
  delete from offer_hotels
  where offer_id = p_offer_id and not (city = any(keep_cities));

  update packages set
    price_iqd = coalesce(
      (select min(price_iqd) from offer_pricing where offer_id = p_offer_id),
      price_iqd
    ),
    content_version = content_version + 1,
    updated_at = now(),
    lifecycle_status = case when lifecycle_status = 'published' then 'pending_review' else lifecycle_status end,
    is_published = case when lifecycle_status = 'published' then false else is_published end
  where id = p_offer_id;
end;
$$;
revoke execute on function save_offer_details(uuid,jsonb,jsonb,jsonb,jsonb)
  from public, anon;
grant execute on function save_offer_details(uuid,jsonb,jsonb,jsonb,jsonb)
  to authenticated;

-- Package row and all child tables are committed or rolled back together.
create or replace function create_offer_draft(
  p_fields jsonb,
  p_itinerary jsonb,
  p_pricing jsonb,
  p_hotels jsonb,
  p_inclusions jsonb
) returns uuid
language plpgsql security definer set search_path = public as $$
declare supplied packages%rowtype;
declare offer_id_value uuid;
begin
  supplied := jsonb_populate_record(null::packages, p_fields);
  if supplied.company_id is null or not owns_company(supplied.company_id) then
    raise exception 'not your company';
  end if;
  insert into packages(
    company_id, title, title_ar, title_en, overview, overview_ar, overview_en,
    price_iqd, original_iqd, days, nights, transport, carrier, transfer_note,
    acc_stars, hotel, distance_haram, room, meals, includes, badge, image_url,
    capacity, departure_date, return_date, hotel_makkah_description,
    hotel_madinah_description, room_occupancies, package_tier, group_type,
    season_tag, departure_airport, airline_name, airline_logo_url, flight_type,
    bus_between_cities, airport_transfers, transport_notes, meals_per_day,
    video_url, cancellation_policy, cancellation_policy_ar,
    cancellation_policy_en, deposit_iqd, non_refundable_deposit, deposit_terms,
    deposit_terms_ar, deposit_terms_en, accepted_payment_methods
  ) values (
    supplied.company_id, supplied.title, supplied.title_ar, supplied.title_en,
    supplied.overview, supplied.overview_ar, supplied.overview_en,
    supplied.price_iqd, supplied.original_iqd, supplied.days, supplied.nights,
    supplied.transport, supplied.carrier, supplied.transfer_note,
    supplied.acc_stars, supplied.hotel, supplied.distance_haram, supplied.room,
    supplied.meals, supplied.includes, supplied.badge, supplied.image_url,
    supplied.capacity, supplied.departure_date, supplied.return_date,
    supplied.hotel_makkah_description, supplied.hotel_madinah_description,
    supplied.room_occupancies, supplied.package_tier, supplied.group_type,
    supplied.season_tag, supplied.departure_airport, supplied.airline_name,
    supplied.airline_logo_url, supplied.flight_type,
    coalesce(supplied.bus_between_cities, false),
    coalesce(supplied.airport_transfers, false), supplied.transport_notes,
    supplied.meals_per_day, supplied.video_url, supplied.cancellation_policy,
    supplied.cancellation_policy_ar, supplied.cancellation_policy_en,
    coalesce(supplied.deposit_iqd, 0),
    coalesce(supplied.non_refundable_deposit, false), supplied.deposit_terms,
    supplied.deposit_terms_ar, supplied.deposit_terms_en,
    coalesce(supplied.accepted_payment_methods, array['cash'])
  ) returning id into offer_id_value;
  perform save_offer_details(
    offer_id_value, p_itinerary, p_pricing, p_hotels, p_inclusions
  );
  return offer_id_value;
end;
$$;

create or replace function update_offer_bundle(
  p_offer_id uuid,
  p_fields jsonb,
  p_itinerary jsonb,
  p_pricing jsonb,
  p_hotels jsonb,
  p_inclusions jsonb
) returns void
language plpgsql security definer set search_path = public as $$
declare current_row packages%rowtype;
declare supplied packages%rowtype;
begin
  select * into current_row from packages where id = p_offer_id for update;
  if current_row.id is null
     or not (owns_company(current_row.company_id) or is_admin()) then
    raise exception 'not your package';
  end if;
  supplied := jsonb_populate_record(current_row, p_fields);
  if supplied.company_id <> current_row.company_id then
    raise exception 'package company cannot be changed';
  end if;
  update packages set
    title = supplied.title, title_ar = supplied.title_ar,
    title_en = supplied.title_en, overview = supplied.overview,
    overview_ar = supplied.overview_ar, overview_en = supplied.overview_en,
    price_iqd = supplied.price_iqd, original_iqd = supplied.original_iqd,
    days = supplied.days, nights = supplied.nights, transport = supplied.transport,
    carrier = supplied.carrier, transfer_note = supplied.transfer_note,
    acc_stars = supplied.acc_stars, hotel = supplied.hotel,
    distance_haram = supplied.distance_haram, room = supplied.room,
    meals = supplied.meals, includes = supplied.includes, badge = supplied.badge,
    capacity = supplied.capacity, departure_date = supplied.departure_date,
    return_date = supplied.return_date,
    hotel_makkah_description = supplied.hotel_makkah_description,
    hotel_madinah_description = supplied.hotel_madinah_description,
    room_occupancies = supplied.room_occupancies,
    package_tier = supplied.package_tier, group_type = supplied.group_type,
    season_tag = supplied.season_tag,
    departure_airport = supplied.departure_airport,
    airline_name = supplied.airline_name,
    airline_logo_url = supplied.airline_logo_url,
    flight_type = supplied.flight_type,
    bus_between_cities = supplied.bus_between_cities,
    airport_transfers = supplied.airport_transfers,
    transport_notes = supplied.transport_notes, meals_per_day = supplied.meals_per_day,
    video_url = supplied.video_url,
    cancellation_policy = supplied.cancellation_policy,
    cancellation_policy_ar = supplied.cancellation_policy_ar,
    cancellation_policy_en = supplied.cancellation_policy_en,
    deposit_iqd = supplied.deposit_iqd,
    non_refundable_deposit = supplied.non_refundable_deposit,
    deposit_terms = supplied.deposit_terms,
    deposit_terms_ar = supplied.deposit_terms_ar,
    deposit_terms_en = supplied.deposit_terms_en,
    accepted_payment_methods = supplied.accepted_payment_methods
  where id = p_offer_id;
  perform save_offer_details(p_offer_id, p_itinerary, p_pricing, p_hotels, p_inclusions);
end;
$$;

revoke execute on function create_offer_draft(jsonb,jsonb,jsonb,jsonb,jsonb)
  from public, anon;
grant execute on function create_offer_draft(jsonb,jsonb,jsonb,jsonb,jsonb)
  to authenticated;
revoke execute on function update_offer_bundle(uuid,jsonb,jsonb,jsonb,jsonb,jsonb)
  from public, anon;
grant execute on function update_offer_bundle(uuid,jsonb,jsonb,jsonb,jsonb,jsonb)
  to authenticated;

create or replace function protect_published_offer_edits()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  new.updated_at := now();
  new.content_version := old.content_version + 1;
  if old.lifecycle_status = 'published' and owns_company(old.company_id) and not is_admin() then
    new.lifecycle_status := 'pending_review';
    new.is_published := false;
    new.review_reason := 'Commercial details changed; review required';
    new.submitted_at := now();
  end if;
  return new;
end;
$$;
drop trigger if exists before_protect_published_offer_edits on packages;
create trigger before_protect_published_offer_edits
before update of title, title_ar, title_en, overview, overview_ar, overview_en,
  price_iqd, original_iqd, days, nights, transport, carrier, acc_stars, hotel,
  distance_haram, room, meals, includes, image_url, video_url, capacity,
  departure_date, return_date,
  room_occupancies, package_tier, group_type, season_tag, departure_airport,
  airline_name, flight_type, bus_between_cities, airport_transfers,
  transport_notes, meals_per_day, cancellation_policy, deposit_iqd,
  non_refundable_deposit, deposit_terms, accepted_payment_methods
on packages for each row execute function protect_published_offer_edits();

create or replace function assert_offer_complete(p_offer_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare p packages%rowtype;
declare hotel_count int;
declare pricing_count int;
begin
  select * into p from packages where id = p_offer_id;
  if p.id is null then raise exception 'package not found'; end if;
  if nullif(btrim(p.title), '') is null or nullif(btrim(p.overview), '') is null then
    raise exception 'title and overview are required';
  end if;
  if p.price_iqd <= 0 or p.capacity is null or p.capacity <= 0 then
    raise exception 'price and capacity are required';
  end if;
  if p.departure_date is null or p.return_date is null
     or p.departure_date < current_date or p.return_date < p.departure_date then
    raise exception 'valid future departure and return dates are required';
  end if;
  if coalesce(cardinality(p.accepted_payment_methods), 0) = 0
     or not (p.accepted_payment_methods <@ array['fib','cash']) then
    raise exception 'select at least one supported payment method';
  end if;
  if nullif(btrim(p.cancellation_policy), '') is null then
    raise exception 'cancellation policy is required';
  end if;
  if not exists(select 1 from itinerary_days where package_id = p.id) then
    raise exception 'itinerary is required';
  end if;
  if not exists(select 1 from offer_inclusions where offer_id = p.id and included) then
    raise exception 'at least one inclusion is required';
  end if;
  select count(*) into hotel_count
  from offer_hotels oh join hotels h on h.id = oh.hotel_id
  where oh.offer_id = p.id and oh.city in ('makkah','madinah')
    and nullif(btrim(h.name), '') is not null
    and nullif(btrim(h.description), '') is not null;
  if hotel_count <> 2 then
    raise exception 'Makkah and Madinah hotels each need a name and description';
  end if;
  if (select coalesce(sum(nights), 0) from offer_hotels where offer_id = p.id)
     <> p.nights then
    raise exception 'hotel nights must equal package nights';
  end if;
  select count(*) into pricing_count from offer_pricing
  where offer_id = p.id
    and occupancy_type = any(array(
      select occupancy_type_for(value) from unnest(p.room_occupancies) value
    ));
  if pricing_count <> cardinality(p.room_occupancies) then
    raise exception 'every room occupancy needs a price';
  end if;
end;
$$;
revoke execute on function assert_offer_complete(uuid) from public, anon, authenticated;

create or replace function protect_package_publication()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.lifecycle_status = 'published' and new.is_published
     and (old.lifecycle_status is distinct from 'published'
          or old.is_published is distinct from true) then
    perform assert_offer_complete(new.id);
  end if;
  return new;
end;
$$;
drop trigger if exists before_protect_package_publication on packages;
create trigger before_protect_package_publication
before update of lifecycle_status, is_published on packages
for each row execute function protect_package_publication();

create or replace function protect_package_delete()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if is_admin() then return old; end if;
  if not owns_company(old.company_id) then raise exception 'not your package'; end if;
  if old.lifecycle_status not in ('draft','needs_changes','rejected') then
    raise exception 'only draft or rejected packages can be deleted';
  end if;
  if exists(select 1 from bookings where package_id = old.id) then
    raise exception 'packages with bookings cannot be deleted';
  end if;
  return old;
end;
$$;
drop trigger if exists before_protect_package_delete on packages;
create trigger before_protect_package_delete
before delete on packages for each row execute function protect_package_delete();

create or replace function pause_package(p_package_id uuid, p_reason text default null)
returns void language plpgsql security definer set search_path = public as $$
declare p packages%rowtype;
begin
  select * into p from packages where id = p_package_id for update;
  if p.id is null or not (owns_company(p.company_id) or is_admin()) then
    raise exception 'not your package';
  end if;
  if p.lifecycle_status not in ('published','sold_out') then
    raise exception 'package cannot be paused from %', p.lifecycle_status;
  end if;
  update packages set lifecycle_status = 'paused', is_published = false,
    review_reason = nullif(btrim(p_reason), '') where id = p.id;
  perform write_audit('package', p.id, 'paused',
    jsonb_build_object('status', p.lifecycle_status),
    jsonb_build_object('status', 'paused'), p_reason);
end;
$$;
revoke execute on function pause_package(uuid,text) from public, anon;
grant execute on function pause_package(uuid,text) to authenticated;

-- Every submission is reviewed. Editing a published offer never silently
-- changes the commercial terms already shown to clients.
create or replace function submit_package(p_package_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare p packages%rowtype;
declare company_ok boolean;
begin
  select * into p from packages where id = p_package_id for update;
  if p.id is null or not owns_company(p.company_id) then raise exception 'not your package'; end if;
  select status = 'active' and is_active and is_verified into company_ok
  from companies where id = p.company_id;
  if not coalesce(company_ok, false) then raise exception 'company is not active'; end if;
  if p.lifecycle_status not in ('draft','needs_changes','rejected','paused','pending_review') then
    raise exception 'package cannot be submitted from %', p.lifecycle_status;
  end if;
  perform assert_offer_complete(p.id);
  update packages set lifecycle_status = 'pending_review', is_published = false,
    review_reason = null, submitted_at = now() where id = p.id;
  perform write_audit('package', p.id, 'submitted',
    jsonb_build_object('status', p.lifecycle_status),
    jsonb_build_object('status', 'pending_review', 'version', p.content_version), null);
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. Expiry, transitions and refunds
-- Lock order is always package -> booking to avoid deadlocks.
-- ---------------------------------------------------------------------------
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
    if not (owns_company(b.company_id) or is_admin()) or b.operational_stage <> 'requested' then
      raise exception 'booking cannot be accepted';
    end if;
    next_stage := case when b.amount_paid_iqd >= b.amount_due_now_iqd then 'confirmed' else 'awaiting_payment' end;
    next_legacy := case when next_stage = 'confirmed' then 'confirmed' else 'pending' end;
  elsif p_action = 'request_information' then
    if not (owns_company(b.company_id) or is_admin())
       or b.operational_stage not in ('requested','needs_information') then
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
       or b.operational_stage not in ('requested','needs_information','awaiting_payment','confirmed','ready') then
      raise exception 'booking cannot be cancelled';
    end if;
    if nullif(btrim(p_reason), '') is null then raise exception 'a cancellation reason is required'; end if;
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
end;
$$;

create or replace function confirm_booking_after_payment()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.amount_paid_iqd >= new.amount_due_now_iqd
     and old.amount_paid_iqd < old.amount_due_now_iqd
     and new.operational_stage = 'awaiting_payment' then
    update bookings set operational_stage = 'confirmed', status = 'confirmed',
      expires_at = null
    where id = new.id;
  end if;
  return new;
end;
$$;
drop trigger if exists after_booking_paid_confirm on bookings;
create trigger after_booking_paid_confirm
after update of amount_paid_iqd on bookings
for each row execute function confirm_booking_after_payment();

create or replace function validate_payment_not_expired()
returns trigger language plpgsql security definer set search_path = public as $$
declare b bookings%rowtype;
begin
  select * into b from bookings where id = new.booking_id;
  if b.id is null then raise exception 'booking not found'; end if;
  if b.operational_stage in ('requested','needs_information','awaiting_payment')
     and b.expires_at is not null and b.expires_at <= now() then
    raise exception 'booking payment window has expired';
  end if;
  if b.operational_stage not in ('awaiting_payment','confirmed') then
    raise exception 'booking is not payable';
  end if;
  return new;
end;
$$;
drop trigger if exists before_validate_payment_not_expired on payments;
create trigger before_validate_payment_not_expired
before insert on payments for each row execute function validate_payment_not_expired();

-- A cancellation creates a refund obligation; it does not falsely mark an
-- external FIB/card refund as complete before the provider confirms it.
create or replace function on_booking_cancelled()
returns trigger language plpgsql security definer set search_path = public as $$
declare withheld bigint := 0;
begin
  if new.status = 'cancelled' and old.status is distinct from 'cancelled'
     and new.amount_paid_iqd > 0 then
    if new.cancelled_by = new.client_id and new.non_refundable_deposit_snapshot then
      withheld := least(new.amount_paid_iqd,
        new.deposit_iqd_snapshot * new.travellers);
    end if;
    new.refund_due_iqd := greatest(0, new.amount_paid_iqd - withheld);
    new.refund_status := case when new.refund_due_iqd > 0 then 'pending' else 'none' end;
  end if;
  return new;
end;
$$;
drop trigger if exists after_booking_cancelled on bookings;
drop trigger if exists before_booking_cancelled_refund on bookings;
create trigger before_booking_cancelled_refund
before update of status on bookings
for each row execute function on_booking_cancelled();

create or replace function expire_stale_bookings()
returns int language plpgsql security definer set search_path = public as $$
declare candidate record;
declare b bookings%rowtype;
declare expired_count int := 0;
begin
  for candidate in
    select id, package_id from bookings
    where expires_at <= now()
      and operational_stage in ('requested','needs_information','awaiting_payment')
    order by expires_at
  loop
    perform 1 from packages where id = candidate.package_id for update;
    select * into b from bookings where id = candidate.id for update;
    if b.operational_stage in ('requested','needs_information','awaiting_payment')
       and b.expires_at <= now() then
      update bookings set operational_stage = 'expired', status = 'cancelled',
        status_reason = 'Booking request expired', cancelled_at = now()
      where id = b.id;
      update packages set seats_reserved = greatest(0, seats_reserved - b.travellers)
      where id = b.package_id;
      expired_count := expired_count + 1;
    end if;
  end loop;
  return expired_count;
end;
$$;
revoke execute on function expire_stale_bookings() from public, anon, authenticated;

do $$ begin
  if exists(select 1 from pg_namespace where nspname = 'cron') then
    perform cron.unschedule(jobid) from cron.job
    where jobname = 'umrah-expire-stale-bookings';
    perform cron.schedule(
      'umrah-expire-stale-bookings', '* * * * *',
      'select public.expire_stale_bookings()'
    );
  end if;
end $$;

-- Explicit Data API privileges for additive columns and RPCs.
-- Offer writes go through bundle RPCs so a package cannot be half-saved and
-- child-table edits cannot bypass versioning/review.
revoke insert on packages from authenticated;
revoke insert, update on itinerary_days from authenticated;
revoke delete on itinerary_days from authenticated;
revoke insert, update, delete on offer_pricing from authenticated;
revoke insert, update, delete on offer_hotels from authenticated;
revoke insert, update, delete on offer_inclusions from authenticated;
revoke insert, update, delete on hotels from authenticated;
grant select (description, description_ar, description_en) on hotels to anon, authenticated;
grant select (room_count, amount_due_now_iqd, quote_version, quote_snapshot,
  cancellation_policy_snapshot, deposit_iqd_snapshot,
  non_refundable_deposit_snapshot, refund_due_iqd, refund_status)
on bookings to authenticated;
revoke execute on function transition_booking(uuid,text,text) from public, anon;
grant execute on function transition_booking(uuid,text,text) to authenticated;
revoke execute on function submit_package(uuid) from public, anon;
grant execute on function submit_package(uuid) to authenticated;
