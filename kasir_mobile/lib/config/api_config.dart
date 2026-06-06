/// Ganti baseUrl sesuai perangkat:
/// - Emulator Android: http://10.0.2.2/aplikasi_post/api
/// - HP fisik (WiFi sama): http://IP_KOMPUTER/aplikasi_post/api
/// - Web localhost: http://localhost/fiqram/aplikasi_post/api
class ApiConfig {
  // Base URL backend PHP
  static String get baseUrl => 'http://localhost/fiqram/aplikasi_post/api';

  // ─── RajaOngkir ─────────────────────────────────────────────────────────────
  // Daftar di https://rajaongkir.com → Plan Starter (gratis)
  // Salin API Key ke sini:
  static const String rajaOngkirKey = '023d02b03933cc6ebfc80bd43205ec31';
  // Kota asal pengiriman 
  // Cari city_id kamu di: GET /kota?search=namaKota
  static const String originCityId = '90';

  // Komerce subdistrict IDs in Dompu (Kabupaten):
  // ID 90: Bada, Dompu, Dompu
  // ID 91: Bali, Dompu, Dompu
  // ID 92: Dora Tangga, Dompu, Dompu
  // ID 93: Dore Bara, Dompu, Dompu
  // ID 94: Kandai I, Dompu, Dompu
}
