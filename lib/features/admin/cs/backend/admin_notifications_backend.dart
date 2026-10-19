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
  });
}

/// Backend khusus untuk AdminNotificationsScreen (admin_notifications_screen.dart)
/// Mengelola pusat notifikasi peringatan operasional, verifikasi identitas, dan feedback customer
/// Terkoneksi ke `public.system_notifications` di Supabase
class AdminNotificationsBackend extends ChangeNotifier {
  AdminNotificationsBackend._();
  static final AdminNotificationsBackend instance = AdminNotificationsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<CsNotificationItem> _defaultNotifications = [
    CsNotificationItem(
      id: 'NOTIF-001',
      icon: Icons.warning_amber,
      iconColor: const Color(0xFFD94B4B),
      bgColor: const Color(0xFFFDE8E4),
      title: '3 Kendaraan Overstay Terdeteksi',
      body: 'Central Park Mall · 3 kendaraan melebihi batas waktu parkir yang dibayarkan.',
      time: '2 menit lalu',
      isRead: false,
      action: 'Cek Overstay',
    ),
    CsNotificationItem(
      id: 'NOTIF-002',
      icon: Icons.verified_user,
      iconColor: const Color(0xFFE07A5F),
      bgColor: const Color(0xFFFDECE7),
      title: '5 Verifikasi KTP Baru',
      body: 'Ada 5 permintaan identitas pengguna baru yang menunggu tinjauan admin.',
      time: '15 menit lalu',
      isRead: false,
      action: 'Tinjau KTP',
    ),
    CsNotificationItem(
      id: 'NOTIF-003',
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFF114177),
      bgColor: const Color(0xFFE3EEFF),
      title: 'Injeksi Saldo Dompet Sukses',
      body: 'Admin berhasil menginjeksi saldo Rp 500.000 ke dompet pengguna Nanda Setiawan.',
      time: '1 jam lalu',
      isRead: true,
      action: 'Cek Dompet',
    ),
    CsNotificationItem(
      id: 'NOTIF-004',
      icon: Icons.feedback,
      iconColor: const Color(0xFF17A18A),
      bgColor: const Color(0xFFD1F2EB),
      title: 'Feedback Baru dari Pengguna',
      body: 'Pengguna atas nama Rafi M memberikan apresiasi terhadap kecepatan barcode check-out.',
      time: '2 jam lalu',
      isRead: true,
      action: 'Lihat Ulasan',
    ),
    CsNotificationItem(
      id: 'NOTIF-005',
      icon: Icons.local_parking,
      iconColor: const Color(0xFF45474A),
      bgColor: const Color(0xFFF1EEE7),
      title: 'Fasilitas Baru Aktif',
      body: 'Lokasi parkir Senayan City Jakarta Selatan telah terhubung ke jaringan ParkSmart.',
      time: '4 jam lalu',
      isRead: true,
    ),
    CsNotificationItem(
      id: 'NOTIF-006',
      icon: Icons.payments,
      iconColor: const Color(0xFF17A18A),
      bgColor: const Color(0xFFD1F2EB),
      title: 'Pencapaian Omzet Harian',
      body: 'Total pendapatan parkir hari ini mencapai Rp 4.2 Jt (12% melebihi estimasi target).',
      time: '6 jam lalu',
      isRead: true,
    ),
  ];

  late List<CsNotificationItem> allNotifications = List.from(_defaultNotifications);

  /// Mengambil notifikasi CS dari Supabase
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('system_notifications')
          .select('id, title, message, notification_type, is_read, created_at')
          .inFilter('target_role', ['all', 'cs', 'admin'])
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        allNotifications = res.map<CsNotificationItem>((row) {
          final isRead = row['is_read'] == true;
          final nType = row['notification_type']?.toString().toLowerCase();

          IconData icon = Icons.notifications_none;
          Color iconColor = const Color(0xFF114177);
          Color bgColor = const Color(0xFFE3EEFF);

          if (nType == 'warning' || nType == 'overstay') {
            icon = Icons.warning_amber;
            iconColor = const Color(0xFFD94B4B);
            bgColor = const Color(0xFFFDE8E4);
          } else if (nType == 'feedback') {
            icon = Icons.feedback;
            iconColor = const Color(0xFF17A18A);
            bgColor = const Color(0xFFD1F2EB);
          }

          return CsNotificationItem(
            id: row['id']?.toString() ?? 'NOTIF-000',
            icon: icon,
            iconColor: iconColor,
            bgColor: bgColor,
            title: row['title']?.toString() ?? 'Pemberitahuan Sistem',
            body: row['message']?.toString() ?? '-',
            time: 'Baru saja',
            isRead: isRead,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminNotificationsBackend] fetchNotifications error: $e');
      _errorMessage = e.toString();
      if (allNotifications.isEmpty) {
        allNotifications = List.from(_defaultNotifications);
      }
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
