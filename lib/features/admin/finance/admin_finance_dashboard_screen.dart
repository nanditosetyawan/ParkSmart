import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cs_kyc/admin_notifications_screen.dart';
import 'admin_pricing_screen.dart';
import 'admin_wallet_screen.dart';
import 'admin_transactions_screen.dart';
import 'admin_bookings_screen.dart';
import 'revenue_screen.dart';
import '../../sitemap_screen.dart';

class AdminFinanceDashboardScreen extends StatelessWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: Navigator.canPop(context)
              ? GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
                  ),
                )
              : null,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                        ),
                        child: Text(
                          'Finance',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text('Dashboard Finansial & Billing', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                ],
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.developer_board, size: 20, color: Color(0xFF1A1A18)),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF1A1A18)),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Keuangan, Tarif & Pendapatan', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 14, color: Color(0xFF17A18A)),
                const SizedBox(width: 6),
                Text('Arus Kas Masuk, Settlement & Laporan Pendapatan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
              ],
            ),
            const SizedBox(height: 14),

            // Restricted Division Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Akses Terbatas: Hanya berwenang mengelola Finansial, Tarif & Transaksi.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFB45309)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KPI Khusus Finansial
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
                  child: _buildKpiCard('Total Omzet Hari Ini', 'Rp 4.2 Jt', Icons.monetization_on_outlined, const Color(0xFF17A18A), '+12% vs Kemarin'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
                  child: _buildKpiCard('Transaksi Sukses', '842 Trx', Icons.receipt_long, const Color(0xFF114177), 'Settlement Sukses'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
                  child: _buildKpiCard('Reservasi Aktif', '156 Booking', Icons.calendar_today_outlined, const Color(0xFFD97706), 'Total Rp 1.560.000'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
                  child: _buildKpiCard('Total Deposit Wallet', 'Rp 18.5 Jt', Icons.account_balance_wallet_outlined, const Color(0xFF45474A), 'Injeksi & Saldo User'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Aksi Khusus Finansial
            Text('Aksi Manajemen Finansial', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.price_change_outlined,
                  label: 'Konfigurasi\nTarif',
                  color: const Color(0xFF114177),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.account_balance_wallet,
                  label: 'Injeksi\nSaldo',
                  color: const Color(0xFF17A18A),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Audit\nTransaksi',
                  color: const Color(0xFFD97706),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.event_note,
                  label: 'Manajemen\nBooking',
                  color: const Color(0xFF45474A),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Hub Laporan Pendapatan Terpadu
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C1D1F), Color(0xFF2E333D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Laporan Pendapatan & Analytics', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('Analisis laba bersih, volume transaksi, dan proyeksi omzet', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFCBD5E1))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Transaksi Finansial Terkini
            Text('Aktivitas Finansial Terkini', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 12),
            _buildFinanceItem(
              title: 'Pembayaran Parkir QRIS Berhasil',
              subtitle: 'Central Park Mall · Sesi #TRX-9482 · Mobil',
              amount: '+Rp 15.000',
              isIncome: true,
              time: '1 mnt lalu',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
            ),
            const SizedBox(height: 10),
            _buildFinanceItem(
              title: 'Injeksi Saldo Dompet Admin',
              subtitle: 'Top-up oleh Super Admin ke User Budi P.',
              amount: '+Rp 250.000',
              isIncome: true,
              time: '18 mnt lalu',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
            ),
            const SizedBox(height: 10),
            _buildFinanceItem(
              title: 'Refund Pembatalan Reservasi',
              subtitle: 'Malioboro Mall · Booking #BK-3021 (Dibatalkan user)',
              amount: '-Rp 20.000',
              isIncome: false,
              time: '45 mnt lalu',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
            ),
            const SizedBox(height: 80),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen()));
          },
          label: const Text('Dev Sitemap'),
          icon: const Icon(Icons.developer_board),
          backgroundColor: const Color(0xFFD97706),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String sub) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 4),
          Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4DFD5)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18), height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceItem({required String title, required String subtitle, required String amount, required bool isIncome, required String time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4DFD5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isIncome ? const Color(0xFFD1F2EB) : const Color(0xFFFDE8E4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isIncome ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
                  ),
                ),
                Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
