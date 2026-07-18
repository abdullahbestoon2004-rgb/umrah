<?php
declare(strict_types=1);

require dirname(__DIR__) . '/app/bootstrap.php';
require dirname(__DIR__) . '/app/payments.php';

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowedOrigins = [
    'https://707222.xyz',
    'https://www.707222.xyz',
    'http://localhost',
    'http://127.0.0.1',
];
if ($origin !== '' && (in_array($origin, $allowedOrigins, true) || preg_match('#^http://(localhost|127\.0\.0\.1):\d+$#', $origin))) {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Vary: Origin');
}
header('Access-Control-Allow-Headers: Authorization, Content-Type, X-Requested-With');
header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$route = trim((string) ($_GET['route'] ?? $_SERVER['PATH_INFO'] ?? ''), '/');
if ($route === '') {
    $route = 'health';
}

switch ($route) {
    case 'health':
        require_method('GET');
        $database = 'ok';
        try {
            db()->query('SELECT 1');
        } catch (Throwable) {
            $database = 'unavailable';
        }
        api_ok(['service' => 'Tawaf API', 'database' => $database, 'time' => gmdate(DATE_ATOM)]);

    // ------------------------------------------------------------------
    // Authentication and account
    // ------------------------------------------------------------------
    case 'auth/register':
        require_method('POST');
        $input = json_input();
        $email = strtolower(required_string($input, 'email', 190));
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            api_error('Please enter a valid email address.', 422);
        }
        $password = (string) ($input['password'] ?? '');
        if (strlen($password) < 10 || !preg_match('/[A-Za-z]/', $password) || !preg_match('/\d/', $password)) {
            api_error('Password must be at least 10 characters and include a letter and a number.', 422);
        }
        $role = ($input['role'] ?? 'client') === 'agency' ? 'agency' : 'client';
        $fullName = required_string($input, 'full_name', 190);
        $phone = trim((string) ($input['phone'] ?? ''));
        if (query_one('SELECT id FROM users WHERE email = ?', [$email]) !== null) {
            api_error('An account with this email already exists.', 409, 'email_exists');
        }
        $userId = uuid_v4();
        $pdo = db();
        $pdo->beginTransaction();
        try {
            execute_sql('INSERT INTO users (id, email, password_hash, role, full_name, phone, email_verified_at) VALUES (?, ?, ?, ?, ?, ?, UTC_TIMESTAMP())', [
                $userId, $email, password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]), $role, $fullName, $phone,
            ]);
            if ($role === 'agency') {
                $companyName = required_string($input, 'company_name', 190);
                execute_sql('INSERT INTO companies (id, owner_id, name, name_en, location, about, since, accepted_payment_methods, tags, branches, gallery_urls, verification_details) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    uuid_v4(), $userId, $companyName, $companyName,
                    trim((string) ($input['company_location'] ?? '')),
                    trim((string) ($input['company_about'] ?? '')),
                    isset($input['company_since']) ? (int) $input['company_since'] : null,
                    json_encode(['cash']), '[]', '[]', '[]', '[]',
                ]);
            }
            $token = issue_token($userId, 'Flutter app');
            $pdo->commit();
        } catch (Throwable $error) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            throw $error;
        }
        audit_log('user', $userId, 'registered', null, ['role' => $role]);
        api_ok(['token' => $token, 'user' => normalize_row([
            'id' => $userId, 'email' => $email, 'role' => $role,
            'full_name' => $fullName, 'phone' => $phone,
        ])], 201);

    case 'auth/login':
        require_method('POST');
        $input = json_input();
        $email = strtolower(required_string($input, 'email', 190));
        $password = (string) ($input['password'] ?? '');
        enforce_rate_limit('login', $email, (int) config('auth.max_login_attempts'), (int) config('auth.login_window_minutes'));
        $user = query_one('SELECT * FROM users WHERE email = ? LIMIT 1', [$email]);
        if ($user === null || $user['status'] !== 'active' || !password_verify($password, $user['password_hash'])) {
            audit_log('user', $user['id'] ?? null, 'login_failed', null, ['email' => $email]);
            api_error('Invalid email or password.', 401, 'invalid_credentials');
        }
        clear_rate_limit('login', $email);
        if (password_needs_rehash($user['password_hash'], PASSWORD_BCRYPT, ['cost' => 12])) {
            execute_sql('UPDATE users SET password_hash = ? WHERE id = ?', [password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]), $user['id']]);
        }
        execute_sql('UPDATE users SET last_login_at = UTC_TIMESTAMP() WHERE id = ?', [$user['id']]);
        $token = issue_token($user['id'], trim((string) ($input['device_label'] ?? 'Flutter app')));
        audit_log('user', $user['id'], 'login');
        api_ok(['token' => $token, 'user' => normalize_row([
            'id' => $user['id'], 'email' => $user['email'], 'role' => $user['role'],
            'full_name' => $user['full_name'], 'phone' => $user['phone'],
            'force_password_change' => $user['force_password_change'],
        ])]);

    case 'auth/me':
        require_method('GET');
        $user = current_user();
        unset($user['session_id']);
        api_ok($user);

    case 'auth/logout':
        require_method('POST');
        $user = current_user();
        execute_sql('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP() WHERE id = ?', [$user['session_id']]);
        audit_log('user', $user['id'], 'logout');
        api_ok();

    case 'auth/profile':
        require_method('PATCH', 'PUT');
        $user = current_user();
        $input = json_input();
        update_allowed_fields('users', $user['id'], $input, ['full_name', 'phone']);
        audit_log('user', $user['id'], 'profile_updated');
        api_ok();

    case 'auth/email':
        require_method('PATCH', 'PUT');
        $user = current_user();
        $input = json_input();
        $email = strtolower(required_string($input, 'email', 190));
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            api_error('Please enter a valid email address.', 422);
        }
        if (query_one('SELECT id FROM users WHERE email = ? AND id <> ?', [$email, $user['id']]) !== null) {
            api_error('This email address is already in use.', 409);
        }
        execute_sql('UPDATE users SET email = ?, email_verified_at = UTC_TIMESTAMP() WHERE id = ?', [$email, $user['id']]);
        audit_log('user', $user['id'], 'email_updated', null, ['email' => $email]);
        api_ok();

    case 'auth/reauthenticate':
        require_method('POST');
        $user = current_user();
        $input = json_input();
        $record = query_one('SELECT password_hash FROM users WHERE id = ?', [$user['id']]);
        if ($record === null || !password_verify((string) ($input['password'] ?? ''), $record['password_hash'])) {
            api_error('The current password is incorrect.', 401, 'invalid_password');
        }
        api_ok();

    case 'auth/password':
        require_method('PATCH', 'PUT');
        $user = current_user();
        $input = json_input();
        $password = (string) ($input['password'] ?? '');
        if (strlen($password) < 10 || !preg_match('/[A-Za-z]/', $password) || !preg_match('/\d/', $password)) {
            api_error('Password must be at least 10 characters and include a letter and a number.', 422);
        }
        execute_sql('UPDATE users SET password_hash = ?, force_password_change = 0 WHERE id = ?', [password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]), $user['id']]);
        execute_sql('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_id = ? AND id <> ?', [$user['id'], $user['session_id']]);
        audit_log('user', $user['id'], 'password_changed');
        api_ok();

    case 'auth/delete':
        require_method('DELETE', 'POST');
        $user = current_user();
        if ($user['role'] === 'admin') {
            api_error('Administrator accounts must be disabled by another administrator.', 422);
        }
        execute_sql('UPDATE users SET status = \'deleted\', email = CONCAT(\'deleted-\', id, \'@invalid.local\'), phone = \'\', full_name = \'Deleted user\', password_hash = ? WHERE id = ?', [password_hash(bin2hex(random_bytes(32)), PASSWORD_BCRYPT), $user['id']]);
        execute_sql('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_id = ?', [$user['id']]);
        audit_log('user', $user['id'], 'account_deleted');
        api_ok();

    case 'auth/password/forgot':
        require_method('POST');
        $input = json_input();
        $email = strtolower(required_string($input, 'email', 190));
        enforce_rate_limit('password_reset', $email, 4, 30);
        $user = query_one('SELECT id FROM users WHERE email = ? AND status = \'active\'', [$email]);
        if ($user !== null) {
            $code = (string) random_int(100000, 999999);
            execute_sql('UPDATE password_resets SET used_at = UTC_TIMESTAMP() WHERE user_id = ? AND used_at IS NULL', [$user['id']]);
            execute_sql('INSERT INTO password_resets (id, user_id, code_hash, expires_at) VALUES (?, ?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? MINUTE))', [
                uuid_v4(), $user['id'], hash('sha256', $code), (int) config('auth.reset_code_minutes'),
            ]);
            send_reset_email($email, $code);
            if (config('app_env') === 'development') {
                api_ok(['development_code' => $code]);
            }
        }
        api_ok();

    case 'auth/password/reset':
        require_method('POST');
        $input = json_input();
        $email = strtolower(required_string($input, 'email', 190));
        $code = required_string($input, 'code', 12);
        $password = (string) ($input['password'] ?? '');
        if (strlen($password) < 10 || !preg_match('/[A-Za-z]/', $password) || !preg_match('/\d/', $password)) {
            api_error('Password must be at least 10 characters and include a letter and a number.', 422);
        }
        $reset = query_one('SELECT pr.*, u.id AS target_user_id FROM password_resets pr JOIN users u ON u.id = pr.user_id WHERE u.email = ? AND pr.used_at IS NULL AND pr.expires_at > UTC_TIMESTAMP() ORDER BY pr.created_at DESC LIMIT 1', [$email]);
        if ($reset === null || (int) $reset['attempts'] >= 5 || !hash_equals($reset['code_hash'], hash('sha256', $code))) {
            if ($reset !== null) {
                execute_sql('UPDATE password_resets SET attempts = attempts + 1 WHERE id = ?', [$reset['id']]);
            }
            api_error('The reset code is invalid or has expired.', 422, 'invalid_reset_code');
        }
        execute_sql('UPDATE users SET password_hash = ?, force_password_change = 0 WHERE id = ?', [password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]), $reset['target_user_id']]);
        execute_sql('UPDATE password_resets SET used_at = UTC_TIMESTAMP() WHERE id = ?', [$reset['id']]);
        execute_sql('UPDATE auth_sessions SET revoked_at = UTC_TIMESTAMP() WHERE user_id = ?', [$reset['target_user_id']]);
        audit_log('user', $reset['target_user_id'], 'password_reset');
        api_ok();

    case 'identity/submit':
        require_method('POST');
        $user = current_user();
        if (!isset($_FILES['passport'], $_FILES['selfie'])) {
            api_error('Passport and selfie images are required.', 422);
        }
        $passport = private_upload($_FILES['passport'], 'identity-' . $user['id']);
        $selfie = private_upload($_FILES['selfie'], 'identity-' . $user['id']);
        execute_sql('UPDATE users SET passport_photo_url = ?, selfie_photo_url = ?, identity_status = \'under_review\', identity_reason = NULL WHERE id = ?', [$passport['path'], $selfie['path'], $user['id']]);
        audit_log('user', $user['id'], 'identity_submitted');
        api_ok();

    // ------------------------------------------------------------------
    // Agencies and documents
    // ------------------------------------------------------------------
    case 'companies':
        require_method('GET');
        $rows = query_all("
            SELECT c.*
            FROM companies c
            WHERE c.is_active = 1
              AND c.is_verified = 1
              AND c.status = 'active'
              AND c.verification_status = 'approved'
            ORDER BY
              EXISTS (
                SELECT 1
                FROM packages p
                WHERE p.company_id = c.id
                  AND p.is_published = 1
                  AND p.lifecycle_status = 'published'
                  AND p.price_iqd > 0
                  AND p.departure_date >= CURRENT_DATE()
                  AND (p.capacity IS NULL OR p.seats_reserved < p.capacity)
              ) DESC,
              c.is_promoted DESC,
              CASE WHEN c.reviews > 0 THEN 1 ELSE 0 END DESC,
              c.rating DESC,
              c.reviews DESC,
              c.created_at DESC
        ");
        api_ok(hydrate_companies($rows));

    case 'companies/mine':
        require_method('GET');
        $user = current_user();
        $row = query_one('SELECT * FROM companies WHERE owner_id = ? LIMIT 1', [$user['id']]);
        if ($row === null) {
            $row = query_one('SELECT c.* FROM agency_staff s JOIN companies c ON c.id = s.company_id WHERE s.user_id = ? AND s.status = \'active\' LIMIT 1', [$user['id']]);
        }
        api_ok($row === null ? null : hydrate_company($row));

    case 'companies/create':
        require_method('POST');
        $user = require_role('agency');
        if (query_one('SELECT id FROM companies WHERE owner_id = ?', [$user['id']]) !== null) {
            api_error('This agency account already has a company.', 409);
        }
        $input = json_input();
        $id = uuid_v4();
        $name = required_string($input, 'name', 190);
        execute_sql('INSERT INTO companies (id, owner_id, name, name_en, location, about, since, tags, branches, gallery_urls, accepted_payment_methods, verification_details) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $id, $user['id'], $name, $name, trim((string) ($input['location'] ?? '')),
            trim((string) ($input['about'] ?? '')), isset($input['since']) ? (int) $input['since'] : null,
            '[]', '[]', '[]', json_encode(['cash']), '[]',
        ]);
        audit_log('company', $id, 'created');
        api_ok(company_row($id), 201);

    case 'companies/update':
        require_method('PATCH', 'PUT');
        $input = json_input();
        $id = required_string($input, 'id', 36);
        require_company_access($id, 'profile');
        $before = company_row($id);
        update_allowed_fields('companies', $id, $input, [
            'name', 'name_ar', 'name_en', 'location', 'about', 'about_ar', 'about_en',
            'tags' => 'json', 'since', 'tint', 'license_number', 'office_address',
            'phone', 'whatsapp', 'office_hours', 'branches' => 'json',
            'gallery_urls' => 'json', 'intro_video_url', 'cancellation_policy',
            'cancellation_policy_ar', 'cancellation_policy_en',
            'accepted_payment_methods' => 'json',
        ]);
        audit_log('company', $id, 'updated', $before, company_row($id));
        api_ok();

    case 'companies/logo':
    case 'companies/banner':
        require_method('POST');
        $id = required_string($_POST, 'company_id', 36);
        require_company_access($id, 'profile');
        if (!isset($_FILES['file'])) {
            api_error('An image is required.', 422);
        }
        $upload = public_upload($_FILES['file'], $route === 'companies/logo' ? 'company-logos' : 'company-banners');
        $field = $route === 'companies/logo' ? 'logo_url' : 'banner_url';
        execute_sql("UPDATE companies SET {$field} = ?, updated_at = UTC_TIMESTAMP() WHERE id = ?", [$upload['url'], $id]);
        audit_log('company', $id, $field . '_updated');
        api_ok(['url' => $upload['url']]);

    case 'companies/documents/upload':
        require_method('POST');
        $companyId = required_string($_POST, 'company_id', 36);
        require_company_access($companyId, 'documents');
        if (!isset($_FILES['file'])) {
            api_error('A document is required.', 422);
        }
        $upload = private_upload($_FILES['file'], 'agency-' . $companyId);
        $id = uuid_v4();
        execute_sql('INSERT INTO agency_documents (id, agency_id, document_type, storage_path, file_name, mime_type, file_size) VALUES (?, ?, ?, ?, ?, ?, ?)', [
            $id, $companyId, required_string($_POST, 'document_type', 80), $upload['path'], $upload['original_name'], $upload['mime'], $upload['size'],
        ]);
        audit_log('agency_document', $id, 'uploaded');
        api_ok(['id' => $id], 201);

    case 'companies/documents':
        require_method('GET');
        $companyId = required_string($_GET, 'company_id', 36);
        require_company_access($companyId, 'documents');
        $rows = query_all('SELECT * FROM agency_documents WHERE agency_id = ? ORDER BY created_at DESC', [$companyId]);
        foreach ($rows as &$row) {
            $expires = time() + 600;
            $signature = hash_hmac('sha256', $row['storage_path'] . '|' . $expires, (string) config('db.password'));
            $row['preview_url'] = config('app_url') . '/api/files/private?path=' . rawurlencode($row['storage_path']) . '&expires=' . $expires . '&sig=' . $signature;
        }
        api_ok(normalize_rows($rows));

    case 'companies/submit':
        require_method('POST');
        $input = json_input();
        $companyId = required_string($input, 'company_id', 36);
        require_company_access($companyId, 'profile');
        $documents = query_one('SELECT COUNT(*) AS total FROM agency_documents WHERE agency_id = ?', [$companyId]);
        if ((int) ($documents['total'] ?? 0) < 1) {
            api_error('Upload at least one licensing document before submitting.', 422);
        }
        execute_sql('UPDATE companies SET verification_status = \'pending\', status = \'pending\', verification_reason = NULL, submitted_at = UTC_TIMESTAMP() WHERE id = ?', [$companyId]);
        audit_log('company', $companyId, 'submitted_for_review');
        api_ok();

    case 'companies/pending':
        require_method('GET');
        require_role('admin');
        api_ok(hydrate_companies(query_all("SELECT * FROM companies WHERE verification_status IN ('pending','needs_changes') ORDER BY submitted_at DESC, created_at DESC")));

    case 'companies/review':
        require_method('POST');
        $admin = require_role('admin');
        $input = json_input();
        $companyId = required_string($input, 'company_id', 36);
        $decision = required_string($input, 'decision', 30);
        if (!in_array($decision, ['approved', 'rejected', 'needs_changes'], true)) {
            api_error('Invalid review decision.', 422);
        }
        $reason = nullable_string($input, 'reason');
        if ($decision !== 'approved' && $reason === null) {
            api_error('A reason is required for this decision.', 422);
        }
        $before = company_row($companyId);
        $status = $decision === 'approved' ? 'active' : ($decision === 'rejected' ? 'rejected' : 'pending');
        execute_sql('UPDATE companies SET verification_status = ?, verification_reason = ?, is_verified = ?, status = ?, reviewed_by = ?, reviewed_at = UTC_TIMESTAMP() WHERE id = ?', [
            $decision, $reason, $decision === 'approved' ? 1 : 0, $status, $admin['id'], $companyId,
        ]);
        execute_sql('INSERT INTO agency_status_history (id, agency_id, old_status, new_status, reason, changed_by) VALUES (?, ?, ?, ?, ?, ?)', [
            uuid_v4(), $companyId, $before['verification_status'] ?? null, $decision, $reason, $admin['id'],
        ]);
        audit_log('company', $companyId, 'reviewed', $before, company_row($companyId), $reason);
        api_ok();

    case 'companies/promote':
        require_method('POST');
        require_role('admin');
        $input = json_input();
        $companyId = required_string($input, 'company_id', 36);
        execute_sql('UPDATE companies SET is_promoted = ? WHERE id = ?', [!empty($input['value']) ? 1 : 0, $companyId]);
        audit_log('company', $companyId, !empty($input['value']) ? 'promoted' : 'promotion_removed');
        api_ok();

    case 'companies/badge':
        require_method('POST');
        $admin = require_role('admin');
        $input = json_input();
        $companyId = required_string($input, 'company_id', 36);
        $badgeKey = required_string($input, 'badge_key', 80);
        $badge = query_one('SELECT id FROM badges WHERE badge_key = ? AND is_active = 1', [$badgeKey]);
        if ($badge === null) {
            api_error('Badge not found.', 404);
        }
        if (!empty($input['enabled'])) {
            execute_sql('INSERT INTO agency_badges (agency_id, badge_id, assigned_by) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE assigned_by = VALUES(assigned_by)', [$companyId, $badge['id'], $admin['id']]);
        } else {
            execute_sql('DELETE FROM agency_badges WHERE agency_id = ? AND badge_id = ?', [$companyId, $badge['id']]);
        }
        audit_log('company', $companyId, !empty($input['enabled']) ? 'badge_assigned' : 'badge_removed', null, ['badge' => $badgeKey]);
        api_ok();

    // ------------------------------------------------------------------
    // Packages and marketplace content
    // ------------------------------------------------------------------
    case 'packages':
        require_method('GET');
        $rows = query_all("
            SELECT p.*
            FROM packages p
            JOIN companies c ON c.id = p.company_id
            WHERE p.is_published = 1
              AND p.lifecycle_status = 'published'
              AND p.price_iqd > 0
              AND p.departure_date >= CURRENT_DATE()
              AND (p.capacity IS NULL OR p.seats_reserved < p.capacity)
              AND c.is_active = 1
              AND c.is_verified = 1
              AND c.status = 'active'
              AND c.verification_status = 'approved'
            ORDER BY
              p.is_featured DESC,
              CASE WHEN c.reviews > 0 THEN 1 ELSE 0 END DESC,
              c.rating DESC,
              c.reviews DESC,
              p.departure_date,
              p.created_at DESC
        ");
        api_ok(hydrate_packages($rows));

    case 'packages/company':
        require_method('GET');
        $companyId = required_string($_GET, 'company_id', 36);
        require_company_access($companyId);
        api_ok(hydrate_packages(query_all('SELECT * FROM packages WHERE company_id = ? ORDER BY created_at DESC', [$companyId])));

    case 'packages/admin':
        require_method('GET');
        require_role('admin');
        api_ok(hydrate_packages(query_all('SELECT * FROM packages ORDER BY created_at DESC')));

    case 'packages/create':
        require_method('POST');
        $input = json_input();
        $fields = is_array($input['fields'] ?? null) ? $input['fields'] : [];
        $companyId = required_string($fields, 'company_id', 36);
        require_company_access($companyId, 'offers');
        $id = uuid_v4();
        $paymentMethods = $fields['accepted_payment_methods'] ?? ['cash'];
        $roomOccupancies = $fields['room_occupancies'] ?? [2, 3, 4];
        $pdo = db();
        $pdo->beginTransaction();
        try {
            execute_sql('INSERT INTO packages (
                id, company_id, title, title_ar, title_en, overview, overview_ar, overview_en,
                price_iqd, original_iqd, days, nights, transport, carrier, transfer_note,
                acc_stars, hotel, hotel_makkah_description, hotel_madinah_description,
                distance_haram, room, room_occupancies, meals, includes, badge, capacity,
                departure_date, return_date, package_tier, group_type, season_tag,
                departure_airport, airline_name, airline_logo_url, flight_type,
                bus_between_cities, airport_transfers, transport_notes, meals_per_day,
                video_url, cancellation_policy, cancellation_policy_ar, cancellation_policy_en,
                deposit_iqd, non_refundable_deposit, deposit_terms, deposit_terms_ar,
                deposit_terms_en, accepted_payment_methods, commission_rate
            ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', [
                $id, $companyId, required_string($fields, 'title', 255), $fields['title_ar'] ?? null, $fields['title_en'] ?? null,
                $fields['overview'] ?? '', $fields['overview_ar'] ?? null, $fields['overview_en'] ?? null,
                (int) ($fields['price_iqd'] ?? 0), $fields['original_iqd'] ?? null, (int) ($fields['days'] ?? 7),
                (int) ($fields['nights'] ?? max(0, (int) ($fields['days'] ?? 7) - 1)),
                in_array($fields['transport'] ?? '', ['plane', 'bus'], true) ? $fields['transport'] : 'plane',
                $fields['carrier'] ?? null, $fields['transfer_note'] ?? null, (int) ($fields['acc_stars'] ?? 3),
                $fields['hotel'] ?? null, $fields['hotel_makkah_description'] ?? null, $fields['hotel_madinah_description'] ?? null,
                $fields['distance_haram'] ?? null, $fields['room'] ?? null, json_encode($roomOccupancies), $fields['meals'] ?? null,
                json_encode($fields['includes'] ?? []), $fields['badge'] ?? null, $fields['capacity'] ?? null,
                $fields['departure_date'] ?? null, $fields['return_date'] ?? null, $fields['package_tier'] ?? 'standard',
                $fields['group_type'] ?? 'group', $fields['season_tag'] ?? 'regular', $fields['departure_airport'] ?? null,
                $fields['airline_name'] ?? null, $fields['airline_logo_url'] ?? null, $fields['flight_type'] ?? null,
                !empty($fields['bus_between_cities']) ? 1 : 0, !empty($fields['airport_transfers']) ? 1 : 0,
                $fields['transport_notes'] ?? null, $fields['meals_per_day'] ?? null, $fields['video_url'] ?? null,
                $fields['cancellation_policy'] ?? null, $fields['cancellation_policy_ar'] ?? null, $fields['cancellation_policy_en'] ?? null,
                (int) ($fields['deposit_iqd'] ?? 0), !empty($fields['non_refundable_deposit']) ? 1 : 0,
                $fields['deposit_terms'] ?? null, $fields['deposit_terms_ar'] ?? null, $fields['deposit_terms_en'] ?? null,
                json_encode($paymentMethods), $fields['commission_rate'] ?? null,
            ]);
            replace_package_children($id, [
                'itinerary' => $input['itinerary'] ?? [], 'pricing' => $input['pricing'] ?? [],
                'hotels' => $input['hotels'] ?? [], 'inclusions' => $input['inclusions'] ?? [],
            ]);
            $pdo->commit();
        } catch (Throwable $error) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $error;
        }
        audit_log('package', $id, 'draft_created');
        api_ok(hydrate_package(query_one('SELECT * FROM packages WHERE id = ?', [$id])), 201);

    case 'packages/update':
        require_method('PATCH', 'PUT');
        $input = json_input();
        $id = required_string($input, 'id', 36);
        $package = query_one('SELECT * FROM packages WHERE id = ?', [$id]);
        if ($package === null) api_error('Package not found.', 404);
        require_company_access($package['company_id'], 'offers');
        $fields = is_array($input['fields'] ?? null) ? $input['fields'] : [];
        unset($fields['company_id'], $fields['id'], $fields['is_published'], $fields['lifecycle_status'], $fields['seats_reserved']);
        $pdo = db();
        $pdo->beginTransaction();
        try {
            update_allowed_fields('packages', $id, $fields, [
                'title', 'title_ar', 'title_en', 'overview', 'overview_ar', 'overview_en',
                'price_iqd', 'original_iqd', 'days', 'nights', 'transport', 'carrier',
                'transfer_note', 'acc_stars', 'hotel', 'hotel_makkah_description',
                'hotel_madinah_description', 'distance_haram', 'room', 'room_occupancies' => 'json',
                'meals', 'includes' => 'json', 'badge', 'capacity', 'departure_date', 'return_date',
                'package_tier', 'group_type', 'season_tag', 'departure_airport', 'airline_name',
                'airline_logo_url', 'flight_type', 'bus_between_cities' => 'bool',
                'airport_transfers' => 'bool', 'transport_notes', 'meals_per_day', 'video_url',
                'cancellation_policy', 'cancellation_policy_ar', 'cancellation_policy_en',
                'deposit_iqd', 'non_refundable_deposit' => 'bool', 'deposit_terms',
                'deposit_terms_ar', 'deposit_terms_en', 'accepted_payment_methods' => 'json',
                'commission_rate',
            ]);
            replace_package_children($id, [
                'itinerary' => $input['itinerary'] ?? [], 'pricing' => $input['pricing'] ?? [],
                'hotels' => $input['hotels'] ?? [], 'inclusions' => $input['inclusions'] ?? [],
            ]);
            execute_sql('UPDATE packages SET content_version = content_version + 1 WHERE id = ?', [$id]);
            $pdo->commit();
        } catch (Throwable $error) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $error;
        }
        audit_log('package', $id, 'updated');
        api_ok();

    case 'packages/delete':
        require_method('DELETE', 'POST');
        $input = json_input();
        $id = required_string($input, 'id', 36);
        $package = query_one('SELECT company_id, lifecycle_status FROM packages WHERE id = ?', [$id]);
        if ($package === null) api_error('Package not found.', 404);
        require_company_access($package['company_id'], 'offers');
        if (query_one('SELECT id FROM bookings WHERE package_id = ? LIMIT 1', [$id]) !== null) {
            api_error('Packages with bookings cannot be deleted. Archive or pause it instead.', 422);
        }
        execute_sql('DELETE FROM packages WHERE id = ?', [$id]);
        audit_log('package', $id, 'deleted');
        api_ok();

    case 'packages/image':
        require_method('POST');
        $id = required_string($_POST, 'package_id', 36);
        $package = query_one('SELECT company_id FROM packages WHERE id = ?', [$id]);
        if ($package === null) api_error('Package not found.', 404);
        require_company_access($package['company_id'], 'offers');
        if (!isset($_FILES['file'])) api_error('An image is required.', 422);
        $upload = public_upload($_FILES['file'], 'package-images');
        execute_sql('UPDATE packages SET image_url = ? WHERE id = ?', [$upload['url'], $id]);
        audit_log('package', $id, 'image_updated');
        api_ok(['url' => $upload['url']]);

    case 'packages/submit':
        require_method('POST');
        $input = json_input();
        $id = required_string($input, 'package_id', 36);
        $package = query_one('SELECT * FROM packages WHERE id = ?', [$id]);
        if ($package === null) api_error('Package not found.', 404);
        require_company_access($package['company_id'], 'offers');
        if ((int) $package['price_iqd'] <= 0 || empty($package['departure_date'])) {
            api_error('Price and departure date are required before submission.', 422);
        }
        execute_sql('UPDATE packages SET lifecycle_status = \'pending_review\', review_reason = NULL, submitted_at = UTC_TIMESTAMP() WHERE id = ?', [$id]);
        audit_log('package', $id, 'submitted_for_review');
        api_ok();

    case 'packages/pause':
        require_method('POST');
        $input = json_input();
        $id = required_string($input, 'package_id', 36);
        $package = query_one('SELECT company_id FROM packages WHERE id = ?', [$id]);
        if ($package === null) api_error('Package not found.', 404);
        require_company_access($package['company_id'], 'offers');
        execute_sql('UPDATE packages SET lifecycle_status = \'paused\', is_published = 0, force_unpublish_reason = ? WHERE id = ?', [nullable_string($input, 'reason'), $id]);
        audit_log('package', $id, 'paused', null, null, nullable_string($input, 'reason'));
        api_ok();

    case 'packages/review':
        require_method('POST');
        $admin = require_role('admin');
        $input = json_input();
        $id = required_string($input, 'package_id', 36);
        $decision = required_string($input, 'decision', 30);
        if (!in_array($decision, ['approved', 'rejected', 'needs_changes'], true)) api_error('Invalid review decision.', 422);
        $reason = nullable_string($input, 'reason');
        if ($decision !== 'approved' && $reason === null) api_error('A reason is required.', 422);
        $lifecycle = $decision === 'approved' ? 'published' : 'needs_changes';
        execute_sql('UPDATE packages SET lifecycle_status = ?, is_published = ?, review_reason = ?, reviewed_by = ?, reviewed_at = UTC_TIMESTAMP() WHERE id = ?', [$lifecycle, $decision === 'approved' ? 1 : 0, $reason, $admin['id'], $id]);
        audit_log('package', $id, 'reviewed', null, ['decision' => $decision], $reason);
        api_ok();

    case 'packages/featured':
        require_method('POST');
        require_role('admin');
        $input = json_input();
        $id = required_string($input, 'package_id', 36);
        execute_sql('UPDATE packages SET is_featured = ? WHERE id = ?', [!empty($input['value']) ? 1 : 0, $id]);
        audit_log('package', $id, !empty($input['value']) ? 'featured' : 'unfeatured');
        api_ok();

    // ------------------------------------------------------------------
    // Booking lifecycle and payments
    // ------------------------------------------------------------------
    case 'bookings/quote':
        require_method('GET');
        $packageId = required_string($_GET, 'package_id', 36);
        $travellers = max(1, min(50, (int) ($_GET['travellers'] ?? 1)));
        $occupancy = (int) ($_GET['room_occupancy'] ?? 0);
        $package = query_one("SELECT * FROM packages WHERE id = ? AND is_published = 1 AND lifecycle_status = 'published'", [$packageId]);
        if ($package === null || empty($package['departure_date']) || $package['departure_date'] < date('Y-m-d')) {
            api_error('This offer is not available.', 404);
        }
        $occupancies = json_decode((string) ($package['room_occupancies'] ?? '[]'), true) ?: [];
        if (!in_array($occupancy, array_map('intval', $occupancies), true)) {
            api_error('The selected room type is not available.', 422);
        }
        if ($package['capacity'] !== null && (int) $package['seats_reserved'] + $travellers > (int) $package['capacity']) {
            api_error('There are not enough seats available.', 422);
        }
        $type = [1 => 'single', 2 => 'double', 3 => 'triple', 4 => 'quad', 5 => 'quintuple'][$occupancy] ?? null;
        $pricing = $type === null ? null : query_one('SELECT price_iqd FROM offer_pricing WHERE package_id = ? AND occupancy_type = ?', [$packageId, $type]);
        if ($pricing === null) {
            api_error('The selected room price is not configured.', 422);
        }
        $unit = (int) $pricing['price_iqd'];
        $total = $unit * $travellers;
        $deposit = (int) $package['deposit_iqd'];
        $methods = json_decode((string) ($package['accepted_payment_methods'] ?? '[]'), true) ?: ['cash'];
        api_ok(normalize_row([
            'offer_id' => $packageId,
            'version' => (int) $package['content_version'],
            'travellers' => $travellers,
            'room_occupancy' => $occupancy,
            'room_count' => (int) ceil($travellers / $occupancy),
            'unit_price_iqd' => $unit,
            'total_iqd' => $total,
            'amount_due_now_iqd' => $deposit > 0 ? min($total, $deposit * $travellers) : $total,
            'departure_date' => $package['departure_date'],
            'return_date' => $package['return_date'],
            'meal' => $package['meals'] ?? '',
            'cancellation_policy' => $package['cancellation_policy'] ?? '',
            'accepted_payment_methods' => $methods,
        ]));

    case 'bookings/create':
        require_method('POST');
        $user = require_role('client');
        $input = json_input();
        $packageId = required_string($input, 'package_id', 36);
        $travellers = (int) ($input['travellers'] ?? 0);
        $occupancy = (int) ($input['room_occupancy'] ?? 0);
        $pilgrims = is_array($input['pilgrims'] ?? null) ? $input['pilgrims'] : [];
        if ($travellers < 1 || $travellers > 50 || count($pilgrims) !== $travellers) {
            api_error('Traveller details must match the traveller count.', 422);
        }
        $leadCount = count(array_filter($pilgrims, fn($p) => !empty($p['is_lead'])));
        if ($leadCount !== 1) {
            api_error('Exactly one lead traveller is required.', 422);
        }
        $requestKey = trim((string) ($input['request_key'] ?? ''));
        if ($requestKey !== '') {
            $existing = query_one('SELECT * FROM bookings WHERE client_id = ? AND request_key = ?', [$user['id'], $requestKey]);
            if ($existing !== null) api_ok(hydrate_booking($existing));
        }
        $pdo = db();
        $pdo->beginTransaction();
        try {
            // Serialize all booking attempts for this client, including requests
            // with different idempotency keys or for different packages.
            query_one('SELECT id FROM users WHERE id = ? FOR UPDATE', [$user['id']]);
            $activeBooking = query_one(
                "SELECT id FROM bookings
                 WHERE client_id = ?
                   AND operational_stage IN ('requested','needs_information','awaiting_payment','confirmed','ready','in_progress')
                   AND refund_status NOT IN ('completed')
                 LIMIT 1 FOR UPDATE",
                [$user['id']]
            );
            if ($activeBooking !== null) {
                throw new DomainException(
                    'You already have an active Umrah booking. You must complete or cancel your current booking before booking another trip.'
                );
            }
            $package = query_one("SELECT p.*, c.owner_id, c.name AS company_name, c.name_ar AS company_name_ar, c.name_en AS company_name_en, c.commission_rate AS company_commission_rate, c.is_verified, c.is_active, c.status AS company_status FROM packages p JOIN companies c ON c.id = p.company_id WHERE p.id = ? FOR UPDATE", [$packageId]);
            if ($package === null || !$package['is_published'] || $package['lifecycle_status'] !== 'published' || !$package['is_verified'] || !$package['is_active'] || $package['company_status'] !== 'active') {
                throw new DomainException('This offer is not available.');
            }
            if (empty($package['departure_date']) || $package['departure_date'] < date('Y-m-d')) {
                throw new DomainException('This departure is no longer available.');
            }
            if ($package['capacity'] !== null && (int) $package['seats_reserved'] + $travellers > (int) $package['capacity']) {
                throw new DomainException('There are not enough seats available.');
            }
            $occupancies = json_decode((string) ($package['room_occupancies'] ?? '[]'), true) ?: [];
            if (!in_array($occupancy, array_map('intval', $occupancies), true)) {
                throw new DomainException('The selected room type is not available.');
            }
            $type = [1 => 'single', 2 => 'double', 3 => 'triple', 4 => 'quad', 5 => 'quintuple'][$occupancy] ?? null;
            $price = $type === null ? null : query_one('SELECT price_iqd FROM offer_pricing WHERE package_id = ? AND occupancy_type = ?', [$packageId, $type]);
            if ($price === null) throw new DomainException('The selected room price is not configured.');
            $payMethod = (string) ($input['pay_method'] ?? 'cash');
            $acceptedMethods = json_decode((string) ($package['accepted_payment_methods'] ?? '[]'), true) ?: ['cash'];
            if (!in_array($payMethod, $acceptedMethods, true) || !in_array($payMethod, ['cash', 'fib'], true)) {
                throw new DomainException('The selected payment method is not accepted.');
            }
            $unit = (int) $price['price_iqd'];
            $total = $unit * $travellers;
            $rate = $package['commission_rate'] !== null ? (float) $package['commission_rate'] : (float) $package['company_commission_rate'];
            $commission = (int) round($total * $rate);
            $deposit = (int) $package['deposit_iqd'];
            $dueNow = $deposit > 0 ? min($total, $deposit * $travellers) : $total;
            $id = uuid_v4();
            $snapshot = [
                'version' => (int) $package['content_version'], 'offer_title' => $package['title'],
                'offer_title_ar' => $package['title_ar'], 'offer_title_en' => $package['title_en'],
                'company_name' => $package['company_name'], 'company_name_ar' => $package['company_name_ar'],
                'company_name_en' => $package['company_name_en'], 'unit_price_iqd' => $unit,
                'total_iqd' => $total, 'room_occupancy' => $occupancy,
            ];
            execute_sql('INSERT INTO bookings (
                id, package_id, company_id, client_id, travellers, unit_price_iqd, total_iqd,
                commission_rate, commission_iqd, payout_iqd, pay_method, departure_date,
                contact_phone, note, room_label, room_occupancy, room_count, meal_preference,
                expires_at, amount_due_now_iqd, quote_version, quote_snapshot,
                cancellation_policy_snapshot, deposit_iqd_snapshot,
                non_refundable_deposit_snapshot, request_key
            ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,DATE_ADD(UTC_TIMESTAMP(), INTERVAL 24 HOUR),?,?,?,?,?,?,?)', [
                $id, $packageId, $package['company_id'], $user['id'], $travellers, $unit, $total,
                $rate, $commission, $total - $commission, $payMethod, $package['departure_date'],
                nullable_string($input, 'contact_phone', 50), nullable_string($input, 'note'),
                nullable_string($input, 'room_label', 100), $occupancy, (int) ceil($travellers / $occupancy),
                $package['meals'] ?? null, $dueNow, (int) $package['content_version'],
                json_encode($snapshot, JSON_UNESCAPED_UNICODE), $package['cancellation_policy'], $deposit,
                !empty($package['non_refundable_deposit']) ? 1 : 0, $requestKey === '' ? null : $requestKey,
            ]);
            foreach ($pilgrims as $pilgrim) {
                $fullName = trim((string) ($pilgrim['full_name'] ?? ''));
                $dob = trim((string) ($pilgrim['date_of_birth'] ?? ''));
                if ($fullName === '' || $dob === '' || $dob > date('Y-m-d')) {
                    throw new DomainException('Each traveller needs a valid passport name and date of birth.');
                }
                execute_sql('INSERT INTO booking_travellers (id, booking_id, client_id, full_name, local_name, passport_no, date_of_birth, phone, is_lead) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    uuid_v4(), $id, $user['id'], $fullName, nullable_string($pilgrim, 'local_name', 190),
                    nullable_string($pilgrim, 'passport_no', 80), $dob, nullable_string($pilgrim, 'phone', 50),
                    !empty($pilgrim['is_lead']) ? 1 : 0,
                ]);
            }
            execute_sql('UPDATE packages SET seats_reserved = seats_reserved + ? WHERE id = ?', [$travellers, $packageId]);
            execute_sql('INSERT INTO notifications (id, user_id, type, arg) VALUES (?, ?, \'bookingRequested\', ?)', [uuid_v4(), $package['owner_id'] ?? query_one('SELECT owner_id FROM companies WHERE id = ?', [$package['company_id']])['owner_id'], $package['title']]);
            $pdo->commit();
        } catch (DomainException $error) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            api_error($error->getMessage(), 422);
        } catch (Throwable $error) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $error;
        }
        audit_log('booking', $id, 'created');
        api_ok(hydrate_booking(query_one('SELECT * FROM bookings WHERE id = ?', [$id])), 201);

    case 'bookings/mine':
        require_method('GET');
        $user = current_user();
        api_ok(hydrate_bookings(query_all('SELECT * FROM bookings WHERE client_id = ? ORDER BY created_at DESC', [$user['id']])));

    case 'bookings/company':
        require_method('GET');
        $companyId = required_string($_GET, 'company_id', 36);
        require_company_access($companyId, 'bookings');
        api_ok(hydrate_bookings(query_all('SELECT * FROM bookings WHERE company_id = ? ORDER BY created_at DESC', [$companyId])));

    case 'bookings/admin':
        require_method('GET');
        require_role('admin');
        api_ok(hydrate_bookings(query_all('SELECT * FROM bookings ORDER BY created_at DESC')));

    case 'bookings/travellers':
        require_method('GET');
        $bookingId = required_string($_GET, 'booking_id', 36);
        $booking = query_one('SELECT client_id, company_id FROM bookings WHERE id = ?', [$bookingId]);
        if ($booking === null) api_error('Booking not found.', 404);
        $user = current_user();
        if ($booking['client_id'] !== $user['id'] && !can_access_company($user, $booking['company_id'], 'documents')) {
            api_error('You do not have access to these travellers.', 403);
        }
        api_ok(normalize_rows(query_all('SELECT * FROM booking_travellers WHERE booking_id = ? ORDER BY is_lead DESC, created_at', [$bookingId])));

    case 'bookings/passports':
        require_method('POST');
        $user = require_role('client');
        $bookingId = required_string($_POST, 'booking_id', 36);
        $travellerId = required_string($_POST, 'traveller_id', 36);
        $booking = query_one('SELECT * FROM bookings WHERE id = ? AND client_id = ?', [$bookingId, $user['id']]);
        if ($booking === null) api_error('Booking not found.', 404);
        if (!isset($_FILES['passport'], $_FILES['selfie'])) api_error('Passport and selfie images are required.', 422);
        $passport = private_upload($_FILES['passport'], 'booking-' . $bookingId);
        $selfie = private_upload($_FILES['selfie'], 'booking-' . $bookingId);
        $changed = execute_sql('UPDATE booking_travellers SET passport_image_path = ?, selfie_image_path = ?, document_status = \'under_review\', document_reason = NULL WHERE id = ? AND booking_id = ?', [$passport['path'], $selfie['path'], $travellerId, $bookingId]);
        if ($changed < 1) api_error('Traveller not found.', 404);
        audit_log('booking_traveller', $travellerId, 'passport_uploaded');
        api_ok();

    case 'bookings/cancel':
        require_method('POST');
        $user = current_user();
        $input = json_input();
        $id = required_string($input, 'booking_id', 36);
        $reason = required_string($input, 'reason', 1000);
        $pdo = db();
        $pdo->beginTransaction();
        try {
            $booking = query_one('SELECT * FROM bookings WHERE id = ? FOR UPDATE', [$id]);
            if ($booking === null || ($booking['client_id'] !== $user['id'] && $user['role'] !== 'admin')) {
                throw new DomainException('Booking not found.');
            }
            if (in_array($booking['operational_stage'], ['completed', 'cancelled', 'rejected', 'expired'], true)) {
                throw new DomainException('This booking can no longer be cancelled.');
            }
            $paid = (int) $booking['amount_paid_iqd'];
            $withheld = !empty($booking['non_refundable_deposit_snapshot'])
                ? min($paid, (int) $booking['deposit_iqd_snapshot'] * (int) $booking['travellers'])
                : 0;
            $refundDue = max(0, $paid - $withheld);
            $refundStatus = $refundDue > 0 ? 'pending' : 'none';
            execute_sql(
                'UPDATE bookings SET status = \'cancelled\', operational_stage = \'cancelled\',
                 status_reason = ?, cancelled_at = UTC_TIMESTAMP(), cancelled_by = ?,
                 refund_due_iqd = ?, refund_status = ? WHERE id = ?',
                [$reason, $user['id'], $refundDue, $refundStatus, $id]
            );
            execute_sql(
                'UPDATE packages SET seats_reserved = GREATEST(0, seats_reserved - ?) WHERE id = ?',
                [$booking['travellers'], $booking['package_id']]
            );
            $pdo->commit();
        } catch (DomainException $error) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            api_error($error->getMessage(), 422);
        } catch (Throwable $error) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $error;
        }
        audit_log('booking', $id, 'cancelled', null, null, $reason);
        api_ok();

    case 'bookings/status':
        require_method('POST');
        $input = json_input();
        $id = required_string($input, 'booking_id', 36);
        $action = required_string($input, 'action', 50);
        $booking = query_one('SELECT * FROM bookings WHERE id = ?', [$id]);
        if ($booking === null) api_error('Booking not found.', 404);
        require_company_access($booking['company_id'], 'bookings');
        $reason = nullable_string($input, 'reason');
        $stage = null;
        $status = $booking['status'];
        if ($action === 'accept' && in_array($booking['operational_stage'], ['requested', 'needs_information'], true)) {
            $stage = 'awaiting_payment';
            $status = 'pending';
        } elseif ($action === 'request_information' && $booking['operational_stage'] === 'requested' && $reason !== null) {
            $stage = 'needs_information';
        } elseif ($action === 'reject' && in_array($booking['operational_stage'], ['requested', 'needs_information', 'awaiting_payment'], true) && $reason !== null) {
            $stage = 'rejected';
            $status = 'cancelled';
        } elseif ($action === 'ready' && $booking['operational_stage'] === 'confirmed') {
            $stage = 'ready';
        } elseif ($action === 'start' && in_array($booking['operational_stage'], ['confirmed', 'ready'], true)) {
            $stage = 'in_progress';
        } elseif ($action === 'complete' && in_array($booking['operational_stage'], ['confirmed', 'ready', 'in_progress'], true)) {
            $stage = 'completed';
            $status = 'completed';
        }
        if ($stage === null) api_error('This booking transition is not allowed.', 422);
        execute_sql('UPDATE bookings SET operational_stage = ?, status = ?, status_reason = ?, accepted_at = IF(? = \'awaiting_payment\', UTC_TIMESTAMP(), accepted_at), ready_at = IF(? = \'ready\', UTC_TIMESTAMP(), ready_at), started_at = IF(? = \'in_progress\', UTC_TIMESTAMP(), started_at), completed_at = IF(? = \'completed\', UTC_TIMESTAMP(), completed_at) WHERE id = ?', [$stage, $status, $reason, $stage, $stage, $stage, $stage, $id]);
        if ($stage === 'rejected') execute_sql('UPDATE packages SET seats_reserved = GREATEST(0, seats_reserved - ?) WHERE id = ?', [$booking['travellers'], $booking['package_id']]);
        execute_sql('INSERT INTO notifications (id, user_id, type, arg) VALUES (?, ?, ?, (SELECT title FROM packages WHERE id = ?))', [uuid_v4(), $booking['client_id'], $stage === 'rejected' ? 'bookingCancelled' : 'bookingConfirmed', $booking['package_id']]);
        audit_log('booking', $id, 'transitioned', ['stage' => $booking['operational_stage']], ['stage' => $stage], $reason);
        api_ok();

    case 'bookings/cash':
        require_method('POST');
        $input = json_input();
        $id = required_string($input, 'booking_id', 36);
        $booking = query_one('SELECT * FROM bookings WHERE id = ?', [$id]);
        if ($booking === null) api_error('Booking not found.', 404);
        require_company_access($booking['company_id'], 'finance');
        if ($booking['pay_method'] !== 'cash') api_error('This booking is not a cash booking.', 422);
        $amount = max(0, min((int) $booking['total_iqd'] - (int) $booking['amount_paid_iqd'], (int) $booking['amount_due_now_iqd'] - (int) $booking['amount_paid_iqd']));
        if ($amount <= 0) api_error('No payment is currently due.', 422);
        $paymentId = uuid_v4();
        execute_sql('INSERT INTO payments (id, booking_id, company_id, client_id, amount_iqd, method, status, idempotency_key) VALUES (?, ?, ?, ?, ?, \'cash\', \'initiated\', ?)', [$paymentId, $id, $booking['company_id'], $booking['client_id'], $amount, 'cash-' . $id . '-' . (int) $booking['amount_paid_iqd']]);
        record_payment_success($paymentId);
        audit_log('payment', $paymentId, 'cash_confirmed');
        api_ok();

    case 'payments/fib/create':
        require_method('POST');
        $user = require_role('client');
        $input = json_input();
        $bookingId = required_string($input, 'booking_id', 36);
        $amount = (int) ($input['amount_iqd'] ?? 0);
        $key = required_string($input, 'idempotency_key', 190);
        $booking = query_one('SELECT * FROM bookings WHERE id = ? AND client_id = ?', [$bookingId, $user['id']]);
        if ($booking === null || $booking['pay_method'] !== 'fib') api_error('FIB payment is not available for this booking.', 422);
        $remaining = min((int) $booking['total_iqd'], (int) $booking['amount_due_now_iqd']) - (int) $booking['amount_paid_iqd'];
        if ($amount <= 0 || $amount > $remaining) api_error('The payment amount is invalid.', 422);
        $payment = query_one('SELECT * FROM payments WHERE idempotency_key = ?', [$key]);
        if ($payment === null) {
            $paymentId = uuid_v4();
            execute_sql('INSERT INTO payments (id, booking_id, company_id, client_id, amount_iqd, method, idempotency_key) VALUES (?, ?, ?, ?, ?, \'fib\', ?)', [$paymentId, $bookingId, $booking['company_id'], $user['id'], $amount, $key]);
            $payment = query_one('SELECT * FROM payments WHERE id = ?', [$paymentId]);
        }
        if ($payment['status'] !== 'initiated') api_ok(['payment_id' => $payment['id'], 'status' => $payment['status']]);
        if (!empty($payment['provider_reference'])) api_ok(['payment_id' => $payment['id'], 'fib' => ['paymentId' => $payment['provider_reference']]]);
        try {
            $fib = fib_create_payment($amount, $bookingId);
        } catch (RuntimeException $error) {
            record_payment_failure($payment['id'], $error->getMessage());
            api_error($error->getMessage(), 503, 'payment_provider_unavailable');
        }
        execute_sql('UPDATE payments SET provider_reference = ?, metadata = ? WHERE id = ?', [$fib['paymentId'] ?? null, json_encode($fib), $payment['id']]);
        audit_log('payment', $payment['id'], 'fib_initiated');
        api_ok(['payment_id' => $payment['id'], 'fib' => $fib]);

    // ------------------------------------------------------------------
    // Saved offers, preferences, ads and notifications
    // ------------------------------------------------------------------
    case 'saved':
        $user = current_user();
        if (($_SERVER['REQUEST_METHOD'] ?? '') === 'GET') {
            api_ok(array_column(query_all('SELECT package_id FROM saved_offers WHERE client_id = ? ORDER BY created_at DESC', [$user['id']]), 'package_id'));
        }
        $input = json_input();
        $packageId = required_string($input, 'package_id', 36);
        if (($_SERVER['REQUEST_METHOD'] ?? '') === 'DELETE') {
            execute_sql('DELETE FROM saved_offers WHERE client_id = ? AND package_id = ?', [$user['id'], $packageId]);
        } else {
            require_method('POST');
            execute_sql('INSERT IGNORE INTO saved_offers (client_id, package_id) VALUES (?, ?)', [$user['id'], $packageId]);
        }
        api_ok();

    case 'preferences':
        $user = current_user();
        if (($_SERVER['REQUEST_METHOD'] ?? '') === 'GET') {
            $prefs = query_one('SELECT marketing_emails, share_activity, preferred_pay_method FROM users WHERE id = ?', [$user['id']]);
            api_ok(normalize_row($prefs ?? []));
        }
        require_method('PATCH', 'PUT');
        update_allowed_fields('users', $user['id'], json_input(), [
            'marketing_emails' => 'bool', 'share_activity' => 'bool', 'preferred_pay_method',
        ]);
        api_ok();

    case 'ads':
        require_method('GET');
        $user = current_user(false);
        $sql = $user !== null && $user['role'] === 'admin'
            ? 'SELECT * FROM home_ads ORDER BY sort_order, created_at DESC'
            : 'SELECT * FROM home_ads WHERE is_active = 1 AND (starts_at IS NULL OR starts_at <= UTC_TIMESTAMP()) AND (ends_at IS NULL OR ends_at >= UTC_TIMESTAMP()) ORDER BY sort_order, created_at DESC';
        api_ok(normalize_rows(query_all($sql)));

    case 'ads/create':
        require_method('POST');
        $admin = require_role('admin');
        $input = json_input();
        $id = uuid_v4();
        execute_sql('INSERT INTO home_ads (id, company_id, package_id, title, title_ar, title_en, sort_order, is_active, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $id, $input['company_id'] ?? null, $input['package_id'] ?? null,
            required_string($input, 'title', 255), $input['title_ar'] ?? null, $input['title_en'] ?? null,
            (int) ($input['sort_order'] ?? 0), array_key_exists('is_active', $input) ? (!empty($input['is_active']) ? 1 : 0) : 1, $admin['id'],
        ]);
        audit_log('home_ad', $id, 'created');
        api_ok(normalize_row(query_one('SELECT * FROM home_ads WHERE id = ?', [$id])), 201);

    case 'ads/update':
        require_method('PATCH', 'PUT');
        require_role('admin');
        $input = json_input();
        $id = required_string($input, 'id', 36);
        update_allowed_fields('home_ads', $id, $input, ['title', 'title_ar', 'title_en', 'sort_order', 'is_active' => 'bool', 'starts_at', 'ends_at']);
        audit_log('home_ad', $id, 'updated');
        api_ok();

    case 'ads/delete':
        require_method('DELETE', 'POST');
        require_role('admin');
        $input = json_input();
        $id = required_string($input, 'id', 36);
        execute_sql('DELETE FROM home_ads WHERE id = ?', [$id]);
        audit_log('home_ad', $id, 'deleted');
        api_ok();

    case 'ads/image':
        require_method('POST');
        require_role('admin');
        $id = required_string($_POST, 'ad_id', 36);
        if (!isset($_FILES['file'])) api_error('An image is required.', 422);
        $upload = public_upload($_FILES['file'], 'home-ads');
        execute_sql('UPDATE home_ads SET image_url = ? WHERE id = ?', [$upload['url'], $id]);
        audit_log('home_ad', $id, 'image_updated');
        api_ok(['url' => $upload['url']]);

    case 'notifications':
        require_method('GET');
        $user = current_user();
        api_ok(normalize_rows(query_all('SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50', [$user['id']])));

    case 'notifications/read':
        require_method('POST');
        $user = current_user();
        $input = json_input();
        execute_sql('UPDATE notifications SET `read` = 1 WHERE id = ? AND user_id = ?', [required_string($input, 'id', 36), $user['id']]);
        api_ok();

    case 'notifications/read-all':
        require_method('POST');
        $user = current_user();
        execute_sql('UPDATE notifications SET `read` = 1 WHERE user_id = ?', [$user['id']]);
        api_ok();

    case 'notifications/delete':
        require_method('DELETE', 'POST');
        $user = current_user();
        $input = json_input();
        execute_sql('DELETE FROM notifications WHERE id = ? AND user_id = ?', [required_string($input, 'id', 36), $user['id']]);
        api_ok();

    case 'notifications/clear':
        require_method('DELETE', 'POST');
        $user = current_user();
        execute_sql('DELETE FROM notifications WHERE user_id = ?', [$user['id']]);
        api_ok();

    // ------------------------------------------------------------------
    // Agency finance, travellers and trip operations
    // ------------------------------------------------------------------
    case 'wallet':
        require_method('GET');
        $companyId = required_string($_GET, 'company_id', 36);
        require_company_access($companyId, 'finance');
        $balance = query_one('SELECT COALESCE(SUM(amount_iqd), 0) AS balance_iqd FROM agency_ledger WHERE company_id = ?', [$companyId]);
        $entries = normalize_rows(query_all('SELECT * FROM agency_ledger WHERE company_id = ? ORDER BY created_at DESC', [$companyId]));
        $payouts = normalize_rows(query_all('SELECT * FROM payouts WHERE company_id = ? ORDER BY created_at DESC', [$companyId]));
        api_ok(['balance_iqd' => (float) ($balance['balance_iqd'] ?? 0), 'entries' => $entries, 'payouts' => $payouts]);

    case 'trips/travellers':
        require_method('GET');
        $packageId = required_string($_GET, 'package_id', 36);
        $package = query_one('SELECT company_id FROM packages WHERE id = ?', [$packageId]);
        if ($package === null) api_error('Trip not found.', 404);
        require_company_access($package['company_id'], 'operations');
        $rows = query_all("SELECT t.* FROM booking_travellers t JOIN bookings b ON b.id = t.booking_id WHERE b.package_id = ? AND b.operational_stage NOT IN ('cancelled','rejected','expired') ORDER BY t.is_lead DESC, t.created_at", [$packageId]);
        api_ok(normalize_rows($rows));

    case 'trips/documents':
        require_method('GET');
        $bookingId = required_string($_GET, 'booking_id', 36);
        $booking = query_one('SELECT client_id, company_id FROM bookings WHERE id = ?', [$bookingId]);
        if ($booking === null) api_error('Booking not found.', 404);
        $user = current_user();
        if ($user['id'] !== $booking['client_id'] && !can_access_company($user, $booking['company_id'], 'documents')) api_error('You do not have access to these documents.', 403);
        api_ok(normalize_rows(query_all('SELECT * FROM traveller_documents WHERE booking_id = ? ORDER BY created_at DESC', [$bookingId])));

    case 'trips/document-url':
        require_method('GET');
        $path = required_string($_GET, 'path', 500);
        $document = query_one('SELECT td.booking_id, td.company_id, b.client_id FROM traveller_documents td JOIN bookings b ON b.id = td.booking_id WHERE td.storage_path = ? UNION SELECT NULL AS booking_id, ad.agency_id AS company_id, c.owner_id AS client_id FROM agency_documents ad JOIN companies c ON c.id = ad.agency_id WHERE ad.storage_path = ? LIMIT 1', [$path, $path]);
        if ($document === null) api_error('Document not found.', 404);
        $user = current_user();
        if ($user['id'] !== $document['client_id'] && !can_access_company($user, $document['company_id'], 'documents')) api_error('You do not have access to this document.', 403);
        $expires = time() + 600;
        $signature = hash_hmac('sha256', $path . '|' . $expires, (string) config('db.password'));
        api_ok(['url' => config('app_url') . '/api/files/private?path=' . rawurlencode($path) . '&expires=' . $expires . '&sig=' . $signature]);

    case 'trips/documents/upload':
        require_method('POST');
        $user = current_user();
        $bookingId = required_string($_POST, 'booking_id', 36);
        $travellerId = required_string($_POST, 'traveller_id', 36);
        $companyId = required_string($_POST, 'company_id', 36);
        $kind = required_string($_POST, 'kind', 50);
        $booking = query_one('SELECT * FROM bookings WHERE id = ? AND company_id = ?', [$bookingId, $companyId]);
        if ($booking === null || ($booking['client_id'] !== $user['id'] && !can_access_company($user, $companyId, 'documents'))) api_error('Booking not found.', 404);
        if (in_array($booking['operational_stage'], ['completed', 'cancelled', 'rejected', 'expired'], true)) api_error('Documents can no longer be uploaded for this booking.', 422);
        if (query_one('SELECT id FROM booking_travellers WHERE id = ? AND booking_id = ?', [$travellerId, $bookingId]) === null) api_error('Traveller not found.', 404);
        if (!isset($_FILES['file'])) api_error('A document is required.', 422);
        $upload = private_upload($_FILES['file'], 'traveller-' . $travellerId);
        $id = uuid_v4();
        execute_sql('INSERT INTO traveller_documents (id, traveller_id, booking_id, company_id, kind, storage_path, original_name, mime_type, file_size) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $id, $travellerId, $bookingId, $companyId, $kind, $upload['path'], $upload['original_name'], $upload['mime'], $upload['size'],
        ]);
        execute_sql('UPDATE booking_travellers SET document_status = \'under_review\', document_reason = NULL WHERE id = ?', [$travellerId]);
        audit_log('traveller_document', $id, 'uploaded');
        api_ok(['id' => $id], 201);

    case 'trips/traveller-update':
        require_method('PATCH', 'PUT');
        $input = json_input();
        $travellerId = required_string($input, 'traveller_id', 36);
        $traveller = query_one('SELECT t.*, b.company_id FROM booking_travellers t JOIN bookings b ON b.id = t.booking_id WHERE t.id = ?', [$travellerId]);
        if ($traveller === null) api_error('Traveller not found.', 404);
        require_company_access($traveller['company_id'], 'documents');
        $documentStatus = $input['document_status'] ?? null;
        $visaStatus = $input['visa_status'] ?? null;
        if ($documentStatus !== null && !in_array($documentStatus, ['missing', 'uploaded', 'under_review', 'approved', 'rejected'], true)) api_error('Invalid document status.', 422);
        if ($visaStatus !== null && !in_array($visaStatus, ['not_started', 'documents_missing', 'ready_to_apply', 'submitted', 'under_review', 'approved', 'rejected'], true)) api_error('Invalid visa status.', 422);
        if ($documentStatus === 'rejected' && nullable_string($input, 'document_reason') === null) api_error('A document rejection reason is required.', 422);
        if ($visaStatus === 'rejected' && nullable_string($input, 'visa_reason') === null) api_error('A visa rejection reason is required.', 422);
        update_allowed_fields('booking_travellers', $travellerId, $input, [
            'document_status', 'document_reason', 'visa_status', 'visa_reference', 'visa_reason', 'transport_seat',
        ]);
        if ($visaStatus !== null) execute_sql('UPDATE booking_travellers SET visa_updated_at = UTC_TIMESTAMP() WHERE id = ?', [$travellerId]);
        audit_log('booking_traveller', $travellerId, 'operations_updated', ['document_status' => $traveller['document_status'], 'visa_status' => $traveller['visa_status']], ['document_status' => $documentStatus, 'visa_status' => $visaStatus]);
        api_ok();

    case 'trips/documents/review':
        require_method('POST');
        $reviewer = current_user();
        $input = json_input();
        $id = required_string($input, 'document_id', 36);
        $document = query_one('SELECT * FROM traveller_documents WHERE id = ?', [$id]);
        if ($document === null) api_error('Document not found.', 404);
        require_company_access($document['company_id'], 'documents');
        $status = required_string($input, 'status', 30);
        $reason = nullable_string($input, 'reason');
        if (!in_array($status, ['approved', 'rejected'], true) || ($status === 'rejected' && $reason === null)) api_error('A valid status and rejection reason are required.', 422);
        execute_sql('UPDATE traveller_documents SET status = ?, rejection_reason = ?, expires_on = ?, reviewed_by = ?, reviewed_at = UTC_TIMESTAMP() WHERE id = ?', [$status, $status === 'rejected' ? $reason : null, $input['expires_on'] ?? null, $reviewer['id'], $id]);
        $aggregate = query_one("SELECT SUM(status = 'rejected') AS rejected, SUM(status = 'under_review') AS reviewing FROM traveller_documents WHERE traveller_id = ?", [$document['traveller_id']]);
        $travellerStatus = (int) ($aggregate['rejected'] ?? 0) > 0 ? 'rejected' : ((int) ($aggregate['reviewing'] ?? 0) > 0 ? 'under_review' : 'approved');
        execute_sql('UPDATE booking_travellers SET document_status = ?, document_reason = ? WHERE id = ?', [$travellerStatus, $travellerStatus === 'rejected' ? $reason : null, $document['traveller_id']]);
        audit_log('traveller_document', $id, 'reviewed', null, ['status' => $status], $reason);
        api_ok();

    case 'trips/announcements':
        $announcementInput = ($_SERVER['REQUEST_METHOD'] ?? '') === 'GET' ? $_GET : json_input();
        $packageId = required_string($announcementInput, 'package_id', 36);
        $package = query_one('SELECT company_id FROM packages WHERE id = ?', [$packageId]);
        if ($package === null) api_error('Trip not found.', 404);
        $user = current_user();
        if (($_SERVER['REQUEST_METHOD'] ?? '') === 'GET') {
            $hasBooking = query_one("SELECT id FROM bookings WHERE package_id = ? AND client_id = ? AND operational_stage NOT IN ('cancelled','rejected','expired') LIMIT 1", [$packageId, $user['id']]);
            if ($hasBooking === null && !can_access_company($user, $package['company_id'], 'announcements')) api_error('You do not have access to these announcements.', 403);
            api_ok(normalize_rows(query_all('SELECT * FROM trip_announcements WHERE package_id = ? ORDER BY created_at DESC', [$packageId])));
        }
        require_method('POST');
        require_company_access($package['company_id'], 'announcements');
        $id = uuid_v4();
        execute_sql('INSERT INTO trip_announcements (id, package_id, company_id, created_by, title, body, audience) VALUES (?, ?, ?, ?, ?, ?, ?)', [
            $id, $packageId, $package['company_id'], $user['id'], required_string($announcementInput, 'title', 255), required_string($announcementInput, 'body', 10000), $announcementInput['audience'] ?? 'all',
        ]);
        audit_log('trip_announcement', $id, 'created');
        api_ok(['id' => $id], 201);

    case 'trips/rooms':
        require_method('GET');
        $packageId = required_string($_GET, 'package_id', 36);
        $package = query_one('SELECT company_id FROM packages WHERE id = ?', [$packageId]);
        if ($package === null) api_error('Trip not found.', 404);
        require_company_access($package['company_id'], 'operations');
        $rows = query_all('SELECT r.*, COUNT(a.traveller_id) AS assigned_count FROM trip_rooms r LEFT JOIN trip_room_assignments a ON a.room_id = r.id WHERE r.package_id = ? GROUP BY r.id ORDER BY r.city, r.label', [$packageId]);
        foreach ($rows as &$row) $row['trip_room_assignments'] = array_fill(0, (int) $row['assigned_count'], ['traveller_id' => 'assigned']);
        api_ok(normalize_rows($rows));

    case 'trips/rooms/create':
        require_method('POST');
        $input = json_input();
        $companyId = required_string($input, 'company_id', 36);
        require_company_access($companyId, 'operations');
        $id = uuid_v4();
        execute_sql('INSERT INTO trip_rooms (id, package_id, company_id, city, label, capacity, gender_policy) VALUES (?, ?, ?, ?, ?, ?, ?)', [
            $id, required_string($input, 'package_id', 36), $companyId, required_string($input, 'city', 20), required_string($input, 'label', 100), (int) ($input['capacity'] ?? 1), $input['gender_policy'] ?? 'family',
        ]);
        audit_log('trip_room', $id, 'created');
        api_ok(['id' => $id], 201);

    case 'trips/rooms/delete':
        require_method('DELETE', 'POST');
        $input = json_input();
        $id = required_string($input, 'room_id', 36);
        $room = query_one('SELECT company_id FROM trip_rooms WHERE id = ?', [$id]);
        if ($room === null) api_error('Room not found.', 404);
        require_company_access($room['company_id'], 'operations');
        execute_sql('DELETE FROM trip_rooms WHERE id = ?', [$id]);
        audit_log('trip_room', $id, 'deleted');
        api_ok();

    case 'trips/rooms/assign':
        require_method('POST');
        $input = json_input();
        $roomId = required_string($input, 'room_id', 36);
        $travellerId = required_string($input, 'traveller_id', 36);
        $room = query_one('SELECT r.*, COUNT(a.traveller_id) AS assigned_count FROM trip_rooms r LEFT JOIN trip_room_assignments a ON a.room_id = r.id WHERE r.id = ? GROUP BY r.id', [$roomId]);
        if ($room === null) api_error('Room not found.', 404);
        require_company_access($room['company_id'], 'operations');
        if ((int) $room['assigned_count'] >= (int) $room['capacity']) api_error('This room is full.', 422);
        $traveller = query_one('SELECT t.id FROM booking_travellers t JOIN bookings b ON b.id = t.booking_id WHERE t.id = ? AND b.package_id = ?', [$travellerId, $room['package_id']]);
        if ($traveller === null) api_error('Traveller does not belong to this trip.', 422);
        execute_sql('DELETE FROM trip_room_assignments WHERE traveller_id = ?', [$travellerId]);
        execute_sql('INSERT INTO trip_room_assignments (room_id, traveller_id) VALUES (?, ?)', [$roomId, $travellerId]);
        audit_log('trip_room', $roomId, 'traveller_assigned', null, ['traveller_id' => $travellerId]);
        api_ok();

    case 'trips/transport':
        require_method('GET');
        $packageId = required_string($_GET, 'package_id', 36);
        $package = query_one('SELECT company_id FROM packages WHERE id = ?', [$packageId]);
        if ($package === null) api_error('Trip not found.', 404);
        require_company_access($package['company_id'], 'operations');
        api_ok(normalize_rows(query_all('SELECT * FROM trip_transport_segments WHERE package_id = ? ORDER BY departure_at', [$packageId])));

    case 'trips/transport/create':
        require_method('POST');
        $input = json_input();
        $companyId = required_string($input, 'company_id', 36);
        require_company_access($companyId, 'operations');
        $id = uuid_v4();
        execute_sql('INSERT INTO trip_transport_segments (id, package_id, company_id, mode, provider, reference_no, vehicle_no, driver_name, driver_phone, guide_name, departure_place, departure_at, arrival_place, arrival_at, baggage, meeting_point) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $id, required_string($input, 'package_id', 36), $companyId, required_string($input, 'mode', 20),
            $input['provider'] ?? null, $input['reference_no'] ?? null, $input['vehicle_no'] ?? null,
            $input['driver_name'] ?? null, $input['driver_phone'] ?? null, $input['guide_name'] ?? null,
            $input['departure_place'] ?? null, $input['departure_at'] ?? null, $input['arrival_place'] ?? null,
            $input['arrival_at'] ?? null, $input['baggage'] ?? null, $input['meeting_point'] ?? null,
        ]);
        audit_log('trip_transport', $id, 'created');
        api_ok(['id' => $id], 201);

    case 'trips/transport/delete':
        require_method('DELETE', 'POST');
        $input = json_input();
        $id = required_string($input, 'segment_id', 36);
        $segment = query_one('SELECT company_id FROM trip_transport_segments WHERE id = ?', [$id]);
        if ($segment === null) api_error('Transport segment not found.', 404);
        require_company_access($segment['company_id'], 'operations');
        execute_sql('DELETE FROM trip_transport_segments WHERE id = ?', [$id]);
        audit_log('trip_transport', $id, 'deleted');
        api_ok();

    case 'agency/staff':
        require_method('GET');
        $companyId = required_string($_GET, 'company_id', 36);
        require_company_access($companyId, 'staff');
        $rows = query_all('SELECT s.*, u.full_name FROM agency_staff s JOIN users u ON u.id = s.user_id WHERE s.company_id = ? ORDER BY s.created_at', [$companyId]);
        foreach ($rows as &$row) {
            $row['profiles'] = ['full_name' => $row['full_name']];
            unset($row['full_name']);
        }
        api_ok(normalize_rows($rows));

    case 'agency/staff/add':
        require_method('POST');
        $inviter = current_user();
        $input = json_input();
        $companyId = required_string($input, 'company_id', 36);
        require_company_access($companyId, 'staff');
        $userId = required_string($input, 'user_id', 36);
        if (query_one('SELECT id FROM users WHERE id = ? AND status = \'active\'', [$userId]) === null) api_error('User not found.', 404);
        execute_sql('INSERT INTO agency_staff (id, company_id, user_id, role, permissions, status, invited_by) VALUES (?, ?, ?, ?, ?, \'active\', ?) ON DUPLICATE KEY UPDATE role = VALUES(role), permissions = VALUES(permissions), status = \'active\', invited_by = VALUES(invited_by)', [
            uuid_v4(), $companyId, $userId, $input['role'] ?? 'support', json_encode($input['permissions'] ?? []), $inviter['id'],
        ]);
        audit_log('company', $companyId, 'staff_added', null, ['user_id' => $userId]);
        api_ok();

    case 'agency/staff/remove':
        require_method('DELETE', 'POST');
        $input = json_input();
        $id = required_string($input, 'membership_id', 36);
        $membership = query_one('SELECT company_id, user_id FROM agency_staff WHERE id = ?', [$id]);
        if ($membership === null) api_error('Staff membership not found.', 404);
        require_company_access($membership['company_id'], 'staff');
        execute_sql('DELETE FROM agency_staff WHERE id = ?', [$id]);
        audit_log('company', $membership['company_id'], 'staff_removed', ['user_id' => $membership['user_id']]);
        api_ok();

    // ------------------------------------------------------------------
    // Commissions, support, reviews, inquiries and reports
    // ------------------------------------------------------------------
    case 'commissions':
        require_method('GET');
        $user = current_user();
        $companyId = trim((string) ($_GET['company_id'] ?? ''));
        if ($user['role'] === 'admin' && $companyId === '') {
            $rows = query_all('SELECT c.*, co.name AS company_name FROM commissions c JOIN companies co ON co.id = c.company_id ORDER BY c.created_at DESC');
        } else {
            if ($companyId === '') api_error('A company is required.', 422);
            if (!can_access_company($user, $companyId, 'finance')) api_error('You do not have access to these commissions.', 403);
            $rows = query_all('SELECT c.*, co.name AS company_name FROM commissions c JOIN companies co ON co.id = c.company_id WHERE c.company_id = ? ORDER BY c.created_at DESC', [$companyId]);
        }
        foreach ($rows as &$row) {
            $row['companies'] = ['name' => $row['company_name']];
            unset($row['company_name']);
        }
        api_ok(normalize_rows($rows));

    case 'commissions/collect':
        require_method('POST');
        require_role('admin');
        $input = json_input();
        $id = required_string($input, 'id', 36);
        execute_sql('UPDATE commissions SET status = \'collected\', collected_at = UTC_TIMESTAMP() WHERE id = ?', [$id]);
        audit_log('commission', $id, 'collected');
        api_ok();

    case 'support/send':
        require_method('POST');
        $user = current_user(false);
        $input = json_input();
        $id = uuid_v4();
        execute_sql('INSERT INTO support_messages (id, user_id, email, message) VALUES (?, ?, ?, ?)', [
            $id, $user['id'] ?? null, $user['email'] ?? nullable_string($input, 'email', 190), required_string($input, 'message', 10000),
        ]);
        audit_log('support_message', $id, 'created');
        api_ok(['id' => $id], 201);

    case 'support':
        require_method('GET');
        require_role('admin');
        api_ok(normalize_rows(query_all("SELECT * FROM support_messages WHERE status <> 'closed' ORDER BY created_at DESC")));

    case 'support/resolve':
        require_method('POST');
        $admin = require_role('admin');
        $input = json_input();
        $id = required_string($input, 'id', 36);
        execute_sql('UPDATE support_messages SET status = \'resolved\', assigned_to = ?, resolution_note = ?, resolved_at = UTC_TIMESTAMP() WHERE id = ?', [$admin['id'], nullable_string($input, 'resolution_note'), $id]);
        audit_log('support_message', $id, 'resolved');
        api_ok();

    case 'reviews/create':
        require_method('POST');
        $user = require_role('client');
        $input = json_input();
        $bookingId = required_string($input, 'booking_id', 36);
        $booking = query_one("SELECT * FROM bookings WHERE id = ? AND client_id = ? AND operational_stage = 'completed'", [$bookingId, $user['id']]);
        if ($booking === null) api_error('Only completed bookings can be reviewed.', 422);
        $rating = (int) ($input['rating'] ?? 0);
        if ($rating < 1 || $rating > 5) api_error('Rating must be between 1 and 5.', 422);
        $id = uuid_v4();
        execute_sql('INSERT INTO reviews (id, booking_id, company_id, client_id, rating, comment) VALUES (?, ?, ?, ?, ?, ?)', [$id, $bookingId, $booking['company_id'], $user['id'], $rating, trim((string) ($input['comment'] ?? ''))]);
        execute_sql('UPDATE companies SET rating = (SELECT AVG(rating) FROM reviews WHERE company_id = ? AND moderation_status = \'visible\'), reviews = (SELECT COUNT(*) FROM reviews WHERE company_id = ? AND moderation_status = \'visible\') WHERE id = ?', [$booking['company_id'], $booking['company_id'], $booking['company_id']]);
        audit_log('review', $id, 'created');
        api_ok(['id' => $id], 201);

    case 'reviews/reviewed':
        require_method('GET');
        $user = current_user();
        api_ok(array_column(query_all('SELECT booking_id FROM reviews WHERE client_id = ?', [$user['id']]), 'booking_id'));

    case 'reviews/company':
        require_method('GET');
        $companyId = required_string($_GET, 'company_id', 36);
        api_ok(normalize_rows(query_all("SELECT * FROM reviews WHERE company_id = ? AND moderation_status = 'visible' ORDER BY created_at DESC", [$companyId])));

    case 'reviews/reply':
        require_method('POST');
        $input = json_input();
        $id = required_string($input, 'review_id', 36);
        $review = query_one('SELECT company_id FROM reviews WHERE id = ?', [$id]);
        if ($review === null) api_error('Review not found.', 404);
        require_company_access($review['company_id'], 'reviews');
        execute_sql('UPDATE reviews SET public_reply = ?, replied_at = UTC_TIMESTAMP() WHERE id = ?', [required_string($input, 'reply', 5000), $id]);
        audit_log('review', $id, 'replied');
        api_ok();

    case 'reports/create':
        require_method('POST');
        $user = current_user();
        $input = json_input();
        $id = uuid_v4();
        execute_sql('INSERT INTO agency_reports (id, reporter_id, agency_id, reason, details) VALUES (?, ?, ?, ?, ?)', [$id, $user['id'], required_string($input, 'agency_id', 36), required_string($input, 'reason', 120), nullable_string($input, 'details')]);
        audit_log('agency_report', $id, 'created');
        api_ok(['id' => $id], 201);

    case 'inquiries/agency':
        require_method('GET');
        $companyId = required_string($_GET, 'agency_id', 36);
        require_company_access($companyId, 'inquiries');
        $rows = query_all('SELECT * FROM inquiries WHERE agency_id = ? ORDER BY updated_at DESC', [$companyId]);
        foreach ($rows as &$row) {
            $row['inquiry_messages'] = normalize_rows(query_all('SELECT * FROM inquiry_messages WHERE inquiry_id = ? ORDER BY created_at', [$row['id']]));
        }
        api_ok(normalize_rows($rows));

    case 'inquiries/reply':
        require_method('POST');
        $user = current_user();
        $input = json_input();
        $inquiryId = required_string($input, 'inquiry_id', 36);
        $inquiry = query_one('SELECT * FROM inquiries WHERE id = ?', [$inquiryId]);
        if ($inquiry === null) api_error('Inquiry not found.', 404);
        if ($inquiry['client_id'] !== $user['id'] && !can_access_company($user, $inquiry['agency_id'], 'inquiries')) api_error('You do not have access to this inquiry.', 403);
        $id = uuid_v4();
        execute_sql('INSERT INTO inquiry_messages (id, inquiry_id, sender_id, body) VALUES (?, ?, ?, ?)', [$id, $inquiryId, $user['id'], required_string($input, 'body', 10000)]);
        execute_sql('UPDATE inquiries SET updated_at = UTC_TIMESTAMP() WHERE id = ?', [$inquiryId]);
        api_ok(['id' => $id], 201);

    case 'errors/log':
        require_method('POST');
        $user = current_user(false);
        $input = json_input();
        execute_sql('INSERT INTO error_logs (id, user_id, message, stack, context, app_version) VALUES (?, ?, ?, ?, ?, ?)', [
            uuid_v4(), $user['id'] ?? null, required_string($input, 'message', 65535),
            nullable_string($input, 'stack', 1000000), nullable_string($input, 'context', 255), nullable_string($input, 'app_version', 50),
        ]);
        api_ok();

    case 'files/private':
        require_method('GET');
        $path = required_string($_GET, 'path', 500);
        $expires = (int) ($_GET['expires'] ?? 0);
        $signature = (string) ($_GET['sig'] ?? '');
        $expected = hash_hmac('sha256', $path . '|' . $expires, (string) config('db.password'));
        if ($expires < time() || $signature === '' || !hash_equals($expected, $signature)) api_error('This file link is invalid or has expired.', 403);
        $base = realpath((string) config('uploads.private_dir'));
        $file = $base === false ? false : realpath($base . '/' . ltrim($path, '/'));
        if ($file === false || !str_starts_with($file, $base . DIRECTORY_SEPARATOR) || !is_file($file)) api_error('File not found.', 404);
        $mime = (new finfo(FILEINFO_MIME_TYPE))->file($file) ?: 'application/octet-stream';
        header('Content-Type: ' . $mime);
        header('Content-Length: ' . filesize($file));
        header('Content-Disposition: inline; filename="' . basename($file) . '"');
        header('Cache-Control: private, max-age=300');
        readfile($file);
        exit;

    default:
        api_error('Endpoint not found.', 404, 'not_found');
}
