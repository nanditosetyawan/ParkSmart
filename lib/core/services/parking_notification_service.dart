import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'session_service.dart';
import '../../features/notification/backend/notification_backend.dart';

/// ─── PARKING URGENT NOTIFICATION SERVICE ───
/// Mengelola siklus penuh notifikasi darurat sesi parkir:
/// 1. Trigger notif saat timer parkir tersisa ≤ 10 menit atau ditekan oleh petugas lapangan (Admin Operasional)
/// 2. Notif push melayang (Heads-up) dengan suara darurat (sound_darurat.mp3) diputar berulang (LOOP)
///    menggunakan native FLAG_INSISTENT sampai user membuka notifikasi
/// 3. Berhenti berbunyi jika diklik user, ditutup, atau sesi diperpanjang (extend)
/// 4. Bekerja baik saat aplikasi aktif (Foreground Realtime) maupun saat di-background / di-clear (Background Service)
class ParkingNotificationService {
  static final ParkingNotificationService _instance =
      ParkingNotificationService._internal();
  factory ParkingNotificationService() => _instance;
  ParkingNotificationService._internal();

  static const int _urgentNotifId = 777;
  static const String _kUrgentChannelId = 'urgent_parking_alarm_v5';
  static const String _kUrgentChannelName = 'Peringatan Darurat Parkir (Alarm)';
  static const String _kUrgentChannelDesc = 'Peringatan mendesak waktu parkir dengan alarm suara darurat looping';

  static const String _kSessionActive = 'ps_parking_session_active';
  static const String _kExpectedCheckout = 'ps_parking_expected_checkout';
  static const String _kNotifDismissed = 'ps_parking_notif_dismissed';
  static const String _kLastNotifTime = 'ps_parking_last_urgent_notif_time';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _pluginInitialized = false;
  Timer? _repeatTimer;
  bool _urgentActive = false;
  RealtimeChannel? _realtimeUrgentChannel;

  // ─── INISIALISASI PLUGIN ──────────────────────────────────────────────────

