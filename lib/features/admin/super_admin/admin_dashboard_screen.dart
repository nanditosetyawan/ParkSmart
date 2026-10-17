import 'dart:math' as math;
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screens for Super Admin Core Governance
import 'admin_user_management_screen.dart';
import 'admin_app_settings_screen.dart';
import 'admin_ai_config_screen.dart';
import '../cs_kyc/admin_notifications_screen.dart';
import '../../../core/services/maintenance_service.dart';

// Screens for Emergency Override Access to other divisions
import '../operations/admin_operations_dashboard_screen.dart';
import '../operations/manage_parking_screen.dart';
import '../operations/admin_locations_screen.dart';
import '../operations/admin_cities_screen.dart';
import '../operations/admin_slot_management_screen.dart';
import '../operations/admin_active_users_screen.dart';

import '../finance/admin_finance_dashboard_screen.dart';
import '../finance/revenue_screen.dart';
import '../finance/admin_pricing_screen.dart';
import '../finance/admin_transactions_screen.dart';
import '../finance/admin_wallet_screen.dart';
import '../finance/admin_bookings_screen.dart';

import '../cs_kyc/admin_cskyc_dashboard_screen.dart';
import '../cs_kyc/admin_kyc_screen.dart';
import '../cs_kyc/admin_customer_profiles_screen.dart';
import '../cs_kyc/manage_users_screen.dart';
import '../cs_kyc/admin_feedback_screen.dart';
import '../cs_kyc/admin_arcade_screen.dart';

import '../../sitemap_screen.dart';

