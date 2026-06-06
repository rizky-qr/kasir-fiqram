class PenjualanItem {
  final int idProduk;
  final String namaProduk;
  final int qty;
  final int harga;
  final int subtotal;

  PenjualanItem({
    required this.idProduk,
    required this.namaProduk,
    required this.qty,
    required this.harga,
    required this.subtotal,
  });

  factory PenjualanItem.fromJson(Map<String, dynamic> json) => PenjualanItem(
        idProduk:   int.tryParse(json['id_produk']?.toString() ?? '0') ?? 0,
        namaProduk: json['nama_produk']?.toString()                    ?? '',
        qty:        int.tryParse(json['qty']?.toString() ?? '0')       ?? 0,
        harga:      int.tryParse(json['harga']?.toString() ?? '0')     ?? 0,
        subtotal:   int.tryParse(json['subtotal']?.toString() ?? '0')  ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id_produk':   idProduk,
        'nama_produk': namaProduk,
        'qty':         qty,
        'harga':       harga,
        'subtotal':    subtotal,
      };
}

class PenjualanModel {
  final int idPenjualan;
  final String tanggal;
  final int total;
  final int bayar;
  final int kembali;
  final String idUser;
  final String namaUser;
  final String status;
  final String metodePembayaran;
  final int ongkir;
  final String kotaTujuan;
  final String alamat;
  final List<PenjualanItem> items;

  PenjualanModel({
    required this.idPenjualan,
    required this.tanggal,
    required this.total,
    required this.bayar,
    required this.kembali,
    required this.idUser,
    required this.namaUser,
    required this.status,
    this.metodePembayaran = 'COD',
    this.ongkir = 0,
    this.kotaTujuan = '',
    this.alamat = '',
    this.items = const [],
  });

  factory PenjualanModel.fromJson(Map<String, dynamic> json) {
    return PenjualanModel(
      idPenjualan:      int.tryParse(json['id_penjualan']?.toString() ?? '') ?? 0,
      tanggal:          json['tanggal']?.toString()             ?? '',
      total:            int.tryParse(json['total']?.toString() ?? '')  ?? 0,
      bayar:            int.tryParse(json['bayar']?.toString() ?? '')  ?? 0,
      kembali:          int.tryParse(json['kembali']?.toString() ?? '') ?? 0,
      idUser:           json['id_user']?.toString()             ?? '-',
      namaUser:         json['nama_user']?.toString()           ?? 'Kasir',
      status:           json['status']?.toString()              ?? 'Menunggu Verifikasi',
      metodePembayaran: json['metode_pembayaran']?.toString()   ?? 'COD',
      ongkir:           int.tryParse(json['ongkir']?.toString() ?? '0') ?? 0,
      kotaTujuan:       json['kota_tujuan']?.toString()         ?? '',
      alamat:           json['alamat']?.toString()              ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PenjualanItem.fromJson(e as Map<String, dynamic>))
              .toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penjualan':      idPenjualan,
      'tanggal':           tanggal,
      'total':             total,
      'bayar':             bayar,
      'kembali':           kembali,
      'id_user':           idUser,
      'status':            status,
      'metode_pembayaran': metodePembayaran,
      'ongkir':            ongkir,
      'kota_tujuan':       kotaTujuan,
      'alamat':            alamat,
      'items':             items.map((e) => e.toJson()).toList(),
    };
  }
}