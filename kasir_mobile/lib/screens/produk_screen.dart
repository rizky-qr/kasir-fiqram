import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/produk_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'form_produk_screen.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final _api = ApiService();
  final _search = TextEditingController();
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<ProdukModel> _produk = [];
  UserModel? _user;
  bool _loading = true;

  bool get _isAdmin => _user?.level == 'admin' || _user?.level == 'kasir';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _user = await _api.getSavedUser();
    debugPrint(
        'ProdukScreen loaded user: ${_user?.username} level=${_user?.level}');
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _api.fetchProduk(search: _search.text.trim());
      if (!mounted) return;
      setState(() {
        _produk = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _openForm([ProdukModel? produk]) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FormProdukScreen(produk: produk)),
    );
    if (ok == true) _load();
  }

  Future<void> _hapus(ProdukModel p) async {
    final y = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus "${p.namaProduk}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );
    if (y != true) return;
    
    try {
      await _api.hapusProduk(p.idProduk);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Data Produk', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                debugPrint('FAB tambah produk pressed; isAdmin=$_isAdmin');
                _openForm();
              },
              backgroundColor: Colors.blueAccent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          // --- 1. AREA PENCARIAN (SEARCH BAR) ---
          Container(
            color: Colors.blueAccent,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari nama produk...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    onPressed: () {
                      _search.clear();
                      FocusScope.of(context).unfocus();
                      _load();
                    },
                    tooltip: 'Segarkan',
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) => _load(),
              ),
            ),
          ),

          // --- 2. AREA DAFTAR PRODUK ---
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _produk.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 12, bottom: 80, left: 16, right: 16),
                        itemCount: _produk.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final p = _produk[i];
                          return _buildProductCard(p);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Widget Kustom untuk Kartu Produk
  Widget _buildProductCard(ProdukModel p) {
    // Menentukan warna peringatan stok
    Color stockColor = Colors.grey.shade600;
    if (p.stok == 0) {
      stockColor = Colors.red;
    } else if (p.stok <= 5) {
      stockColor = Colors.orange.shade700;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isAdmin ? () => _openForm(p) : null,
          onLongPress: _isAdmin ? () => _hapus(p) : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Gambar Produk (Rounded Rectangle)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade100,
                    child: Image.network(
                      p.fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.namaProduk,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.namaKategori,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 14, color: stockColor),
                          const SizedBox(width: 4),
                          Text(
                            p.stok == 0 ? 'Stok Habis' : 'Stok: ${p.stok}',
                            style: TextStyle(
                              fontSize: 12,
                              color: stockColor,
                              fontWeight: p.stok <= 5 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Harga & Indikator Edit (Jika Admin)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currency.format(p.harga),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                      ),
                    ),
                    if (_isAdmin) ...[
                      const SizedBox(height: 8),
                      Icon(Icons.edit_note, color: Colors.grey.shade400, size: 20),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Kustom ketika data produk kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _search.text.isEmpty ? 'Belum ada data produk' : 'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_search.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                _search.clear();
                _load();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Hapus Pencarian'),
            )
          ]
        ],
      ),
    );
  }
}