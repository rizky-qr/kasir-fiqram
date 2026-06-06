class CartItem {
  final int idProduk;
  final String namaProduk;
  final int harga;
  int qty;
  String satuan; // Tambahkan variabel ini

  CartItem({
    required this.idProduk,
    required this.namaProduk,
    required this.harga,
    required this.qty,
    this.satuan = 'KG', // Default satuan adalah KG
  });

  // Logika perhitungan harga otomatis
  int get subtotal {
    if (satuan == 'TON') {
      // 1 TON = 1000 KG. Diskon 10% = dikali 0.9
      return (harga * 1000 * qty * 0.9).toInt();
    }
    return harga * qty;
  }

  Map<String, dynamic> toJson() {
    return {
      'idProduk': idProduk,
      'namaProduk': namaProduk,
      'harga': harga,
      'qty': qty,
      'satuan': satuan,
      'subtotal': subtotal,
    };
  }
}
