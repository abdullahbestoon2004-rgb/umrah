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

The marketplace patch adds rich occupancy pricing, reusable hotels,
inclusions, media, agency public-profile fields, approval history, documents,
reports, badges, inquiries, carousel requests, protected commercial settings,
triggers, Realtime publication entries, grants, and RLS policies.

Run `supabase/tests_workflow.sql`, `supabase/tests_payments.sql`, and
`supabase/tests_marketplace_update.sql` against a development project after
applying the patches. The test scripts roll back their fixtures.

## Flutter checks

```bash
flutter gen-l10n
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

All user-facing additions belong in `app_ku.arb`, `app_ar.arb`, and
`app_en.arb`; generated localization files are committed.
