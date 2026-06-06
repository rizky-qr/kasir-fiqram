import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/produk_model.dart';
import '../models/stok_model.dart';
import '../services/api_service.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  final _api = ApiService();
  final _qty = TextEditingController(text: '1');
  final _ket = TextEditingController();

  List<StokModel> _riwayat = [];
  List<ProdukModel> _produk = [];
  ProdukModel? _selected;
  DateTime _tanggal = DateTime.now();
  bool _loading = true;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final riwayat = await _api.fetchStok();
      final produk = await _api.fetchProduk();
      if (!mounted) return;
      setState(() {
        _riwayat = riwayat;
        _produk = produk;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(e);
    }
  }

  Future<void> _simpan() async {
    if (_selected == null) {
      _snack('Pilih produk');
      return;
    }
    final qty = int.tryParse(_qty.text) ?? 0;
    if (qty <= 0) {
      _snack('Qty stok masuk harus > 0');
      return;
    }
    try {
      await _api.tambahStok(
        idProduk: _selected!.idProduk,
        tanggal: _fmt(_tanggal),
        stokMasuk: qty,
        keterangan: _ket.text.trim(),
      );
      _qty.text = '1';
      _ket.clear();
      await _load();
      if (!mounted) return;
      _snack('Stok berhasil ditambahkan', ok: true);
    } catch (e) {
      _snack(e);
    }
  }

  void _snack(Object msg, {bool ok = false}) {
    final text =
        ok ? msg.toString() : msg.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _qty.dispose();
    _ket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Stok Masuk')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          DropdownButtonFormField<ProdukModel>(
                            initialValue: _selected,
                            decoration: const InputDecoration(
                              labelText: 'Produk',
                              border: OutlineInputBorder(),
                            ),
                            items: _produk
                                .map((p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(
                                          '${p.namaProduk} (stok: ${p.stok})'),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selected = v),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _tanggal,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (d != null) setState(() => _tanggal = d);
                            },
                            child: Text('Tanggal: ${dateFmt.format(_tanggal)}'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _qty,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Stok Masuk',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ket,
                            decoration: const InputDecoration(
                              labelText: 'Keterangan',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _simpan,
                              icon: const Icon(Icons.add),
                              label: const Text('Simpan Stok Masuk'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Riwayat Stok Masuk',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: _riwayat.isEmpty
                      ? const Center(child: Text('Belum ada riwayat'))
                      : ListView.builder(
                          itemCount: _riwayat.length,
                          itemBuilder: (ctx, i) {
                            final s = _riwayat[i];
                            return ListTile(
                              title: Text(s.namaProduk),
                              subtitle: Text(
                                  '${dateFmt.format(DateTime.parse(s.tanggal))} | ${s.keterangan ?? '-'}'),
                              trailing: Text('+${s.stokMasuk}',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
