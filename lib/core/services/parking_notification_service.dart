import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ─── PARKING URGENT NOTIFICATION SERVICE ───
/// Mengelola siklus penuh notifikasi darurat sesi parkir:
/// 1. Trigger notif saat timer parkir tersisa ≤ 10 menit
/// 2. Notif berulang setiap 3 menit jika user tidak merespons
/// 3. Berhenti jika diklik user atau sesi diperpanjang (extend)
/// 4. Bekerja bahkan saat aplikasi di-background / ditutup
class ParkingNotificationService {
  static final ParkingNotificationService _instance =
      ParkingNotificationService._internal();
  factory ParkingNotificationService() => _instance;
  ParkingNotificationService._internal();

  static const int _urgentNotifId = 777;
  static const String _kSessionActive = 'ps_parking_session_active';
  static const String _kExpectedCheckout = 'ps_parking_expected_checkout';
  static const String _kNotifDismissed = 'ps_parking_notif_dismissed';
  static const String _kLastNotifTime = 'ps_parking_last_urgent_notif_time';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _pluginInitialized = false;
  Timer? _repeatTimer;
  bool _urgentActive = false;

  // ─── INISIALISASI PLUGIN ──────────────────────────────────────────────────

  static Future<void> _ensurePluginInitialized() async {
    if (_pluginInitialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.id == _urgentNotifId || response.payload == 'expiring_session') {
          _markNotifDismissed();
          ParkingNotificationService().stopUrgentNotification();
        }
      },
      onDidReceiveBackgroundNotificationResponse: _notifBackgroundHandler,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      // Buat channel darurat dengan custom sound
      const urgentChannel = AndroidNotificationChannel(
        'urgent_channel_v4',
        'Urgent Parking Notifications',
        description: 'Peringatan waktu parkir dengan suara darurat',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('sound_darurat'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
      );
      await androidPlugin.createNotificationChannel(urgentChannel);

      // Buat channel untuk background monitor service
      const bgChannel = AndroidNotificationChannel(
        'parking_background_channel',
        'ParkSmart Background Monitor',
        description: 'Memantau waktu parkir aktif di latar belakang',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      );
      await androidPlugin.createNotificationChannel(bgChannel);
    }

