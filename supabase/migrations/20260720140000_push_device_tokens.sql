-- Push notification delivery.
--
-- The notifications table already records *what* to tell a user; this adds the
-- "where to send it" half so a pilgrim learns their booking was confirmed
-- without having to reopen the app.

-- ---------------------------------------------------------------------------
-- 1. Device tokens
-- ---------------------------------------------------------------------------
create table if not exists device_tokens (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  token       text not null,
  platform    text not null check (platform in ('ios', 'android', 'web')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  -- One row per physical device. Re-registering the same token for a
  -- different account must move it, not duplicate it, or the previous user
  -- keeps receiving the new user's notifications on a shared handset.
  unique (token)
);

create index if not exists device_tokens_user_id_idx on device_tokens(user_id);

alter table device_tokens enable row level security;

drop policy if exists "read own device tokens" on device_tokens;
create policy "read own device tokens" on device_tokens for select
  using (user_id = auth.uid());

drop policy if exists "insert own device tokens" on device_tokens;
create policy "insert own device tokens" on device_tokens for insert
  with check (user_id = auth.uid());

drop policy if exists "update own device tokens" on device_tokens;
create policy "update own device tokens" on device_tokens for update
  using (user_id = auth.uid());

drop policy if exists "delete own device tokens" on device_tokens;
create policy "delete own device tokens" on device_tokens for delete
  using (user_id = auth.uid());

-- Registering a token that already exists (same handset, new sign-in) hands
-- it to the current owner rather than failing the insert.
create or replace function register_device_token(
  p_token text,
  p_platform text
)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  if p_platform not in ('ios', 'android', 'web') then
    raise exception 'unsupported platform';
  end if;

  insert into device_tokens (user_id, token, platform)
  values (auth.uid(), p_token, p_platform)
  on conflict (token) do update
    set user_id = auth.uid(),
        platform = excluded.platform,
        updated_at = now();
end;
$$;

revoke execute on function register_device_token(text, text) from anon;
grant execute on function register_device_token(text, text) to authenticated;

-- Signing out should stop delivery to that handset.
create or replace function unregister_device_token(p_token text)
returns void language plpgsql security definer set search_path = public as $$
begin
  delete from device_tokens
   where token = p_token and user_id = auth.uid();
end;
$$;

revoke execute on function unregister_device_token(text) from anon;
grant execute on function unregister_device_token(text) to authenticated;

-- ---------------------------------------------------------------------------
-- 2. Fan out new notifications to the send-push Edge Function
-- ---------------------------------------------------------------------------
-- Requires pg_net (available on Supabase) plus two settings holding the
-- project URL and service-role key:
--   alter database postgres set app.settings.supabase_url = 'https://<ref>.supabase.co';
--   alter database postgres set app.settings.service_role_key = '<service-role-key>';
create extension if not exists pg_net with schema extensions;

create or replace function notify_push_on_notification()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  project_url text := current_setting('app.settings.supabase_url', true);
  service_key text := current_setting('app.settings.service_role_key', true);
begin
  -- Unconfigured environments (local dev, CI) simply skip delivery; the
  -- in-app notification row is already written either way.
  if project_url is null or service_key is null then
    return new;
  end if;

  perform extensions.net.http_post(
    url := project_url || '/functions/v1/send-push',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_key
    ),
    body := jsonb_build_object(
      'user_id', new.user_id,
      'type', new.type,
      'arg', new.arg,
      'booking_id', new.booking_id,
      'notification_id', new.id
    )
  );
  return new;
end;
$$;

drop trigger if exists push_on_notification on notifications;
create trigger push_on_notification
  after insert on notifications
  for each row execute function notify_push_on_notification();
