class ProdukModel {
  final int idProduk;
  final String namaProduk;
  final int idKategori;
  final String namaKategori;
  final int harga;
  final int stok;
  final String foto;
  final String fotoUrl;

  ProdukModel({
    required this.idProduk,
    required this.namaProduk,
    required this.idKategori,
    required this.namaKategori,
    required this.harga,
    required this.stok,
    required this.foto,
    required this.fotoUrl,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    int pInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return ProdukModel(
      idProduk: pInt(json['id_produk']),
      namaProduk: json['nama_produk']?.toString() ?? '',
      idKategori: pInt(json['id_kategori']),
      namaKategori: json['nama_kategori']?.toString() ?? '',
      harga: pInt(json['harga']),
      stok: pInt(json['stok']),
      foto: json['foto']?.toString() ?? '',
      fotoUrl: json['foto_url']?.toString() ?? '',
    );
  }
}
