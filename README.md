# Umrah Marketplace

A trilingual Flutter + Supabase marketplace for Umrah packages. Clients,
agencies, and administrators ship in one mobile app with role-gated navigation
and database-enforced permissions.

## Role shells

- `client`: existing Home, Companies, Offers, Bookings, Profile shell. The
  prayer-time panel remains the first content section on Home.
- `agency`: Overview, My Offers, Bookings, Messages, More. Pending, rejected,
  and suspended agencies are held behind a status screen.
- `admin`: Overview, Agencies, Offers, Bookings, More.

## Database rollout

Existing installations are upgraded additively. Apply SQL in this order:

1. `supabase/schema.sql`
2. Existing `supabase/patches*.sql` files, ending with
   `supabase/patches_workflow.sql`
3. `supabase/patches_marketplace_update.sql`
4. All files in `supabase/migrations/` in timestamp order

The marketplace patch adds rich occupancy pricing, reusable hotels,
inclusions, media, agency public-profile fields, approval history, documents,
reports, badges, inquiries, carousel requests, protected commercial settings,
triggers, Realtime publication entries, grants, and RLS policies.

The company trip-operations migration adds permissioned staff access, a
trip-centric operations hub, separate traveller document and visa states,
private document review, rooming, transport manifests, targeted announcements,
and explicit Data API privileges for new Supabase projects. The Flutter company
shell also includes the hybrid settlement wallet, reports, reviews, staff
management, and passenger Excel/PDF exports.

Run `supabase/tests_workflow.sql`, `supabase/tests_payments.sql`, and
`supabase/tests_marketplace_update.sql`, then
`supabase/tests_trip_integrity.sql` and
`supabase/tests_company_trip_operations.sql`, then
`supabase/tests_security_hardening.sql` against a development project after
applying the patches and migrations. The test scripts roll back their fixtures.

## Flutter checks

```bash
flutter gen-l10n
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

All user-facing additions belong in `app_ku.arb`, `app_ar.arb`, and
`app_en.arb`; generated localization files are committed.
