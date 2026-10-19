import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_finance_notifications_screen.dart';
import 'admin_wallet_screen.dart';
import 'admin_transactions_screen.dart';
import 'revenue_screen.dart';
import '../../sitemap_screen.dart';
import 'backend/admin_finance_dashboard_backend.dart';

class AdminFinanceDashboardScreen extends StatefulWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  State<AdminFinanceDashboardScreen> createState() => _AdminFinanceDashboardScreenState();
}

class _AdminFinanceDashboardScreenState extends State<AdminFinanceDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AdminFinanceDashboardBackend.instance.fetchFinanceDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminFinanceDashboardBackend.instance,
      builder: (context, _) => Theme(
        data: AppTheme.light,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF9F9F9),
          drawer: _buildFinanceDrawer(context),
          appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 54,
          // Tombol Ikon Wallet sebagai trigger drawer (menggantikan burger button)
          leading: Center(
            child: InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 20, color: Color(0xFFD97706)),
              ),
            ),
          ),
          titleSpacing: 4,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 0.7),
                    ),
                    child: Text(
                      'FINANSIAL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Dashboard Keuangan & Billing',
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminFinanceNotificationsScreen()),
              ),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF1A1A18)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: _buildTabCashflowAndSummary(context),
        ),
      ),
    );
  }

  // ==================== DRAWER SIDEBAR ====================
  Widget _buildFinanceDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profil Admin Finansial
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFD97706),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('B', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bambang Sutrisno', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Admin Finansial & Billing', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Divisi Finansial', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu Navigasi Lengkap
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                    child: Text(
                      'MANAJEMEN KEUANGAN & BILLING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF76777B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard Finansial',
                    onTap: () => Navigator.pop(context),
                    isActive: true,
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics_outlined,
                    label: 'Laporan Pendapatan & Omzet',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Riwayat & Mutasi Transaksi',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Injeksi Saldo & Wallet Admin',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_active_outlined,
                    label: 'Notifikasi Injeksi Saldo',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinanceNotificationsScreen()));
                    },
                  ),
                  const Divider(color: Color(0xFFF3F4F6), height: 24, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
                    child: Text(
                      'UTILITAS SISTEM',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF76777B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.map_outlined,
                    label: 'Sitemap Navigasi Sistem',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: isActive ? const Color(0xFFD97706) : const Color(0xFF76777B)),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? const Color(0xFFD97706) : const Color(0xFF1A1A18),
        ),
      ),
      selected: isActive,
      selectedTileColor: const Color(0xFFD97706).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
    );
  }

  // ==================== TAB 1: RINGKASAN & ARUS KAS ====================
  Widget _buildTabCashflowAndSummary(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // 1. Total Omzet dengan Mountain Chart Bulanan
        _buildMountainOmzetCard(context),
        const SizedBox(height: 12),

        // 2. Transaksi Sukses Card dengan Button
        _buildBetterSuccessTrxCard(context),
        const SizedBox(height: 12),

        // 3. Total Deposit Dompet Card dengan Button
        _buildBetterDepositCard(context),
        const SizedBox(height: 20),

        // Transaksi Finansial Terkini
        Text(
          'Aktivitas Transaksi Terkini',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
        ),
        const SizedBox(height: 8),

        _buildTransactionFeedItem(
          icon: Icons.qr_code_2,
          iconBg: const Color(0xFFD1F2EB),
          iconColor: const Color(0xFF17A18A),
          title: 'Pembayaran QRIS Gerbang Masuk',
          subtitle: 'Central Park Mall · Sesi #TRX-9482 (B 1234 SKP)',
          amount: '+Rp 15.000',
          isIncome: true,
          time: '2 mnt lalu',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
        ),
        const SizedBox(height: 8),
        _buildTransactionFeedItem(
          icon: Icons.account_balance_wallet,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: 'Injeksi Saldo Dompet Admin',
          subtitle: 'Top-up oleh admin ke akun Budi Santoso',
          amount: '+Rp 250.000',
          isIncome: true,
          time: '18 mnt lalu',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
        ),
        const SizedBox(height: 8),
        _buildTransactionFeedItem(
          icon: Icons.credit_card,
          iconBg: const Color(0xFFEBF2FA),
          iconColor: const Color(0xFF114177),
          title: 'Settlement Midtrans Auto-Payout',
          subtitle: 'Rekening Operasional Bank Mandiri · Batch #ST-881',
          amount: '+Rp 4.250.000',
          isIncome: true,
          time: '35 mnt lalu',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
        ),
        const SizedBox(height: 8),
        _buildTransactionFeedItem(
          icon: Icons.replay,
          iconBg: const Color(0xFFFDE8E4),
          iconColor: const Color(0xFFD94B4B),
          title: 'Refund Pembatalan Parkir Tiket',
          subtitle: 'Malioboro Mall · #BK-3021 (Dibatalkan pengguna)',
          amount: '-Rp 20.000',
          isIncome: false,
          time: '1 jam lalu',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
        ),
        const SizedBox(height: 30),
      ],
    );
  }





  // ==================== WIDGET HELPERS ====================
  // ==================== WIDGET HELPERS: 3 KARTU UTAMA KE KEUANGAN ====================
  Widget _buildMountainOmzetCard(BuildContext context) {
    final b = AdminFinanceDashboardBackend.instance;
    final chartData = b.mountainChartData;
    final xLabels = b.mountainXLabels;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF114177).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.monetization_on_rounded, size: 20, color: Color(0xFF114177)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL OMZET BULANAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF76777B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Tren Pendapatan 6 Bulan Terakhir',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              b.totalMonthlyOmzet,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF114177),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              b.currentMonthLabel,
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF76777B)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF17A18A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                b.monthlyGrowth,
                style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
              ),
            ),
            const SizedBox(height: 12),

            // Mountain Chart Area
            SizedBox(
              height: 90,
              width: double.infinity,
              child: CustomPaint(
                painter: _SimpleMountainPainter(
                  data: chartData,
                  xLabels: xLabels,
                  lineColor: const Color(0xFF114177),
                  gradientStart: const Color(0xFF114177).withValues(alpha: 0.3),
                  gradientEnd: const Color(0xFF114177).withValues(alpha: 0.0),
                ),
              ),
            ),
            const SizedBox(height: 8),

            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Buka Analitik Pendapatan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF114177)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBetterSuccessTrxCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF114177).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 20, color: Color(0xFF114177)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaksi Sukses',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                      ),
                      Text(
                        'Settlement Real-time 100% Valid',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF114177).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${AdminFinanceDashboardBackend.instance.successTrxCount} Trx Hari Ini',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AdminFinanceDashboardBackend.instance.successTrxVolume,
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
          ),
          const SizedBox(height: 2),
          Text(
            'Total volume pembayaran parkir & settlement per hari ini',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
              icon: const Icon(Icons.receipt_long, size: 16, color: Colors.white),
              label: Text(
                'Lihat Manajemen Transaksi',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114177),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetterDepositCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, size: 20, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Deposit Saldo Dompet',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                      ),
                      Text(
                        'Akumulasi saldo kas e-wallet pengguna siap pakai',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${AdminFinanceDashboardBackend.instance.activeWalletUsers} User',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFFD97706)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AdminFinanceDashboardBackend.instance.totalWalletDeposit,
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
          ),
          const SizedBox(height: 2),
          Text(
            'Dana deposit pengguna yang mengendap dalam ekosistem',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
              icon: const Icon(Icons.account_balance_wallet, size: 16, color: Colors.white),
              label: Text(
                'Kelola Injeksi Saldo & Kas',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionFeedItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
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
                const SizedBox(height: 2),
                Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
              ],
            ),
          ],
        ),
      ),
    );
  }


}

