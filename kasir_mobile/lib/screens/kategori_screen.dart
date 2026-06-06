import 'package:flutter/material.dart';

import '../models/kategori_model.dart';
import '../services/api_service.dart';

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({super.key});

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final _api = ApiService();
  final _nama = TextEditingController();
  final _ket = TextEditingController();

  List<KategoriModel> _list = [];
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _api.fetchKategori();
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(e);
    }
  }

  Future<void> _tambah() async {
    if (_nama.text.trim().isEmpty) {
      _snack('Nama kategori wajib diisi');
      return;
    }
    try {
      await _api.tambahKategori(_nama.text.trim(), _ket.text.trim());
      _nama.clear();
      _ket.clear();
      await _load();
      if (!mounted) return;
      _snack('Kategori ditambahkan', ok: true);
    } catch (e) {
      _snack(e);
    }
  }

  Future<void> _hapus(KategoriModel k) async {
    final y = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Hapus "${k.namaKategori}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (y != true) return;
    try {
      await _api.hapusKategori(k.idKategori);
      await _load();
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
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nama.dispose();
    _ket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Produk')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _nama,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kategori',
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
                        onPressed: _tambah,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Kategori'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty
                    ? const Center(child: Text('Belum ada kategori'))
                    : ListView.builder(
                        itemCount: _list.length,
                        itemBuilder: (ctx, i) {
                          final k = _list[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              title: Text(k.namaKategori),
                              subtitle: Text(k.keterangan ?? '-'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _hapus(k),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
