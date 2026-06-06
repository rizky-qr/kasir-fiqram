import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../models/cart_item.dart';
import '../models/kota_model.dart';
import '../models/ongkir_model.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Metode Pembayaran
// ─────────────────────────────────────────────────────────────────────────────
class PaymentMethod {
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

const _paymentMethods = [
  PaymentMethod(
    id: 'COD',
    name: 'Bayar di Tempat',
    subtitle: 'Bayar saat barang tiba',
    icon: Icons.local_shipping_rounded,
    color: Color(0xFF059669),
    bgColor: Color(0xFFECFDF5),
  ),
  PaymentMethod(
    id: 'Transfer Bank',
    name: 'Transfer Bank',
    subtitle: 'BCA · BNI · Mandiri · BRI',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF1D4ED8),
    bgColor: Color(0xFFEFF6FF),
  ),
  PaymentMethod(
    id: 'GoPay',
    name: 'GoPay',
    subtitle: 'Dompet digital Gojek',
    icon: Icons.account_balance_wallet_rounded,
    color: Color(0xFF00AA5B),
    bgColor: Color(0xFFE6F7EF),
  ),
  PaymentMethod(
    id: 'OVO',
    name: 'OVO',
    subtitle: 'Dompet digital OVO',
    icon: Icons.wallet_rounded,
    color: Color(0xFF4C2A86),
    bgColor: Color(0xFFF3EFF9),
  ),
  PaymentMethod(
    id: 'QRIS',
    name: 'QRIS',
    subtitle: 'Scan kode QR universal',
    icon: Icons.qr_code_rounded,
    color: Color(0xFFD97706),
    bgColor: Color(0xFFFFFBEB),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Checkout Screen
// ─────────────────────────────────────────────────────────────────────────────
class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cart;
  final String namaUser;
  final String alamat;
  final String noHp;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.namaUser,
    required this.alamat,
    required this.noHp,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  final _api = ApiService();
  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // ── State ──────────────────────────────────────────────────────────────────
  int _step = 0; // 0=ringkasan, 1=kota, 2=ongkir, 3=bayar, 4=konfirmasi

  // Kota
  final _kotaCtrl = TextEditingController();
  List<KotaModel> _kotaList = [];
  KotaModel? _selectedKota;
  bool _loadingKota = false;
  Timer? _debounce;

  // Ongkir
  String _selectedKurir = 'jne';
  List<OngkirResult> _ongkirList = [];
  OngkirResult? _selectedOngkir;
  bool _loadingOngkir = false;

  // Berat default: 500g per item
  int get _beratTotal => widget.cart.fold(0, (s, e) => s + e.beratTotal);
  int get _subtotal   => widget.cart.fold(0, (s, e) => s + e.subtotal);
  int get _ongkirBiaya => _selectedOngkir?.biaya ?? 0;
  int get _totalBayar  => _subtotal + _ongkirBiaya;

  // Pembayaran
  String _selectedPayment = 'COD';

  // Checkout
  bool _loadingCheckout = false;

  late AnimationController _stepCtrl;
  late Animation<double> _stepFade;

  late TextEditingController _alamatCtrl;

  @override
  void initState() {
    super.initState();
    _alamatCtrl = TextEditingController(text: widget.alamat);
    _stepCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _stepFade = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut);
    _stepCtrl.forward();
  }

