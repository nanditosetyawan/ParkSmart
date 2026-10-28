import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'maintenance_service.dart';
import 'session_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    try {
      if (MaintenanceService.instance.isPushMaintenance) {
        // Gateway Push Notification dinonaktifkan oleh Superadmin
        return;
      }
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'payment_channel', 'Payment Notifications',
        channelDescription: 'Notifications for successful payments',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await _flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
      );
    } catch (e) {
      // Prevent push notification failure from breaking transaction/navigation flow
    }
  }

  Future<void> showMaintenanceNotification({required String title, required String body}) async {
    try {
      await requestPermissions();
      const AndroidNotificationDetails maintenanceDetails = AndroidNotificationDetails(
        'maintenance_alerts_channel',
        'Pemberitahuan Maintenance Sistem',
        channelDescription: 'Pemberitahuan darurat pemeliharaan sistem ParkSmart',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );
      const NotificationDetails platformDetails = NotificationDetails(
        android: maintenanceDetails,
      );
      await _flutterLocalNotificationsPlugin.show(
        id: 991,
        title: title,
        body: body,
        notificationDetails: platformDetails,
      );
    } catch (e) {
      // Ignore if on desktop/web or headless
    }
  }

  /// Menampilkan notifikasi darurat parkir (suara darurat)
  Future<void> showUrgentParkingNotification({int minsLeft = 10}) async {
    if (SessionService.instance.isAdmin || SessionService.instance.userType == 'admin') return;
    try {
      await requestPermissions();
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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
      );
      const NotificationDetails details = NotificationDetails(android: androidDetails);
      await _flutterLocalNotificationsPlugin.show(
        id: 777,
        title: '⚠️ Sisa Waktu Parkir $minsLeft Menit!',
        body: 'Waktu parkir Anda hampir habis. Segera perpanjang atau checkout untuk menghindari denda.',
        notificationDetails: details,
        payload: 'expiring_session',
      );
    } catch (_) {}
  }

  /// Membatalkan notifikasi darurat parkir
  Future<void> cancelUrgentParkingNotification() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id: 777);
    } catch (_) {}
  }
}

