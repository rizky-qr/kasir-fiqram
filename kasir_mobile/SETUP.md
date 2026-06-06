# Setup Kasir Mobile (Windows)

## 1. Tambahkan Flutter ke PATH

1. Win + R → `sysdm.cpl` → **Environment Variables**
2. Path user → **New** → `C:\flutter\bin`
3. Tutup semua CMD/Cursor, buka lagi
4. Cek: `flutter --version`

## 2. Install Android Studio (untuk build APK)

1. Download: https://developer.android.com/studio
2. Install → buka Android Studio → **SDK Manager**
3. Centang: Android SDK Platform, Android SDK Build-Tools, Android SDK Command-line Tools
4. Di CMD:

```bash
flutter doctor --android-licenses
```

Terima semua lisensi dengan `y`.

## 3. Jalankan backend (XAMPP)

- Apache + MySQL ON
- Database `transaksi` sudah di-import
- Tes API: buka browser  
  `http://localhost/aplikasi_post/api/login.php` (harus error method, artinya file ada)

## 4. Konfigurasi URL di app

Edit `lib/config/api_config.dart`:

| Perangkat    | URL                                      |
| ------------ | ---------------------------------------- |
| Emulator     | `http://10.0.2.2/aplikasi_post/api`      |
| HP WiFi sama | `http://192.168.0.107/aplikasi_post/api` |

Cek IP: `ipconfig` → IPv4 Address

## 5. Jalankan di VS Code / Cursor

1. Install extension: **Dart** dan **Flutter** (publisher: Dart Code)
2. **File → Open Folder** → pilih `c:\xampp\htdocs\kasir_mobile`
3. Pastikan XAMPP (Apache + MySQL) sudah ON
4. Pilih device di kanan bawah status bar (Chrome / Windows / emulator Android)
5. Tekan **F5** atau menu **Run → Start Debugging**
   - Atau buka **Run and Debug** (Ctrl+Shift+D) → pilih **Kasir Mobile (Debug)**

Jika Flutter tidak terdeteksi, file `.vscode/settings.json` sudah mengarah ke `C:\flutter`.

## 6. Build & run (terminal)

```bash
cd c:\laragon\www\kasir_mobile
flutter pub get
flutter run
flutter build apk --release
```

APK: `build\app\outputs\flutter-apk\app-release.apk`

## Login

- Username: `admin`
- Password: `admin123`

## Fitur lengkap

- Transaksi kasir
- Dashboard
- Produk (tambah/edit/hapus — admin)
- Kategori (admin)
- Stok masuk
- Laporan penjualan
- Kelola user (admin)
