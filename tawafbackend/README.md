# Tawaf PHP backend deployment

Upload this directory unchanged to the web document root as `tawafbackend`.
The expected public URL is `https://707222.xyz/tawafbackend`.

## Requirements

- PHP 8.1 or newer
- PDO MySQL, cURL, OpenSSL, Fileinfo, JSON, and mbstring extensions
- MySQL 8 or MariaDB 10.6+
- Apache `mod_rewrite` and `.htaccess` support
- Write permission for `uploads/public` and `uploads/private`

## Database

In phpMyAdmin, select `xyz_tawaf` and import `sql/production.sql`. For fake
development content, then import `sql/development.sql`. Never import the
development file into the real production database.

## Configuration

`app/config.php` already contains the supplied localhost database connection.
If the host supports environment variables, use these overrides:

```text
TAWAF_APP_ENV=production
TAWAF_APP_URL=https://707222.xyz/tawafbackend
TAWAF_ADMIN_URL=https://707222.xyz/tawaf
TAWAF_DB_HOST=localhost
TAWAF_DB_PORT=3306
TAWAF_DB_NAME=xyz_tawaf
TAWAF_DB_USER=xyz_tawaf_user
TAWAF_DB_PASSWORD=your-database-password
TAWAF_MAIL_FROM=noreply@707222.xyz
TAWAF_SUPPORT_EMAIL=support@707222.xyz
FIB_BASE_URL=https://fib.stage.fib.iq
FIB_CLIENT_ID=
FIB_CLIENT_SECRET=
```

The `app` directory is denied from the web. Private uploads are also denied;
only signed API links or authenticated administrator downloads can read them.

## Verification

Open `https://707222.xyz/tawafbackend/api/health`. A correct deployment returns
JSON with `service: Tawaf API` and `database: ok`.

If clean `/api/...` routes do not work, the Flutter app still calls
`api/index.php?route=...` directly. The administrator and generated file URLs
need Apache rewrite support.
