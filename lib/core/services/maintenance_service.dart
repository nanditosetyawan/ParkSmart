import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Service sentral untuk mengelola status Maintenance Global dan Modular Platform
class MaintenanceService extends ChangeNotifier {
  static final MaintenanceService _instance = MaintenanceService._internal();
  factory MaintenanceService() => _instance;
  static MaintenanceService get instance => _instance;
  MaintenanceService._internal();

  // Keys SharedPreferences
  static const String _kGlobalActive = 'sys_maintenance_global_active';
  static const String _kTitle = 'sys_maintenance_title';
  static const String _kMessage = 'sys_maintenance_message';
  static const String _kEta = 'sys_maintenance_eta';
  static const String _kWarningOnly = 'sys_maintenance_warning_only';
  static const String _kWarningTitle = 'sys_warning_title';
  static const String _kWarningMessage = 'sys_warning_message';

  // Modul Keys (Default: OFF / False = Beroperasi Normal)
  static const String _kModBooking = 'sys_mod_maint_booking';
  static const String _kModAi = 'sys_mod_maint_ai';
  static const String _kModKyc = 'sys_mod_maint_kyc';
  static const String _kModPush = 'sys_mod_maint_push';

  // Global State
  bool _isGlobalMaintenance = false;
  String _maintenanceTitle = 'Sistem Sedang Dalam Pemeliharaan Terjadwal';
  String _maintenanceMessage =
      'ParkSmart sedang melakukan peningkatan server. Seluruh akses pemesanan tiket sementara ditutup demi kestabilan sistem dan keamanan data.';
  String _maintenanceEta = '2 Jam (Selesai pukul 05:00 WIB)';

  bool _isWarningOnly = false;
  String _warningTitle = 'Pemberitahuan Pemeliharaan Sistem';
  String _warningMessage =
      'Sistem saat ini sedang dalam pemeliharaan rutin. Seluruh layanan aplikasi tetap dapat diakses dan digunakan secara normal.';

  // Modular Maintenance States (Default: False / Normal)
  bool _isBookingMaintenance = false;
  bool _isAiMaintenance = false;
  bool _isKycMaintenance = false;
  bool _isPushMaintenance = false;

  // Getters
  bool get isGlobalMaintenance => _isGlobalMaintenance;
  String get maintenanceTitle => _maintenanceTitle;
  String get maintenanceMessage => _maintenanceMessage;
  String get maintenanceEta => _maintenanceEta;

  bool get isWarningOnly => _isWarningOnly;
  String get warningTitle => _warningTitle;
  String get warningMessage => _warningMessage;

  bool get isBookingMaintenance => _isBookingMaintenance;
  bool get isAiMaintenance => _isAiMaintenance;
  bool get isKycMaintenance => _isKycMaintenance;
  bool get isPushMaintenance => _isPushMaintenance;

  /// Inisialisasi awal saat aplikasi start
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGlobalMaintenance = prefs.getBool(_kGlobalActive) ?? false;
      _maintenanceTitle = prefs.getString(_kTitle) ?? _maintenanceTitle;
      _maintenanceMessage = prefs.getString(_kMessage) ?? _maintenanceMessage;
      _maintenanceEta = prefs.getString(_kEta) ?? _maintenanceEta;
      _isWarningOnly = prefs.getBool(_kWarningOnly) ?? false;
      _warningTitle = prefs.getString(_kWarningTitle) ?? _warningTitle;
      _warningMessage = prefs.getString(_kWarningMessage) ?? _warningMessage;

