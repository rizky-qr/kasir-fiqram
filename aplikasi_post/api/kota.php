<?php
require_once __DIR__ . '/helpers.php';

define('RAJAONGKIR_KEY', '023d02b03933cc6ebfc80bd43205ec31');
define('RAJAONGKIR_URL', 'https://rajaongkir.komerce.id/api/v1');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonResponse(false, 'Method tidak diizinkan. Gunakan GET.', null, 405);
}

requireAuth($koneksi);

$search = trim($_GET['search'] ?? '');

if (empty($search)) {
    jsonResponse(true, 'Data kota berhasil diambil.', ['data' => []]);
}

// ─── Call RajaOngkir Komerce API: Domestic Destination ────────────────────────
$url = RAJAONGKIR_URL . '/destination/domestic-destination?search=' . urlencode($search);

$ch = curl_init();
curl_setopt_array($ch, [
    CURLOPT_URL            => $url,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER     => ['key: ' . RAJAONGKIR_KEY],
    CURLOPT_TIMEOUT        => 10,
    CURLOPT_SSL_VERIFYPEER => false,
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($response === false) {
    jsonResponse(false, 'Gagal menghubungi RajaOngkir.', null, 503);
}

$data = json_decode($response, true);

if ($httpCode !== 200 || !isset($data['data'])) {
    $errMsg = $data['meta']['message'] ?? 'Gagal mengambil data kota dari RajaOngkir.';
    jsonResponse(false, $errMsg, null, 422);
}

$cities = $data['data'];
$list = [];

foreach ($cities as $c) {
    // Map Komerce subdistrict level ID to city_id
    // Set cityName as a combined subdistrict, district, and city name
    $combinedName = $c['subdistrict_name'] . ', ' . $c['district_name'] . ', ' . $c['city_name'];
    $list[] = [
        'city_id'   => (string) ($c['id'] ?? ''),
        'city_name' => $combinedName,
        'type'      => 'Kec.',
        'province'  => $c['province_name'] . ' (' . ($c['zip_code'] ?? '') . ')',
    ];
}

jsonResponse(true, 'Data kota berhasil diambil.', ['data' => $list]);
