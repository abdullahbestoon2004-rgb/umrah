<?php
declare(strict_types=1);

require __DIR__ . '/includes/bootstrap.php';
require __DIR__ . '/includes/layout.php';

$admin = require_admin_dashboard();
$allowedSections = ['dashboard','users','agencies','packages','bookings','finance','support','moderation','ads','audit','settings'];
$section = (string) ($_GET['section'] ?? 'dashboard');
if (!in_array($section, $allowedSections, true)) $section = 'dashboard';
$titles = [
    'dashboard' => 'Operations overview', 'users' => 'Users', 'agencies' => 'Agencies',
    'packages' => 'Umrah packages', 'bookings' => 'Bookings', 'finance' => 'Finance',
    'support' => 'Support inbox', 'moderation' => 'Moderation queue', 'ads' => 'Home advertising',
    'audit' => 'Audit log', 'settings' => 'Platform settings',
];
render_header($titles[$section], $section, $admin);

function action_form(string $action, string $section, array $fields, string $label, string $class = 'button small ghost', ?string $confirm = null): void
{
    echo '<form method="post" action="actions.php" class="inline-form">';
    csrf_field();
    echo '<input type="hidden" name="action" value="' . e($action) . '"><input type="hidden" name="return_section" value="' . e($section) . '">';
    foreach ($fields as $key => $value) echo '<input type="hidden" name="' . e($key) . '" value="' . e($value) . '">';
    echo '<button class="' . e($class) . '" type="submit"' . ($confirm ? ' data-confirm="' . e($confirm) . '"' : '') . '>' . e($label) . '</button></form>';
}

