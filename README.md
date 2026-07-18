# Tawaf Umrah Marketplace

A trilingual Flutter marketplace backed by a self-hosted PHP 8 + MySQL API.
Clients can browse and book; agencies manage offers and trip operations; the
web administrator controls users, approvals, bookings, finance, support,
moderation, advertising, and audit history.

## Project folders

- `lib/` — Flutter app using `https://707222.xyz/tawafbackend/api`.
- `tawafbackend/` — upload this complete folder as `/tawafbackend`.
- `tawaf/` — upload this complete folder as `/tawaf`.
- `tawafbackend/sql/production.sql` — empty production business database with
  only the starter administrator and required reference settings.
- `tawafbackend/sql/development.sql` — optional fake data imported after the
  production schema.
- `supabase/` — legacy migration history only; it is no longer used by the app.

## Server deployment

1. In phpMyAdmin, select the `xyz_tawaf` database and import
   `tawafbackend/sql/production.sql`.
2. For a development database only, import
   `tawafbackend/sql/development.sql` immediately afterwards.
3. Upload `tawafbackend` to the document root so its public URL is
   `https://707222.xyz/tawafbackend`.
4. Upload `tawaf` beside it so its public URL is
   `https://707222.xyz/tawaf`.
5. Ensure PHP has PDO MySQL, cURL, OpenSSL, Fileinfo, JSON, and mbstring, and
   that `tawafbackend/uploads` is writable by PHP.
6. Open `https://707222.xyz/tawafbackend/api/health`; both service and database
   should report `ok`.
7. Sign in at `https://707222.xyz/tawaf` and immediately change the starter
   administrator password in Settings.

The checked-in backend configuration uses the supplied localhost database
credentials. Environment variables documented in `tawafbackend/README.md`
override those values and are preferred when the host supports them.

## Administrator login

- URL: `https://707222.xyz/tawaf`
- Email: `admin@707222.xyz`
- First password: `ChangeMe!707222`

The account is marked as requiring a password change. The production SQL is
idempotent and will not overwrite a password that has already been changed.

Development-only accounts all use `Demo!2026`:

- `agency@tawaf.test`
- `client@tawaf.test`
- `guide@tawaf.test`

## Flutter checks

```bash
flutter gen-l10n
flutter analyze
flutter test
```

Override the API URL for staging or local development with:

```bash
flutter run --dart-define=TAWAF_API_URL=https://example.com/tawafbackend/api/index.php
```

## Payment configuration

FIB credentials stay on the PHP server and are never included in the Flutter
app. Set `FIB_BASE_URL`, `FIB_CLIENT_ID`, and `FIB_CLIENT_SECRET` in the hosting
environment before enabling FIB. See `PAYMENTS.md` for the payment and ledger
model.
