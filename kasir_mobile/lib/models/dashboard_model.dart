import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- 1. MODEL DATA (Tetap menggunakan kode asli Anda) ---
class DashboardModel {
  final int totalProduk;
  final int totalPenjualan;
  final int totalPendapatan;
  final int stokMenipis;

  DashboardModel({
    required this.totalProduk,
    required this.totalPenjualan,
    required this.totalPendapatan,
    required this.stokMenipis,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    int pInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final normalized = v.replaceAll(RegExp(r'[^0-9\-]'), '');
        return int.tryParse(normalized) ?? 0;
      }
      return 0;
    }

    return DashboardModel(
      totalProduk: pInt(json['total_produk']),
      totalPenjualan: pInt(json['total_penjualan']),
      totalPendapatan: pInt(json['total_pendapatan']),
      stokMenipis: pInt(json['stok_menipis']),
    );
  }
}

// --- 2. TAMPILAN UI (Sudah Diperbarui ke Material Design Modern) ---
class DashboardScreen extends StatelessWidget {
  final DashboardModel dashboardData;

  const DashboardScreen({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang yang lebih lembut
      appBar: AppBar(
        title: const Text(
          'Ringkasan Data',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.indigo, // Warna solid yang lebih tegas
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0, left: 4.0),
                child: Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    1.1, // Menyesuaikan proporsi kotak agar tidak terlalu tinggi
                children: [
                  _buildCard(
                    title: 'Total Produk',
                    value: dashboardData.totalProduk.toString(),
                    icon: Icons.inventory_2_rounded,
                    color: Colors.blue,
                  ),
                  _buildCard(
                    title: 'Penjualan',
                    value: dashboardData.totalPenjualan.toString(),
                    icon: Icons.shopping_cart_rounded,
                    color: Colors.green,
                  ),
                  _buildCard(
                    title: 'Pendapatan',
                    value: currency.format(dashboardData.totalPendapatan),
                    icon: Icons.account_balance_wallet_rounded,
                    color: Colors.purple,
                  ),
                  _buildCard(
                    title: 'Stok Menipis',
                    value: dashboardData.stokMenipis.toString(),
                    icon: Icons.warning_rounded,
                    color: Colors
                        .orange, // Menggunakan orange agar lebih soft dibanding merah tajam
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET CARD KUSTOM YANG LEBIH MODERN ---
  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2), // Bayangan mengikuti warna ikon
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Efek sentuhan (ripple) khas Android
        },
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Rata kiri lebih modern
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color
                      .withValues(alpha: 0.15), // Latar belakang lingkaran transparan
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
