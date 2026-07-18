<?php
declare(strict_types=1);

define('TAWAF_BACKEND_ROOT', dirname(__DIR__));

function config(?string $key = null, mixed $default = null): mixed
{
    static $configuration;
    if ($configuration === null) {
        $configuration = require __DIR__ . '/config.php';
    }
    if ($key === null) {
        return $configuration;
    }
    $value = $configuration;
    foreach (explode('.', $key) as $segment) {
        if (!is_array($value) || !array_key_exists($segment, $value)) {
            return $default;
        }
        $value = $value[$segment];
    }
    return $value;
}

date_default_timezone_set((string) config('timezone', 'Asia/Baghdad'));

function db(): PDO
{
    static $pdo;
    if ($pdo instanceof PDO) {
        return $pdo;
    }
    $cfg = config('db');
    $dsn = sprintf(
        'mysql:host=%s;port=%d;dbname=%s;charset=%s',
        $cfg['host'],
        $cfg['port'],
        $cfg['name'],
        $cfg['charset']
    );
    $pdo = new PDO($dsn, $cfg['user'], $cfg['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET time_zone = '+03:00'",
    ]);
    return $pdo;
}

function uuid_v4(): string
{
    $bytes = random_bytes(16);
    $bytes[6] = chr((ord($bytes[6]) & 0x0f) | 0x40);
    $bytes[8] = chr((ord($bytes[8]) & 0x3f) | 0x80);
    $hex = bin2hex($bytes);
    return sprintf('%s-%s-%s-%s-%s',
        substr($hex, 0, 8), substr($hex, 8, 4), substr($hex, 12, 4),
        substr($hex, 16, 4), substr($hex, 20)
    );
}

function utc_now(): string
{
    return gmdate('Y-m-d H:i:s');
}

function json_input(): array
{
    $raw = file_get_contents('php://input') ?: '';
    if ($raw === '') {
        return [];
    }
    try {
        $value = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        api_error('Invalid JSON body.', 400);
    }
    if (!is_array($value)) {
        api_error('The request body must be a JSON object.', 400);
    }
    return $value;
}

function api_response(array $payload, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    header('X-Content-Type-Options: nosniff');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function api_ok(mixed $data = null, int $status = 200): never
{
    api_response(['success' => true, 'data' => $data], $status);
}

function api_error(string $message, int $status = 400, ?string $code = null): never
{
    $error = ['message' => $message];
    if ($code !== null) {
        $error['code'] = $code;
    }
    api_response(['success' => false, 'error' => $error], $status);
}

function require_method(string ...$allowed): void
{
    $method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    if (!in_array($method, $allowed, true)) {
        header('Allow: ' . implode(', ', $allowed));
        api_error('Method not allowed.', 405);
    }
}

function required_string(array $input, string $key, int $max = 255): string
{
    $value = trim((string) ($input[$key] ?? ''));
    if ($value === '') {
        api_error("The {$key} field is required.", 422);
    }
    if (mb_strlen($value) > $max) {
        api_error("The {$key} field is too long.", 422);
    }
    return $value;
}

function nullable_string(array $input, string $key, int $max = 65535): ?string
{
    if (!array_key_exists($key, $input) || $input[$key] === null) {
        return null;
    }
    $value = trim((string) $input[$key]);
    if (mb_strlen($value) > $max) {
        api_error("The {$key} field is too long.", 422);
    }
    return $value === '' ? null : $value;
}

function query_all(string $sql, array $params = []): array
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

function query_one(string $sql, array $params = []): ?array
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row === false ? null : $row;
}

function execute_sql(string $sql, array $params = []): int
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt->rowCount();
}

function placeholders(int $count): string
{
    return implode(',', array_fill(0, $count, '?'));
}

