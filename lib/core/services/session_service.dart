import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/login_screen.dart';
import '../../features/profile/backend/profile_backend.dart';
import '../../features/profile/backend/payment_methods_backend.dart';
import '../../features/checkout/backend/checkout_backend.dart';
import '../../features/home/backend/home_backend.dart';
import '../../main.dart' show navigatorKey;

/// Layanan Pengelola Sesi Terpadu (User & Admin) - ParkSmart ID
/// Mengatur batas waktu tidak aktif (Inactivity Timeout) dan background session
/// selama 30 menit. Jika waktu habis, sistem otomatis melakukan logout demi keamanan.
class SessionService with WidgetsBindingObserver {
  static final SessionService instance = SessionService._internal();
  factory SessionService() => instance;
  SessionService._internal();

  /// Durasi batas waktu sesi tidak aktif / latar belakang: 30 Menit
  static const Duration sessionTimeout = Duration(minutes: 30);

  // Storage Keys
  static const String _kIsLoggedIn = 'ps_session_is_logged_in';
  static const String _kUserType = 'ps_session_user_type';
  static const String _kIdentifier = 'ps_session_identifier';
  static const String _kUserId = 'ps_session_user_id';
  static const String _kUserName = 'ps_session_user_name';
  static const String _kAdminRole = 'ps_session_admin_role';
  static const String _kLastActiveTime = 'ps_session_last_active_time';
  static const String _kBackgroundTime = 'ps_session_background_time';

  // In-memory state
  bool _isLoggedIn = false;
  String? _userType; // 'user' | 'admin'
  String? _identifier;
  String? _userId;
  String? _userName;
  String? _adminRole;
  DateTime? _lastActiveTime;
  DateTime? _backgroundTime;
  DateTime? _lastDiskWriteTime;

  bool _sessionExpiredOnStartup = false;
  bool get sessionExpiredOnStartup => _sessionExpiredOnStartup;

  Timer? _inactivityCheckTimer;
  Timer? _backgroundTimeoutTimer;

  bool get isLoggedIn => _isLoggedIn;
  String? get userType => _userType;
  String? get identifier => _identifier;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get adminRole => _adminRole;

  /// Sisa waktu sesi aktif sebelum logout otomatis
  Duration get remainingTime {
    if (!_isLoggedIn || _lastActiveTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastActiveTime!);
    final remaining = sessionTimeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Format sisa waktu menit:detik (contoh: 29:45)
  String get formattedRemainingTime {
    final rem = remainingTime;
    final minutes = rem.inMinutes;
    final seconds = rem.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Inisialisasi awal saat aplikasi dibuka di main.dart
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;
      _userType = prefs.getString(_kUserType);
      _identifier = prefs.getString(_kIdentifier);
      _userId = prefs.getString(_kUserId);
      _userName = prefs.getString(_kUserName);
      _adminRole = prefs.getString(_kAdminRole);

      final lastActiveMs = prefs.getInt(_kLastActiveTime);
      final backgroundMs = prefs.getInt(_kBackgroundTime);

      if (_isLoggedIn) {
        final referenceMs = backgroundMs ?? lastActiveMs;
        if (referenceMs != null && referenceMs > 0) {
          final referenceTime = DateTime.fromMillisecondsSinceEpoch(referenceMs);
          final elapsed = DateTime.now().difference(referenceTime);

          if (elapsed >= sessionTimeout) {
            // Sesi kedaluwarsa saat aplikasi ditutup/dimatikan lebih dari 30 menit
            debugPrint('[SessionService] Sesi kedaluwarsa saat cold start: $elapsed > 30 menit. Auto logout.');
            await clearSession();
            _sessionExpiredOnStartup = true;
          } else {
            // Sesi masih valid
            _lastActiveTime = DateTime.now();
            await _persistLastActiveTime(_lastActiveTime!);
            _startInactivityCheckTimer();
            debugPrint('[SessionService] Sesi dipulihkan. Sisa waktu: $formattedRemainingTime');
          }
        } else {
          _lastActiveTime = DateTime.now();
          _startInactivityCheckTimer();
        }
      }
    } catch (e) {
      debugPrint('[SessionService] Error init: $e');
    }
  }

