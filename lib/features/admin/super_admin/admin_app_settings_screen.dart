import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/maintenance_service.dart';
import 'backend/admin_app_settings_backend.dart';

class AdminAppSettingsScreen extends StatefulWidget {
  const AdminAppSettingsScreen({super.key});

  @override
  State<AdminAppSettingsScreen> createState() => _AdminAppSettingsScreenState();
}

class _AdminAppSettingsScreenState extends State<AdminAppSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Emergency Maintenance Mode
  bool _maintenanceMode = false;
  late final TextEditingController _maintenanceTitleCtrl;
  late final TextEditingController _maintenanceMessageCtrl;
  late final TextEditingController _maintenanceEtaCtrl;

  // Mode Peringatan Saja
  bool _showMaintenanceBannerOnly = false;
  late final TextEditingController _warningTitleCtrl;
  late final TextEditingController _warningMessageCtrl;

  // Modular Maintenance Toggles (OFF = Normal, ON = Sedang Maintenance)
  final Map<String, bool> _moduleToggles = {
    'booking': false,
    'ai': false,
    'kyc': false,
    'push': false,
  };

  @override
  void initState() {
    super.initState();
    AdminAppSettingsBackend.instance.loadSettings();
    // Hanya 2 Tab: Maintenance dan Modul Sistem
    _tabController = TabController(length: 2, vsync: this);

    final service = MaintenanceService.instance;
    _maintenanceMode = service.isGlobalMaintenance;
    _maintenanceTitleCtrl = TextEditingController(text: service.maintenanceTitle);
    _maintenanceMessageCtrl = TextEditingController(text: service.maintenanceMessage);
    _maintenanceEtaCtrl = TextEditingController(text: service.maintenanceEta);

    _showMaintenanceBannerOnly = service.isWarningOnly;
    _warningTitleCtrl = TextEditingController(text: service.warningTitle);
    _warningMessageCtrl = TextEditingController(text: service.warningMessage);

    // Default semua toggle modul adalah OFF (Beroperasi normal)
    _moduleToggles['booking'] = service.isBookingMaintenance;
    _moduleToggles['ai'] = service.isAiMaintenance;
    _moduleToggles['kyc'] = service.isKycMaintenance;
    _moduleToggles['push'] = service.isPushMaintenance;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maintenanceTitleCtrl.dispose();
    _maintenanceMessageCtrl.dispose();
    _maintenanceEtaCtrl.dispose();
    _warningTitleCtrl.dispose();
    _warningMessageCtrl.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A18),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF76777B),
              ),
            ),
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
                  color: (_maintenanceMode ? const Color(0xFFC0392B) : const Color(0xFF14B8A6))
                      .withValues(alpha: 0.3),
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
                  _maintenanceMode ? 'Layanan Publik Terkunci' : 'Platform Beroperasi Penuh',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _maintenanceMode
                      ? 'Aplikasi pengguna umum dinonaktifkan sementara. Pengguna akan melihat pop-up pemeliharaan sistem dan menerima push notifikasi Android.'
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
                    labelText: 'Judul Pengumuman Pop-up',
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
                    labelText: 'Isi Pesan Pop-up & Notifikasi',
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

          // PENGATURAN MODE PERINGATAN SAJA (Banner Pengumuman)
          _buildSectionTitle(
            'Mode Peringatan Saja',
            subtitle: 'Tampilkan pesan pengumuman tanpa memblokir seluruh akses dan pemesanan aplikasi',
          ),

          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Aktifkan Mode Peringatan Saja (Banner Info)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A18),
                    ),
                  ),
                  subtitle: Text(
                    'Pengguna tetap dapat memesan tiket, hanya dimunculkan banner peringatan di layar utama.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                  ),
                  value: _showMaintenanceBannerOnly,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _showMaintenanceBannerOnly = v),
                ),
                if (_showMaintenanceBannerOnly) ...[
                  const Divider(height: 24, color: Color(0xFFF1EEE7)),
                  Text(
                    'Kustomisasi Pesan Banner Peringatan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF114177),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _warningTitleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Judul Peringatan',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _warningMessageCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Isi Pesan Peringatan',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: _saveMaintenanceConfig,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                'Simpan Konfigurasi Maintenance',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
              ),
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

  Future<void> _saveMaintenanceConfig() async {
    await AdminAppSettingsBackend.instance.saveMaintenanceSettings(
      isGlobal: _maintenanceMode,
      title: _maintenanceTitleCtrl.text,
      message: _maintenanceMessageCtrl.text,
      eta: _maintenanceEtaCtrl.text,
      isWarningOnly: _showMaintenanceBannerOnly,
      warningTitle: _warningTitleCtrl.text,
      warningMessage: _warningMessageCtrl.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Konfigurasi Maintenance Berhasil Disimpan & Diterapkan!',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF17A18A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmMaintenanceToggle(bool activate) async {
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
                'Mengaktifkan mode maintenance akan MENGUNCI akses aplikasi seluruh pengguna dan memunculkan pop-up pemeliharaan sistem.',
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
                    const Icon(Icons.notifications_active, size: 18, color: Color(0xFFD94B4B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Push notifikasi Android juga akan dikirimkan otomatis ke bilah notifikasi pengguna dengan judul dan isi pesan yang telah Anda tentukan.',
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
                setState(() {
                  _maintenanceMode = true;
                });
                Navigator.pop(ctx);
                await AdminAppSettingsBackend.instance.saveMaintenanceSettings(
                  isGlobal: true,
                  title: _maintenanceTitleCtrl.text,
                  message: _maintenanceMessageCtrl.text,
                  eta: _maintenanceEtaCtrl.text,
                  isWarningOnly: _showMaintenanceBannerOnly,
                  warningTitle: _warningTitleCtrl.text,
                  warningMessage: _warningMessageCtrl.text,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'MODE MAINTENANCE AKTIF! Pop-up & push notifikasi Android telah dikirimkan.',
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
      });
      await AdminAppSettingsBackend.instance.saveMaintenanceSettings(
        isGlobal: false,
        title: _maintenanceTitleCtrl.text,
        message: _maintenanceMessageCtrl.text,
        eta: _maintenanceEtaCtrl.text,
        isWarningOnly: _showMaintenanceBannerOnly,
        warningTitle: _warningTitleCtrl.text,
        warningMessage: _warningMessageCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mode maintenance DIMATIKAN. Layanan publik kembali normal.',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF17A18A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // TAB 2: GLOBAL MODULE TOGGLES (Hanya Gateway & Modul Utama, default OFF)
  Widget _buildModulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Gateway & Modul Utama',
          ),
          _buildCard(
            child: Column(
              children: [
                _buildModularToggleRow(
                  'booking',
                  'Gateway Booking Tiket',
                  'Jika aktif, pemesanan tiket di-lockdown dan memunculkan pop-up maintenance booking. Fitur jelajah tetap aktif.',
                  Icons.event_available,
                  const Color(0xFF114177),
                ),
                const Divider(height: 20, color: Color(0xFFF1EEE7)),
                _buildModularToggleRow(
                  'ai',
                  'Engine AI Assistant',
                  'Jika aktif, layanan asisten chat AI dimatikan sementara. Fitur jelajah dan booking tetap berjalan.',
                  Icons.smart_toy_outlined,
                  const Color(0xFF6D28D9),
                ),
                const Divider(height: 20, color: Color(0xFFF1EEE7)),
                _buildModularToggleRow(
                  'kyc',
                  'Modul Wajib KYC KTP',
                  'Jika aktif, modul verifikasi identitas KTP dinonaktifkan sementara untuk pembaharuan.',
                  Icons.verified_user_outlined,
                  const Color(0xFF17A18A),
                ),
                const Divider(height: 20, color: Color(0xFFF1EEE7)),
                _buildModularToggleRow(
                  'push',
                  'Gateway Push Notification',
                  'Jika aktif, pengiriman siaran notifikasi dan alert darurat ditunda sementara.',
                  Icons.notifications_active_outlined,
                  const Color(0xFFE07A5F),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton.icon(
              onPressed: () async {
                await AdminAppSettingsBackend.instance.saveAllModuleToggles(_moduleToggles);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pengaturan Modul Sistem Tersimpan dan Berlaku!',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: const Color(0xFF17A18A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(
                'Simpan Status Modul Sistem',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
              ),
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

  Widget _buildModularToggleRow(
    String key,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final isMaintenanceOn = _moduleToggles[key] ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (isMaintenanceOn ? const Color(0xFFD94B4B) : iconColor).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isMaintenanceOn ? Icons.build_circle_rounded : icon,
            size: 22,
            color: isMaintenanceOn ? const Color(0xFFD94B4B) : iconColor,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A18),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMaintenanceOn
                          ? const Color(0xFFFDE8E4)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isMaintenanceOn ? 'MAINTENANCE' : 'NORMAL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: isMaintenanceOn
                            ? const Color(0xFFD94B4B)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF76777B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isMaintenanceOn,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFFD94B4B),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFD1D5DB),
          onChanged: (newVal) {
            setState(() {
              _moduleToggles[key] = newVal;
            });
            AdminAppSettingsBackend.instance.updateModuleToggle(key, newVal);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  newVal
                      ? '$title diatur ke MODE MAINTENANCE.'
                      : '$title kembali BEROPERASI NORMAL.',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
                backgroundColor: newVal ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
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
              Text(
                'Pengaturan Global Platform',
                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
              Text(
                'Maintenance Lockdown & Modul Sistem',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: const Color(0xFF114177),
            unselectedLabelColor: const Color(0xFF76777B),
            indicatorColor: const Color(0xFF114177),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.power_settings_new, size: 18), text: 'Maintenance'),
              Tab(icon: Icon(Icons.tune, size: 18), text: 'Modul Sistem'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMaintenanceTab(),
            _buildModulesTab(),
          ],
        ),
      ),
    );
  }
}