function normalize_row(array $row): array
{
    static $boolFields = [
        'is_active', 'is_verified', 'is_promoted', 'first_offer_approved',
        'is_published', 'is_featured', 'bus_between_cities', 'airport_transfers',
        'non_refundable_deposit', 'is_lead', 'read', 'included',
        'non_refundable_deposit_snapshot', 'is_default',
        'marketing_emails', 'share_activity', 'two_factor_enabled',
        'force_password_change',
    ];
    static $intFields = [
        'since', 'reviews', 'pilgrims_served', 'median_response_minutes',
        'acc_stars', 'days', 'nights', 'meals_per_day', 'content_version',
        'capacity', 'seats_reserved', 'day_no', 'sort_order', 'star_rating',
        'distance_from_haram_m', 'travellers', 'room_count', 'room_occupancy',
        'quote_version', 'assigned_count', 'unread_count',
    ];
    static $numberFields = [
        'price_iqd', 'price_usd', 'original_iqd', 'deposit_iqd', 'unit_price_iqd',
        'total_iqd', 'commission_iqd', 'payout_iqd', 'amount_due_now_iqd',
        'amount_paid_iqd', 'refund_due_iqd', 'amount_iqd', 'refunded_iqd',
        'balance_iqd', 'commission_rate',
    ];
    static $jsonFields = [
        'tags', 'branches', 'gallery_urls', 'accepted_payment_methods',
        'verification_details', 'includes', 'room_occupancies', 'photo_urls',
        'permissions', 'quote_snapshot', 'metadata', 'before_data', 'after_data',
    ];
    foreach ($row as $key => $value) {
        if (is_array($value)) {
            $row[$key] = array_is_list($value)
                ? array_map(fn($item) => is_array($item) ? normalize_row($item) : $item, $value)
                : normalize_row($value);
        } elseif (in_array($key, $boolFields, true)) {
            $row[$key] = (bool) $value;
        } elseif (in_array($key, $intFields, true) && $value !== null) {
            $row[$key] = (int) $value;
        } elseif (in_array($key, $numberFields, true) && $value !== null) {
            $row[$key] = is_numeric($value) ? (float) $value : 0.0;
        } elseif ($key === 'rating' && $value !== null) {
            $row[$key] = str_contains((string) $value, '.') ? (float) $value : (int) $value;
        } elseif (in_array($key, $jsonFields, true)) {
            if ($value === null || $value === '') {
                $row[$key] = in_array($key, ['quote_snapshot', 'metadata', 'before_data', 'after_data'], true) ? [] : [];
            } elseif (is_string($value)) {
                $decoded = json_decode($value, true);
                $row[$key] = is_array($decoded) ? $decoded : [];
            }
        } elseif ($value !== null && str_ends_with($key, '_count')) {
            $row[$key] = (int) $value;
        }
    }
    return $row;
}

function normalize_rows(array $rows): array
{
    return array_map('normalize_row', $rows);
}

function bearer_token(): ?string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if ($header === '' && function_exists('getallheaders')) {
        $headers = getallheaders();
        $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }
    return preg_match('/^Bearer\s+(.+)$/i', $header, $match) ? trim($match[1]) : null;
}

function issue_token(string $userId, ?string $label = null): string
{
    $plain = bin2hex(random_bytes(32));
    $days = (int) config('auth.token_days', 30);
    execute_sql(
        'INSERT INTO auth_sessions (id, user_id, token_hash, device_label, ip_address, user_agent, expires_at) VALUES (?, ?, ?, ?, ?, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? DAY))',
        [uuid_v4(), $userId, hash('sha256', $plain), $label,
            substr((string) ($_SERVER['REMOTE_ADDR'] ?? ''), 0, 45),
            substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 255), $days]
    );
    return $plain;
}

function current_user(bool $required = true): ?array
{
    static $resolved = false;
    static $user;
    if ($resolved) {
        if ($required && $user === null) {
            api_error('Authentication required.', 401, 'unauthorized');
        }
        return $user;
    }
    $resolved = true;
    $token = bearer_token();
    if ($token !== null) {
        $user = query_one(
            'SELECT u.id, u.email, u.role, u.full_name, u.phone, u.status, u.force_password_change, s.id AS session_id
             FROM auth_sessions s JOIN users u ON u.id = s.user_id
             WHERE s.token_hash = ? AND s.revoked_at IS NULL AND s.expires_at > UTC_TIMESTAMP() AND u.status = \'active\' LIMIT 1',
            [hash('sha256', $token)]
        );
        if ($user !== null) {
            execute_sql('UPDATE auth_sessions SET last_used_at = UTC_TIMESTAMP() WHERE id = ?', [$user['session_id']]);
            $user = normalize_row($user);
        }
    }
    if ($required && $user === null) {
        api_error('Authentication required.', 401, 'unauthorized');
    }
    return $user;
}

