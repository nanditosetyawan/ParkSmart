import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'session_service.dart';
import '../../main.dart' show navigatorKey;
import '../../features/auth/login_screen.dart';

/// Service sentral untuk mengelola status Maintenance Global, Mode Peringatan, dan Modular Platform
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

  // Dialog state tracking (mencegah duplikasi dialog saat sinkronisasi realtime)
  bool _isGlobalDialogOpen = false;
  BuildContext? _activeDialogContext;
  Timer? _syncTimer;

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
  bool get isGlobalDialogOpen => _isGlobalDialogOpen;

  /// Cek apakah modul tertentu sedang dalam pemeliharaan
  bool isModuleInMaintenance(String moduleKey) {
    if (SessionService.instance.isAdmin) return false;
    switch (moduleKey.toLowerCase()) {
      case 'booking':
        return _isBookingMaintenance;
      case 'ai':
        return _isAiMaintenance;
      case 'kyc':
        return _isKycMaintenance;
      case 'push':
        return _isPushMaintenance;
      default:
        return false;
    }
  }

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

      // Sinkronkan data aktual dari Supabase
      await checkStatusFromRemote();

      // Jalankan sinkronisasi background secara berkala
      startStatusSync();
    } catch (e) {
      debugPrint('Error init MaintenanceService: $e');
    }
  }

  /// Memeriksa status langsung dari Supabase database
  Future<bool> checkStatusFromRemote() async {
    try {
      SupabaseClient? client;
      try {
        client = Supabase.instance.client;
      } catch (_) {
        // Supabase belum diinisialisasi (misal di test environment)
        return _isGlobalMaintenance && !_isWarningOnly;
      }

      final res = await client
          .from('system_settings')
          .select('key, value')
          .inFilter('key', ['maintenance_mode', 'modular_maintenance']);

      for (var row in res) {
        if (row['key'] == 'maintenance_mode' && row['value'] is Map) {
          final val = row['value'] as Map<String, dynamic>;
          _isGlobalMaintenance = val['is_active'] == true;
          if (val['title'] != null && val['title'].toString().trim().isNotEmpty) {
            _maintenanceTitle = val['title'].toString().trim();
          }
          if (val['message'] != null && val['message'].toString().trim().isNotEmpty) {
            _maintenanceMessage = val['message'].toString().trim();
          }
          if (val['eta'] != null && val['eta'].toString().trim().isNotEmpty) {
            _maintenanceEta = val['eta'].toString().trim();
          }
          if (val['warning_only'] != null) {
            _isWarningOnly = val['warning_only'] == true;
          }
          if (val['warning_title'] != null && val['warning_title'].toString().trim().isNotEmpty) {
            _warningTitle = val['warning_title'].toString().trim();
          }
          if (val['warning_message'] != null && val['warning_message'].toString().trim().isNotEmpty) {
            _warningMessage = val['warning_message'].toString().trim();
          }
        } else if (row['key'] == 'modular_maintenance' && row['value'] is Map) {
          final modMap = row['value'] as Map<String, dynamic>;
          if (modMap.containsKey('booking')) _isBookingMaintenance = modMap['booking'] == true;
          if (modMap.containsKey('ai')) _isAiMaintenance = modMap['ai'] == true;
          if (modMap.containsKey('kyc')) _isKycMaintenance = modMap['kyc'] == true;
          if (modMap.containsKey('push')) _isPushMaintenance = modMap['push'] == true;
        }
      }

      // Simpan pembaruan ke cache SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kGlobalActive, _isGlobalMaintenance);
      await prefs.setString(_kTitle, _maintenanceTitle);
      await prefs.setString(_kMessage, _maintenanceMessage);
      await prefs.setString(_kEta, _maintenanceEta);
      await prefs.setBool(_kWarningOnly, _isWarningOnly);
      await prefs.setString(_kWarningTitle, _warningTitle);
      await prefs.setString(_kWarningMessage, _warningMessage);

      await prefs.setBool(_kModBooking, _isBookingMaintenance);
      await prefs.setBool(_kModAi, _isAiMaintenance);
      await prefs.setBool(_kModKyc, _isKycMaintenance);
      await prefs.setBool(_kModPush, _isPushMaintenance);

      notifyListeners();

      // Kembalikan apakah Global Lockdown aktif
      return _isGlobalMaintenance && !_isWarningOnly;
    } catch (e) {
      debugPrint('[MaintenanceService] checkStatusFromRemote error: $e');
      // Jika terjadi kegagalan jaringan, pertahankan status aman yang tersimpan
      return _isGlobalMaintenance && !_isWarningOnly;
    }
  }

  /// Mulai sinkronisasi periodik status di background (setiap 10 detik)
  void startStatusSync({Duration interval = const Duration(seconds: 10)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) async {
      final isLockdown = await checkStatusFromRemote();
      // Jika pemeliharaan nonaktif ATAU pengguna saat ini adalah akun admin, pastikan pop-up tertutup
      if ((!isLockdown || SessionService.instance.isAdmin) && _isGlobalDialogOpen && _activeDialogContext != null) {
        try {
          if (Navigator.of(_activeDialogContext!).canPop()) {
            Navigator.of(_activeDialogContext!).pop();
          }
        } catch (_) {}
        _isGlobalDialogOpen = false;
        _activeDialogContext = null;
      }
    });
  }

  void stopStatusSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Update pengaturan maintenance global & sinkronkan langsung ke Supabase
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

    // Sinkronkan ke Supabase system_settings agar tersimpan di cloud & tidak ditimpa background timer
    try {
      final client = Supabase.instance.client;
      await client.from('system_settings').upsert({
        'key': 'maintenance_mode',
        'value': {
          'is_active': _isGlobalMaintenance,
          'title': _maintenanceTitle,
          'message': _maintenanceMessage,
          'eta': _maintenanceEta,
          'warning_only': _isWarningOnly,
          'warning_title': _warningTitle,
          'warning_message': _warningMessage,
        },
        'description': 'Status darurat pemeliharaan sistem global dan banner peringatan',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[MaintenanceService] Gagal sinkronisasi setGlobalMaintenance ke Supabase: $e');
    }

    notifyListeners();

    // Trigger Android push notification jika maintenance global diaktifkan
    if (active && notifyPush && !_isPushMaintenance) {
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
    switch (moduleKey.toLowerCase()) {
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
      switch (moduleKey.toLowerCase()) {
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
  /// Menghalangi interaksi, tidak bisa di-back/dismiss, tombol periksa status aktual.
  static Future<void> showGlobalMaintenanceDialog(BuildContext context) async {
    // Akun admin (Super Admin, Ops, Finance, CS) 100% bebas dari pembatasan pemeliharaan
    if (SessionService.instance.isAdmin) return;

    final s = MaintenanceService.instance;
    if (s._isGlobalDialogOpen) return;
    s._isGlobalDialogOpen = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        s._activeDialogContext = ctx;
        bool isChecking = false;
        String? feedbackMessage;
        Color feedbackColor = const Color(0xFFDC2626);

        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (dialogCtx, setDialogState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ikon Pemeliharaan
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
                    // Judul Pengumuman Pop-up
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
                    // Isi Pesan Pop-up & Notifikasi
                    Text(
                      s.maintenanceMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF5A5B60),
                        height: 1.5,
                      ),
                    ),
                    // Estimasi Downtime ETA
                    if (s.maintenanceEta.trim().isNotEmpty) ...[
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
                    // Feedback jika pemeriksaan status dilakukan
                    if (feedbackMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: feedbackColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: feedbackColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          feedbackMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: feedbackColor,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    // Tombol Periksa Status Kembali
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isChecking
                            ? null
                            : () async {
                                setDialogState(() {
                                  isChecking = true;
                                  feedbackMessage = null;
                                });

                                try {
                                  final isLockdown = await s.checkStatusFromRemote();

                                  if (!isLockdown) {
                                    // Status normal terverifikasi! Tutup pop-up
                                    s._isGlobalDialogOpen = false;
                                    s._activeDialogContext = null;
                                    if (ctx.mounted) {
                                      Navigator.of(ctx).pop();
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Status normal terverifikasi. Layanan aplikasi kembali beroperasi!',
                                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                                          ),
                                          backgroundColor: const Color(0xFF10B981),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } else {
                                    // Masih dalam masa maintenance! POP-UP TETAP TERBUKA & PENGGUNA TETAP DIBLOKIR
                                    setDialogState(() {
                                      isChecking = false;
                                      feedbackMessage = 'Sistem masih dalam pemeliharaan terjadwal. Harap menunggu hingga perbaikan selesai.';
                                      feedbackColor = const Color(0xFFDC2626);
                                    });
                                  }
                                } catch (e) {
                                  // Kegagalan jaringan / error: TETAP BLOKIR
                                  setDialogState(() {
                                    isChecking = false;
                                    feedbackMessage = 'Gagal memeriksa status jaringan. Pembatasan tetap diberlakukan demi kestabilan.';
                                    feedbackColor = const Color(0xFFDC2626);
                                  });
                                }
                              },
                        icon: isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.refresh, size: 16, color: Colors.white),
                        label: Text(
                          isChecking ? 'Memeriksa Status...' : 'Periksa Status Kembali',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1D1F),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tombol Keluar Akun / Akses Portal Admin
                    TextButton.icon(
                      onPressed: () async {
                        s._isGlobalDialogOpen = false;
                        s._activeDialogContext = null;
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        await SessionService.instance.clearSession();
                        final nav = navigatorKey.currentState;
                        if (nav != null) {
                          nav.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, size: 15, color: Color(0xFF76777B)),
                      label: Text(
                        'Keluar Akun (Ke Halaman Masuk / Portal Admin)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF76777B),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    s._isGlobalDialogOpen = false;
    s._activeDialogContext = null;
  }

  /// Tampilkan Pop-Up Dialog Mode Peringatan Saja (Warning Only Mode)
  /// Menampilkan judul & deskripsi peringatan, TANPA estimasi waktu, tombol "Oke" menutup pop-up.
  static Future<void> showWarningDialog(BuildContext context) {
    if (SessionService.instance.isAdmin) return Future.value();
    final s = MaintenanceService.instance;
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Informasi / Peringatan
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFDE68A), width: 2),
              ),
              child: const Icon(Icons.info_outline_rounded, size: 38, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 18),
            // Badge Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PEMBERITAHUAN SISTEM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD97706),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Judul Peringatan
            Text(
              s.warningTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A18),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            // Isi Pesan Peringatan (Tanpa Estimasi Downtime)
            Text(
              s.warningMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF5A5B60),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Tombol Oke
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1D1F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Oke',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tampilkan Pop-Up Dialog Maintenance Modular (misal Gateway Booking, AI, KYC)
  static Future<void> showModularMaintenanceDialog(
    BuildContext context, {
    String title = 'Modul Sedang Dalam Pemeliharaan',
    String message =
        'Modul ini sedang menjalani pemeliharaan sementara. Silakan coba kembali setelah layanan tersedia.',
    IconData icon = Icons.lock_clock_rounded,
  }) {
    if (SessionService.instance.isAdmin) return Future.value();
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
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
                      'Fitur lain pada aplikasi tetap dapat beroperasi normal.',
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
              onPressed: () => Navigator.of(ctx).pop(),
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
