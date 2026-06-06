<?php
include "koneksi.php";

$id = $_GET['id'];

$data = mysqli_fetch_assoc(mysqli_query($koneksi,
"SELECT * FROM produk WHERE id_produk='$id'"));

if(isset($_POST['update'])){

    $nama = $_POST['nama_produk'];
    $kategori = $_POST['id_kategori'];
    $harga = $_POST['harga'];
    $stok = $_POST['stok'];

    $foto = $_FILES['foto']['name'];
    $tmp  = $_FILES['foto']['tmp_name'];

    if($foto != ""){

        move_uploaded_file($tmp, "upload/".$foto);

        mysqli_query($koneksi,
        "UPDATE produk SET
        nama_produk='$nama',
        id_kategori='$kategori',
        harga='$harga',
        stok='$stok',
        foto='$foto'
        WHERE id_produk='$id'");

    } else {

        mysqli_query($koneksi,
        "UPDATE produk SET
        nama_produk='$nama',
        id_kategori='$kategori',
        harga='$harga',
        stok='$stok'
        WHERE id_produk='$id'");

    }

    echo "<script>
    alert('Produk berhasil diupdate');
    window.location='produk.php';
    </script>";
}
?>

<!DOCTYPE html>
<html>
<head>
<title>Edit Produk</title>

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

</head>

<body>

<div class="container mt-4">

<div class="card shadow">

<div class="card-header bg-warning">
Edit Produk
</div>

<div class="card-body">

<form method="POST" enctype="multipart/form-data">

<div class="form-group">
<label>Nama Produk</label>
<input type="text" name="nama_produk"
value="<?= $data['nama_produk'] ?>"
class="form-control" required>
</div>

<div class="form-group">
<label>Kategori</label>

<select name="id_kategori"
class="form-control" required>

<?php
$kategori = mysqli_query($koneksi,"SELECT * FROM kategori");

while($k = mysqli_fetch_assoc($kategori)){
?>

<option value="<?= $k['id_kategori'] ?>"
<?php if($k['id_kategori']==$data['id_kategori']) echo "selected"; ?>>

<?= $k['nama_kategori'] ?>

</option>

<?php } ?>

</select>

</div>

<div class="form-group">
<label>Harga</label>
<input type="number" name="harga"
value="<?= $data['harga'] ?>"
class="form-control" required>
</div>

<div class="form-group">
<label>Stok</label>
<input type="number" name="stok"
value="<?= $data['stok'] ?>"
class="form-control" required>
</div>

<div class="form-group">
<label>Foto Produk</label><br>

<img src="upload/<?= $data['foto'] ?>"
width="80" class="mb-2">

<input type="file" name="foto"
class="form-control">
</div>

<button type="submit" name="update"
class="btn btn-success">

Update

</button>

<a href="produk.php"
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