import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Layanan Pengaman Koneksi Jaringan Global (User & Admin)
/// Berjalan murni secara lokal di setiap perangkat (Client-Side Only),
/// tidak menyentuh database atau mengubah data server.
class NetworkSecurityService extends ChangeNotifier with WidgetsBindingObserver {
  static final NetworkSecurityService _instance = NetworkSecurityService._internal();
  factory NetworkSecurityService() => _instance;
  static NetworkSecurityService get instance => _instance;
  NetworkSecurityService._internal();

  // Status koneksi jaringan
  bool _hasConnection = true;
  bool _isChecking = false;
  int _consecutiveFailures = 0;
  Timer? _heartbeatTimer;
  bool _isInitialized = false;

  bool get hasConnection => _hasConnection;
  bool get isChecking => _isChecking;

  /// Inisialisasi awal layanan saat aplikasi pertama kali dijalankan
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);

    // Jalankan pemeriksaan awal
    await checkConnection(force: true);

    // Mulai pemantauan berkala
    _startHeartbeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Saat user kembali dari Pengaturan Jaringan Android ke aplikasi, segera cek koneksi
    if (state == AppLifecycleState.resumed) {
      checkConnection(force: true);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    final interval = _hasConnection ? const Duration(seconds: 4) : const Duration(seconds: 2);
    _heartbeatTimer = Timer.periodic(interval, (_) {
      checkConnection();
    });
  }

  /// Memeriksa ketersediaan koneksi internet
  Future<bool> checkConnection({bool force = false}) async {
    if (kIsWeb) {
      _hasConnection = true;
      return true;
    }

    if (_isChecking && !force) {
      return _hasConnection;
    }

    _isChecking = true;
    notifyListeners();

    bool isOnline = false;

    try {
      // 1. Uji koneksi socket TCP langsung ke Google DNS (8.8.8.8:53) - Sangat cepat & tidak butuh resolusi DNS
      final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(milliseconds: 2200));
      socket.destroy();
      isOnline = true;
    } catch (_) {
      try {
        // 2. Fallback uji socket ke Cloudflare DNS (1.1.1.1:53)
        final socket2 = await Socket.connect('1.1.1.1', 53, timeout: const Duration(milliseconds: 2200));
        socket2.destroy();
        isOnline = true;
      } catch (_) {
        try {
          // 3. Fallback resolusi DNS standar (e.g. google.com)
          final lookup = await InternetAddress.lookup('google.com')
              .timeout(const Duration(milliseconds: 2500));
          isOnline = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
        } catch (_) {
          isOnline = false;
        }
      }
    }

    _isChecking = false;

    if (isOnline) {
      _consecutiveFailures = 0;
      if (!_hasConnection) {
        _hasConnection = true;
        _startHeartbeat();
        notifyListeners();
      } else {
        notifyListeners();
      }
      return true;
    } else {
      _consecutiveFailures++;
      // Butuh 2x kegagalan berturut-turut untuk menghindari false alarm saat beralih Wi-Fi/Seluler,
      // kecuali force: true
      if (_consecutiveFailures >= 2 || force) {
        if (_hasConnection) {
          _hasConnection = false;
          _startHeartbeat(); // interval lebih cepat saat terputus
          notifyListeners();
        } else {
          notifyListeners();
        }
      }
      return false;
    }
  }

  /// Masuk ke Pengaturan Jaringan Android masing-masing perangkat
  Future<void> openNetworkSettings() async {
    if (kIsWeb) return;
    try {
      const platform = MethodChannel('com.example.smart_parking/audio');
      final res = await platform.invokeMethod('openNetworkSettings');
      if (res == true) return;
    } catch (e) {
      debugPrint('[NetworkSecurityService] Native openNetworkSettings failed: $e');
    }

    // Fallback menggunakan permission_handler openAppSettings jika intent khusus tidak didukung ROM tertentu
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('[NetworkSecurityService] openAppSettings fallback failed: $e');
    }
  }

  /// Menutup dan keluar dari aplikasi
  void exitApp() {
    try {
      SystemNavigator.pop();
    } catch (_) {}

    if (!kIsWeb) {
      try {
        exit(0);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}
