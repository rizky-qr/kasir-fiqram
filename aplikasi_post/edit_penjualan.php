<?php
include "koneksi.php";

$id = $_GET['id'];


$penjualan = mysqli_fetch_assoc(mysqli_query($koneksi,
"SELECT * FROM penjualan WHERE id_penjualan='$id'"));


$detail = mysqli_query($koneksi,

"SELECT dp.*, p.nama_produk
FROM detail_penjualan dp
JOIN produk p ON dp.id_produk = p.id_produk
WHERE dp.id_penjualan='$id'");


if(isset($_POST['update'])){

    $total = $_POST['total'];
    $bayar = $_POST['bayar'];
    $kembali = $bayar - $total;

    mysqli_query($koneksi,

    "UPDATE penjualan SET
    total='$total',
    bayar='$bayar',
    kembali='$kembali'
    WHERE id_penjualan='$id'");

    echo "<script>
    alert('Penjualan berhasil diupdate');
    window.location='laporan.php';
    </script>";
}
?>

<!DOCTYPE html>
<html>
<head>

<title>Edit Penjualan</title>

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

</head>

<body>

<div class="container mt-4">

<div class="card shadow">

<div class="card-header bg-warning">

<i class="fas fa-edit"></i>
Edit Penjualan

</div>

<div class="card-body">



<h5 class="mb-3">
<i class="fas fa-box"></i>
Detail Item Penjualan
</h5>

<div class="table-responsive">

<table class="table table-bordered">

<thead class="thead-dark">

<tr>

<th>No</th>
<th>Nama Produk</th>
<th>Harga</th>
<th>Qty</th>
<th>Subtotal</th>

</tr>

</thead>

<tbody>

<?php
$no = 1;
$total = 0;

while($d = mysqli_fetch_assoc($detail)){
$total += $d['subtotal'];
?>

<tr>

<td><?= $no++ ?></td>

<td>
<i class="fas fa-cube text-primary"></i>
<?= $d['nama_produk'] ?>
</td>

<td>Rp <?= number_format($d['harga']) ?></td>

<td>
<span class="badge badge-info">
<?= $d['qty'] ?>
</span>
</td>

<td>Rp <?= number_format($d['subtotal']) ?></td>

</tr>

<?php } ?>

</tbody>

<tfoot>

<tr>

<th colspan="4" class="text-right">
TOTAL
</th>

<th>
Rp <?= number_format($total) ?>
</th>

</tr>

</tfoot>

</table>

</div>

<hr>

<form method="POST">

<div class="form-group">

<label>Total (otomatis dari item)</label>

<input type="number"
name="total"
value="<?= $total ?>"
class="form-control"
readonly>

</div>

<div class="form-group">

<label>Bayar</label>

<input type="number"
name="bayar"
value="<?= $penjualan['bayar'] ?>"
class="form-control"
required>

</div>

<div class="form-group">

<label>Kembali</label>

<input type="text"
value="<?= $penjualan['kembali'] ?>"
class="form-control"
readonly>

</div>

<button class="btn btn-success"
name="update">

<i class="fas fa-save"></i>
Update Penjualan

</button>

<a href="laporan.php"
class="btn btn-secondary">

Kembali

</a>

</form>

</div>

</div>

</div>
<footer class="main-footer">
        <strong>MT &copy; 2026-2027 <a href="https://adminlte.io">Sistem Cerdas</a>.</strong>
        Ikhtiar Bersama, Cerdaskan Owner.
        <div class="float-right d-none d-sm-inline-block">
          <b>Version</b> 3.2.0
        </div>
      </footer>
</body>
</html>