<?php
declare(strict_types=1);

require __DIR__ . '/includes/bootstrap.php';

if (admin_user() !== null) {
    header('Location: index.php');
    exit;
}

$error = null;
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    verify_csrf();
    $email = strtolower(trim((string) ($_POST['email'] ?? '')));
    $password = (string) ($_POST['password'] ?? '');
    try {
        enforce_rate_limit('admin_login', $email, 6, 20);
        $user = query_one("SELECT * FROM users WHERE email = ? AND role = 'admin' LIMIT 1", [$email]);
        if ($user === null || $user['status'] !== 'active' || !password_verify($password, $user['password_hash'])) {
            $error = 'The email or password is incorrect.';
            admin_audit($user ?? ['id' => null], 'user', $user['id'] ?? null, 'admin_login_failed', null, ['email' => $email]);
        } else {
            clear_rate_limit('admin_login', $email);
            session_regenerate_id(true);
            $_SESSION['admin_id'] = $user['id'];
            $_SESSION['admin_last_seen'] = time();
            execute_sql('UPDATE users SET last_login_at = UTC_TIMESTAMP() WHERE id = ?', [$user['id']]);
            admin_audit($user, 'user', $user['id'], 'admin_login');
            header('Location: index.php?section=' . (!empty($user['force_password_change']) ? 'settings' : 'dashboard'));
            exit;
        }
    } catch (Throwable $exception) {
        error_log((string) $exception);
        $error = 'The dashboard could not connect to the database. Check the backend configuration and imported schema.';
    }
}
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0b493f">
  <title>Sign in · Tawaf Admin</title>
  <link rel="stylesheet" href="assets/admin.css?v=1">
</head>
<body class="login-body">
  <main class="login-shell">
    <section class="login-brand-panel">
      <a class="brand brand-light" href="login.php"><span class="brand-mark">ط</span><span><strong>Tawaf</strong><small>Administration</small></span></a>
      <div class="login-brand-copy">
        <p class="eyebrow">Marketplace command centre</p>
        <h1>One clear view of every journey.</h1>
        <p>Review agencies, manage departures, follow payments, and support pilgrims from a secure operations workspace.</p>
      </div>
      <div class="login-signal"><span class="live-dot"></span><span>PHP API and MySQL operations</span></div>
    </section>
    <section class="login-form-panel">
      <div class="login-form-wrap">
        <span class="mobile-brand-mark">ط</span>
        <p class="eyebrow">Welcome back</p>
        <h2>Administrator sign in</h2>
        <p class="muted">Use the administrator account created by the SQL schema.</p>
        <?php if (isset($_GET['expired'])): ?><div class="alert warning">Your session expired. Sign in again.</div><?php endif; ?>
        <?php if ($error !== null): ?><div class="alert danger" role="alert"><?= e($error) ?></div><?php endif; ?>
        <form method="post" class="login-form" autocomplete="on">
          <?php csrf_field(); ?>
          <label>Email address<input type="email" name="email" value="<?= e($_POST['email'] ?? '') ?>" autocomplete="username" required autofocus></label>
          <label>Password
            <span class="password-field"><input type="password" name="password" autocomplete="current-password" required data-password-input><button type="button" data-password-toggle aria-label="Show password">Show</button></span>
          </label>
          <button class="button primary wide" type="submit">Sign in to Tawaf</button>
        </form>
        <p class="login-help">Production access is limited to accounts with the <strong>admin</strong> role.</p>
      </div>
    </section>
  </main>
  <script src="assets/admin.js?v=1" defer></script>
</body>
</html>
