import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_operations_notifications_screen.dart';
import 'admin_locations_screen.dart';
import 'admin_slot_management_screen.dart';
import 'admin_active_users_screen.dart';
import 'admin_bookings_screen.dart';
import '../../sitemap_screen.dart';

class AdminOperationsDashboardScreen extends StatefulWidget {
  const AdminOperationsDashboardScreen({super.key});

  @override
  State<AdminOperationsDashboardScreen> createState() => _AdminOperationsDashboardScreenState();
}

class _AdminOperationsDashboardScreenState extends State<AdminOperationsDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentTabIndex = 0;
  int _selectedChartCityIndex = 0;
  String _selectedStatusFilter = 'Semua';

  final List<Map<String, dynamic>> _cityDensityList = [
    {
      'city': 'Jakarta',
      'province': 'DKI Jakarta',
      'facilities': '2 Lokasi (Central Park & GI)',
      'facilityCount': 2,
      'total': 750,
      'occupied': 655,
      'status': 'Kritis',
      'statusColor': const Color(0xFFD94B4B),
      'mobil': 520,
      'motor': 100,
      'ev': 35,
    },
    {
      'city': 'Bandung',
      'province': 'Jawa Barat',
      'facilities': '1 Lokasi (Paris Van Java)',
      'facilityCount': 1,
      'total': 280,
      'occupied': 210,
      'status': 'Padat',
      'statusColor': const Color(0xFFE07A5F),
      'mobil': 145,
      'motor': 50,
      'ev': 15,
    },
    {
      'city': 'Surabaya',
      'province': 'Jawa Timur',
      'facilities': '1 Lokasi (Galaxy Mall)',
      'facilityCount': 1,
      'total': 350,
      'occupied': 180,
      'status': 'Normal',
      'statusColor': const Color(0xFF17A18A),
      'mobil': 130,
      'motor': 40,
      'ev': 10,
    },
    {
      'city': 'Yogyakarta',
      'province': 'D.I. Yogyakarta',
      'facilities': '1 Lokasi (Malioboro Mall)',
      'facilityCount': 1,
      'total': 200,
      'occupied': 102,
      'status': 'Normal',
      'statusColor': const Color(0xFF17A18A),
      'mobil': 65,
      'motor': 30,
      'ev': 7,
    },
  ];

  final List<Map<String, dynamic>> _operationalLocations = [
    {
      'id': 'LOC-001',
      'name': 'Central Park Mall',
      'city': 'Jakarta Barat',
      'zone': 'Basement B1 - B3',
      'total': 300,
      'occupied': 240,
      'status': 'Padat',
      'statusColor': const Color(0xFFE07A5F),
      'mobil': 190,
      'motor': 35,
      'ev': 15,
    },
    {
      'id': 'LOC-002',
      'name': 'Malioboro Mall',
      'city': 'Yogyakarta',
      'zone': 'Area Outdoor & B1',
      'total': 200,
      'occupied': 102,
      'status': 'Normal',
      'statusColor': const Color(0xFF17A18A),
      'mobil': 65,
      'motor': 30,
      'ev': 7,
    },
    {
      'id': 'LOC-003',
      'name': 'Grand Indonesia',
      'city': 'Jakarta Pusat',
      'zone': 'East & West Mall (B1 - B4)',
      'total': 450,
      'occupied': 415,
      'status': 'Kritis',
      'statusColor': const Color(0xFFD94B4B),
      'mobil': 330,
      'motor': 65,
      'ev': 20,
    },
    {
      'id': 'LOC-004',
      'name': 'Galaxy Mall Surabaya',
      'city': 'Surabaya',
      'zone': 'Mall 1 - 3 (Basement)',
      'total': 350,
      'occupied': 180,
      'status': 'Normal',
      'statusColor': const Color(0xFF17A18A),
      'mobil': 130,
      'motor': 40,
      'ev': 10,
    },
  ];

  int get _totalParkedVehicles {
    int sum = 0;
    for (var l in _operationalLocations) {
      sum += (l['occupied'] as int);
    }
    return sum;
  }

  int get _totalCapacity {
    int sum = 0;
    for (var l in _operationalLocations) {
      sum += (l['total'] as int);
    }
    return sum;
  }

  int get _totalAvailableSlots => _totalCapacity - _totalParkedVehicles;

  double get _occupancyPercentage => _totalCapacity > 0 ? (_totalParkedVehicles / _totalCapacity) * 100 : 0.0;

  List<Map<String, dynamic>> get _filteredLocations {
    if (_selectedStatusFilter == 'Semua') return _operationalLocations;
    return _operationalLocations.where((loc) => loc['status'] == _selectedStatusFilter).toList();
  }

  int _activitySubTab = 0; // 0 = Sesi Aktif, 1 = Reservasi

  final List<Map<String, dynamic>> _liveSessions = [
    {
      'id': 'SES-9901',
      'plate': 'B 1234 SKP',
      'user': 'Nanda Setiawan',
      'type': 'Mobil',
      'vehicle': 'Honda CR-V Hitam',
      'location': 'Central Park Mall',
      'slot': 'B2 / A-01',
      'checkIn': '10:30 WIB',
      'duration': '2j 15m',
      'fee': 'Rp 13.000',
      'isOverstay': false,
      'isEv': false,
    },
    {
      'id': 'SES-9902',
      'plate': 'B 5532 PLM',
      'user': 'Rafi Maulana',
      'type': 'Mobil',
      'vehicle': 'Toyota Fortuner Putih',
      'location': 'Central Park Mall',
      'slot': 'B2 / C-01',
      'checkIn': '08:00 WIB',
      'duration': '4j 45m',
      'fee': 'Rp 29.000',
      'isOverstay': true,
      'overstayDuration': '45 mnt',
      'isEv': false,
    },
    {
      'id': 'SES-9903',
      'plate': 'B 1111 ION',
      'user': 'Dewi Lestari',
      'type': 'EV Mobil',
      'vehicle': 'Hyundai Ioniq 5',
      'location': 'Central Park Mall',
      'slot': 'B2 / B-01 (EV Fast)',
      'checkIn': '11:15 WIB',
      'duration': '1j 30m',
      'fee': 'Rp 22.500',
      'isOverstay': false,
      'isEv': true,
    },
    {
      'id': 'SES-9904',
      'plate': 'D 8888 ABC',
      'user': 'Fajar Ramadhan',
      'type': 'Motor',
      'vehicle': 'Yamaha NMAX Hitam',
      'location': 'Paris Van Java',
      'slot': 'GF / M-05',
      'checkIn': '12:00 WIB',
      'duration': '0j 45m',
      'fee': 'Rp 4.000',
      'isOverstay': false,
      'isEv': false,
    },
    {
      'id': 'SES-9905',
      'plate': 'L 7777 WRT',
      'user': 'Siti Rahma',
      'type': 'Mobil',
      'vehicle': 'Toyota Innova Zenix',
      'location': 'Grand Indonesia',
      'slot': 'B1 / VIP-03',
      'checkIn': '09:40 WIB',
      'duration': '3j 05m',
      'fee': 'Rp 18.000',
      'isOverstay': false,
      'isEv': false,
    },
  ];

  final List<Map<String, dynamic>> _liveBookings = [
    {
      'id': 'BK-8821',
      'code': 'PRK-8821',
      'name': 'Rafi Maulana',
      'phone': '0812-3456-7890',
      'location': 'Central Park Mall',
      'slot': 'B2 / A-03',
      'vehicleType': 'Mobil',
      'plate': 'B 1234 ABC',
      'time': '13:00 - 15:00 WIB',
      'status': 'Dikonfirmasi',
    },
    {
      'id': 'BK-8822',
      'code': 'PRK-8822',
      'name': 'Siti Rahma',
      'phone': '0813-9876-5432',
      'location': 'Grand Indonesia',
      'slot': 'B1 / VIP-01',
      'vehicleType': 'EV Mobil',
      'plate': 'B 9999 EV',
      'time': '14:30 - 17:30 WIB',
      'status': 'Menunggu',
    },
    {
      'id': 'BK-8823',
      'code': 'PRK-8823',
      'name': 'Budi Santoso',
      'phone': '0857-1122-3344',
      'location': 'Paris Van Java',
      'slot': 'Lt 1 / C-12',
      'vehicleType': 'Motor',
      'plate': 'D 4321 XYZ',
      'time': '15:00 - 18:00 WIB',
      'status': 'Dikonfirmasi',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFFF3F4F6),
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

  // ==================== TAB 0: LOKASI & LAPANGAN ====================
  Widget _buildTabLocations(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 4 KPI Real-Time
        _buildRealtimeKpiSection(),
        const SizedBox(height: 18),

        // Daftar Fasilitas Lapangan
        _buildFacilityListSection(context),
        const SizedBox(height: 24),
      ],
    );
  }

  // ==================== TAB 1: GRAFIK & ANALITIK ====================
  Widget _buildTabAnalytics(BuildContext context) {
    int totalMobil = 0;
    int totalMotor = 0;
    int totalEv = 0;
    for (var city in _cityDensityList) {
      totalMobil += city['mobil'] as int;
      totalMotor += city['motor'] as int;
      totalEv += city['ev'] as int;
    }

    return ListView(
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

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    Expanded(flex: totalMobil, child: Container(height: 12, color: const Color(0xFF114177))),
                    Expanded(flex: totalMotor, child: Container(height: 12, color: const Color(0xFF17A18A))),
                    Expanded(flex: totalEv, child: Container(height: 12, color: const Color(0xFFE07A5F))),
                  ],
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
  // ==================== TAB 2: AKTIVITAS LAPANGAN REAL-TIME ====================
  Widget _buildTabActivity(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
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
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => _activitySubTab == 0 ? const ActiveUsersScreen() : const AdminBookingsScreen()),
                );
              },
              icon: const Icon(Icons.fullscreen_rounded, size: 15, color: Color(0xFF114177)),
              label: Text(
                _activitySubTab == 0 ? 'Monitor Lengkap' : 'Booking Lengkap',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _activitySubTab == 0 ? 'Ketuk kartu untuk monitor & kendali lengkap' : 'Ketuk reservasi untuk manajemen booking',
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)),
            ),
            Icon(Icons.touch_app_rounded, size: 14, color: const Color(0xFF114177).withValues(alpha: 0.6)),
          ],
        ),
        const SizedBox(height: 10),

        if (_activitySubTab == 0) ...[
          // Sesi Kendaraan Aktif
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveUsersScreen()),
                    );
                  },
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminBookingsScreen()),
                    );
                  },
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
    );
  }

  // ==================== WIDGETS: KPI METRICS (4 CARDS) ====================
  Widget _buildRealtimeKpiSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Kendaraan Parkir',
                value: '$_totalParkedVehicles Unit',
                subtitle: 'Total 4 Titik Pantauan',
                icon: Icons.directions_car,
                accentColor: const Color(0xFF17A18A),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Sisa Slot Kosong',
                value: '$_totalAvailableSlots Slot',
                subtitle: 'Siap Digunakan',
                icon: Icons.local_parking_rounded,
                accentColor: const Color(0xFF114177),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Rata-rata Okupansi',
                value: '${_occupancyPercentage.toStringAsFixed(1)}%',
                subtitle: 'Kapasitas Terisi',
                icon: Icons.pie_chart_outline_rounded,
                accentColor: const Color(0xFFD97706),
                onTap: () => setState(() => _currentTabIndex = 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Overstay Alert',
                value: '3 Kendaraan',
                subtitle: 'Melebihi Kuota Waktu',
                icon: Icons.warning_amber_rounded,
                accentColor: const Color(0xFFD94B4B),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: const Color(0xFF76777B).withValues(alpha: 0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))),
          ],
        ),
      ),
    );
  }



  // ==================== WIDGETS: KEPADATAN KOTA INTERAKTIF ====================
  Widget _buildInteractiveCapacitySection() {
    final selectedCity = _cityDensityList[_selectedChartCityIndex];

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
              final total = city['total'] as int;
              final occupied = city['occupied'] as int;
              final ratio = (occupied / total).clamp(0.0, 1.0);
              final isSelected = i == _selectedChartCityIndex;
              final statusColor = city['statusColor'] as Color;

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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen())),
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

        // Kartu-Kartu Lokasi
        ..._filteredLocations.map((loc) {
          final total = loc['total'] as int;
          final occupied = loc['occupied'] as int;
          final available = total - occupied;
          final pct = (occupied / total).clamp(0.0, 1.0);
          final statusColor = loc['statusColor'] as Color;

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
                          Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          Text('${loc['city']} • ${loc['zone']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
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
                        loc['status'],
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
                Row(
                  children: [
                    Text('Armada: ', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                    Text('🚗 ${loc['mobil']} Mobil  ', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                    Text('🏍️ ${loc['motor']} Motor  ', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                    Text('⚡ ${loc['ev']} EV', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFE07A5F))),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),

                // Tombol Denah Slot Lapangan (Tunggal & Tidak Redundan)
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
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
                    child: const Center(
                      child: Text('R', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rina Wijaya', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Admin Operasional Lapangan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
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
                    icon: Icons.business_outlined,
                    label: 'Kelola Lokasi Parkir',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen()));
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
