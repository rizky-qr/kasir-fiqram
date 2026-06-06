<?php
include "koneksi.php";

if(isset($_POST['simpan'])){

    $nama_kategori = mysqli_real_escape_string($koneksi, $_POST['nama_kategori']);
    $keterangan    = mysqli_real_escape_string($koneksi, $_POST['keterangan']);

    $simpan = mysqli_query($koneksi,"
        INSERT INTO kategori(nama_kategori, keterangan)
        VALUES('$nama_kategori','$keterangan')
    ");

    if($simpan){
        echo "
        <script>
            alert('Data kategori berhasil disimpan');
            window.location='produk.php';
        </script>";
    } else {
        echo "
        <script>
            alert('Data gagal disimpan');
        </script>";
    }
}
?>

<section class="content">
<div class="container-fluid">

<div class="row justify-content-center">
<div class="col-md-8">

<div class="card shadow-lg">

    <div class="card-header bg-primary text-white">
        <h4 class="mb-0">
            <i class="fas fa-tags"></i>
            Tambah Kategori
        </h4>
    </div>

    <form method="POST">

        <div class="card-body">

            <div class="form-group">
                <label>Nama Kategori</label>
                <input type="text"
                       name="nama_kategori"
                       class="form-control"
                       placeholder="Masukkan Nama Kategori"
                       required>
            </div>

            <div class="form-group">
                <label>Keterangan</label>
                <textarea name="keterangan"
                          class="form-control"
                          rows="4"
                          placeholder="Masukkan Keterangan"></textarea>
            </div>

        </div>

        <div class="card-footer text-right">

            <button type="submit"
                    name="simpan"
                    class="btn btn-primary">
                <i class="fas fa-save"></i>
                Simpan
            </button>

            <a href="data_kategori.php"
               class="btn btn-secondary">
               <i class="fas fa-arrow-left"></i>
               Kembali
            </a>

        </div>

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
</div>
</section>