    _pluginInitialized = true;
  }

  static Future<void> _markNotifDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifDismissed, true);
    } catch (_) {}
  }

  // ─── SIMPAN STATE SESI ────────────────────────────────────────────────────

  Future<void> saveActiveSession({required DateTime expectedCheckout}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSessionActive, true);
      await prefs.setInt(
          _kExpectedCheckout, expectedCheckout.millisecondsSinceEpoch);
      await prefs.setBool(_kNotifDismissed, false);
      await prefs.setInt(_kLastNotifTime, 0);
      debugPrint('[ParkingNotif] Sesi disimpan. Checkout: $expectedCheckout');
    } catch (e) {
      debugPrint('[ParkingNotif] saveActiveSession error: $e');
    }
  }

  Future<void> clearActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSessionActive, false);
      await prefs.remove(_kExpectedCheckout);
      await prefs.setBool(_kNotifDismissed, false);
      await prefs.remove(_kLastNotifTime);
    } catch (_) {}
  }

  // ─── NOTIFIKASI DARURAT ───────────────────────────────────────────────────

  static Future<void> _showUrgentNotif({String? customBody, int minsLeft = 10}) async {
    await _ensurePluginInitialized();
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'urgent_channel_v4',
        'Urgent Parking Notifications',
        channelDescription: 'Peringatan waktu parkir dengan suara darurat',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('sound_darurat'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        fullScreenIntent: true,
        autoCancel: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'perpanjang_id',
            'Perpanjang Waktu',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'checkout_id',
            'Checkout Sekarang',
            showsUserInterface: true,
          ),
        ],
      );
      const NotificationDetails details =
          NotificationDetails(android: androidDetails);
      await _plugin.show(
        id: _urgentNotifId,
        title: '⚠️ Sisa Waktu Parkir $minsLeft Menit!',
        body: customBody ??
            'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout untuk menghindari denda.',
        notificationDetails: details,
        payload: 'expiring_session',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLastNotifTime, DateTime.now().millisecondsSinceEpoch);
      debugPrint('[ParkingNotif] Notif darurat ditampilkan ($minsLeft menit)');
    } catch (e) {
      debugPrint('[ParkingNotif] _showUrgentNotif error: $e');
    }
  }

  Future<void> cancelUrgentNotification() async {
    await _ensurePluginInitialized();
    _urgentActive = false;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    try {
      await _plugin.cancel(id: _urgentNotifId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifDismissed, true);
      debugPrint('[ParkingNotif] Notif darurat dibatalkan');
    } catch (e) {
      debugPrint('[ParkingNotif] cancelUrgentNotification error: $e');
    }
  }

  Future<void> stopUrgentNotification() async => cancelUrgentNotification();

  // ─── TRIGGER UTAMA ────────────────────────────────────────────────────────

  /// Dipanggil saat timer parkir mencapai sisa ≤ 10 menit (600 detik).
  Future<void> triggerUrgentWarning({int remainingSeconds = 600}) async {
    if (_urgentActive) return;
    _urgentActive = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifDismissed, false);
    } catch (_) {}

    final mins = (remainingSeconds / 60).ceil();
    await _showUrgentNotif(
      minsLeft: mins,
      customBody:
          'Sisa $mins menit waktu parkir Anda! Segera perpanjang atau checkout untuk menghindari denda.',
    );

    // Ulang setiap 3 menit jika belum direspons
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final dismissed = prefs.getBool(_kNotifDismissed) ?? false;
        final sessionActive = prefs.getBool(_kSessionActive) ?? false;
        if (dismissed || !sessionActive || !_urgentActive) {
          _repeatTimer?.cancel();
          _repeatTimer = null;
          _urgentActive = false;
          return;
        }
      } catch (_) {}

      if (!_urgentActive) return;
      await _showUrgentNotif(
        minsLeft: 10,
        customBody: 'Waktu parkir hampir habis! Segera perpanjang atau checkout sekarang.',
      );
      debugPrint('[ParkingNotif] Notif diulang (3 menit)');
    });
  }

  /// Dipanggil setelah extend sesi berhasil
  Future<void> onSessionExtended({required DateTime newExpectedCheckout}) async {
    _urgentActive = false;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    await cancelUrgentNotification();
    await saveActiveSession(expectedCheckout: newExpectedCheckout);
    // Start ulang background monitor dengan waktu baru
    await ParkingNotificationService.startBackgroundMonitor(
      expectedCheckout: newExpectedCheckout,
    );
    debugPrint('[ParkingNotif] Sesi diperpanjang. Checkout baru: $newExpectedCheckout');
  }

  /// Dipanggil saat sesi parkir berakhir / checkout
  Future<void> onSessionEnded() async {
    _urgentActive = false;
    _repeatTimer?.cancel();
    _repeatTimer = null;
    await cancelUrgentNotification();
    await clearActiveSession();
    await ParkingNotificationService.stopBackgroundMonitor();
    debugPrint('[ParkingNotif] Sesi berakhir, semua notifikasi dihentikan.');
  }

  // ─── BACKGROUND SERVICE ───────────────────────────────────────────────────

  static Future<void> initBackgroundService() async {
    // Pastikan channel notifikasi sudah terdaftar di sistem Android terlebih dahulu
    await _ensurePluginInitialized();

    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onBackgroundStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'parking_background_channel',
        initialNotificationTitle: 'ParkSmart',
        initialNotificationContent: 'Memantau sesi parkir aktif di latar belakang...',
        foregroundServiceNotificationId: 778,
        autoStartOnBoot: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onBackgroundStart,
        onBackground: onIosBackground,
      ),
    );
    debugPrint('[ParkingNotif] Background service dikonfigurasi.');
  }

  static Future<void> startBackgroundMonitor({
    required DateTime expectedCheckout,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSessionActive, true);
      await prefs.setInt(
          _kExpectedCheckout, expectedCheckout.millisecondsSinceEpoch);
      await prefs.setBool(_kNotifDismissed, false);
      await prefs.setInt(_kLastNotifTime, 0);
    } catch (_) {}

    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
      debugPrint('[ParkingNotif] Background monitor dimulai.');
    }
  }

  static Future<void> stopBackgroundMonitor() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    debugPrint('[ParkingNotif] Background monitor dihentikan.');
  }
}

// ─── BACKGROUND HANDLERS (Top-level — wajib untuk isolate) ───────────────

