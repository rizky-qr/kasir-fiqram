class PenjualanModel {
  final int idPenjualan;
  final String tanggal;
  final int total;
  final int bayar;
  final int kembali;
  final String idUser; 
  final String namaUser; 
  final String status; 

  PenjualanModel({
    required this.idPenjualan,
    required this.tanggal,
    required this.total,
    required this.bayar,
    required this.kembali,
    required this.idUser,
    required this.namaUser,
    required this.status, 
  });

  factory PenjualanModel.fromJson(Map<String, dynamic> json) {
    return PenjualanModel(
      idPenjualan: int.tryParse(json['id_penjualan'].toString()) ?? 0,
      tanggal: json['tanggal']?.toString() ?? '',
      total: int.tryParse(json['total'].toString()) ?? 0,
      bayar: int.tryParse(json['bayar'].toString()) ?? 0,
      kembali: int.tryParse(json['kembali'].toString()) ?? 0,
      idUser: json['id_user']?.toString() ?? '-', 
      namaUser: json['nama_user']?.toString() ?? 'Kasir',
      status: json['status']?.toString() ?? 'Menunggu Verifikasi', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_penjualan': idPenjualan,
      'tanggal': tanggal,
      'total': total,
      'bayar': bayar,
      'kembali': kembali,
      'id_user': idUser,
      'status': status,
    };
  }
}