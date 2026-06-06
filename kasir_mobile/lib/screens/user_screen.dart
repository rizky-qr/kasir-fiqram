import 'package:flutter/material.dart';

import '../models/user_list_model.dart';
import '../services/api_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _api = ApiService();
  final _nama = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  String _level = 'pelanggan'; // Set default ke pelanggan agar lebih aman
  bool _isObscure = true; // Untuk fitur lihat password

  List<UserListModel> _list = [];
  bool _loading = true;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _api.fetchUsers();
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(e, isError: true);
    }
  }

  Future<void> _tambah() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard

    if (_nama.text.trim().isEmpty ||
        _username.text.trim().isEmpty ||
        _password.text.trim().isEmpty) {
      _snack('Semua kolom wajib diisi!', isWarning: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await _api.tambahUser(
        namaUser: _nama.text.trim(),
        username: _username.text.trim(),
        password: _password.text.trim(),
        level: _level,
      );

      // Bersihkan form setelah sukses
      _nama.clear();
      _username.clear();
      _password.clear();
      setState(() => _level = 'pelanggan');

      await _load();
      if (!mounted) return;
      _snack('Pengguna berhasil ditambahkan', ok: true);
    } catch (e) {
      setState(() => _loading = false);
      _snack(e, isError: true);
    }
  }

  Future<void> _hapus(UserListModel u) async {
    final y = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Pengguna'),
          ],
        ),
        content: Text(
            'Apakah Anda yakin ingin menghapus akun "${u.username}"? Akses login pengguna ini akan dicabut permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (y != true) return;

    setState(() => _loading = true);
    try {
      await _api.hapusUser(u.idUser);
      await _load();
      if (!mounted) return;
      _snack('Pengguna berhasil dihapus', ok: true);
    } catch (e) {
      setState(() => _loading = false);
      _snack(e, isError: true);
    }
  }

  void _snack(Object msg,
      {bool ok = false, bool isError = false, bool isWarning = false}) {
    final text =
        ok ? msg.toString() : msg.toString().replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok
                  ? Icons.check_circle
                  : (isWarning ? Icons.info_outline : Icons.error_outline),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
        backgroundColor: ok
            ? Colors.green
            : (isWarning ? Colors.orange.shade700 : Colors.red.shade700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nama.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kelola Pengguna',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor:
            Colors.deepPurple, // Warna khusus admin untuk menu user
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildInputForm(),
          const Divider(height: 1),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  // --- WIDGET FORM INPUT ---
  Widget _buildInputForm() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Akun Baru',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nama,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.badge_outlined,
                        color: Colors.deepPurple.shade300),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _username,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Username Login',
                    prefixIcon: Icon(Icons.alternate_email,
                        color: Colors.deepPurple.shade300),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _password,
                  obscureText: _isObscure,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Colors.deepPurple.shade300),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _level,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                    DropdownMenuItem(
                        value: 'pelanggan', child: Text('Pelanggan')),
                  ],
                  onChanged: (v) => setState(() => _level = v ?? 'pelanggan'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _loading ? null : _tambah,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Buat Akun',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET DAFTAR PENGGUNA ---
  Widget _buildUserList() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple));
    }

    if (_list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada pengguna',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _list.length,
      itemBuilder: (ctx, i) {
        final u = _list[i];

        // Menentukan Icon dan Warna berdasarkan Role
        IconData roleIcon;
        Color roleColor;

        switch (u.level.toLowerCase()) {
          case 'admin':
            roleIcon = Icons.admin_panel_settings;
            roleColor = Colors.red.shade400;
            break;
          case 'kasir':
            roleIcon = Icons.point_of_sale;
            roleColor = Colors.green.shade600;
            break;
          default: // pelanggan
            roleIcon = Icons.person_outline;
            roleColor = Colors.blue.shade600;
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: roleColor.withValues(alpha: 0.1),
              child: Icon(roleIcon, color: roleColor, size: 22),
            ),
            title: Text(
              u.namaUser,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text('@${u.username}',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      u.level.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: roleColor),
                    ),
                  ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Hapus Akun',
              onPressed: () => _hapus(u),
            ),
          ),
        );
      },
    );
  }
}
