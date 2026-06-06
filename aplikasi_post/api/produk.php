<?php
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

// ─── GET: Daftar produk ──────────────────────────────────────────────────────
if ($method === 'GET') {
    requireAuth($koneksi);

    $search    = isset($_GET['search']) ? mysqli_real_escape_string($koneksi, $_GET['search']) : '';
    $available = isset($_GET['available']) && $_GET['available'] === '1';

    $where = "WHERE 1=1";
    if ($search !== '') {
        $where .= " AND p.nama_produk LIKE '%$search%'";
    }
    if ($available) {
        $where .= " AND p.stok > 0";
    }

    $baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http')
        . '://' . $_SERVER['HTTP_HOST'];

    $query = mysqli_query($koneksi, "
        SELECT p.*, k.nama_kategori
        FROM produk p
        LEFT JOIN kategori k ON p.id_kategori = k.id_kategori
        $where
        ORDER BY p.id_produk DESC
    ");

    $list = [];
    while ($row = mysqli_fetch_assoc($query)) {
        $foto = $row['foto'] ?? 'default.png';
        $list[] = [
            'id_produk'     => (int) $row['id_produk'],
            'nama_produk'   => $row['nama_produk'],
            'id_kategori'   => (int) $row['id_kategori'],
            'nama_kategori' => $row['nama_kategori'] ?? '',
            'harga'         => (int) $row['harga'],
            'stok'          => (int) $row['stok'],
            'foto'          => $foto,
            'foto_url'      => $baseUrl . '/aplikasi_post/upload/' . $foto,
        ];
    }

    jsonResponse(true, 'Data produk berhasil diambil.', ['data' => $list]);
}

// ─── POST: Tambah produk (multipart) ─────────────────────────────────────────
elseif ($method === 'POST') {
    requireAuth($koneksi);

    $namaProduk = mysqli_real_escape_string($koneksi, trim($_POST['nama_produk'] ?? ''));
    $idKategori = (int) ($_POST['id_kategori'] ?? 0);
    $harga      = (int) ($_POST['harga'] ?? 0);
    $stok       = (int) ($_POST['stok'] ?? 0);

    if (empty($namaProduk) || $idKategori === 0 || $harga === 0) {
        jsonResponse(false, 'nama_produk, id_kategori, dan harga wajib diisi.', null, 400);
    }

    $foto = 'default.png';
    if (!empty($_FILES['foto']['name'])) {
        $ext      = strtolower(pathinfo($_FILES['foto']['name'], PATHINFO_EXTENSION));
        $allowed  = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
        if (!in_array($ext, $allowed)) {
            jsonResponse(false, 'Format foto tidak didukung. Gunakan jpg, jpeg, png, gif, atau webp.', null, 400);
        }
        $namaFile = 'produk_' . time() . '_' . uniqid() . '.' . $ext;
        $uploadDir = __DIR__ . '/../upload/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
        move_uploaded_file($_FILES['foto']['tmp_name'], $uploadDir . $namaFile);
        $foto = $namaFile;
    }

    $fotoEsc = mysqli_real_escape_string($koneksi, $foto);
    $ok = mysqli_query($koneksi, "
        INSERT INTO produk (nama_produk, id_kategori, harga, stok, foto)
        VALUES ('$namaProduk', '$idKategori', '$harga', '$stok', '$fotoEsc')
    ");

    if (!$ok) {
        jsonResponse(false, 'Gagal menyimpan produk: ' . mysqli_error($koneksi), null, 500);
    }

    jsonResponse(true, 'Produk berhasil ditambahkan.');
}

// ─── PUT: Update produk (JSON body) ─────────────────────────────────────────
elseif ($method === 'PUT') {
    requireAuth($koneksi);
    $body = getJsonBody();

    $idProduk   = (int) ($body['id_produk'] ?? 0);
    $namaProduk = mysqli_real_escape_string($koneksi, trim($body['nama_produk'] ?? ''));
    $idKategori = (int) ($body['id_kategori'] ?? 0);
    $harga      = (int) ($body['harga'] ?? 0);
    $stok       = (int) ($body['stok'] ?? 0);

    if ($idProduk === 0 || empty($namaProduk)) {
        jsonResponse(false, 'id_produk dan nama_produk wajib diisi.', null, 400);
    }

    $ok = mysqli_query($koneksi, "
        UPDATE produk
        SET nama_produk = '$namaProduk',
            id_kategori = '$idKategori',
            harga       = '$harga',
            stok        = '$stok'
        WHERE id_produk = '$idProduk'
    ");

    if (!$ok) {
        jsonResponse(false, 'Gagal mengupdate produk: ' . mysqli_error($koneksi), null, 500);
    }

    jsonResponse(true, 'Produk berhasil diperbarui.');
}

// ─── DELETE: Hapus produk ────────────────────────────────────────────────────
elseif ($method === 'DELETE') {
    requireAuth($koneksi);

    $id = (int) ($_GET['id'] ?? 0);
    if ($id === 0) {
        jsonResponse(false, 'Parameter id wajib diisi.', null, 400);
    }

    $ok = mysqli_query($koneksi, "DELETE FROM produk WHERE id_produk = '$id'");
    if (!$ok) {
        jsonResponse(false, 'Gagal menghapus produk: ' . mysqli_error($koneksi), null, 500);
    }

    jsonResponse(true, 'Produk berhasil dihapus.');
}

else {
    jsonResponse(false, 'Method tidak diizinkan.', null, 405);
}
