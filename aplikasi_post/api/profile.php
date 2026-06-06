<?php
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

// Get logged-in user
$user = requireAuth($koneksi);

if ($method === 'GET') {
    // Return current user profile details
    jsonResponse(true, 'Profil berhasil diambil.', [
        'data' => [
            'id_user'   => (int) $user['id_user'],
            'nama_user' => $user['nama_user'],
            'username'  => $user['username'],
            'email'     => $user['email'] ?? '',
            'no_hp'     => $user['no_hp'] ?? '',
            'alamat'    => $user['alamat'] ?? '',
        ]
    ]);
} elseif ($method === 'POST') {
    $body = getJsonBody();
    $namaUser = trim($body['nama_user'] ?? $body['nama'] ?? '');
    $email    = trim($body['email'] ?? '');
    $noHp     = trim($body['no_hp'] ?? '');
    $alamat   = trim($body['alamat'] ?? '');

    if (empty($namaUser)) {
        jsonResponse(false, 'Nama tidak boleh kosong.', null, 400);
    }

    $idUser = $user['id_user'];

    $stmt = mysqli_prepare($koneksi, "UPDATE user SET nama_user = ?, email = ?, no_hp = ?, alamat = ? WHERE id_user = ?");
    mysqli_stmt_bind_param($stmt, "ssssi", $namaUser, $email, $noHp, $alamat, $idUser);
    $ok = mysqli_stmt_execute($stmt);

    if (!$ok) {
        jsonResponse(false, 'Gagal memperbarui profil: ' . mysqli_error($koneksi), null, 500);
    }
    mysqli_stmt_close($stmt);

    jsonResponse(true, 'Profil berhasil diperbarui.', [
        'data' => [
            'nama_user' => $namaUser,
            'email'     => $email,
            'no_hp'     => $noHp,
            'alamat'    => $alamat,
        ]
    ]);
} else {
    jsonResponse(false, 'Method tidak diizinkan.', null, 405);
}
