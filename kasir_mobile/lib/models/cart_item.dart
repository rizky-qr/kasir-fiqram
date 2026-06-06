class CartItem {
  final int idProduk;
  final String namaProduk;
  final int harga;
  int qty;
  String satuan;
  final int berat; // berat per KG dalam gram

  CartItem({
    required this.idProduk,
    required this.namaProduk,
    required this.harga,
    required this.qty,
    this.satuan = 'KG',
    this.berat = 1000, // default 1 kg (1000 gram)
  });

  // Logika perhitungan harga otomatis
  int get subtotal {
    if (satuan == 'TON') {
      // 1 TON = 1000 KG. Diskon 10% = dikali 0.9
      return (harga * 1000 * qty * 0.9).toInt();
    }
    return harga * qty;
  }

  // Kalkulasi berat total dalam gram
  int get beratTotal {
    if (satuan == 'TON') {
      return qty * 1000 * berat;
    }
    return qty * berat;
  }

  Map<String, dynamic> toJson() {
    return {
      'idProduk': idProduk,
      'namaProduk': namaProduk,
      'harga': harga,
      'qty': qty,
      'satuan': satuan,
      'subtotal': subtotal,
      'berat': berat,
    };
  }
}
