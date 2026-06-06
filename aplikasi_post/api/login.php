<?php
require_once __DIR__ . '/helpers.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(false, 'Method tidak diizinkan. Gunakan POST.', null, 405);
}

$username = trim($_POST['username'] ?? '');
$password = trim($_POST['password'] ?? '');

if (empty($username) || empty($password)) {
    jsonResponse(false, 'Username dan password wajib diisi.', null, 400);
}

$username = mysqli_real_escape_string($koneksi, $username);
$hashedPw = md5($password);

$query = mysqli_query($koneksi, "
    SELECT * FROM user
    WHERE username = '$username'
    AND password = '$hashedPw'
    LIMIT 1
");

$userData = mysqli_fetch_assoc($query);

if (!$userData) {
    jsonResponse(false, 'Username atau password salah.', null, 401);
}

// Hapus token lama jika ada
$idUser = $userData['id_user'];
mysqli_query($koneksi, "DELETE FROM tokens WHERE id_user = '$idUser'");

// Buat token baru
$token = generateToken();
mysqli_query($koneksi, "
    INSERT INTO tokens (id_user, token)
    VALUES ('$idUser', '$token')
");

jsonResponse(true, 'Login berhasil.', [
    'token' => $token,
    'user'  => [
        'id_user'   => (int) $userData['id_user'],
        'nama_user' => $userData['nama_user'],
        'username'  => $userData['username'],
        'level'     => $userData['level'],
        'email'     => $userData['email'] ?? '',
        'no_hp'     => $userData['no_hp'] ?? '',
        'alamat'    => $userData['alamat'] ?? '',
    ],
]);
