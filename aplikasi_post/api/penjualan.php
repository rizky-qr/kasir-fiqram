<?php
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

// ─── POST: Simpan transaksi penjualan (JSON body) ────────────────────────────
if ($method === 'POST') {
    $authUser        = requireAuth($koneksi);
    $body            = getJsonBody();

    $items           = $body['items']             ?? [];
    $total           = (int) ($body['total']      ?? 0);
    $bayar           = (int) ($body['bayar']      ?? 0);
    $metodeBayar     = mysqli_real_escape_string($koneksi, trim($body['metode_pembayaran'] ?? 'COD'));
    $ongkir          = (int) ($body['ongkir']     ?? 0);
    $kotaTujuan      = mysqli_real_escape_string($koneksi, trim($body['kota_tujuan']      ?? ''));
    $alamat          = mysqli_real_escape_string($koneksi, trim($body['alamat']           ?? ''));

    if (empty($items)) {
        jsonResponse(false, 'Keranjang kosong. Tambahkan produk terlebih dahulu.', null, 400);
    }
    if ($bayar < $total) {
        jsonResponse(false, 'Jumlah bayar tidak boleh kurang dari total.', null, 400);
    }

    $kembali  = $bayar - $total;
    $tanggal  = date('Y-m-d H:i:s');
    $idUser   = (int) $authUser['id_user'];

    // Mulai transaksi DB
    mysqli_begin_transaction($koneksi);

    try {
        $ok = mysqli_query($koneksi, "
            INSERT INTO penjualan (tanggal, total, bayar, kembali, id_user, status, metode_pembayaran, ongkir, kota_tujuan, alamat)
            VALUES ('$tanggal', '$total', '$bayar', '$kembali', '$idUser', 'Menunggu Verifikasi', '$metodeBayar', '$ongkir', '$kotaTujuan', '$alamat')
        ");
        if (!$ok) throw new Exception('Gagal menyimpan penjualan: ' . mysqli_error($koneksi));

        $idPenjualan = mysqli_insert_id($koneksi);

        foreach ($items as $item) {
            $idProduk = (int) ($item['id_produk'] ?? $item['idProduk'] ?? 0);
            $qty      = (int) ($item['qty'] ?? 0);
            $harga    = (int) ($item['harga'] ?? 0);
            $subtotal = (int) ($item['subtotal'] ?? ($harga * $qty));

            if ($idProduk === 0 || $qty <= 0) continue;

            $ok = mysqli_query($koneksi, "
                INSERT INTO detail_penjualan (id_penjualan, id_produk, qty, harga, subtotal)
                VALUES ('$idPenjualan', '$idProduk', '$qty', '$harga', '$subtotal')
            ");
            if (!$ok) throw new Exception('Gagal menyimpan detail: ' . mysqli_error($koneksi));

            $ok = mysqli_query($koneksi, "
                UPDATE produk SET stok = stok - $qty
                WHERE id_produk = '$idProduk' AND stok >= $qty
            ");
            if (!$ok || mysqli_affected_rows($koneksi) === 0) {
                throw new Exception("Stok produk ID $idProduk tidak mencukupi.");
            }
        }

        mysqli_commit($koneksi);

        jsonResponse(true, 'Transaksi berhasil disimpan.', [
            'id_penjualan'      => $idPenjualan,
            'kembali'           => $kembali,
            'metode_pembayaran' => $metodeBayar,
            'ongkir'            => $ongkir,
        ]);

    } catch (Exception $e) {
        mysqli_rollback($koneksi);
        jsonResponse(false, $e->getMessage(), null, 500);
    }
}

// ─── GET: Laporan / Riwayat penjualan ─────────────────────────────────────────
elseif ($method === 'GET') {
    requireAuth($koneksi);

    $awal  = mysqli_real_escape_string($koneksi, $_GET['awal']  ?? date('Y-m-01'));
    $akhir = mysqli_real_escape_string($koneksi, $_GET['akhir'] ?? date('Y-m-d'));

    // PERBAIKAN: Jika dipanggil dari menu Riwayat Pesanan Flutter (?all=true), bypass filter tanggal
    if (isset($_GET['all']) && ($_GET['all'] === 'true' || $_GET['all'] == 1)) {
        $whereClause = "";
    } else {
        $whereClause = "WHERE DATE(p.tanggal) BETWEEN '$awal' AND '$akhir'";
    }

    $query = mysqli_query($koneksi, "
        SELECT p.*, u.nama_user
        FROM penjualan p
        JOIN user u ON p.id_user = u.id_user
        $whereClause
        ORDER BY p.id_penjualan DESC
    ");

    $list = [];
    while ($row = mysqli_fetch_assoc($query)) {
        $idPenjualan = (int) $row['id_penjualan'];
        
        // Ambil item detail untuk transaksi ini
        $queryItems = mysqli_query($koneksi, "
            SELECT dp.*, pr.nama_produk
            FROM detail_penjualan dp
            JOIN produk pr ON dp.id_produk = pr.id_produk
            WHERE dp.id_penjualan = $idPenjualan
        ");
        
        $items = [];
        if ($queryItems) {
            while ($itemRow = mysqli_fetch_assoc($queryItems)) {
                $items[] = [
                    'id_produk'   => (int) $itemRow['id_produk'],
                    'nama_produk' => $itemRow['nama_produk'],
                    'qty'         => (int) $itemRow['qty'],
                    'harga'       => (int) $itemRow['harga'],
                    'subtotal'    => (int) $itemRow['subtotal'],
                ];
            }
        }

        $list[] = [
            'id_penjualan'      => $idPenjualan,
            'tanggal'           => $row['tanggal'],
            'total'             => (int) $row['total'],
            'bayar'             => (int) $row['bayar'],
            'kembali'           => (int) $row['kembali'],
            'id_user'           => (int) $row['id_user'],
            'nama_user'         => $row['nama_user'],
            'status'            => $row['status'] ?? 'Menunggu Verifikasi',
            'metode_pembayaran' => $row['metode_pembayaran'] ?? 'COD',
            'ongkir'            => (int) ($row['ongkir'] ?? 0),
            'kota_tujuan'       => $row['kota_tujuan'] ?? '',
            'alamat'            => $row['alamat'] ?? '',
            'items'             => $items,
        ];
    }

    // Hitung total pendapatan periode laporan
    $rowTotal = mysqli_fetch_assoc(mysqli_query($koneksi, "
        SELECT COALESCE(SUM(total), 0) AS grand
        FROM penjualan
        WHERE DATE(tanggal) BETWEEN '$awal' AND '$akhir'
    "));

    jsonResponse(true, 'Data laporan berhasil diambil.', [
        'data'             => $list,
        'total_pendapatan' => (int) $rowTotal['grand'],
    ]);
}

else {
    jsonResponse(false, 'Method tidak diizinkan.', null, 405);
}