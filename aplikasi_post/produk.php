<?php
include "koneksi.php";


if(isset($_POST['simpan'])){

    $nama = $_POST['nama_produk'];
    $kategori = $_POST['id_kategori'];
    $harga = $_POST['harga'];
    $stok = $_POST['stok'];

    $foto = $_FILES['foto']['name'];
    $tmp  = $_FILES['foto']['tmp_name'];

    if($foto != ""){
        move_uploaded_file($tmp, "upload/".$foto);
    } else {
        $foto = "default.png";
    }

    mysqli_query($koneksi,
    "INSERT INTO produk(nama_produk,id_kategori,harga,stok,foto)
    VALUES('$nama','$kategori','$harga','$stok','$foto')");

    echo "<script>alert('Produk berhasil disimpan');window.location='produk.php';</script>";
}

if(isset($_GET['hapus'])){

    $id = $_GET['hapus'];

    mysqli_query($koneksi,
    "DELETE FROM produk WHERE id_produk='$id'");

    echo "<script>alert('Produk dihapus');window.location='produk.php';</script>";
}

$keyword = "";
if(isset($_GET['search'])){
    $keyword = $_GET['search'];
}
?>

<!DOCTYPE html>
<html>
<head>

<title>Produk</title>

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>

body{
    background:#f4f6f9;
}

.card{
    border-radius:15px;
}

.img-product{
    width:60px;
    height:60px;
    object-fit:cover;
    border-radius:10px;
}

</style>

</head>

<body>

<div class="container mt-4">

<div class="d-flex justify-content-between mb-3">
    <h4><i class="fas fa-box"></i> Data Item Produk</h4>
    <a href="dashboard.php" class="btn btn-secondary">
        <i class="fas fa-arrow-left"></i> Kembali
    </a>

</div>

<div class="card shadow mb-4">

<div class="card-header bg-primary text-white">
Tambah Produk
</div>

<div class="card-body">

<form method="POST" enctype="multipart/form-data">

<div class="row">

<div class="col-md-3">
<input type="text" name="nama_produk"
class="form-control" placeholder="Nama Produk" required>
</div>

<div class="col-md-2">

<select name="id_kategori" class="form-control" required>

<option value="">Kategori</option>

<?php
$kat = mysqli_query($koneksi,"SELECT * FROM kategori");
while($k = mysqli_fetch_assoc($kat)){
?>
<option value="<?= $k['id_kategori'] ?>">
<?= $k['nama_kategori'] ?>
</option>
<?php } ?>

</select>

</div>

<div class="col-md-2">
<input type="number" name="harga"
class="form-control" placeholder="Harga" required>
</div>

<div class="col-md-2">
<input type="number" name="stok"
class="form-control" placeholder="Stok" required>
</div>

<div class="col-md-2">
<input type="file" name="foto"
class="form-control">
</div>

<div class="col-md-1">
<button class="btn btn-primary btn-block"
name="simpan">

<i class="fas fa-save"></i>

</button>
</div>

</div>

</form>

</div>

</div>

<form method="GET" class="mb-3">

<input type="text" name="search"
class="form-control"
placeholder="Cari produk..."
value="<?= $keyword ?>">

</form>

<div class="card shadow">

<div class="card-header bg-success text-white">
Daftar Produk
</div>

<div class="card-body table-responsive">

<table class="table table-bordered table-hover">

<thead class="thead-dark">
<tr>
<th>No</th>
<th>Foto</th>
<th>Produk</th>
<th>Kategori</th>
<th>Harga</th>
<th>Stok</th>
<th>Aksi</th>
</tr>
</thead>

<tbody>

<?php
$no = 1;

$query = mysqli_query($koneksi,

"SELECT produk.*, kategori.nama_kategori
FROM produk
JOIN kategori ON produk.id_kategori=kategori.id_kategori
WHERE nama_produk LIKE '%$keyword%'
ORDER BY id_produk DESC");

while($d = mysqli_fetch_assoc($query)){
?>

<tr>

<td><?= $no++ ?></td>

<td>
<img src="upload/<?= $d['foto'] ?>"
class="img-product">
</td>

<td><?= $d['nama_produk'] ?></td>

<td><?= $d['nama_kategori'] ?></td>

<td>Rp <?= number_format($d['harga']) ?></td>

<td><?= $d['stok'] ?></td>

<td>

<a href="edit_produk.php?id=<?= $d['id_produk'] ?>"
class="btn btn-warning btn-sm">

<i class="fas fa-edit"></i>

</a>

<a href="produk.php?hapus=<?= $d['id_produk'] ?>"
class="btn btn-danger btn-sm"
onclick="return confirm('Hapus data?')">

<i class="fas fa-trash"></i>

</a>

</td>

</tr>

<?php } ?>

</tbody>

</table>

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