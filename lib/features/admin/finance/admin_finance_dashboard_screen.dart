import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_finance_notifications_screen.dart';
import 'admin_wallet_screen.dart';
import 'admin_transactions_screen.dart';
import 'revenue_screen.dart';
import '../../auth/login_screen.dart';
import '../../../core/services/session_service.dart';
import 'backend/admin_finance_dashboard_backend.dart';

class AdminFinanceDashboardScreen extends StatefulWidget {
  const AdminFinanceDashboardScreen({super.key});

  @override
  State<AdminFinanceDashboardScreen> createState() => _AdminFinanceDashboardScreenState();
}

class _AdminFinanceDashboardScreenState extends State<AdminFinanceDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _inspectedQuarterIndex;
  String _adminName = 'Admin Finansial';
  String _adminEmail = 'finance@parksmart.id';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    AdminFinanceDashboardBackend.instance.fetchFinanceDashboard();
  }

  Future<void> _loadAdminInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('current_admin_name');
      final savedEmail = prefs.getString('current_admin_email');
      final savedRole = prefs.getString('current_admin_role');
      if (savedName != null && savedName.isNotEmpty && (savedRole == null || savedRole.toLowerCase().contains('finansial'))) {
        if (mounted) {
          setState(() {
            _adminName = savedName;
            if (savedEmail != null) _adminEmail = savedEmail;
          });
        }
        return;
      }
      final res = await Supabase.instance.client
          .from('admins')
          .select('full_name, email')
          .eq('role', 'finance')
          .maybeSingle();
      if (res != null && mounted) {
        setState(() {
          _adminName = res['full_name'] ?? _adminName;
          _adminEmail = res['email'] ?? _adminEmail;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      AdminFinanceDashboardBackend.instance.fetchFinanceDashboard(),
      _loadAdminInfo(),
    ]);
  }

  void _onQuarterChartTouch(double localX, double canvasWidth, int pointCount, int activeCount) {
    if (pointCount <= 1 || canvasWidth <= 0 || activeCount <= 0) return;
    const double marginHorizontal = 12.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    if (chartWidth <= 0) return;
    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = (localX - marginHorizontal).clamp(0.0, chartWidth);
    final int closestIndex = (relativeX / stepX).round().clamp(0, activeCount - 1);
    if (_inspectedQuarterIndex != closestIndex) {
      setState(() => _inspectedQuarterIndex = closestIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminFinanceDashboardBackend.instance,
      builder: (context, _) => Theme(
        data: AppTheme.light,
        child: Scaffold(
          key: _scaffoldKey,
          // ─── [ADMIN FINANCE] WARNA LATAR BELAKANG DASHBOARD ───
          backgroundColor: const Color(0xFFF9F9F9), // <-- Ubah warna Background Dashboard Admin Finance
          drawer: _buildFinanceDrawer(context),

          // ─── [ADMIN FINANCE] WARNA HEADER / TOPBAR (APPBAR) ───
          appBar: AppBar(
          backgroundColor: Colors.white, // <-- Ubah warna TopBar/Header Admin Finance
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
            IconButton(
              icon: AdminFinanceDashboardBackend.instance.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706)),
                    )
                  : const Icon(Icons.refresh_rounded, color: Color(0xFF1A1A18), size: 22),
              tooltip: 'Muat Ulang Database',
              onPressed: AdminFinanceDashboardBackend.instance.isLoading
                  ? null
                  : () => AdminFinanceDashboardBackend.instance.fetchFinanceDashboard(),
            ),
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
                    child: Center(
                      child: Text(
                        _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'F',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_adminName, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(_adminEmail, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
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
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFD94B4B)),
                    title: Text(
                      'Keluar Dashboard',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD94B4B),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    onTap: () {
                      SessionService.instance.clearSession();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
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
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFFD97706),
      backgroundColor: Colors.white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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

          Builder(
            builder: (ctx) {
              final b = AdminFinanceDashboardBackend.instance;
              if (b.recentTransactions.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.receipt_long_outlined, size: 24, color: Color(0xFF76777B)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Belum Ada Aktivitas Transaksi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A18),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Riwayat transaksi finansial terbaru akan muncul di sini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF76777B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: b.recentTransactions.map((trx) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildTransactionFeedItem(
                    icon: trx['icon'] as IconData,
                    iconBg: trx['iconBg'] as Color,
                    iconColor: trx['iconColor'] as Color,
                    title: trx['title'] as String,
                    subtitle: trx['subtitle'] as String,
                    amount: trx['amount'] as String,
                    isIncome: trx['isIncome'] as bool,
                    time: trx['time'] as String,
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(builder: (_) => const AdminTransactionsScreen()),
                    ),
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }





  // ==================== WIDGET HELPERS ====================
  // ==================== WIDGET HELPERS: 3 KARTU UTAMA KE KEUANGAN ====================
  Widget _buildMountainOmzetCard(BuildContext context) {
    final b = AdminFinanceDashboardBackend.instance;
    final chartData = b.quarterlyChartData;
    final xLabels = b.quarterlyXLabels;
    final int availableCount = b.availableQuartersCount;
    final int activeIdx = (_inspectedQuarterIndex ?? b.latestQuarterIndex).clamp(0, b.quarterlyValues.length - 1);
    final String displayOmzet = b.quarterlyValues[activeIdx];
    final String displayLabel = b.quarterlyDates[activeIdx];
    final double growth = b.quarterlyGrowths[activeIdx];
    final bool isNegative = growth < 0;
    final String growthBadgeText = activeIdx == 0
        ? 'Kuartal 1 (Basis)'
        : '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}% vs Q$activeIdx';

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
                      'TOTAL OMZET KUARTAL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF76777B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Tren Pendapatan 4 Kuartal (2026)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              displayOmzet,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF114177),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              displayLabel,
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF76777B)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isNegative ? const Color(0xFFFDE8E4) : const Color(0xFFE8F7F4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isNegative
                      ? const Color(0xFFD94B4B).withValues(alpha: 0.25)
                      : const Color(0xFF17A18A).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isNegative ? Icons.trending_down : Icons.trending_up,
                    size: 12,
                    color: isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    growthBadgeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Mountain Chart Area (Interaktif 4 Kuartal)
            LayoutBuilder(
              builder: (context, constraints) {
                final double canvasWidth = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => _onQuarterChartTouch(details.localPosition.dx, canvasWidth, chartData.length, availableCount),
                  onPanStart: (details) => _onQuarterChartTouch(details.localPosition.dx, canvasWidth, chartData.length, availableCount),
                  onPanUpdate: (details) => _onQuarterChartTouch(details.localPosition.dx, canvasWidth, chartData.length, availableCount),
                  child: SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _SimpleMountainPainter(
                        data: chartData,
                        xLabels: xLabels,
                        inspectedIndex: _inspectedQuarterIndex,
                        activePointCount: availableCount,
                        lineColor: const Color(0xFF114177),
                        gradientStart: const Color(0xFF114177).withValues(alpha: 0.3),
                        gradientEnd: const Color(0xFF114177).withValues(alpha: 0.0),
                      ),
                    ),
                  ),
                );
              },
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
  final int? inspectedIndex;
  final int activePointCount;
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;

  _SimpleMountainPainter({
    required this.data,
    required this.xLabels,
    this.inspectedIndex,
    this.activePointCount = 4,
    required this.lineColor,
    required this.gradientStart,
    required this.gradientEnd,
  });

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = 3,
    double dashSpace = 3,
  }) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    final double unitX = dx / distance;
    final double unitY = dy / distance;

    double current = 0;
    while (current < distance) {
      final double start = current;
      final double end = math.min(current + dashWidth, distance);
      canvas.drawLine(
        Offset(p1.dx + unitX * start, p1.dy + unitY * start),
        Offset(p1.dx + unitX * end, p1.dy + unitY * end),
        paint,
      );
      current += dashWidth + dashSpace;
    }
  }

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

    final int effectiveActive = activePointCount.clamp(1, points.length);

    // 🌊 Fill Gradien Biru Tua (Hanya sampai kuartal aktif)
    final Path linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < effectiveActive - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(points[effectiveActive - 1].dx, baselineY);
    fillPath.lineTo(points.first.dx, baselineY);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTRB(0, topPadding, 0, baselineY));

    canvas.drawPath(fillPath, fillPaint);

    // 〰️ Garis Biru Tua Utama (Hanya sampai kuartal aktif)
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Garis putus-putus untuk kuartal yang belum berjalan
    if (effectiveActive < points.length) {
      final futurePaint = Paint()
        ..color = const Color(0xFFD1D5DB)
        ..strokeWidth = 1.4;
      for (int i = effectiveActive - 1; i < points.length - 1; i++) {
        _drawDashedLine(canvas, points[i], points[i + 1], futurePaint);
      }
      for (int i = effectiveActive; i < points.length; i++) {
        canvas.drawCircle(points[i], 2.5, Paint()..color = const Color(0xFFD1D5DB));
      }
    }

    final int activeDotIdx = inspectedIndex ?? (effectiveActive - 1);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = i == activeDotIdx;
      final isFuture = i >= effectiveActive;

      if (isSelected && !isFuture) {
        final glowPaint = Paint()..color = lineColor.withValues(alpha: 0.2);
        canvas.drawCircle(p, 8.0, glowPaint);
        final outerDot = Paint()..color = Colors.white;
        canvas.drawCircle(p, 4.0, outerDot);
        final innerDot = Paint()..color = lineColor;
        canvas.drawCircle(p, 2.8, innerDot);
      } else if (!isFuture) {
        final dotPaint = Paint()..color = lineColor;
        canvas.drawCircle(p, 2.2, dotPaint);
      }

      if (i < xLabels.length) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: xLabels[i],
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSelected ? 10.5 : 9.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? lineColor
                  : isFuture
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF76777B),
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
  bool shouldRepaint(covariant _SimpleMountainPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.inspectedIndex != inspectedIndex ||
        oldDelegate.activePointCount != activePointCount ||
        oldDelegate.lineColor != lineColor;
  }
}

