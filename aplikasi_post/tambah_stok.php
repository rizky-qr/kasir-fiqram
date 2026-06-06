<?php
include "koneksi.php";
?>

<section class="content">
<div class="container-fluid">

<div class="row justify-content-center">
<div class="col-md-10">

<div class="card shadow-lg">

    <div class="card-header bg-success text-white">
        <h4 class="mb-0">
            <i class="fas fa-boxes"></i>
            Tambah Stok Barang
        </h4>
    </div>

<?php

if(isset($_POST['simpan'])){

    $id_produk     = $_POST['id_produk'];
    $tanggal       = $_POST['tanggal'];
    $stok_masuk    = $_POST['stok_masuk'];
    $keterangan    = mysqli_real_escape_string($koneksi,$_POST['keterangan']);

    $produk = mysqli_fetch_assoc(mysqli_query($koneksi,
        "SELECT * FROM produk WHERE id_produk='$id_produk'")
    );

    $stok_lama = $produk['stok'];
    $stok_baru = $stok_lama + $stok_masuk;

$simpan = mysqli_query($koneksi,"
        INSERT INTO stok(
            id_produk,
            tanggal,
            stok_masuk,
            keterangan
        ) VALUES(
            '$id_produk',
            '$tanggal',
            '$stok_masuk',
            '$keterangan'
        )
    ");

    if($simpan){

        mysqli_query($koneksi,"
            UPDATE produk
            SET stok='$stok_baru'
            WHERE id_produk='$id_produk'
        ");

        echo "
        <script>
            alert('Stok berhasil ditambahkan');
            window.location='produk.php';
        </script>
        ";

    } else {

        echo "
        <script>
            alert('Data gagal disimpan');
        </script>
        ";
    }
}
?>

<form method="POST">

<div class="card-body">

    <div class="row">

        <div class="col-md-6">

            <div class="form-group">
                <label>Tanggal</label>
                <input type="date"
                       name="tanggal"
                       class="form-control"
                       value="<?= date('Y-m-d'); ?>"
                       required>
            </div>

        </div>

        <div class="col-md-6">

            <div class="form-group">
                <label>Pilih Produk</label>

                <select name="id_produk"
                        class="form-control"
                        required>

                    <option value="">-- Pilih Produk --</option>

                    <?php
                    $query = mysqli_query($koneksi,"
                        SELECT * FROM produk
                        ORDER BY nama_produk ASC
                    ");

                    while($data = mysqli_fetch_assoc($query)){
                    ?>

                    <option value="<?= $data['id_produk']; ?>">
                        <?= $data['nama_produk']; ?>
                        | Stok : <?= $data['stok']; ?>
                    </option>

                    <?php } ?>

                </select>
            </div>

        </div>

    </div>

    <div class="row">

        <div class="col-md-6">

            <div class="form-group">
                <label>Jumlah Stok Masuk</label>

                <input type="number"
                       name="stok_masuk"
                       class="form-control"
                       placeholder="Masukkan jumlah stok"
                       min="1"
                       required>
            </div>

        </div>

        <div class="col-md-6">

            <div class="form-group">
                <label>Keterangan</label>

                <input type="text"
                       name="keterangan"
                       class="form-control"
                       placeholder="Contoh : Barang baru datang">
            </div>

        </div>

    </div>

</div>

<div class="card-footer text-right">

    <button type="submit"
            name="simpan"
            class="btn btn-success">

        <i class="fas fa-save"></i>
        Simpan

    </button>

    <a href="data_stok.php"
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