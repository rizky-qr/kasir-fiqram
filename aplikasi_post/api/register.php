<?php
require_once __DIR__ . '/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, 'Method tidak diizinkan. Gunakan POST.', null, 405);
}

$body     = getJsonBody();
$namaUser = trim($body['nama_user'] ?? '');
$username = trim($body['username'] ?? '');
$email    = trim($body['email'] ?? '');
$noHp     = trim($body['no_hp'] ?? '');
$password = trim($body['password'] ?? '');

// ─── Validasi input ───────────────────────────────────────────────────────────
if (empty($namaUser) || empty($username) || empty($password)) {
    jsonResponse(false, 'Nama, username, dan password wajib diisi.', null, 400);
}

if (strlen($password) < 6) {
    jsonResponse(false, 'Password minimal 6 karakter.', null, 400);
}

if (!empty($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonResponse(false, 'Format email tidak valid.', null, 400);
}

// ─── Cek duplikat username ────────────────────────────────────────────────────
$stmtCekUser = mysqli_prepare($koneksi, "SELECT id_user FROM user WHERE username = ? LIMIT 1");
mysqli_stmt_bind_param($stmtCekUser, 's', $username);
mysqli_stmt_execute($stmtCekUser);
mysqli_stmt_store_result($stmtCekUser);

if (mysqli_stmt_num_rows($stmtCekUser) > 0) {
    mysqli_stmt_close($stmtCekUser);
    jsonResponse(false, 'Username sudah digunakan. Silakan pilih username lain.', null, 409);
}
mysqli_stmt_close($stmtCekUser);

// ─── Cek duplikat email (jika diisi) ─────────────────────────────────────────
if (!empty($email)) {
    $stmtCekEmail = mysqli_prepare($koneksi, "SELECT id_user FROM user WHERE email = ? AND email != '' LIMIT 1");
    mysqli_stmt_bind_param($stmtCekEmail, 's', $email);
    mysqli_stmt_execute($stmtCekEmail);
    mysqli_stmt_store_result($stmtCekEmail);

    if (mysqli_stmt_num_rows($stmtCekEmail) > 0) {
        mysqli_stmt_close($stmtCekEmail);
        jsonResponse(false, 'Email sudah terdaftar. Gunakan email lain atau langsung login.', null, 409);
    }
    mysqli_stmt_close($stmtCekEmail);
}

// ─── Pastikan kolom email & no_hp ada (auto-migrate) ─────────────────────────
mysqli_query($koneksi, "ALTER TABLE user ADD COLUMN IF NOT EXISTS email VARCHAR(100) DEFAULT '' AFTER nama_user");
mysqli_query($koneksi, "ALTER TABLE user ADD COLUMN IF NOT EXISTS no_hp VARCHAR(20) DEFAULT '' AFTER email");

// ─── Hash password & insert ───────────────────────────────────────────────────
$hashedPw = md5($password);
$level    = 'pelanggan';

$stmtInsert = mysqli_prepare($koneksi,
    "INSERT INTO user (nama_user, email, no_hp, username, password, level) VALUES (?, ?, ?, ?, ?, ?)"
);
mysqli_stmt_bind_param($stmtInsert, 'ssssss', $namaUser, $email, $noHp, $username, $hashedPw, $level);
$ok = mysqli_stmt_execute($stmtInsert);

if (!$ok) {
    // Fallback tanpa kolom email/no_hp (tabel lama)
    mysqli_stmt_close($stmtInsert);
    $stmtFallback = mysqli_prepare($koneksi,
        "INSERT INTO user (nama_user, username, password, level) VALUES (?, ?, ?, ?)"
    );
    mysqli_stmt_bind_param($stmtFallback, 'ssss', $namaUser, $username, $hashedPw, $level);
    $ok2 = mysqli_stmt_execute($stmtFallback);
    mysqli_stmt_close($stmtFallback);

    if (!$ok2) {
        jsonResponse(false, 'Gagal mendaftarkan akun: ' . mysqli_error($koneksi), null, 500);
    }
} else {
    mysqli_stmt_close($stmtInsert);
}

jsonResponse(true, 'Akun berhasil dibuat! Silakan login dengan username dan password Anda.', [
    'username' => $username,
    'level'    => $level,
]);