function require_role(string ...$roles): array
{
    $user = current_user();
    if (!in_array($user['role'], $roles, true)) {
        api_error('You do not have permission to perform this action.', 403, 'forbidden');
    }
    return $user;
}

function can_access_company(array $user, string $companyId, ?string $permission = null): bool
{
    if ($user['role'] === 'admin') {
        return true;
    }
    $company = query_one('SELECT owner_id FROM companies WHERE id = ?', [$companyId]);
    if ($company !== null && hash_equals((string) $company['owner_id'], (string) $user['id'])) {
        return true;
    }
    $membership = query_one(
        'SELECT permissions FROM agency_staff WHERE company_id = ? AND user_id = ? AND status = \'active\'',
        [$companyId, $user['id']]
    );
    if ($membership === null) {
        return false;
    }
    if ($permission === null) {
        return true;
    }
    $permissions = json_decode((string) ($membership['permissions'] ?? '[]'), true) ?: [];
    return in_array('*', $permissions, true) || in_array($permission, $permissions, true);
}

function require_company_access(string $companyId, ?string $permission = null): array
{
    $user = current_user();
    if (!can_access_company($user, $companyId, $permission)) {
        api_error('You do not have access to this agency.', 403, 'forbidden');
    }
    return $user;
}

function audit_log(string $entityType, ?string $entityId, string $action, mixed $before = null, mixed $after = null, ?string $note = null): void
{
    $user = current_user(false);
    try {
        execute_sql(
            'INSERT INTO audit_logs (id, actor_id, actor_role, entity_type, entity_id, action, before_data, after_data, note, ip_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [uuid_v4(), $user['id'] ?? null, $user['role'] ?? 'system', $entityType,
                $entityId, $action,
                $before === null ? null : json_encode($before, JSON_UNESCAPED_UNICODE),
                $after === null ? null : json_encode($after, JSON_UNESCAPED_UNICODE),
                $note, substr((string) ($_SERVER['REMOTE_ADDR'] ?? ''), 0, 45)]
        );
    } catch (Throwable) {
        // Auditing must never turn a successful user operation into a failure.
    }
}

function enforce_rate_limit(string $action, string $identifier, int $maxAttempts, int $windowMinutes): void
{
    $keyHash = hash('sha256', strtolower(trim($identifier)) . '|' . ($_SERVER['REMOTE_ADDR'] ?? ''));
    execute_sql('DELETE FROM rate_limits WHERE expires_at <= UTC_TIMESTAMP()');
    $row = query_one('SELECT id, attempts FROM rate_limits WHERE action_name = ? AND key_hash = ? AND expires_at > UTC_TIMESTAMP()', [$action, $keyHash]);
    if ($row !== null && (int) $row['attempts'] >= $maxAttempts) {
        api_error('Too many attempts. Please wait and try again.', 429, 'rate_limited');
    }
    if ($row === null) {
        execute_sql('INSERT INTO rate_limits (id, action_name, key_hash, attempts, expires_at) VALUES (?, ?, ?, 1, DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? MINUTE))', [uuid_v4(), $action, $keyHash, $windowMinutes]);
    } else {
        execute_sql('UPDATE rate_limits SET attempts = attempts + 1 WHERE id = ?', [$row['id']]);
    }
}

function clear_rate_limit(string $action, string $identifier): void
{
    $keyHash = hash('sha256', strtolower(trim($identifier)) . '|' . ($_SERVER['REMOTE_ADDR'] ?? ''));
    execute_sql('DELETE FROM rate_limits WHERE action_name = ? AND key_hash = ?', [$action, $keyHash]);
}

