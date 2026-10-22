import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'admin_operations_notifications_screen.dart';
import 'admin_active_users_screen.dart';
import 'admin_bookings_screen.dart';
import 'manage_parking_screen.dart';
import '../../sitemap_screen.dart';
import '../../auth/login_screen.dart';
import '../../../core/services/session_service.dart';
import 'backend/admin_operations_dashboard_backend.dart';

class AdminOperationsDashboardScreen extends StatefulWidget {
  const AdminOperationsDashboardScreen({super.key});

  @override
  State<AdminOperationsDashboardScreen> createState() => _AdminOperationsDashboardScreenState();
}

class _AdminOperationsDashboardScreenState extends State<AdminOperationsDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _adminName = 'BAHLIL ETANOL';
  String _adminEmail = 'bahlil@parksmart.id';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    AdminOperationsDashboardBackend.instance.addListener(_onBackendChanged);
    AdminOperationsDashboardBackend.instance.fetchDashboardData();
  }

  Future<void> _loadAdminInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('current_admin_name');
      final savedEmail = prefs.getString('current_admin_email');
      final savedRole = prefs.getString('current_admin_role');
      if (savedName != null && savedName.isNotEmpty && (savedRole == null || savedRole.toLowerCase().contains('operasional'))) {
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
          .eq('role', 'operational')
          .maybeSingle();
      if (res != null && mounted) {
        setState(() {
          _adminName = res['full_name'] ?? _adminName;
          _adminEmail = res['email'] ?? _adminEmail;
        });
      }
    } catch (_) {}
  }

  void _onBackendChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AdminOperationsDashboardBackend.instance.removeListener(_onBackendChanged);
    super.dispose();
  }

  int _currentTabIndex = 0;
  int _selectedChartCityIndex = 0;
  String _selectedStatusFilter = 'Semua';
  String? _selectedParkedMonth;
  List<String> get _parkedMonths => AdminOperationsDashboardBackend.instance.availableMonths;

  // 📈 Kursor Crosshair Inspeksi Chart Gunung Kendaraan Parkir
  int? _inspectedParkedPointIndex;

  void _onParkedChartTouch(double touchX, double canvasWidth, int pointCount, int activePointCount) {
    if (pointCount <= 1 || canvasWidth <= 0 || activePointCount <= 0) return;
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    if (chartWidth <= 0) return;

    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = (touchX - marginHorizontal).clamp(0.0, chartWidth);
    final int closestIndex = (relativeX / stepX).round().clamp(0, activePointCount - 1);

    if (_inspectedParkedPointIndex != closestIndex) {
      setState(() {
        _inspectedParkedPointIndex = closestIndex;
      });
    }
  }

  List<Map<String, dynamic>> get _cityDensityList => AdminOperationsDashboardBackend.instance.cityDensityList;
  List<Map<String, dynamic>> get _operationalLocations => AdminOperationsDashboardBackend.instance.locations;

  List<Map<String, dynamic>> get _filteredLocations {
    if (_selectedStatusFilter == 'Semua') return _operationalLocations;
    return _operationalLocations.where((loc) => loc['status'] == _selectedStatusFilter).toList();
  }

  int _activitySubTab = 0; // 0 = Sesi Aktif, 1 = Reservasi

  List<Map<String, dynamic>> get _liveSessions => AdminOperationsDashboardBackend.instance.liveSessions;
  List<Map<String, dynamic>> get _liveBookings => AdminOperationsDashboardBackend.instance.liveBookings;


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminOperationsDashboardBackend.instance,
      builder: (context, _) {
        return Theme(
          data: AppTheme.light,
          child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF9F9F9),
        drawer: _buildOperationsDrawer(context),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 54,
          // Tombol P sebagai trigger drawer (menggantikan burger button)
          leading: Center(
            child: InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF114177).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF114177).withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.local_parking_rounded, size: 20, color: Color(0xFF114177)),
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
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3B82F6), width: 0.7),
                    ),
                    child: Text(
                      'OPERASIONAL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Dashboard Lapangan',
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOperationsNotificationsScreen()),
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
                        decoration: const BoxDecoration(color: Color(0xFFD94B4B), shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildTabLocations(context),
            _buildTabAnalytics(context),
            _buildTabActivity(context),
          ],
        ),
        // Navigasi Bar Tab di Bawah Layar (Menempel sisi bawah, tidak melayang)
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
                    icon: Icons.grid_view_rounded,
                    label: 'Monitoring',
                    index: 0,
                    activeColor: const Color(0xFF114177),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Analitik',
                    index: 1,
                    activeColor: const Color(0xFF114177),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.directions_car_rounded,
                    label: 'Sesi & Booking',
                    index: 2,
                    activeColor: const Color(0xFF114177),
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

  Future<void> _handleRefresh() async {
    await Future.wait([
      AdminOperationsDashboardBackend.instance.fetchDashboardData(),
      _loadAdminInfo(),
    ]);
  }

  // ==================== TAB 0: LOKASI & LAPANGAN ====================
  Widget _buildTabLocations(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF114177),
      backgroundColor: Colors.white,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        children: [
          // 4 KPI Real-Time
          _buildRealtimeKpiSection(),
          const SizedBox(height: 18),

          // Daftar Fasilitas Lapangan
          _buildFacilityListSection(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ==================== TAB 1: GRAFIK & ANALITIK ====================
  Widget _buildTabAnalytics(BuildContext context) {
    if (_cityDensityList.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFF114177),
        backgroundColor: Colors.white,
        onRefresh: _handleRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF114177).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.analytics_outlined, size: 30, color: Color(0xFF114177)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Data Analitik Lapangan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Data keterisian fisik dan proporsi armada akan terisi secara otomatis setelah titik tempat parkir dan sesi kendaraan ditambahkan ke database.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF76777B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    int totalMobil = 0;
    int totalMotor = 0;
    int totalEv = 0;
    for (var city in _cityDensityList) {
      totalMobil += city['mobil'] as int;
      totalMotor += city['motor'] as int;
      totalEv += city['ev'] as int;
    }

    final totalVehicles = totalMobil + totalMotor + totalEv;

    return RefreshIndicator(
      color: const Color(0xFF114177),
      backgroundColor: Colors.white,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
      children: [
        // Konteks Header Analitik
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF114177).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF114177).withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.insights_rounded, size: 22, color: Color(0xFF114177)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analisis Kapasitas & Armada', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                    Text('Data keterisian fisik dan proporsi kendaraan per wilayah kota.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Bar Chart Kepadatan Kota
        _buildInteractiveCapacitySection(),
        const SizedBox(height: 16),

        // Distribusi Keseluruhan Armada
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Distribusi Armada Keseluruhan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('Total jenis kendaraan dari ${_cityDensityList.length} kota operasional', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
              const SizedBox(height: 14),

              if (totalVehicles > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      if (totalMobil > 0) Expanded(flex: totalMobil, child: Container(height: 12, color: const Color(0xFF114177))),
                      if (totalMotor > 0) Expanded(flex: totalMotor, child: Container(height: 12, color: const Color(0xFF17A18A))),
                      if (totalEv > 0) Expanded(flex: totalEv, child: Container(height: 12, color: const Color(0xFFE07A5F))),
                    ],
                  ),
                )
              else
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFleetLegendItem(Icons.directions_car, 'Mobil', '$totalMobil Unit', const Color(0xFF114177)),
                  _buildFleetLegendItem(Icons.two_wheeler, 'Motor', '$totalMotor Unit', const Color(0xFF17A18A)),
                  _buildFleetLegendItem(Icons.electric_car, 'EV', '$totalEv Unit', const Color(0xFFE07A5F)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
}

  Widget _buildFleetLegendItem(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          ],
        ),
      ],
    );
  }

  // ==================== TAB 2: AKTIVITAS LAPANGAN REAL-TIME ====================
  Widget _buildTabActivity(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF114177),
      backgroundColor: Colors.white,
      onRefresh: _handleRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivitas Lapangan Real-Time',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
            ),
            const SizedBox(height: 2),
            Text(
              'Monitoring sesi kendaraan aktif & reservasi hari ini',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Segmented Switcher (Sesi Aktif vs Reservasi)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_activitySubTab == 0) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen()));
                    } else {
                      setState(() => _activitySubTab = 0);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _activitySubTab == 0 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: _activitySubTab == 0
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Kendaraan Aktif (${_liveSessions.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: _activitySubTab == 0 ? FontWeight.bold : FontWeight.w500,
                          color: _activitySubTab == 0 ? const Color(0xFF114177) : const Color(0xFF76777B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_activitySubTab == 1) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen()));
                    } else {
                      setState(() => _activitySubTab = 1);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _activitySubTab == 1 ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: _activitySubTab == 1
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Reservasi Masuk (${_liveBookings.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: _activitySubTab == 1 ? FontWeight.bold : FontWeight.w500,
                          color: _activitySubTab == 1 ? const Color(0xFF114177) : const Color(0xFF76777B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Hint interaktif
       
        const SizedBox(height: 10),

        if (_activitySubTab == 0) ...[
          // Sesi Kendaraan Aktif
          if (_liveSessions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.directions_car_outlined, size: 36, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 10),
                  Text(
                    'Belum Ada Kendaraan Aktif',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada sesi parkir yang sedang berjalan di database.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  ),
                ],
              ),
            )
          else
            ..._liveSessions.map((s) {
            final isOverstay = s['isOverstay'] == true;
            final isEv = s['isEv'] == true;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isOverstay ? const Color(0xFFF9D8D3) : const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _showActiveVehicleActionModal(s),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF114177).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    s['plate'],
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(s['type'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isOverstay
                                        ? const Color(0xFFFDE8E4)
                                        : (isEv ? const Color(0xFFEDE9FE) : const Color(0xFFD1F2EB)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isOverstay ? 'Overstay ${s['overstayDuration']}' : (isEv ? 'EV Charging' : 'Normal'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isOverstay
                                          ? const Color(0xFFD94B4B)
                                          : (isEv ? const Color(0xFF6D28D9) : const Color(0xFF17A18A)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${s['vehicle']} • Pengemudi: ${s['user']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('📍 ${s['location']} (${s['slot']})', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B))),
                            Text('⏱️ ${s['duration']} (${s['checkIn']})', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
            icon: const Icon(Icons.open_in_new_rounded, size: 14),
            label: Text('Buka Monitor Kendaraan Lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF114177),
              side: const BorderSide(color: Color(0xFF114177)),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ] else ...[
          // Reservasi Masuk
          if (_liveBookings.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 36, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 10),
                  Text(
                    'Belum Ada Reservasi Masuk',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada reservasi parkir yang tercatat di database.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  ),
                ],
              ),
            )
          else
            ..._liveBookings.map((b) {
            final isConfirmed = b['status'] == 'Dikonfirmasi';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _showBookingDetailModal(b),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b['code'],
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isConfirmed ? const Color(0xFFD1F2EB) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    b['status'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isConfirmed ? const Color(0xFF17A18A) : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${b['name']} • ${b['vehicleType']} (${b['plate']})', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('📍 ${b['location']} • ${b['slot']}', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B))),
                            Text('🕒 ${b['time']}', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
            icon: const Icon(Icons.open_in_new_rounded, size: 14),
            label: Text('Buka Manajemen Booking Lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF114177),
              side: const BorderSide(color: Color(0xFF114177)),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    ),
  );
}

  // 🚗 MODAL AKSI KENDARAAN AKTIF (KIRIM PENGINGAT & FORCE CHECK-OUT)
  void _showActiveVehicleActionModal(Map<String, dynamic> session) {
    final bool isOverstay = session['isOverstay'] == true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['plate'],
                      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                    ),
                    Text(
                      '${session['user']} • ${session['phone'] ?? '0812-3456-7890'}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverstay ? const Color(0xFFFDE8E4) : const Color(0xFFD1F2EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOverstay ? 'Overstay' : 'Normal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOverstay ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFFF3F4F6), height: 24),
            _buildActionDetailRow('Lokasi & Slot:', '${session['location']} (${session['slot']})'),
            _buildActionDetailRow('Kendaraan:', session['vehicle']),
            _buildActionDetailRow('Jam Check-In:', session['checkIn']),
            _buildActionDetailRow('Durasi Berjalan:', session['duration']),
            _buildActionDetailRow('Akumulasi Biaya:', session['fee']),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notifikasi peringatan berhasil dikirimkan ke ${session['user']}!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF114177)),
                    label: Text(
                      'Kirim Pengingat',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _liveSessions.removeWhere((s) => s['id'] == session['id']);
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF17A18A),
                          behavior: SnackBarBehavior.floating,
                          content: Text('Kendaraan ${session['plate']} berhasil di-checkout manual!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.exit_to_app, size: 16, color: Colors.white),
                    label: Text(
                      'Force Check-Out',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD94B4B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // 📋 MODAL DETAIL BOOKING LENGKAP (BKG-2024-002 RAFI MAULANA DLL)
  void _showBookingDetailModal(Map<String, dynamic> booking) {
    final bool isConfirmed = booking['status'] == 'Dikonfirmasi';
    final Color statusColor = isConfirmed ? const Color(0xFF17A18A) : const Color(0xFFD97706);
    final Color statusBg = isConfirmed ? const Color(0xFFD1F2EB) : const Color(0xFFFEF3C7);
    final String avatarInitial = (booking['name'] as String).isNotEmpty ? (booking['name'] as String)[0].toUpperCase() : 'B';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detail Booking', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        Text('${booking['id']} • ${booking['code']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(booking['status'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 18),

                // User Info
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(14)),
                      child: Center(
                        child: Text(
                          avatarInitial,
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          Text(booking['phone'] ?? '-', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 18),

                // Informasi Booking
                Text(
                  'Informasi Booking',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                ),
                const SizedBox(height: 10),
                _buildActionDetailRow('Tipe Booking:', 'Reservasi'),
                _buildActionDetailRow('Lokasi:', '${booking['location']} (${booking['floor'] ?? 'B2'})'),
                _buildActionDetailRow('Slot Parkir:', booking['slot']),
                _buildActionDetailRow('Kendaraan:', '${booking['plate']} (${booking['vehicleType']})'),
                _buildActionDetailRow('Jadwal Waktu:', booking['time']),
                _buildActionDetailRow('Durasi Reservasi:', booking['duration'] ?? '2 jam'),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 18),

                // Pembayaran
                Text(
                  'Pembayaran',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                ),
                const SizedBox(height: 10),
                _buildActionDetailRow('Total Biaya:', booking['totalPrice'] ?? 'Rp 28.000'),
                _buildActionDetailRow('Status Bayar:', booking['paymentStatus'] ?? 'Dibayar'),
                const SizedBox(height: 22),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Booking ${booking['code']} telah dibatalkan.'),
                              backgroundColor: const Color(0xFFD94B4B),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 16, color: Color(0xFFD94B4B)),
                        label: Text('Batalkan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD94B4B)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF17A18A),
                              behavior: SnackBarBehavior.floating,
                              content: Text('Sesi parkir untuk ${booking['name']} (${booking['plate']}) telah dimulai!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                        label: Text('Mulai Sesi', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17A18A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        ],
      ),
    );
  }

  // ==================== WIDGETS: KPI METRICS (CHART GUNUNG & OVERSTAY ALERT) ====================
  Widget _buildRealtimeKpiSection() {
    final overstayCount = AdminOperationsDashboardBackend.instance.overstaySessionsCount;
    return Column(
      children: [
        // 1. Chart Gunung Kendaraan Parkir (Bulan Ini)
        _buildParkedVehiclesMountainChart(),
        if (overstayCount > 0) ...[
          const SizedBox(height: 12),
          // 2. Overstay Alert Card Menarik di bawahnya
          _buildOverstayAlertCard(),
        ],
      ],
    );
  }

  // ⛰️ KARTU CHART GUNUNG KENDARAAN PARKIR (4 MINGGU PER BULAN)
  Widget _buildParkedVehiclesMountainChart() {
    const Color accentColor = Color(0xFF17A18A); // Emerald green
    final availableMonths = _parkedMonths;
    final monthlyData = AdminOperationsDashboardBackend.instance.monthlyChartData;

    if (availableMonths.isEmpty) {
      return _buildEmptyParkedVehiclesChart(accentColor);
    }

    final effectiveMonth = (_selectedParkedMonth != null && availableMonths.contains(_selectedParkedMonth))
        ? _selectedParkedMonth!
        : availableMonths.first;

    final activeData = monthlyData[effectiveMonth] ?? {
      'availableWeeksCount': 4,
      'latestWeekIndex': 0,
      'rawValues': [0, 0, 0, 0],
      'chartData': [0.05, 0.05, 0.05, 0.05],
      'pointValues': ['0 Unit', '0 Unit', '0 Unit', '0 Unit'],
      'pointDates': ['Minggu 1 (Tgl 1-7)', 'Minggu 2 (Tgl 8-14)', 'Minggu 3 (Tgl 15-21)', 'Minggu 4 (Tgl 22-Akhir)'],
      'xLabels': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
      'percentages': [0.0, 0.0, 0.0, 0.0],
    };

    final int availableWeeksCount = (activeData['availableWeeksCount'] as num?)?.toInt() ?? 4;
    final int latestWeekIndex = (activeData['latestWeekIndex'] as num?)?.toInt() ?? 0;
    final List<int> rawValues = List<int>.from(activeData['rawValues'] ?? [0, 0, 0, 0]);
    final List<double> chartData = List<double>.from(activeData['chartData'] ?? [0.05, 0.05, 0.05, 0.05]);
    final List<String> pointValues = List<String>.from(activeData['pointValues']);
    final List<String> pointDates = List<String>.from(activeData['pointDates']);
    final List<String> xLabels = List<String>.from(activeData['xLabels']);
    final List<double> percentages = List<double>.from(activeData['percentages']);
    final int pointCount = chartData.length;

    final bool isInspecting = _inspectedParkedPointIndex != null &&
        _inspectedParkedPointIndex! >= 0 &&
        _inspectedParkedPointIndex! < availableWeeksCount;

    // Menentukan minggu yang aktif ditampilkan nilainya
    final int activeWeekIdx = isInspecting ? _inspectedParkedPointIndex! : latestWeekIndex;
    final String displayValue = '${rawValues[activeWeekIdx]} Unit';
    final String displaySubtitle = pointDates[activeWeekIdx];

    // Kalkulasi persentase kenaikan/penurunan vs minggu sebelumnya
    double diffPercent = 0.0;
    String badgeText = 'Minggu 1';
    bool isNegative = false;

    if (activeWeekIdx > 0) {
      diffPercent = percentages[activeWeekIdx];
      isNegative = diffPercent < 0;
      badgeText = '${diffPercent >= 0 ? '+' : ''}${diffPercent.toStringAsFixed(1)}% vs M-$activeWeekIdx';
    } else {
      badgeText = 'Minggu 1';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Info Metrik + Dropdown Pilihan Bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car_rounded, size: 22, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kendaraan Parkir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      Text(
                        displaySubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isInspecting ? accentColor : const Color(0xFF76777B),
                          fontWeight: isInspecting ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Dropdown Pilihan Bulan (Dari database, maks 6 bulan terakhir WIB)
              PopupMenuButton<String>(
                initialValue: effectiveMonth,
                onSelected: (String month) {
                  setState(() {
                    _selectedParkedMonth = month;
                    _inspectedParkedPointIndex = null;
                  });
                },
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                itemBuilder: (context) => availableMonths.map((m) {
                  final isSelected = m == effectiveMonth;
                  final isCurrentMonth = m.contains('Okt 2026') || m == availableMonths.first;
                  final label = isCurrentMonth ? 'Bulan Ini ($m)' : m;
                  return PopupMenuItem<String>(
                    value: m,
                    height: 38,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF17A18A) : const Color(0xFF1A1A18),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_rounded, size: 16, color: Color(0xFF17A18A)),
                      ],
                    ),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1A1A18), width: 0.9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 12, color: Color(0xFF1A1A18)),
                      const SizedBox(width: 5),
                      Text(
                        effectiveMonth,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF1A1A18)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Nilai Angka Besar + Persentase Kenaikan/Penurunan (Tombol Reset Dihilangkan)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                displayValue,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A18),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isNegative ? const Color(0xFFFDE8E4) : const Color(0xFFE8F7F4),
                  borderRadius: BorderRadius.circular(6),
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
                    const SizedBox(width: 3),
                    Text(
                      badgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isNegative ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ⛰️ Chart Gunung Area (4 Titik: Minggu 1 s.d. 4)
          LayoutBuilder(
            builder: (context, constraints) {
              final double canvasWidth = constraints.maxWidth;
              const double canvasHeight = 160.0;

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEFECE6)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      _onParkedChartTouch(details.localPosition.dx, canvasWidth, pointCount, availableWeeksCount);
                    },
                    onPanStart: (details) {
                      _onParkedChartTouch(details.localPosition.dx, canvasWidth, pointCount, availableWeeksCount);
                    },
                    onPanUpdate: (details) {
                      _onParkedChartTouch(details.localPosition.dx, canvasWidth, pointCount, availableWeeksCount);
                    },
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: CustomPaint(
                        painter: _MountainChartPainter(
                          data: chartData,
                          pointValues: pointValues,
                          pointDates: pointDates,
                          xLabels: xLabels,
                          inspectedIndex: isInspecting ? _inspectedParkedPointIndex : null,
                          activePointCount: availableWeeksCount,
                          lineColor: accentColor,
                          gradientStart: accentColor.withValues(alpha: 0.35),
                          gradientEnd: accentColor.withValues(alpha: 0.0),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Geser titik grafik untuk inspeksi data',
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)),
              ),
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka Monitoring Sesi',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF114177)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyParkedVehiclesChart(Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
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
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.directions_car_rounded, size: 22, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kendaraan Parkir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      Text(
                        'Database Kosong',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                      ),
                    ],
                  ),
                ],
              ),
              // Dropdown Pilihan Bulan: Tetap bertuliskan "Bulan Ini" dan dapat diklik (menampilkan "Belum ada data")
              PopupMenuButton<String>(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    value: 'empty',
                    height: 38,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF76777B)),
                        const SizedBox(width: 8),
                        Text(
                          'Belum ada data',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF76777B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1A1A18), width: 0.9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 12, color: Color(0xFF1A1A18)),
                      const SizedBox(width: 5),
                      Text(
                        'Bulan Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF1A1A18)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '0 Unit',
            style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF1A1A18)),
          ),
          const SizedBox(height: 12),
          // Area Chart 160px: Mempertahankan garis dasar dan teks Minggu 1, 2, 3, 4 di bawahnya
          LayoutBuilder(
            builder: (context, constraints) {
              final double canvasWidth = constraints.maxWidth;
              const double canvasHeight = 160.0;
              const double marginHorizontal = 24.0;
              final double chartWidth = canvasWidth - (marginHorizontal * 2);
              final double stepX = chartWidth / 3.0; // 4 titik -> 3 segmen

              return Container(
                width: canvasWidth,
                height: canvasHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEFECE6)),
                ),
                child: Stack(
                  children: [
                    // Pesan 'Belum ada data' di tengah area grafik
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28.0, left: 16.0, right: 16.0),
                        child: Text(
                          'Belum ada data sesi parkir di database untuk periode ini.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF76777B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Garis Axis Baseline
                    Positioned(
                      left: marginHorizontal - 15,
                      right: marginHorizontal - 15,
                      bottom: 36.0,
                      child: Container(
                        height: 1.2,
                        color: const Color(0xFFE4DFD5),
                      ),
                    ),
                    // Pertahankan tulisan Minggu 1, 2, 3, 4
                    ...List.generate(4, (index) {
                      final double posX = marginHorizontal + (index * stepX);
                      final label = 'Minggu ${index + 1}';
                      return Positioned(
                        left: posX - 32.0,
                        width: 64.0,
                        bottom: 8.0,
                        child: Center(
                          child: Text(
                            label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF76777B),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 🚨 KARTU OVERSTAY ALERT MENARIK & EYE-CATCHING DI BAWAH CHART
  Widget _buildOverstayAlertCard() {
    final overstayCount = AdminOperationsDashboardBackend.instance.overstaySessionsCount;
    if (overstayCount <= 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F5), Color(0xFFFEE2E2)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Overstay Alert',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF991B1B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$overstayCount KENDARAAN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$overstayCount kendaraan melebihi batas kuota waktu parkir maksimal di lapangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF7F1D1D),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Aksi Menarik (Perbaiki tombol Overstay Alert kurang menarik)
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
              icon: const Icon(Icons.shield_outlined, size: 16, color: Colors.white),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tindak Lanjuti & Cek Plat Kendaraan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFFDC2626).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // ==================== WIDGETS: KEPADATAN KOTA INTERAKTIF ====================
  Widget _buildInteractiveCapacitySection() {
    if (_cityDensityList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF114177).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_city_rounded, size: 28, color: Color(0xFF114177)),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum Ada Data Kepadatan Kota',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
            ),
            const SizedBox(height: 6),
            Text(
              'Grafik kepadatan akan otomatis dihitung saat lokasi operasional terdaftar di database.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF76777B), height: 1.4),
            ),
          ],
        ),
      );
    }

    final safeIndex = _selectedChartCityIndex.clamp(0, _cityDensityList.length - 1);
    final selectedCity = _cityDensityList[safeIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF114177).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_city_rounded, size: 16, color: Color(0xFF114177)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kepadatan Kota',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
                ],
              ),
              Text(
                'Ketuk batang kota untuk rincian',
                style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visual Bar Chart Interaktif per Kota
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_cityDensityList.length, (i) {
              final city = _cityDensityList[i];
              final total = (city['total'] as num?)?.toInt() ?? 0;
              final occupied = (city['occupied'] as num?)?.toInt() ?? 0;
              final ratio = total > 0 ? (occupied / total).clamp(0.0, 1.0) : 0.0;
              final isSelected = i == safeIndex;
              final statusColor = (city['statusColor'] as Color?) ?? const Color(0xFF17A18A);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedChartCityIndex = i;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(ratio * 100).toInt()}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? const Color(0xFF114177) : const Color(0xFF76777B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 44,
                      height: 85 * ratio + 15,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF114177) : statusColor.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? Border.all(color: const Color(0xFF0F172A), width: 2) : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      city['city'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF114177) : const Color(0xFF45474A),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 10),

          // Detail Kota yang Dipilih
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kota ${selectedCity['city']}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                          ),
                          Text(
                            '${selectedCity['province']} • ${selectedCity['facilities']}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (selectedCity['statusColor'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        selectedCity['status'],
                        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: selectedCity['statusColor']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kapasitas Kota: ${selectedCity['occupied']} / ${selectedCity['total']} Terisi',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF45474A)),
                    ),
                    Text(
                      'Sisa ${(selectedCity['total'] as int) - (selectedCity['occupied'] as int)} Slot',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Bar Pembagian Armada Kota
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: selectedCity['mobil'] as int,
                        child: Container(height: 8, color: const Color(0xFF114177)),
                      ),
                      Expanded(
                        flex: selectedCity['motor'] as int,
                        child: Container(height: 8, color: const Color(0xFF17A18A)),
                      ),
                      Expanded(
                        flex: selectedCity['ev'] as int,
                        child: Container(height: 8, color: const Color(0xFFE07A5F)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Legenda Armada Kota
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCompactLegend(Icons.directions_car, 'Mobil: ${selectedCity['mobil']}', const Color(0xFF114177)),
                    _buildCompactLegend(Icons.two_wheeler, 'Motor: ${selectedCity['motor']}', const Color(0xFF17A18A)),
                    _buildCompactLegend(Icons.electric_car, 'EV: ${selectedCity['ev']}', const Color(0xFFE07A5F)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegend(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF45474A)),
        ),
      ],
    );
  }

  // ==================== WIDGETS: DAFTAR TITIK LAPANGAN ====================
  Widget _buildFacilityListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Titik Tempat Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                Text('Kapasitas dan sisa slot kosong terpantau langsung', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageParkingScreen(initialTabIndex: 0))),
              icon: const Icon(Icons.list_alt, size: 14, color: Color(0xFF114177)),
              label: Text('Semua', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Filter Chips Status
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Semua', 'Normal', 'Padat', 'Kritis'].map((status) {
              final isSelected = _selectedStatusFilter == status;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStatusFilter = status);
                    }
                  },
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                  ),
                  selectedColor: const Color(0xFF114177),
                  backgroundColor: const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isSelected ? const Color(0xFF114177) : const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Kartu-Kartu Lokasi atau Status Kosong
        if (_filteredLocations.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF114177).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_parking_rounded, size: 28, color: Color(0xFF114177)),
                ),
                const SizedBox(height: 12),
                Text(
                  _operationalLocations.isEmpty
                      ? 'Belum Ada Titik Tempat Parkir'
                      : 'Tidak Ada Lokasi Berstatus "$_selectedStatusFilter"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _operationalLocations.isEmpty
                      ? 'Database lokasi parkir masih kosong. Daftarkan lokasi baru melalui menu Pengelolaan Lokasi.'
                      : 'Semua lokasi saat ini memiliki status ketersediaan yang lain.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF76777B),
                    height: 1.4,
                  ),
                ),
                if (_operationalLocations.isEmpty) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageParkingScreen(initialTabIndex: 0))),
                    icon: const Icon(Icons.add_location_alt_rounded, size: 16, color: Colors.white),
                    label: Text(
                      'Kelola Titik Parkir',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF114177),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          ..._filteredLocations.map((loc) {
            final total = (loc['total'] as num?)?.toInt() ?? 0;
            final occupied = (loc['occupied'] as num?)?.toInt() ?? 0;
            final available = total > occupied ? total - occupied : 0;
            final pct = total > 0 ? (occupied / total).clamp(0.0, 1.0) : 0.0;
            final statusColor = (loc['statusColor'] as Color?) ?? const Color(0xFF17A18A);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc['name'] ?? 'Lokasi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                            Text('${loc['city'] ?? ''} • ${loc['zone'] ?? ''}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          loc['status'] ?? 'Normal',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bar Visual Kapasitas
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Status Slot & Armada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$occupied / $total Terisi',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF45474A)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17A18A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Sisa $available Slot Kosong',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rincian Unit Terparkir
                 
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 10),

                  // Tombol Denah Slot Lapangan (Tunggal & Tidak Redundan)
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageParkingScreen(
                            initialTabIndex: 1,
                            initialLocationId: loc['db_id']?.toString() ?? loc['id']?.toString(),
                            initialLocationName: loc['name']?.toString(),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.grid_on_rounded, size: 14, color: Colors.white),
                      label: Text(
                        'Buka Denah & Status Slot',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF114177),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==================== DRAWER SIDEBAR ====================
  Widget _buildOperationsDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header Profil Admin Operasional
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
                    child: Center(
                      child: Text(
                        _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'O',
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
                          child: Text('Divisi Operasional', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Menu Navigasi Master & Pengaturan Saja (Tidak Redundan!)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                    child: Text(
                      'MASTER DATA & FASILITAS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF76777B),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    icon: Icons.local_parking_rounded,
                    label: 'Kelola Parkir dan Aturan Tarif',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageParkingScreen()));
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
}

// ⛰️ CUSTOM PAINTER CHART GUNUNG DENGAN TITIK KURSOR INSPEKSI SILANG (CROSSHAIR)
class _MountainChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> pointValues;
  final List<String> pointDates;
  final List<String> xLabels;
  final int? inspectedIndex;
  final int activePointCount;
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;

  _MountainChartPainter({
    required this.data,
    required this.pointValues,
    required this.pointDates,
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

    const double marginHorizontal = 24.0;
    final double chartWidth = size.width - (marginHorizontal * 2);
    final double stepX = chartWidth / (data.length - 1);
    const double topPadding = 24.0;
    final double baselineY = size.height - 36.0;
    final double availableHeight = baselineY - topPadding;

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = marginHorizontal + (i * stepX);
      final double y = topPadding + (1.0 - data[i].clamp(0.0, 1.0)) * availableHeight;
      points.add(Offset(x, y));
    }

    final int effectiveActive = activePointCount.clamp(1, points.length);

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB).withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    for (final double ratio in [0.25, 0.50, 0.75]) {
      final double yGrid = topPadding + ratio * availableHeight;
      _drawDashedLine(
        canvas,
        Offset(marginHorizontal - 15, yGrid),
        Offset(size.width - marginHorizontal + 15, yGrid),
        gridPaint,
        dashWidth: 4,
        dashSpace: 4,
      );
    }

    final baselinePaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(marginHorizontal - 15, baselineY),
      Offset(size.width - marginHorizontal + 15, baselineY),
      baselinePaint,
    );

    // 🌊 Fill Gunung Hijau (Hanya digambar sampai minggu aktif/tersedia)
    final path = Path();
    path.moveTo(points.first.dx, baselineY);
    path.lineTo(points.first.dx, points.first.dy);

    const double tension = 0.22;
    for (int i = 0; i < effectiveActive - 1; i++) {
      final Offset p0 = i > 0 ? points[i - 1] : points[0];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i < effectiveActive - 2 ? points[i + 2] : p2;

      final Offset cp1 = Offset(p1.dx + (p2.dx - p0.dx) * tension, p1.dy + (p2.dy - p0.dy) * tension);
      final Offset cp2 = Offset(p2.dx - (p3.dx - p1.dx) * tension, p2.dy - (p3.dy - p1.dy) * tension);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    path.lineTo(points[effectiveActive - 1].dx, baselineY);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, availableHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // 〰️ Garis Hijau Utama (Hanya digambar sampai minggu aktif/tersedia)
    final strokePath = Path();
    strokePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < effectiveActive - 1; i++) {
      final Offset p0 = i > 0 ? points[i - 1] : points[0];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i < effectiveActive - 2 ? points[i + 2] : p2;

      final Offset cp1 = Offset(p1.dx + (p2.dx - p0.dx) * tension, p1.dy + (p2.dy - p0.dy) * tension);
      final Offset cp2 = Offset(p2.dx - (p3.dx - p1.dx) * tension, p2.dy - (p3.dy - p1.dy) * tension);

      strokePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(strokePath, linePaint);

    // Garis putus-putus tipis untuk minggu yang belum berjalan (misal minggu 4)
    if (effectiveActive < points.length) {
      final futurePaint = Paint()
        ..color = const Color(0xFFD1D5DB)
        ..strokeWidth = 1.4;
      for (int i = effectiveActive - 1; i < points.length - 1; i++) {
        _drawDashedLine(canvas, points[i], points[i + 1], futurePaint, dashWidth: 4, dashSpace: 4);
      }
      for (int i = effectiveActive; i < points.length; i++) {
        canvas.drawCircle(points[i], 3, Paint()..color = const Color(0xFFD1D5DB));
      }
    }

    // Label Sumbu X (Minggu 1, Minggu 2, Minggu 3, Minggu 4)
    for (int i = 0; i < xLabels.length && i < points.length; i++) {
      final bool isSelected = inspectedIndex == i;
      final bool isFuture = i >= effectiveActive;

      final labelSpan = TextSpan(
        text: xLabels[i],
        style: TextStyle(
          fontSize: isSelected ? 10 : 9,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? lineColor
              : isFuture
                  ? const Color(0xFFB0B0B0)
                  : const Color(0xFF76777B),
        ),
      );
      final labelTp = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final double labelX = points[i].dx - (labelTp.width / 2);
      final double labelY = baselineY + 8.0;

      if (isSelected) {
        final pillRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(labelX - 4, labelY - 2, labelTp.width + 8, labelTp.height + 4),
          const Radius.circular(4),
        );
        canvas.drawRRect(pillRect, Paint()..color = lineColor.withValues(alpha: 0.15));
      }

      labelTp.paint(canvas, Offset(labelX, labelY));
    }

    // Tampilan Titik Crosshair saat Inspeksi / Klik Minggu
    if (inspectedIndex != null && inspectedIndex! >= 0 && inspectedIndex! < effectiveActive) {
      final Offset inspectPt = points[inspectedIndex!];

      final crosshairVerticalPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.2;
      _drawDashedLine(
        canvas,
        Offset(inspectPt.dx, topPadding - 10),
        Offset(inspectPt.dx, baselineY),
        crosshairVerticalPaint,
        dashWidth: 3,
        dashSpace: 3,
      );

      final crosshairHorizontalPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.35)
        ..strokeWidth = 1.0;
      _drawDashedLine(
        canvas,
        Offset(marginHorizontal - 15, inspectPt.dy),
        Offset(size.width - marginHorizontal + 15, inspectPt.dy),
        crosshairHorizontalPaint,
        dashWidth: 3,
        dashSpace: 3,
      );

      canvas.drawCircle(
        inspectPt,
        9,
        Paint()..color = lineColor.withValues(alpha: 0.25),
      );
      canvas.drawCircle(
        inspectPt,
        5,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        inspectPt,
        2.5,
        Paint()..color = Colors.white,
      );

      if (inspectedIndex! < pointDates.length && inspectedIndex! < pointValues.length) {
        final tooltipSpan = TextSpan(
          children: [
            TextSpan(
              text: '${pointDates[inspectedIndex!]}  •  ',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD1D5DB),
              ),
            ),
            TextSpan(
              text: pointValues[inspectedIndex!],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        );
        final tp = TextPainter(
          text: tooltipSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        const double padH = 8.0;
        const double padV = 5.0;
        final double boxW = tp.width + (padH * 2);
        final double boxH = tp.height + (padV * 2);

        double boxX = inspectPt.dx - (boxW / 2);
        boxX = boxX.clamp(6.0, size.width - boxW - 6.0);

        double boxY = inspectPt.dy - boxH - 10.0;
        bool isAbove = true;
        if (boxY < 2.0) {
          boxY = inspectPt.dy + 12.0;
          isAbove = false;
        }

        final boxRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(boxX, boxY, boxW, boxH),
          const Radius.circular(6),
        );

        canvas.drawRRect(
          boxRect,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );

        canvas.drawRRect(
          boxRect,
          Paint()..color = const Color(0xFF1C1D1F),
        );

        canvas.drawRRect(
          boxRect,
          Paint()
            ..color = lineColor.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );

        final pointerPath = Path();
        final double targetX = inspectPt.dx.clamp(boxX + 6.0, boxX + boxW - 6.0);
        if (isAbove) {
          pointerPath.moveTo(targetX - 4, boxY + boxH);
          pointerPath.lineTo(targetX + 4, boxY + boxH);
          pointerPath.lineTo(targetX, boxY + boxH + 4);
        } else {
          pointerPath.moveTo(targetX - 4, boxY);
          pointerPath.lineTo(targetX + 4, boxY);
          pointerPath.lineTo(targetX, boxY - 4);
        }
        pointerPath.close();
        canvas.drawPath(pointerPath, Paint()..color = const Color(0xFF1C1D1F));

        tp.paint(canvas, Offset(boxX + padH, boxY + padV));
      }
    } else {
      // Titik puncak (Peak) dalam rentang minggu yang aktif
      int peakIndex = 0;
      double maxVal = data[0];
      for (int i = 1; i < effectiveActive; i++) {
        if (data[i] > maxVal) {
          maxVal = data[i];
          peakIndex = i;
        }
      }
      if (peakIndex != effectiveActive - 1) {
        final peakPoint = points[peakIndex];
        canvas.drawCircle(peakPoint, 7, Paint()..color = lineColor.withValues(alpha: 0.2));
        canvas.drawCircle(peakPoint, 4, Paint()..color = lineColor);
        canvas.drawCircle(peakPoint, 2, Paint()..color = Colors.white);
      }

      // Titik terbaru (Live dot) pada minggu aktif terakhir
      final livePoint = points[effectiveActive - 1];
      canvas.drawCircle(livePoint, 8, Paint()..color = lineColor.withValues(alpha: 0.3));
      canvas.drawCircle(livePoint, 4.5, Paint()..color = lineColor);
      canvas.drawCircle(livePoint, 2.2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _MountainChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.inspectedIndex != inspectedIndex ||
        oldDelegate.activePointCount != activePointCount;
  }
}