class _SimpleMountainPainter extends CustomPainter {
  final List<double> data;
  final List<String> xLabels;
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;

  _SimpleMountainPainter({
    required this.data,
    required this.xLabels,
    required this.lineColor,
    required this.gradientStart,
    required this.gradientEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double marginHorizontal = 12.0;
    final double chartWidth = size.width - (marginHorizontal * 2);
    final double stepX = chartWidth / (data.length - 1);
    const double topPadding = 10.0;
    final double baselineY = size.height - 22.0;
    final double availableHeight = baselineY - topPadding;

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = marginHorizontal + (i * stepX);
      final double y = topPadding + (1.0 - data[i].clamp(0.0, 1.0)) * availableHeight;
      points.add(Offset(x, y));
    }

    final Path linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(points.last.dx, baselineY);
    fillPath.lineTo(points.first.dx, baselineY);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTRB(0, topPadding, 0, baselineY));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isLast = i == points.length - 1;

      if (isLast) {
        final glowPaint = Paint()..color = lineColor.withValues(alpha: 0.2);
        canvas.drawCircle(p, 8.0, glowPaint);
        final outerDot = Paint()..color = Colors.white;
        canvas.drawCircle(p, 4.0, outerDot);
        final innerDot = Paint()..color = lineColor;
        canvas.drawCircle(p, 2.8, innerDot);
      } else {
        final dotPaint = Paint()..color = lineColor;
        canvas.drawCircle(p, 2.0, dotPaint);
      }

      if (i < xLabels.length) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: xLabels[i],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
              color: isLast ? lineColor : const Color(0xFF76777B),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(p.dx - (textPainter.width / 2), baselineY + 5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleMountainPainter oldDelegate) => false;
}

