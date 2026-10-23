import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../profile/backend/profile_backend.dart';
import '../../home/backend/home_backend.dart';

/// Backend khusus untuk NotificationScreen (lib/features/notification/notification_screen.dart)
/// Menggunakan Targeted Column Query & Strict User Isolation (Mencegah kebocoran notifikasi antar akun/role)
class NotificationBackend extends ChangeNotifier {
  NotificationBackend._();
  static final NotificationBackend instance = NotificationBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => n['is_read'] == false).length;

  RealtimeChannel? _realtimeChannel;

  /// Mengidentifikasi User ID yang sedang login secara akurat
  String? _resolveCurrentUserId() {
    final sessionUid = SessionService.instance.userId;
    if (sessionUid != null && sessionUid.trim().isNotEmpty) return sessionUid.trim();
    final profileUid = ProfileBackend.instance.userId;
    if (profileUid.trim().isNotEmpty) return profileUid.trim();
    final authUid = _client.auth.currentUser?.id;
    if (authUid != null && authUid.trim().isNotEmpty) return authUid.trim();
    return null;
  }

  /// Memulai langganan realtime Supabase untuk perubahan di tabel system_notifications
  void initRealtimeSubscription() {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = _client.channel('public:user_notifications')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'system_notifications',
          callback: (payload) {
            debugPrint('[NotificationBackend] Realtime update dari system_notifications');
            fetchNotifications();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('[NotificationBackend] initRealtimeSubscription error: $e');
    }
  }

  /// Melepas langganan realtime
  void disposeRealtime() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  /// Membersihkan memori notifikasi (misal saat logout)
  void clear() {
    _notifications = [];
    _isLoading = false;
    notifyListeners();
  }

  /// Memuat daftar notifikasi dari Supabase dengan filter ketat per user
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUid = _resolveCurrentUserId();

      // 1. Filter Database PostgREST:
      // - target_role HANYA 'user' atau 'all' (TIDAK BOLEH menarik notifikasi 'finance', 'operational', 'cs', dll)
      // - recipient_user_id WAJIB cocok dengan akun yang login, atau NULL jika berupa broadcast publik
      var query = _client
          .from('system_notifications')
          .select('id, title, message, notification_type, action_type, is_read, created_at, recipient_user_id, target_role')
          .inFilter('target_role', ['user', 'all']);

      if (currentUid != null && currentUid.isNotEmpty) {
        query = query.or('recipient_user_id.eq.$currentUid,recipient_user_id.is.null');
      } else {
        query = query.filter('recipient_user_id', 'is', null);
      }

      final response = await query.order('created_at', ascending: false);

      // 2. Defense-in-depth: In-memory filter tambahan agar TIDAK ADA kebocoran sama sekali
      final rawList = List<Map<String, dynamic>>.from(response);
      _notifications = rawList.where((n) {
        // Cek target_role
        final targetRole = (n['target_role'] ?? 'all').toString().toLowerCase().trim();
        if (targetRole != 'all' && targetRole != 'user') return false;

        // Cek recipient_user_id
        final recipient = n['recipient_user_id']?.toString().trim();
        if (recipient != null && recipient.isNotEmpty) {
          if (currentUid == null || recipient.toLowerCase() != currentUid.toLowerCase()) {
            return false;
          }
        }
        return true;
      }).toList();
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

      final index = _notifications.indexWhere((n) => n['id']?.toString() == id);
      if (index != -1) {
        _notifications[index]['is_read'] = true;
        notifyListeners();
      }

      // Sinkronkan badge di HomeScreen
      try {
        HomeBackend.instance.refreshUnreadNotifications();
      } catch (_) {}
    } catch (e) {
      debugPrint('[NotificationBackend] markAsRead error: $e');
    }
  }

  /// Menandai semua notifikasi user ini sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    try {
      final unreadIds = _notifications
          .where((n) => n['is_read'] == false && n['id'] != null)
          .map((n) => n['id'].toString())
          .toList();

      if (unreadIds.isNotEmpty) {
        // Hanya update ID notifikasi milik akun ini yang sedang ditampilkan
        await _client
            .from('system_notifications')
            .update({'is_read': true})
            .inFilter('id', unreadIds);
      }

      for (var n in _notifications) {
        n['is_read'] = true;
      }
      notifyListeners();

      // Sinkronkan badge di HomeScreen
      try {
        HomeBackend.instance.refreshUnreadNotifications();
      } catch (_) {}
    } catch (e) {
      debugPrint('[NotificationBackend] markAllAsRead error: $e');
    }
  }
}
