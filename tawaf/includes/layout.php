<?php
declare(strict_types=1);

function render_header(string $title, string $section, array $admin): void
{
    $nav = [
        'dashboard' => ['Overview', 'grid'],
        'users' => ['Users', 'users'],
        'agencies' => ['Agencies', 'building'],
        'packages' => ['Packages', 'briefcase'],
        'bookings' => ['Bookings', 'ticket'],
        'finance' => ['Finance', 'wallet'],
        'support' => ['Support', 'message'],
        'moderation' => ['Moderation', 'shield'],
        'ads' => ['Home ads', 'megaphone'],
        'audit' => ['Audit log', 'activity'],
        'settings' => ['Settings', 'settings'],
    ];
    $pending = query_one("SELECT
        (SELECT COUNT(*) FROM companies WHERE verification_status IN ('pending','needs_changes')) +
        (SELECT COUNT(*) FROM packages WHERE lifecycle_status = 'pending_review') +
        (SELECT COUNT(*) FROM support_messages WHERE status IN ('open','in_progress')) +
        (SELECT COUNT(*) FROM agency_reports WHERE status IN ('open','reviewing')) AS total");
    $pendingTotal = (int) ($pending['total'] ?? 0);
    ?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Tawaf marketplace administration">
  <meta name="theme-color" content="#0b493f">
  <meta property="og:title" content="Tawaf Administration">
  <meta property="og:description" content="Operations, bookings, agencies and finance in one secure workspace.">
  <meta property="og:type" content="website">
  <meta property="og:image" content="<?= e(config('admin_url')) ?>/assets/og.png">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Tawaf Administration">
  <meta name="twitter:description" content="Operations, bookings, agencies and finance in one secure workspace.">
  <meta name="twitter:image" content="<?= e(config('admin_url')) ?>/assets/og.png">
  <title><?= e($title) ?> · Tawaf Admin</title>
  <link rel="stylesheet" href="assets/admin.css?v=1">
</head>
<body>
  <div class="app-shell">
    <aside class="sidebar" id="sidebar">
      <a class="brand" href="index.php">
        <span class="brand-mark" aria-hidden="true">ط</span>
        <span><strong>Tawaf</strong><small>Administration</small></span>
      </a>
      <nav class="main-nav" aria-label="Main navigation">
        <?php foreach ($nav as $key => [$label, $icon]): ?>
          <a class="nav-link <?= $section === $key ? 'active' : '' ?>" href="index.php?section=<?= e($key) ?>">
            <span class="nav-icon" data-icon="<?= e($icon) ?>" aria-hidden="true"></span>
            <span><?= e($label) ?></span>
            <?php if ($key === 'moderation' && $pendingTotal > 0): ?><span class="nav-count"><?= $pendingTotal ?></span><?php endif; ?>
          </a>
        <?php endforeach; ?>
      </nav>
      <div class="sidebar-foot">
        <div class="admin-mini">
          <span class="avatar"><?= e(strtoupper(substr($admin['full_name'] ?: $admin['email'], 0, 1))) ?></span>
          <span><strong><?= e($admin['full_name'] ?: 'Administrator') ?></strong><small><?= e($admin['email']) ?></small></span>
        </div>
        <a class="logout-link" href="logout.php">Sign out</a>
      </div>
    </aside>
    <main class="main-content">
      <header class="topbar">
        <button class="menu-button" type="button" aria-label="Open navigation" aria-controls="sidebar" aria-expanded="false" data-menu-button>
          <span></span><span></span><span></span>
        </button>
        <div><p class="eyebrow">Tawaf marketplace</p><h1><?= e($title) ?></h1></div>
        <div class="topbar-actions">
          <a class="site-link" href="<?= e(config('app_url')) ?>/api/health" target="_blank" rel="noreferrer"><span class="live-dot"></span>API status</a>
          <span class="date-chip"><?= date('D, M j') ?></span>
        </div>
      </header>
      <div class="page-content">
        <?php if (!empty($admin['force_password_change'])): ?>
          <div class="alert warning"><strong>Change the starter password.</strong> Open Settings and set a private administrator password before using production data.</div>
        <?php endif; ?>
        <?php if ($flash = pull_flash()): ?>
          <div class="alert <?= e($flash['type']) ?>" role="status"><?= e($flash['message']) ?></div>
        <?php endif; ?>
    <?php
}

function render_footer(): void
{
    ?>
      </div>
    </main>
  </div>
  <script src="assets/admin.js?v=1" defer></script>
</body>
</html>
    <?php
}

function badge(string $status): string
{
    return '<span class="status ' . e(status_class($status)) . '"><i></i>' . e(str_replace('_', ' ', $status)) . '</span>';
}

function empty_state(string $title, string $copy): void
{
    echo '<div class="empty-state"><span aria-hidden="true">✓</span><h3>' . e($title) . '</h3><p>' . e($copy) . '</p></div>';
}
