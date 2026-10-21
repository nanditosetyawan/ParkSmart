import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CsNotificationItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String body;
  final String time;
  bool isRead;
  final String? action;
  final String notificationType;

  CsNotificationItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.action,
    this.notificationType = 'system',
  });
}

/// Backend khusus untuk AdminNotificationsScreen (admin_notifications_screen.dart)
/// Mengelola pusat notifikasi peringatan operasional, verifikasi identitas, dan feedback customer
/// Terkoneksi secara realtime ke tabel `public.system_notifications` di Supabase
class AdminNotificationsBackend extends ChangeNotifier {
  AdminNotificationsBackend._();
  static final AdminNotificationsBackend instance = AdminNotificationsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CsNotificationItem> allNotifications = [];

  RealtimeChannel? _realtimeChannel;

  /// Memulai langganan realtime Supabase untuk perubahan di tabel system_notifications
  void initRealtimeSubscription() {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = _client.channel('public:admin_cs_notifications')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'system_notifications',
          callback: (payload) {
            debugPrint('[AdminNotificationsBackend] Realtime update dari system_notifications');
            fetchNotifications();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('[AdminNotificationsBackend] initRealtimeSubscription error: $e');
    }
  }

  /// Melepas langganan realtime
  void disposeRealtime() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  String _formatTimeAgo(dynamic dateRaw) {
    if (dateRaw == null) return 'Baru saja';
    try {
      final dt = DateTime.parse(dateRaw.toString()).toLocal();
      final diff = DateTime.now().difference(dt);

      if (diff.inSeconds < 60) {
        return 'Baru saja';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} menit lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} jam lalu';
      } else if (diff.inDays == 1) {
        return 'Kemarin';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} hari lalu';
      } else {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    } catch (_) {
      return 'Baru saja';
    }
  }

  /// Mengambil notifikasi CS asli dari Supabase
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('system_notifications')
          .select('id, title, message, notification_type, action_type, is_read, created_at, target_role')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        final filteredRows = res.where((row) {
          final targetRole = row['target_role']?.toString().toLowerCase();
          if (targetRole == null || targetRole.isEmpty) return true;
          return targetRole == 'all' || targetRole == 'cs' || targetRole == 'admin' || targetRole == 'super_admin';
        }).toList();

        allNotifications = filteredRows.map<CsNotificationItem>((row) {
          final isRead = row['is_read'] == true;
          final nType = row['notification_type']?.toString().toLowerCase() ?? 'system';
          final action = row['action_type']?.toString();

          IconData icon = Icons.notifications_none_rounded;
          Color iconColor = const Color(0xFF114177);
          Color bgColor = const Color(0xFFE3EEFF);

          if (nType == 'warning' || nType == 'overstay' || nType == 'alert') {
            icon = Icons.warning_amber_rounded;
            iconColor = const Color(0xFFD94B4B);
            bgColor = const Color(0xFFFDE8E4);
          } else if (nType == 'kyc' || nType == 'verification') {
            icon = Icons.verified_user_rounded;
            iconColor = const Color(0xFFE07A5F);
            bgColor = const Color(0xFFFDECE7);
          } else if (nType == 'wallet' || nType == 'finance' || nType == 'injection' || nType == 'payment') {
            icon = Icons.account_balance_wallet_rounded;
            iconColor = const Color(0xFF114177);
            bgColor = const Color(0xFFE3EEFF);
          } else if (nType == 'feedback' || nType == 'review') {
            icon = Icons.rate_review_rounded;
            iconColor = const Color(0xFF17A18A);
            bgColor = const Color(0xFFD1F2EB);
          } else {
            icon = Icons.local_parking_rounded;
            iconColor = const Color(0xFF45474A);
            bgColor = const Color(0xFFF1EEE7);
          }

          return CsNotificationItem(
            id: row['id']?.toString() ?? 'NOTIF-000',
            icon: icon,
            iconColor: iconColor,
            bgColor: bgColor,
            title: row['title']?.toString() ?? 'Pemberitahuan Sistem',
            body: row['message']?.toString() ?? '-',
            time: _formatTimeAgo(row['created_at']),
            isRead: isRead,
            action: (action != null && action.isNotEmpty) ? action : null,
            notificationType: nType,
          );
        }).toList();
      } else {
        allNotifications = [];
      }
    } catch (e) {
      debugPrint('[AdminNotificationsBackend] fetchNotifications error: $e');
      _errorMessage = e.toString();
      allNotifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menandai seluruh notifikasi telah dibaca
  Future<void> markAllAsRead() async {
    for (var n in allNotifications) {
      n.isRead = true;
    }
    notifyListeners();

    try {
      await _client.from('system_notifications').update({
        'is_read': true,
      }).neq('id', '00000000-0000-0000-0000-000000000000');
    } catch (_) {}
  }

  /// Menandai satu notifikasi telah dibaca
  Future<void> markAsRead(String id) async {
    final idx = allNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      allNotifications[idx].isRead = true;
      notifyListeners();
    }

    try {
      await _client.from('system_notifications').update({
        'is_read': true,
      }).eq('id', id);
    } catch (_) {}
  }
}
