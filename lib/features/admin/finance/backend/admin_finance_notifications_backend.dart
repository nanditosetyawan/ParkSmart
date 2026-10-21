import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin_finance_notifications_screen.dart';

/// Backend khusus untuk AdminFinanceNotificationsScreen (admin_finance_notifications_screen.dart)
/// Mengelola riwayat notifikasi injeksi saldo dompet pengguna dan status mutasi kas
/// Terkoneksi ke `public.system_notifications` di Supabase
class AdminFinanceNotificationsBackend extends ChangeNotifier {
  AdminFinanceNotificationsBackend._();
  static final AdminFinanceNotificationsBackend instance = AdminFinanceNotificationsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<FinanceNotificationItem> notifications = [];

  String _formatTimeAgo(dynamic raw) {
    if (raw == null) return 'Baru saja';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return 'Baru saja';
    }
  }

  /// Mengambil notifikasi finansial dari Supabase
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifications = []; // Selalu reset daftar saat memulai pembaruan
    notifyListeners();

    try {
      final res = await _client
          .from('system_notifications')
          .select('''
            id,
            title,
            message,
            notification_type,
            action_type,
            is_read,
            created_at,
            recipient_user_id,
            users:recipient_user_id(full_name)
          ''')
          .inFilter('target_role', ['all', 'finance'])
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        notifications = res.map<FinanceNotificationItem>((row) {
          final isRead = row['is_read'] == true;
          final nType = row['notification_type']?.toString().toLowerCase();
          final isFail = nType == 'error' || nType == 'failed';

          final userData = row['users'] as Map<String, dynamic>?;
          final userName = userData?['full_name']?.toString() ?? 'Pengguna ParkSmart';
          final String rawUserId = row['recipient_user_id']?.toString() ?? '';
          final userId = rawUserId.length >= 8
              ? 'usr-${rawUserId.substring(0, 8)}'
              : 'usr-000';

          final msg = row['message']?.toString() ?? '-';
          final title = row['title']?.toString() ?? 'Injeksi Saldo Dompet';

          // Ekstrak nominal jika ada
          final match = RegExp(r'Rp\s?[\d.,]+').firstMatch('$title $msg');
          final amount = match?.group(0) ?? 'Rp 0';

          return FinanceNotificationItem(
            id: row['id']?.toString() ?? 'NOTIF-000',
            title: title,
            userName: userName,
            userId: userId,
            amount: amount,
            description: msg,
            status: isFail ? 'Gagal' : 'Berhasil',
            time: _formatTimeAgo(row['created_at']),
            isRead: isRead,
          );
        }).toList();
      } else {
        notifications = [];
      }
    } catch (e) {
      debugPrint('[AdminFinanceNotificationsBackend] fetchNotifications error: $e');
      _errorMessage = e.toString();
      notifications = [];
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
