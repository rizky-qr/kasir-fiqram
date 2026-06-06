<?php
session_start();
include "koneksi.php";


if(isset($_POST['tambah'])){

    $id_produk = $_POST['id_produk'];
    $qty = $_POST['qty'];

    $produk = mysqli_fetch_assoc(mysqli_query($koneksi,
    "SELECT * FROM produk
    WHERE id_produk='$id_produk'"));

    $subtotal = $produk['harga'] * $qty;

    $_SESSION['cart'][] = [

        'id_produk'   => $produk['id_produk'],
        'nama_produk' => $produk['nama_produk'],
        'harga'       => $produk['harga'],
        'qty'         => $qty,
        'subtotal'    => $subtotal

    ];

}


if(isset($_GET['hapus'])){

    unset($_SESSION['cart'][$_GET['hapus']]);

    header("location:transaksi.php");

}


if(isset($_POST['simpan'])){

    $tanggal = date('Y-m-d H:i:s');
    $total = $_POST['total'];
    $bayar = $_POST['bayar'];
    $kembali = $bayar - $total;

    $id_user = $_SESSION['id_user'];

    mysqli_query($koneksi,

    "INSERT INTO penjualan
    (tanggal,total,bayar,kembali,id_user)

    VALUES

    ('$tanggal','$total','$bayar',
    '$kembali','$id_user')");

    $id_penjualan = mysqli_insert_id($koneksi);

    foreach($_SESSION['cart'] as $item){

        mysqli_query($koneksi,

        "INSERT INTO detail_penjualan
        (id_penjualan,id_produk,qty,harga,subtotal)

        VALUES

        ('$id_penjualan',
        '{$item['id_produk']}',
        '{$item['qty']}',
        '{$item['harga']}',
        '{$item['subtotal']}')");

        mysqli_query($koneksi,

        "UPDATE produk
        SET stok = stok - {$item['qty']}
        WHERE id_produk='{$item['id_produk']}'");

    }

    unset($_SESSION['cart']);

    echo "
    <script>

        alert('Transaksi Berhasil');

        window.location='transaksi.php';

    </script>
    ";

}

?>

<!DOCTYPE html>
<html lang="id">

<head>

<meta charset="UTF-8">
<meta name="viewport"
content="width=device-width, initial-scale=1">

<title>Transaksi Kasir</title>


<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">


<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>

body{
    background:#f4f6f9;
    font-family:'Segoe UI',sans-serif;
}

.card{
    border:none;
    border-radius:20px;
}


.btn{
    border-radius:12px;
}


.table{
    border-radius:15px;
    overflow:hidden;
}


.header-title{
    font-weight:bold;
}


.total-box{
    background:#28a745;
    color:white;
    border-radius:15px;
    padding:20px;
}

</style>

</head>

<body>

<div class="container-fluid mt-4">


    <div class="card shadow mb-4">

        <div class="card-body">

            <div class="row align-items-center">

                <div class="col-md-6">

                    <h3 class="header-title">

                        <i class="fas fa-cash-register text-primary"></i>

                        Form Transaksi Kasir

                    </h3>

                </div>

                <div class="col-md-6 text-right">

                    <a href="dashboard.php"
                    class="btn btn-secondary">

                        <i class="fas fa-home"></i>
                        Dashboard

                    </a>

                </div>

            </div>

        </div>

    </div>

    <div class="row">


        <div class="col-md-4">

            <div class="card shadow">

                <div class="card-header bg-primary text-white">

                    <h5 class="mb-0">

                        <i class="fas fa-box"></i>
                        Tambah Produk

                    </h5>

                </div>

                <div class="card-body">

                    <form method="POST">


                        <div class="form-group">

                            <label>Pilih Produk</label>

                            <select name="id_produk"
                            class="form-control"
                            required>

                                <option value="">
                                    -- Pilih Produk --
                                </option>

                                <?php

                                $produk =
                                mysqli_query($koneksi,

                                "SELECT * FROM produk
                                WHERE stok > 0");

                                while($p =
                                mysqli_fetch_assoc($produk)){

                                ?>

                                <option
                                value="<?= $p['id_produk'] ?>">

                                    <?= $p['nama_produk'] ?>

                                    -

                                    Rp
                                    <?= number_format($p['harga']) ?>

                                    -

                                    Stok:
                                    <?= $p['stok'] ?>

                                </option>

                                <?php } ?>

                            </select>

                        </div>


                        <div class="form-group">

                            <label>Jumlah</label>

                            <input type="number"
                            name="qty"
                            class="form-control"
                            min="1"
                            required>

                        </div>

                        <button type="submit"
                        name="tambah"
                        class="btn btn-primary btn-block">

                            <i class="fas fa-cart-plus"></i>
                            Tambah Keranjang

                        </button>

                    </form>

                </div>

            </div>

        </div>

        <div class="col-md-8">

            <div class="card shadow">

                <div class="card-header bg-success text-white">

                    <h5 class="mb-0">

                        <i class="fas fa-shopping-cart"></i>
                        Keranjang Belanja

                    </h5>

                </div>

                <div class="card-body">

                    <div class="table-responsive">

                        <table class="table table-bordered table-hover">

                            <thead class="thead-dark">

                                <tr>

                                    <th>No</th>
                                    <th>Produk</th>
                                    <th>Harga</th>
                                    <th>Qty</th>
                                    <th>Subtotal</th>
                                    <th>Aksi</th>

                                </tr>

                            </thead>

                            <tbody>

                            <?php

                            $no = 1;
                            $grand = 0;

                            if(!empty($_SESSION['cart'])){

                                foreach($_SESSION['cart']
                                as $key => $item){

                                $grand +=
                                $item['subtotal'];

                            ?>

                                <tr>

                                    <td>
                                        <?= $no++ ?>
                                    </td>

                                    <td>
                                        <?= $item['nama_produk'] ?>
                                    </td>

                                    <td>

                                        Rp
                                        <?= number_format($item['harga']) ?>

                                    </td>

                                    <td>

                                        <?= $item['qty'] ?>

                                    </td>

                                    <td>

                                        Rp
                                        <?= number_format($item['subtotal']) ?>

                                    </td>

                                    <td>

                                        <a href="?hapus=<?= $key ?>"
                                        class="btn btn-danger btn-sm"
                                        onclick="return confirm('Hapus produk?')">

                                            <i class="fas fa-trash"></i>

                                        </a>

                                    </td>

                                </tr>

                            <?php }} ?>

                            </tbody>

                        </table>

                    </div>


                    <div class="total-box mb-3">

                        <h4>

                            Grand Total :

                            Rp
                            <?= number_format($grand) ?>

                        </h4>

                    </div>

                    <form method="POST">

                        <input type="hidden"
                        name="total"
                        id="total"
                        value="<?= $grand ?>">

                        <div class="row">


                            <div class="col-md-4">

                                <label>Bayar</label>

                                <input type="number"
                                name="bayar"
                                id="bayar"
                                class="form-control"
                                required
                                onkeyup="hitungKembalian()">

                            </div>

                            <div class="col-md-4">

                                <label>Kembalian</label>

                                <input type="text"
                                id="kembalian"
                                class="form-control"
                                readonly>

                            </div>

                            <div class="col-md-4">

                                <label>&nbsp;</label>

                                <button type="submit"
                                name="simpan"
                                class="btn btn-success btn-block">

                                    <i class="fas fa-save"></i>

                                    Simpan

                                </button>

                            </div>

                        </div>

                    </form>

                </div>

            </div>

        </div>

    </div>

</div>

<script>

function hitungKembalian(){

    let total =
    parseInt(document.getElementById('total').value);

    let bayar =
    parseInt(document.getElementById('bayar').value);

    let kembali = bayar - total;

    if(!isNaN(kembali)){

        document.getElementById('kembalian').value =

        'Rp ' +

        kembali.toLocaleString('id-ID');

    }

}

</script>
<footer class="main-footer">
        <strong>MT &copy; 2026-2027 <a href="https://adminlte.io">Sistem Cerdas</a>.</strong>
        Ikhtiar Bersama, Cerdaskan Owner.
        <div class="float-right d-none d-sm-inline-block">
          <b>Version</b> 3.2.0
        </div>
      </footer>
</body>
</html>