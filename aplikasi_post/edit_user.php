<?php
session_start();
include "koneksi.php";

$id = $_GET['id'];

$query = mysqli_query($koneksi,

"SELECT * FROM user
WHERE id_user='$id'");

$data = mysqli_fetch_assoc($query);

if(isset($_POST['update'])){

    $nama_user = $_POST['nama_user'];
    $username  = $_POST['username'];
    $level     = $_POST['level'];

    if(!empty($_POST['password'])){

        $password = md5($_POST['password']);

        mysqli_query($koneksi,

        "UPDATE user SET

        nama_user='$nama_user',
        username='$username',
        password='$password',
        level='$level'

        WHERE id_user='$id'");

    }else{

        mysqli_query($koneksi,

        "UPDATE user SET

        nama_user='$nama_user',
        username='$username',
        level='$level'

        WHERE id_user='$id'");

    }

    echo "
    <script>

        alert('User berhasil diupdate');

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

<title>Edit Data User</title>

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


.form-control{
    border-radius:12px;
    height:45px;
}

.btn{
    border-radius:12px;
}


.shadow-custom{
    box-shadow:0 5px 20px rgba(0,0,0,0.1);
}

</style>

</head>

<body>

<div class="container mt-5">

    <div class="row justify-content-center">

        <div class="col-md-6">

            <div class="card shadow-custom">

                          <div class="card-header bg-warning text-dark">

                    <h4 class="mb-0">

                        <i class="fas fa-user-edit"></i>

                        Edit User

                    </h4>

                </div>

                <div class="card-body">

                    <form method="POST">
                        

                        <div class="form-group">

                            <label>Nama User</label>

                            <input type="text"
                            name="nama_user"
                            class="form-control"

                            value="<?= $data['nama_user'] ?>"

                            required>

                        </div>

                        <div class="form-group">

                            <label>Username</label>

                            <input type="text"
                            name="username"
                            class="form-control"

                            value="<?= $data['username'] ?>"

                            required>

                        </div>

                        <div class="form-group">

                            <label>Password Baru</label>

                            <input type="password"
                            name="password"
                            class="form-control"

                            placeholder=
                            "Kosongkan jika tidak diubah">

                            <small class="text-muted">

                                Isi password jika ingin mengganti password

                            </small>

                        </div>

                        <div class="form-group">

                            <label>Level</label>

                            <select name="level"
                            class="form-control"
                            required>

                                <option value="admin"

                                <?php
                                if($data['level']=='admin'){
                                    echo "selected";
                                }
                                ?>>

                                    Admin

                                </option>

                                <option value="kasir"

                                <?php
                                if($data['level']=='kasir'){
                                    echo "selected";
                                }
                                ?>>

                                    Kasir

                                </option>

                            </select>

                        </div>

                        <hr>

                        <div class="row">

                            <div class="col-md-6 mb-2">

                                <button type="submit"
                                name="update"

                                class="btn btn-warning btn-block">

                                    <i class="fas fa-save"></i>

                                    Update

                                </button>

                            </div>

                            <div class="col-md-6 mb-2">

                                <a href="user.php"
                                class="btn btn-secondary btn-block">

                                    <i class="fas fa-arrow-left"></i>

                                    Kembali

                                </a>

                            </div>

                        </div>

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