  static Future<void> _ensurePluginInitialized() async {
    if (_pluginInitialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.id == _urgentNotifId ||
            response.payload == 'expiring_session' ||
            response.actionId == 'stop_alarm' ||
            response.actionId == 'checkout_id' ||
            response.actionId == 'perpanjang_id') {
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

      // Buat channel darurat dengan custom sound looping
      final urgentChannel = AndroidNotificationChannel(
        _kUrgentChannelId,
        _kUrgentChannelName,
        description: _kUrgentChannelDesc,
        importance: Importance.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('sound_darurat'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
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

  // ─── NOTIFIKASI DARURAT ALARM (LOOPING SOUND & HEADS-UP) ──────────────────

  /// Menampilkan notifikasi push melayang (Heads-up) dengan suara darurat
  /// yang berbunyi secara berulang (LOOP) sampai dibuka oleh pengguna.
  static Future<void> showUrgentAlarmNotification({
    String? title,
    String? body,
    int? minsLeft,
  }) async {
    // 🛡️ PROTEKSI 1: Cek apakah sesi saat ini adalah Admin
    final session = SessionService.instance;
    if (session.isAdmin || session.userType == 'admin') {
      debugPrint('[ParkingNotif] BLOCKED: HP Admin dilarang membunyikan alarm darurat / sound_darurat!');
      return;
    }

    // 🛡️ PROTEKSI 2: Cek fallback dari SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('ps_session_user_type');
      final adminEmail = prefs.getString('current_admin_email');
      final adminRole = prefs.getString('current_admin_role');
      if (userType == 'admin' || (adminEmail != null && adminEmail.isNotEmpty) || (adminRole != null && adminRole.isNotEmpty)) {
        debugPrint('[ParkingNotif] BLOCKED: SharedPreferences mendeteksi peran Admin. Alarm dibatalkan.');
        return;
      }
    } catch (_) {}

    await _ensurePluginInitialized();
    try {
      final androidDetails = AndroidNotificationDetails(
        _kUrgentChannelId,
        _kUrgentChannelName,
        channelDescription: _kUrgentChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('sound_darurat'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        // Native Android FLAG_INSISTENT (4): Audio berbunyi berulang (loop) sampai dibuka/dismiss
        additionalFlags: Int32List.fromList(<int>[4]),
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction(
            'perpanjang_id',
            'Perpanjang Waktu',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'checkout_id',
            'Buka Tiket',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'stop_alarm',
            'Matikan Alarm',
            cancelNotification: true,
          ),
        ],
      );
      final details = NotificationDetails(android: androidDetails);
      await _plugin.show(
        id: _urgentNotifId,
        title: title ?? (minsLeft != null ? '⚠️ Sisa Waktu Parkir $minsLeft Menit!' : '⚠️ Peringatan Darurat Parkir!'),
        body: body ?? 'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout untuk menghindari denda.',
        notificationDetails: details,
        payload: 'expiring_session',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLastNotifTime, DateTime.now().millisecondsSinceEpoch);
      await prefs.setBool(_kNotifDismissed, false);
      debugPrint('[ParkingNotif] showUrgentAlarmNotification berhasil dibunyikan dengan loop sound!');
    } catch (e) {
      debugPrint('[ParkingNotif] showUrgentAlarmNotification error: $e');
    }
  }

  static Future<void> _showUrgentNotif({String? customBody, int minsLeft = 10}) async {
    await showUrgentAlarmNotification(
      title: '⚠️ Sisa Waktu Parkir $minsLeft Menit!',
      body: customBody ?? 'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout untuk menghindari denda.',
      minsLeft: minsLeft,
    );
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
      debugPrint('[ParkingNotif] Notif darurat dibatalkan & suara loop berhenti');
    } catch (e) {
      debugPrint('[ParkingNotif] cancelUrgentNotification error: $e');
    }
  }

  Future<void> stopUrgentNotification() async => cancelUrgentNotification();

  /// Trigger notifikasi darurat manual (identik dengan tombol Developer Options Profil & Pengingat Petugas)
  static Future<void> showSystemUrgentNotificationDirectly({BuildContext? context}) async {
    await showUrgentAlarmNotification(
      title: '⚠️ Sisa Waktu Parkir 10 Menit!',
      body: 'Waktu parkir hampir habis. Segera perpanjang atau checkout.',
      minsLeft: 10,
    );
  }

  // ─── REALTIME LISTENER NOTIFIKASI DARURAT DARI OPERASIONAL (FOREGROUND) ───

  /// Berlangganan event INSERT di tabel `system_notifications` secara realtime
  /// Ketika Admin Operasional menekan "Kirim Pengingat", event langsung tiba di HP user
  void startRealtimeUrgentListener() {
    // 🛡️ JANGAN PERNAH jalankan listener ini jika peran yang aktif adalah Admin!
    final session = SessionService.instance;
    if (session.isAdmin || session.userType == 'admin') {
      debugPrint('[ParkingNotif] Device aktif sebagai Admin, menolak startRealtimeUrgentListener.');
      stopRealtimeUrgentListener();
      return;
    }

    final currentUid = session.userId;
    if (currentUid == null || currentUid.isEmpty) return;

    if (_realtimeUrgentChannel != null) return;
    try {
      final client = Supabase.instance.client;
      _realtimeUrgentChannel = client.channel('public:urgent_user_notif_$currentUid')
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'system_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'recipient_user_id',
            value: currentUid,
          ),
          callback: (payload) {
            // 🛡️ 1. Cek apakah HP ini sedang aktif sebagai Admin
            final activeSession = SessionService.instance;
            if (activeSession.isAdmin || activeSession.userType == 'admin') {
              debugPrint('[ParkingNotif] Realtime callback diabaikan: Device adalah Admin.');
              return;
            }

            final newRow = payload.newRecord;
            final recipientId = newRow['recipient_user_id']?.toString();
            final myUid = activeSession.userId;

            // 🛡️ 2. Pastikan notifikasi ini BENAR-BENAR ditujukan ke user HP ini (bukan user lain / broadcast admin)
            if (myUid == null || myUid.isEmpty || recipientId == null || recipientId != myUid) {
              debugPrint('[ParkingNotif] Realtime urgent diabaikan: recipientId ($recipientId) != myUid ($myUid)');
              return;
            }

            final targetRole = newRow['target_role']?.toString().toLowerCase();
            if (targetRole != null && targetRole != 'user' && targetRole != 'all') {
              debugPrint('[ParkingNotif] Diabaikan karena target_role bukan user ($targetRole)');
              return;
            }

            final nType = newRow['notification_type']?.toString().toLowerCase();
            final aType = newRow['action_type']?.toString().toLowerCase();

            if (nType == 'urgent' || aType == 'expiring_session') {
              debugPrint('[ParkingNotif] Realtime urgent notif terverifikasi untuk user $myUid!');
              final title = newRow['title']?.toString() ?? '⚠️ Sisa Waktu Parkir 10 Menit!';
              final message = newRow['message']?.toString() ?? 'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout.';
              showUrgentAlarmNotification(title: title, body: message);

              // Update badge & daftar notifikasi di dalam aplikasi
              NotificationBackend.instance.fetchNotifications();
            }
          },
        )
        ..subscribe();
      debugPrint('[ParkingNotif] Realtime urgent listener aktif untuk user: $currentUid');
    } catch (e) {
      debugPrint('[ParkingNotif] startRealtimeUrgentListener error: $e');
    }
  }

