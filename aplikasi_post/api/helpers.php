<?php
// Pastikan TIDAK ADA spasi kosong atau enter sebelum tag <?php di baris pertama ini!

// ─── CORS Headers ───────────────────────────────────────────────────────────
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

// Tangani preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ─── Kumpulan Fungsi (Helpers) ──────────────────────────────────────────────
if (!function_exists('jsonResponse')) {
    function jsonResponse(bool $success, string $message = '', $data = null, int $code = 200): void {
        http_response_code($code);
        $resp = ['success' => $success, 'message' => $message];
        if ($data !== null) {
            $resp = array_merge($resp, $data);
        }
        echo json_encode($resp, JSON_UNESCAPED_UNICODE);
        exit;
    }
}

if (!function_exists('generateToken')) {
    function generateToken(): string {
        return bin2hex(random_bytes(32));
    }
}

if (!function_exists('getBearerToken')) {
    function getBearerToken(): ?string {
        $headers = null;
        if (isset($_SERVER['Authorization'])) {
            $headers = trim($_SERVER["Authorization"]);
        } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
        } elseif (function_exists('apache_request_headers')) {
            $requestHeaders = apache_request_headers();
            // PERBAIKAN: Ubah semua key array menjadi huruf kecil agar kebal error (case-insensitive)
            $requestHeaders = array_change_key_case($requestHeaders, CASE_LOWER);
            if (isset($requestHeaders['authorization'])) {
                $headers = trim($requestHeaders['authorization']);
            }
        }
        
        if ($headers && preg_match('/Bearer\s+(.+)/i', $headers, $m)) {
            return $m[1];
        }
        return null;
    }
}

if (!function_exists('requireAuth')) {
    function requireAuth(mysqli $koneksi): array {
        $token = getBearerToken();
        if (!$token) {
            jsonResponse(false, 'Token tidak ditemukan. Harap login terlebih dahulu.', null, 401);
        }
        
        $token = mysqli_real_escape_string($koneksi, $token);
        $res = mysqli_query($koneksi, "
            SELECT user.* FROM tokens
            JOIN user ON tokens.id_user = user.id_user
            WHERE tokens.token = '$token'
            LIMIT 1
        ");
        
        if (!$res) {
            jsonResponse(false, 'Terjadi kesalahan pada database.', null, 500);
        }
        
        $userData = mysqli_fetch_assoc($res);
        if (!$userData) {
            jsonResponse(false, 'Token tidak valid atau sudah kadaluarsa. Harap login ulang.', null, 401);
        }
        return $userData;
    }
}

if (!function_exists('getJsonBody')) {
    function getJsonBody(): array {
        $raw = file_get_contents('php://input');
        if (empty($raw)) return [];
        $data = json_decode($raw, true);
        return is_array($data) ? $data : [];
    }
}

// ─── Koneksi Database ────────────────────────────────────────────────────────
$host = "localhost";
$user = "root";
$pass = "";
$db   = "transaksi";

// Mematikan warning bawaan PHP agar tidak merusak format output JSON
mysqli_report(MYSQLI_REPORT_OFF);

$koneksi = mysqli_connect($host, $user, $pass, $db);
if (!$koneksi) {
    jsonResponse(false, "Koneksi database gagal. Pastikan Laragon/XAMPP sudah menyala.", null, 500);
}
mysqli_set_charset($koneksi, "utf8");

// ─── Buat tabel tokens jika belum ada ───────────────────────────────────────
mysqli_query($koneksi, "
    CREATE TABLE IF NOT EXISTS tokens (
        id INT AUTO_INCREMENT PRIMARY KEY,
        id_user INT NOT NULL,
        token VARCHAR(64) NOT NULL UNIQUE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
");

// ─── Migrasi kolom user (email, no_hp, alamat) ──────────────────────────────
$resEmail = mysqli_query($koneksi, "SHOW COLUMNS FROM user LIKE 'email'");
if (mysqli_num_rows($resEmail) == 0) {
    mysqli_query($koneksi, "ALTER TABLE user ADD COLUMN email VARCHAR(100) DEFAULT '' AFTER nama_user");
}
$resNoHp = mysqli_query($koneksi, "SHOW COLUMNS FROM user LIKE 'no_hp'");
if (mysqli_num_rows($resNoHp) == 0) {
    mysqli_query($koneksi, "ALTER TABLE user ADD COLUMN no_hp VARCHAR(20) DEFAULT '' AFTER email");
}
$resAlamat = mysqli_query($koneksi, "SHOW COLUMNS FROM user LIKE 'alamat'");
if (mysqli_num_rows($resAlamat) == 0) {
    mysqli_query($koneksi, "ALTER TABLE user ADD COLUMN alamat TEXT AFTER no_hp");
}

// ─── Migrasi kolom produk (berat dalam gram) ───────────────────────────────
$resBerat = mysqli_query($koneksi, "SHOW COLUMNS FROM produk LIKE 'berat'");
if (mysqli_num_rows($resBerat) == 0) {
    mysqli_query($koneksi, "ALTER TABLE produk ADD COLUMN berat INT DEFAULT 1000 AFTER stok");
}

// ─── Buat folder upload jika belum ada ──────────────────────────────────────
$uploadDir = __DIR__ . '/../upload/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}