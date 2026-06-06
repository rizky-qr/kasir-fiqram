<?php include "koneksi.php"; ?>

<?php
if (isset($_POST['simpan'])){

    $nik = $_POST['nik'];
    $nama = $_POST['nama'];
    $no_kk = $_POST['no_kk'];
    $alamat = $_POST['alamat'];
    $kelamin = $_POST['kelamin'];
    $tempat_lahir = $_POST['tempat_lahir'];
    $tanggal_lahir = $_POST['tanggal_lahir'];
    $agama = $_POST['agama'];
    $pendidikan = $_POST['pendidikan'];
    $hubungan = $_POST['hubungan'];
    $ayah = $_POST['ayah'];
    $ibu = $_POST['ibu'];
    $pekerjaan = $_POST['pekerjaan'];
    $dusun = $_POST['dusun'];
    $status_perkawinan = $_POST['status_perkawinan'];

    // CEK DATA
    $cek = mysqli_query($koneksi, "SELECT * FROM t_penduduk WHERE nik='$nik'");

    if (mysqli_num_rows($cek) > 0) {

        // UPDATE
        mysqli_query($koneksi, "
            UPDATE t_penduduk SET
                nama='$nama',
                no_kk='$no_kk',
                alamat='$alamat',
                kelamin='$kelamin',
                tempat_lahir='$tempat_lahir',
                tanggal_lahir='$tanggal_lahir',
                agama='$agama',
                pendidikan='$pendidikan',
                hubungan='$hubungan',
                ayah='$ayah',
                ibu='$ibu',
                pekerjaan='$pekerjaan',
                dusun='$dusun',
                status_perkawinan='$status_perkawinan'
            WHERE nik='$nik'
        ");

    } else {

        // INSERT
        mysqli_query($koneksi, "
            INSERT INTO t_penduduk
            (nik,nama,no_kk,alamat,kelamin,tempat_lahir,tanggal_lahir,agama,pendidikan,hubungan,ayah,ibu,pekerjaan,dusun,status_perkawinan)
            VALUES
            ('$nik','$nama','$no_kk','$alamat','$kelamin','$tempat_lahir','$tanggal_lahir','$agama','$pendidikan','$hubungan','$ayah','$ibu','$pekerjaan','$dusun','$status_perkawinan')
        ");
    }

    // =====================
    // HANDLE TABEL KK
    // =====================

    $cekKK = mysqli_query($koneksi, "SELECT * FROM t_kk WHERE no_kk='$no_kk'");

    // Cegah anggota tanpa KK
    if ($hubungan != "Kepala Keluarga" && mysqli_num_rows($cekKK) == 0) {
        echo "<script>alert('KK belum dibuat!');window.location='?page=add_penduduk';</script>";
        exit;
    }

    if ($hubungan == "Kepala Keluarga") {

        if (mysqli_num_rows($cekKK) == 0) {
            // INSERT KK
            mysqli_query($koneksi, "
                INSERT INTO t_kk (no_kk, nama_kk, nik, anggota, dusun)
                VALUES ('$no_kk', '$nama', '$nik', 1, '$dusun')
            ");
        } else {
            // UPDATE KK
            mysqli_query($koneksi, "
                UPDATE t_kk SET
                    nama_kk='$nama',
                    nik='$nik',
                    dusun='$dusun'
                WHERE no_kk='$no_kk'
            ");
        }

    } else {
        // TAMBAH ANGGOTA
        mysqli_query($koneksi, "
            UPDATE t_kk 
            SET anggota = anggota + 1
            WHERE no_kk='$no_kk'
        ");
    }

    echo "<script>
        alert('Data berhasil disimpan!');
        window.location='?page=penduduk';
    </script>";
}
?>

<section class="content">
<div class="container-fluid">
<div class="row justify-content-center">
<div class="col-md-10">

<div class="card shadow-lg">
<div class="card-header bg-primary text-white text-center">
    <h4 class="mb-0 font-weight-bold display-6"><i class="fas fa-users"></i>
        Data Kartu Keluarga
    </h4>
    </div>

<form method="post">
<div class="card-body">

<div class="row">

<div class="col-md-6">

<label>NIK</label>
<input type="text" name="nik" id="nik" class="form-control" required>

<label>Nama</label>
<input type="text" name="nama" id="nama" class="form-control">

<label>No KK</label>
<input type="text" name="no_kk" id="no_kk" class="form-control" required>

<label>Alamat</label>
<input type="text" name="alamat" id="alamat" class="form-control">

<label>Kelamin</label>
<select name="kelamin" id="kelamin" class="form-control">
<option value="">Pilih</option>
<option value="Laki-laki">Laki-laki</option>
<option value="Perempuan">Perempuan</option>
</select>

<label>Tempat Lahir</label>
<input type="text" name="tempat_lahir" id="tempat_lahir" class="form-control">

<label>Tanggal Lahir</label>
<input type="date" name="tanggal_lahir" id="tanggal_lahir" class="form-control">

<label>Agama</label>
<select name="agama" id="agama" class="form-control">
<option value="">Pilih</option>
<?php
$q = mysqli_query($koneksi, "SELECT * FROM t_agama");
while ($d = mysqli_fetch_array($q)){
echo "<option value='$d[agama]'>$d[agama]</option>";
}
?>
</select>

<label>Pendidikan</label>
<select name="pendidikan" id="pendidikan" class="form-control">
<option value="">Pilih</option>
<?php
$q = mysqli_query($koneksi, "SELECT * FROM t_pendidikan");
while ($d = mysqli_fetch_array($q)){
echo "<option value='$d[nama]'>$d[nama]</option>";
}
?>
</select>

<label>Hubungan</label>
<select name="hubungan" id="hubungan" class="form-control">
<option value="">Pilih</option>
<option value="Kepala Keluarga">Kepala Keluarga</option>
<option value="Istri">Istri</option>
<option value="Anak">Anak</option>
</select>

<label>Ayah</label>
<input type="text" name="ayah" id="ayah" class="form-control">

<label>Ibu</label>
<input type="text" name="ibu" id="ibu" class="form-control">

<label>Pekerjaan</label>
<select name="pekerjaan" id="pekerjaan" class="form-control">
<option value="">Pilih</option>
<?php
$q = mysqli_query($koneksi, "SELECT * FROM t_pekerjaan");
while ($d = mysqli_fetch_array($q)){
echo "<option value='$d[pekerjaan]'>$d[pekerjaan]</option>";
}
?>
</select>

<label>Dusun</label>
<select name="dusun" id="dusun" class="form-control">
<option value="">Pilih</option>
<?php
$q = mysqli_query($koneksi, "SELECT * FROM t_dusun");
while ($d = mysqli_fetch_array($q)){
echo "<option value='$d[nama]'>$d[nama]</option>";
}
?>
</select>

<label>Status</label>
<select name="status_perkawinan" id="status_perkawinan" class="form-control">
<option value="">Pilih</option>
<option value="Kawin">Kawin</option>
<option value="Lajang">Lajang</option>
<option value="Duda">Duda</option>
<option value="Janda">Janda</option>
</select>

</div>

</div>

</div>

<div class="card-footer text-right">
<button type="submit" name="simpan" class="btn btn-primary">Simpan</button>
</div>

</form>

</div>
</div>
</div>
</div>
</section>

<!-- AUTO FILL -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
$('#nik').keyup(function(){
    var nik = $(this).val();

    if(nik.length >= 8){
        $.ajax({
            url: 'get_kk_penduduk.php',
            method: 'GET',
            data: {nik: nik},
            success: function(data){
                var d = JSON.parse(data);

                if(d){
                    $('#nama').val(d.nama);
                    $('#alamat').val(d.alamat);
                    $('#kelamin').val(d.kelamin);
                    $('#tempat_lahir').val(d.tempat_lahir);
                    $('#tanggal_lahir').val(d.tanggal_lahir);
                    $('#agama').val(d.agama);
                    $('#pendidikan').val(d.pendidikan);
                    $('#ayah').val(d.ayah);
                    $('#ibu').val(d.ibu);
                    $('#pekerjaan').val(d.pekerjaan);
                    $('#dusun').val(d.dusun);
                    $('#status_perkawinan').val(d.status_perkawinan);
                }
            }
        });
    }
});
</script>