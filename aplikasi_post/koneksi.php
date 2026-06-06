<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "transaksi";

$koneksi = mysqli_connect($host,$user,$pass,$db);

if(!$koneksi){
    die("Koneksi Gagal : ".mysqli_connect_error());
}
?>