      // Default module toggles are OFF (false)
      _isBookingMaintenance = prefs.getBool(_kModBooking) ?? false;
      _isAiMaintenance = prefs.getBool(_kModAi) ?? false;
      _isKycMaintenance = prefs.getBool(_kModKyc) ?? false;
      _isPushMaintenance = prefs.getBool(_kModPush) ?? false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error init MaintenanceService: $e');
    }
  }

  /// Update pengaturan maintenance global
  Future<void> setGlobalMaintenance(
    bool active, {
    String? title,
    String? message,
    String? eta,
    bool? warningOnly,
    bool notifyPush = true,
  }) async {
    _isGlobalMaintenance = active;
    if (title != null && title.trim().isNotEmpty) _maintenanceTitle = title.trim();
    if (message != null && message.trim().isNotEmpty) _maintenanceMessage = message.trim();
    if (eta != null && eta.trim().isNotEmpty) _maintenanceEta = eta.trim();
    if (warningOnly != null) _isWarningOnly = warningOnly;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kGlobalActive, _isGlobalMaintenance);
      await prefs.setString(_kTitle, _maintenanceTitle);
      await prefs.setString(_kMessage, _maintenanceMessage);
      await prefs.setString(_kEta, _maintenanceEta);
      await prefs.setBool(_kWarningOnly, _isWarningOnly);
    } catch (_) {}

    notifyListeners();

    // Trigger Android push notification jika maintenance global diaktifkan
    if (active && notifyPush) {
      await NotificationService().showMaintenanceNotification(
        title: _maintenanceTitle,
        body: _maintenanceMessage,
      );
    }
  }

  /// Update pengaturan mode peringatan saja
  Future<void> setWarningOnlySettings(
    bool warningOnly, {
    String? title,
    String? message,
  }) async {
    _isWarningOnly = warningOnly;
    if (title != null && title.trim().isNotEmpty) _warningTitle = title.trim();
    if (message != null && message.trim().isNotEmpty) _warningMessage = message.trim();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kWarningOnly, _isWarningOnly);
      await prefs.setString(_kWarningTitle, _warningTitle);
      await prefs.setString(_kWarningMessage, _warningMessage);
    } catch (_) {}

    notifyListeners();
  }

  /// Update modul toggle (OFF = Normal, ON = Sedang Maintenance)
  Future<void> setModuleMaintenance(String moduleKey, bool isMaintenance) async {
    switch (moduleKey) {
      case 'booking':
        _isBookingMaintenance = isMaintenance;
        break;
      case 'ai':
        _isAiMaintenance = isMaintenance;
        break;
      case 'kyc':
        _isKycMaintenance = isMaintenance;
        break;
      case 'push':
        _isPushMaintenance = isMaintenance;
        break;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      switch (moduleKey) {
        case 'booking':
          await prefs.setBool(_kModBooking, isMaintenance);
          break;
        case 'ai':
          await prefs.setBool(_kModAi, isMaintenance);
          break;
        case 'kyc':
          await prefs.setBool(_kModKyc, isMaintenance);
          break;
        case 'push':
          await prefs.setBool(_kModPush, isMaintenance);
          break;
      }
    } catch (_) {}

    notifyListeners();
  }

  /// Tampilkan Pop-Up Dialog Maintenance Global ke Layar Pengguna
  static Future<void> showGlobalMaintenanceDialog(BuildContext context) {
    final s = MaintenanceService.instance;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon Pulsing / Peringatan
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E4),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 2),
                ),
                child: const Icon(Icons.build_circle_rounded, size: 40, color: Color(0xFFD94B4B)),
              ),
              const SizedBox(height: 18),
              // Badge Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'PEMELIHARAAN SISTEM',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDC2626),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Judul dari Super Admin
              Text(
                s.maintenanceTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A18),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              // Pesan dari Super Admin
              Text(
                s.maintenanceMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF5A5B60),
                  height: 1.5,
                ),
              ),
              if (s.maintenanceEta.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF475569)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Estimasi: ${s.maintenanceEta}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Tombol Periksa Status / Refresh
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (s.isGlobalMaintenance && !s.isWarningOnly) {
                      // Jika masih aktif, tampilkan kembali snackbar feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Sistem masih dalam masa perbaikan. Harap menunggu hingga selesai.',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFFD94B4B),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                  label: Text(
                    'Periksa Status Kembali',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C1D1F),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tampilkan Pop-Up Dialog Maintenance Modular (misal Gateway Booking)
  static Future<void> showModularMaintenanceDialog(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.lock_clock_rounded,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFD97706), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MODUL DALAM PEMELIHARAAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF1A1A18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.45,
                color: const Color(0xFF4A4B4F),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFF0F766E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fitur lain seperti peta jelajah, detail parkir, dan AI Assistant tetap beroperasi normal.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF0F766E),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C1D1F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Mengerti',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