function safe_upload(array $file, bool $public, array $allowedTypes, string $prefix): array
{
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
        api_error('The file upload failed.', 422);
    }
    $max = (int) config('uploads.max_bytes');
    if (($file['size'] ?? 0) < 1 || $file['size'] > $max) {
        api_error('The uploaded file is empty or too large.', 422);
    }
    $mime = (new finfo(FILEINFO_MIME_TYPE))->file($file['tmp_name']) ?: '';
    if (!in_array($mime, $allowedTypes, true)) {
        api_error('This file type is not allowed.', 422);
    }
    $extensions = [
        'image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp',
        'image/heic' => 'heic', 'application/pdf' => 'pdf',
    ];
    $name = preg_replace('/[^a-zA-Z0-9_-]+/', '-', trim($prefix, '/'));
    $relative = trim($name, '-') . '/' . uuid_v4() . '.' . ($extensions[$mime] ?? 'bin');
    $base = $public ? config('uploads.public_dir') : config('uploads.private_dir');
    $absolute = rtrim((string) $base, '/') . '/' . $relative;
    $directory = dirname($absolute);
    if (!is_dir($directory) && !mkdir($directory, 0750, true) && !is_dir($directory)) {
        api_error('The upload directory is not writable.', 500);
    }
    if (!move_uploaded_file($file['tmp_name'], $absolute)) {
        api_error('Unable to save the uploaded file.', 500);
    }
    return [
        'path' => $relative,
        'url' => $public ? config('app_url') . '/uploads/public/' . implode('/', array_map('rawurlencode', explode('/', $relative))) : null,
        'mime' => $mime,
        'size' => (int) $file['size'],
        'original_name' => substr((string) ($file['name'] ?? 'upload'), 0, 255),
    ];
}

function public_upload(array $file, string $prefix): array
{
    return safe_upload($file, true, config('uploads.allowed_image_types'), $prefix);
}

function private_upload(array $file, string $prefix): array
{
    return safe_upload($file, false, config('uploads.allowed_document_types'), $prefix);
}

function send_reset_email(string $email, string $code): void
{
    $subject = 'Your Tawaf password reset code';
    $message = "Your Tawaf password reset code is: {$code}\n\nIt expires in " . config('auth.reset_code_minutes') . " minutes.\nIf you did not request this, ignore this email.";
    $headers = [
        'From: Tawaf <' . config('mail.from') . '>',
        'Content-Type: text/plain; charset=UTF-8',
    ];
    @mail($email, $subject, $message, implode("\r\n", $headers));
}

function company_row(string $companyId): ?array
{
    $company = query_one('SELECT * FROM companies WHERE id = ?', [$companyId]);
    return $company === null ? null : hydrate_company($company);
}

function hydrate_company(array $company): array
{
    $badges = query_all(
        'SELECT ab.assigned_at, b.badge_key AS `key`, b.name_ku, b.name_ar, b.name_en, b.icon, b.type
         FROM agency_badges ab JOIN badges b ON b.id = ab.badge_id WHERE ab.agency_id = ? ORDER BY ab.assigned_at',
        [$company['id']]
    );
    $company['agency_badges'] = array_map(fn($badge) => ['assigned_at' => $badge['assigned_at'], 'badges' => normalize_row($badge)], $badges);
    return normalize_row($company);
}

function hydrate_companies(array $companies): array
{
    return array_map('hydrate_company', $companies);
}

function hydrate_package(array $package): array
{
    $id = $package['id'];
    $package['itinerary_days'] = normalize_rows(query_all('SELECT * FROM itinerary_days WHERE package_id = ? ORDER BY day_no', [$id]));
    $package['offer_pricing'] = normalize_rows(query_all('SELECT * FROM offer_pricing WHERE package_id = ? ORDER BY occupancy_type', [$id]));
    $package['offer_hotels'] = array_map(function ($row) {
        $hotel = query_one('SELECT * FROM hotels WHERE id = ?', [$row['hotel_id']]);
        $row['hotels'] = $hotel === null ? [] : normalize_row($hotel);
        return normalize_row($row);
    }, query_all('SELECT * FROM offer_hotels WHERE package_id = ? ORDER BY city', [$id]));
    $package['offer_inclusions'] = normalize_rows(query_all('SELECT * FROM offer_inclusions WHERE package_id = ? ORDER BY sort_order', [$id]));
    $package['offer_media'] = normalize_rows(query_all('SELECT * FROM offer_media WHERE package_id = ? ORDER BY sort_order', [$id]));
    return normalize_row($package);
}

function hydrate_packages(array $packages): array
{
    return array_map('hydrate_package', $packages);
}

