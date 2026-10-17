import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
}
