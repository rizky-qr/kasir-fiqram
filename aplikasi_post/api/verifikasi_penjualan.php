<?php
// Gunakan helpers.php yang sudah berisi koneksi DB, CORS, dan fungsi standar
require_once __DIR__ . '/helpers.php';

// Hanya izinkan POST
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, 'Method tidak diizinkan.', null, 405);
}

// Autentikasi — hanya admin yang boleh verifikasi
$authUser = requireAuth($koneksi);
if (strtolower($authUser['level']) !== 'admin') {
    jsonResponse(false, 'Akses ditolak. Hanya admin yang dapat memverifikasi pesanan.', null, 403);
}

$body         = getJsonBody();
$id_penjualan = (int) ($body['id_penjualan'] ?? $_POST['id_penjualan'] ?? 0);

if ($id_penjualan <= 0) {
    jsonResponse(false, 'ID Penjualan tidak valid.', null, 400);
}

// Cek apakah pesanan ada dan belum diverifikasi
$esc = mysqli_real_escape_string($koneksi, $id_penjualan);
$res = mysqli_query($koneksi, "SELECT status FROM penjualan WHERE id_penjualan = '$esc' LIMIT 1");

if (!$res || mysqli_num_rows($res) === 0) {
    jsonResponse(false, 'Data penjualan tidak ditemukan.', null, 404);
}

$row = mysqli_fetch_assoc($res);
$statusSekarang = strtolower($row['status'] ?? '');

if ($statusSekarang === 'terverifikasi' || $statusSekarang === 'selesai') {
    jsonResponse(false, 'Pesanan ini sudah diverifikasi sebelumnya.', null, 409);
}

// Update status penjualan menjadi Terverifikasi
// CATATAN: Stok sudah dikurangi saat pesanan dibuat (di penjualan.php POST).
// Tidak perlu kurangi stok lagi di sini untuk menghindari double-deduction.
$ok = mysqli_query($koneksi, "
    UPDATE penjualan 
    SET status = 'Terverifikasi' 
    WHERE id_penjualan = '$esc'
");

if (!$ok) {
    jsonResponse(false, 'Gagal mengupdate status pesanan: ' . mysqli_error($koneksi), null, 500);
}

jsonResponse(true, "Pesanan #$id_penjualan berhasil diverifikasi.");