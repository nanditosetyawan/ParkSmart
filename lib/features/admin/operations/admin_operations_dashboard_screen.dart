import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_operations_notifications_screen.dart';
import 'admin_locations_screen.dart';
import 'admin_slot_management_screen.dart';
import 'admin_active_users_screen.dart';
import 'admin_bookings_screen.dart';
import 'manage_parking_screen.dart';
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
  String _selectedParkedMonth = 'Okt 2026';
  final List<String> _parkedMonths = [
    'Okt 2026',
    'Sep 2026',
    'Agu 2026',
    'Jul 2026',
    'Jun 2026',
    'Mei 2026',
  ];

  // 📈 Kursor Crosshair Inspeksi Chart Gunung Kendaraan Parkir
  int? _inspectedParkedPointIndex;

  void _onParkedChartTouch(double touchX, double canvasWidth, int pointCount) {
    if (pointCount <= 1 || canvasWidth <= 0) return;
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    if (chartWidth <= 0) return;

    final double stepX = chartWidth / (pointCount - 1);
    final double relativeX = (touchX - marginHorizontal).clamp(0.0, chartWidth);
    final int closestIndex = (relativeX / stepX).round().clamp(0, pointCount - 1);

    if (_inspectedParkedPointIndex != closestIndex) {
      setState(() {
        _inspectedParkedPointIndex = closestIndex;
      });
    }
  }

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
      'phone': '0812-3456-7890',
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
      'phone': '0856-7890-1234',
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
      'phone': '0878-1234-5678',
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
      'phone': '0896-2345-6789',
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
      'phone': '0813-9876-5432',
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
      'id': 'BKG-2024-002',
      'code': 'PRK-8821',
      'name': 'Rafi Maulana',
      'phone': '0812-3456-7890',
      'location': 'Central Park Mall',
      'slot': 'B2 / A-03',
      'floor': 'B2',
      'vehicleType': 'Mobil',
      'plate': 'B 1234 ABC',
      'time': '13:00 - 15:00 WIB',
      'duration': '2 jam',
      'status': 'Dikonfirmasi',
      'totalPrice': 'Rp 28.000',
      'paymentStatus': 'Dibayar',
    },
    {
      'id': 'BKG-2024-003',
      'code': 'PRK-8822',
      'name': 'Siti Rahma',
      'phone': '0813-9876-5432',
      'location': 'Grand Indonesia',
      'slot': 'B1 / VIP-01',
      'floor': 'B1',
      'vehicleType': 'EV Mobil',
      'plate': 'B 9999 EV',
      'time': '14:30 - 17:30 WIB',
      'duration': '3 jam',
      'status': 'Menunggu',
      'totalPrice': 'Rp 35.000',
      'paymentStatus': 'Pending',
    },
    {
      'id': 'BKG-2024-004',
      'code': 'PRK-8823',
      'name': 'Budi Santoso',
      'phone': '0857-1122-3344',
      'location': 'Paris Van Java',
      'slot': 'Lt 1 / C-12',
      'floor': 'Lantai 1',
      'vehicleType': 'Motor',
      'plate': 'D 4321 XYZ',
      'time': '15:00 - 18:00 WIB',
      'duration': '3 jam',
      'status': 'Dikonfirmasi',
      'totalPrice': 'Rp 12.000',
      'paymentStatus': 'Dibayar',
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
    return Column(
      children: [
        // 1. Chart Gunung Kendaraan Parkir 937 Unit (Bulan Ini)
        _buildParkedVehiclesMountainChart(),
        const SizedBox(height: 12),
        // 2. Overstay Alert Card Menarik di bawahnya
        _buildOverstayAlertCard(),
      ],
    );
  }

  // ⛰️ KARTU CHART GUNUNG KENDARAAN PARKIR (TEKAN & GESER TITIKNYA)
  Widget _buildParkedVehiclesMountainChart() {
    const Color accentColor = Color(0xFF17A18A); // Emerald green

    final Map<String, Map<String, dynamic>> monthDataMap = {
      'Okt 2026': {
        'total': '$_totalParkedVehicles Unit',
        'subtitle': 'Hari Ini (31 Okt)',
        'chartData': [0.38, 0.48, 0.62, 0.82, 0.76, 0.88, 0.96],
        'pointValues': ['720 Unit', '765 Unit', '815 Unit', '890 Unit', '860 Unit', '910 Unit', '$_totalParkedVehicles Unit'],
        'pointDates': ['1 Okt', '6 Okt', '11 Okt', '16 Okt', '21 Okt', '26 Okt', 'Hari Ini (31 Okt)'],
        'xLabels': ['1 Okt', '6 Okt', '11 Okt', '16 Okt', '21 Okt', '26 Okt', 'Hari Ini'],
        'trend': '+14.8% Akumulasi Bulan Ini',
      },
      'Sep 2026': {
        'total': '885 Unit',
        'subtitle': 'Akhir Bulan (30 Sep)',
        'chartData': [0.32, 0.42, 0.55, 0.70, 0.68, 0.80, 0.88],
        'pointValues': ['680 Unit', '710 Unit', '750 Unit', '820 Unit', '805 Unit', '860 Unit', '885 Unit'],
        'pointDates': ['1 Sep', '6 Sep', '11 Sep', '16 Sep', '21 Sep', '26 Sep', '30 Sep'],
        'xLabels': ['1 Sep', '6 Sep', '11 Sep', '16 Sep', '21 Sep', '26 Sep', '30 Sep'],
        'trend': '+11.2% Akumulasi Sep',
      },
      'Agu 2026': {
        'total': '840 Unit',
        'subtitle': 'Akhir Bulan (31 Agu)',
        'chartData': [0.28, 0.38, 0.50, 0.65, 0.60, 0.75, 0.84],
        'pointValues': ['620 Unit', '660 Unit', '710 Unit', '780 Unit', '760 Unit', '815 Unit', '840 Unit'],
        'pointDates': ['1 Agu', '6 Agu', '11 Agu', '16 Agu', '21 Agu', '26 Agu', '31 Agu'],
        'xLabels': ['1 Agu', '6 Agu', '11 Agu', '16 Agu', '21 Agu', '26 Agu', '31 Agu'],
        'trend': '+8.5% Akumulasi Agu',
      },
      'Jul 2026': {
        'total': '820 Unit',
        'subtitle': 'Akhir Bulan (31 Jul)',
        'chartData': [0.30, 0.40, 0.48, 0.62, 0.58, 0.72, 0.82],
        'pointValues': ['640 Unit', '680 Unit', '720 Unit', '760 Unit', '745 Unit', '790 Unit', '820 Unit'],
        'pointDates': ['1 Jul', '6 Jul', '11 Jul', '16 Jul', '21 Jul', '26 Jul', '31 Jul'],
        'xLabels': ['1 Jul', '6 Jul', '11 Jul', '16 Jul', '21 Jul', '26 Jul', '31 Jul'],
        'trend': '+9.1% Akumulasi Jul',
      },
      'Jun 2026': {
        'total': '795 Unit',
        'subtitle': 'Akhir Bulan (30 Jun)',
        'chartData': [0.25, 0.35, 0.45, 0.58, 0.55, 0.68, 0.78],
        'pointValues': ['610 Unit', '650 Unit', '695 Unit', '740 Unit', '730 Unit', '770 Unit', '795 Unit'],
        'pointDates': ['1 Jun', '6 Jun', '11 Jun', '16 Jun', '21 Jun', '26 Jun', '30 Jun'],
        'xLabels': ['1 Jun', '6 Jun', '11 Jun', '16 Jun', '21 Jun', '26 Jun', '30 Jun'],
        'trend': '+7.3% Akumulasi Jun',
      },
      'Mei 2026': {
        'total': '760 Unit',
        'subtitle': 'Akhir Bulan (31 Mei)',
        'chartData': [0.22, 0.30, 0.40, 0.52, 0.50, 0.64, 0.74],
        'pointValues': ['580 Unit', '620 Unit', '660 Unit', '705 Unit', '690 Unit', '735 Unit', '760 Unit'],
        'pointDates': ['1 Mei', '6 Mei', '11 Mei', '16 Mei', '21 Mei', '26 Mei', '31 Mei'],
        'xLabels': ['1 Mei', '6 Mei', '11 Mei', '16 Mei', '21 Mei', '26 Mei', '31 Mei'],
        'trend': '+6.8% Akumulasi Mei',
      },
    };

    final activeData = monthDataMap[_selectedParkedMonth] ?? monthDataMap['Okt 2026']!;
    final List<double> chartData = List<double>.from(activeData['chartData']);
    final List<String> pointValues = List<String>.from(activeData['pointValues']);
    final List<String> pointDates = List<String>.from(activeData['pointDates']);
    final List<String> xLabels = List<String>.from(activeData['xLabels']);
    final int pointCount = chartData.length;

    final bool isInspecting = _inspectedParkedPointIndex != null &&
        _inspectedParkedPointIndex! >= 0 &&
        _inspectedParkedPointIndex! < pointCount;

    final String displayValue = isInspecting
        ? pointValues[_inspectedParkedPointIndex!]
        : (activeData['total'] as String);

    final String displaySubtitle = isInspecting
        ? pointDates[_inspectedParkedPointIndex!]
        : (activeData['subtitle'] as String);

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
              // Dropdown Pilihan Bulan (Background Putih + Outline Tipis Hitam)
              PopupMenuButton<String>(
                initialValue: _selectedParkedMonth,
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
                itemBuilder: (context) => _parkedMonths.map((m) {
                  final isSelected = m == _selectedParkedMonth;
                  final label = m == 'Okt 2026' ? 'Bulan Ini ($m)' : m;
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
                        _selectedParkedMonth == 'Okt 2026'
                            ? 'Bulan Ini ($_selectedParkedMonth)'
                            : _selectedParkedMonth,
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

          // Nilai Angka Besar + Status Keterangan
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
              if (isInspecting)
                InkWell(
                  onTap: () {
                    setState(() => _inspectedParkedPointIndex = null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF71717A),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    activeData['trend'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF17A18A),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ⛰️ Chart Gunung Area (Tekan & Geser Titik Crosshair Langsung)
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
                      _onParkedChartTouch(details.localPosition.dx, canvasWidth, pointCount);
                    },
                    onPanStart: (details) {
                      _onParkedChartTouch(details.localPosition.dx, canvasWidth, pointCount);
                    },
                    onPanUpdate: (details) {
                      _onParkedChartTouch(details.localPosition.dx, canvasWidth, pointCount);
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
                          inspectedIndex: _inspectedParkedPointIndex,
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

  // 🚨 KARTU OVERSTAY ALERT MENARIK & EYE-CATCHING DI BAWAH CHART
  Widget _buildOverstayAlertCard() {
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
                            '3 KENDARAAN',
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
                      '3 kendaraan melebihi batas kuota waktu parkir maksimal di lapangan',
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
  final Color lineColor;
  final Color gradientStart;
  final Color gradientEnd;

  _MountainChartPainter({
    required this.data,
    required this.pointValues,
    required this.pointDates,
    required this.xLabels,
    this.inspectedIndex,
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

    final path = Path();
    path.moveTo(points.first.dx, baselineY);
    path.lineTo(points.first.dx, points.first.dy);

    const double tension = 0.22;
    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = i > 0 ? points[i - 1] : points[0];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i < points.length - 2 ? points[i + 2] : p2;

      final Offset cp1 = Offset(p1.dx + (p2.dx - p0.dx) * tension, p1.dy + (p2.dy - p0.dy) * tension);
      final Offset cp2 = Offset(p2.dx - (p3.dx - p1.dx) * tension, p2.dy - (p3.dy - p1.dy) * tension);

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    path.lineTo(points.last.dx, baselineY);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, availableHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    final strokePath = Path();
    strokePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = i > 0 ? points[i - 1] : points[0];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i < points.length - 2 ? points[i + 2] : p2;

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

    final int labelStep = xLabels.length > 8 ? (xLabels.length / 5).ceil() : 1;
    for (int i = 0; i < xLabels.length && i < points.length; i++) {
      final bool isSelected = inspectedIndex == i;
      final bool shouldDraw = isSelected || (i % labelStep == 0) || (i == xLabels.length - 1);
      if (!shouldDraw) continue;

      final labelSpan = TextSpan(
        text: xLabels[i],
        style: TextStyle(
          fontSize: isSelected ? 10 : 9,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? lineColor : const Color(0xFF76777B),
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

    if (inspectedIndex != null && inspectedIndex! >= 0 && inspectedIndex! < points.length) {
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
      int peakIndex = 0;
      double maxVal = data[0];
      for (int i = 1; i < data.length; i++) {
        if (data[i] > maxVal) {
          maxVal = data[i];
          peakIndex = i;
        }
      }
      final peakPoint = points[peakIndex];
      canvas.drawCircle(peakPoint, 7, Paint()..color = lineColor.withValues(alpha: 0.2));
      canvas.drawCircle(peakPoint, 4, Paint()..color = lineColor);
      canvas.drawCircle(peakPoint, 2, Paint()..color = Colors.white);

      final livePoint = points.last;
      canvas.drawCircle(livePoint, 8, Paint()..color = lineColor.withValues(alpha: 0.3));
      canvas.drawCircle(livePoint, 4.5, Paint()..color = lineColor);
      canvas.drawCircle(livePoint, 2.2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _MountainChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.inspectedIndex != inspectedIndex;
  }
}