typedef DashboardScreen = AdminDashboardScreen;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Selected Read-Only Divisional Metric & Period for Mountain Chart
  int _selectedMetricIndex = 0; // 0: Pendapatan, 1: Booking, 2: Customer
  int _selectedPeriodIndex = 2; // 0: 1 Hari, 1: 1 Minggu, 2: 1 Bulan, 3: 1 Tahun
  final List<String> _periodOptions = ['1 Hari', '1 Minggu', '1 Bulan', '1 Tahun'];

  // 📈 Kursor Crosshair Inspection State
  int? _inspectedPointIndex;

  @override
  void initState() {
    super.initState();
    _isMaintenanceActive = MaintenanceService.instance.isGlobalMaintenance;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onChartTouch(double localX, double canvasWidth, int pointCount) {
    if (pointCount <= 1) return;
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    final double stepX = chartWidth / (pointCount - 1);

    final double relativeX = localX - marginHorizontal;
    final int closestIndex = (relativeX / stepX).round().clamp(0, pointCount - 1);

    if (_inspectedPointIndex != closestIndex) {
      setState(() {
        _inspectedPointIndex = closestIndex;
      });
    }
  }

  // Emergency Maintenance Mode quick toggle state
  bool _isMaintenanceActive = false;

  // Divisional Read-Only Metrics Data (Dengan opsi 1 Hari, 1 Minggu, 1 Bulan, 1 Tahun)
  final List<Map<String, dynamic>> _divisionalMetrics = [
    {
      'title': 'Pendapatan Global',
      'division': 'Divisi Finansial',
      'accentColor': const Color(0xFF17A18A),
      'icon': Icons.trending_up,
      'periods': [
        // 0: 1 Hari
        {
          'value': 'Rp 3.850.000',
          'growth': '+18%',
          'chartData': [0.15, 0.28, 0.42, 0.65, 0.58, 0.82, 0.95],
          'pointValues': ['Rp 320 Rb', 'Rp 650 Rb', 'Rp 1.25 Jt', 'Rp 2.10 Jt', 'Rp 2.55 Jt', 'Rp 3.20 Jt', 'Rp 3.85 Jt'],
          'pointDates': ['00:00 WIB', '04:00 WIB', '08:00 WIB', '12:00 WIB', '16:00 WIB', '20:00 WIB', '23:59 WIB'],
          'xLabels': ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'],
        },
        // 1: 1 Minggu
        {
          'value': 'Rp 26.400.000',
          'growth': '+12%',
          'chartData': [0.35, 0.48, 0.42, 0.68, 0.75, 0.92, 0.86],
          'pointValues': ['Rp 2.8 Jt', 'Rp 3.2 Jt', 'Rp 3.0 Jt', 'Rp 4.1 Jt', 'Rp 4.5 Jt', 'Rp 5.1 Jt', 'Rp 3.7 Jt'],
          'pointDates': ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
          'xLabels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
        },
        // 2: 1 Bulan
        {
          'value': 'Rp 48.500.000',
          'growth': '+14%',
          'chartData': [0.25, 0.32, 0.28, 0.45, 0.38, 0.52, 0.60, 0.55, 0.72, 0.68, 0.85, 0.78, 0.95, 0.82, 0.90],
          'pointValues': [
            'Rp 21.5 Jt', 'Rp 24.2 Jt', 'Rp 22.8 Jt', 'Rp 29.0 Jt', 'Rp 26.4 Jt',
            'Rp 33.1 Jt', 'Rp 36.5 Jt', 'Rp 34.0 Jt', 'Rp 41.2 Jt', 'Rp 39.5 Jt',
            'Rp 45.8 Jt', 'Rp 43.0 Jt', 'Rp 52.0 Jt', 'Rp 46.2 Jt', 'Rp 48.5 Jt'
          ],
          'pointDates': [
            '01 Okt', '02 Okt', '03 Okt', '04 Okt', '05 Okt',
            '06 Okt', '07 Okt', '08 Okt', '09 Okt', '10 Okt',
            '11 Okt', '12 Okt', '13 Okt', '14 Okt', '15 Okt'
          ],
          'xLabels': [
            '01', '02', '03', '04', '05',
            '06', '07', '08', '09', '10',
            '11', '12', '13', '14', '15 Okt'
          ],
        },
        // 3: 1 Tahun
        {
          'value': 'Rp 582.400.000',
          'growth': '+28%',
          'chartData': [0.25, 0.30, 0.36, 0.42, 0.48, 0.55, 0.62, 0.68, 0.75, 0.82, 0.91, 0.98],
          'pointValues': [
            'Rp 32 Jt', 'Rp 36 Jt', 'Rp 40 Jt', 'Rp 44 Jt', 'Rp 48 Jt', 'Rp 52 Jt',
            'Rp 55 Jt', 'Rp 58 Jt', 'Rp 61 Jt', 'Rp 64 Jt', 'Rp 69 Jt', 'Rp 73.4 Jt'
          ],
          'pointDates': [
            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
          ],
          'xLabels': ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'],
        },
      ],
    },
    {
      'title': 'Total Booking',
      'division': 'Divisi Finansial',
      'accentColor': const Color(0xFF114177),
      'icon': Icons.book_online,
      'periods': [
        // 0: 1 Hari
        {
          'value': '245 Transaksi',
          'growth': '+11%',
          'chartData': [0.18, 0.25, 0.50, 0.72, 0.65, 0.88, 0.95],
          'pointValues': ['18 tx', '25 tx', '65 tx', '125 tx', '160 tx', '215 tx', '245 tx'],
          'pointDates': ['00:00 WIB', '04:00 WIB', '08:00 WIB', '12:00 WIB', '16:00 WIB', '20:00 WIB', '23:59 WIB'],
          'xLabels': ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'],
        },
        // 1: 1 Minggu
        {
          'value': '1.720 Transaksi',
          'growth': '+7%',
          'chartData': [0.32, 0.45, 0.40, 0.62, 0.70, 0.90, 0.82],
          'pointValues': ['195 tx', '230 tx', '210 tx', '285 tx', '310 tx', '345 tx', '245 tx'],
          'pointDates': ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
          'xLabels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
        },
        // 2: 1 Bulan
        {
          'value': '3.420 Transaksi',
          'growth': '+8%',
          'chartData': [0.30, 0.38, 0.35, 0.50, 0.48, 0.62, 0.58, 0.70, 0.65, 0.80, 0.75, 0.88, 0.82, 0.96, 0.88],
          'pointValues': [
            '1.420 tx', '1.680 tx', '1.590 tx', '2.100 tx', '2.050 tx',
            '2.450 tx', '2.380 tx', '2.720 tx', '2.610 tx', '3.050 tx',
            '2.920 tx', '3.310 tx', '3.180 tx', '3.650 tx', '3.420 tx'
          ],
          'pointDates': [
            '01 Okt', '02 Okt', '03 Okt', '04 Okt', '05 Okt',
            '06 Okt', '07 Okt', '08 Okt', '09 Okt', '10 Okt',
            '11 Okt', '12 Okt', '13 Okt', '14 Okt', '15 Okt'
          ],
          'xLabels': [
            '01', '02', '03', '04', '05',
            '06', '07', '08', '09', '10',
            '11', '12', '13', '14', '15 Okt'
          ],
        },
        // 3: 1 Tahun
        {
          'value': '41.250 Transaksi',
          'growth': '+22%',
          'chartData': [0.28, 0.33, 0.38, 0.45, 0.52, 0.58, 0.65, 0.71, 0.78, 0.85, 0.91, 0.97],
          'pointValues': [
            '2.400 tx', '2.680 tx', '2.950 tx', '3.200 tx', '3.450 tx', '3.620 tx',
            '3.780 tx', '3.910 tx', '4.080 tx', '4.250 tx', '4.380 tx', '4.550 tx'
          ],
          'pointDates': [
            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
          ],
          'xLabels': ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'],
        },
      ],
    },
    {
      'title': 'Customer Aktif',
      'division': 'Divisi CS & KYC',
      'accentColor': const Color(0xFF6D28D9),
      'icon': Icons.people_outline,
      'periods': [
        // 0: 1 Hari
        {
          'value': '1.420 Pengguna',
          'growth': '+9%',
          'chartData': [0.22, 0.35, 0.52, 0.68, 0.74, 0.88, 0.96],
          'pointValues': ['120 User', '210 User', '580 User', '890 User', '1.150 User', '1.340 User', '1.420 User'],
          'pointDates': ['00:00 WIB', '04:00 WIB', '08:00 WIB', '12:00 WIB', '16:00 WIB', '20:00 WIB', '23:59 WIB'],
          'xLabels': ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'],
        },
        // 1: 1 Minggu
        {
          'value': '4.850 Pengguna',
          'growth': '+6%',
          'chartData': [0.35, 0.44, 0.52, 0.63, 0.72, 0.84, 0.94],
          'pointValues': ['3.900 User', '4.050 User', '4.200 User', '4.380 User', '4.550 User', '4.720 User', '4.850 User'],
          'pointDates': ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
          'xLabels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
        },
        // 2: 1 Bulan
        {
          'value': '12.850 Pengguna',
          'growth': '+5%',
          'chartData': [0.35, 0.40, 0.44, 0.48, 0.53, 0.58, 0.63, 0.67, 0.72, 0.76, 0.81, 0.85, 0.89, 0.93, 0.96],
          'pointValues': [
            '9.820 User', '10.050 User', '10.240 User', '10.510 User', '10.780 User',
            '11.020 User', '11.290 User', '11.530 User', '11.820 User', '12.040 User',
            '12.280 User', '12.490 User', '12.650 User', '12.780 User', '12.850 User'
          ],
          'pointDates': [
            '01 Okt', '02 Okt', '03 Okt', '04 Okt', '05 Okt',
            '06 Okt', '07 Okt', '08 Okt', '09 Okt', '10 Okt',
            '11 Okt', '12 Okt', '13 Okt', '14 Okt', '15 Okt'
          ],
          'xLabels': [
            '01', '02', '03', '04', '05',
            '06', '07', '08', '09', '10',
            '11', '12', '13', '14', '15 Okt'
          ],
        },
        // 3: 1 Tahun
        {
          'value': '48.900 Pengguna',
          'growth': '+35%',
          'chartData': [0.30, 0.36, 0.43, 0.50, 0.57, 0.64, 0.72, 0.79, 0.85, 0.90, 0.94, 0.98],
          'pointValues': [
            '15.200 User', '18.100 User', '21.400 User', '25.000 User', '28.600 User', '32.100 User',
            '35.800 User', '39.200 User', '42.500 User', '45.100 User', '47.300 User', '48.900 User'
          ],
          'pointDates': [
            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
          ],
          'xLabels': ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'],
        },
      ],
    },
  ];

  // Log Aktivitas Login Admin
  final List<Map<String, dynamic>> _adminLogs = [
    {
      'id': 'LOG-001',
      'admin': 'Dito Pratama',
      'role': 'Super Admin',
      'action': 'Login berhasil',
      'device': 'Vivo y65',
      'ip': '182.253.12.8',
      'time': '5 mnt lalu',
      'roleColor': const Color(0xFF6D28D9),
      'status': 'Berhasil',
    },
    {
      'id': 'LOG-002',
      'admin': 'Rina Wijaya',
      'role': 'Admin Operasional',
      'action': 'Login berhasil',
      'device': 'Vivo y65',
      'ip': '114.122.45.19',
      'time': '28 mnt lalu',
      'roleColor': const Color(0xFF114177),
      'status': 'Berhasil',
    },
    {
      'id': 'LOG-003',
      'admin': 'Bambang Sutrisno',
      'role': 'Admin Finansial',
      'action': 'Login berhasil',
      'device': 'Vivo y65',
      'ip': '180.252.88.74',
      'time': '2 jam lalu',
      'roleColor': const Color(0xFF17A18A),
      'status': 'Berhasil',
    },
    {
      'id': 'LOG-004',
      'admin': 'Siti Rahma',
      'role': 'Admin CS & KYC',
      'action': 'Login berhasil',
      'device': 'Vivo y65',
      'ip': '36.85.190.21',
      'time': '4 jam lalu',
      'roleColor': const Color(0xFFE07A5F),
      'status': 'Berhasil',
    },
  ];

  void _pruneAuditLogs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.delete_sweep_outlined, color: Color(0xFFD94B4B), size: 26),
            const SizedBox(width: 8),
            Text('Bersihkan Log Login', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Pembersihan log dilakukan untuk mengosongkan riwayat sesi login admin lama.\n\nPilih tindakan yang diinginkan:',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B))),
          ),
          OutlinedButton(
            onPressed: () {
              setState(() {
                if (_adminLogs.length > 2) {
                  _adminLogs.removeRange(2, _adminLogs.length);
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Log login lama (>7 hari) berhasil dipangkas!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFF17A18A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF114177)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Pangkas > 7 Hari', style: TextStyle(color: Color(0xFF114177), fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _adminLogs.clear();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Seluruh log login admin berhasil dikosongkan!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFFD94B4B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD94B4B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus Semua', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _toggleMaintenanceMode(bool value) {
    if (value) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD94B4B), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kunci Akses Pengguna?',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mode Maintenance akan mengunci akses aplikasi seluruh pengguna publik.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A18),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFED7D7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFFD94B4B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'User tidak dapat melakukan reservasi tiket, pembayaran, atau akses dompet hingga dinonaktifkan kembali.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9B1C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1A18),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A18),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() => _isMaintenanceActive = true);
                Navigator.pop(ctx);
                await MaintenanceService.instance.setGlobalMaintenance(true, notifyPush: true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Mode Maintenance AKTIF. Push notifikasi telah dikirim ke pengguna.',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFD94B4B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.lock, size: 16, color: Colors.white),
              label: Text(
                'Aktifkan Sekarang',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD94B4B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() => _isMaintenanceActive = false);
      MaintenanceService.instance.setGlobalMaintenance(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mode Maintenance DIMATIKAN. Layanan beroperasi normal kembali.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF17A18A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMetric = _divisionalMetrics[_selectedMetricIndex < _divisionalMetrics.length ? _selectedMetricIndex : 0];

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF9F9F9),

        // ─── BURGER BAR (DRAWER) DENGAN RINGKASAN GLOBAL ───
        drawer: _buildBurgerDrawer(context),

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              // 🍔 SIMBOL "P" SEBAGAI BURGER BUTTON PEMBUKA DRAWER
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1D1F),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        left: 8,
                        child: Icon(Icons.menu, size: 14, color: Colors.white70),
                      ),
                      const Positioned(
                        right: 8,
                        child: Icon(Icons.local_parking, size: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
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
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF8B5CF6), width: 0.8),
                        ),
                        child: Text(
                          'Super Admin',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6D28D9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text('Control Hub Super Admin', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                ],
              ),
            ],
          ),
          actions: [
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none, size: 20, color: Color(0xFF1A1A18)),
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
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF6D28D9),
                child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),

        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome Header
            Text('Dashboard Super Admin', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            

            // ─── SECTION 1: STATISTIK MONITORING DIVISI (READ-ONLY) DENGAN GRAFIK GUNUNG ───
            _buildMountainChartSection(currentMetric),
            const SizedBox(height: 24),

            // 🚨 SECTION 2: 1 TOMBOL MENONJOL: AKSES DARURAT DIVISI (EMERGENCY OVERRIDE)
            _buildEmergencyAccessButton(context),
            const SizedBox(height: 24),

            // ─── SECTION 3: FITUR INTI KHUSUS SUPER ADMIN (BUKAN AKSES DIVISI LAIN) ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tata Kelola & Wewenang Inti', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Domain Khusus', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fitur 1: Emergency Maintenance Mode Toggle
            _buildMaintenanceSwitchCard(context),
            const SizedBox(height: 12),

            // Fitur 2: Konfigurasi Engine AI (Gemini / GPT)
            _buildAiConfigCard(context),
            const SizedBox(height: 24),

            // ─── SECTION 4: AUDIT TRAIL LOG ADMIN DENGAN KONTROL PANGKAS LOG ───
            _buildAuditTrailSection(),
            const SizedBox(height: 80),
          ],
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen()));
          },
          label: const Text('Dev Sitemap'),
          icon: const Icon(Icons.developer_board),
          backgroundColor: const Color(0xFF1C1D1F),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // ─── DRAWER / BURGER BAR DENGAN RINGKASAN GLOBAL ───
  Widget _buildBurgerDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header: Identitas Super Admin
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1D1F),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6D28D9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('D', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dito Pratama', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('dito@parksmart.id', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF8B5CF6), width: 0.6),
                            ),
                            child: Text(
                              'SUPER ADMIN MASTER',
                              style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFDDD6FE)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

       

          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Navigasi Shortcut
          ListTile(
            leading: const Icon(Icons.dashboard_outlined, color: Color(0xFF1A1A18)),
            title: Text('Beranda Super Admin', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF6D28D9)),
            title: Text('Manajemen Admin & RBAC', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Color(0xFF1D4ED8)),
            title: Text('Pengaturan Global & Maintenance', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAppSettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined, color: Color(0xFF0F766E)),
            title: Text('Konfigurasi AI Engine', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAiConfigScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.flash_on, color: Color(0xFFC0392B)),
            title: Text('Akses Darurat Divisi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFC0392B))),
            onTap: () {
              Navigator.pop(context);
              _showEmergencyMasterModal(context);
            },
          ),

          const Divider(height: 20, color: Color(0xFFE4DFD5)),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFD94B4B)),
            title: Text('Keluar Dashboard', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }



  // ─── GRAFIK CHART GUNUNG (SMOOTH MOUNTAIN AREA CHART - KURSOR & PERIODE WAKTU) ───
  Widget _buildMountainChartSection(Map<String, dynamic> currentMetric) {
    final Color accentColor = currentMetric['accentColor'] as Color;
    final List<Map<String, dynamic>> periods = List<Map<String, dynamic>>.from(currentMetric['periods']);
    final Map<String, dynamic> activePeriod = periods[_selectedPeriodIndex];

    final List<double> chartData = List<double>.from(activePeriod['chartData']);
    final List<String> pointValues = List<String>.from(activePeriod['pointValues']);
    final List<String> pointDates = List<String>.from(activePeriod['pointDates']);
    final List<String> xLabels = List<String>.from(activePeriod['xLabels']);
    final int pointCount = chartData.length;

    // Nilai terinspeksi jika mode kursor aktif atau disentuh
    final bool isInspecting = _inspectedPointIndex != null &&
        _inspectedPointIndex! >= 0 &&
        _inspectedPointIndex! < pointCount;
    final String displayValue = isInspecting
        ? pointValues[_inspectedPointIndex!]
        : activePeriod['value'];
    final String? displayDate = isInspecting
        ? pointDates[_inspectedPointIndex!]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4DFD5)),
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
          // Header: Icon + Info Divisi & Dropdown Pilihan Metrik (Pendapatan, Total, Customer)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(currentMetric['icon'] as IconData, size: 20, color: accentColor),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentMetric['title'],
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                      ),
                      Text(
                        currentMetric['division'],
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                      ),
                    ],
                  ),
                ],
              ),

              // Dropdown Pilihan Metrik menggantikan posisi tombol Kembali
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE4DFD5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedMetricIndex,
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A1A18), size: 20),
                    borderRadius: BorderRadius.circular(12),
                    elevation: 3,
                    dropdownColor: Colors.white,
                    items: [
                      DropdownMenuItem<int>(
                        value: 0,
                        child: Text(
                          'Pendapatan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A18),
                          ),
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(
                          'Total',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A18),
                          ),
                        ),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text(
                          'Customer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A18),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMetricIndex = val;
                          _inspectedPointIndex = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nilai Utama
          Text(
            displayValue,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isInspecting ? accentColor : const Color(0xFF1A1A18),
            ),
          ),
          const SizedBox(height: 6),

          // Persentase Pertumbuhan / Tanggal Titik Kursor (dapat disentuh untuk reset)
          if (isInspecting)
            GestureDetector(
              onTap: () {
                setState(() {
                  _inspectedPointIndex = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 11, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      displayDate ?? '',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.close, size: 11, color: accentColor),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1F2EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    activePeriod['growth'],
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),

          // ⛰️ Chart Area Responsif Penuh (HANYA KURSOR SAJA - Gestur Drag & Tap Langsung Menggerakkan Kursor)
          LayoutBuilder(
            builder: (context, constraints) {
              final double canvasWidth = constraints.maxWidth;
              const double canvasHeight = 165.0;

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
                      _onChartTouch(details.localPosition.dx, canvasWidth, pointCount);
                    },
                    onPanStart: (details) {
                      _onChartTouch(details.localPosition.dx, canvasWidth, pointCount);
                    },
                    onPanUpdate: (details) {
                      _onChartTouch(details.localPosition.dx, canvasWidth, pointCount);
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
                          inspectedIndex: _inspectedPointIndex,
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
          const SizedBox(height: 14),

          // ⏱️ FILTER PERIODE WAKTU (1 Hari, 1 Minggu, 1 Bulan, 1 Tahun) di Posisi Bawah
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EEE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(_periodOptions.length, (idx) {
                final isPeriodSelected = _selectedPeriodIndex == idx;
                final label = _periodOptions[idx];

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeriodIndex = idx;
                        _inspectedPointIndex = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isPeriodSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        border: isPeriodSelected
                            ? Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2)
                            : Border.all(color: Colors.transparent),
                        boxShadow: isPeriodSelected
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPeriodSelected) ...[
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: isPeriodSelected ? FontWeight.bold : FontWeight.w600,
                                color: isPeriodSelected ? const Color(0xFF1A1A18) : const Color(0xFF76777B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 🚨 1 TOMBOL MENONJOL: AKSES DARURAT DIVISI (EMERGENCY OVERRIDE HUB)
  Widget _buildEmergencyAccessButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      shadowColor: const Color(0xFFC0392B).withValues(alpha: 0.35),
      child: InkWell(
        onTap: () => _showEmergencyMasterModal(context),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B0000), Color(0xFFB91C1C), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white38, width: 1),
                ),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'AKSES DARURAT DIVISI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                       
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bypass langsung ke seluruh modul Operasional, Finansial, & CS-KYC jika terjadi kendala',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // FITUR INTI 2: EMERGENCY MAINTENANCE MODE TOGGLE
  Widget _buildMaintenanceSwitchCard(BuildContext context) {
    return Container(
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isMaintenanceActive ? const Color(0xFFFDE8E4) : const Color(0xFFE3EEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: _isMaintenanceActive ? const Color(0xFFD94B4B) : const Color(0xFF114177),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mode Maintenance (Kill-Switch)', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    Text('Kunci akses user seketika bila terjadi insiden atau pemeliharaan server', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  ],
                ),
              ),
              Switch(
                value: _isMaintenanceActive,
                activeThumbColor: const Color(0xFFD94B4B),
                onChanged: _toggleMaintenanceMode,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isMaintenanceActive ? const Color(0xFFFDE8E4) : const Color(0xFFD1F2EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _isMaintenanceActive ? Icons.lock : Icons.check_circle,
                  size: 14,
                  color: _isMaintenanceActive ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _isMaintenanceActive
                        ? 'PERINGATAN: Seluruh aplikasi pengguna umum saat ini dinonaktifkan.'
                        : 'STATUS NORMAL: Pengguna dapat mencari slot, booking, dan membayar seperti biasa.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _isMaintenanceActive ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAppSettingsScreen())),
            icon: const Icon(Icons.tune, size: 16, color: Color(0xFF114177)),
            label: Text('Atur Pesan Maintenance & Modul Global', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF114177)),
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // FITUR INTI 3: KONFIGURASI GROQ AI ENGINE
  Widget _buildAiConfigCard(BuildContext context) {
    return Container(
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF55036).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFFF55036), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Konfigurasi Groq AI Key', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    Text('Provider: Groq Cloud LPU™ • Model: Qwen 2.5', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model Aktif:', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                    Text('Qwen 2.5 (qwen/qwen3.8-27b)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFF55036))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF55036).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('LPU™ 500+ tok/s', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFF55036))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAiConfigScreen())),
            icon: const Icon(Icons.vpn_key_outlined, size: 16, color: Colors.white),
            label: Text('Atur Groq API Key', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF55036),
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION 4: LOG AKTIVITAS LOGIN ADMIN DENGAN KONTROL PANGKAS LOG
  Widget _buildAuditTrailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log Aktivitas Login Admin', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                Text('Riwayat sesi masuk & login seluruh administrator platform', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
            // Tombol Bersihkan / Prune Log
            IconButton(
              onPressed: _pruneAuditLogs,
              icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFD94B4B)),
              tooltip: 'Pangkas Log',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_adminLogs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, size: 36, color: Color(0xFF17A18A)),
                  const SizedBox(height: 8),
                  Text('Log login bersih. Tidak ada riwayat sesi tersimpan.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _adminLogs.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1EEE7)),
              itemBuilder: (ctx, index) {
                final log = _adminLogs[index];
                final roleColor = log['roleColor'] as Color;

                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              log['admin'][0],
                              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: roleColor),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF17A18A),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(log['admin'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: roleColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        log['role'],
                                        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: roleColor),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(log['time'], style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.login_rounded, size: 13, color: Color(0xFF17A18A)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    '${log['action']} • ${log['device']}',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF45474A)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IP: ${log['ip']} • Status: ${log['status']}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ─── MODAL AKSES DARURAT KE 3 DIVISI ───
  void _showEmergencyMasterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header Modal
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE4DFD5))),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.flash_on, color: Color(0xFFC0392B), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Akses Darurat Master Super Admin',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A18),
                              ),
                            ),
                            Text(
                              'Bypass seluruh otoritas divisi khusus untuk penanganan darurat',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF76777B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Konten 3 Divisi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 1. DIVISI OPERASIONAL
                  _buildEmergencyDivisionGroup(
                    context,
                    title: '1. Divisi Operasional',
                    roleBadge: 'Admin Operasional',
                    badgeColor: const Color(0xFF114177),
                    desc: 'Akses bypass titik parkir, master kota, denah slot, dan sensor IoT',
                    onOpenDashboard: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOperationsDashboardScreen()));
                    },
                    items: [
                      _EmergencyItem('Kelola Titik Parkir', Icons.local_parking, () => const ManageParkingScreen()),
                      _EmergencyItem('Master Lokasi Parkir', Icons.place, () => const LocationsScreen()),
                      _EmergencyItem('Master Kota Operasional', Icons.location_city, () => const AdminCitiesScreen()),
                      _EmergencyItem('Denah Slot & Sensor IoT', Icons.grid_view, () => const SlotManagementScreen()),
                      _EmergencyItem('Live Kendaraan & Overstay', Icons.car_crash, () => const ActiveUsersScreen()),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. DIVISI FINANSIAL
                  _buildEmergencyDivisionGroup(
                    context,
                    title: '2. Divisi Finansial',
                    roleBadge: 'Admin Finansial',
                    badgeColor: const Color(0xFF17A18A),
                    desc: 'Akses bypass laporan omzet, tarif dinamis, transaksi, dan saldo dompet',
                    onOpenDashboard: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinanceDashboardScreen()));
                    },
                    items: [
                      _EmergencyItem('Laporan Pendapatan & Omzet', Icons.trending_up, () => const RevenueScreen()),
                      _EmergencyItem('Atur Tarif Dinamis', Icons.price_change, () => const PricingScreen()),
                      _EmergencyItem('Transaksi Real-time', Icons.receipt_long, () => const AdminTransactionsScreen()),
                      _EmergencyItem('Injeksi/Tarik Saldo Dompet', Icons.account_balance_wallet, () => const AdminWalletScreen()),
                      _EmergencyItem('Rekonsiliasi Tiket Booking', Icons.book_online, () => const AdminBookingsScreen()),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. DIVISI CS & KYC
                  _buildEmergencyDivisionGroup(
                    context,
                    title: '3. Divisi CS & KYC',
                    roleBadge: 'Admin CS & KYC',
                    badgeColor: const Color(0xFFE07A5F),
                    desc: 'Akses bypass verifikasi KTP, blokir pengguna, komplain, dan arcade',
                    onOpenDashboard: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCsKycDashboardScreen()));
                    },
                    items: [
                      _EmergencyItem('Verifikasi KTP / KYC Identitas', Icons.verified_user, () => const AdminKycScreen()),
                      _EmergencyItem('Profil Pelanggan CRM', Icons.badge, () => const AdminCustomerProfilesScreen()),
                      _EmergencyItem('Blokir / Buka Pengguna', Icons.person_off, () => const ManageUsersScreen()),
                      _EmergencyItem('Komplain & Feedback Pengguna', Icons.feedback, () => const FeedbackAdminScreen()),
                      _EmergencyItem('Broadcast Notifikasi Promo', Icons.campaign, () => const AdminNotificationsScreen()),
                      _EmergencyItem('Pengaturan Mini-Game Arcade', Icons.videogame_asset, () => const ArcadeAdminScreen()),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyDivisionGroup(
    BuildContext context, {
    required String title,
    required String roleBadge,
    required Color badgeColor,
    required String desc,
    required VoidCallback onOpenDashboard,
    required List<_EmergencyItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(roleBadge, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          const SizedBox(height: 10),

          // Tombol Buka Dashboard Utama Divisi Terkait
          OutlinedButton.icon(
            onPressed: onOpenDashboard,
            icon: const Icon(Icons.open_in_new, size: 14),
            label: Text('Buka Dashboard Utama $roleBadge', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: badgeColor,
              side: BorderSide(color: badgeColor),
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 10),

          // Daftar Tombol Shortcut Layar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((it) {
              return ActionChip(
                avatar: Icon(it.icon, size: 14, color: const Color(0xFF1A1A18)),
                label: Text(it.title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE4DFD5)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => it.screenBuilder()));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EmergencyItem {
  final String title;
  final IconData icon;
  final Widget Function() screenBuilder;
  _EmergencyItem(this.title, this.icon, this.screenBuilder);
}

// ─── CUSTOM PAINTER: SMOOTH MOUNTAIN AREA CHART (TRADING STYLE) ───
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
    final double baselineY = size.height - 36.0; // Sisakan 36px untuk label tanggal di bawah
    final double availableHeight = baselineY - topPadding;

    // 1. Hitung seluruh koordinat titik data
    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = marginHorizontal + (i * stepX);
      final double y = topPadding + (1.0 - data[i].clamp(0.0, 1.0)) * availableHeight;
      points.add(Offset(x, y));
    }

    // 2. Gambar Gridlines Horizontal ala Aplikasi Trading (Tingkat 25%, 50%, 75%)
    final gridPaint = Paint()
      ..color = const Color(0xFFE4DFD5).withValues(alpha: 0.6)
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

    // Garis dasar / Axis Baseline
    final baselinePaint = Paint()
      ..color = const Color(0xFFE4DFD5)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(marginHorizontal - 15, baselineY),
      Offset(size.width - marginHorizontal + 15, baselineY),
      baselinePaint,
    );

    // 3. Bangun Area Gunung dengan Spline Catmull-Rom Cubic Bézier
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

    // Fill dengan vertical linear gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, availableHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);

    // 4. Garis Stroke Kurva Utama
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

    // 5. Gambar Sumbu X Label Tanggal di Bawah Setiap Titik
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

    // 6. Mode Inspeksi / Crosshair Aktif (Kursor Silang ala TradingView)
    if (inspectedIndex != null && inspectedIndex! >= 0 && inspectedIndex! < points.length) {
      final Offset inspectPt = points[inspectedIndex!];

      // Garis vertikal crosshair
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

      // Garis horizontal level crosshair
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

      // Titik fokus dengan efek glowing halo
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

      // Tooltip Box Mengambang (Floating Tooltip Box)
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

        // Posisikan tooltip di atas titik jika cukup ruang, atau di bawah jika dekat tepi atas
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

        // Bayangan tooltip
        canvas.drawRRect(
          boxRect,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );

        // Latar hitam terminal trading
        canvas.drawRRect(
          boxRect,
          Paint()..color = const Color(0xFF1C1D1F),
        );

        // Border aksen
        canvas.drawRRect(
          boxRect,
          Paint()
            ..color = lineColor.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );

        // Panah pointer segitiga kecil
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

        // Gambar teks tooltip
        tp.paint(canvas, Offset(boxX + padH, boxY + padV));
      }
    } else {
      // 7. Jika tidak dalam mode inspeksi, gambar indikator titik puncak & titik terbaru (Live)
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

      // Titik Terbaru / Live (di ujung kanan)
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
