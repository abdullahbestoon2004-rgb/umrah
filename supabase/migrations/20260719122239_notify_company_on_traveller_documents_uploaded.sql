-- Move a successfully submitted traveller into document review and alert the
-- company owner plus active staff who can review booking documents.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create or replace function private.notify_company_documents_uploaded()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  booking_company_id uuid;
begin
  if nullif(new.passport_image_path, '') is null
     or nullif(new.selfie_image_path, '') is null
     or new.document_status <> 'under_review' then
    return new;
  end if;

  -- Notify on the first complete submission and whenever rejected/approved
  -- documents are resubmitted for review. A no-op update while already under
  -- review does not produce duplicate notifications.
  if old.document_status = 'under_review'
     and nullif(old.passport_image_path, '') is not null
     and nullif(old.selfie_image_path, '') is not null then
    return new;
  end if;

  select b.company_id
    into booking_company_id
  from public.bookings b
  where b.id = new.booking_id;

  if booking_company_id is null then
    return new;
  end if;

  insert into public.notifications (user_id, type, arg, booking_id)
  select recipient.user_id, 'documentsUploaded', new.full_name, new.booking_id
  from (
    select c.owner_id as user_id
    from public.companies c
    where c.id = booking_company_id

    union

    select staff.user_id
    from public.agency_staff staff
    where staff.company_id = booking_company_id
      and staff.status = 'active'
      and (
        'manage_all' = any(staff.permissions)
        or 'documents' = any(staff.permissions)
        or staff.role in ('manager', 'booking', 'visa')
      )
  ) recipient
  where recipient.user_id is not null;

  return new;
end;
$$;

revoke all on function private.notify_company_documents_uploaded()
  from public, anon, authenticated;

drop trigger if exists after_notify_company_documents_uploaded
  on public.booking_travellers;
create trigger after_notify_company_documents_uploaded
  after update of passport_image_path, selfie_image_path, document_status
  on public.booking_travellers
  for each row
  execute function private.notify_company_documents_uploaded();

-- Notification reads always filter by user and order newest-first.
create index if not exists notifications_user_created_at_idx
  on public.notifications (user_id, created_at desc);
