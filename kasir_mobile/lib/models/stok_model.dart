class StokModel {
  final int idStok;
  final String tanggal;
  final int stokMasuk;
  final String? keterangan;
  final int idProduk;
  final String namaProduk;

  StokModel({
    required this.idStok,
    required this.tanggal,
    required this.stokMasuk,
    this.keterangan,
    required this.idProduk,
    required this.namaProduk,
  });

  factory StokModel.fromJson(Map<String, dynamic> json) {
    int pInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return StokModel(
      idStok: pInt(json['id_stok']),
      tanggal: json['tanggal']?.toString() ?? '',
      stokMasuk: pInt(json['stok_masuk']),
      keterangan: json['keterangan']?.toString(),
      idProduk: pInt(json['id_produk']),
      namaProduk: json['nama_produk']?.toString() ?? '',
    );
  }
}
