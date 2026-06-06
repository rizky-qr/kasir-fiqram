<?php
require_once __DIR__ . '/helpers.php';

// ─── Konfigurasi RajaOngkir ───────────────────────────────────────────────────
// Ganti dengan API Key kamu dari https://rajaongkir.com
define('RAJAONGKIR_KEY', '023d02b03933cc6ebfc80bd43205ec31');
define('RAJAONGKIR_URL', 'https://rajaongkir.komerce.id/api/v1');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(false, 'Method tidak diizinkan. Gunakan GET.', null, 405);
}

requireAuth($koneksi);

$origin      = trim($_GET['origin']      ?? '74945'); // default: Surabaya subdistrict
$destination = trim($_GET['destination'] ?? '');
$weight      = (int) ($_GET['weight']    ?? 1000);    // gram
$courier     = trim($_GET['courier']     ?? 'jne');   // jne | pos | tiki | jnt | sicepat | etc.

if (empty($destination)) {
    jsonResponse(false, 'Parameter destination (id kota tujuan) wajib diisi.', null, 400);
}

// Translate courier codes if needed (e.g. 'j&t' to 'jnt')
$courier = strtolower($courier);
if ($courier === 'j&t' || $courier === 'jnt') {
    $courier = 'jnt';
}

// ─── Call RajaOngkir Komerce API: Calculate Cost ─────────────────────────────
$ch = curl_init();
curl_setopt_array($ch, [
    CURLOPT_URL            => RAJAONGKIR_URL . '/calculate/domestic-cost',
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST           => true,
    CURLOPT_POSTFIELDS     => http_build_query([
        'origin'      => $origin,
        'destination' => $destination,
        'weight'      => $weight,
        'courier'     => $courier,
    ]),
    CURLOPT_HTTPHEADER     => [
        'key: ' . RAJAONGKIR_KEY,
        'content-type: application/x-www-form-urlencoded',
    ],
    CURLOPT_TIMEOUT        => 15,
    CURLOPT_SSL_VERIFYPEER => false,
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($response === false) {
    jsonResponse(false, 'Gagal menghubungi RajaOngkir. Coba lagi.', null, 503);
}

// If Komerce API returns 404 (e.g. Route/courier not supported), return empty services list rather than failing
if ($httpCode === 404) {
    jsonResponse(true, 'Ongkir tidak tersedia untuk kurir ini.', ['data' => []]);
}

$data = json_decode($response, true);

if ($httpCode !== 200 || !isset($data['data'])) {
    $errMsg = $data['meta']['message'] ?? 'Gagal menghitung ongkos kirim.';
    jsonResponse(false, $errMsg, null, 422);
}

$services = [];
if (is_array($data['data'])) {
    foreach ($data['data'] as $s) {
        $services[] = [
            'kurir'    => strtoupper($s['code'] ?? $courier),
            'service'  => $s['service'] ?? '',
            'deskripsi'=> $s['description'] ?? '',
            'biaya'    => (int) ($s['cost'] ?? 0),
            'estimasi' => !empty($s['etd']) ? $s['etd'] : '-',
        ];
    }
}

jsonResponse(true, 'Ongkir berhasil dihitung.', ['data' => $services]);
