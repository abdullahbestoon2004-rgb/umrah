-- Company card backgrounds: agencies may save their selected brand colour.
-- Safe to run in the Supabase SQL Editor after the main schema/patches.

alter table public.companies
  add column if not exists tint text not null default '#0f5c4d';

grant update (tint) on table public.companies to authenticated;

-- The standard schema already creates this ownership policy. This block makes
-- the patch safe for projects where it was not applied yet.
do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'companies'
      and policyname = 'agency update own company'
  ) then
    create policy "agency update own company" on public.companies
      for update to authenticated
      using (owner_id = auth.uid() or is_admin());
  end if;
end $$;
