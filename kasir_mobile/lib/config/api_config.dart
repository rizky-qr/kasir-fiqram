/// Ganti baseUrl sesuai perangkat:
/// - Emulator Android: http://10.0.2.2/aplikasi_post/api
/// - HP fisik (WiFi sama): http://IP_KOMPUTER/aplikasi_post/api
///   Contoh: http://192.168.1.100/aplikasi_post/api
/// - Jika menggunakan adb reverse: http://127.0.0.1:8080/aplikasi_post/api
///   Pastikan `adb reverse tcp:8080 tcp:80` aktif dan server host mendengarkan pada port 80.
/// - Jangan pakai 127.0.0.1 pada HP fisik kecuali Anda membuat reverse tunnel.
class ApiConfig {
  // Karena Anda fokus menggunakan localhost di Web, kita patenkan saja baseUrl-nya
  static String get baseUrl => 'http://localhost/fiqram/aplikasi_post/api';
}
