<?php
include "koneksi.php";

$nik = $_GET['nik'];

$query = mysqli_query($koneksi, "SELECT * FROM t_penduduk WHERE nik='$nik'");
$data = mysqli_fetch_assoc($query);

echo json_encode($data);