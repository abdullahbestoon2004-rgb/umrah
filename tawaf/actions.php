<?php
declare(strict_types=1);

require __DIR__ . '/includes/bootstrap.php';

$admin = require_admin_dashboard();
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    http_response_code(405);
    exit('Method not allowed');
}
verify_csrf();

$action = (string) ($_POST['action'] ?? '');
$section = (string) ($_POST['return_section'] ?? 'dashboard');

try {
    switch ($action) {
        case 'company_review':
            $id = required_string($_POST, 'id', 36);
            $decision = required_string($_POST, 'decision', 30);
            $reason = nullable_string($_POST, 'reason');
            if (!in_array($decision, ['approved', 'rejected', 'needs_changes'], true)) throw new DomainException('Invalid company decision.');
            if ($decision !== 'approved' && $reason === null) throw new DomainException('Add a reason for the agency.');
            $before = query_one('SELECT * FROM companies WHERE id = ?', [$id]);
            if ($before === null) throw new DomainException('Agency not found.');
            $status = $decision === 'approved' ? 'active' : ($decision === 'rejected' ? 'rejected' : 'pending');
            execute_sql('UPDATE companies SET verification_status = ?, verification_reason = ?, is_verified = ?, status = ?, reviewed_by = ?, reviewed_at = UTC_TIMESTAMP() WHERE id = ?', [$decision, $reason, $decision === 'approved' ? 1 : 0, $status, $admin['id'], $id]);
            execute_sql('INSERT INTO agency_status_history (id, agency_id, old_status, new_status, reason, changed_by) VALUES (?, ?, ?, ?, ?, ?)', [uuid_v4(), $id, $before['verification_status'], $decision, $reason, $admin['id']]);
            admin_audit($admin, 'company', $id, 'reviewed', $before, ['verification_status' => $decision], $reason);
            set_flash('success', 'Agency review saved.');
            break;

        case 'company_toggle':
            $id = required_string($_POST, 'id', 36);
            $field = ($_POST['field'] ?? '') === 'is_promoted' ? 'is_promoted' : 'is_active';
            $value = !empty($_POST['value']) ? 1 : 0;
            execute_sql("UPDATE companies SET {$field} = ? WHERE id = ?", [$value, $id]);
            admin_audit($admin, 'company', $id, $field . '_changed', null, [$field => (bool) $value]);
            set_flash('success', 'Agency setting updated.');
            break;

        case 'package_review':
            $id = required_string($_POST, 'id', 36);
            $decision = required_string($_POST, 'decision', 30);
            $reason = nullable_string($_POST, 'reason');
            if (!in_array($decision, ['approved', 'needs_changes', 'paused'], true)) throw new DomainException('Invalid package decision.');
            if ($decision !== 'approved' && $reason === null) throw new DomainException('Add a reason for the agency.');
            $lifecycle = $decision === 'approved' ? 'published' : ($decision === 'paused' ? 'paused' : 'needs_changes');
            execute_sql('UPDATE packages SET lifecycle_status = ?, is_published = ?, review_reason = ?, force_unpublish_reason = ?, reviewed_by = ?, reviewed_at = UTC_TIMESTAMP() WHERE id = ?', [$lifecycle, $decision === 'approved' ? 1 : 0, $reason, $decision === 'paused' ? $reason : null, $admin['id'], $id]);
            admin_audit($admin, 'package', $id, 'reviewed', null, ['decision' => $decision], $reason);
            set_flash('success', 'Package review saved.');
            break;

        case 'package_feature':
            $id = required_string($_POST, 'id', 36);
            $value = !empty($_POST['value']) ? 1 : 0;
            execute_sql('UPDATE packages SET is_featured = ? WHERE id = ?', [$value, $id]);
            admin_audit($admin, 'package', $id, $value ? 'featured' : 'unfeatured');
            set_flash('success', 'Featured placement updated.');
            break;

        case 'booking_stage':
            $id = required_string($_POST, 'id', 36);
            $stage = required_string($_POST, 'stage', 40);
            $allowed = ['requested','needs_information','awaiting_payment','confirmed','ready','in_progress','completed','cancelled','rejected','expired'];
            if (!in_array($stage, $allowed, true)) throw new DomainException('Invalid booking stage.');
            $booking = query_one('SELECT * FROM bookings WHERE id = ?', [$id]);
            if ($booking === null) throw new DomainException('Booking not found.');
            $status = in_array($stage, ['confirmed','ready','in_progress'], true) ? 'confirmed' : (in_array($stage, ['cancelled','rejected','expired'], true) ? 'cancelled' : ($stage === 'completed' ? 'completed' : 'pending'));
            execute_sql('UPDATE bookings SET operational_stage = ?, status = ?, status_reason = ? WHERE id = ?', [$stage, $status, nullable_string($_POST, 'reason'), $id]);
            admin_audit($admin, 'booking', $id, 'stage_overridden', ['stage' => $booking['operational_stage']], ['stage' => $stage], nullable_string($_POST, 'reason'));
            set_flash('success', 'Booking stage updated.');
            break;

        case 'commission_collect':
            $id = required_string($_POST, 'id', 36);
            execute_sql("UPDATE commissions SET status = 'collected', collected_at = UTC_TIMESTAMP() WHERE id = ?", [$id]);
            admin_audit($admin, 'commission', $id, 'collected');
            set_flash('success', 'Commission marked collected.');
            break;

        case 'payout_create':
            $companyId = required_string($_POST, 'company_id', 36);
            $amount = (int) ($_POST['amount_iqd'] ?? 0);
            if ($amount <= 0) throw new DomainException('Enter a positive payout amount.');
            $balance = query_one('SELECT COALESCE(SUM(amount_iqd), 0) AS amount FROM agency_ledger WHERE company_id = ?', [$companyId]);
            $pending = query_one("SELECT COALESCE(SUM(amount_iqd), 0) AS amount FROM payouts WHERE company_id = ? AND status = 'pending'", [$companyId]);
            if ($amount > (int) ($balance['amount'] ?? 0) - (int) ($pending['amount'] ?? 0)) throw new DomainException('Payout exceeds the agency’s available balance.');
            $id = uuid_v4();
            execute_sql('INSERT INTO payouts (id, company_id, amount_iqd, method, reference, status, period_start, period_end, created_by) VALUES (?, ?, ?, ?, ?, \'pending\', ?, ?, ?)', [$id, $companyId, $amount, nullable_string($_POST, 'method', 80), nullable_string($_POST, 'reference', 190), $_POST['period_start'] ?: null, $_POST['period_end'] ?: null, $admin['id']]);
            admin_audit($admin, 'payout', $id, 'created', null, ['amount_iqd' => $amount]);
            set_flash('success', 'Payout created in pending state.');
            break;

        case 'payout_complete':
            $id = required_string($_POST, 'id', 36);
            $payout = query_one("SELECT * FROM payouts WHERE id = ? AND status = 'pending'", [$id]);
            if ($payout === null) throw new DomainException('Pending payout not found.');
            $pdo = db();
            $pdo->beginTransaction();
            execute_sql("UPDATE payouts SET status = 'completed', completed_at = UTC_TIMESTAMP(), reference = COALESCE(?, reference) WHERE id = ?", [nullable_string($_POST, 'reference', 190), $id]);
            execute_sql("INSERT INTO agency_ledger (id, company_id, payout_id, entry_type, amount_iqd, description) VALUES (?, ?, ?, 'payout', ?, 'Agency payout completed')", [uuid_v4(), $payout['company_id'], $id, -(int) $payout['amount_iqd']]);
            $pdo->commit();
            admin_audit($admin, 'payout', $id, 'completed', $payout, ['status' => 'completed']);
            set_flash('success', 'Payout completed and posted to the ledger.');
            break;

        case 'support_resolve':
            $id = required_string($_POST, 'id', 36);
            execute_sql("UPDATE support_messages SET status = 'resolved', assigned_to = ?, resolution_note = ?, resolved_at = UTC_TIMESTAMP() WHERE id = ?", [$admin['id'], nullable_string($_POST, 'note'), $id]);
            admin_audit($admin, 'support_message', $id, 'resolved');
            set_flash('success', 'Support message resolved.');
            break;

        case 'review_moderate':
            $id = required_string($_POST, 'id', 36);
            $status = required_string($_POST, 'status', 30);
            if (!in_array($status, ['visible','hidden','flagged'], true)) throw new DomainException('Invalid moderation state.');
            execute_sql('UPDATE reviews SET moderation_status = ?, flagged_reason = ? WHERE id = ?', [$status, nullable_string($_POST, 'reason'), $id]);
            $review = query_one('SELECT company_id FROM reviews WHERE id = ?', [$id]);
            if ($review !== null) execute_sql("UPDATE companies SET rating = COALESCE((SELECT AVG(rating) FROM reviews WHERE company_id = ? AND moderation_status = 'visible'), 0), reviews = (SELECT COUNT(*) FROM reviews WHERE company_id = ? AND moderation_status = 'visible') WHERE id = ?", [$review['company_id'], $review['company_id'], $review['company_id']]);
            admin_audit($admin, 'review', $id, 'moderated', null, ['status' => $status], nullable_string($_POST, 'reason'));
            set_flash('success', 'Review moderation updated.');
            break;

        case 'report_resolve':
            $id = required_string($_POST, 'id', 36);
            $status = required_string($_POST, 'status', 30);
            if (!in_array($status, ['reviewing','resolved','dismissed'], true)) throw new DomainException('Invalid report state.');
            execute_sql('UPDATE agency_reports SET status = ?, resolution_note = ?, resolved_by = ?, resolved_at = IF(? IN (\'resolved\',\'dismissed\'), UTC_TIMESTAMP(), NULL) WHERE id = ?', [$status, nullable_string($_POST, 'note'), $admin['id'], $status, $id]);
            admin_audit($admin, 'agency_report', $id, 'status_changed', null, ['status' => $status]);
            set_flash('success', 'Agency report updated.');
            break;

        case 'ad_toggle':
            $id = required_string($_POST, 'id', 36);
            $value = !empty($_POST['value']) ? 1 : 0;
            execute_sql('UPDATE home_ads SET is_active = ? WHERE id = ?', [$value, $id]);
            admin_audit($admin, 'home_ad', $id, $value ? 'activated' : 'deactivated');
            set_flash('success', 'Home ad updated.');
            break;

        case 'ad_create':
            $id = uuid_v4();
            execute_sql('INSERT INTO home_ads (id, company_id, package_id, title, sort_order, is_active, created_by) VALUES (?, ?, ?, ?, ?, 1, ?)', [
                $id, ($_POST['company_id'] ?? '') !== '' ? $_POST['company_id'] : null,
                ($_POST['package_id'] ?? '') !== '' ? $_POST['package_id'] : null,
                required_string($_POST, 'title', 255), (int) ($_POST['sort_order'] ?? 0), $admin['id'],
            ]);
            admin_audit($admin, 'home_ad', $id, 'created');
            set_flash('success', 'Home ad created. Add its image from the Flutter admin tools or the API.');
            break;

        case 'ad_delete':
            $id = required_string($_POST, 'id', 36);
            execute_sql('DELETE FROM home_ads WHERE id = ?', [$id]);
            admin_audit($admin, 'home_ad', $id, 'deleted');
            set_flash('success', 'Home ad deleted.');
            break;

        case 'user_status':
            $id = required_string($_POST, 'id', 36);
            $status = required_string($_POST, 'status', 30);
            if ($id === $admin['id']) throw new DomainException('You cannot suspend your own administrator account.');
            if (!in_array($status, ['active','suspended'], true)) throw new DomainException('Invalid user state.');
            execute_sql('UPDATE users SET status = ? WHERE id = ?', [$status, $id]);
            if ($status === 'suspended') execute_sql('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_id = ?', [$id]);
            admin_audit($admin, 'user', $id, 'status_changed', null, ['status' => $status]);
            set_flash('success', 'User status updated.');
            break;

        case 'identity_review':
            $id = required_string($_POST, 'id', 36);
            $status = required_string($_POST, 'status', 30);
            if (!in_array($status, ['approved','rejected'], true)) throw new DomainException('Invalid identity decision.');
            $reason = nullable_string($_POST, 'reason');
            if ($status === 'rejected' && $reason === null) throw new DomainException('Add a rejection reason.');
            execute_sql('UPDATE users SET identity_status = ?, identity_reason = ? WHERE id = ?', [$status, $reason, $id]);
            admin_audit($admin, 'user', $id, 'identity_reviewed', null, ['status' => $status], $reason);
            set_flash('success', 'Identity review saved.');
            break;

        case 'agency_document_review':
            $id = required_string($_POST, 'id', 36);
            $status = required_string($_POST, 'status', 30);
            if (!in_array($status, ['approved','rejected'], true)) throw new DomainException('Invalid document decision.');
            execute_sql('UPDATE agency_documents SET status = ?, admin_feedback = ?, reviewed_by = ?, reviewed_at = UTC_TIMESTAMP() WHERE id = ?', [$status, nullable_string($_POST, 'reason'), $admin['id'], $id]);
            admin_audit($admin, 'agency_document', $id, 'reviewed', null, ['status' => $status]);
            set_flash('success', 'Agency document reviewed.');
            break;

        case 'carousel_review':
            $id = required_string($_POST, 'id', 36);
            $status = required_string($_POST, 'status', 30);
            if (!in_array($status, ['approved','rejected'], true)) throw new DomainException('Invalid carousel decision.');
            $request = query_one('SELECT * FROM carousel_requests WHERE id = ?', [$id]);
            if ($request === null) throw new DomainException('Carousel request not found.');
            $pdo = db();
            $pdo->beginTransaction();
            execute_sql('UPDATE carousel_requests SET status = ?, reviewed_by = ?, review_note = ?, starts_at = IF(? = \'approved\', UTC_TIMESTAMP(), NULL), ends_at = IF(? = \'approved\', DATE_ADD(UTC_TIMESTAMP(), INTERVAL requested_days DAY), NULL) WHERE id = ?', [$status, $admin['id'], nullable_string($_POST, 'reason'), $status, $status, $id]);
            if ($status === 'approved') {
                execute_sql('INSERT INTO home_ads (id, company_id, package_id, title, sort_order, is_active, starts_at, ends_at, created_by) VALUES (?, ?, ?, ?, 0, 1, UTC_TIMESTAMP(), DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY), ?)', [uuid_v4(), $request['agency_id'], $request['package_id'], $request['title'], $request['requested_days'], $admin['id']]);
            }
            $pdo->commit();
            admin_audit($admin, 'carousel_request', $id, 'reviewed', $request, ['status' => $status]);
            set_flash('success', 'Carousel request reviewed.');
            break;

        case 'settings_update':
            foreach (['platform_commission_rate','booking_request_expiry_hours','maintenance_mode','support_email'] as $key) {
                if (!array_key_exists($key, $_POST)) continue;
                execute_sql('UPDATE system_settings SET setting_value = ?, updated_by = ? WHERE setting_key = ?', [trim((string) $_POST[$key]), $admin['id'], $key]);
                admin_audit($admin, 'system_setting', null, 'updated', null, [$key => $_POST[$key]]);
            }
            set_flash('success', 'Platform settings saved.');
            break;

        case 'change_password':
            $record = query_one('SELECT password_hash FROM users WHERE id = ?', [$admin['id']]);
            if ($record === null || !password_verify((string) ($_POST['current_password'] ?? ''), $record['password_hash'])) throw new DomainException('Current password is incorrect.');
            $password = (string) ($_POST['new_password'] ?? '');
            if (strlen($password) < 12 || !preg_match('/[A-Za-z]/', $password) || !preg_match('/\d/', $password)) throw new DomainException('New password must be at least 12 characters and contain a letter and a number.');
            if ($password !== (string) ($_POST['confirm_password'] ?? '')) throw new DomainException('The new passwords do not match.');
            execute_sql('UPDATE users SET password_hash = ?, force_password_change = 0 WHERE id = ?', [password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]), $admin['id']]);
            execute_sql('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_id = ?', [$admin['id']]);
            admin_audit($admin, 'user', $admin['id'], 'admin_password_changed');
            set_flash('success', 'Administrator password changed.');
            break;

        default:
            throw new DomainException('Unknown dashboard action.');
    }
} catch (DomainException $error) {
    if (db()->inTransaction()) db()->rollBack();
    set_flash('danger', $error->getMessage());
} catch (Throwable $error) {
    if (db()->inTransaction()) db()->rollBack();
    error_log((string) $error);
    set_flash('danger', 'The action could not be completed. Check the server error log.');
}

redirect_dashboard($section);
