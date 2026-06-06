<?php
session_start();
include "koneksi.php";

if(!isset($_SESSION['id_user'])){
    header("location:login.php");
    exit;
}

$produk = mysqli_num_rows(mysqli_query($koneksi,
"SELECT * FROM produk"));

$penjualan = mysqli_num_rows(mysqli_query($koneksi,
"SELECT * FROM penjualan"));

$user = mysqli_num_rows(mysqli_query($koneksi,
"SELECT * FROM user"));

$total = mysqli_fetch_assoc(mysqli_query($koneksi,
"SELECT SUM(total) as grand FROM penjualan"));

$stok_minimum = mysqli_num_rows(mysqli_query($koneksi,
"SELECT * FROM produk WHERE stok <= 5"));

?>

<!DOCTYPE html>
<html lang="id">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Aplikasi Kasir@</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
body{
    background:#f4f6f9;
    font-family:Arial, Helvetica, sans-serif;
}

.navbar{
    box-shadow:0 2px 10px rgba(0,0,0,0.1);
}

.dashboard-card{
    border:none;
    border-radius:15px;
    transition:0.3s;
}

.dashboard-card:hover{
    transform:translateY(-5px);
}

.card-icon{
    font-size:45px;
    opacity:0.3;
    position:absolute;
    right:20px;
    top:20px;
}

/* Dark Mode */
.dark-mode{
    background:#121212 !important;
    color:white !important;
}

.dark-mode .card{
    background:#1e1e1e;
    color:white;
}

.dark-mode .table{
    color:white;
}

.dark-mode .navbar{
    background:#000 !important;
}
</style>

</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <a class="navbar-brand font-weight-bold">
        <i class="fas fa-cash-register"></i>
        APLIKASI KASIR
    </a>
    <div class="ml-auto">
        <button onclick="darkMode()" class="btn btn-dark btn-sm">
            <i class="fas fa-moon"></i>
            Dark Mode
        </button>
        <a href="logout.php" class="btn btn-danger btn-sm">
            <i class="fas fa-sign-out-alt"></i>
            Logout
        </a>
    </div>
</nav>

<div class="container-fluid mt-4">

    <div class="alert alert-primary shadow-sm">
        <h4>
            <i class="fas fa-user-circle"></i>
            Selamat Datang,
            <?= $_SESSION['nama_user'] ?? 'User'; ?>
        </h4>
        <p class="mb-0">
            Sistem Transaksi
        </p>
    </div>

    <div class="row">
        <div class="col-md-3 mb-3">
            <div class="card dashboard-card bg-primary text-white shadow">
                <div class="card-body">
                    <i class="fas fa-box card-icon"></i>
                    <h5>Total Produk</h5>
                    <h2><?= $produk ?></h2>
                </div>
            </div>
        </div>

        <div class="col-md-3 mb-3">
            <div class="card dashboard-card bg-success text-white shadow">
                <div class="card-body">
                    <i class="fas fa-shopping-cart card-icon"></i>
                    <h5>Total Penjualan</h5>
                    <h2><?= $penjualan ?></h2>
                </div>
            </div>
        </div>

        <div class="col-md-3 mb-3">
            <div class="card dashboard-card bg-danger text-white shadow">
                <div class="card-body">
                    <i class="fas fa-money-bill-wave card-icon"></i>
                    <h5>Total Pendapatan</h5>
                    <h4>
                        Rp.
                        <?= number_format($total['grand'] ?? 0) ?>
                    </h4>
                </div>
            </div>
        </div>

        <div class="col-md-3 mb-3">
            <div class="card dashboard-card bg-warning text-white shadow">
                <div class="card-body">
                    <i class="fas fa-exclamation-triangle card-icon"></i>
                    <h5>Stok Menipis</h5>
                    <h2><?= $stok_minimum ?></h2>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow border-0">
        <div class="card-header bg-dark text-white">
            <h5 class="mb-0">
                <i class="fas fa-bars"></i>
                Menu Utama
            </h5>
        </div>
        <div class="card-body">
            <div class="row text-center">
                <div class="col-md-2 mb-3">
                    <a href="produk.php" class="btn btn-primary btn-block p-3">
                        <i class="fas fa-box fa-2x"></i>
                        <br><br>Produk
                    </a>
                </div>
                <div class="col-md-2 mb-3">
                    <a href="produk.php" class="btn btn-primary btn-block p-3">
                        <i class="fas fa-box fa-2x"></i>
                        <br><br>Kategori
                    </a>
                </div>
                <div class="col-md-2 mb-3">
                    <a href="transaksi.php" class="btn btn-success btn-block p-3">
                        <i class="fas fa-cash-register fa-2x"></i>
                        <br><br>Transaksi
                    </a>
                </div>
                <div class="col-md-2 mb-3">
                    <a href="laporan.php" class="btn btn-warning btn-block p-3">
                        <i class="fas fa-file-alt fa-2x"></i>
                        <br><br>Laporan
                    </a>
                </div>
                <div class="col-md-2 mb-3">
                    <a href="user.php" class="btn btn-info btn-block p-3">
                        <i class="fas fa-users fa-2x"></i>
                        <br><br>User
                    </a>
                </div>
                <div class="col-md-2 mb-3">
                    <a href="stok.php" class="btn btn-danger btn-block p-3">
                        <i class="fas fa-warehouse fa-2x"></i>
                        <br><br>Stok
                    </a>
                </div>
                <div class="col-md-2 mb-3">
                    <a href="setting.php" class="btn btn-secondary btn-block p-3">
                        <i class="fas fa-cog fa-2x"></i>
                        <br><br>Setting
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const ctx = document.getElementById('grafikPenjualan');
if(ctx) {
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei'],
            datasets: [{
                label: 'Jumlah Penjualan',
                backgroundColor: [
                    '#007bff',
                    '#28a745',
                    '#ffc107',
                    '#dc3545',
                    '#17a2b8'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive:true,
            scales: {
                y: {
                    beginAtZero:true
                }
            }
        }
    });
}

function darkMode(){
    document.body.classList.toggle("dark-mode");
}
</script>

<footer class="main-footer pt-4 pb-4 text-center">
    <strong>MT &copy; 2026-2027 <a href="https://adminlte.io">Sistem Cerdas</a>.</strong>
    Ikhtiar Bersama, Cerdaskan Owner.
    <div class="float-right d-none d-sm-inline-block">
        <b>Version</b> 3.2.0
    </div>
</footer>

</body>
</html>