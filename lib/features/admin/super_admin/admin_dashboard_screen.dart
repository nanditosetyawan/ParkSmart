import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backend/admin_dashboard_backend.dart';
import 'backend/admin_kyc_backend.dart';

// Screens for Super Admin Core Governance
import 'admin_user_management_screen.dart';
import 'admin_app_settings_screen.dart';
import 'admin_ai_config_screen.dart';
import '../cs/admin_notifications_screen.dart';
import '../../../core/services/maintenance_service.dart';
import '../../../core/services/client_info_service.dart';

import 'admin_kyc_screen.dart';
import 'admin_kyc_detail_modal.dart';
import 'admin_arcade_screen.dart';

import '../../sitemap_screen.dart';
import '../../auth/login_screen.dart';

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

  // 👤 Super Admin Profile State
  String _superAdminName = 'Gibran Widodo';
  final String _superAdminEmail = 'superadmin@parksmart.id';
  String? _superAdminAvatarPath;

  // 🪪 Daftar Permintaan Konfirmasi Pendaftaran KTP (KYC) Baru dari Supabase
  List<Map<String, dynamic>> get _pendingKycList => AdminDashboardBackend.instance.pendingKycList;

  @override
  void initState() {
    super.initState();
    _isMaintenanceActive = MaintenanceService.instance.isGlobalMaintenance;
    _loadSuperAdminProfile();
    _initClientAuditLogs();
    AdminDashboardBackend.instance.addListener(_onDashboardBackendChanged);
    AdminDashboardBackend.instance.startPeriodicMetrics();
    AdminDashboardBackend.instance.fetchDashboardMetrics();
  }

  void _onDashboardBackendChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSuperAdminProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('super_admin_name');
      final savedAvatar = prefs.getString('super_admin_avatar');
      if (savedName != null && savedName.isNotEmpty) {
        setState(() => _superAdminName = savedName);
      }
      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        setState(() => _superAdminAvatarPath = savedAvatar);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    AdminDashboardBackend.instance.stopPeriodicMetrics();
    AdminDashboardBackend.instance.removeListener(_onDashboardBackendChanged);
    super.dispose();
  }

  void _onChartTouch(double localX, double canvasWidth, int pointCount, int activeCount) {
    if (pointCount <= 1 || canvasWidth <= 0) return;
    if (activeCount == 0) {
      if (_inspectedPointIndex != 0) {
        setState(() => _inspectedPointIndex = 0);
      }
      return;
    }
    const double marginHorizontal = 24.0;
    final double chartWidth = canvasWidth - (marginHorizontal * 2);
    if (chartWidth <= 0) return;
    final double stepX = chartWidth / (pointCount - 1);

    final double relativeX = (localX - marginHorizontal).clamp(0.0, chartWidth);
    int closestIndex = (relativeX / stepX).round().clamp(0, pointCount - 1);
    if (closestIndex >= activeCount) {
      closestIndex = activeCount - 1;
    }

    if (_inspectedPointIndex != closestIndex) {
      setState(() {
        _inspectedPointIndex = closestIndex;
      });
    }
  }

  // Emergency Maintenance Mode quick toggle state
  bool _isMaintenanceActive = false;

  // Divisional Read-Only Metrics Data (Dengan opsi 1 Hari, 1 Minggu, 1 Bulan, 1 Tahun)
  // Dikalkulasi secara real-time dari Supabase & Waktu Server Indonesia WIB oleh AdminDashboardBackend
  List<Map<String, dynamic>> get _divisionalMetrics => AdminDashboardBackend.instance.divisionalMetrics;

  // Log Aktivitas Login Admin (Diperbarui real-time via ClientInfoService)
  List<Map<String, dynamic>> _adminLogs = [];
  bool _isLoadingNetworkInfo = false;

  Color _getRoleColor(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('super')) return const Color(0xFF6D28D9);
    if (lower.contains('operasional')) return const Color(0xFF114177);
    if (lower.contains('finansial')) return const Color(0xFF17A18A);
    return const Color(0xFFE07A5F);
  }

  Future<void> _initClientAuditLogs({bool forceNetworkRefresh = false}) async {
    if (mounted) setState(() => _isLoadingNetworkInfo = true);
    try {
      if (forceNetworkRefresh) {
        await ClientInfoService.instance.fetchClientNetworkInfo(forceRefresh: true);
        await ClientInfoService.instance.getDeviceModel(forceRefresh: true);
        await ClientInfoService.instance.recordAdminLogin(
          adminName: _superAdminName,
          role: 'Super Admin',
          action: 'Login berhasil (Sesi Aktif)',
        );
      }

      var rawLogs = await ClientInfoService.instance.getStoredLogs();

      // Jika log masih kosong sama sekali, catat sesi awal
      if (rawLogs.isEmpty) {
        await ClientInfoService.instance.recordAdminLogin(
          adminName: _superAdminName,
          role: 'Super Admin',
          action: 'Login berhasil (Sesi Aktif)',
        );
        rawLogs = await ClientInfoService.instance.getStoredLogs();
      }

      if (mounted) {
        setState(() {
          _adminLogs = rawLogs.map((log) => {
            'id': log.id,
            'admin': log.admin,
            'role': log.role,
            'action': log.action,
            'device': log.device,
            'ip': log.ip,
            'location': log.location,
            'isp': log.isp,
            'time': log.time,
            'roleColor': _getRoleColor(log.role),
            'status': log.status,
            'isCurrentSession': log.isCurrentSession,
            'syncedToSupabase': log.syncedToSupabase,
          }).toList();
          _isLoadingNetworkInfo = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingNetworkInfo = false);
    }
  }

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
            onPressed: () async {
              await ClientInfoService.instance.pruneOldLogs();
              final rawLogs = await ClientInfoService.instance.getStoredLogs();
              if (mounted) {
                setState(() {
                  _adminLogs = rawLogs.map((log) => {
                    'id': log.id,
                    'admin': log.admin,
                    'role': log.role,
                    'action': log.action,
                    'device': log.device,
                    'ip': log.ip,
                    'location': log.location,
                    'isp': log.isp,
                    'time': log.time,
                    'roleColor': _getRoleColor(log.role),
                    'status': log.status,
                    'isCurrentSession': log.isCurrentSession,
                    'syncedToSupabase': log.syncedToSupabase,
                  }).toList();
                });
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Log login lama (>7 hari) berhasil dipangkas!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFF17A18A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF114177)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Pangkas > 7 Hari', style: TextStyle(color: Color(0xFF114177), fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ClientInfoService.instance.clearAllLogs();
              if (mounted) {
                setState(() {
                  _adminLogs.clear();
                });
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Seluruh log login admin berhasil dikosongkan!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFFD94B4B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
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

  void _showLogDetailBottomSheet(BuildContext context, Map<String, dynamic> log) {
    final roleColor = log['roleColor'] as Color? ?? const Color(0xFF6D28D9);
    final isCurrent = log['isCurrentSession'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4DFD5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCurrent ? Icons.verified_user : Icons.devices_other,
                    color: roleColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              log['admin'] ?? 'Admin',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A18),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF17A18A).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'AKTIF SEKARANG',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF17A18A),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '${log['role']} • ID: ${log['id']}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF76777B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1EEE7)),
            const SizedBox(height: 14),

            // Card IP & Perangkat
            _buildDetailRow(
              icon: Icons.public,
              iconColor: const Color(0xFF114177),
              title: 'Alamat IP Publik (Real-Time)',
              value: log['ip'] ?? '127.0.0.1',
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 16, color: Color(0xFF114177)),
                tooltip: 'Salin IP',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: log['ip'] ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alamat IP (${log['ip']}) disalin ke clipboard!', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.computer,
              iconColor: const Color(0xFF6D28D9),
              title: 'Model Perangkat (Hardware)',
              value: log['device'] ?? 'Perangkat',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.wifi,
              iconColor: const Color(0xFF17A18A),
              title: 'Penyedia Jaringan (ISP)',
              value: log['isp'] ?? 'Jaringan Aktif',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.location_on_outlined,
              iconColor: const Color(0xFFE07A5F),
              title: 'Lokasi Geografis Koneksi',
              value: log['location'] ?? 'Indonesia',
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.access_time,
              iconColor: const Color(0xFF76777B),
              title: 'Waktu Sesi & Status',
              value: '${log['time']} (${log['status']})',
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF114177),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Tutup', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1EEE7)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              ],
            ),
          ),
          ?trailing,
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
    return ListenableBuilder(
      listenable: AdminDashboardBackend.instance,
      builder: (context, _) {
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
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
              onTap: _showEditProfileDialog,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF6D28D9),
                backgroundImage: _superAdminAvatarPath != null
                    ? FileImage(File(_superAdminAvatarPath!))
                    : null,
                child: _superAdminAvatarPath == null
                    ? Text(
                        _superAdminName.isNotEmpty ? _superAdminName[0].toUpperCase() : 'D',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    : null,
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


            // 🪪 SECTION: KONFIRMASI PENDAFTARAN KTP (VERIFIKASI KYC IDENTITAS)
            _buildKycConfirmationSection(context),
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
  },
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
                        image: _superAdminAvatarPath != null
                            ? DecorationImage(
                                image: FileImage(File(_superAdminAvatarPath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _superAdminAvatarPath == null
                          ? Center(
                              child: Text(
                                _superAdminName.isNotEmpty ? _superAdminName[0].toUpperCase() : 'D',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_superAdminName, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(_superAdminEmail, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
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
                    IconButton(
                      tooltip: 'Edit Profil Super Admin',
                      icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditProfileDialog();
                      },
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
            leading: const Icon(Icons.verified_user_outlined, color: Color(0xFFE07A5F)),
            title: Text('Konfirmasi Pendaftaran KTP', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen()));
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
            leading: const Icon(Icons.videogame_asset_outlined, color: Color(0xFF0D9488)),
            title: Text('Pengaturan Poin, Arcade & Hadiah', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ArcadeAdminScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time_filled, color: Color(0xFFD97706)),
            title: Text('Waktu', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              _showTimeZonesDialog();
            },
          ),

          const Divider(height: 20, color: Color(0xFFE4DFD5)),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFD94B4B)),
            title: Text('Keluar Dashboard', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── FITUR: POP-UP KONVERSI ZONA WAKTU INDONESIA (WIB, WITA, WIT) ───
  void _showTimeZonesDialog() {
    showDialog(
      context: context,
      builder: (_) => const _RealtimeTimeZonesDialog(),
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
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
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
                      _onChartTouch(details.localPosition.dx, canvasWidth, pointCount, activePeriod['activePointCount'] as int? ?? 0);
                    },
                    onPanStart: (details) {
                      _onChartTouch(details.localPosition.dx, canvasWidth, pointCount, activePeriod['activePointCount'] as int? ?? 0);
                    },
                    onPanUpdate: (details) {
                      _onChartTouch(details.localPosition.dx, canvasWidth, pointCount, activePeriod['activePointCount'] as int? ?? 0);
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
                          activePointCount: activePeriod['activePointCount'] as int? ?? 0,
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
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model Aktif:', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                const SizedBox(height: 2),
                Text('Qwen 2.5 (qwen/qwen3.8-27b)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFF55036))),
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
                Text('Audit jejak IP publik & perangkat riil', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
            Row(
              children: [
                // Tombol Refresh IP & Jaringan
                IconButton(
                  onPressed: _isLoadingNetworkInfo ? null : () => _initClientAuditLogs(forceNetworkRefresh: true),
                  icon: _isLoadingNetworkInfo
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF114177)))
                      : const Icon(Icons.refresh, size: 20, color: Color(0xFF114177)),
                  tooltip: 'Segarkan IP & Jaringan',
                  visualDensity: VisualDensity.compact,
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
                final roleColor = log['roleColor'] as Color? ?? const Color(0xFF6D28D9);
                final isCurrent = log['isCurrentSession'] == true;

                return InkWell(
                  onTap: () => _showLogDetailBottomSheet(context, log),
                  borderRadius: index == 0
                      ? const BorderRadius.vertical(top: Radius.circular(18))
                      : index == _adminLogs.length - 1
                          ? const BorderRadius.vertical(bottom: Radius.circular(18))
                          : BorderRadius.zero,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: isCurrent
                        ? BoxDecoration(
                            color: const Color(0xFF17A18A).withValues(alpha: 0.04),
                            borderRadius: index == 0
                                ? const BorderRadius.vertical(top: Radius.circular(18))
                                : BorderRadius.zero,
                          )
                        : null,
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
                                (log['admin'] != null && (log['admin'] as String).isNotEmpty)
                                    ? (log['admin'] as String)[0]
                                    : 'A',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: roleColor),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: isCurrent ? const Color(0xFF10B981) : const Color(0xFF17A18A),
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
                                      Text(log['admin'] ?? 'Admin', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: roleColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          log['role'] ?? 'Staff',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: roleColor),
                                        ),
                                      ),
                                      if (isCurrent) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF17A18A).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'SESI ANDA',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(log['time'] ?? 'Baru saja', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Baris 1: Status Action Login
                              Row(
                                children: [
                                  Icon(Icons.login_rounded, size: 13, color: isCurrent ? const Color(0xFF10B981) : const Color(0xFF17A18A)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      log['action'] ?? 'Login berhasil',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF45474A)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Baris 2: Keterangan Web Browser / Perangkat di bawah Action (tanpa dot)
                              Row(
                                children: [
                                  const Icon(Icons.devices_outlined, size: 12, color: Color(0xFF8C8E92)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      log['device'] ?? 'Perangkat Web Browser',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF5A5C60)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Baris 3: Alamat IP (tanpa dot)
                              Row(
                                children: [
                                  const Icon(Icons.public, size: 12, color: Color(0xFF114177)),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'IP: ${log['ip'] ?? "127.0.0.1"}',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w500, color: const Color(0xFF76777B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Baris 4: Lokasi di bawah IP (tanpa dot)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFFE07A5F)),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            log['location'] ?? 'Indonesia',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF76777B)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, size: 14, color: Color(0xFFB0B0AF)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }


  // ─── FITUR: EDIT PROFIL SUPER ADMIN (NAMA & FOTO, EMAIL TERKUNCI) ───
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _superAdminName);
    String? tempAvatarPath = _superAdminAvatarPath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage(ImageSource source) async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
              if (picked != null) {
                setDialogState(() {
                  tempAvatarPath = picked.path;
                });
              }
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(content: Text('Gagal mengambil gambar: $e'), backgroundColor: const Color(0xFFD94B4B)),
              );
            }
          }

          void showSourceSelection() {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 16),
                      Text('Pilih Foto Profil', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFFEDE9FE), child: Icon(Icons.photo_library, color: Color(0xFF6D28D9))),
                        title: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFFD1F2EB), child: Icon(Icons.camera_alt, color: Color(0xFF17A18A))),
                        title: Text('Ambil Foto Kamera', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(ImageSource.camera);
                        },
                      ),
                      if (tempAvatarPath != null)
                        ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFFFDE8E4), child: Icon(Icons.delete_outline, color: Color(0xFFD94B4B))),
                          title: Text('Hapus Foto Profil', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: const Color(0xFFD94B4B))),
                          onTap: () {
                            Navigator.pop(context);
                            setDialogState(() {
                              tempAvatarPath = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
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
                          Text('Edit Profil Super Admin', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          Text('Perbarui nama dan foto profil utama', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF76777B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFE4DFD5)),

                  // AVATAR PICKER
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFF6D28D9),
                          backgroundImage: tempAvatarPath != null
                              ? FileImage(File(tempAvatarPath!))
                              : null,
                          child: tempAvatarPath == null
                              ? Text(
                                  nameController.text.isNotEmpty ? nameController.text[0].toUpperCase() : 'S',
                                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: showSourceSelection,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A18),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: showSourceSelection,
                      icon: const Icon(Icons.edit, size: 14, color: Color(0xFF6D28D9)),
                      label: Text('Ganti Foto Profil', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NAMA FIELD
                  Text('Nama Lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF6D28D9)),
                      hintText: 'Masukkan nama Super Admin',
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6D28D9), width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // EMAIL FIELD (TERKUNCI / READ ONLY)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Alamat Email (Permanen)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(4)),
                        child: Text('Terkunci', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    readOnly: true,
                    enabled: false,
                    controller: TextEditingController(text: _superAdminEmail),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B), fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF76777B)),
                      suffixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFFD94B4B)),
                      filled: true,
                      fillColor: const Color(0xFFF1EEE7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 12, color: Color(0xFF76777B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Email Super Admin terikat dengan otoritas root sistem dan tidak dapat diubah.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE4DFD5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final newName = nameController.text.trim();
                            if (newName.isEmpty) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Nama tidak boleh kosong!'), backgroundColor: Color(0xFFD94B4B)),
                              );
                              return;
                            }
                            setState(() {
                              _superAdminName = newName;
                              _superAdminAvatarPath = tempAvatarPath;
                            });
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('super_admin_name', newName);
                              if (tempAvatarPath != null) {
                                await prefs.setString('super_admin_avatar', tempAvatarPath!);
                              } else {
                                await prefs.remove('super_admin_avatar');
                              }
                            } catch (_) {}

                            if (ctx.mounted) Navigator.pop(ctx);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Profil Super Admin berhasil diperbarui!'),
                                backgroundColor: Color(0xFF17A18A),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D28D9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── 🪪 FITUR INTI: KONFIRMASI PENDAFTARAN KTP (VERIFIKASI KYC IDENTITAS) ───
  Widget _buildKycConfirmationSection(BuildContext context) {
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
                  color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined, color: Color(0xFFE07A5F), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfirmasi Pendaftaran KTP',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Verifikasi berkas identitas KTP pendaftar baru oleh Super Admin',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_pendingKycList.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4DFD5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, size: 36, color: Color(0xFF17A18A)),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak Ada Antrean',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada antrean verifikasi KTP pelanggan yang pending saat ini.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingKycList.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final kyc = _pendingKycList[index];
                return _buildKycItemCard(kyc, index);
              },
            ),

          const SizedBox(height: 16),

          // Action row: Buka Modul KYC Penuh & Generate Pengajuan Baru
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen()));
                  },
                  icon: const Icon(Icons.open_in_new, size: 14, color: Color(0xFF114177)),
                  label: Text(
                    'Buka Modul KYC Penuh',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF114177)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateMoreKyc,
                  icon: const Icon(Icons.autorenew, size: 14, color: Colors.white),
                  label: Text(
                    'Generate Berkas Baru',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07A5F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKycItemCard(Map<String, dynamic> kyc, int index) {
    final name = kyc['name'] ?? '-';
    final nik = kyc['nik'] ?? '-';
    final submittedAt = kyc['submittedAt'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
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
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.hourglass_top_rounded, size: 10, color: Color(0xFFEA580C)),
                                const SizedBox(width: 3),
                                Text(
                                  kyc['status'] ?? 'Menunggu',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFEA580C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Text(
                              'NIK: $nik',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF3F3F46)),
                            ),
                          ),
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: nik));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('NIK ($nik) disalin.'), duration: const Duration(seconds: 2)),
                              );
                            },
                            child: const Icon(Icons.copy_rounded, size: 12, color: Color(0xFF71717A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Lokasi & Tanggal Lahir (cth: Bandung, Jawa Barat • 15 April 2003)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF71717A)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${kyc['city'] ?? ''}${kyc['dob'] != null ? ' • ${kyc['dob']}' : ''}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF71717A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Waktu Pengajuan tepat di bawah lokasi
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF71717A)),
                          const SizedBox(width: 4),
                          Text(
                            submittedAt,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF71717A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, color: Color(0xFFF1EEE7)),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _showKycDetailDialog(kyc, index),
                    icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.white),
                    label: Text(
                      'Lihat & Periksa 2 Foto Berkas',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF114177),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final reason = await showKycRejectReasonDialog(
                              context,
                              applicantName: kyc['name'] ?? 'Pengguna',
                            );
                            if (reason != null && reason.isNotEmpty) {
                              _handleKycAction(index, false, reason);
                            }
                          },
                          icon: const Icon(Icons.close_rounded, size: 13, color: Color(0xFFDC2626)),
                          label: Text(
                            'Tolak',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDC2626)),
                            backgroundColor: const Color(0xFFFEF2F2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleKycAction(index, true),
                          icon: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                          label: Text(
                            'Terima & Setujui',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleKycAction(int index, bool accepted, [String? rejectReason]) async {
    if (index >= _pendingKycList.length) return;
    final item = _pendingKycList[index];
    final kycId = item['id']?.toString();
    setState(() {
      _pendingKycList.removeAt(index);
    });

    if (kycId != null && !kycId.startsWith('KYC-')) {
      try {
        if (accepted) {
          await AdminKycBackend.instance.approveKyc(kycId);
        } else {
          await AdminKycBackend.instance.rejectKyc(kycId, rejectReason ?? 'Ditolak oleh admin');
        }
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accepted
                ? 'Pendaftaran KTP ${item['name']} telah disetujui & diverifikasi.'
                : 'Pendaftaran KTP ${item['name']} telah ditolak. Alasan: ${rejectReason ?? "Tidak memenuhi syarat"}',
          ),
          backgroundColor: accepted ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
        ),
      );
    }
  }

  void _showKycDetailDialog(Map<String, dynamic> kyc, int index) {
    showKycDetailModal(
      context,
      kyc: kyc,
      onAccept: () => _handleKycAction(index, true),
      onRejectWithReason: (reason) => _handleKycAction(index, false, reason),
    );
  }

  void _generateMoreKyc() {
    final names = ['Budi Prasetyo', 'Nadia Putri', 'Indra Wicaksono', 'Laras Kusuma', 'Fajar Ramadhan'];
    final cities = ['Jakarta Selatan, DKI', 'Surabaya, Jatim', 'Denpasar, Bali', 'Medan, Sumut', 'Makassar, Sulsel'];
    final random = math.Random();
    final pickedName = names[random.nextInt(names.length)];
    final pickedCity = cities[random.nextInt(cities.length)];
    final generatedNik = '31710${random.nextInt(899999) + 100000}000${random.nextInt(9) + 1}';

    setState(() {
      _pendingKycList.add({
        'id': 'KYC-00${_pendingKycList.length + 5}',
        'name': pickedName,
        'nik': generatedNik,
        'submittedAt': 'Baru saja',
        'status': 'Menunggu',
        'city': pickedCity,
        'dob': '${random.nextInt(28) + 1} Agustus ${1990 + random.nextInt(15)}',
        'address': 'Jl. Kenanga Timur No. ${random.nextInt(99) + 1}',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengajuan pendaftaran KTP baru atas nama $pickedName berhasil dibuat.'),
        backgroundColor: const Color(0xFFE07A5F),
      ),
    );
  }
}


// ─── CUSTOM PAINTER: SMOOTH MOUNTAIN AREA CHART (TRADING STYLE) ───
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
    this.activePointCount = 0,
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

    // 3. Bangun Area Gunung & Garis Kurva berdasarkan activePointCount
    // Rule:
    // - activePointCount == 0 (belum ada data): Cukup titik hijau di sisi bawah saja (baseline).
    // - activePointCount == 1 (hanya titik pertama yang ada data): Titik hijau di posisi terangkat (posisi ga dibawah), belum membentuk garis.
    // - activePointCount >= 2: Baru membentuk garis kurva & fill area dari titik 0 sampai titik (activePointCount - 1).
    if (activePointCount >= 2) {
      final int count = activePointCount.clamp(2, points.length);
      final List<Offset> activePoints = points.sublist(0, count);

      final path = Path();
      path.moveTo(activePoints.first.dx, baselineY);
      path.lineTo(activePoints.first.dx, activePoints.first.dy);

      const double tension = 0.22;
      for (int i = 0; i < activePoints.length - 1; i++) {
        final Offset p0 = i > 0 ? activePoints[i - 1] : activePoints[0];
        final Offset p1 = activePoints[i];
        final Offset p2 = activePoints[i + 1];
        final Offset p3 = i < activePoints.length - 2 ? activePoints[i + 2] : p2;

        final Offset cp1 = Offset(p1.dx + (p2.dx - p0.dx) * tension, p1.dy + (p2.dy - p0.dy) * tension);
        final Offset cp2 = Offset(p2.dx - (p3.dx - p1.dx) * tension, p2.dy - (p3.dy - p1.dy) * tension);

        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
      }

      path.lineTo(activePoints.last.dx, baselineY);
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

      // Garis Stroke Kurva Utama
      final strokePath = Path();
      strokePath.moveTo(activePoints.first.dx, activePoints.first.dy);

      for (int i = 0; i < activePoints.length - 1; i++) {
        final Offset p0 = i > 0 ? activePoints[i - 1] : activePoints[0];
        final Offset p1 = activePoints[i];
        final Offset p2 = activePoints[i + 1];
        final Offset p3 = i < activePoints.length - 2 ? activePoints[i + 2] : p2;

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

      // Titik intermediate kecil di sepanjang garis aktif
      for (int i = 0; i < activePoints.length - 1; i++) {
        canvas.drawCircle(activePoints[i], 2.5, Paint()..color = lineColor.withValues(alpha: 0.6));
      }
    }

    // 4. Titik Utama / Indikator Live
    if (inspectedIndex == null) {
      if (activePointCount == 0) {
        // Belum ada data: Cukup titik hijau di sisi bawah saja (baseline)
        final Offset emptyDot = Offset(points[0].dx, baselineY);
        canvas.drawCircle(emptyDot, 7, Paint()..color = lineColor.withValues(alpha: 0.25));
        canvas.drawCircle(emptyDot, 4.5, Paint()..color = lineColor);
        canvas.drawCircle(emptyDot, 2.2, Paint()..color = Colors.white);
      } else if (activePointCount == 1) {
        // Sudah ada data titik 1: Titik hijau tapi posisi terangkat (posisi ga dibawah)
        final Offset singleDot = points[0];
        canvas.drawCircle(singleDot, 8, Paint()..color = lineColor.withValues(alpha: 0.3));
        canvas.drawCircle(singleDot, 4.5, Paint()..color = lineColor);
        canvas.drawCircle(singleDot, 2.2, Paint()..color = Colors.white);
      } else {
        // Sudah ada >= 2 titik: Gambar titik puncak & titik terbaru (Live) di ujung kurva aktif
        final int count = activePointCount.clamp(2, points.length);
        int peakIndex = 0;
        double maxVal = data[0];
        for (int i = 1; i < count; i++) {
          if (data[i] > maxVal) {
            maxVal = data[i];
            peakIndex = i;
          }
        }
        if (peakIndex != count - 1 && data[peakIndex] > 0) {
          final peakPoint = points[peakIndex];
          canvas.drawCircle(peakPoint, 7, Paint()..color = lineColor.withValues(alpha: 0.2));
          canvas.drawCircle(peakPoint, 4, Paint()..color = lineColor);
          canvas.drawCircle(peakPoint, 2, Paint()..color = Colors.white);
        }

        // Titik terbaru (Live) di ujung titik aktif (bukan di ujung kanvas points.last)
        final livePoint = points[count - 1];
        canvas.drawCircle(livePoint, 8, Paint()..color = lineColor.withValues(alpha: 0.3));
        canvas.drawCircle(livePoint, 4.5, Paint()..color = lineColor);
        canvas.drawCircle(livePoint, 2.2, Paint()..color = Colors.white);
      }
    }

    // 5. Mode Inspeksi / Crosshair Aktif (Kursor Silang ala TradingView)
    if (inspectedIndex != null && inspectedIndex! >= 0 && inspectedIndex! < points.length) {
      final int maxInspect = activePointCount > 0 ? activePointCount : 1;
      final int safeInspect = inspectedIndex!.clamp(0, maxInspect - 1);
      final Offset inspectPt = (activePointCount == 0 && safeInspect == 0)
          ? Offset(points[0].dx, baselineY)
          : points[safeInspect];

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
      if (safeInspect < pointDates.length && safeInspect < pointValues.length) {
        final tooltipSpan = TextSpan(
          children: [
            TextSpan(
              text: '${pointDates[safeInspect]}  •  ',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD1D5DB),
              ),
            ),
            TextSpan(
              text: pointValues[safeInspect],
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
    }

    // 6. Gambar Sumbu X Label Tanggal di Bawah Setiap Titik
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
  }

  @override
  bool shouldRepaint(covariant _MountainChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.inspectedIndex != inspectedIndex ||
        oldDelegate.activePointCount != activePointCount;
  }
}

// ─── DIALOG WAKTU REALTIME INDONESIA (WIB, WITA, WIT) ───
class _RealtimeTimeZonesDialog extends StatefulWidget {
  const _RealtimeTimeZonesDialog();

  @override
  State<_RealtimeTimeZonesDialog> createState() => _RealtimeTimeZonesDialogState();
}

class _RealtimeTimeZonesDialogState extends State<_RealtimeTimeZonesDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update setiap detik agar detik bergerak secara realtime
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatTime(DateTime dt) =>
      '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}:${_twoDigits(dt.second)}';

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const days = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
    ];
    final dayIndex = dt.weekday == 7 ? 0 : dt.weekday;
    return '${days[dayIndex]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildTimeZoneCard({
    required String zoneName,
    required String fullName,
    required String timeString,
    required String regions,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  zoneName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                timeString,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            fullName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            regions,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    final wib = nowUtc.add(const Duration(hours: 7));
    final wita = nowUtc.add(const Duration(hours: 8));
    final wit = nowUtc.add(const Duration(hours: 9));

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.access_time_filled, color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waktu Saat Ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C1D1F),
                  ),
                ),
                Text(
                  _formatDate(wib),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeZoneCard(
              zoneName: 'WIB',
              fullName: 'Waktu Indonesia Barat (UTC+7)',
              timeString: '${_formatTime(wib)} WIB',
              regions: 'Sumatera, Jawa, Kalimantan Barat & Tengah',
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFFECFDF5),
            ),
            const SizedBox(height: 10),
            _buildTimeZoneCard(
              zoneName: 'WITA',
              fullName: 'Waktu Indonesia Tengah (UTC+8)',
              timeString: '${_formatTime(wita)} WITA',
              regions: 'Sulawesi, Bali, NTB, NTT, Kalsel, Kaltim, Kaltara',
              color: const Color(0xFF3B82F6),
              bgColor: const Color(0xFFEFF6FF),
            ),
            const SizedBox(height: 10),
            _buildTimeZoneCard(
              zoneName: 'WIT',
              fullName: 'Waktu Indonesia Timur (UTC+9)',
              timeString: '${_formatTime(wit)} WIT',
              regions: 'Maluku, Maluku Utara, Papua',
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFF5F3FF),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C1D1F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

