import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_finance_notifications_screen.dart';
import 'admin_pricing_screen.dart';
import 'admin_wallet_screen.dart';
import 'admin_transactions_screen.dart';
import 'revenue_screen.dart';
import '../../sitemap_screen.dart';

class AdminFinanceDashboardScreen extends StatefulWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  State<AdminFinanceDashboardScreen> createState() => _AdminFinanceDashboardScreenState();
}

class _AdminFinanceDashboardScreenState extends State<AdminFinanceDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedPeriodIndex = 0; // 0=Hari Ini, 1=7 Hari, 2=Bulan Ini, 3=Tahun Ini
  int _inspectedChartPointIndex = 0;

  final List<Map<String, dynamic>> _periodData = [
    {
      'period': 'Hari Ini',
      'revenue': 'Rp 4.480.000',
      'growth': '+14.2%',
      'transactions': '842 Trx',
      'chartData': [0.15, 0.28, 0.45, 0.65, 0.78, 0.92, 1.0],
      'labels': ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '21:00'],
      'pointValues': ['Rp 350 Rb', 'Rp 780 Rb', 'Rp 1.45 Jt', 'Rp 2.35 Jt', 'Rp 3.10 Jt', 'Rp 3.95 Jt', 'Rp 4.48 Jt'],
    },
    {
      'period': '7 Hari',
      'revenue': 'Rp 28.600.000',
      'growth': '+18.5%',
      'transactions': '5.410 Trx',
      'chartData': [0.35, 0.48, 0.42, 0.68, 0.75, 0.92, 0.86],
      'labels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
      'pointValues': ['Rp 3.2 Jt', 'Rp 3.8 Jt', 'Rp 3.5 Jt', 'Rp 4.4 Jt', 'Rp 4.8 Jt', 'Rp 5.2 Jt', 'Rp 3.7 Jt'],
    },
    {
      'period': 'Bulan Ini',
      'revenue': 'Rp 118.500.000',
      'growth': '+16.0%',
      'transactions': '22.840 Trx',
      'chartData': [0.22, 0.45, 0.68, 0.95],
      'labels': ['Mgg 1', 'Mgg 2', 'Mgg 3', 'Mgg 4'],
      'pointValues': ['Rp 24 Jt', 'Rp 29 Jt', 'Rp 32 Jt', 'Rp 33.5 Jt'],
    },
    {
      'period': 'Tahun Ini',
      'revenue': 'Rp 1.420.000.000',
      'growth': '+24.8%',
      'transactions': '264.000 Trx',
      'chartData': [0.18, 0.26, 0.35, 0.48, 0.58, 0.70, 0.82, 0.95],
      'labels': ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7', 'Q8'],
      'pointValues': ['Rp 110 Jt', 'Rp 145 Jt', 'Rp 160 Jt', 'Rp 180 Jt', 'Rp 195 Jt', 'Rp 205 Jt', 'Rp 210 Jt', 'Rp 215 Jt'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
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
                  color: const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(12),
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabCashflowAndSummary(context),
            _buildTabRevenueAnalytics(context),
            _buildTabFinancialLedgers(context),
          ],
        ),
        // Navigasi Bar Tab di Bawah Layar (Menempel sisi bawah layar, tidak melayang)
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE4DFD5), width: 1)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Arus Kas',
                    index: 0,
                    activeColor: const Color(0xFFD97706),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.insights_rounded,
                    label: 'Pendapatan',
                    index: 1,
                    activeColor: const Color(0xFFD97706),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.account_balance_rounded,
                    label: 'Buku Besar',
                    index: 2,
                    activeColor: const Color(0xFFD97706),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : const Color(0xFF76777B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF76777B),
              ),
            ),
          ],
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
                color: Color(0xFF114177),
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
                    icon: Icons.price_change_outlined,
                    label: 'Konfigurasi Tarif Parkir',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_active_outlined,
                    label: 'Notifikasi & Settlement Masuk',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinanceNotificationsScreen()));
                    },
                  ),
                  const Divider(color: Color(0xFFF1EEE7), indent: 16, endIndent: 16),
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
      leading: Icon(icon, size: 20, color: isActive ? const Color(0xFF114177) : const Color(0xFF76777B)),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? const Color(0xFF114177) : const Color(0xFF1A1A18),
        ),
      ),
      selected: isActive,
      selectedTileColor: const Color(0xFF114177).withValues(alpha: 0.08),
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
        // Ringkasan Tiga Kartu Finansial Utama
        Row(
          children: [
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'Total Omzet Hari Ini',
                value: 'Rp 4.480.000',
                subtitle: '+14.2% vs Kemarin',
                icon: Icons.monetization_on_outlined,
                accentColor: const Color(0xFF17A18A),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryMetricCard(
                title: 'Transaksi Sukses',
                value: '842 Trx',
                subtitle: 'Settlement 100% Valid',
                icon: Icons.receipt_long_rounded,
                accentColor: const Color(0xFF114177),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Kartu Deposit Dompet User
        _buildSummaryWideCard(
          title: 'Total Deposit Saldo Dompet',
          value: 'Rp 18.500.000',
          subtitle: 'Akumulasi saldo e-wallet pengguna siap pakai transaksi',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: const Color(0xFFD97706),
          buttonText: 'Kelola Injeksi Saldo',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
        ),
        const SizedBox(height: 20),

        // Tombol Aksi Cepat Finansial
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aksi Cepat Finansial', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Tindakan Administrasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.price_change_outlined,
              label: 'Konfigurasi\nTarif Parkir',
              color: const Color(0xFF114177),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingScreen())),
            ),
            const SizedBox(width: 10),
            _buildQuickActionButton(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Injeksi Saldo\nDompet',
              color: const Color(0xFFD97706),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
            ),
            const SizedBox(width: 10),
            _buildQuickActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'Riwayat &\nMutasi',
              color: const Color(0xFF17A18A),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Transaksi Finansial Terkini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aktivitas Transaksi Terkini', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                Text('Arus pembayaran parkir real-time dari gerbang & app', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
              child: Text('Buka Semua', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
            ),
          ],
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

  // ==================== TAB 2: ANALITIK PENDAPATAN ====================
  Widget _buildTabRevenueAnalytics(BuildContext context) {
    final activeData = _periodData[_selectedPeriodIndex];
    final chartValues = activeData['chartData'] as List<double>;
    final labels = activeData['labels'] as List<String>;
    final pointValues = activeData['pointValues'] as List<String>;

    final currentInspectedPoint = _inspectedChartPointIndex.clamp(0, chartValues.length - 1);

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Penjelasan Analitik
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF17A18A).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF17A18A).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.insights_rounded, size: 22, color: Color(0xFF17A18A)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian Penghasilan & Analisis Omzet',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                    ),
                    Text(
                      'Pilih rentang periode waktu di bawah untuk menyaring grafik pendapatan secara instan.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filter Pilihan Periode
        Row(
          children: List.generate(_periodData.length, (i) {
            final isSelected = i == _selectedPeriodIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriodIndex = i;
                    _inspectedChartPointIndex = 0;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: i == _periodData.length - 1 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF114177) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? const Color(0xFF114177) : const Color(0xFFE4DFD5)),
                  ),
                  child: Center(
                    child: Text(
                      _periodData[i]['period'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF45474A),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // KARTU GRAFIK INTERAKTIF
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4DFD5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activeData['period'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                      Text(
                        activeData['revenue'],
                        style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17A18A).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, size: 14, color: Color(0xFF17A18A)),
                        const SizedBox(width: 4),
                        Text(activeData['growth'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Visual Grafik Bar Interaktif
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(chartValues.length, (idx) {
                    final val = chartValues[idx];
                    final isHighlighted = idx == currentInspectedPoint;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _inspectedChartPointIndex = idx;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: chartValues.length > 6 ? 24 : 36,
                            height: (100 * val).clamp(16.0, 100.0),
                            decoration: BoxDecoration(
                              color: isHighlighted ? const Color(0xFF17A18A) : const Color(0xFF114177).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: isHighlighted ? Border.all(color: const Color(0xFF0F172A), width: 1.5) : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            labels[idx],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                              color: isHighlighted ? const Color(0xFF114177) : const Color(0xFF76777B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1EEE7)),
              const SizedBox(height: 12),

              // Keterangan Titik yang Disorot
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAF9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF1EEE7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.touch_app_outlined, size: 16, color: Color(0xFF114177)),
                        const SizedBox(width: 8),
                        Text(
                          'Titik: ${labels[currentInspectedPoint]}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                        ),
                      ],
                    ),
                    Text(
                      'Pemasukan: ${pointValues[currentInspectedPoint]}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // KOMPOSISI METODE PEMBAYARAN
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4DFD5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distribusi Metode Pembayaran', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('Proporsi saluran transaksi masuk yang terverifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              const SizedBox(height: 16),

              // Multi-Color Segment Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Expanded(flex: 52, child: Container(height: 14, color: const Color(0xFF17A18A))),
                    Expanded(flex: 34, child: Container(height: 14, color: const Color(0xFFD97706))),
                    Expanded(flex: 14, child: Container(height: 14, color: const Color(0xFF114177))),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildPaymentChannelRow('QRIS & Midtrans Gateway', '52% (Rp 2.329.600)', const Color(0xFF17A18A)),
              const SizedBox(height: 8),
              _buildPaymentChannelRow('Saldo Dompet ParkSmart (E-Wallet)', '34% (Rp 1.523.200)', const Color(0xFFD97706)),
              const SizedBox(height: 8),
              _buildPaymentChannelRow('Transfer Bank & Kartu Debit/Kredit', '14% (Rp 627.200)', const Color(0xFF114177)),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // KONTRIBUSI PER LOKASI
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4DFD5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kontribusi Omzet per Gedung', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
                    child: Text('Detail Lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildLocationContributionRow('Central Park Mall', 'Jakarta Barat', 'Rp 1.950.000', 0.85),
              const SizedBox(height: 10),
              _buildLocationContributionRow('Grand Indonesia', 'Jakarta Pusat', 'Rp 1.620.000', 0.72),
              const SizedBox(height: 10),
              _buildLocationContributionRow('Malioboro Mall', 'Yogyakarta', 'Rp 580.000', 0.40),
              const SizedBox(height: 10),
              _buildLocationContributionRow('Galaxy Mall Surabaya', 'Surabaya', 'Rp 330.000', 0.25),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ==================== TAB 3: BUKU BESAR & MODUL ====================
  Widget _buildTabFinancialLedgers(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Pusat Buku Besar Finansial', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        Text('Akses lengkap riwayat mutasi transaksi, audit dompet dan struktur tarif', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        const SizedBox(height: 16),

        // Riwayat & Mutasi Transaksi (Audit Transaksi)
        _buildHubActionCard(
          context,
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF114177),
          title: 'Riwayat & Mutasi Transaksi',
          subtitle: 'Audit buku besar transaksi, settlement gerbang, log Midtrans & cetak tanda terima',
          actionText: 'Buka Mutasi Transaksi',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
        ),
        const SizedBox(height: 12),

        // Injeksi Saldo & Wallet Admin
        _buildHubActionCard(
          context,
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFFD97706),
          title: 'Injeksi Saldo & Wallet Admin',
          subtitle: 'Pengisian saldo manual pengguna, verifikasi refund dan monitoring saldo mengendap',
          actionText: 'Kelola Saldo Dompet',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
        ),
        const SizedBox(height: 12),

        // Konfigurasi Tarif Parkir
        _buildHubActionCard(
          context,
          icon: Icons.price_change_outlined,
          iconColor: const Color(0xFF17A18A),
          title: 'Konfigurasi Tarif Parkir',
          subtitle: 'Penetapan tarif dasar per jam, tarif flat malam hari dan aturan penalti keterlambatan',
          actionText: 'Atur Struktur Tarif',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingScreen())),
        ),
        const SizedBox(height: 12),

        // Laporan Pendapatan & MRR
        _buildHubActionCard(
          context,
          icon: Icons.analytics_outlined,
          iconColor: const Color(0xFF6D28D9),
          title: 'Laporan Pendapatan & Revenue Analytics',
          subtitle: 'Analisis laba bersih, rekonsiliasi bulanan, proyeksi omzet dan pertumbuhan tahunan',
          actionText: 'Buka Analitik Penuh',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ==================== WIDGET HELPERS ====================
  Widget _buildSummaryMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4DFD5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryWideCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF114177)),
                  label: Text(buttonText, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF114177)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4DFD5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18), height: 1.2),
              ),
            ],
          ),
        ),
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

  Widget _buildPaymentChannelRow(String name, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
          ],
        ),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
      ],
    );
  }

  Widget _buildLocationContributionRow(String name, String city, String amount, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$name ($city)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
            Text(amount, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: const Color(0xFFF1EEE7),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF114177)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildHubActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B), height: 1.3)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                  label: Text(actionText, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF114177),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
