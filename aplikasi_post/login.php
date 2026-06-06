<?php
session_start();
include "koneksi.php";

if(isset($_POST['login'])){

    $username = $_POST['username'];
    $password = md5($_POST['password']);

    $query = mysqli_query($koneksi,
    "SELECT * FROM user
    WHERE username='$username'
    AND password='$password'");

    $data = mysqli_fetch_assoc($query);

    if($data){

        $_SESSION['id_user'] = $data['id_user'];
        $_SESSION['nama_user'] = $data['nama_user'];
        $_SESSION['level'] = $data['level'];

        header("location:dashboard.php");

    }else{
        echo "<script>alert('Login Gagal');</script>";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Login Kasir</title>
    <link rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
</head>
<body>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">

            <div class="card shadow">

                <div class="card-header bg-primary text-white text-center">
                    Silahkan Login Terlebih Dahulu
                </div>

                <div class="card-body">

                    <form method="POST">

                        <div class="form-group">
                            <label>Username</label>
                            <input type="text" name="username"
                            class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label>Password</label>
                            <input type="password" name="password"
                            class="form-control" required>
                        </div>

                        <button type="submit" name="login"
                        class="btn btn-primary btn-block">
                            LOGIN
                        </button>

                    </form>

                </div>

            </div>

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