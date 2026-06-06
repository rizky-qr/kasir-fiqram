<?php
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

// ─── GET: Daftar riwayat stok masuk ─────────────────────────────────────────
if ($method === 'GET') {
    requireAuth($koneksi);

    $query = mysqli_query($koneksi, "
        SELECT s.*, p.nama_produk
        FROM stok s
        JOIN produk p ON s.id_produk = p.id_produk
        ORDER BY s.id_stok DESC
    ");

    $list = [];
    while ($row = mysqli_fetch_assoc($query)) {
        $list[] = [
            'id_stok'     => (int) $row['id_stok'],
            'id_produk'   => (int) $row['id_produk'],
            'nama_produk' => $row['nama_produk'],
            'tanggal'     => $row['tanggal'],
            'stok_masuk'  => (int) $row['stok_masuk'],
            'keterangan'  => $row['keterangan'] ?? '',
        ];
    }

    jsonResponse(true, 'Data stok berhasil diambil.', ['data' => $list]);
}

// ─── POST: Tambah stok masuk (JSON body) ─────────────────────────────────────
elseif ($method === 'POST') {
    requireAuth($koneksi);
    $body = getJsonBody();

    $idProduk   = (int) ($body['id_produk'] ?? 0);
    $tanggal    = mysqli_real_escape_string($koneksi, trim($body['tanggal'] ?? ''));
    $stokMasuk  = (int) ($body['stok_masuk'] ?? 0);
    $keterangan = mysqli_real_escape_string($koneksi, trim($body['keterangan'] ?? ''));

    if ($idProduk === 0 || empty($tanggal) || $stokMasuk <= 0) {
        jsonResponse(false, 'id_produk, tanggal, dan stok_masuk wajib diisi.', null, 400);
    }

    // Cek produk ada
    $produkRes = mysqli_fetch_assoc(mysqli_query($koneksi, "SELECT stok FROM produk WHERE id_produk = '$idProduk'"));
    if (!$produkRes) {
        jsonResponse(false, 'Produk tidak ditemukan.', null, 404);
    }

    // Insert ke tabel stok
    $ok = mysqli_query($koneksi, "
        INSERT INTO stok (id_produk, tanggal, stok_masuk, keterangan)
        VALUES ('$idProduk', '$tanggal', '$stokMasuk', '$keterangan')
    ");

    if (!$ok) {
        jsonResponse(false, 'Gagal menyimpan stok: ' . mysqli_error($koneksi), null, 500);
    }

    // Update stok di tabel produk
    $stokBaru = ((int) $produkRes['stok']) + $stokMasuk;
    mysqli_query($koneksi, "UPDATE produk SET stok = '$stokBaru' WHERE id_produk = '$idProduk'");

    jsonResponse(true, 'Stok berhasil ditambahkan.');
}

else {
    jsonResponse(false, 'Method tidak diizinkan.', null, 405);
}
