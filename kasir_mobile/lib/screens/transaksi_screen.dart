import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cart_item.dart';
import '../models/produk_model.dart';
import '../services/api_service.dart';

class TransaksiScreen extends StatefulWidget {
  final List<CartItem>? initialCart;
  final bool isCustomerView;

  const TransaksiScreen({
    super.key,
    this.initialCart,
    this.isCustomerView = false,
  });

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final _api = ApiService();
  final _bayarCtrl = TextEditingController();
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  List<ProdukModel> _produk = [];
  final List<CartItem> _cart = [];
  ProdukModel? _selected;
  final _qtyCtrl = TextEditingController(text: '1');

  // State pilihan satuan (Admin view)
  String _selectedSatuan = 'KG';

  bool _loading = true;
  bool _saving = false;

  String _metodeBayar = 'Tunai';
  final int _ongkir = 15000;

  int get _subTotal => _cart.fold(0, (sum, item) => sum + item.subtotal);
  int get _grandTotal => _cart.isEmpty ? 0 : _subTotal + _ongkir;

  @override
  void initState() {
    super.initState();
    if (widget.initialCart != null) {
      _cart.addAll(widget.initialCart!);
    }
    _loadProduk();
  }

  Future<void> _loadProduk() async {
    setState(() => _loading = true);
    try {
      final list = await _api.fetchProduk(availableOnly: true);
      if (!mounted) return;
      setState(() {
        _produk = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  void _tambahKeKeranjang() {
    FocusScope.of(context).unfocus();

    if (_selected == null) {
      _showSnack('Pilih produk terlebih dahulu', isWarning: true);
      return;
    }

    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) {
      _showSnack('Jumlah harus lebih dari 0', isWarning: true);
      return;
    }

    // Jika pilih TON, stok yang dibutuhkan adalah 1000x lipat
    int stokDibutuhkan = _selectedSatuan == 'TON' ? (qty * 1000) : qty;

    if (stokDibutuhkan > _selected!.stok) {
      _showSnack('Sisa stok tidak mencukupi (Tersedia: ${_selected!.stok} KG)',
          isError: true);
      return;
    }

    final existing = _cart.indexWhere((c) =>
        c.idProduk == _selected!.idProduk && c.satuan == _selectedSatuan);
    if (existing >= 0) {
      final newQty = _cart[existing].qty + qty;
      setState(() => _cart[existing].qty = newQty);
    } else {
      setState(() {
        _cart.add(CartItem(
          idProduk: _selected!.idProduk,
          namaProduk: _selected!.namaProduk,
          harga: _selected!.harga,
          qty: qty,
          satuan: _selectedSatuan,
        ));
      });
    }

    if (_metodeBayar == 'Transfer') {
      _bayarCtrl.text = _grandTotal.toString();
    }

    setState(() {
      _selected = null;
      _qtyCtrl.text = '1';
      _selectedSatuan = 'KG'; // Reset kembali ke default
    });
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();

    if (_cart.isEmpty) {
      _showSnack('Keranjang masih kosong', isWarning: true);
      return;
    }

    final bayar = int.tryParse(_bayarCtrl.text.replaceAll('.', '')) ?? 0;
    if (bayar < _grandTotal) {
      _showSnack('Nominal uang bayar kurang!', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await _api.simpanPenjualan(
        items: _cart.map((e) => e.toJson()).toList(),
        total: _grandTotal,
        bayar: bayar,
      );
      if (!mounted) return;

      final kembali = bayar - _grandTotal;
      _tampilkanDialogSukses(kembali);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _tampilkanDialogSukses(int kembali) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Pesanan Berhasil!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Text('Metode: $_metodeBayar',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  const Text('Kembalian', style: TextStyle(fontSize: 12)),
                  Text(_currency.format(kembali),
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: const Text('KEMBALI KE BERANDA'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String message,
      {bool isError = false, bool isWarning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : (isWarning ? Colors.orange : Colors.green),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawBayar = _bayarCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final bayarInput = int.tryParse(rawBayar) ?? 0;
    final kembalian = bayarInput - _grandTotal;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: Colors.teal.shade700))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAlamatPengiriman(),
                  const SizedBox(height: 8),
                  if (!widget.isCustomerView) ...[
                    _buildInputProduk(),
                    const SizedBox(height: 8),
                  ],
                  _buildDaftarPesanan(),
                  const SizedBox(height: 8),
                  _buildOpsiPengiriman(),
                  const SizedBox(height: 8),
                  _buildMetodePembayaran(kembalian),
                  const SizedBox(height: 8),
                  _buildRincianPembayaran(),
                ],
              ),
            ),
      bottomNavigationBar: _loading ? null : _buildBottomBar(),
    );
  }

  Widget _buildAlamatPengiriman() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.teal),
              SizedBox(width: 8),
              Text('Alamat Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Alamat default pelanggan',
              style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildInputProduk() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tambah Produk (Admin)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<ProdukModel>(
            decoration: const InputDecoration(
                labelText: 'Pilih Produk', border: OutlineInputBorder()),
            initialValue: _selected,
            items: _produk
                .map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(
                        '${p.namaProduk} - ${_currency.format(p.harga)}/KG')))
                .toList(),
            onChanged: (val) => setState(() => _selected = val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Jumlah', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Satuan', border: OutlineInputBorder()),
                  initialValue: _selectedSatuan,
                  items: ['KG', 'TON']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSatuan = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: _tambahKeKeranjang,
              child: const Text('TAMBAH KE KERANJANG'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDaftarPesanan() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daftar Pesanan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (_cart.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada pesanan')))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, i) {
                final item = _cart[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.namaProduk,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${item.qty} ${item.satuan} x ${_currency.format(item.harga)}/KG\n${item.satuan == 'TON' ? '(Diskon 10% Diterapkan)' : ''}',
                      style: TextStyle(
                          color: item.satuan == 'TON'
                              ? Colors.green
                              : Colors.grey)),
                  trailing: Text(_currency.format(item.subtotal),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange)),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOpsiPengiriman() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ongkos Kirim',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(_currency.format(_ongkir),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetodePembayaran(int kembalian) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            initialValue: _metodeBayar,
            items: ['Tunai', 'Transfer']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _metodeBayar = val!;
                if (_metodeBayar == 'Transfer') {
                  _bayarCtrl.text = _grandTotal.toString();
                } else {
                  _bayarCtrl.clear();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bayarCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Nominal Uang (Rp)', border: OutlineInputBorder()),
            onChanged: (val) => setState(() {}),
          ),
          if (_metodeBayar == 'Tunai' && kembalian >= 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Kembalian: ${_currency.format(kembalian)}',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }

  Widget _buildRincianPembayaran() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal Produk'),
            Text(_currency.format(_subTotal))
          ]),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Ongkos Kirim'),
            Text(_currency.format(_ongkir))
          ]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total Belanja',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_currency.format(_grandTotal),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    fontSize: 18))
          ]),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pembayaran',
                      style: TextStyle(fontSize: 12)),
                  Text(_currency.format(_grandTotal),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontSize: 18)),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              onPressed: _saving ? null : _simpan,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('BUAT PESANAN',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
