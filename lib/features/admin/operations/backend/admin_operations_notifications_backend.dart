import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin_operations_notifications_screen.dart';

/// Backend khusus untuk AdminOperationsNotificationsScreen
/// Mengelola peringatan lapangan (overstay, sensor offline, kapasitas penuh)
/// Terkoneksi ke `public.system_notifications` di Supabase
class AdminOperationsNotificationsBackend extends ChangeNotifier {
  AdminOperationsNotificationsBackend._();
  static final AdminOperationsNotificationsBackend instance = AdminOperationsNotificationsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<OperationNotificationItem> _defaultNotifications = [
    OperationNotificationItem(
      id: 'NOTIF-OP-001',
      title: 'Peringatan Overstay: 3 Kendaraan Melebihi Batas',
      description: 'Central Park Mall (Basement B2). Kendaraan B 1234 ABC telah parkir > 8 jam melampaui batas toleransi tiket.',
      time: '2 mnt lalu',
      category: 'Kritis',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFD94B4B),
      bgColor: const Color(0xFFFDE8E8),
      actionLabel: 'Tinjau Sesi Parkir',
      actionTarget: 'active_users',
    ),
    OperationNotificationItem(
      id: 'NOTIF-OP-002',
      title: 'Sensor IoT Slot Offline: 2 Sensor Lantai B1',
      description: 'Grand Indonesia. Sensor slot B-14 dan B-15 tidak merespons ping gateway LoRaWAN selama 15 menit.',
      time: '18 mnt lalu',
      category: 'Perangkat',
      icon: Icons.sensors_off_rounded,
      iconColor: const Color(0xFFE07A5F),
      bgColor: const Color(0xFFFBF0EA),
      actionLabel: 'Cek Denah Slot',
      actionTarget: 'slot_mgmt',
    ),
    OperationNotificationItem(
      id: 'NOTIF-OP-003',
      title: 'Kapasitas Kritis: Pacific Place 95% Penuh',
      description: 'Pacific Place SCBD mencapai 190/200 slot terisi. Rekomendasikan pengalihan lalu lintas masuk ke lokasi cadangan.',
      time: '45 mnt lalu',
      category: 'Kapasitas',
      icon: Icons.local_parking_rounded,
      iconColor: const Color(0xFF17A18A),
      bgColor: const Color(0xFFE8F6F4),
      actionLabel: 'Atur Lokasi',
      actionTarget: 'locations',
    ),
  ];

  late List<OperationNotificationItem> notifications = List.from(_defaultNotifications);

  /// Mengambil notifikasi operasional dari Supabase
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('system_notifications')
          .select('id, title, message, notification_type, action_type, is_read, created_at')
          .inFilter('target_role', ['all', 'operational'])
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        notifications = res.map<OperationNotificationItem>((row) {
          final isRead = row['is_read'] == true;
          final nType = row['notification_type']?.toString().toLowerCase();

          IconData icon = Icons.info_outline;
          Color iconCol = const Color(0xFF17A18A);
          Color bgCol = const Color(0xFFE8F6F4);
          String cat = 'Sistem';

          if (nType == 'warning' || nType == 'alert') {
            icon = Icons.warning_amber_rounded;
            iconCol = const Color(0xFFD94B4B);
            bgCol = const Color(0xFFFDE8E8);
            cat = 'Kritis';
          } else if (nType == 'device') {
            icon = Icons.sensors_off_rounded;
            iconCol = const Color(0xFFE07A5F);
            bgCol = const Color(0xFFFBF0EA);
            cat = 'Perangkat';
          }

          return OperationNotificationItem(
            id: row['id']?.toString() ?? 'NOTIF-000',
            title: row['title']?.toString() ?? 'Pemberitahuan Operasional',
            description: row['message']?.toString() ?? '-',
            time: 'Baru saja',
            category: cat,
            icon: icon,
            iconColor: iconCol,
            bgColor: bgCol,
            actionLabel: 'Tinjau Sesi Parkir',
            actionTarget: 'active_users',
            isRead: isRead,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminOperationsNotificationsBackend] fetchNotifications error: $e');
      _errorMessage = e.toString();
      if (notifications.isEmpty) {
        notifications = List.from(_defaultNotifications);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tandai notifikasi telah dibaca
  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx].isRead = true;
      notifyListeners();
    }

    try {
      await _client.from('system_notifications').update({
        'is_read': true,
      }).eq('id', id);
    } catch (_) {}
  }
}
