<?php
// --- dashboard.php ---

// 1. Panggil helpers (CORS Header, Koneksi Database, dan fungsi JSON sudah ada di sini)
require_once __DIR__ . '/helpers.php';

// Pastikan hanya menerima request GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(false, 'Method tidak diizinkan. Gunakan GET.', null, 405);
}

// 2. Validasi token / akses user
// (Pastikan fungsi ini memanggil variabel $koneksi yang ada di helpers.php)
$currentUser = requireAuth($koneksi);

try {
    // 3. Eksekusi Query
    // Penggunaan (int) dan null coalescing (??) membuat kode PHP 8 lebih kebal terhadap error
    
    $qProduk = mysqli_query($koneksi, "SELECT COUNT(id_produk) AS total FROM produk");
    $totalProduk = (int) ($qProduk ? mysqli_fetch_assoc($qProduk)['total'] : 0);

    $qPenjualan = mysqli_query($koneksi, "SELECT COUNT(id_penjualan) AS total FROM penjualan");
    $totalPenjualan = (int) ($qPenjualan ? mysqli_fetch_assoc($qPenjualan)['total'] : 0);

    $qUser = mysqli_query($koneksi, "SELECT COUNT(id_user) AS total FROM user");
    $totalUser = (int) ($qUser ? mysqli_fetch_assoc($qUser)['total'] : 0);

    $qPendapatan = mysqli_query($koneksi, "SELECT COALESCE(SUM(total), 0) AS grand FROM penjualan");
    $totalPendapatan = (int) ($qPendapatan ? mysqli_fetch_assoc($qPendapatan)['grand'] : 0);

    $qStok = mysqli_query($koneksi, "SELECT COUNT(id_produk) AS total FROM produk WHERE stok <= 5");
    $stokMenipis = (int) ($qStok ? mysqli_fetch_assoc($qStok)['total'] : 0);

    // 4. Kirim response ke Flutter
    jsonResponse(true, 'Data dashboard berhasil diambil.', [
        'data' => [
            'total_produk'     => $totalProduk,
            'total_penjualan'  => $totalPenjualan,
            'total_user'       => $totalUser,
            'total_pendapatan' => $totalPendapatan,
            'stok_menipis'     => $stokMenipis,
        ]
    ]);

} catch (\Throwable $e) {
    // Menggunakan \Throwable (Standar PHP 8) untuk menangkap Exception dan Error fatal
    // Menambahkan $e->getMessage() sementara untuk mempermudah debugging jika ada error SQL
    jsonResponse(false, 'Terjadi kesalahan sistem: ' . $e->getMessage(), null, 500);
}