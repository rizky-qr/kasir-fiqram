<?php
session_start();
include "koneksi.php";


if(isset($_POST['simpan'])){

    $nama_user = $_POST['nama_user'];
    $username  = $_POST['username'];
    $password  = md5($_POST['password']);
    $level     = $_POST['level'];

    $cek = mysqli_num_rows(mysqli_query($koneksi,

    "SELECT * FROM user
    WHERE username='$username'"));

    if($cek > 0){

        echo "
        <script>
            alert('Username sudah digunakan');
        </script>
        ";

    }else{

        mysqli_query($koneksi,

        "INSERT INTO user
        (nama_user,username,password,level)

        VALUES

        ('$nama_user',
        '$username',
        '$password',
        '$level')");

        echo "
        <script>

            alert('User berhasil ditambahkan');

            window.location='user.php';

        </script>
        ";

    }

}


if(isset($_GET['hapus'])){

    $id = $_GET['hapus'];

    mysqli_query($koneksi,

    "DELETE FROM user
    WHERE id_user='$id'");

    echo "
    <script>

        alert('User berhasil dihapus');

        window.location='user.php';

    </script>
    ";

}

?>

<!DOCTYPE html>
<html lang="id">

<head>

<meta charset="UTF-8">
<meta name="viewport"
content="width=device-width, initial-scale=1">

<title>Data User</title>

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">


<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>

body{
    background:#f4f6f9;
    font-family:'Segoe UI',sans-serif;
}

.card{
    border:none;
    border-radius:20px;
}

.btn{
    border-radius:12px;
}


.form-control{
    border-radius:12px;
}


.table{
    border-radius:15px;
    overflow:hidden;
}

.table thead{
    background:#007bff;
    color:white;
}


.header-title{
    font-weight:bold;
}


.shadow-custom{
    box-shadow:0 5px 20px rgba(0,0,0,0.1);
}

</style>

</head>

<body>

<div class="container-fluid mt-4">


    <div class="card shadow-custom mb-4">

        <div class="card-body">

            <div class="row align-items-center">

                <div class="col-md-6">

                    <h3 class="header-title">

                        <i class="fas fa-users text-primary"></i>

                        Form Data User

                    </h3>

                </div>

                <div class="col-md-6 text-right">

                    <a href="dashboard.php"
                    class="btn btn-secondary">

                        <i class="fas fa-home"></i>
                        Dashboard

                    </a>

                </div>

            </div>

        </div>

    </div>

    <div class="row">

        <div class="col-md-4">

            <div class="card shadow-custom">

                <div class="card-header bg-primary text-white">

                    <h5 class="mb-0">

                        <i class="fas fa-user-plus"></i>

                        Tambah User

                    </h5>

                </div>

                <div class="card-body">

                    <form method="POST">


                        <div class="form-group">

                            <label>Nama User</label>

                            <input type="text"
                            name="nama_user"
                            class="form-control"
                            placeholder="Masukkan nama user"
                            required>

                        </div>

                        <div class="form-group">

                            <label>Username</label>

                            <input type="text"
                            name="username"
                            class="form-control"
                            placeholder="Masukkan username"
                            required>

                        </div>

                        <div class="form-group">

                            <label>Password</label>

                            <input type="password"
                            name="password"
                            class="form-control"
                            placeholder="Masukkan password"
                            required>

                        </div>

                        <div class="form-group">

                            <label>Level</label>

                            <select name="level"
                            class="form-control"
                            required>

                                <option value="">
                                    -- Pilih Level --
                                </option>

                                <option value="admin">
                                    Admin
                                </option>

                                <option value="kasir">
                                    Kasir
                                </option>

                            </select>

                        </div>

                        <button type="submit"
                        name="simpan"
                        class="btn btn-primary btn-block">

                            <i class="fas fa-save"></i>

                            Simpan User

                        </button>

                    </form>

                </div>

            </div>

        </div>

        <div class="col-md-8">

            <div class="card shadow-custom">

                <div class="card-header bg-success text-white">

                    <h5 class="mb-0">

                        <i class="fas fa-table"></i>

                        Data User

                    </h5>

                </div>

                <div class="card-body">

                    <div class="table-responsive">

                        <table class="table table-bordered table-hover">

                            <thead>

                                <tr>

                                    <th width="5%">No</th>
                                    <th>Nama User</th>
                                    <th>Username</th>
                                    <th>Level</th>
                                    <th width="15%">Aksi</th>

                                </tr>

                            </thead>

                            <tbody>

                            <?php

                            $no = 1;

                            $query = mysqli_query($koneksi,

                            "SELECT * FROM user
                            ORDER BY id_user DESC");

                            while($data =
                            mysqli_fetch_assoc($query)){

                            ?>

                                <tr>

                                    <td>
                                        <?= $no++ ?>
                                    </td>

                                    <td>

                                        <i class="fas fa-user-circle
                                        text-primary"></i>

                                        <?= $data['nama_user'] ?>

                                    </td>

                                    <td>

                                        <?= $data['username'] ?>

                                    </td>

                                    <td>

                                        <?php
                                        if($data['level']
                                        == 'admin'){
                                        ?>

                                            <span class="badge
                                            badge-primary p-2">

                                                Admin

                                            </span>

                                        <?php }else{ ?>

                                            <span class="badge
                                            badge-success p-2">

                                                Kasir

                                            </span>

                                        <?php } ?>

                                    </td>

                                    <td>

                                        <a href="edit_user.php?id=
                                        <?= $data['id_user'] ?>"

                                        class="btn btn-warning btn-sm">

                                            <i class="fas fa-edit"></i>

                                        </a>

                                        <a href="?hapus=
                                        <?= $data['id_user'] ?>"

                                        class="btn btn-danger btn-sm"

                                        onclick="return confirm
                                        ('Yakin hapus user?')">

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