<?php
include "koneksi.php";

$awal  = isset($_GET['awal']) ? $_GET['awal'] : date('Y-m-01');
$akhir = isset($_GET['akhir']) ? $_GET['akhir'] : date('Y-m-d');

$query = mysqli_query($koneksi,
"SELECT penjualan.*, user.nama_user
FROM penjualan
JOIN user ON penjualan.id_user=user.id_user
WHERE DATE(tanggal) BETWEEN '$awal' AND '$akhir'
ORDER BY id_penjualan DESC");

$total = mysqli_fetch_assoc(mysqli_query($koneksi,
"SELECT SUM(total) as grand
FROM penjualan
WHERE DATE(tanggal) BETWEEN '$awal' AND '$akhir'"));
?>

<!DOCTYPE html>
<html>
<head>
<title>Laporan Kasir</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
body{
    background:#f4f6f9;
}
.card{
    border-radius:15px;
}
</style>
</head>

<body>

<div class="container mt-4">
    <div class="d-flex justify-content-between mb-3">
        <h4>
            <i class="fas fa-file-alt"></i>
            Laporan Penjualan
        </h4>
        <a href="dashboard.php" class="btn btn-secondary">
            <i class="fas fa-home"></i> Dashboard
        </a>
    </div>

    <div class="card shadow mb-3">
        <div class="card-body">
            <form method="GET">
                <div class="row">
                    <div class="col-md-4">
                        <label>Tanggal Awal</label>
                        <input type="date" name="awal" value="<?= $awal ?>" class="form-control">
                    </div>
                    <div class="col-md-4">
                        <label>Tanggal Akhir</label>
                        <input type="date" name="akhir" value="<?= $akhir ?>" class="form-control">
                    </div>
                    <div class="col-md-4">
                        <label>&nbsp;</label><br>
                        <button class="btn btn-primary btn-block">
                            <i class="fas fa-search"></i> Filter
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="alert alert-success">
        <strong>Total Pendapatan:</strong>
        Rp <?= number_format($total['grand'] ?? 0) ?>
    </div>

    <div class="card shadow">
        <div class="card-header bg-dark text-white">
            <i class="fas fa-table"></i>
            Data Transaksi
        </div>
        <div class="card-body table-responsive">
            <table class="table table-bordered table-striped">
                <thead class="thead-dark">
                    <tr>
                        <th>No</th>
                        <th>Tanggal</th>
                        <th>Kasir</th>
                        <th>Total</th>
                        <th>Bayar</th>
                        <th>Kembali</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $no = 1;
                    while($data = mysqli_fetch_assoc($query)){
                    ?>
                    <tr>
                        <td><?= $no++ ?></td>
                        <td><?= date('d-m-Y H:i', strtotime($data['tanggal'])) ?></td>
                        <td><?= $data['nama_user'] ?></td>
                        <td>Rp <?= number_format($data['total']) ?></td>
                        <td>Rp <?= number_format($data['bayar']) ?></td>
                        <td>Rp <?= number_format($data['kembali']) ?></td>
                        <td>
                            <a href="edit_penjualan.php?id=<?= $data['id_penjualan'] ?>" class="btn btn-warning btn-sm">
                                <i class="fas fa-edit"></i>
                            </a>
                            <a href="hapus_penjualan.php?id=<?= $data['id_penjualan'] ?>" class="btn btn-danger btn-sm" onclick="return confirm('Hapus transaksi ini?')">
                                <i class="fas fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <?php } ?>
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-3 mb-5">
        <button onclick="window.print()" class="btn btn-danger">
            <i class="fas fa-print"></i> Print
        </button>
        <a href="export_excel.php?awal=<?= $awal ?>&akhir=<?= $akhir ?>" class="btn btn-success">
            <i class="fas fa-file-excel"></i> Export Excel
        </a>
    </div>

</div>

<footer class="main-footer pb-4 pt-4 text-center">
    <strong>MT &copy; 2026-2027 <a href="https://adminlte.io">Sistem Cerdas</a>.</strong>
    Ikhtiar Bersama, Cerdaskan Owner.
    <div class="float-right d-none d-sm-inline-block">
        <b>Version</b> 3.2.0
    </div>
</footer>

</body>
</html>