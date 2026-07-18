<?php
declare(strict_types=1);

function fib_request(string $method, string $path, ?array $body = null, bool $form = false): array
{
    if (!function_exists('curl_init')) {
        throw new RuntimeException('The PHP cURL extension is required for FIB payments.');
    }
    $url = config('fib.base_url') . $path;
    $curl = curl_init($url);
    $headers = [];
    $options = [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 25,
        CURLOPT_CUSTOMREQUEST => $method,
    ];
    if ($body !== null) {
        $payload = $form ? http_build_query($body) : json_encode($body, JSON_UNESCAPED_SLASHES);
        $options[CURLOPT_POSTFIELDS] = $payload;
        $headers[] = $form ? 'Content-Type: application/x-www-form-urlencoded' : 'Content-Type: application/json';
    }
    if ($headers !== []) {
        $options[CURLOPT_HTTPHEADER] = $headers;
    }
    curl_setopt_array($curl, $options);
    $raw = curl_exec($curl);
    $status = (int) curl_getinfo($curl, CURLINFO_HTTP_CODE);
    $error = curl_error($curl);
    curl_close($curl);
    if ($raw === false || $status < 200 || $status >= 300) {
        throw new RuntimeException('FIB request failed' . ($error !== '' ? ": {$error}" : " with HTTP {$status}"));
    }
    $decoded = json_decode((string) $raw, true);
    if (!is_array($decoded)) {
        throw new RuntimeException('FIB returned an invalid response.');
    }
    return $decoded;
}

function fib_access_token(): string
{
    $clientId = (string) config('fib.client_id');
    $secret = (string) config('fib.client_secret');
    if ($clientId === '' || $secret === '') {
        throw new RuntimeException('FIB payments are not configured on this server.');
    }
    $response = fib_request('POST', '/auth/realms/fib-online-shop/protocol/openid-connect/token', [
        'grant_type' => 'client_credentials',
        'client_id' => $clientId,
        'client_secret' => $secret,
    ], true);
    if (empty($response['access_token'])) {
        throw new RuntimeException('FIB authentication did not return an access token.');
    }
    return (string) $response['access_token'];
}

function fib_authorized_request(string $method, string $path, ?array $body = null): array
{
    $url = config('fib.base_url') . $path;
    $curl = curl_init($url);
    $headers = [
        'Authorization: Bearer ' . fib_access_token(),
        'Content-Type: application/json',
    ];
    $options = [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 25,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_HTTPHEADER => $headers,
    ];
    if ($body !== null) {
        $options[CURLOPT_POSTFIELDS] = json_encode($body, JSON_UNESCAPED_SLASHES);
    }
    curl_setopt_array($curl, $options);
    $raw = curl_exec($curl);
    $status = (int) curl_getinfo($curl, CURLINFO_HTTP_CODE);
    $error = curl_error($curl);
    curl_close($curl);
    if ($raw === false || $status < 200 || $status >= 300) {
        throw new RuntimeException('FIB request failed' . ($error !== '' ? ": {$error}" : " with HTTP {$status}"));
    }
    $decoded = json_decode((string) $raw, true);
    if (!is_array($decoded)) {
        throw new RuntimeException('FIB returned an invalid response.');
    }
    return $decoded;
}

function fib_create_payment(int $amountIqd, string $bookingId): array
{
    return fib_authorized_request('POST', '/protected/v1/payments', [
        'monetaryValue' => ['amount' => (string) $amountIqd, 'currency' => 'IQD'],
        'statusCallbackUrl' => config('app_url') . '/webhooks/fib',
        'description' => "Umrah booking {$bookingId}",
    ]);
}

function fib_payment_status(string $providerReference): string
{
    $response = fib_authorized_request('GET', '/protected/v1/payments/' . rawurlencode($providerReference) . '/status');
    return strtoupper((string) ($response['status'] ?? 'UNPAID'));
}

function record_payment_success(string $paymentId): void
{
    $pdo = db();
    $pdo->beginTransaction();
    try {
        $payment = query_one('SELECT * FROM payments WHERE id = ? FOR UPDATE', [$paymentId]);
        if ($payment === null || $payment['status'] !== 'initiated') {
            $pdo->commit();
            return;
        }
        $booking = query_one('SELECT * FROM bookings WHERE id = ? FOR UPDATE', [$payment['booking_id']]);
        if ($booking === null) {
            throw new RuntimeException('Payment booking not found.');
        }
        execute_sql('UPDATE payments SET status = \'succeeded\', confirmed_at = UTC_TIMESTAMP(), updated_at = UTC_TIMESTAMP() WHERE id = ?', [$paymentId]);
        $paid = min((int) $booking['total_iqd'], (int) $booking['amount_paid_iqd'] + (int) $payment['amount_iqd']);
        $payStatus = $paid >= (int) $booking['total_iqd'] ? 'paid' : 'partially_paid';
        $stage = $paid >= (int) $booking['amount_due_now_iqd'] && in_array($booking['operational_stage'], ['requested', 'awaiting_payment'], true)
            ? 'confirmed'
            : $booking['operational_stage'];
        execute_sql('UPDATE bookings SET amount_paid_iqd = ?, pay_status = ?, operational_stage = ?, status = IF(? = \'confirmed\', \'confirmed\', status), updated_at = UTC_TIMESTAMP() WHERE id = ?', [$paid, $payStatus, $stage, $stage, $booking['id']]);

        $ratio = (int) $booking['total_iqd'] > 0 ? $paid / (int) $booking['total_iqd'] : 0;
        $target = $booking['pay_method'] === 'cash'
            ? -(int) round((int) $booking['commission_iqd'] * $ratio)
            : (int) round((int) $booking['payout_iqd'] * $ratio);
        $ledgered = query_one('SELECT COALESCE(SUM(amount_iqd), 0) AS amount FROM agency_ledger WHERE booking_id = ?', [$booking['id']]);
        $delta = $target - (int) ($ledgered['amount'] ?? 0);
        if ($delta !== 0) {
            execute_sql('INSERT INTO agency_ledger (id, company_id, booking_id, payment_id, entry_type, amount_iqd, description) VALUES (?, ?, ?, ?, ?, ?, ?)', [
                uuid_v4(), $booking['company_id'], $booking['id'], $paymentId,
                $booking['pay_method'] === 'cash' ? 'cash_commission_debit' : 'booking_credit',
                $delta, $booking['pay_method'] === 'cash' ? 'Commission owed on cash payment' : 'Agency share of online payment',
            ]);
        }
        execute_sql('INSERT INTO commissions (id, booking_id, company_id, amount_iqd, status) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE amount_iqd = VALUES(amount_iqd)', [
            uuid_v4(), $booking['id'], $booking['company_id'], $booking['commission_iqd'], $booking['pay_method'] === 'cash' ? 'owed' : 'collected',
        ]);
        execute_sql('INSERT INTO notifications (id, user_id, type, arg) VALUES (?, ?, \'bookingConfirmed\', (SELECT title FROM packages WHERE id = ?))', [uuid_v4(), $booking['client_id'], $booking['package_id']]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
}

function record_payment_failure(string $paymentId, string $reason): void
{
    execute_sql('UPDATE payments SET status = \'failed\', failure_reason = ?, updated_at = UTC_TIMESTAMP() WHERE id = ? AND status = \'initiated\'', [$reason, $paymentId]);
}
