<?php
include "koneksi.php";
?>

<section class="content">
<div class="container-fluid">

<div class="card shadow-lg">

    <div class="card-header bg-primary text-white">
        <h4 class="mb-0">
            <i class="fas fa-boxes"></i>
            Laporan Data Stok Barang
        </h4>
    </div>

    <div class="card-body">

        <div class="table-responsive">

            <table id="example1"
                   class="table table-bordered table-striped">

                <thead class="bg-info text-white">

                    <tr align="center">
                        <th>No</th>
                        <th>Tanggal</th>
                        <th>Nama Produk</th>
                        <th>Stok Masuk</th>
                        <th>Keterangan</th>
                    </tr>

                </thead>

                <tbody>

                    <?php
                    $no = 1;

                    $query = mysqli_query($koneksi,"
                        SELECT stok.*, produk.nama_produk
                        FROM stok
                        JOIN produk
                        ON stok.id_produk = produk.id_produk
                        ORDER BY id_stok DESC
                    ");

                    while($data = mysqli_fetch_assoc($query)){
                    ?>

                    <tr>

                        <td align="center">
                            <?= $no++; ?>
                        </td>

                        <td>
                            <?= date('d-m-Y', strtotime($data['tanggal'])); ?>
                        </td>

                        <td>
                            <?= $data['nama_produk']; ?>
                        </td>

                        <td align="center">
                            <?= $data['stok_masuk']; ?>
                        </td>

                        <td>
                            <?= $data['keterangan']; ?>
                        </td>

                    </tr>

                    <?php } ?>

                </tbody>

            </table>

        </div>

    </div>

    <div class="card-footer">

        <a href="cetak_laporan.php"
           target="_blank"
           class="btn btn-success">

           <i class="fas fa-print"></i>
           Cetak Laporan

        </a>

    </div>

</div>

</div>
</section>