@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final plugin = FlutterLocalNotificationsPlugin();
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await plugin.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.id == 777 || response.payload == 'expiring_session') {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('ps_parking_notif_dismissed', true);
          await plugin.cancel(id: 777);
        } catch (_) {}
      }
    },
    onDidReceiveBackgroundNotificationResponse: _notifBackgroundHandler,
  );

  // Pastikan Notification Channel terdaftar di dalam Background Isolate Android
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (androidPlugin != null) {
    const bgChannel = AndroidNotificationChannel(
      'parking_background_channel',
      'ParkSmart Background Monitor',
      description: 'Memantau waktu parkir aktif di latar belakang',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await androidPlugin.createNotificationChannel(bgChannel);

    const urgentChannel = AndroidNotificationChannel(
      'urgent_channel_v4',
      'Urgent Parking Notifications',
      description: 'Peringatan waktu parkir dengan suara darurat',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('sound_darurat'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
    );
    await androidPlugin.createNotificationChannel(urgentChannel);
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
    // Set notification content yang valid untuk foreground service
    service.setForegroundNotificationInfo(
      title: 'ParkSmart',
      content: 'Memantau sesi parkir aktif di latar belakang...',
    );
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Cek setiap 15 detik di latar belakang
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionActive =
          prefs.getBool('ps_parking_session_active') ?? false;
      if (!sessionActive) {
        timer.cancel();
        service.stopSelf();
        return;
      }

      final checkoutMs = prefs.getInt('ps_parking_expected_checkout');
      if (checkoutMs == null) return;

      final checkoutTime = DateTime.fromMillisecondsSinceEpoch(checkoutMs);
      final remaining = checkoutTime.difference(DateTime.now());
      final remainingSeconds = remaining.inSeconds;
      final dismissed =
          prefs.getBool('ps_parking_notif_dismissed') ?? false;

      debugPrint(
          '[ParkingBG] Sisa: ${remaining.inMinutes}m${remaining.inSeconds % 60}s | dismissed: $dismissed');

      if (remainingSeconds <= 0) {
        await prefs.setBool('ps_parking_session_active', false);
        await plugin.cancel(id: 777);
        timer.cancel();
        service.stopSelf();
        return;
      }

      // Jika sisa ≤ 10 menit (600 detik) dan belum ditutup/dismissed oleh user
      if (remainingSeconds <= 600 && !dismissed) {
        final lastNotifMs = prefs.getInt('ps_parking_last_urgent_notif_time') ?? 0;
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final elapsedMs = nowMs - lastNotifMs;

        // Bunyikan segera saat pertama kali mencapai 10 menit,
        // lalu bunyikan berulang setiap 3 menit (180.000 ms) jika tidak ada tindakan
        if (lastNotifMs == 0 || elapsedMs >= 180000) {
          final minsLeft = (remainingSeconds / 60).ceil();
          await _bgShowUrgentNotif(plugin, minsLeft: minsLeft > 0 ? minsLeft : 1);
          await prefs.setInt('ps_parking_last_urgent_notif_time', nowMs);
          debugPrint('[ParkingBG] Notif darurat dikirim ($minsLeft menit). Mengulang dalam 3 menit jika belum direspons.');
        }
      }
    } catch (e) {
      debugPrint('[ParkingBG] Monitor error: $e');
    }
  });
}

Future<void> _bgShowUrgentNotif(FlutterLocalNotificationsPlugin plugin,
    {int minsLeft = 10}) async {
  try {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'urgent_channel_v4',
      'Urgent Parking Notifications',
      channelDescription: 'Peringatan waktu parkir dengan suara darurat',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('sound_darurat'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      autoCancel: true,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'perpanjang_id',
          'Perpanjang Waktu',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'checkout_id',
          'Checkout Sekarang',
          showsUserInterface: true,
        ),
      ],
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);
    await plugin.show(
      id: 777,
      title: '⚠️ Sisa Waktu Parkir $minsLeft Menit!',
      body: 'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout untuk menghindari denda.',
      notificationDetails: details,
      payload: 'expiring_session',
    );
    debugPrint('[ParkingBG] Notif BG ditampilkan ($minsLeft menit tersisa)');
  } catch (e) {
    debugPrint('[ParkingBG] _bgShowUrgentNotif error: $e');
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// Handler notifikasi dari background (top-level, diperlukan oleh flutter_local_notifications)
@pragma('vm:entry-point')
void _notifBackgroundHandler(NotificationResponse response) async {
  if (response.id == 777 || response.payload == 'expiring_session') {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ps_parking_notif_dismissed', true);
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancel(id: 777);
    } catch (_) {}
  }
}
