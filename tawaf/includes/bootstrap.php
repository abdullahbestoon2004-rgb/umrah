<?php
declare(strict_types=1);

require dirname(__DIR__, 2) . '/tawafbackend/app/bootstrap.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_name('tawaf_admin');
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/tawaf',
        'secure' => !empty($_SERVER['HTTPS']),
        'httponly' => true,
        'samesite' => 'Strict',
    ]);
    session_start();
}

header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: same-origin');
header("Permissions-Policy: camera=(), microphone=(), geolocation=()");
header("Content-Security-Policy: default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'self'; font-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'");

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

// The shared backend bootstrap installs a JSON exception renderer for API
// routes. The dashboard needs an HTML-safe renderer instead, especially when
// an exception happens after a page has begun rendering.
set_exception_handler(function (Throwable $error): void {
    error_log((string) $error);
    if (!headers_sent()) {
        http_response_code(500);
        header('Content-Type: text/html; charset=utf-8');
        header('Cache-Control: no-store');
    }
    $message = config('app_env') === 'development'
        ? e($error->getMessage())
        : 'An unexpected dashboard error occurred. Please try again.';
    echo '<div style="max-width:720px;margin:48px auto;padding:24px;font-family:system-ui,sans-serif;color:#10201d">'
        . '<h1>Tawaf dashboard error</h1><p>' . $message . '</p></div>';
});

function admin_user(): ?array
{
    static $loaded = false;
    static $admin;
    if ($loaded) return $admin;
    $loaded = true;
    $id = $_SESSION['admin_id'] ?? null;
    if (!is_string($id) || $id === '') return null;
    $admin = query_one("SELECT id, email, role, full_name, phone, status, force_password_change, last_login_at FROM users WHERE id = ? AND role = 'admin' AND status = 'active'", [$id]);
    if ($admin === null) {
        unset($_SESSION['admin_id']);
    }
    return $admin;
}

function require_admin_dashboard(): array
{
    $admin = admin_user();
    if ($admin === null) {
        header('Location: login.php');
        exit;
    }
    if (isset($_SESSION['admin_last_seen']) && time() - (int) $_SESSION['admin_last_seen'] > 7200) {
        session_unset();
        session_destroy();
        header('Location: login.php?expired=1');
        exit;
    }
    $_SESSION['admin_last_seen'] = time();
    return $admin;
}

function csrf_token(): string
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return (string) $_SESSION['csrf_token'];
}

function csrf_field(): void
{
    echo '<input type="hidden" name="csrf_token" value="' . e(csrf_token()) . '">';
}

function verify_csrf(): void
{
    $provided = (string) ($_POST['csrf_token'] ?? '');
    if ($provided === '' || !hash_equals(csrf_token(), $provided)) {
        http_response_code(419);
        exit('Your session token expired. Go back, refresh the page, and try again.');
    }
}

function set_flash(string $type, string $message): void
{
    $_SESSION['flash'] = ['type' => $type, 'message' => $message];
}

function pull_flash(): ?array
{
    $flash = $_SESSION['flash'] ?? null;
    unset($_SESSION['flash']);
    return is_array($flash) ? $flash : null;
}

function redirect_dashboard(string $section = 'dashboard'): never
{
    $allowed = ['dashboard','users','agencies','packages','bookings','finance','support','moderation','ads','audit','settings'];
    if (!in_array($section, $allowed, true)) $section = 'dashboard';
    header('Location: index.php?section=' . rawurlencode($section));
    exit;
}

function status_class(string $status): string
{
    return match ($status) {
        'active', 'approved', 'published', 'paid', 'succeeded', 'completed', 'collected', 'resolved', 'visible' => 'success',
        'pending', 'pending_review', 'requested', 'awaiting_payment', 'partially_paid', 'under_review', 'open', 'reviewing' => 'warning',
        'rejected', 'cancelled', 'failed', 'suspended', 'deleted', 'hidden', 'flagged' => 'danger',
        default => 'neutral',
    };
}

function money(mixed $amount): string
{
    return number_format((float) $amount, 0) . ' IQD';
}

function short_id(?string $id): string
{
    return $id === null ? '—' : strtoupper(substr($id, 0, 8));
}

function format_date(?string $value, bool $withTime = false): string
{
    if ($value === null || $value === '') return '—';
    $timestamp = strtotime($value);
    return $timestamp === false ? '—' : date($withTime ? 'M j, Y H:i' : 'M j, Y', $timestamp);
}

function admin_audit(array $admin, string $entityType, ?string $entityId, string $action, mixed $before = null, mixed $after = null, ?string $note = null): void
{
    execute_sql('INSERT INTO audit_logs (id, actor_id, actor_role, entity_type, entity_id, action, before_data, after_data, note, ip_address) VALUES (?, ?, \'admin\', ?, ?, ?, ?, ?, ?, ?)', [
        uuid_v4(), $admin['id'], $entityType, $entityId, $action,
        $before === null ? null : json_encode($before, JSON_UNESCAPED_UNICODE),
        $after === null ? null : json_encode($after, JSON_UNESCAPED_UNICODE),
        $note, substr((string) ($_SERVER['REMOTE_ADDR'] ?? ''), 0, 45),
    ]);
}
