<?php
include "koneksi.php";

$id = $_GET['id'];
mysqli_query($koneksi,
"DELETE FROM detail_penjualan WHERE id_penjualan='$id'");
mysqli_query($koneksi,
"DELETE FROM penjualan WHERE id_penjualan='$id'");

echo "<script>
alert('Transaksi berhasil dihapus');
window.location='laporan.php';
</script>";
?>