if ($section === 'dashboard'):
    $counts = query_one("SELECT
        (SELECT COUNT(*) FROM users WHERE status = 'active') AS users,
        (SELECT COUNT(*) FROM companies WHERE is_verified = 1 AND status = 'active') AS agencies,
        (SELECT COUNT(*) FROM packages WHERE is_published = 1) AS packages,
        (SELECT COUNT(*) FROM bookings WHERE operational_stage NOT IN ('cancelled','rejected','expired','completed')) AS live_bookings,
        (SELECT COUNT(*) FROM companies WHERE verification_status IN ('pending','needs_changes')) AS agency_queue,
        (SELECT COUNT(*) FROM packages WHERE lifecycle_status = 'pending_review') AS package_queue,
        (SELECT COUNT(*) FROM support_messages WHERE status IN ('open','in_progress')) AS support_queue");
    $money = query_one("SELECT
        COALESCE((SELECT SUM(amount_iqd) FROM payments WHERE status = 'succeeded'),0) AS processed,
        COALESCE((SELECT SUM(amount_iqd) FROM commissions WHERE status = 'owed'),0) AS commission_owed,
        COALESCE((SELECT SUM(amount_iqd) FROM payouts WHERE status = 'pending'),0) AS pending_payouts");
    $recentBookings = query_all('SELECT b.*, p.title_en, p.title, c.name_en AS company_en, c.name AS company_name, u.full_name FROM bookings b JOIN packages p ON p.id = b.package_id JOIN companies c ON c.id = b.company_id JOIN users u ON u.id = b.client_id ORDER BY b.created_at DESC LIMIT 7');
    $agencyQueue = query_all("SELECT * FROM companies WHERE verification_status IN ('pending','needs_changes') ORDER BY submitted_at DESC LIMIT 4");
?>
  <section class="hero-panel">
    <div><p class="eyebrow light">Live operations</p><h2>Keep every pilgrim journey moving.</h2><p>Review what needs attention, follow active bookings, and reconcile marketplace money from one workspace.</p></div>
    <div class="hero-metric"><span>Active bookings</span><strong><?= number_format((int) $counts['live_bookings']) ?></strong><small><?= (int) $counts['agency_queue'] + (int) $counts['package_queue'] + (int) $counts['support_queue'] ?> items need review</small></div>
  </section>
  <section class="kpi-grid">
    <article class="kpi-card"><span class="kpi-icon emerald">↗</span><p>Payment volume</p><strong><?= money($money['processed']) ?></strong><small>Confirmed transactions</small></article>
    <article class="kpi-card"><span class="kpi-icon gold">◎</span><p>Active users</p><strong><?= number_format((int) $counts['users']) ?></strong><small><?= number_format((int) $counts['agencies']) ?> approved agencies</small></article>
    <article class="kpi-card"><span class="kpi-icon blue">◇</span><p>Published packages</p><strong><?= number_format((int) $counts['packages']) ?></strong><small>Available in the app</small></article>
    <article class="kpi-card"><span class="kpi-icon coral">!</span><p>Commission owed</p><strong><?= money($money['commission_owed']) ?></strong><small><?= money($money['pending_payouts']) ?> pending payouts</small></article>
  </section>
  <div class="content-grid two-one">
    <section class="panel">
      <div class="panel-head"><div><p class="eyebrow">Latest activity</p><h2>Recent bookings</h2></div><a href="index.php?section=bookings">View all</a></div>
      <?php if ($recentBookings): ?>
      <div class="table-wrap"><table><thead><tr><th>Booking</th><th>Pilgrim</th><th>Agency</th><th>Total</th><th>Stage</th></tr></thead><tbody>
      <?php foreach ($recentBookings as $booking): ?><tr><td><strong><?= e($booking['title_en'] ?: $booking['title']) ?></strong><small>#<?= e(short_id($booking['id'])) ?> · <?= format_date($booking['created_at']) ?></small></td><td><?= e($booking['full_name']) ?><small><?= (int) $booking['travellers'] ?> traveller<?= (int) $booking['travellers'] === 1 ? '' : 's' ?></small></td><td><?= e($booking['company_en'] ?: $booking['company_name']) ?></td><td><?= money($booking['total_iqd']) ?></td><td><?= badge($booking['operational_stage']) ?></td></tr><?php endforeach; ?>
      </tbody></table></div>
      <?php else: empty_state('No bookings yet', 'New marketplace bookings will appear here.'); endif; ?>
    </section>
    <aside class="panel attention-panel">
      <div class="panel-head"><div><p class="eyebrow">Needs attention</p><h2>Review queue</h2></div></div>
      <div class="queue-totals"><a href="index.php?section=agencies"><strong><?= (int) $counts['agency_queue'] ?></strong><span>Agencies</span></a><a href="index.php?section=packages"><strong><?= (int) $counts['package_queue'] ?></strong><span>Packages</span></a><a href="index.php?section=support"><strong><?= (int) $counts['support_queue'] ?></strong><span>Support</span></a></div>
      <div class="mini-list">
      <?php foreach ($agencyQueue as $agency): ?><a href="index.php?section=agencies"><span class="company-dot" style="--dot:<?= e($agency['tint']) ?>"><?= e(strtoupper(substr($agency['name_en'] ?: $agency['name'], 0, 1))) ?></span><span><strong><?= e($agency['name_en'] ?: $agency['name']) ?></strong><small><?= e($agency['location']) ?> · <?= e(str_replace('_', ' ', $agency['verification_status'])) ?></small></span><b>›</b></a><?php endforeach; ?>
      <?php if (!$agencyQueue): ?><p class="all-clear">Agency review queue is clear.</p><?php endif; ?>
      </div>
    </aside>
  </div>

<?php elseif ($section === 'users'):
    $q = trim((string) ($_GET['q'] ?? ''));
    $params = [];
    $where = '';
    if ($q !== '') { $where = 'WHERE email LIKE ? OR full_name LIKE ? OR phone LIKE ?'; $params = ["%{$q}%", "%{$q}%", "%{$q}%"]; }
    $users = query_all("SELECT * FROM users {$where} ORDER BY created_at DESC LIMIT 150", $params);
?>
  <div class="section-toolbar"><div><p>Manage client, agency, and administrator access.</p></div><form class="search" method="get"><input type="hidden" name="section" value="users"><input name="q" value="<?= e($q) ?>" placeholder="Search name, email, or phone"><button>Search</button></form></div>
  <section class="panel">
    <?php if ($users): ?><div class="table-wrap"><table><thead><tr><th>User</th><th>Role</th><th>Identity</th><th>Created</th><th>Last sign-in</th><th>Status</th><th></th></tr></thead><tbody>
    <?php foreach ($users as $user): ?><tr><td><strong><?= e($user['full_name'] ?: 'Unnamed user') ?></strong><small><?= e($user['email']) ?><?= $user['phone'] ? ' · ' . e($user['phone']) : '' ?></small></td><td><span class="role-chip"><?= e($user['role']) ?></span></td><td><?= badge($user['identity_status']) ?></td><td><?= format_date($user['created_at']) ?></td><td><?= format_date($user['last_login_at'], true) ?></td><td><?= badge($user['status']) ?></td><td class="actions-cell"><?php if ($user['id'] !== $admin['id']): action_form('user_status','users',['id'=>$user['id'],'status'=>$user['status']==='active'?'suspended':'active'],$user['status']==='active'?'Suspend':'Activate','button small ' . ($user['status']==='active'?'danger-ghost':'ghost'),$user['status']==='active'?'Suspend this account and revoke its app sessions?':null); endif; ?></td></tr><?php endforeach; ?>
    </tbody></table></div><?php else: empty_state('No users found', 'Try a different search.'); endif; ?>
  </section>

<?php elseif ($section === 'agencies'):
    $agencies = query_all('SELECT c.*, u.email AS owner_email, u.full_name AS owner_name, (SELECT COUNT(*) FROM packages p WHERE p.company_id = c.id) AS package_count, (SELECT COUNT(*) FROM bookings b WHERE b.company_id = c.id) AS booking_count FROM companies c JOIN users u ON u.id = c.owner_id ORDER BY FIELD(c.verification_status, \'pending\',\'needs_changes\',\'draft\',\'approved\',\'rejected\'), c.created_at DESC');
?>
  <div class="section-toolbar"><div><p>Verify legal documents, control marketplace visibility, and monitor agency health.</p></div><span class="summary-chip"><?= count($agencies) ?> total agencies</span></div>
  <div class="card-list">
  <?php foreach ($agencies as $agency): ?>
    <article class="entity-card">
      <div class="entity-main"><span class="company-avatar" style="--brand:<?= e($agency['tint']) ?>"><?= e(strtoupper(substr($agency['name_en'] ?: $agency['name'], 0, 2))) ?></span><div><div class="entity-title"><h3><?= e($agency['name_en'] ?: $agency['name']) ?></h3><?= badge($agency['verification_status']) ?><?php if ($agency['is_promoted']): ?><span class="status gold">Promoted</span><?php endif; ?></div><p><?= e($agency['location']) ?> · Owner: <?= e($agency['owner_name']) ?> (<?= e($agency['owner_email']) ?>)</p><div class="entity-stats"><span><strong><?= (int) $agency['package_count'] ?></strong> packages</span><span><strong><?= (int) $agency['booking_count'] ?></strong> bookings</span><span><strong><?= number_format((float) $agency['rating'], 1) ?></strong> rating</span><span><strong><?= number_format((float) $agency['commission_rate'] * 100, 1) ?>%</strong> commission</span></div></div></div>
      <div class="entity-actions">
        <?php action_form('company_toggle','agencies',['id'=>$agency['id'],'field'=>'is_promoted','value'=>$agency['is_promoted']?'0':'1'],$agency['is_promoted']?'Remove promotion':'Promote'); ?>
        <?php action_form('company_toggle','agencies',['id'=>$agency['id'],'field'=>'is_active','value'=>$agency['is_active']?'0':'1'],$agency['is_active']?'Pause agency':'Reactivate','button small ' . ($agency['is_active']?'danger-ghost':'ghost'),$agency['is_active']?'Hide this agency and its public availability?':null); ?>
      </div>
      <?php if (in_array($agency['verification_status'], ['pending','needs_changes','draft'], true)): ?>
      <form class="review-strip" method="post" action="actions.php"><?php csrf_field(); ?><input type="hidden" name="action" value="company_review"><input type="hidden" name="return_section" value="agencies"><input type="hidden" name="id" value="<?= e($agency['id']) ?>"><textarea name="reason" placeholder="Reason or requested changes (required unless approving)"><?= e($agency['verification_reason']) ?></textarea><button class="button small primary" name="decision" value="approved">Approve</button><button class="button small ghost" name="decision" value="needs_changes">Needs changes</button><button class="button small danger-ghost" name="decision" value="rejected" data-confirm="Reject this agency application?">Reject</button></form>
      <?php endif; ?>
    </article>
  <?php endforeach; ?>
  <?php if (!$agencies) empty_state('No agencies yet', 'Agency registrations will appear here.'); ?>
  </div>

<?php elseif ($section === 'packages'):
    $packages = query_all('SELECT p.*, c.name AS company_name, c.name_en AS company_en, (SELECT COUNT(*) FROM bookings b WHERE b.package_id = p.id) AS booking_count FROM packages p JOIN companies c ON c.id = p.company_id ORDER BY FIELD(p.lifecycle_status, \'pending_review\',\'needs_changes\',\'published\',\'draft\',\'paused\',\'archived\'), p.created_at DESC');
?>
  <div class="section-toolbar"><p>Review commercial terms and control which departures appear in the app.</p><span class="summary-chip"><?= count($packages) ?> packages</span></div>
  <section class="panel"><?php if ($packages): ?><div class="table-wrap"><table><thead><tr><th>Package</th><th>Agency</th><th>Departure</th><th>Price</th><th>Capacity</th><th>Status</th><th>Placement</th></tr></thead><tbody>
  <?php foreach ($packages as $package): ?><tr><td><strong><?= e($package['title_en'] ?: $package['title']) ?></strong><small>#<?= short_id($package['id']) ?> · <?= (int) $package['days'] ?> days · <?= e($package['transport']) ?></small></td><td><?= e($package['company_en'] ?: $package['company_name']) ?><small><?= (int) $package['booking_count'] ?> bookings</small></td><td><?= format_date($package['departure_date']) ?><small>Returns <?= format_date($package['return_date']) ?></small></td><td><?= money($package['price_iqd']) ?><small>Deposit <?= money($package['deposit_iqd']) ?></small></td><td><?= $package['capacity'] === null ? 'Open' : number_format(max(0,(int)$package['capacity']-(int)$package['seats_reserved'])) . ' / ' . number_format((int)$package['capacity']) ?><small>available</small></td><td><?= badge($package['lifecycle_status']) ?><?php if ($package['review_reason']): ?><small class="danger-text"><?= e($package['review_reason']) ?></small><?php endif; ?></td><td class="actions-cell"><?php action_form('package_feature','packages',['id'=>$package['id'],'value'=>$package['is_featured']?'0':'1'],$package['is_featured']?'Unfeature':'Feature'); ?><?php if ($package['lifecycle_status']==='pending_review'): ?><details class="action-menu"><summary>Review</summary><form method="post" action="actions.php"><?php csrf_field(); ?><input type="hidden" name="action" value="package_review"><input type="hidden" name="return_section" value="packages"><input type="hidden" name="id" value="<?= e($package['id']) ?>"><textarea name="reason" placeholder="Reason for changes"></textarea><button name="decision" value="approved" class="button small primary">Approve</button><button name="decision" value="needs_changes" class="button small ghost">Return</button></form></details><?php endif; ?></td></tr><?php endforeach; ?>
  </tbody></table></div><?php else: empty_state('No packages yet', 'Agency package drafts will appear here.'); endif; ?></section>

<?php elseif ($section === 'bookings'):
    $bookings = query_all('SELECT b.*, p.title, p.title_en, c.name AS company_name, c.name_en AS company_en, u.full_name, u.email FROM bookings b JOIN packages p ON p.id = b.package_id JOIN companies c ON c.id = b.company_id JOIN users u ON u.id = b.client_id ORDER BY b.created_at DESC LIMIT 200');
?>
  <div class="section-toolbar"><p>Inspect booking progress, payment state, and operational exceptions.</p><span class="summary-chip"><?= count($bookings) ?> shown</span></div>
  <section class="panel"><?php if ($bookings): ?><div class="table-wrap"><table><thead><tr><th>Reference</th><th>Pilgrim</th><th>Trip</th><th>Travel</th><th>Payment</th><th>Stage</th><th>Admin override</th></tr></thead><tbody>
  <?php foreach ($bookings as $booking): ?><tr><td><strong>UM-<?= short_id($booking['id']) ?></strong><small><?= format_date($booking['created_at'], true) ?></small></td><td><?= e($booking['full_name']) ?><small><?= e($booking['email']) ?> · <?= (int)$booking['travellers'] ?> travellers</small></td><td><?= e($booking['title_en'] ?: $booking['title']) ?><small><?= e($booking['company_en'] ?: $booking['company_name']) ?></small></td><td><?= format_date($booking['departure_date']) ?><small><?= e($booking['room_occupancy'] ? $booking['room_occupancy'] . '-person room' : 'Room pending') ?></small></td><td><strong><?= money($booking['amount_paid_iqd']) ?></strong><small>of <?= money($booking['total_iqd']) ?></small><?= badge($booking['pay_status']) ?></td><td><?= badge($booking['operational_stage']) ?><?php if ($booking['status_reason']): ?><small class="danger-text"><?= e($booking['status_reason']) ?></small><?php endif; ?></td><td><details class="action-menu"><summary>Change</summary><form method="post" action="actions.php"><?php csrf_field(); ?><input type="hidden" name="action" value="booking_stage"><input type="hidden" name="return_section" value="bookings"><input type="hidden" name="id" value="<?= e($booking['id']) ?>"><select name="stage"><?php foreach (['requested','needs_information','awaiting_payment','confirmed','ready','in_progress','completed','cancelled','rejected','expired'] as $stage): ?><option value="<?= $stage ?>" <?= $stage===$booking['operational_stage']?'selected':'' ?>><?= e(str_replace('_',' ',$stage)) ?></option><?php endforeach; ?></select><textarea name="reason" placeholder="Admin note"></textarea><button class="button small primary">Save stage</button></form></details></td></tr><?php endforeach; ?>
  </tbody></table></div><?php else: empty_state('No bookings yet', 'Client bookings will appear here.'); endif; ?></section>

<?php elseif ($section === 'finance'):
    $finance = query_one("SELECT
      COALESCE((SELECT SUM(amount_iqd) FROM payments WHERE status='succeeded'),0) AS processed,
      COALESCE((SELECT SUM(amount_iqd) FROM commissions WHERE status='owed'),0) AS owed,
      COALESCE((SELECT SUM(amount_iqd) FROM commissions WHERE status='collected'),0) AS collected,
      COALESCE((SELECT SUM(amount_iqd) FROM payouts WHERE status='pending'),0) AS payouts_pending");
    $balances = query_all("SELECT c.id, c.name, c.name_en, COALESCE(SUM(l.amount_iqd),0) AS balance_iqd, COALESCE((SELECT SUM(amount_iqd) FROM payouts p WHERE p.company_id=c.id AND p.status='pending'),0) AS pending_payout FROM companies c LEFT JOIN agency_ledger l ON l.company_id=c.id GROUP BY c.id ORDER BY balance_iqd DESC");
    $commissions = query_all("SELECT co.*, c.name, c.name_en FROM commissions co JOIN companies c ON c.id=co.company_id ORDER BY FIELD(co.status,'owed','collected','waived'), co.created_at DESC LIMIT 100");
    $payouts = query_all("SELECT p.*, c.name, c.name_en FROM payouts p JOIN companies c ON c.id=p.company_id ORDER BY p.created_at DESC LIMIT 50");
?>
  <section class="kpi-grid">
    <article class="kpi-card"><span class="kpi-icon emerald">↗</span><p>Processed payments</p><strong><?= money($finance['processed']) ?></strong><small>All successful transactions</small></article>
    <article class="kpi-card"><span class="kpi-icon gold">◎</span><p>Commission collected</p><strong><?= money($finance['collected']) ?></strong><small>Settled platform revenue</small></article>
    <article class="kpi-card"><span class="kpi-icon coral">!</span><p>Commission owed</p><strong><?= money($finance['owed']) ?></strong><small>Outstanding agency debt</small></article>
    <article class="kpi-card"><span class="kpi-icon blue">◇</span><p>Pending payouts</p><strong><?= money($finance['payouts_pending']) ?></strong><small>Awaiting transfer</small></article>
  </section>
  <section class="panel">
    <div class="panel-head"><div><p class="eyebrow">Settlement</p><h2>Agency balances</h2></div><p>Positive means Tawaf owes the agency; negative means the agency owes Tawaf.</p></div>
    <?php if ($balances): ?><div class="table-wrap"><table><thead><tr><th>Agency</th><th>Ledger balance</th><th>Pending payout</th><th>Available</th><th>Create payout</th></tr></thead><tbody>
    <?php foreach ($balances as $balance): $available=max(0,(int)$balance['balance_iqd']-(int)$balance['pending_payout']); ?><tr><td><strong><?= e($balance['name_en'] ?: $balance['name']) ?></strong></td><td class="<?= (int)$balance['balance_iqd']<0?'danger-text':'' ?>"><?= money($balance['balance_iqd']) ?></td><td><?= money($balance['pending_payout']) ?></td><td><strong><?= money($available) ?></strong></td><td><?php if ($available>0): ?><details class="action-menu align-right"><summary>New payout</summary><form method="post" action="actions.php"><?php csrf_field(); ?><input type="hidden" name="action" value="payout_create"><input type="hidden" name="return_section" value="finance"><input type="hidden" name="company_id" value="<?= e($balance['id']) ?>"><label>Amount IQD<input type="number" name="amount_iqd" min="1" max="<?= $available ?>" required></label><label>Method<input name="method" placeholder="Bank, FIB, cash"></label><label>Reference<input name="reference"></label><div class="form-row"><label>Period from<input type="date" name="period_start"></label><label>to<input type="date" name="period_end"></label></div><button class="button small primary">Create pending payout</button></form></details><?php else: ?><span class="muted">No payout available</span><?php endif; ?></td></tr><?php endforeach; ?>
    </tbody></table></div><?php endif; ?>
  </section>
  <div class="content-grid equal">
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Revenue</p><h2>Commission ledger</h2></div></div><?php if ($commissions): ?><div class="stack-list"><?php foreach ($commissions as $commission): ?><article><div><strong><?= e($commission['name_en'] ?: $commission['name']) ?></strong><small>Booking UM-<?= short_id($commission['booking_id']) ?> · <?= format_date($commission['created_at']) ?></small></div><div class="stack-end"><strong><?= money($commission['amount_iqd']) ?></strong><?= badge($commission['status']) ?><?php if ($commission['status']==='owed'): action_form('commission_collect','finance',['id'=>$commission['id']],'Mark collected','button tiny primary'); endif; ?></div></article><?php endforeach; ?></div><?php else: empty_state('No commissions', 'Commission rows appear as bookings are paid.'); endif; ?></section>
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Transfers</p><h2>Recent payouts</h2></div></div><?php if ($payouts): ?><div class="stack-list"><?php foreach ($payouts as $payout): ?><article><div><strong><?= e($payout['name_en'] ?: $payout['name']) ?></strong><small><?= e($payout['method'] ?: 'Method pending') ?><?= $payout['reference']?' · '.e($payout['reference']):'' ?> · <?= format_date($payout['created_at']) ?></small></div><div class="stack-end"><strong><?= money($payout['amount_iqd']) ?></strong><?= badge($payout['status']) ?><?php if ($payout['status']==='pending'): action_form('payout_complete','finance',['id'=>$payout['id']],'Complete','button tiny primary','Post this payout permanently to the agency ledger?'); endif; ?></div></article><?php endforeach; ?></div><?php else: empty_state('No payouts yet', 'Create a payout from an agency’s positive available balance.'); endif; ?></section>
  </div>

<?php elseif ($section === 'support'):
    $messages = query_all("SELECT s.*, u.full_name FROM support_messages s LEFT JOIN users u ON u.id=s.user_id WHERE s.status <> 'closed' ORDER BY FIELD(s.status,'open','in_progress','resolved'), s.created_at DESC LIMIT 150");
?>
  <div class="section-toolbar"><p>Respond to pilgrim and agency questions, then document the resolution.</p><span class="summary-chip"><?= count(array_filter($messages,fn($m)=>in_array($m['status'],['open','in_progress'],true))) ?> open</span></div>
  <div class="message-list"><?php foreach ($messages as $message): ?><article class="message-card"><div class="message-meta"><span class="avatar small-avatar"><?= e(strtoupper(substr($message['full_name'] ?: ($message['email'] ?: '?'),0,1))) ?></span><div><strong><?= e($message['full_name'] ?: 'Guest') ?></strong><small><?= e($message['email'] ?: 'No email') ?> · <?= format_date($message['created_at'],true) ?></small></div><?= badge($message['status']) ?></div><p><?= nl2br(e($message['message'])) ?></p><?php if ($message['status']!=='resolved'): ?><form method="post" action="actions.php" class="resolve-form"><?php csrf_field(); ?><input type="hidden" name="action" value="support_resolve"><input type="hidden" name="return_section" value="support"><input type="hidden" name="id" value="<?= e($message['id']) ?>"><input name="note" placeholder="Resolution note (optional)"><button class="button small primary">Resolve</button></form><?php elseif ($message['resolution_note']): ?><div class="resolution"><strong>Resolution</strong><?= e($message['resolution_note']) ?></div><?php endif; ?></article><?php endforeach; ?><?php if (!$messages) empty_state('Inbox clear', 'New support requests will appear here.'); ?></div>

<?php elseif ($section === 'moderation'):
    $reports = query_all("SELECT r.*, c.name, c.name_en, u.full_name AS reporter FROM agency_reports r JOIN companies c ON c.id=r.agency_id JOIN users u ON u.id=r.reporter_id WHERE r.status IN ('open','reviewing') ORDER BY r.created_at DESC");
    $reviews = query_all("SELECT r.*, c.name, c.name_en, u.full_name FROM reviews r JOIN companies c ON c.id=r.company_id JOIN users u ON u.id=r.client_id WHERE r.moderation_status IN ('flagged','hidden') OR r.flagged_reason IS NOT NULL ORDER BY r.created_at DESC LIMIT 100");
    $documents = query_all("SELECT d.*, c.name, c.name_en FROM agency_documents d JOIN companies c ON c.id=d.agency_id WHERE d.status='pending' ORDER BY d.created_at DESC");
    $identities = query_all("SELECT id,email,full_name,identity_status,identity_reason,passport_photo_url,selfie_photo_url,created_at FROM users WHERE identity_status='under_review' ORDER BY updated_at");
    $carousel = query_all("SELECT cr.*, c.name, c.name_en FROM carousel_requests cr JOIN companies c ON c.id=cr.agency_id WHERE cr.status='pending' ORDER BY cr.created_at DESC");
?>
  <div class="section-toolbar"><p>Resolve reports, verify documents, and keep public marketplace content trustworthy.</p></div>
  <div class="moderation-grid">
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Trust & safety</p><h2>Agency reports <span class="count-pill"><?= count($reports) ?></span></h2></div></div><?php if ($reports): ?><div class="moderation-list"><?php foreach ($reports as $report): ?><article><div class="moderation-title"><strong><?= e($report['name_en'] ?: $report['name']) ?></strong><?= badge($report['status']) ?></div><small>Reported by <?= e($report['reporter']) ?> · <?= format_date($report['created_at'],true) ?></small><h4><?= e(str_replace('_',' ',$report['reason'])) ?></h4><p><?= e($report['details']) ?></p><form method="post" action="actions.php" class="compact-form"><?php csrf_field(); ?><input type="hidden" name="action" value="report_resolve"><input type="hidden" name="return_section" value="moderation"><input type="hidden" name="id" value="<?= e($report['id']) ?>"><input name="note" placeholder="Resolution note"><button name="status" value="reviewing" class="button tiny ghost">Investigate</button><button name="status" value="resolved" class="button tiny primary">Resolve</button><button name="status" value="dismissed" class="button tiny danger-ghost">Dismiss</button></form></article><?php endforeach; ?></div><?php else: empty_state('No open reports', 'The agency report queue is clear.'); endif; ?></section>
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Compliance</p><h2>Agency documents <span class="count-pill"><?= count($documents) ?></span></h2></div></div><?php if ($documents): ?><div class="moderation-list"><?php foreach ($documents as $document): ?><article><div class="moderation-title"><strong><?= e($document['name_en'] ?: $document['name']) ?></strong><?= badge($document['status']) ?></div><small><?= e(str_replace('_',' ',$document['document_type'])) ?> · <?= e($document['file_name']) ?></small><div class="button-row"><a class="button tiny ghost" href="download.php?type=agency&id=<?= e($document['id']) ?>" target="_blank">View file</a></div><form method="post" action="actions.php" class="compact-form"><?php csrf_field(); ?><input type="hidden" name="action" value="agency_document_review"><input type="hidden" name="return_section" value="moderation"><input type="hidden" name="id" value="<?= e($document['id']) ?>"><input name="reason" placeholder="Feedback if rejected"><button name="status" value="approved" class="button tiny primary">Approve</button><button name="status" value="rejected" class="button tiny danger-ghost">Reject</button></form></article><?php endforeach; ?></div><?php else: empty_state('Documents clear', 'There are no agency documents awaiting review.'); endif; ?></section>
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Identity</p><h2>Pilgrim verification <span class="count-pill"><?= count($identities) ?></span></h2></div></div><?php if ($identities): ?><div class="moderation-list"><?php foreach ($identities as $identity): ?><article><div class="moderation-title"><strong><?= e($identity['full_name']) ?></strong><?= badge($identity['identity_status']) ?></div><small><?= e($identity['email']) ?></small><div class="button-row"><a class="button tiny ghost" href="download.php?type=identity&id=<?= e($identity['id']) ?>&kind=passport" target="_blank">Passport</a><a class="button tiny ghost" href="download.php?type=identity&id=<?= e($identity['id']) ?>&kind=selfie" target="_blank">Selfie</a></div><form method="post" action="actions.php" class="compact-form"><?php csrf_field(); ?><input type="hidden" name="action" value="identity_review"><input type="hidden" name="return_section" value="moderation"><input type="hidden" name="id" value="<?= e($identity['id']) ?>"><input name="reason" placeholder="Reason if rejected"><button name="status" value="approved" class="button tiny primary">Approve</button><button name="status" value="rejected" class="button tiny danger-ghost">Reject</button></form></article><?php endforeach; ?></div><?php else: empty_state('Identity queue clear', 'There are no identity submissions awaiting review.'); endif; ?></section>
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Paid placement</p><h2>Carousel requests <span class="count-pill"><?= count($carousel) ?></span></h2></div></div><?php if ($carousel): ?><div class="moderation-list"><?php foreach ($carousel as $request): ?><article><div class="moderation-title"><strong><?= e($request['title']) ?></strong><?= badge($request['status']) ?></div><small><?= e($request['name_en'] ?: $request['name']) ?> · <?= (int)$request['requested_days'] ?> days · <?= money($request['price_iqd']) ?></small><form method="post" action="actions.php" class="compact-form"><?php csrf_field(); ?><input type="hidden" name="action" value="carousel_review"><input type="hidden" name="return_section" value="moderation"><input type="hidden" name="id" value="<?= e($request['id']) ?>"><input name="reason" placeholder="Review note"><button name="status" value="approved" class="button tiny primary">Approve & publish</button><button name="status" value="rejected" class="button tiny danger-ghost">Reject</button></form></article><?php endforeach; ?></div><?php else: empty_state('No ad requests', 'There are no pending carousel requests.'); endif; ?></section>
  </div>
  <?php if ($reviews): ?><section class="panel"><div class="panel-head"><div><p class="eyebrow">Public reviews</p><h2>Flagged and hidden reviews</h2></div></div><div class="table-wrap"><table><thead><tr><th>Review</th><th>Agency</th><th>Author</th><th>Status</th><th>Moderate</th></tr></thead><tbody><?php foreach ($reviews as $review): ?><tr><td><strong><?= str_repeat('★',(int)$review['rating']) ?></strong><small><?= e($review['comment']) ?></small></td><td><?= e($review['name_en'] ?: $review['name']) ?></td><td><?= e($review['full_name']) ?></td><td><?= badge($review['moderation_status']) ?></td><td><form method="post" action="actions.php" class="inline-form"><?php csrf_field(); ?><input type="hidden" name="action" value="review_moderate"><input type="hidden" name="return_section" value="moderation"><input type="hidden" name="id" value="<?= e($review['id']) ?>"><button class="button tiny primary" name="status" value="visible">Show</button><button class="button tiny danger-ghost" name="status" value="hidden">Hide</button></form></td></tr><?php endforeach; ?></tbody></table></div></section><?php endif; ?>

<?php elseif ($section === 'ads'):
    $ads = query_all('SELECT a.*, c.name AS company_name, c.name_en AS company_en, p.title AS package_title, p.title_en AS package_en FROM home_ads a LEFT JOIN companies c ON c.id=a.company_id LEFT JOIN packages p ON p.id=a.package_id ORDER BY a.sort_order,a.created_at DESC');
    $companies = query_all("SELECT id,name,name_en FROM companies WHERE is_verified=1 AND status='active' ORDER BY name");
    $packages = query_all("SELECT id,title,title_en FROM packages WHERE lifecycle_status='published' ORDER BY departure_date");
?>
  <div class="content-grid one-two">
    <section class="panel sticky-panel"><div class="panel-head"><div><p class="eyebrow">New placement</p><h2>Create home ad</h2></div></div><form method="post" action="actions.php" class="settings-form"><?php csrf_field(); ?><input type="hidden" name="action" value="ad_create"><input type="hidden" name="return_section" value="ads"><label>Title<input name="title" required maxlength="255"></label><label>Agency<select name="company_id"><option value="">None</option><?php foreach($companies as $company): ?><option value="<?= e($company['id']) ?>"><?= e($company['name_en'] ?: $company['name']) ?></option><?php endforeach; ?></select></label><label>Linked package<select name="package_id"><option value="">None</option><?php foreach($packages as $package): ?><option value="<?= e($package['id']) ?>"><?= e($package['title_en'] ?: $package['title']) ?></option><?php endforeach; ?></select></label><label>Sort order<input type="number" name="sort_order" value="0"></label><button class="button primary">Create placement</button></form></section>
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Home carousel</p><h2>Current placements</h2></div><span class="count-pill"><?= count($ads) ?></span></div><?php if($ads): ?><div class="ad-grid"><?php foreach($ads as $ad): ?><article class="ad-card"><?php if($ad['image_url']): ?><img src="<?= e($ad['image_url']) ?>" alt=""><?php else: ?><div class="ad-placeholder">ط</div><?php endif; ?><div><div class="moderation-title"><h3><?= e($ad['title']) ?></h3><?= badge($ad['is_active']?'active':'paused') ?></div><p><?= e($ad['package_en'] ?: ($ad['package_title'] ?: 'General placement')) ?></p><small><?= e($ad['company_en'] ?: ($ad['company_name'] ?: 'Tawaf')) ?> · Position <?= (int)$ad['sort_order'] ?></small><div class="button-row"><?php action_form('ad_toggle','ads',['id'=>$ad['id'],'value'=>$ad['is_active']?'0':'1'],$ad['is_active']?'Pause':'Activate','button tiny ghost'); ?><?php action_form('ad_delete','ads',['id'=>$ad['id']],'Delete','button tiny danger-ghost','Delete this home ad?'); ?></div></div></article><?php endforeach; ?></div><?php else: empty_state('No home ads', 'Create a placement or approve an agency carousel request.'); endif; ?></section>
  </div>

<?php elseif ($section === 'audit'):
    $logs = query_all('SELECT a.*, u.full_name, u.email FROM audit_logs a LEFT JOIN users u ON u.id=a.actor_id ORDER BY a.created_at DESC LIMIT 250');
?>
  <div class="section-toolbar"><p>Immutable record of sensitive administrator and API actions.</p><span class="summary-chip">Latest <?= count($logs) ?> events</span></div>
  <section class="panel"><?php if($logs): ?><div class="table-wrap"><table><thead><tr><th>Time</th><th>Actor</th><th>Action</th><th>Entity</th><th>Note</th><th>IP</th></tr></thead><tbody><?php foreach($logs as $log): ?><tr><td><?= format_date($log['created_at'],true) ?></td><td><strong><?= e($log['full_name'] ?: ucfirst($log['actor_role'])) ?></strong><small><?= e($log['email'] ?: $log['actor_role']) ?></small></td><td><span class="action-chip"><?= e(str_replace('_',' ',$log['action'])) ?></span></td><td><?= e($log['entity_type']) ?><small><?= e(short_id($log['entity_id'])) ?></small></td><td><?= e($log['note'] ?: '—') ?></td><td><code><?= e($log['ip_address'] ?: '—') ?></code></td></tr><?php endforeach; ?></tbody></table></div><?php else: empty_state('No audit events', 'Sensitive activity will be recorded here.'); endif; ?></section>

<?php elseif ($section === 'settings'):
    $settingsRows = query_all('SELECT * FROM system_settings ORDER BY setting_key');
    $settings = [];
    foreach($settingsRows as $row) $settings[$row['setting_key']]=$row['setting_value'];
?>
  <div class="content-grid equal settings-grid">
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Marketplace</p><h2>Platform configuration</h2></div></div><form method="post" action="actions.php" class="settings-form"><?php csrf_field(); ?><input type="hidden" name="action" value="settings_update"><input type="hidden" name="return_section" value="settings"><label>Default commission rate<input type="number" name="platform_commission_rate" min="0" max="1" step="0.0001" value="<?= e($settings['platform_commission_rate']??'0.05') ?>"><small>Enter 0.05 for five percent.</small></label><label>Booking request expiry (hours)<input type="number" name="booking_request_expiry_hours" min="1" max="168" value="<?= e($settings['booking_request_expiry_hours']??'24') ?>"></label><label>Support email<input type="email" name="support_email" value="<?= e($settings['support_email']??'support@707222.xyz') ?>"></label><label>Maintenance mode<select name="maintenance_mode"><option value="false" <?= ($settings['maintenance_mode']??'false')==='false'?'selected':'' ?>>Off — app available</option><option value="true" <?= ($settings['maintenance_mode']??'false')==='true'?'selected':'' ?>>On — maintenance</option></select></label><button class="button primary">Save platform settings</button></form></section>
    <section class="panel"><div class="panel-head"><div><p class="eyebrow">Security</p><h2>Administrator password</h2></div></div><form method="post" action="actions.php" class="settings-form"><?php csrf_field(); ?><input type="hidden" name="action" value="change_password"><input type="hidden" name="return_section" value="settings"><label>Current password<input type="password" name="current_password" required autocomplete="current-password"></label><label>New password<input type="password" name="new_password" required minlength="12" autocomplete="new-password"><small>At least 12 characters, including a letter and a number.</small></label><label>Confirm new password<input type="password" name="confirm_password" required minlength="12" autocomplete="new-password"></label><button class="button primary">Change password</button></form><div class="security-note"><strong>Signed in as <?= e($admin['email']) ?></strong><p>Last sign-in: <?= format_date($admin['last_login_at'],true) ?>. App API sessions are revoked when this password changes.</p></div></section>
  </div>
  <section class="panel deployment-panel"><div><p class="eyebrow">Deployment</p><h2>Connected services</h2></div><div class="service-cards"><article><span class="live-dot"></span><div><strong>PHP API</strong><small><?= e(config('app_url')) ?></small></div></article><article><span class="live-dot"></span><div><strong>MySQL database</strong><small><?= e(config('db.name')) ?> on <?= e(config('db.host')) ?></small></div></article><article><span class="live-dot"></span><div><strong>Admin dashboard</strong><small><?= e(config('admin_url')) ?></small></div></article></div></section>
<?php endif; ?>

<?php render_footer(); ?>
