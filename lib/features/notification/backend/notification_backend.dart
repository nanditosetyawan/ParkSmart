import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk NotificationScreen (lib/features/notification/notification_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk notifikasi real-time & ringan
class NotificationBackend extends ChangeNotifier {
  NotificationBackend._();
  static final NotificationBackend instance = NotificationBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => n['is_read'] == false).length;

  /// Memuat daftar notifikasi dari Supabase
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Targeted Column Query: Hanya mengambil field yang dibutuhkan untuk kartu notifikasi
      final response = await _client
          .from('system_notifications')
          .select('id, title, message, notification_type, action_type, is_read, created_at')
          .order('created_at', ascending: false);

      _notifications = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[NotificationBackend] fetchNotifications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menandai notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id) async {
    try {
      await _client
          .from('system_notifications')
          .update({'is_read': true})
          .eq('id', id);

      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationBackend] markAsRead error: $e');
    }
  }

  /// Menandai semua notifikasi sudah dibaca
  Future<void> markAllAsRead() async {
    try {
      await _client
          .from('system_notifications')
          .update({'is_read': true})
          .eq('is_read', false);

      for (var n in _notifications) {
        n['is_read'] = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationBackend] markAllAsRead error: $e');
    }
  }
}
