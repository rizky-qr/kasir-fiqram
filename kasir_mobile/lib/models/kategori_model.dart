class KategoriModel {
  final int idKategori;
  final String namaKategori;
  final String? keterangan;

  KategoriModel({
    required this.idKategori,
    required this.namaKategori,
    this.keterangan,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    int pInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return KategoriModel(
      idKategori: pInt(json['id_kategori']),
      namaKategori: json['nama_kategori']?.toString() ?? '',
      keterangan: json['keterangan']?.toString(),
    );
  }
}
