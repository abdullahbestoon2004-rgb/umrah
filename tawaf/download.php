<?php
declare(strict_types=1);

require __DIR__ . '/includes/bootstrap.php';
require_admin_dashboard();

$type = (string) ($_GET['type'] ?? '');
$id = (string) ($_GET['id'] ?? '');
$path = null;
$downloadName = 'document';

if ($type === 'agency') {
    $row = query_one('SELECT storage_path, file_name FROM agency_documents WHERE id = ?', [$id]);
    if ($row !== null) {
        $path = $row['storage_path'];
        $downloadName = $row['file_name'] ?: 'agency-document';
    }
} elseif ($type === 'identity') {
    $field = ($_GET['kind'] ?? '') === 'selfie' ? 'selfie_photo_url' : 'passport_photo_url';
    $row = query_one("SELECT {$field} AS storage_path, full_name FROM users WHERE id = ?", [$id]);
    if ($row !== null) {
        $path = $row['storage_path'];
        $downloadName = ($row['full_name'] ?: 'identity') . '-' . (($_GET['kind'] ?? '') === 'selfie' ? 'selfie' : 'passport');
    }
} elseif ($type === 'traveller') {
    $row = query_one('SELECT storage_path, original_name FROM traveller_documents WHERE id = ?', [$id]);
    if ($row !== null) {
        $path = $row['storage_path'];
        $downloadName = $row['original_name'] ?: 'traveller-document';
    }
}

if (!is_string($path) || $path === '') {
    http_response_code(404);
    exit('Document not found.');
}

$base = realpath((string) config('uploads.private_dir'));
$file = $base === false ? false : realpath($base . '/' . ltrim($path, '/'));
if ($file === false || !str_starts_with($file, $base . DIRECTORY_SEPARATOR) || !is_file($file)) {
    http_response_code(404);
    exit('The document file is not present on this server.');
}

$mime = (new finfo(FILEINFO_MIME_TYPE))->file($file) ?: 'application/octet-stream';
$safeName = preg_replace('/[^A-Za-z0-9._-]+/', '-', $downloadName);
header('Content-Type: ' . $mime);
header('Content-Length: ' . filesize($file));
header('Content-Disposition: inline; filename="' . $safeName . '"');
header('Cache-Control: private, no-store');
readfile($file);
exit;
