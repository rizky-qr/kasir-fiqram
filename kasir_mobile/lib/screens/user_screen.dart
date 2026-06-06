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
  final _email = TextEditingController();
  final _noHp = TextEditingController();
  final _searchController = TextEditingController();

  String _level = 'pelanggan';
  bool _isObscure = true;
  String _searchQuery = '';

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

  Future<void> _tambah(BuildContext sheetContext) async {
    if (_nama.text.trim().isEmpty ||
        _username.text.trim().isEmpty ||
        _password.text.trim().isEmpty) {
      _snack('Nama, Username, dan Kata Sandi wajib diisi!', isWarning: true);
      return;
    }

    // Tutup bottom sheet
    Navigator.pop(sheetContext);
    
    setState(() => _loading = true);
    try {
      await _api.tambahUser(
        namaUser: _nama.text.trim(),
        username: _username.text.trim(),
        password: _password.text.trim(),
        level: _level,
        email: _email.text.trim(),
        noHp: _noHp.text.trim(),
      );

      // Bersihkan form setelah sukses
      _nama.clear();
      _username.clear();
      _password.clear();
      _email.clear();
      _noHp.clear();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Hapus Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun "${u.namaUser}" (@${u.username})?\nTindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: ok
            ? Colors.green.shade600
            : (isWarning ? Colors.orange.shade700 : Colors.red.shade700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAddUserSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tambah Pengguna Baru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nama,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap *',
                          prefixIcon: Icon(Icons.badge_outlined, color: Colors.deepPurple.shade400),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _username,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Username Login *',
                          prefixIcon: Icon(Icons.alternate_email, color: Colors.deepPurple.shade400),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _password,
                              obscureText: _isObscure,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi *',
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.deepPurple.shade400),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => setSheetState(() => _isObscure = !_isObscure),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: _level,
                              decoration: InputDecoration(
                                labelText: 'Role *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                DropdownMenuItem(value: 'kasir', child: Text('Kasir')),
                                DropdownMenuItem(value: 'pelanggan', child: Text('Pelanggan')),
                              ],
                              onChanged: (v) => setSheetState(() => _level = v ?? 'pelanggan'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Email (Opsional)',
                          prefixIcon: Icon(Icons.mail_outline, color: Colors.deepPurple.shade400),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noHp,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Nomor Handphone (Opsional)',
                          prefixIcon: Icon(Icons.phone_android_outlined, color: Colors.deepPurple.shade400),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.deepPurple, Colors.indigo],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _tambah(sheetContext),
                            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                            label: const Text(
                              'Simpan Pengguna',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
    _email.dispose();
    _noHp.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Kelola Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.5),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _load,
          )
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildUserList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserSheet,
        elevation: 4,
        highlightElevation: 8,
        label: const Text(
          'Tambah Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.indigo],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'Cari nama, username, email, hp...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.deepPurple),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    final filteredList = _list.where((u) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      return u.namaUser.toLowerCase().contains(query) ||
          u.username.toLowerCase().contains(query) ||
          u.level.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.noHp.contains(query);
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.group_off_outlined : Icons.search_off_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'Belum ada pengguna' : 'Pengguna tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Coba gunakan kata kunci pencarian yang lain.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              )
            ]
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), // Extra padding bottom for FAB
      itemCount: filteredList.length,
      itemBuilder: (ctx, i) {
        final u = filteredList[i];

        IconData roleIcon;
        List<Color> roleGradient;

        switch (u.level.toLowerCase()) {
          case 'admin':
            roleIcon = Icons.admin_panel_settings_rounded;
            roleGradient = [Colors.red.shade400, Colors.pink.shade600];
            break;
          case 'kasir':
            roleIcon = Icons.point_of_sale_rounded;
            roleGradient = [Colors.teal.shade400, Colors.green.shade600];
            break;
          default:
            roleIcon = Icons.person_outline_rounded;
            roleGradient = [Colors.blue.shade400, Colors.indigo.shade600];
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {}, // Tap effect
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [roleGradient[0].withValues(alpha: 0.12), roleGradient[1].withValues(alpha: 0.12)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(roleIcon, color: roleGradient[1], size: 24),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    u.namaUser,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: roleGradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    u.level.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${u.username}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (u.email.isNotEmpty || u.noHp.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Divider(height: 1, thickness: 0.5),
                              const SizedBox(height: 8),
                            ],
                            if (u.email.isNotEmpty) ...[
                              Row(
                                children: [
                                  Icon(Icons.mail_outline_rounded, size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      u.email,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (u.noHp.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone_android_outlined, size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      u.noHp,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Actions
                      Align(
                        alignment: Alignment.topCenter,
                        child: IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                          tooltip: 'Hapus Akun',
                          onPressed: () => _hapus(u),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

