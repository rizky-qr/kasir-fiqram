# 🛒 Kasir Fiqram

Aplikasi kasir (Point of Sale) modern yang mengintegrasikan backend REST API berbasis PHP dan frontend mobile berbasis Flutter untuk mengelola produk, kategori, stok, transaksi penjualan, ongkos kirim real-time, dan laporan penjualan.

---

## 📋 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Fitur Baru & Unggulan](#-fitur-baru--unggulan)
- [Teknologi](#-teknologi)
- [Struktur Proyek](#-struktur-proyek)
- [Prasyarat](#-prasyarat)
- [Instalasi & Setup](#-instalasi--setup)
  - [Backend REST API (aplikasi_post)](#backend-rest-api-aplikasi_post)
  - [Aplikasi Mobile (kasir_mobile)](#aplikasi-mobile-kasir_mobile)
- [Konfigurasi API](#-konfigurasi-api)
- [API Endpoints](#-api-endpoints)
- [Struktur Database](#-struktur-database)
- [Developer](#-developer)

---

## 📖 Tentang Proyek

**Kasir Fiqram** saat ini menggunakan arsitektur **API-First**:
- **Backend API (`aplikasi_post`)** — REST API yang murni menyajikan data transaksi, produk, stok, user, chat, serta proxy RajaOngkir. Semua modul UI web lama telah dihapus agar sistem terfokus dan aman.
- **Frontend Mobile (`kasir_mobile`)** — Aplikasi Flutter premium dengan performa tinggi yang digunakan oleh semua tingkatan pengguna (Admin, Kasir, dan Pelanggan) untuk bertransaksi secara real-time.

---

## ✨ Fitur Baru & Unggulan

### 📱 Aplikasi Mobile (Flutter)
- 🔐 **Autentikasi & Registrasi** — Login via REST API serta formulir registrasi pelanggan baru secara langsung di aplikasi.
- 🚚 **RajaOngkir Komerce API v2** — Pencarian destinasi kelurahan/kecamatan domestik secara inline serta perhitungan biaya ongkos kirim real-time untuk kurir J&T, POS, dan TIKI.
- 💳 **Metode Pembayaran Modern** — UI pemilihan metode pembayaran (COD, Bank Transfer, QRIS, GoPay, OVO) dengan ringkasan berat total belanjaan (dalam Gram/KG).
- 👥 **Kelola Pengguna Premium** — Halaman manajemen user untuk admin dengan bilah pencarian real-time, input Email & Nomor HP, serta form pendaftaran user dalam *slide-up bottom sheet*.
- 📋 **Kartu Transaksi Detail** — Kartu riwayat pesanan (Admin & Pelanggan) yang menampilkan detail belanjaan secara langsung tanpa perlu klik expand.
- 💬 **Chat Real-time** — Fitur chat langsung di aplikasi antara pelanggan dan admin.

### 🔌 Backend REST API (PHP)
- 🛠️ **Auto-Migration Database** — `helpers.php` secara otomatis melakukan migrasi database (membuat kolom `email`, `no_hp`, `alamat` pada tabel `user`, dan kolom `berat` pada tabel `produk`) saat dijalankan pertama kali.
- 🔒 **Keamanan Prepared Statements** — Semua proses input (registrasi, login, penambahan produk, chat, dll.) menggunakan Prepared Statements untuk mencegah celah SQL Injection.
- 🔐 **Token Session Management** — Manajemen otentikasi berbasis token unik di database.

---

## 🛠️ Teknologi

### Backend REST API
| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| PHP | ≥ 7.4 | REST API & Core Engine |
| MySQL | ≥ 5.7 | Database utama |
| RajaOngkir | Komerce v2 | API ongkos kirim & destinasi |

### Frontend Mobile (Flutter)
| Library / Package | Keterangan |
|-------------------|------------|
| `google_fonts` | Tipografi premium (Outfit/Inter) |
| `shimmer` | Shimmer loading skeleton |
| `http` | HTTP Client untuk integrasi API |
| `shared_preferences` | Manajemen session lokal |
| `image_picker` | Unggah foto produk |

---

## 📁 Struktur Proyek

```
fiqram/
├── aplikasi_post/          # Backend REST API
│   ├── api/                # API Endpoints & Core Helpers
│   │   ├── chat.php
│   │   ├── dashboard.php
│   │   ├── helpers.php     # Inisialisasi DB, CORS, & Auto-Migration
│   │   ├── kategori.php
│   │   ├── kota.php        # Proxy Destinasi Komerce
│   │   ├── login.php
│   │   ├── logout.php
│   │   ├── ongkir.php      # Proxy Hitung Ongkir Komerce
│   │   ├── penjualan.php
│   │   ├── produk.php
│   │   ├── profile.php     # Manajemen Profil User
│   │   ├── register.php    # Registrasi Akun Baru
│   │   ├── stok.php
│   │   ├── user.php
│   │   └── verifikasi_penjualan.php
│   ├── img/                # Aset Gambar Statis Instansi
│   └── upload/             # Direktori Unggah Foto Produk
├── kasir_mobile/           # Frontend Mobile Flutter
│   ├── lib/
│   │   ├── config/
│   │   │   └── api_config.dart     # Konfigurasi URL API & API Key RajaOngkir
│   │   ├── models/                 # Model Data (JSON Mapper)
│   │   ├── screens/                # UI Halaman Mobile
│   │   └── services/
│   │       └── api_service.dart    # Komunikasi REST API
│   ├── pubspec.yaml        # Konfigurasi Dependensi Flutter
│   └── ...
├── transaksi.sql           # Schema Database Bersih
└── README.md
```

---

## ⚙️ Prasyarat

- **Laragon / XAMPP** dengan PHP ≥ 7.4 dan MySQL menyala.
- **Flutter SDK** ≥ 3.2.0 terinstal di sistem Anda.

---

## 🚀 Instalasi & Setup

### Backend REST API (aplikasi_post)

**1. Salin folder proyek ke direktori web server**
Pindahkan folder `aplikasi_post/` ke dalam direktori Laragon atau XAMPP Anda:
```
# Laragon
C:/laragon/www/fiqram/aplikasi_post/

# XAMPP
C:/xampp/htdocs/fiqram/aplikasi_post/
```

**2. Impor database**
Buka phpMyAdmin atau HeidiSQL, buat database baru bernama `transaksi`, lalu impor file database utama di root direktori:
```
transaksi.sql
```

**3. Konfigurasi koneksi database**
Buka file `aplikasi_post/api/helpers.php` dan sesuaikan parameter koneksi database Anda di baris berikut:
```php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "transaksi";
```

---

### Aplikasi Mobile (kasir_mobile)

**1. Masuk ke direktori mobile**
```bash
cd kasir_mobile
```

**2. Instal dependensi Flutter**
```bash
flutter pub get
```

**3. Konfigurasi Endpoint & RajaOngkir**
Buka file `lib/config/api_config.dart` dan sesuaikan konfigurasinya:
```dart
class ApiConfig {
  // Base URL backend PHP
  static String get baseUrl => 'http://localhost/fiqram/aplikasi_post/api';

  // API Key Komerce RajaOngkir
  static const String rajaOngkirKey = '023d02b03933cc6ebfc80bd43205ec31';

  // ID Kota asal default (Surabaya: 444, Dompu: 90)
  static const String originCityId = '90';
}
```

**4. Jalankan aplikasi**
```bash
flutter run
```

---

## 🔧 Konfigurasi API

| Jenis Perangkat | Format Base URL |
|-----------------|-----------------|
| Browser / Web Localhost | `http://localhost/fiqram/aplikasi_post/api` |
| Emulator Android | `http://10.0.2.2/fiqram/aplikasi_post/api` |
| HP Fisik (WiFi Sama) | `http://<IP_KOMPUTER>/fiqram/aplikasi_post/api` |

---

## 📡 API Endpoints

REST API Base: `http://localhost/fiqram/aplikasi_post/api`

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/login.php` | Login akun & kirim token |
| POST | `/logout.php` | Hapus token session |
| POST | `/register.php` | Registrasi akun pelanggan baru |
| GET/POST | `/profile.php` | Ambil / simpan perubahan profil |
| GET | `/dashboard.php` | Statistik performa untuk admin/kasir |
| GET/POST/DELETE | `/produk.php` | CRUD produk & upload foto |
| GET/POST/DELETE | `/kategori.php` | CRUD kategori produk |
| GET/POST | `/penjualan.php` | Kirim transaksi baru & riwayat order |
| POST | `/verifikasi_penjualan.php` | Verifikasi status transaksi oleh admin |
| GET/POST | `/stok.php` | Monitoring & update stok |
| GET/POST/DELETE | `/user.php` | CRUD user manajemen (admin) |
| GET/POST | `/chat.php` | Kirim & baca pesan chat realtime |
| GET | `/kota.php` | Pencarian kota RajaOngkir Komerce |
| GET | `/ongkir.php` | Hitung ongkos kirim Komerce |

---

## 🗄️ Struktur Database

Database `transaksi` saat ini terdiri dari **8 tabel aktif**:

| Tabel | Deskripsi |
|-------|-----------|
| `user` | Menyimpan kredensial login (admin, kasir, pelanggan), email, nomor HP, dan alamat rumah. |
| `produk` | Daftar produk, kategori, harga, stok, foto, dan berat produk (dalam gram). |
| `kategori` | Kategori produk. |
| `stok` | Riwayat masuknya stok barang. |
| `penjualan` | Header data pesanan, metode bayar, kota tujuan, ongkir, dan total transaksi. |
| `detail_penjualan` | Detail kuantitas, harga, subtotal, dan satuan (KG/TON) tiap item pesanan. |
| `tokens` | Token otentikasi session login pengguna. |
| `chat` | Riwayat komunikasi pelanggan dan admin. |

> Skema lengkap dapat diinisialisasi melalui file [`transaksi.sql`](./transaksi.sql).

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
