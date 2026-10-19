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

  final List<FinanceNotificationItem> _defaultNotifications = [
    FinanceNotificationItem(
      id: 'NOTIF-INJ-001',
      title: 'Injeksi Saldo Berhasil • Rp 250.000',
      userName: 'Budi Santoso',
      userId: 'usr-001',
      amount: 'Rp 250.000',
      description:
          'Saldo sebesar Rp 250.000 berhasil dikreditkan ke dompet akun Budi Santoso (usr-001). Buku kas dompet telah terupdate.',
      status: 'Berhasil',
      time: '12 mnt lalu',
      isRead: false,
    ),
    FinanceNotificationItem(
      id: 'NOTIF-INJ-002',
      title: 'Injeksi Saldo Gagal • Rp 500.000',
      userName: 'Andi Wijaya',
      userId: 'usr-002',
      amount: 'Rp 500.000',
      description:
          'Gagal melakukan top-up manual untuk akun Andi Wijaya (usr-002). Akun sedang dalam peninjauan verifikasi keamanan KYC.',
      status: 'Gagal',
      time: '45 mnt lalu',
      isRead: false,
    ),
    FinanceNotificationItem(
      id: 'NOTIF-INJ-003',
      title: 'Injeksi Saldo Berhasil • Rp 100.000',
      userName: 'Siti Rahayu',
      userId: 'usr-003',
      amount: 'Rp 100.000',
      description:
          'Kompensasi kendala sensor barcode gateway gate out berhasil dikreditkan ke dompet Siti Rahayu (usr-003).',
      status: 'Berhasil',
      time: '2 jam lalu',
      isRead: true,
    ),
  ];

  late List<FinanceNotificationItem> notifications = List.from(_defaultNotifications);

  /// Mengambil notifikasi finansial dari Supabase
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('system_notifications')
          .select('id, title, message, notification_type, is_read, created_at')
          .inFilter('target_role', ['all', 'finance'])
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        notifications = res.map<FinanceNotificationItem>((row) {
          final isRead = row['is_read'] == true;
          final nType = row['notification_type']?.toString().toLowerCase();
          final isFail = nType == 'error' || nType == 'failed';

          return FinanceNotificationItem(
            id: row['id']?.toString() ?? 'NOTIF-000',
            title: row['title']?.toString() ?? 'Pemberitahuan Finansial',
            userName: 'Pengguna Terkait',
            userId: 'usr-000',
            amount: 'Rp 100.000',
            description: row['message']?.toString() ?? '-',
            status: isFail ? 'Gagal' : 'Berhasil',
            time: 'Baru saja',
            isRead: isRead,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminFinanceNotificationsBackend] fetchNotifications error: $e');
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