  @override
  void dispose() {
    _alamatCtrl.dispose();
    _kotaCtrl.dispose();
    _debounce?.cancel();
    _stepCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _step++;
      _stepCtrl.forward(from: 0);
    });
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() {
        _step--;
        _stepCtrl.forward(from: 0);
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _searchKota(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (q.isEmpty) {
        setState(() => _kotaList = []);
        return;
      }
      setState(() => _loadingKota = true);
      try {
        final result = await _api.fetchKota(search: q);
        if (!mounted) return;
        setState(() {
          _kotaList    = result;
          _loadingKota = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _loadingKota = false);
      }
    });
  }

  Future<void> _hitungOngkir() async {
    if (_selectedKota == null) return;
    setState(() {
      _loadingOngkir = true;
      _ongkirList    = [];
      _selectedOngkir = null;
    });
    try {
      final result = await _api.fetchOngkir(
        destination: _selectedKota!.cityId,
        weightGram:  _beratTotal,
        courier:     _selectedKurir,
      );
      if (!mounted) return;
      setState(() {
        _ongkirList    = result;
        _loadingOngkir = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingOngkir = false);
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _prosesCheckout() async {
    setState(() => _loadingCheckout = true);
    try {
      final fullAlamat = '${_alamatCtrl.text.trim()}, ${_selectedKota?.displayName ?? ""}';
      await _api.simpanPenjualan(
        items:              widget.cart.map((e) => e.toJson()).toList(),
        total:              _totalBayar,
        bayar:              _totalBayar,
        metodePembayaran:   _selectedPayment,
        ongkir:             _ongkirBiaya,
        kotaTujuan:         fullAlamat,
      );
      if (!mounted) return;
      Navigator.pop(context, 'success');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingCheckout = false);
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _stepFade,
        child: _buildStep(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    const steps = ['Alamat & Tujuan', 'Ongkir', 'Pembayaran', 'Konfirmasi'];
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        onPressed: _prevStep,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            steps[_step.clamp(0, 3)],
            style: GoogleFonts.poppins(
                color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text('Langkah ${(_step + 1)} dari ${steps.length}',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: (_step + 1) / steps.length,
          backgroundColor: Colors.grey.shade200,
          valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
          minHeight: 3,
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _buildRingkasan();
      case 1: return _buildPilihOngkir();
      case 2: return _buildPilihPembayaran();
      case 3: return _buildKonfirmasi();
      default: return const SizedBox();
    }
  }

  // ─── Step 0: Ringkasan Keranjang ───────────────────────────────────────────
  Widget _buildRingkasan() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alamat pengiriman lengkap + Kota/Kecamatan RajaOngkir
                _sectionCard(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Alamat Pengiriman Lengkap',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Penerima: ${widget.namaUser}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (widget.noHp.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'WhatsApp: ${widget.noHp}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Text(
                        'Alamat Jalan / Rumah:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _alamatCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Nama jalan, No. Rumah, RT/RW, Kelurahan, Dusun, dll.',
                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Kota / Kecamatan (RajaOngkir):',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      if (_selectedKota == null) ...[
                        TextField(
                          controller: _kotaCtrl,
                          onChanged: _searchKota,
                          decoration: InputDecoration(
                            hintText: 'Ketik & cari kota / kecamatan...',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF7C3AED)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_city_rounded, color: Color(0xFF2563EB), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_selectedKota!.type} ${_selectedKota!.cityName}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1E3A8A)),
                                    ),
                                    Text(
                                      _selectedKota!.province,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF3B82F6)),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedKota = null;
                                    _ongkirList = [];
                                    _selectedOngkir = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_loadingKota) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                            ),
                          ),
                        ),
                      ] else if (_kotaList.isNotEmpty && _selectedKota == null) ...[
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(4),
                            itemCount: _kotaList.length,
                            itemBuilder: (context, index) {
                              final kota = _kotaList[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '${kota.type} ${kota.cityName}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                subtitle: Text(kota.province, style: const TextStyle(fontSize: 11)),
                                onTap: () {
                                  setState(() {
                                    _selectedKota = kota;
                                    _kotaList = [];
                                    _kotaCtrl.clear();
                                    _ongkirList = [];
                                    _selectedOngkir = null;
                                  });
                                  _hitungOngkir();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Item keranjang
                _sectionCard(
                  icon: Icons.shopping_basket_rounded,
                  iconColor: Colors.deepOrange,
                  title: 'Item Pesanan (${widget.cart.length})',
                  child: Column(
                    children: widget.cart
                        .map((item) => _buildCartItemTile(item))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Info berat
                _sectionCard(
                  icon: Icons.scale_rounded,
                  iconColor: Colors.blue,
                  title: 'Estimasi Berat',
                  child: Text(
                    '${(_beratTotal / 1000).toStringAsFixed(2)} kg',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 14),

                // Subtotal
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal Produk',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(_currency.format(_subtotal),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton(
          'Pilih Pengiriman',
          onTap: () {
            if (_alamatCtrl.text.trim().isEmpty) {
              _snack('Mohon isi alamat lengkap pengiriman terlebih dahulu.', isError: true);
              return;
            }
            if (_selectedKota == null) {
              _snack('Mohon cari dan pilih kota/kecamatan tujuan pengiriman.', isError: true);
              return;
            }
            _nextStep();
          },
        ),
      ],
    );
  }

  Widget _buildCartItemTile(CartItem item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.grass_rounded,
                  color: Colors.deepOrange, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.namaProduk,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('${item.qty} ${item.satuan} × ${_currency.format(item.harga)}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Text(_currency.format(item.subtotal),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepOrange)),
          ],
        ),
      );

  // ─── Step 1: Pilih Kota ───────────────────────────────────────────────────
  // _buildPilihKota dipindahkan ke inline Ringkasan Langkah 1

  // ─── Step 2: Pilih Ongkir ─────────────────────────────────────────────────
  Widget _buildPilihOngkir() {
    return Column(
      children: [
        // Pilih kurir
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kota tujuan: ${_selectedKota?.displayName ?? '-'}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              const Text('Pilih kurir:',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['jne', 'j&t', 'pos', 'tiki'].map((k) {
                    final isSelected = _selectedKurir == k;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedKurir = k);
                        _hitungOngkir();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF7C3AED),
                                    Color(0xFF2563EB)
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          k.toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _loadingOngkir
              ? _buildShimmerList()
              : _ongkirList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined,
                              size: 64, color: Colors.grey.shade200),
                          const SizedBox(height: 12),
                          Text(
                            'Sedang menghitung ongkir...\nPilih kurir di atas untuk mulai.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _hitungOngkir,
                            child: const Text('Hitung Ulang'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _ongkirList.length,
                      itemBuilder: (_, i) {
                        final o = _ongkirList[i];
                        final selected = _selectedOngkir == o;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedOngkir = o);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF7C3AED)
                                    : Colors.grey.shade200,
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF7C3AED)
                                            .withValues(alpha: 0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFF7C3AED)
                                            .withValues(alpha: 0.1)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.local_shipping_rounded,
                                      color: selected
                                          ? const Color(0xFF7C3AED)
                                          : Colors.grey,
                                      size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${o.kurir} ${o.service}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        '${o.deskripsi} · Estimasi ${o.estimasi} hari',
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _currency.format(o.biaya),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selected
                                        ? const Color(0xFF7C3AED)
                                        : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),

        if (_selectedOngkir != null)
          _buildBottomButton(
            'Pilih Pembayaran',
            onTap: _nextStep,
            subtitle: 'Ongkir: ${_currency.format(_ongkirBiaya)}',
          ),
      ],
    );
  }

  // ─── Step 3: Pilih Pembayaran ─────────────────────────────────────────────
  Widget _buildPilihPembayaran() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pilih Metode Pembayaran',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'Pilih cara yang paling nyaman untuk kamu',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ..._paymentMethods.map((pm) => _buildPaymentCard(pm)),
              ],
            ),
          ),
        ),
        _buildBottomButton(
          'Lanjut ke Konfirmasi',
          onTap: _nextStep,
          subtitle: _paymentMethods
              .firstWhere((p) => p.id == _selectedPayment)
              .name,
        ),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentMethod pm) {
    final isSelected = _selectedPayment == pm.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = pm.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? pm.color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: pm.color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? pm.color.withValues(alpha: 0.12) : pm.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(pm.icon, color: pm.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pm.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSelected ? pm.color : Colors.black87)),
                  const SizedBox(height: 2),
                  Text(pm.subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? pm.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? pm.color : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 4: Konfirmasi ───────────────────────────────────────────────────
  Widget _buildKonfirmasi() {
    final pm = _paymentMethods.firstWhere((p) => p.id == _selectedPayment);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ringkasan
                _sectionCard(
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Ringkasan Pesanan',
                  child: Column(
                    children: [
                      _summaryRow('Subtotal produk', _currency.format(_subtotal)),
                      const SizedBox(height: 8),
                      _summaryRow(
                        'Ongkos kirim (${_selectedOngkir?.kurir ?? '-'} ${_selectedOngkir?.service ?? ''})',
                        _currency.format(_ongkirBiaya),
                      ),
                      const Divider(height: 20),
                      _summaryRow(
                        'Total Pembayaran',
                        _currency.format(_totalBayar),
                        isBold: true,
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Pengiriman
                _sectionCard(
                  icon: Icons.local_shipping_rounded,
                  iconColor: Colors.green,
                  title: 'Pengiriman',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_alamatCtrl.text.trim().isNotEmpty) ...[
                        Text(_alamatCtrl.text.trim(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                      ],
                      Text(_selectedKota?.displayName ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedOngkir?.kurir.toUpperCase()} ${_selectedOngkir?.service} · Estimasi ${_selectedOngkir?.estimasi} hari',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Pembayaran
                _sectionCard(
                  icon: pm.icon,
                  iconColor: pm.color,
                  title: 'Metode Pembayaran',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: pm.bgColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(pm.icon, color: pm.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pm.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(pm.subtitle,
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Colors.amber.shade700, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pesanan akan diverifikasi admin sebelum diproses.',
                          style: TextStyle(
                              color: Colors.amber.shade800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomButton(
          'Pesan Sekarang 🛒',
          onTap: _prosesCheckout,
          loading: _loadingCheckout,
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: isBold ? Colors.black87 : Colors.grey.shade600,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 16 : 13,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87)),
      ],
    );
  }

  // ─── Shared Widgets ────────────────────────────────────────────────────────
  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomButton(
    String label, {
    required VoidCallback onTap,
    String? subtitle,
    bool loading = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Bayar',
                      style: TextStyle(color: Colors.grey.shade500)),
                  Text(_currency.format(_totalBayar),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: loading ? null : onTap,
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(label,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
