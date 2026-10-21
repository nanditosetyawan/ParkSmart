import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_notifications_screen.dart';
import 'admin_customer_profiles_screen.dart';
import 'admin_feedback_screen.dart';
import '../../sitemap_screen.dart';
import '../../auth/login_screen.dart';
import '../../../core/services/session_service.dart';
import 'backend/admin_cs_dashboard_backend.dart';

typedef AdminCsKycDashboardScreen = AdminCsDashboardScreen;

class AdminCsDashboardScreen extends StatefulWidget {
  const AdminCsDashboardScreen({super.key});

  @override
  State<AdminCsDashboardScreen> createState() => _AdminCsDashboardScreenState();
}

class _AdminCsDashboardScreenState extends State<AdminCsDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentTabIndex = 0;
  int? _inspectedQuarterIndex;
  String _adminName = 'Admin CS & Layanan';
  String _adminEmail = 'cs@parksmart.id';

  int get _activeQuarterIndex {
    final list = AdminCsDashboardBackend.instance.userGrowthQuarterlyData;
    if (list.isEmpty) return 0;
    return (_inspectedQuarterIndex ?? AdminCsDashboardBackend.instance.latestQuarterIndex)
        .clamp(0, list.length - 1);
  }

  List<Map<String, dynamic>> get _userGrowthQuarterlyData =>
      AdminCsDashboardBackend.instance.userGrowthQuarterlyData;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    AdminCsDashboardBackend.instance.fetchCsDashboardData();
    AdminCsDashboardBackend.instance.initRealtimeSubscription();
  }

  Future<void> _loadAdminInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('current_admin_name');
      final savedEmail = prefs.getString('current_admin_email');
      final savedRole = prefs.getString('current_admin_role');
      if (savedName != null && savedName.isNotEmpty && (savedRole == null || savedRole.toLowerCase().contains('cs') || savedRole.toLowerCase().contains('kyc'))) {
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
          .eq('role', 'cs')
          .maybeSingle();
      if (res != null && mounted) {
        setState(() {
          _adminName = res['full_name'] ?? _adminName;
          _adminEmail = res['email'] ?? _adminEmail;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    AdminCsDashboardBackend.instance.disposeRealtime();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminCsDashboardBackend.instance,
      builder: (context, _) {
        return Theme(
          data: AppTheme.light,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFF9F9F9),
            drawer: _buildCsDrawer(context),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
          leadingWidth: 54,
          // Tombol Ikon CS sebagai trigger drawer (menggantikan burger button seperti di operasional)
          leading: Center(
            child: InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.support_agent_rounded, size: 20, color: Color(0xFF0D9488)),
              ),
            ),
          ),
          titleSpacing: 4,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ParkSmart',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0xFF76777B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF14B8A6), width: 0.7),
                    ),
                    child: Text(
                      'CUSTOMER SERVICE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Dashboard Layanan & CRM',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A18),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                AdminCsDashboardBackend.instance.fetchCsDashboardData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Memperbarui data CS...', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFF0D9488),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF0D9488)),
              tooltip: 'Perbarui Data',
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()),
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
                child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF1A1A18)),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildTabOverview(context),
            _buildTabCrm(context),
          ],
        ),
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
                    icon: Icons.support_agent_rounded,
                    label: 'Layanan CS',
                    index: 0,
                    activeColor: const Color(0xFF0D9488),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.people_outline_rounded,
                    label: 'Pelanggan & CRM',
                    index: 1,
                    activeColor: const Color(0xFF0D9488),
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


  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
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
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF76777B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DRAWER SIDEBAR CS ====================
  Widget _buildCsDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profil Admin Customer Service
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D9488),
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
                        _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'C',
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
                          child: Text('Divisi Customer Service', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu Navigasi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                    child: Text(
                      'LAYANAN & PELANGGAN',
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
                    label: 'Dashboard Layanan CS',
                    onTap: () => Navigator.pop(context),
                    isActive: true,
                  ),
                  _buildDrawerItem(
                    icon: Icons.badge_outlined,
                    label: 'Profil Pelanggan CRM',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.rate_review_outlined,
                    label: 'Review & Ulasan Pengguna',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Pusat Notifikasi & Siaran',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()));
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
      leading: Icon(icon, size: 20, color: isActive ? const Color(0xFF0D9488) : const Color(0xFF76777B)),
      title: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? const Color(0xFF0D9488) : const Color(0xFF1A1A18),
        ),
      ),
      selected: isActive,
      selectedTileColor: const Color(0xFF0D9488).withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: onTap,
    );
  }

  // ==================== TAB 0: LAYANAN CS & OVERVIEW ====================
  Widget _buildTabOverview(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => AdminCsDashboardBackend.instance.fetchCsDashboardData(),
      color: const Color(0xFF0D9488),
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Layanan Pelanggan (CS)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                Text(
                  'Manajemen Customer, CRM & Ulasan Pengguna',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF76777B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF14B8A6), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 7, color: Color(0xFF0D9488)),
                  const SizedBox(width: 5),
                  Text(
                    'CS Online',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid Ringkasan Metrik CS
        _buildCsMetricGrid(),
        const SizedBox(height: 16),

        // Chart Pertumbuhan User Aktif yang Bergabung per Bulan
        _buildUserGrowthChartCard(context),
        const SizedBox(height: 18),

        // Quick Hub Cards: Akses Cepat CS & CRM
        Text(
          'Akses Cepat Customer Service',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A18),
          ),
        ),
        const SizedBox(height: 10),
        _buildCrmHubCard(
          icon: Icons.person_search_rounded,
          color: const Color(0xFF114177),
          title: 'Database Profil Pengguna (CRM)',
          subtitle: 'Histori transaksi, status akun, nomor HP, dan aktivitas booking',
          actionText: 'Buka Profil CRM',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _buildCrmHubCard(
          icon: Icons.rate_review_rounded,
          color: const Color(0xFFD97706),
          title: 'Ulasan & Feedback Pelanggan',
          subtitle: 'Rating bintang, masukan fasilitas, dan keluhan langsung customer',
          actionText: 'Kelola Ulasan',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackAdminScreen()),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
    );
  }

  // ==================== STATS METRIC GRID ====================
  Widget _buildCsMetricGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Pelanggan',
            value: AdminCsDashboardBackend.instance.totalPelanggan,
            sub: AdminCsDashboardBackend.instance.pertumbuhanKuartalIni,
            icon: Icons.people_outline_rounded,
            iconColor: const Color(0xFF114177),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            title: 'Kepuasan Customer',
            value: AdminCsDashboardBackend.instance.kepuasanCustomer,
            sub: AdminCsDashboardBackend.instance.ulasanMasuk,
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
          ),
        ),
      ],
    );
  }


  Widget _buildMetricCard({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF76777B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A18),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: CUSTOMER & CRM ====================
  Widget _buildTabCrm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Pusat Pengguna & Hubungan Pelanggan (CRM)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A18),
          ),
        ),
        Text(
          'Kelola database profil customer dan pantau review rating kepuasan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF76777B),
          ),
        ),
        const SizedBox(height: 16),

        _buildCrmHubCard(
          icon: Icons.person_search_rounded,
          color: const Color(0xFF114177),
          title: 'Database Profil Pengguna (CRM)',
          subtitle: 'Histori transaksi, status verifikasi akun, dan aktivitas booking',
          actionText: 'Buka Profil CRM',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen()),
          ),
        ),
        const SizedBox(height: 12),

        _buildCrmHubCard(
          icon: Icons.rate_review_rounded,
          color: const Color(0xFFD97706),
          title: 'Ulasan & Feedback Pelanggan',
          subtitle: 'Rating bintang, saran perbaikan fasilitas, dan tanggapan customer',
          actionText: 'Kelola Ulasan',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackAdminScreen()),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCrmHubCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionText,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A18),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0xFF76777B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF76777B)),
          ],
        ),
      ),
    );
  }

  // ==================== CHART: PERTUMBUHAN USER AKTIF (PER KUARTAL) ====================
  Widget _buildUserGrowthChartCard(BuildContext context) {
    final backend = AdminCsDashboardBackend.instance;
    final selectedData = _userGrowthQuarterlyData[_activeQuarterIndex];
    final chartValues = backend.quarterlyChartData;
    final labels = backend.quarterlyXLabels;
    final double growthVal = (selectedData['growth'] as num?)?.toDouble() ?? 0.0;
    final bool isNegative = growthVal < 0;
    final bool isBasis = _activeQuarterIndex == 0;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF114177).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_outline_rounded, size: 20, color: Color(0xFF114177)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pertumbuhan Customer Aktif',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      Text(
                        'Peningkatan pengguna baru yang bergabung per kuartal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF76777B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen()),
                ),
                icon: const Icon(Icons.arrow_forward, size: 13, color: Color(0xFF114177)),
                label: Text(
                  'Lihat Profil',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF114177),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User Stats Highlight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join ${selectedData['quarter']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFF114177),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+${_formatNumber(selectedData['joined'])} User',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF114177),
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total User Aktif',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFF76777B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatNumber(selectedData['cumulative'])} User',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A18),
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 28, color: const Color(0xFFCBD5E1)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laju Pertumbuhan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFF76777B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isBasis
                              ? Icons.info_outline
                              : (isNegative ? Icons.trending_down : Icons.trending_up),
                          size: 14,
                          color: isBasis
                              ? const Color(0xFF76777B)
                              : (isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A)),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${selectedData['growthText']}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isBasis
                                ? const Color(0xFF76777B)
                                : (isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mountain Area Chart: Pertumbuhan User Join (4 Kuartal)
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _handleChartTouch(details.localPosition, constraints.maxWidth),
                onHorizontalDragUpdate: (details) => _handleChartTouch(details.localPosition, constraints.maxWidth),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _UserGrowthMountainPainter(
                      data: chartValues,
                      xLabels: labels,
                      selectedIndex: _activeQuarterIndex,
                      activePointCount: backend.availableQuartersCount,
                      lineColor: const Color(0xFF114177),
                      gradientStart: const Color(0xFF114177).withValues(alpha: 0.28),
                      gradientEnd: const Color(0xFF114177).withValues(alpha: 0.01),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleChartTouch(Offset localPosition, double totalWidth) {
    final backend = AdminCsDashboardBackend.instance;
    final int activeCount = backend.availableQuartersCount;
    if (activeCount <= 0 || totalWidth <= 0) return;
    const double marginHorizontal = 16.0;
    final double chartWidth = totalWidth - (marginHorizontal * 2);
    if (chartWidth <= 0) return;
    final double stepX = chartWidth / (backend.quarterlyXLabels.length - 1);
    final double relativeX = (localPosition.dx - marginHorizontal).clamp(0.0, chartWidth);
    final int newIndex = (relativeX / stepX).round().clamp(0, activeCount - 1);
    if (newIndex != _inspectedQuarterIndex) {
      setState(() {
        _inspectedQuarterIndex = newIndex;
      });
    }
  }

  String _formatNumber(dynamic n) {
    if (n == null) return '0';
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}

class _UserGrowthMountainPainter extends CustomPainter {
  final List<double> data;
  final List<String> xLabels;
  final int selectedIndex;
  final int activePointCount;
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;

  _UserGrowthMountainPainter({
    required this.data,
    required this.xLabels,
    required this.selectedIndex,
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
    double dashWidth = 4,
    double dashSpace = 4,
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

    const double marginHorizontal = 16.0;
    final double chartWidth = size.width - (marginHorizontal * 2);
    final double stepX = chartWidth / (data.length - 1);
    const double topPadding = 12.0;
    final double baselineY = size.height - 22.0;
    final double availableHeight = baselineY - topPadding;

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = marginHorizontal + (i * stepX);
      final double y = topPadding + (1.0 - data[i].clamp(0.0, 1.0)) * availableHeight;
      points.add(Offset(x, y));
    }

    final int effectiveActive = activePointCount.clamp(1, points.length);

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

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Garis putus-putus untuk kuartal mendatang jika ada
    if (effectiveActive < points.length) {
      final futurePaint = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 1.5;
      for (int i = effectiveActive - 1; i < points.length - 1; i++) {
        _drawDashedLine(canvas, points[i], points[i + 1], futurePaint);
      }
      for (int i = effectiveActive; i < points.length; i++) {
        canvas.drawCircle(points[i], 2.5, Paint()..color = const Color(0xFFCBD5E1));
      }
    }

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = i == selectedIndex;
      final isFuture = i >= effectiveActive;

      if (isSelected && !isFuture) {
        // Vertical dashed indicator line
        final indicatorPaint = Paint()
          ..color = lineColor.withValues(alpha: 0.5)
          ..strokeWidth = 1.2;
        _drawDashedLine(canvas, Offset(p.dx, topPadding), Offset(p.dx, baselineY), indicatorPaint, dashWidth: 3, dashSpace: 3);

        final glowPaint = Paint()..color = lineColor.withValues(alpha: 0.25);
        canvas.drawCircle(p, 9.0, glowPaint);
        final outerDot = Paint()..color = Colors.white;
        canvas.drawCircle(p, 4.5, outerDot);
        final innerDot = Paint()..color = lineColor;
        canvas.drawCircle(p, 3.0, innerDot);
      } else if (!isFuture) {
        final dotPaint = Paint()..color = lineColor.withValues(alpha: 0.6);
        canvas.drawCircle(p, 2.5, dotPaint);
      }

      if (i < xLabels.length) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: xLabels[i],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? lineColor
                  : isFuture
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF76777B),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textX = p.dx - (textPainter.width / 2);
        final textY = baselineY + 4.0;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _UserGrowthMountainPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.activePointCount != activePointCount ||
        oldDelegate.data != data;
  }
}
