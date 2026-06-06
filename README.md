# 🛒 Kasir Fiqram

Aplikasi kasir berbasis web dan mobile yang terintegrasi untuk manajemen transaksi, produk, stok, dan laporan penjualan.

---

## 📋 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Fitur](#-fitur)
- [Teknologi](#-teknologi)
- [Struktur Proyek](#-struktur-proyek)
- [Prasyarat](#-prasyarat)
- [Instalasi](#-instalasi)
  - [Aplikasi Web (aplikasi_post)](#aplikasi-web-aplikasi_post)
  - [Aplikasi Mobile (kasir_mobile)](#aplikasi-mobile-kasir_mobile)
- [Konfigurasi API](#-konfigurasi-api)
- [Penggunaan](#-penggunaan)
- [API Endpoints](#-api-endpoints)
- [Struktur Database](#-struktur-database)
- [Kontribusi](#-kontribusi)

---

## 📖 Tentang Proyek

**Kasir Fiqram** adalah sistem Point of Sale (POS) yang terdiri dari:
- **Aplikasi Web** — Backend & frontend berbasis PHP untuk manajemen kasir melalui browser
- **Aplikasi Mobile** — Aplikasi Flutter untuk kasir di perangkat Android/iOS
- **WebSocket Server** — Server real-time untuk fitur chat antar pengguna

---

## ✨ Fitur

### Aplikasi Web
- 🔐 **Autentikasi** — Login & logout dengan manajemen sesi
- 📊 **Dashboard** — Ringkasan penjualan, produk, dan stok
- 🛍️ **Transaksi** — Proses penjualan & pembayaran
- 📦 **Manajemen Produk** — Tambah, edit, hapus produk beserta foto
- 🗂️ **Kategori** — Pengelompokan produk berdasarkan kategori
- 📈 **Stok** — Monitoring dan penambahan stok produk
- 📋 **Laporan** — Laporan penjualan dengan filter tanggal
- 👥 **Manajemen User** — Tambah, edit, hapus pengguna
- 💬 **Chat Real-time** — Komunikasi antar pengguna via WebSocket

### Aplikasi Mobile (Flutter)
- 🔐 **Login** — Autentikasi via REST API
- 🏠 **Dashboard** — Statistik penjualan harian
- 🛒 **Transaksi** — Proses transaksi dari perangkat mobile
- 📦 **Produk** — Melihat & mengelola produk
- 🗂️ **Kategori** — Manajemen kategori produk
- 📈 **Stok** — Monitoring stok
- 📋 **Laporan** — Laporan penjualan
- 👥 **User** — Manajemen pengguna
- 💬 **Chat** — Fitur chat real-time

---

## 🛠️ Teknologi

### Backend (Web)
| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| PHP | ≥ 7.4 | Backend utama |
| MySQL | ≥ 5.7 | Database |
| AdminLTE | 3.x | Template UI |
| Ratchet PHP | Latest | WebSocket server |
| Composer | 2.x | Package manager |

### Frontend Mobile
| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| Flutter | ≥ 3.2.0 | Framework mobile |
| Dart | ≥ 3.2.0 | Bahasa pemrograman |
| `http` | ^1.2.0 | HTTP client |
| `shared_preferences` | ^2.2.2 | Penyimpanan lokal |
| `intl` | ^0.19.0 | Format tanggal & angka |
| `image_picker` | ^1.0.7 | Upload foto produk |

---

## 📁 Struktur Proyek

```
kasir-fiqram/
├── aplikasi_post/          # Aplikasi Web PHP
│   ├── api/                # REST API endpoints
│   │   ├── login.php
│   │   ├── dashboard.php
│   │   ├── produk.php
│   │   ├── kategori.php
│   │   ├── penjualan.php
│   │   ├── stok.php
│   │   ├── user.php
│   │   └── chat.php
│   ├── pages/              # Halaman-halaman tambahan
│   ├── plugins/            # Library JS/CSS (AdminLTE, dll)
│   ├── img/                # Gambar statis
│   ├── upload/             # Upload foto produk
│   ├── websocket/          # WebSocket server (Ratchet)
│   ├── koneksi.php         # Konfigurasi database
│   ├── login.php           # Halaman login
│   ├── dashboard.php       # Halaman dashboard
│   ├── transaksi.php       # Halaman transaksi
│   ├── produk.php          # Halaman produk
│   ├── kategori.php        # Halaman kategori
│   ├── stok.php            # Halaman stok
│   ├── laporan.php         # Halaman laporan
│   ├── user.php            # Halaman manajemen user
│   └── transaksi.sql       # Skema database
├── kasir_mobile/           # Aplikasi Flutter
│   ├── lib/
│   │   ├── config/
│   │   │   └── api_config.dart     # Konfigurasi URL API
│   │   ├── models/                 # Model data
│   │   ├── screens/                # Halaman UI
│   │   └── services/
│   │       └── api_service.dart    # HTTP service
│   ├── android/            # Konfigurasi Android
│   ├── ios/                # Konfigurasi iOS
│   └── pubspec.yaml        # Dependencies Flutter
├── transaksi.sql           # Skema database utama
└── README.md
```

---

## ⚙️ Prasyarat

### Untuk Aplikasi Web
- [Laragon](https://laragon.org/) / XAMPP / WAMP
- PHP ≥ 7.4
- MySQL ≥ 5.7
- Composer

### Untuk Aplikasi Mobile
- [Flutter SDK](https://flutter.dev/) ≥ 3.2.0
- Android Studio / VS Code
- Android SDK (untuk build Android)
- Xcode (untuk build iOS, hanya di macOS)

---

## 🚀 Instalasi

### Aplikasi Web (aplikasi_post)

**1. Clone repository**
```bash
git clone https://github.com/rizky-qr/kasir-fiqram.git
cd kasir-fiqram
```

**2. Pindahkan folder ke direktori web server**
```
# Laragon
C:/laragon/www/fiqram/

# XAMPP
C:/xampp/htdocs/fiqram/
```

**3. Import database**

Buka phpMyAdmin → Buat database baru bernama `transaksi` → Import file:
```
transaksi.sql
```
atau gunakan file SQL di dalam folder aplikasi_post:
```
aplikasi_post/transaksi.sql
```

**4. Konfigurasi koneksi database**

Edit file `aplikasi_post/koneksi.php`:
```php
<?php
$host = "localhost";
$user = "root";       // sesuaikan username MySQL
$pass = "";           // sesuaikan password MySQL
$db   = "transaksi";  // nama database

$koneksi = mysqli_connect($host, $user, $pass, $db);
?>
```

**5. Install dependencies (opsional)**
```bash
cd aplikasi_post
composer install
```

**6. Akses aplikasi**
```
http://localhost/fiqram/aplikasi_post/
```

---

### Aplikasi Mobile (kasir_mobile)

**1. Masuk ke folder mobile**
```bash
cd kasir-fiqram/kasir_mobile
```

**2. Install dependencies Flutter**
```bash
flutter pub get
```

**3. Konfigurasi URL API**

Edit file `lib/config/api_config.dart`:
```dart
class ApiConfig {
  // Emulator Android
  static String get baseUrl => 'http://10.0.2.2/fiqram/aplikasi_post/api';

  // HP fisik (ganti dengan IP komputer kamu)
  // static String get baseUrl => 'http://192.168.1.100/fiqram/aplikasi_post/api';
}
```

**4. Jalankan aplikasi**
```bash
# Cek perangkat yang tersedia
flutter devices

# Jalankan di emulator/device
flutter run
```

**5. Build APK (opsional)**
```bash
flutter build apk --release
```
File APK tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

---

### WebSocket Server (Real-time Chat)

```bash
cd aplikasi_post/websocket
composer install
php server.php
```

---

## 🔧 Konfigurasi API

| Skenario | URL Base |
|----------|----------|
| Browser / localhost | `http://localhost/fiqram/aplikasi_post/api` |
| Emulator Android | `http://10.0.2.2/fiqram/aplikasi_post/api` |
| HP fisik (WiFi sama) | `http://<IP_KOMPUTER>/fiqram/aplikasi_post/api` |
| ADB Reverse Tunnel | `http://127.0.0.1:8080/fiqram/aplikasi_post/api` |

> **Catatan:** Untuk HP fisik, cari IP komputer dengan `ipconfig` (Windows) atau `ifconfig` (Linux/Mac), lalu pastikan HP dan komputer terhubung ke WiFi yang sama.

---

## 📡 API Endpoints

Base URL: `http://localhost/fiqram/aplikasi_post/api`

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/login.php` | Login pengguna |
| POST | `/logout.php` | Logout pengguna |
| GET | `/dashboard.php` | Data statistik dashboard |
| GET/POST/PUT/DELETE | `/produk.php` | CRUD produk |
| GET/POST/PUT/DELETE | `/kategori.php` | CRUD kategori |
| GET/POST | `/penjualan.php` | Data & proses penjualan |
| GET/POST | `/stok.php` | Data & update stok |
| GET/POST/PUT/DELETE | `/user.php` | CRUD pengguna |
| GET/POST | `/chat.php` | Pesan chat |

---

## 🗄️ Struktur Database

Database: `transaksi`

| Tabel | Deskripsi |
|-------|-----------|
| `users` | Data pengguna / kasir |
| `kategori` | Kategori produk |
| `produk` | Data produk & harga |
| `penjualan` | Header transaksi penjualan |
| `detail_penjualan` | Detail item per transaksi |
| `stok` | Riwayat perubahan stok |
| `chat` | Riwayat pesan chat |

> Untuk skema lengkap, lihat file [`transaksi.sql`](./transaksi.sql)

---

## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b fitur/nama-fitur`)
3. Commit perubahan (`git commit -m 'Tambah fitur X'`)
4. Push ke branch (`git push origin fitur/nama-fitur`)
5. Buat Pull Request

---

## 👨‍💻 Developer

**Fiqram**
**Rizky** — [@rizky-qr](https://github.com/rizky-qr)

---

<p align="center">Made with ❤️ using PHP & Flutter</p>
