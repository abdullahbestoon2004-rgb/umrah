# Tawaf administrator dashboard

Upload this directory beside `tawafbackend` as `tawaf`. It includes the secure
PHP login, responsive operations dashboard, moderation, finance, support,
advertising, settings, and audit views.

It includes `../tawafbackend/app/bootstrap.php`, so both uploaded directories
must remain siblings in the same document root.

## First login

- URL: `https://707222.xyz/tawaf`
- Email: `admin@707222.xyz`
- Password: `ChangeMe!707222`

Open Settings immediately after signing in and replace the starter password.
The database marks the starter account with `force_password_change` so the
dashboard keeps showing a warning until this is done.
