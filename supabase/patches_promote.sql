-- ============================================================================
-- PATCH — Promote companies: add is_promoted column to companies and update
-- RLS/triggers. Run in: Supabase Dashboard > SQL Editor. Safe to re-run.
-- ============================================================================

-- 1. Add is_promoted column to companies table
alter table companies add column if not exists is_promoted boolean not null default false;

-- 2. Update the protect_company_admin_fields trigger function to include is_promoted
create or replace function protect_company_admin_fields()
returns trigger language plpgsql as $$
begin
  if not is_admin() then
    new.is_verified := old.is_verified;
    new.is_active   := old.is_active;
    new.is_promoted := old.is_promoted; -- Protect from non-admin self-promotion
    new.rating      := old.rating;
    new.owner_id    := old.owner_id;
  end if;
  return new;
end; $$;
