<?php
declare(strict_types=1);

require dirname(__DIR__) . '/app/bootstrap.php';
require dirname(__DIR__) . '/app/payments.php';

require_method('POST');
$input = json_input();
$payment = null;
if (!empty($input['payment_id'])) {
    $payment = query_one('SELECT * FROM payments WHERE id = ? AND method = \'fib\'', [(string) $input['payment_id']]);
} elseif (!empty($input['id'])) {
    $payment = query_one('SELECT * FROM payments WHERE provider_reference = ? AND method = \'fib\'', [(string) $input['id']]);
}
if ($payment === null || empty($payment['provider_reference'])) {
    api_ok(['matched' => false]);
}
if ($payment['status'] !== 'initiated') {
    api_ok(['matched' => true, 'status' => $payment['status']]);
}
$status = fib_payment_status((string) $payment['provider_reference']);
if ($status === 'PAID') {
    record_payment_success((string) $payment['id']);
} elseif ($status === 'DECLINED') {
    record_payment_failure((string) $payment['id'], 'Declined by FIB');
}
api_ok(['matched' => true, 'status' => $status]);
