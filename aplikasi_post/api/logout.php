<?php
require_once __DIR__ . '/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, 'Method tidak diizinkan. Gunakan POST.', null, 405);
}

$token = getBearerToken();
if ($token) {
    $token = mysqli_real_escape_string($koneksi, $token);
    mysqli_query($koneksi, "DELETE FROM tokens WHERE token = '$token'");
}

jsonResponse(true, 'Logout berhasil.');
