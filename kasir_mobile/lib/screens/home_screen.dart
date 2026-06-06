import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cart_item.dart';
import '../models/dashboard_model.dart';
import '../models/penjualan_model.dart';
import '../models/produk_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';
import 'kategori_screen.dart';
import 'kelola_penjualan_screen.dart';
import 'laporan_screen.dart';
import 'login_screen.dart';
import 'produk_screen.dart';
import 'stok_screen.dart';
import 'transaksi_screen.dart';
import 'user_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _api = ApiService();
  UserModel? _user;
  DashboardModel? _stats;

  List<ProdukModel> _katalogProduk = [];
  List<PenjualanModel> _riwayatPesanan = [];
  final List<CartItem> _customerCart = [];

  bool _loading = true;
  int _selectedIndex = 0; // untuk pelanggan

  // Profil pelanggan (disimpan lokal)
  String _namaPelanggan = '';
  String _noHp = '';
  String _alamat = '';
  final _namaPelangganCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();

  // Tab controller untuk ADMIN
  late TabController _adminTabCtrl;

  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  bool get _isAdmin => _user?.level.toLowerCase() == 'admin';

  // Pesanan yang masih pending (untuk admin tab)
  List<PenjualanModel> get _pendingOrders => _riwayatPesanan
      .where((o) =>
          o.status.trim().toLowerCase().contains('menunggu') ||
          o.status.trim().toLowerCase() == 'pending')
      .toList();

  @override
  void initState() {
    super.initState();
    _adminTabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _adminTabCtrl.dispose();
    _namaPelangganCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await _api.getSavedUser();
      DashboardModel? stats;
      List<ProdukModel> produkList = [];
      List<PenjualanModel> historyList = [];

      if (user?.level.toLowerCase() == 'admin') {
        stats = await _api.fetchDashboard();
        try {
          historyList = await _api.fetchAllPenjualan();
        } catch (_) {}
      } else {
        produkList = await _api.fetchProduk(availableOnly: true);
        try {
          historyList = await _api.fetchAllPenjualan();
        } catch (_) {}
        // Load profil lokal
        final profil = await _api.getProfilPelanggan();
        if (profil != null) {
          _namaPelanggan = profil['nama'] ?? '';
          _noHp = profil['no_hp'] ?? '';
          _alamat = profil['alamat'] ?? '';
        }

        // Jika data profil kosong, coba gunakan data dari user login (database)
        if (_namaPelanggan.isEmpty && user != null) {
          _namaPelanggan = user.namaUser;
        }
        if (_noHp.isEmpty && user != null) {
          _noHp = user.noHp;
        }


        _namaPelangganCtrl.text = _namaPelanggan;
        _noHpCtrl.text = _noHp;
      }

      if (!mounted) return;
      setState(() {
        _user = user;
        _stats = stats;
        _katalogProduk = produkList;
        _riwayatPesanan = historyList;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _verifikasiPesanan(int idPenjualan) async {
    setState(() => _loading = true);
    try {
      await _api.verifikasiPenjualan(idPenjualan);
      if (!mounted) return;
      _showSnack('Pesanan #SPN-$idPenjualan berhasil diverifikasi! ✅',
          ok: true);
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  void _tambahKeKeranjang(ProdukModel p) {
    if (p.stok <= 0) {
      _showSnack('Maaf, stok ${p.namaProduk} sedang habis', isWarning: true);
      return;
    }
    final existing =
        _customerCart.indexWhere((c) => c.idProduk == p.idProduk);
    if (existing >= 0) {
      if (_customerCart[existing].qty < p.stok) {
        setState(() => _customerCart[existing].qty += 1);
        _showSnack('${p.namaProduk} +1 ✓', ok: true);
      } else {
        _showSnack('Stok maksimal tercapai!', isWarning: true);
      }
    } else {
      setState(() {
        _customerCart.add(CartItem(
          idProduk: p.idProduk,
          namaProduk: p.namaProduk,
          harga: p.harga,
          qty: 1,
          satuan: 'KG',
          berat: p.berat,
        ));
      });
      _showSnack('${p.namaProduk} ditambahkan ke keranjang ✓', ok: true);
    }
  }

  // ─── CHECKOUT: ke CheckoutScreen (ongkir + payment UI) ────────────────
  Future<void> _prosesCheckout(int totalTagihan) async {
    if (_noHp.isEmpty) {
      _showSnack(
          'Mohon lengkapi nomor HP di menu Profil terlebih dahulu.',
          isWarning: true);
      setState(() => _selectedIndex = 3);
      return;
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cart:      List.from(_customerCart),
          namaUser:  _user?.namaUser ?? _namaPelanggan,
          alamat:    _alamat,
          noHp:      _noHp,
        ),
      ),
    );
    if (result == 'success' && mounted) {
      setState(() {
        _customerCart.clear();
        _selectedIndex = 1;
      });
      _showSnack('Pesanan berhasil dibuat! Menunggu verifikasi admin.', ok: true);
      await _load();
    }
  }

  void _showSnack(String message,
      {bool ok = false, bool isError = false, bool isWarning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
                ok
                    ? Icons.check_circle
                    : (isError ? Icons.error_outline : Icons.info_outline),
                color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ok
            ? Colors.green
            : (isError ? Colors.red.shade700 : Colors.orange.shade800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            _isAdmin ? Colors.indigo : Colors.deepOrange.shade600,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isAdmin ? 'Dashboard Admin' : _customerPageTitle,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              '${_user?.username ?? ''} · ${_user?.level ?? ''}'.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (!_isAdmin && _selectedIndex == 0)
            _buildCartButton(),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
        bottom: _isAdmin
            ? TabBar(
                controller: _adminTabCtrl,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                tabs: [
                  const Tab(
                      icon: Icon(Icons.dashboard_rounded, size: 20),
                      text: 'Beranda'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pending_actions_rounded, size: 18),
                        const SizedBox(width: 4),
                        const Text('Pesanan',
                            style: TextStyle(fontSize: 12)),
                        if (_pendingOrders.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text('${_pendingOrders.length}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const Tab(
                      icon: Icon(Icons.forum_rounded, size: 20),
                      text: 'Chat'),
                ],
              )
            : null,
      ),
      floatingActionButton: (!_isAdmin &&
              _customerCart.isNotEmpty &&
              _selectedIndex == 0)
          ? FloatingActionButton.extended(
              onPressed: _showCartBottomSheet,
              backgroundColor: Colors.deepOrange,
              icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
              label: Text(
                '${_customerCart.length} item · ${_currency.format(_customerCart.fold(0, (s, e) => s + e.subtotal))}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: !_isAdmin
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) {
                setState(() => _selectedIndex = i);
                if (i == 1) _load();
              },
              backgroundColor: Colors.white,
              indicatorColor: Colors.deepOrange.withValues(alpha: 0.15),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.storefront_outlined),
                    selectedIcon: Icon(Icons.storefront_rounded),
                    label: 'Beranda'),
                NavigationDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history_rounded),
                    label: 'Riwayat'),
                NavigationDestination(
                    icon: Icon(Icons.chat_outlined),
                    selectedIcon: Icon(Icons.chat_rounded),
                    label: 'Chat'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profil'),
              ],
            )
          : null,
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                  color: _isAdmin ? Colors.indigo : Colors.deepOrange))
          : _isAdmin
              ? _buildAdminBody()
              : _buildPelangganBody(),
    );
  }

  String get _customerPageTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Beranda Belanja';
      case 1:
        return 'Riwayat Pesanan';
      case 2:
        return 'Chat & Bantuan';
      case 3:
        return 'Profil Saya';
      default:
        return 'Beranda';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN BODY
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAdminBody() {
    return TabBarView(
      controller: _adminTabCtrl,
      children: [
        _buildAdminDashboard(),
        _buildAdminPesananTab(),
        _buildAdminChatTab(),
      ],
    );
  }

  Widget _buildAdminDashboard() {
    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.indigo,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_stats != null) _buildStatsGrid(),
            _buildSectionTitle('Menu Manajemen'),
            _buildAdminMainMenu(),
            _buildSectionTitle('Pengaturan Sistem'),
            _buildAdminSettingsMenu(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminPesananTab() {
    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.indigo,
      child: _pendingOrders.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 80, color: Colors.green.shade200),
                      const SizedBox(height: 16),
                      const Text('Semua pesanan sudah diverifikasi! 🎉',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Tidak ada pesanan yang menunggu verifikasi.',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const KelolaPenjualanScreen()),
                        ).then((_) => _load()),
                        icon: const Icon(Icons.list_alt_rounded),
                        label: const Text('Lihat Semua Pesanan'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingOrders.length,
              itemBuilder: (ctx, i) =>
                  _buildAdminOrderCard(_pendingOrders[i]),
            ),
    );
  }

  Widget _buildAdminOrderCard(PenjualanModel order) {
    final totalQty = order.items.fold<int>(0, (sum, item) => sum + item.qty);
    final isVerif = order.status.trim().toLowerCase() == 'terverifikasi' ||
        order.status.trim().toLowerCase() == 'selesai';
    final statusColor = isVerif ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('#SPN-${order.idPenjualan}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                              fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.namaUser,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    isVerif ? 'Terverifikasi' : 'Pending',
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Tanggal & Jumlah Barang
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      order.tanggal,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$totalQty Barang',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Detail Barang
            const Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black54),
                SizedBox(width: 6),
                Text(
                  'Detail Barang',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.items.isEmpty)
                    const Text(
                      'Tidak ada item barang',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.namaProduk} x${item.qty}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              _currency.format(item.subtotal),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // Alamat Pengiriman
            if (order.alamat.isNotEmpty || order.kotaTujuan.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Alamat Tujuan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Text(
                  [
                    if (order.alamat.isNotEmpty) order.alamat,
                    if (order.kotaTujuan.isNotEmpty) order.kotaTujuan,
                  ].join('\n'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ),
            ],

            // Detail Pembayaran
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.payment_outlined, size: 16, color: Colors.black54),
                SizedBox(width: 6),
                Text(
                  'Detail Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      Text(
                        order.metodePembayaran,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  if (order.ongkir > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ongkos Kirim',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          _currency.format(order.ongkir),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFCBD5E1)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        _currency.format(order.total),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      side: BorderSide(color: Colors.indigo.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                              order: order, userLevel: 'admin'),
                        ),
                      ).then((_) => _load());
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 16),
                    label: const Text('Chat',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () =>
                        _verifikasiPesanan(order.idPenjualan),
                    icon: const Icon(Icons.verified_rounded, size: 16),
                    label: const Text('Verifikasi',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminChatTab() {
    if (_riwayatPesanan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Belum ada pesanan.',
                style:
                    TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _riwayatPesanan.length,
      itemBuilder: (ctx, i) {
        final order = _riwayatPesanan[i];
        final isVerif = order.status.trim().toLowerCase() == 'terverifikasi' ||
            order.status.trim().toLowerCase() == 'selesai';
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor:
                  (isVerif ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.15),
              child: Icon(
                isVerif
                    ? Icons.verified_rounded
                    : Icons.pending_actions_rounded,
                color: isVerif ? Colors.green : Colors.orange,
              ),
            ),
            title: Text('#SPN-${order.idPenjualan} · ${order.namaUser}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              '${_currency.format(order.total)} · ${order.status.trim()}',
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            trailing: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChatScreen(order: order, userLevel: 'admin'),
                  ),
                ).then((_) => _load());
              },
              icon: const Icon(Icons.chat_rounded, size: 15),
              label: const Text('Chat',
                  style: TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PELANGGAN BODY
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPelangganBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildCustomerBeranda(),
        _buildRiwayatPesanan(),
        _buildChatTab(),
        _buildProfilPelanggan(),
      ],
    );
  }

  Widget _buildCustomerBeranda() {
    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.deepOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSectionTitle('Katalog Produk'),
            _buildCustomerCatalog(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatPesanan() {
    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.deepOrange,
      child: _riwayatPesanan.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Belum Ada Riwayat Pesanan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        'Pesanan Anda akan muncul di sini.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _riwayatPesanan.length,
              itemBuilder: (ctx, i) =>
                  _buildOrderCard(_riwayatPesanan[i]),
            ),
    );
  }

  Widget _buildOrderCard(PenjualanModel order) {
    final totalQty = order.items.fold<int>(0, (sum, item) => sum + item.qty);
    final isVerif = order.status.trim().toLowerCase() == 'terverifikasi' ||
        order.status.trim().toLowerCase() == 'selesai';
    final statusColor = isVerif ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#SPN-${order.idPenjualan}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    order.status.trim(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tanggal & Jumlah Barang
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      order.tanggal,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$totalQty Barang',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Detail Barang
            const Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.black54),
                SizedBox(width: 6),
                Text(
                  'Detail Barang',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.items.isEmpty)
                    const Text(
                      'Tidak ada item barang',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.namaProduk} x${item.qty}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              _currency.format(item.subtotal),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // Alamat Pengiriman
            if (order.alamat.isNotEmpty || order.kotaTujuan.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Alamat Tujuan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Text(
                  [
                    if (order.alamat.isNotEmpty) order.alamat,
                    if (order.kotaTujuan.isNotEmpty) order.kotaTujuan,
                  ].join('\n'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ),
            ],

            // Detail Pembayaran
            const SizedBox(height: 14),
            const Row(
              children: [
                Icon(Icons.payment_outlined, size: 16, color: Colors.black54),
                SizedBox(width: 6),
                Text(
                  'Detail Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      Text(
                        order.metodePembayaran,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  if (order.ongkir > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ongkos Kirim',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          _currency.format(order.ongkir),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFCBD5E1)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        _currency.format(order.total),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.deepOrange.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepOrange,
                  side: BorderSide(color: Colors.deepOrange.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                          order: order,
                          userLevel:
                              _user?.level ?? 'pelanggan'),
                    ),
                  ).then((_) => _load());
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    size: 16),
                label: const Text('Hubungi Admin via Chat',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    // Tab chat pelanggan: list pesanan + chat umum
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat Bantuan Umum
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                        order: null,
                        userLevel: _user?.level ?? 'pelanggan'),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade600,
                      Colors.orange.shade400
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 36),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chat Bantuan Umum',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          SizedBox(height: 4),
                          Text(
                              'Tanya langsung ke admin kami.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ),

          if (_riwayatPesanan.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Chat Per Pesanan',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            ..._riwayatPesanan.map((order) {
              final isVerif =
                  order.status.trim().toLowerCase() == 'terverifikasi' ||
                      order.status.trim().toLowerCase() == 'selesai';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (isVerif ? Colors.green : Colors.orange)
                            .withValues(alpha: 0.15),
                    child: Icon(
                      isVerif
                          ? Icons.verified_rounded
                          : Icons.pending_actions_rounded,
                      color: isVerif ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Text('#SPN-${order.idPenjualan}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${_currency.format(order.total)} · ${order.status.trim()}',
                      style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat_rounded,
                        color: Colors.deepOrange),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                              order: order,
                              userLevel:
                                  _user?.level ?? 'pelanggan'),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildProfilPelanggan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar / header profil
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.deepOrange.shade50,
                  child: Icon(Icons.person_rounded,
                      size: 48, color: Colors.deepOrange.shade400),
                ),
                const SizedBox(height: 12),
                Text(
                  _user?.namaUser ?? '-',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _user?.username ?? '',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Data Profil Pelanggan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text('Akan digunakan saat proses checkout.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          TextField(
            controller: _namaPelangganCtrl,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noHpCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Nomor WhatsApp / HP',
              prefixIcon: const Icon(Icons.phone_android_rounded),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_namaPelangganCtrl.text.trim().isEmpty ||
                    _noHpCtrl.text.trim().isEmpty) {
                  _showSnack('Nama dan Nomor HP harus diisi!', isWarning: true);
                  return;
                }
                try {
                  await _api.simpanProfilPelanggan(
                    nama: _namaPelangganCtrl.text.trim(),
                    noHp: _noHpCtrl.text.trim(),
                    alamat: '',
                  );
                  setState(() {
                    _namaPelanggan = _namaPelangganCtrl.text.trim();
                    _noHp = _noHpCtrl.text.trim();
                    _alamat = '';
                  });
                  if (!mounted) return;
                  _showSnack('Profil berhasil disimpan! ✓', ok: true);
                } catch (e) {
                  if (!mounted) return;
                  _showSnack(e.toString().replaceFirst('Exception: ', ''),
                      isError: true);
                }
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Simpan Profil',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCartButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () async {
            if (_customerCart.isEmpty) {
              _showSnack('Keranjang masih kosong!', isWarning: true);
              return;
            }
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TransaksiScreen(
                          initialCart: List.from(_customerCart),
                          isCustomerView: true,
                        )));
            if (!mounted) return;
            if (result == true) {
              setState(() => _customerCart.clear());
              _load();
            }
          },
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        if (_customerCart.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration:
                  const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text('${_customerCart.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (_, setModalState) {
            int grandTotal =
                _customerCart.fold(0, (sum, item) => sum + item.subtotal);
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(ctx).size.height * 0.85),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                    const Text('Keranjang Belanja',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    Expanded(
                      child: _customerCart.isEmpty
                          ? const Center(child: Text('Keranjang kosong'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _customerCart.length,
                              itemBuilder: (_, idx) {
                                final item = _customerCart[idx];
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 4),
                                  title: Text(item.namaProduk,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      '${_currency.format(item.harga)}/KG',
                                      style: TextStyle(
                                          color: Colors.deepOrange
                                              .shade600)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.grey),
                                        onPressed: () {
                                          if (item.qty > 1) {
                                            setModalState(
                                                () => item.qty--);
                                            setState(() {});
                                          } else {
                                            setModalState(() =>
                                                _customerCart
                                                    .removeAt(idx));
                                            setState(() {});
                                            if (_customerCart.isEmpty) {
                                              Navigator.pop(ctx);
                                            }
                                          }
                                        },
                                      ),
                                      Text('${item.qty}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      IconButton(
                                        icon: Icon(
                                            Icons.add_circle_outline,
                                            color: Colors
                                                .deepOrange.shade400),
                                        onPressed: () {
                                          setModalState(() => item.qty++);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 14, color: Colors.black54)),
                        Text(_currency.format(grandTotal),
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.deepOrange)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _customerCart.isEmpty
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                await _prosesCheckout(grandTotal);
                              },
                        child: const Text('CHECKOUT SEKARANG',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: _isAdmin ? Colors.indigo : Colors.deepOrange.shade600,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isAdmin ? 'Selamat bekerja,' : 'Selamat berbelanja,',
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(_user?.namaUser ?? '-',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          if (_isAdmin && _stats != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _headerChip(
                    '${_stats!.totalPenjualan} Transaksi',
                    Icons.receipt_rounded),
                const SizedBox(width: 10),
                _headerChip(
                    '${_stats!.stokMenipis} Stok Menipis',
                    Icons.warning_rounded),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  Widget _buildCustomerCatalog() {
    if (_katalogProduk.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Belum ada produk yang tersedia',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: _katalogProduk.length,
        itemBuilder: (context, index) {
          final p = _katalogProduk[index];
          final outOfStock = p.stok <= 0;
          return Card(
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: outOfStock ? null : () => _tambahKeKeranjang(p),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: Icon(Icons.inventory_2_outlined,
                              size: 56,
                              color: Colors.grey.shade300),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.namaProduk,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(_currency.format(p.harga),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange.shade600)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  outOfStock
                                      ? 'Habis'
                                      : 'Stok: ${p.stok}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: outOfStock
                                          ? Colors.red
                                          : Colors.grey.shade600,
                                      fontWeight: outOfStock
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                                if (!outOfStock)
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.deepOrange.shade600,
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        size: 14,
                                        color: Colors.white),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (outOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.6),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(20)),
                          child: const Text('HABIS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: [
          _statCard('Total Produk', '${_stats!.totalProduk}',
              Icons.inventory_2_rounded, Colors.blue),
          _statCard('Total Penjualan', '${_stats!.totalPenjualan}',
              Icons.shopping_cart_rounded, Colors.green),
          _statCard(
              'Pendapatan',
              _currency.format(_stats!.totalPendapatan),
              Icons.account_balance_wallet_rounded,
              Colors.purple),
          _statCard('Stok Menipis', '${_stats!.stokMenipis}',
              Icons.warning_rounded, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildAdminMainMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          _menuTile('Transaksi', Icons.point_of_sale_rounded, Colors.green,
              () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TransaksiScreen()));
            if (mounted) _load();
          }),
          _menuTile('Kelola Pesanan', Icons.verified_rounded,
              Colors.deepOrange, () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const KelolaPenjualanScreen()));
            if (mounted) _load();
          }),
          _menuTile('Produk', Icons.inventory_rounded, Colors.blue, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProdukScreen()));
          }),
          _menuTile('Stok Masuk', Icons.warehouse_rounded, Colors.teal,
              () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StokScreen()));
            if (mounted) _load();
          }),
          _menuTile('Laporan', Icons.assessment_rounded, Colors.orange, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LaporanScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildAdminSettingsMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          _menuTile(
              'Kategori',
              Icons.category_rounded,
              Colors.indigo,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const KategoriScreen()))),
          _menuTile(
              'Kelola Akun',
              Icons.people_alt_rounded,
              Colors.deepPurple,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UserScreen()))),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                radius: 16,
                child: Icon(icon, color: color, size: 18)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 22)),
              const SizedBox(height: 6),
              Expanded(
                child: Center(
                  child: Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}