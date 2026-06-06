import 'dart:async' show Future, TimeoutException;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/dashboard_model.dart';
import '../models/kategori_model.dart';
import '../models/penjualan_model.dart';
import '../models/produk_model.dart';
import '../models/stok_model.dart';
import '../models/user_list_model.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';

class ApiService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  // Mengambil Base URL secara otomatis dari ApiConfig
  String get _activeBaseUrl => ApiConfig.baseUrl;
  String get baseUrl => _activeBaseUrl;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(
        _userKey,
        jsonEncode({
          'id_user': user.idUser,
          'nama_user': user.namaUser,
          'username': user.username,
          'level': user.level,
        }));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, String>> _headers(
      {bool auth = true, bool json = true}) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (json) {
      headers['Content-Type'] = 'application/json';
    } else {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _decode(http.Response res) async {
    late Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
          'Respons server tidak valid. Pastikan server aktif dan kembalian berupa JSON.');
    }

    final success = body['success'];
    final hasError = res.statusCode >= 400 ||
        success == false ||
        success == 0 ||
        success == '0' ||
        success == 'false';

    if (hasError) {
      throw Exception(
          body['message']?.toString() ?? 'Terjadi kesalahan pada server');
    }
    return body;
  }

  Future<UserModel> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_activeBaseUrl/login.php'),
        headers: await _headers(auth: false, json: false),
        body: {'username': username, 'password': password},
      ).timeout(const Duration(seconds: 10));

      final body = await _decode(res);
      final userData = body['user'];
      final token = body['token'];

      if (userData == null || token == null) {
        throw Exception('Respons login tidak lengkap dari server.');
      }

      final user = UserModel.fromJson(userData as Map<String, dynamic>);
      await _saveSession(token.toString(), user);
      return user;
    } on TimeoutException catch (_) {
      throw Exception(
          'Koneksi timeout. Pastikan server Laragon menyala dan IP benar.');
    } on SocketException catch (_) {
      throw Exception(
          'Tidak dapat terhubung ke server. Periksa jaringan Anda.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_activeBaseUrl/logout.php'),
        headers: await _headers(),
      );
    } finally {
      await clearSession();
    }
  }

  Future<DashboardModel> fetchDashboard() async {
    final res = await http.get(
      Uri.parse('$_activeBaseUrl/dashboard.php'),
      headers: await _headers(),
    );
    final body = await _decode(res);
    return DashboardModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<ProdukModel>> fetchProduk(
      {String search = '', bool availableOnly = false}) async {
    final query = <String, String>{
      if (search.isNotEmpty) 'search': search,
      if (availableOnly) 'available': '1',
    };
    final uri =
        Uri.parse('$_activeBaseUrl/produk.php').replace(queryParameters: query);
    final res = await http.get(uri, headers: await _headers());
    final body = await _decode(res);
    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ProdukModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> tambahProduk({
    required String namaProduk,
    required int idKategori,
    required int harga,
    required int stok,
    String? fotoPath,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$_activeBaseUrl/produk.php'));
    final token = await getToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields['nama_produk'] = namaProduk;
    request.fields['id_kategori'] = idKategori.toString();
    request.fields['harga'] = harga.toString();
    request.fields['stok'] = stok.toString();
    if (fotoPath != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPath));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    await _decode(res);
  }

  Future<void> updateProduk({
    required int idProduk,
    required String namaProduk,
    required int idKategori,
    required int harga,
    required int stok,
  }) async {
    final res = await http.put(
      Uri.parse('$_activeBaseUrl/produk.php'),
      headers: await _headers(),
      body: jsonEncode({
        'id_produk': idProduk,
        'nama_produk': namaProduk,
        'id_kategori': idKategori,
        'harga': harga,
        'stok': stok,
      }),
    );
    await _decode(res);
  }

  Future<void> hapusProduk(int idProduk) async {
    final res = await http.delete(
      Uri.parse('$_activeBaseUrl/produk.php?id=$idProduk'),
      headers: await _headers(),
    );
    await _decode(res);
  }

  Future<List<KategoriModel>> fetchKategori() async {
    final res = await http.get(
      Uri.parse('$_activeBaseUrl/kategori.php'),
      headers: await _headers(),
    );
    final body = await _decode(res);
    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => KategoriModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> tambahKategori(String nama, String keterangan) async {
    final res = await http.post(
      Uri.parse('$_activeBaseUrl/kategori.php'),
      headers: await _headers(),
      body: jsonEncode({'nama_kategori': nama, 'keterangan': keterangan}),
    );
    await _decode(res);
  }

  Future<void> hapusKategori(int id) async {
    final res = await http.delete(
      Uri.parse('$_activeBaseUrl/kategori.php?id=$id'),
      headers: await _headers(),
    );
    await _decode(res);
  }

  Future<List<StokModel>> fetchStok() async {
    final res = await http.get(
      Uri.parse('$_activeBaseUrl/stok.php'),
      headers: await _headers(),
    );
    final body = await _decode(res);
    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => StokModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> tambahStok({
    required int idProduk,
    required String tanggal,
    required int stokMasuk,
    required String keterangan,
  }) async {
    final res = await http.post(
      Uri.parse('$_activeBaseUrl/stok.php'),
      headers: await _headers(),
      body: jsonEncode({
        'id_produk': idProduk,
        'tanggal': tanggal,
        'stok_masuk': stokMasuk,
        'keterangan': keterangan,
      }),
    );
    await _decode(res);
  }

  Future<List<UserListModel>> fetchUsers() async {
    final res = await http.get(
      Uri.parse('$_activeBaseUrl/user.php'),
      headers: await _headers(),
    );
    final body = await _decode(res);
    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => UserListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> tambahUser({
    required String namaUser,
    required String username,
    required String password,
    required String level,
  }) async {
    final res = await http.post(
      Uri.parse('$_activeBaseUrl/user.php'),
      headers: await _headers(),
      body: jsonEncode({
        'nama_user': namaUser,
        'username': username,
        'password': password,
        'level': level,
      }),
    );
    await _decode(res);
  }

  Future<void> hapusUser(int id) async {
    final res = await http.delete(
      Uri.parse('$_activeBaseUrl/user.php?id=$id'),
      headers: await _headers(),
    );
    await _decode(res);
  }

  Future<Map<String, dynamic>> simpanPenjualan({
    required List<Map<String, dynamic>> items,
    required int total,
    required int bayar,
  }) async {
    final res = await http.post(
      Uri.parse('$_activeBaseUrl/penjualan.php'),
      headers: await _headers(),
      body: jsonEncode({'items': items, 'total': total, 'bayar': bayar}),
    );
    return _decode(res);
  }

  Future<({List<PenjualanModel> data, int totalPendapatan})> fetchLaporan({
    required String awal,
    required String akhir,
  }) async {
    final uri = Uri.parse('$_activeBaseUrl/penjualan.php').replace(
      queryParameters: {'awal': awal, 'akhir': akhir},
    );
    final res = await http.get(uri, headers: await _headers());
    final body = await _decode(res);
    final list = (body['data'] as List<dynamic>?) ?? [];
    return (
      data: list
          .map((e) => PenjualanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPendapatan: int.tryParse(body['total_pendapatan'].toString()) ?? 0
    );
  }

  Future<List<PenjualanModel>> fetchAllPenjualan() async {
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final uri =
        Uri.parse('$_activeBaseUrl/penjualan.php?all=true&t=$timeStamp');

    final res = await http.get(uri, headers: await _headers());
    final body = await _decode(res);

    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => PenjualanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> verifikasiPenjualan(int idPenjualan) async {
    final uri = Uri.parse('$_activeBaseUrl/verifikasi_penjualan.php');
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'id_penjualan': idPenjualan,
      }),
    );
    await _decode(res);
  }

  // ─── Profil Pelanggan (disimpan lokal di SharedPreferences) ────────────────
  static const _profilKey = 'profil_pelanggan';

  Future<void> simpanProfilPelanggan({
    required String nama,
    required String noHp,
    required String alamat,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _profilKey,
        jsonEncode({
          'nama': nama,
          'no_hp': noHp,
          'alamat': alamat,
        }));
  }

  Future<Map<String, String>?> getProfilPelanggan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilKey);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return {
        'nama': m['nama']?.toString() ?? '',
        'no_hp': m['no_hp']?.toString() ?? '',
        'alamat': m['alamat']?.toString() ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  Future<List<ChatModel>> fetchChat(int idPenjualan) async {
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final uri = Uri.parse(
        '$_activeBaseUrl/chat.php?id_penjualan=$idPenjualan&t=$timeStamp');
    final res = await http.get(uri, headers: await _headers());
    final body = await _decode(res);

    final list = (body['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> kirimPesan(int idPenjualan, String pesan) async {
    final uri = Uri.parse('$_activeBaseUrl/chat.php');
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'id_penjualan': idPenjualan,
        'pesan': pesan,
      }),
    );
    await _decode(res);
  }
}