function hydrate_booking(array $booking): array
{
    $package = query_one('SELECT title, title_ar, title_en, return_date FROM packages WHERE id = ?', [$booking['package_id']]);
    $company = query_one('SELECT name, name_ar, name_en, tint, is_verified FROM companies WHERE id = ?', [$booking['company_id']]);
    $booking['packages'] = normalize_row($package ?? []);
    $booking['companies'] = normalize_row($company ?? []);
    $booking['booking_travellers'] = normalize_rows(query_all(
        'SELECT document_status, visa_status FROM booking_travellers WHERE booking_id = ?',
        [$booking['id']]
    ));
    return normalize_row($booking);
}

function hydrate_bookings(array $bookings): array
{
    return array_map('hydrate_booking', $bookings);
}

function replace_package_children(string $packageId, array $input): void
{
    foreach (['itinerary_days', 'offer_pricing', 'offer_hotels', 'offer_inclusions'] as $table) {
        execute_sql("DELETE FROM {$table} WHERE package_id = ?", [$packageId]);
    }
    foreach (($input['itinerary'] ?? []) as $index => $day) {
        execute_sql('INSERT INTO itinerary_days (id, package_id, day_no, title, summary) VALUES (?, ?, ?, ?, ?)', [
            uuid_v4(), $packageId, (int) ($day['day_no'] ?? $index + 1), trim((string) ($day['title'] ?? '')), trim((string) ($day['summary'] ?? '')),
        ]);
    }
    foreach (($input['pricing'] ?? []) as $price) {
        execute_sql('INSERT INTO offer_pricing (id, package_id, occupancy_type, price_iqd, price_usd) VALUES (?, ?, ?, ?, ?)', [
            uuid_v4(), $packageId, $price['occupancy_type'] ?? 'double', (int) ($price['price_iqd'] ?? 0), $price['price_usd'] ?? null,
        ]);
    }
    foreach (($input['hotels'] ?? []) as $hotelInput) {
        $hotelId = uuid_v4();
        execute_sql('INSERT INTO hotels (id, name, name_ar, name_en, description, description_ar, description_en, city, star_rating, photo_urls) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            $hotelId, $hotelInput['name'] ?? '', $hotelInput['name_ar'] ?? null, $hotelInput['name_en'] ?? null,
            $hotelInput['description'] ?? '', $hotelInput['description_ar'] ?? null, $hotelInput['description_en'] ?? null,
            $hotelInput['city'] ?? 'makkah', (int) ($hotelInput['star_rating'] ?? 3), json_encode($hotelInput['photo_urls'] ?? []),
        ]);
        execute_sql('INSERT INTO offer_hotels (package_id, hotel_id, city, nights, distance_from_haram_m) VALUES (?, ?, ?, ?, ?)', [
            $packageId, $hotelId, $hotelInput['city'] ?? 'makkah', (int) ($hotelInput['nights'] ?? 0), (int) ($hotelInput['distance_from_haram_m'] ?? 0),
        ]);
    }
    foreach (($input['inclusions'] ?? []) as $index => $item) {
        execute_sql('INSERT INTO offer_inclusions (id, package_id, type, included, details, details_ar, details_en, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [
            uuid_v4(), $packageId, $item['type'] ?? '', !empty($item['included']) ? 1 : 0,
            $item['details'] ?? '', $item['details_ar'] ?? null, $item['details_en'] ?? null, $index,
        ]);
    }
}

function update_allowed_fields(string $table, string $id, array $input, array $allowed): int
{
    $parts = [];
    $params = [];
    foreach ($allowed as $field => $transform) {
        $key = is_int($field) ? $transform : $field;
        if (!array_key_exists($key, $input)) {
            continue;
        }
        $parts[] = "`{$key}` = ?";
        $value = $input[$key];
        if ($transform === 'json') {
            $value = json_encode($value ?? [], JSON_UNESCAPED_UNICODE);
        } elseif ($transform === 'bool') {
            $value = !empty($value) ? 1 : 0;
        }
        $params[] = $value;
    }
    if ($parts === []) {
        return 0;
    }
    $params[] = $id;
    return execute_sql("UPDATE `{$table}` SET " . implode(', ', $parts) . ', updated_at = UTC_TIMESTAMP() WHERE id = ?', $params);
}

set_exception_handler(function (Throwable $error): void {
    error_log((string) $error);
    if (config('app_env') === 'development') {
        api_error($error->getMessage(), 500, 'server_error');
    }
    api_error('An internal server error occurred.', 500, 'server_error');
});
