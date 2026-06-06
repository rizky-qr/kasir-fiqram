<?php
require_once __DIR__ . '/helpers.php';

// Atur header agar selalu mengembalikan JSON dan mendukung CORS jika diperlukan
header('Content-Type: application/json');

$method = $_SERVER['REQUEST_METHOD'];

// ─── POST: Kirim Pesan Chat ──────────────────────────────────────────────────
if ($method === 'POST') {
    $authUser = requireAuth($koneksi);
    $body     = getJsonBody();

    $id_penjualan = isset($body['id_penjualan']) ? (int)$body['id_penjualan'] : 0;
    $pesan        = isset($body['pesan']) ? mysqli_real_escape_string($koneksi, trim($body['pesan'])) : '';

    // Otomatis deteksi pengirim berdasarkan level akun token yang aktif
    $pengirim = strtolower($authUser['level']) === 'admin' ? 'admin' : 'pelanggan';
    $tanggal  = date('Y-m-d H:i:s');

    // id_penjualan >= 0 diizinkan (0 = Chat Umum)
    if ($id_penjualan < 0 || empty($pesan)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Data chat tidak lengkap.']);
        exit;
    }

    $query = mysqli_query($koneksi, "
        INSERT INTO chat (id_penjualan, pengirim, pesan, tanggal)
        VALUES ('$id_penjualan', '$pengirim', '$pesan', '$tanggal')
    ");

    if ($query) {
        http_response_code(200);
        echo json_encode([
            'success'      => true,
            'message'      => 'Pesan terkirim.',
            'data'         => [
                'id_chat'      => (int) mysqli_insert_id($koneksi),
                'id_penjualan' => $id_penjualan,
                'pengirim'     => $pengirim,
                'pesan'        => $body['pesan'],
                'tanggal'      => $tanggal,
            ]
        ], JSON_UNESCAPED_UNICODE);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Gagal mengirim pesan ke database: ' . mysqli_error($koneksi)]);
    }
    exit;
}

// ─── GET: Ambil Riwayat Obrolan ──────────────────────────────────────────────
elseif ($method === 'GET') {
    requireAuth($koneksi);

    $id_penjualan = isset($_GET['id_penjualan']) ? (int)$_GET['id_penjualan'] : -1;

    if ($id_penjualan < 0) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'ID Penjualan tidak valid.']);
        exit;
    }

    // Ambil semua pesan di nota ini, diurutkan dari yang paling lama ke terbaru
    $query = mysqli_query($koneksi, "
        SELECT * FROM chat
        WHERE id_penjualan = '$id_penjualan'
        ORDER BY id_chat ASC
    ");

    $list = [];
    if ($query) {
        while ($row = mysqli_fetch_assoc($query)) {
            $list[] = [
                'id_chat'      => (int) $row['id_chat'],
                'id_penjualan' => (int) $row['id_penjualan'],
                'pengirim'     => $row['pengirim'],
                'pesan'        => $row['pesan'],
                'tanggal'      => $row['tanggal'],
            ];
        }
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Chat berhasil dimuat.',
        'data'    => $list,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

else {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method tidak diizinkan.']);
    exit;
}