  /// Mengambil dan me-reset status sesi kedaluwarsa saat cold start
  bool consumeSessionExpiredOnStartup() {
    final expired = _sessionExpiredOnStartup;
    _sessionExpiredOnStartup = false;
    return expired;
  }

  /// Memulai sesi login baru (baik untuk Pengguna biasa maupun Admin)
  Future<void> startSession({
    required String userType,
    required String identifier,
    required String userName,
    String? userId,
    String? adminRole,
  }) async {
    _isLoggedIn = true;
    _userType = userType;
    _identifier = identifier;
    _userId = userId;
    _userName = userName;
    _adminRole = adminRole;
    _lastActiveTime = DateTime.now();
    _backgroundTime = null;
    _sessionExpiredOnStartup = false;

    _backgroundTimeoutTimer?.cancel();
    _backgroundTimeoutTimer = null;
    _startInactivityCheckTimer();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIsLoggedIn, true);
      await prefs.setString(_kUserType, userType);
      await prefs.setString(_kIdentifier, identifier);
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(_kUserId, userId);
      } else {
        await prefs.remove(_kUserId);
      }
      await prefs.setString(_kUserName, userName);
      if (adminRole != null) {
        await prefs.setString(_kAdminRole, adminRole);
      } else {
        await prefs.remove(_kAdminRole);
      }
      await prefs.setInt(_kLastActiveTime, _lastActiveTime!.millisecondsSinceEpoch);
      await prefs.remove(_kBackgroundTime);
    } catch (e) {
      debugPrint('[SessionService] Error startSession: $e');
    }

    debugPrint('[SessionService] Sesi $userType dimulai untuk $userName ($identifier, uid: $userId). Batas waktu: 30 menit.');
  }

  /// Mencatat sentuhan/interaksi pengguna di layar agar countdown 30 menit diperbarui
  void recordUserActivity() {
    if (!_isLoggedIn) return;

    final now = DateTime.now();
    _lastActiveTime = now;

    // Batasi penulisan ke disk (SharedPreferences) minimal setiap 15 detik untuk optimasi performa
    if (_lastDiskWriteTime == null || now.difference(_lastDiskWriteTime!).inSeconds >= 15) {
      _lastDiskWriteTime = now;
      _persistLastActiveTime(now);
    }
  }

  Future<void> _persistLastActiveTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLastActiveTime, time.millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Memulai pengecekan periodik ketika aplikasi sedang aktif di layar
  void _startInactivityCheckTimer() {
    _inactivityCheckTimer?.cancel();
    _inactivityCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isLoggedIn || _lastActiveTime == null) return;

      final elapsed = DateTime.now().difference(_lastActiveTime!);
      if (elapsed >= sessionTimeout) {
        debugPrint('[SessionService] Inactivity timeout tercapai (30 menit tanpa interaksi). Auto logout.');
        logoutDueToTimeout();
      }
    });
  }

  /// Menangani perubahan siklus hidup aplikasi (Foreground / Background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isLoggedIn) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Aplikasi diminimalkan / masuk latar belakang / layar terkunci
      _onAppBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      // Aplikasi dibuka kembali ke latar depan
      _onAppResumed();
    }
  }

  /// Dipanggil saat aplikasi berpindah ke background
  void _onAppBackgrounded() {
    final now = DateTime.now();
    _backgroundTime = now;

    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_kBackgroundTime, now.millisecondsSinceEpoch);
    });

    // Jalankan timer 30 menit di memori jika proses masih hidup di background
    _backgroundTimeoutTimer?.cancel();
    _backgroundTimeoutTimer = Timer(sessionTimeout, () {
      debugPrint('[SessionService] Background 30 menit timer habis di background. Menandai sesi expired.');
      clearSession();
    });

    debugPrint('[SessionService] Aplikasi masuk latar belakang. Waktu mulai hitung 30 menit: $now');
  }

  /// Dipanggil saat aplikasi dibuka kembali dari background
  void _onAppResumed() {
    _backgroundTimeoutTimer?.cancel();
    _backgroundTimeoutTimer = null;

    if (!_isLoggedIn) return;

    final now = DateTime.now();
    final referenceTime = _backgroundTime ?? _lastActiveTime ?? now;
    final elapsed = now.difference(referenceTime);

    debugPrint('[SessionService] Aplikasi kembali ke layar. Waktu di latar belakang: ${elapsed.inMinutes} menit ${elapsed.inSeconds % 60} detik');

    if (elapsed >= sessionTimeout) {
      debugPrint('[SessionService] Waktu di latar belakang melebihi 30 menit! Auto logout dipicu.');
      logoutDueToTimeout();
    } else {
      // Masih dalam batas 30 menit, reset waktu aktif
      _lastActiveTime = now;
      _backgroundTime = null;
      _persistLastActiveTime(now);
      SharedPreferences.getInstance().then((prefs) => prefs.remove(_kBackgroundTime));
    }
  }

  /// Melakukan logout otomatis karena batas waktu 30 menit habis
  Future<void> logoutDueToTimeout() async {
    if (!_isLoggedIn) return;

    debugPrint('[SessionService] Menjalankan logout otomatis karena sesi habis...');
    await clearSession();

    // Reset sesi di ProfileBackend
    try {
      ProfileBackend.instance.setLoggedInUser(
        id: '',
        fullName: '',
        email: '',
        phone: '',
        memberTier: 'BRONZE',
        walletBalance: 0,
      );
    } catch (_) {}

    // Sign out dari Supabase
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}

    // Bersihkan sesi aktif admin dari SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_admin_name');
      await prefs.remove('current_admin_email');
      await prefs.remove('current_admin_role');
    } catch (_) {}

    // Arahkan navigasi ke LoginScreen dengan parameter sessionExpired: true
    try {
      final nav = navigatorKey.currentState;
      if (nav != null) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(sessionExpired: true),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('[SessionService] Error redirecting to LoginScreen: $e');
    }
  }

  /// Membersihkan seluruh data sesi (Manual Logout atau Timeout)
  Future<void> clearSession() async {
    _isLoggedIn = false;
    _userType = null;
    _identifier = null;
    _userId = null;
    _userName = null;
    _adminRole = null;
    _lastActiveTime = null;
    _backgroundTime = null;

    _inactivityCheckTimer?.cancel();
    _inactivityCheckTimer = null;
    _backgroundTimeoutTimer?.cancel();
    _backgroundTimeoutTimer = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIsLoggedIn, false);
      await prefs.remove(_kUserType);
      await prefs.remove(_kIdentifier);
      await prefs.remove(_kUserId);
      await prefs.remove(_kUserName);
      await prefs.remove(_kAdminRole);
      await prefs.remove(_kLastActiveTime);
      await prefs.remove(_kBackgroundTime);
      await prefs.remove('user_profile_id');
      await prefs.remove('user_profile_name');
      await prefs.remove('user_profile_email');
      await prefs.remove('user_profile_phone');
    } catch (e) {
      debugPrint('[SessionService] Error clearSession: $e');
    }

    // Reset seluruh backend in-memory state agar data akun sebelumnya tidak bocor
    try {
      ProfileBackend.instance.clearProfile();
    } catch (_) {}
    try {
      PaymentMethodsBackend.instance.clear();
    } catch (_) {}
    try {
      CheckoutBackend.instance.clear();
    } catch (_) {}
    try {
      HomeBackend.instance.clear();
    } catch (_) {}
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityCheckTimer?.cancel();
    _backgroundTimeoutTimer?.cancel();
  }
}
