<?php
declare(strict_types=1);

/**
 * Tawaf backend configuration.
 *
 * This folder is denied by Apache in app/.htaccess. If your host supports
 * environment variables, they take precedence so the password does not need
 * to remain in this file after deployment.
 */
return [
    'app_env' => getenv('TAWAF_APP_ENV') ?: 'production',
    'app_url' => rtrim(getenv('TAWAF_APP_URL') ?: 'https://707222.xyz/tawafbackend', '/'),
    'admin_url' => rtrim(getenv('TAWAF_ADMIN_URL') ?: 'https://707222.xyz/tawaf', '/'),
    'timezone' => getenv('TAWAF_TIMEZONE') ?: 'Asia/Baghdad',
    'db' => [
        'host' => getenv('TAWAF_DB_HOST') ?: 'localhost',
        'port' => (int) (getenv('TAWAF_DB_PORT') ?: 3306),
        'name' => getenv('TAWAF_DB_NAME') ?: 'xyz_tawaf',
        'user' => getenv('TAWAF_DB_USER') ?: 'xyz_tawaf_user',
        'password' => getenv('TAWAF_DB_PASSWORD') ?: '=&_-$^6e*WBP',
        'charset' => 'utf8mb4',
    ],
    'auth' => [
        'token_days' => 30,
        'reset_code_minutes' => 15,
        'max_login_attempts' => 8,
        'login_window_minutes' => 15,
    ],
    'uploads' => [
        'max_bytes' => 10 * 1024 * 1024,
        'public_dir' => dirname(__DIR__) . '/uploads/public',
        'private_dir' => dirname(__DIR__) . '/uploads/private',
        'allowed_image_types' => ['image/jpeg', 'image/png', 'image/webp', 'image/heic'],
        'allowed_document_types' => [
            'image/jpeg', 'image/png', 'image/webp', 'image/heic',
            'application/pdf',
        ],
    ],
    'mail' => [
        'from' => getenv('TAWAF_MAIL_FROM') ?: 'noreply@707222.xyz',
        'support' => getenv('TAWAF_SUPPORT_EMAIL') ?: 'support@707222.xyz',
    ],
    'fib' => [
        'base_url' => rtrim(getenv('FIB_BASE_URL') ?: 'https://fib.stage.fib.iq', '/'),
        'client_id' => getenv('FIB_CLIENT_ID') ?: '',
        'client_secret' => getenv('FIB_CLIENT_SECRET') ?: '',
    ],
];
