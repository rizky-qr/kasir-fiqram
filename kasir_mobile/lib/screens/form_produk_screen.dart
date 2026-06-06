import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/kategori_model.dart';
import '../models/produk_model.dart';
import '../services/api_service.dart';

class FormProdukScreen extends StatefulWidget {
  final ProdukModel? produk;

  const FormProdukScreen({super.key, this.produk});

  @override
  State<FormProdukScreen> createState() => _FormProdukScreenState();
}

class _FormProdukScreenState extends State<FormProdukScreen> {
  final _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _harga = TextEditingController();
  final _stok = TextEditingController();

  List<KategoriModel> _kategori = [];
  int? _idKategori;
  String? _fotoPath;
  bool _loading = false;
  bool _loadingKat = true;

  bool get _isEdit => widget.produk != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.produk!;
      _nama.text = p.namaProduk;
      _harga.text = p.harga.toString();
      _stok.text = p.stok.toString();
      _idKategori = p.idKategori;
    }
    _loadKategori();
  }

  Future<void> _loadKategori() async {
    try {
      final list = await _api.fetchKategori();
      if (!mounted) return;
      setState(() {
        _kategori = list;
        _loadingKat = false;
        if (_idKategori == null && list.isNotEmpty) {
          _idKategori = list.first.idKategori;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingKat = false);
      _showError(e);
    }
  }

  Future<void> _pickFoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => _fotoPath = file.path);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate() || _idKategori == null) return;

    setState(() => _loading = true);
    try {
      final harga = int.parse(_harga.text);
      final stok = int.parse(_stok.text);

      if (_isEdit) {
        await _api.updateProduk(
          idProduk: widget.produk!.idProduk,
          namaProduk: _nama.text.trim(),
          idKategori: _idKategori!,
          harga: harga,
          stok: stok,
        );
      } else {
        await _api.tambahProduk(
          namaProduk: _nama.text.trim(),
          idKategori: _idKategori!,
          harga: harga,
          stok: stok,
          fotoPath: _fotoPath,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }

  @override
  void dispose() {
    _nama.dispose();
    _harga.dispose();
    _stok.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: _loadingKat
          ? const Center(child: CircularProgressIndicator())
          : _kategori.isEmpty
              ? const Center(child: Text('Buat kategori dulu di menu Kategori'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_isEdit) ...[
                          GestureDetector(
                            onTap: _pickFoto,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundImage: _fotoPath != null ? FileImage(File(_fotoPath!)) : null,
                              child: _fotoPath == null ? const Icon(Icons.camera_alt, size: 40) : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Ketuk untuk pilih foto (opsional)'),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _nama,
                          decoration: const InputDecoration(labelText: 'Nama Produk', border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _idKategori,
                          decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                          items: _kategori
                              .map((k) => DropdownMenuItem(value: k.idKategori, child: Text(k.namaKategori)))
                              .toList(),
                          onChanged: (v) => setState(() => _idKategori = v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _harga,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Harga', border: OutlineInputBorder()),
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Harga tidak valid' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _stok,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Stok', border: OutlineInputBorder()),
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) < 0 ? 'Stok tidak valid' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _loading ? null : _simpan,
                            child: _loading
                                ? const CircularProgressIndicator()
                                : Text(_isEdit ? 'PERBARUI' : 'SIMPAN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
