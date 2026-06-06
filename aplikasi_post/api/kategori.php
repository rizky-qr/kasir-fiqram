<?php
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

// ─── GET: Daftar kategori ────────────────────────────────────────────────────
if ($method === 'GET') {
    requireAuth($koneksi);

    $query = mysqli_query($koneksi, "SELECT * FROM kategori ORDER BY nama_kategori ASC");
    $list  = [];
    while ($row = mysqli_fetch_assoc($query)) {
        $list[] = [
            'id_kategori'   => (int) $row['id_kategori'],
            'nama_kategori' => $row['nama_kategori'],
            'keterangan'    => $row['keterangan'] ?? '',
        ];
    }

    jsonResponse(true, 'Data kategori berhasil diambil.', ['data' => $list]);
}

// ─── POST: Tambah kategori (JSON body) ───────────────────────────────────────
elseif ($method === 'POST') {
    requireAuth($koneksi);
    $body = getJsonBody();

    $namaKategori = mysqli_real_escape_string($koneksi, trim($body['nama_kategori'] ?? ''));
    $keterangan   = mysqli_real_escape_string($koneksi, trim($body['keterangan'] ?? ''));

    if (empty($namaKategori)) {
        jsonResponse(false, 'nama_kategori wajib diisi.', null, 400);
    }

    $ok = mysqli_query($koneksi, "
        INSERT INTO kategori (nama_kategori, keterangan)
        VALUES ('$namaKategori', '$keterangan')
    ");

    if (!$ok) {
        jsonResponse(false, 'Gagal menyimpan kategori: ' . mysqli_error($koneksi), null, 500);
    }

    jsonResponse(true, 'Kategori berhasil ditambahkan.');
}

// ─── DELETE: Hapus kategori ──────────────────────────────────────────────────
elseif ($method === 'DELETE') {
    requireAuth($koneksi);

    $id = (int) ($_GET['id'] ?? 0);
    if ($id === 0) {
        jsonResponse(false, 'Parameter id wajib diisi.', null, 400);
    }

    // Cek apakah kategori masih dipakai produk
    $cek = mysqli_num_rows(mysqli_query($koneksi, "SELECT id_produk FROM produk WHERE id_kategori = '$id'"));
    if ($cek > 0) {
        jsonResponse(false, 'Kategori tidak dapat dihapus karena masih digunakan oleh produk.', null, 409);
    }

    $ok = mysqli_query($koneksi, "DELETE FROM kategori WHERE id_kategori = '$id'");
    if (!$ok) {
        jsonResponse(false, 'Gagal menghapus kategori: ' . mysqli_error($koneksi), null, 500);
    }

    jsonResponse(true, 'Kategori berhasil dihapus.');
}

else {
    jsonResponse(false, 'Method tidak diizinkan.', null, 405);
}