  void stopRealtimeUrgentListener() {
    _realtimeUrgentChannel?.unsubscribe();
    _realtimeUrgentChannel = null;
  }

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

    final urgentChannel = AndroidNotificationChannel(
      'urgent_parking_alarm_v5',
      'Peringatan Darurat Parkir (Alarm)',
      description: 'Peringatan mendesak waktu parkir dengan alarm suara darurat looping',
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('sound_darurat'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
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

      // 🛡️ PROTEKSI LATAR BELAKANG: Jika HP ini sedang digunakan oleh Admin, jangan pernah cek/bunyikan alarm user!
      final userType = prefs.getString('ps_session_user_type');
      final adminEmail = prefs.getString('current_admin_email');
      final adminRole = prefs.getString('current_admin_role');
      if (userType == 'admin' || (adminEmail != null && adminEmail.isNotEmpty) || (adminRole != null && adminRole.isNotEmpty)) {
        return;
      }

      // ─── 1. CEK NOTIFIKASI DARURAT DARI ADMIN LAPANGAN DI SUPABASE (BACKGROUND / KILLED) ───
      final supabaseUrl = prefs.getString('supabase_url');
      final supabaseAnonKey = prefs.getString('supabase_anon_key');
      final currentUserId = prefs.getString('ps_session_user_id');

      if (supabaseUrl != null &&
          supabaseAnonKey != null &&
          currentUserId != null &&
          currentUserId.isNotEmpty) {
        try {
          final uri = Uri.parse(
            '$supabaseUrl/rest/v1/system_notifications?recipient_user_id=eq.$currentUserId&is_read=eq.false&notification_type=eq.urgent&order=created_at.desc&limit=1',
          );
          final res = await http.get(uri, headers: {
            'apikey': supabaseAnonKey,
            'Authorization': 'Bearer $supabaseAnonKey',
            'Accept': 'application/json',
          }).timeout(const Duration(seconds: 5));

          if (res.statusCode == 200) {
            final List<dynamic> notifs = jsonDecode(res.body);
            if (notifs.isNotEmpty) {
              final latestNotif = notifs.first as Map<String, dynamic>;
              final notifId = latestNotif['id']?.toString() ?? '';
              final lastShownNotifId =
                  prefs.getString('ps_last_shown_urgent_notif_id') ?? '';

              if (notifId.isNotEmpty && notifId != lastShownNotifId) {
                await prefs.setString('ps_last_shown_urgent_notif_id', notifId);
                await prefs.setBool('ps_parking_notif_dismissed', false);

                final title = latestNotif['title']?.toString() ??
                    '⚠️ Sisa Waktu Parkir 10 Menit!';
                final message = latestNotif['message']?.toString() ??
                    'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout.';

                await _bgShowUrgentAlarmNotif(
                  plugin,
                  title: title,
                  body: message,
                );
                debugPrint(
                    '[ParkingBG] Notifikasi darurat dari Admin berhasil dibunyikan di background!');
              }
            }
          }
        } catch (e) {
          debugPrint('[ParkingBG] Cek notif server error: $e');
        }
      }

      // ─── 2. MONITOR SISA WAKTU PARKIR LOKAL ───
      final sessionActive =
          prefs.getBool('ps_parking_session_active') ?? false;
      if (!sessionActive) {
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
          await _bgShowUrgentAlarmNotif(plugin, minsLeft: minsLeft > 0 ? minsLeft : 1);
          await prefs.setInt('ps_parking_last_urgent_notif_time', nowMs);
          debugPrint('[ParkingBG] Notif darurat dikirim ($minsLeft menit). Mengulang dalam 3 menit jika belum direspons.');
        }
      }
    } catch (e) {
      debugPrint('[ParkingBG] Monitor error: $e');
    }
  });
}

