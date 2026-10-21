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

  late List<OperationNotificationItem> notifications = [];

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
      } else {
        notifications = [];
      }
    } catch (e) {
      debugPrint('[AdminOperationsNotificationsBackend] fetchNotifications error: $e');
      _errorMessage = e.toString();
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
