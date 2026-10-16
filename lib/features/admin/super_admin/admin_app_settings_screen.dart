import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAppSettingsScreen extends StatefulWidget {
  const AdminAppSettingsScreen({super.key});

  @override
  State<AdminAppSettingsScreen> createState() => _AdminAppSettingsScreenState();
}

class _AdminAppSettingsScreenState extends State<AdminAppSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Emergency Maintenance Mode
  bool _maintenanceMode = false;
  final TextEditingController _maintenanceTitleCtrl = TextEditingController(
    text: 'Sistem Sedang Dalam Pemeliharaan Terjadwal',
  );
  final TextEditingController _maintenanceMessageCtrl = TextEditingController(
    text: 'ParkSmart sedang melakukan peningkatan infrastruktur server. Seluruh akses pemesanan tiket sementara dihentikan demi keamanan data Anda.',
  );
  final TextEditingController _maintenanceEtaCtrl = TextEditingController(
    text: '2 Jam (Selesai pukul 05:00 WIB)',
  );
  bool _allowAdminBypass = true;
  bool _showMaintenanceBannerOnly = false;

  // Global Feature Toggles (Domain Super Admin)
  final Map<String, bool> _globalToggles = {
    'maintenance_mode': false,
    'enable_booking_gateway': true,
    'enable_ai_assistant': true,
    'enable_kyc_verification': true,
    'enable_push_notifications': true,
    'enable_biometric_auth': false,
    'enable_blockchain_audit': true,
    'enable_crash_reporting': true,
    'enable_multi_language': true,
    'enable_offline_cache': true,
  };

  // Notification Templates (Sistem & Darurat)
  final Map<String, TextEditingController> _notificationTemplates = {
    'system_maintenance': TextEditingController(
      text: 'ParkSmart akan melakukan maintenance pada {date} {time}. Seluruh sesi parkir berjalan tetap aman.',
    ),
    'maintenance_ended': TextEditingController(
      text: 'Pemeliharaan sistem telah selesai. Seluruh layanan ParkSmart kini kembali beroperasi normal.',
    ),
    'security_alert': TextEditingController(
      text: 'Pemberitahuan Keamanan: Terdeteksi perubahan penting pada pengaturan sistem platform.',
    ),
    'emergency_broadcast': TextEditingController(
      text: 'Pengumuman Penting: Harap ikuti arahan petugas di lokasi terkait penataan ulang area parkir.',
    ),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maintenanceTitleCtrl.dispose();
    _maintenanceMessageCtrl.dispose();
    _maintenanceEtaCtrl.dispose();
    for (var ctrl in _notificationTemplates.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: child,
    );
  }

  // TAB 1: EMERGENCY MAINTENANCE MODE
  Widget _buildMaintenanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Status Utama
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _maintenanceMode
                    ? [const Color(0xFF8B0000), const Color(0xFFC0392B)]
                    : [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_maintenanceMode ? const Color(0xFFC0392B) : const Color(0xFF14B8A6)).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _maintenanceMode ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _maintenanceMode ? 'STATUS: MAINTENANCE AKTIF' : 'STATUS: LIVE ONLINE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _maintenanceMode,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFFE07A5F),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white30,
                      onChanged: (val) {
                        _confirmMaintenanceToggle(val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _maintenanceMode
                      ? 'Layanan Publik Terkunci'
                      : 'Platform Beroperasi Penuh',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _maintenanceMode
                      ? 'Aplikasi pengguna umum dinonaktifkan sementara. Pengguna akan melihat layar darurat pemeliharaan sistem.'
                      : 'Seluruh pengguna dapat mencari slot, reservasi parkir, dan melakukan transaksi secara normal.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          _buildSectionTitle(
            'Konfigurasi Layar Pemeliharaan',
            subtitle: 'Pesan yang akan ditampilkan kepada pengguna saat mode maintenance aktif',
          ),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _maintenanceTitleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Judul Pengumuman',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title, color: Color(0xFF114177)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _maintenanceMessageCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Isi Pesan / Penjelasan Teknis',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _maintenanceEtaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Estimasi Waktu Selesai (Downtime ETA)',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.timer_outlined, color: Color(0xFF114177)),
                  ),
                ),
              ],
            ),
          ),

          _buildSectionTitle(
            'Kebijakan Akses Darurat',
            subtitle: 'Pengecualian akses untuk tim administrator selama masa perbaikan',
          ),

          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Izinkan Akses Admin (Bypass Whitelist)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)),
                  ),
                  subtitle: Text(
                    'Admin tetap dapat login ke dashboard untuk memantau server dan perbaikan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  ),
                  value: _allowAdminBypass,
                  activeThumbColor: const Color(0xFF114177),
                  onChanged: (v) => setState(() => _allowAdminBypass = v),
                ),
                const Divider(height: 20, color: Color(0xFFF1EEE7)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Mode Peringatan Saja (Banner Info)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)),
                  ),
                  subtitle: Text(
                    'Tampilkan banner maintenance tanpa memblokir pemesanan user',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  ),
                  value: _showMaintenanceBannerOnly,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _showMaintenanceBannerOnly = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Konfigurasi Mode Maintenance Disimpan ke Server!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFF17A18A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text('Simpan Konfigurasi Maintenance', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C1D1F),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmMaintenanceToggle(bool activate) {
    if (activate) {
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
                  'Aktifkan Mode Maintenance?',
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
                'Mengaktifkan mode maintenance akan MENGHENTIKAN akses seluruh aplikasi pengguna saat ini.',
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
                        'User tidak akan bisa memesan tiket parkir hingga mode ini dimatikan kembali oleh Super Admin.',
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
              onPressed: () {
                setState(() {
                  _maintenanceMode = true;
                  _globalToggles['maintenance_mode'] = true;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'MODE MAINTENANCE DIAKTIFKAN. Akses pengguna dikunci.',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFFD94B4B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.lock, size: 16, color: Colors.white),
              label: Text(
                'Kunci & Aktifkan',
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
      setState(() {
        _maintenanceMode = false;
        _globalToggles['maintenance_mode'] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mode maintenance DIMATIKAN. Layanan publik kembali normal.', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF17A18A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // TAB 2: GLOBAL MODULE TOGGLES
  Widget _buildModulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Gateway & Modul Utama', subtitle: 'Aktifkan atau nonaktifkan modul platform secara instan'),
          _buildCard(
            child: Column(
              children: [
                _buildToggleRow(
                  'enable_booking_gateway',
                  'Gateway Booking Tiket',
                  'Izinkan aplikasi user membuat transaksi booking baru',
                  Icons.event_available,
                  const Color(0xFF114177),
                ),
                const Divider(height: 16, color: Color(0xFFF1EEE7)),
                _buildToggleRow(
                  'enable_ai_assistant',
                  'Engine AI Assistant',
                  'Akses asisten pencarian parkir pintar untuk pelanggan',
                  Icons.smart_toy_outlined,
                  const Color(0xFF6D28D9),
                ),
                const Divider(height: 16, color: Color(0xFFF1EEE7)),
                _buildToggleRow(
                  'enable_kyc_verification',
                  'Modul Wajib KYC KTP',
                  'Wajibkan verifikasi identitas KTP sebelum pemesanan',
                  Icons.verified_user_outlined,
                  const Color(0xFF17A18A),
                ),
                const Divider(height: 16, color: Color(0xFFF1EEE7)),
                _buildToggleRow(
                  'enable_push_notifications',
                  'Gateway Push Notification',
                  'Kirim peringatan parkir, overstay, dan tiket via FCM',
                  Icons.notifications_active_outlined,
                  const Color(0xFFE07A5F),
                ),
              ],
            ),
          ),

          _buildSectionTitle('Infrastruktur & Keamanan', subtitle: 'Parameter stabilitas sistem dan integritas platform'),
          _buildCard(
            child: Column(
              children: [
                _buildToggleRow(
                  'enable_blockchain_audit',
                  'Audit Trail Imutabel (SHA-256)',
                  'Catat setiap transaksi sensitif ke dalam ledger audit log',
                  Icons.link,
                  const Color(0xFF114177),
                ),
                const Divider(height: 16, color: Color(0xFFF1EEE7)),
                _buildToggleRow(
                  'enable_biometric_auth',
                  'Autentikasi Biometrik Paksa',
                  'Wajibkan sidik jari/FaceID untuk aksi sensitif admin',
                  Icons.fingerprint,
                  const Color(0xFF45474A),
                ),
                const Divider(height: 16, color: Color(0xFFF1EEE7)),
                _buildToggleRow(
                  'enable_crash_reporting',
                  'Auto Crash & Error Telemetry',
                  'Kirim rekaman crash aplikasi secara anonim ke backend',
                  Icons.bug_report_outlined,
                  const Color(0xFFD94B4B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String key, String title, String subtitle, IconData icon, Color iconColor) {
    final value = _globalToggles[key] ?? true;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: iconColor,
          onChanged: (newVal) {
            setState(() {
              _globalToggles[key] = newVal;
            });
          },
        ),
      ],
    );
  }

  // TAB 3: SYSTEM NOTIFICATION TEMPLATES
  Widget _buildTemplatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Template Pesan Sistem & Siaran',
            subtitle: 'Format teks otomatis untuk notifikasi pemeliharaan dan pengumuman platform',
          ),
          ..._notificationTemplates.entries.map((entry) {
            final labels = {
              'system_maintenance': 'Jadwal Pemeliharaan Mendatang',
              'maintenance_ended': 'Pemberitahuan Sistem Normal Kembali',
              'security_alert': 'Peringatan Keamanan & SOP',
              'emergency_broadcast': 'Siaran Evakuasi / Lapangan Darurat',
            };
            return _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        labels[entry.key] ?? entry.key,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EEE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(entry.key, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF76777B))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: entry.value,
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pengaturan Global Platform', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('Maintenance Lockdown & Modul Sistem', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF114177),
            unselectedLabelColor: const Color(0xFF76777B),
            indicatorColor: const Color(0xFF114177),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.power_settings_new, size: 18), text: 'Maintenance Mode'),
              Tab(icon: Icon(Icons.tune, size: 18), text: 'Modul Sistem'),
              Tab(icon: Icon(Icons.campaign_outlined, size: 18), text: 'Template Pesan'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMaintenanceTab(),
            _buildModulesTab(),
            _buildTemplatesTab(),
          ],
        ),
      ),
    );
  }
}