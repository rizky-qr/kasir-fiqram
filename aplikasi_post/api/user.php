<?php
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

// ─── GET: Daftar user ────────────────────────────────────────────────────────
if ($method === 'GET') {
    requireAuth($koneksi);

    $query = mysqli_query($koneksi, "SELECT id_user, nama_user, username, email, no_hp, level FROM user ORDER BY id_user DESC");
    
    // Cek apakah query berhasil dieksekusi
    if (!$query) {
        jsonResponse(false, 'Gagal mengambil data user: ' . mysqli_error($koneksi), null, 500);
    }

    $list = [];
    while ($row = mysqli_fetch_assoc($query)) {
        $list[] = [
            'id_user'   => (int) $row['id_user'],
            'nama_user' => $row['nama_user'],
            'username'  => $row['username'],
            'email'     => $row['email'] ?? '',
            'no_hp'     => $row['no_hp'] ?? '',
            'level'     => $row['level'],
        ];
    }

    jsonResponse(true, 'Data user berhasil diambil.', ['data' => $list]);
}

// ─── POST: Tambah user (JSON body) ───────────────────────────────────────────
elseif ($method === 'POST') {
    requireAuth($koneksi);
    $body = getJsonBody();

    // Tidak perlu lagi mysqli_real_escape_string karena kita akan pakai Prepared Statement
    $namaUser = trim($body['nama_user'] ?? '');
    $username = trim($body['username'] ?? '');
    $email    = trim($body['email'] ?? '');
    $noHp     = trim($body['no_hp'] ?? '');
    $password = trim($body['password'] ?? '');
    $level    = trim($body['level'] ?? '');

    if (empty($namaUser) || empty($username) || empty($password) || empty($level)) {
        jsonResponse(false, 'Semua field (nama_user, username, password, level) wajib diisi.', null, 400);
    }

    if (!in_array($level, ['admin', 'kasir', 'pelanggan'])) {
        jsonResponse(false, 'Level harus berupa "admin", "kasir", atau "pelanggan".', null, 400);
    }

    // 1. Cek duplikat username menggunakan Prepared Statement
    $stmtCek = mysqli_prepare($koneksi, "SELECT id_user FROM user WHERE username = ?");
    mysqli_stmt_bind_param($stmtCek, "s", $username);
    mysqli_stmt_execute($stmtCek);
    mysqli_stmt_store_result($stmtCek);
    
    if (mysqli_stmt_num_rows($stmtCek) > 0) {
        mysqli_stmt_close($stmtCek);
        jsonResponse(false, 'Username sudah digunakan. Pilih username lain.', null, 409);
    }
    mysqli_stmt_close($stmtCek);

    // Hashing password (Catatan: md5 tetap dipertahankan agar tidak merusak login sistem Anda, 
    // namun untuk proyek ke depan sangat disarankan beralih ke password_hash())
    $hashedPw = md5($password);
    
    // 2. Insert data menggunakan Prepared Statement (Sangat aman dari SQL Injection)
    $stmtInsert = mysqli_prepare($koneksi, "INSERT INTO user (nama_user, email, no_hp, username, password, level) VALUES (?, ?, ?, ?, ?, ?)");
    mysqli_stmt_bind_param($stmtInsert, "ssssss", $namaUser, $email, $noHp, $username, $hashedPw, $level);
    $ok = mysqli_stmt_execute($stmtInsert);

    if (!$ok) {
        jsonResponse(false, 'Gagal menambahkan user: ' . mysqli_error($koneksi), null, 500);
    }
    mysqli_stmt_close($stmtInsert);

    jsonResponse(true, 'User berhasil ditambahkan.');
}

// ─── DELETE: Hapus user ──────────────────────────────────────────────────────
elseif ($method === 'DELETE') {
    requireAuth($koneksi);

    $id = (int) ($_GET['id'] ?? 0);
    if ($id === 0) {
        jsonResponse(false, 'Parameter id wajib diisi.', null, 400);
    }

    // Menggunakan Transaction agar penghapusan data berelasi dijamin tuntas
    mysqli_begin_transaction($koneksi);

    try {
        // Hapus token user
        $hapusToken = mysqli_query($koneksi, "DELETE FROM tokens WHERE id_user = $id");
        if (!$hapusToken) throw new Exception('Gagal menghapus token');

        // Hapus data user
        $hapusUser = mysqli_query($koneksi, "DELETE FROM user WHERE id_user = $id");
        if (!$hapusUser) throw new Exception('Gagal menghapus data user');

        // Jika semua berhasil, simpan perubahan secara permanen
        mysqli_commit($koneksi);
        jsonResponse(true, 'User berhasil dihapus.');
        
    } catch (Exception $e) {
        // Jika terjadi error di tengah jalan, kembalikan database ke kondisi semula (Rollback)
        mysqli_rollback($koneksi);
        jsonResponse(false, 'Sistem gagal menghapus user: ' . $e->getMessage(), null, 500);
    }
}

else {
    jsonResponse(false, 'Method tidak diizinkan.', null, 405);
}