Future<void> _bgShowUrgentAlarmNotif(
  FlutterLocalNotificationsPlugin plugin, {
  String? title,
  String? body,
  int? minsLeft,
}) async {
  try {
    // 🛡️ PROTEKSI: Pastikan HP ini bukan HP Admin saat memainkan alarm di background
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('ps_session_user_type');
    final adminEmail = prefs.getString('current_admin_email');
    final adminRole = prefs.getString('current_admin_role');
    if (userType == 'admin' || (adminEmail != null && adminEmail.isNotEmpty) || (adminRole != null && adminRole.isNotEmpty)) {
      debugPrint('[ParkingBG] BLOCKED: Device terdeteksi Admin. Alarm dibatalkan.');
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'urgent_parking_alarm_v5',
      'Peringatan Darurat Parkir (Alarm)',
      channelDescription: 'Peringatan mendesak waktu parkir dengan alarm suara darurat looping',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('sound_darurat'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      autoCancel: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      // Native Android FLAG_INSISTENT (4): Audio berbunyi berulang (loop) sampai dibuka/dismiss
      additionalFlags: Int32List.fromList(<int>[4]),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'perpanjang_id',
          'Perpanjang Waktu',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'checkout_id',
          'Buka Tiket',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'stop_alarm',
          'Matikan Alarm',
          cancelNotification: true,
        ),
      ],
    );
    final details = NotificationDetails(android: androidDetails);
    await plugin.show(
      id: 777,
      title: title ?? (minsLeft != null ? '⚠️ Sisa Waktu Parkir $minsLeft Menit!' : '⚠️ Peringatan Darurat Parkir!'),
      body: body ?? 'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout untuk menghindari denda.',
      notificationDetails: details,
      payload: 'expiring_session',
    );
    debugPrint('[ParkingBG] Notif BG darurat ditampilkan dengan sound looping ($minsLeft menit tersisa)');
  } catch (e) {
    debugPrint('[ParkingBG] _bgShowUrgentAlarmNotif error: $e');
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
  if (response.id == 777 ||
      response.payload == 'expiring_session' ||
      response.actionId == 'stop_alarm' ||
      response.actionId == 'checkout_id' ||
      response.actionId == 'perpanjang_id') {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ps_parking_notif_dismissed', true);
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancel(id: 777);
    } catch (_) {}
  }
}
