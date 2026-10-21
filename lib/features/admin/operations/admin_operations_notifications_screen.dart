import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_active_users_screen.dart';
import 'manage_parking_screen.dart';
import 'backend/admin_operations_notifications_backend.dart';

class OperationNotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final String category; // 'Kritis' | 'Gerbang' | 'Kapasitas'
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String actionLabel;
  final String actionTarget; // 'active_users' | 'slot_mgmt' | 'locations'
  bool isRead;

  OperationNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.actionLabel,
    required this.actionTarget,
    this.isRead = false,
  });
}

class AdminOperationsNotificationsScreen extends StatefulWidget {
  const AdminOperationsNotificationsScreen({super.key});

  @override
  State<AdminOperationsNotificationsScreen> createState() => _AdminOperationsNotificationsScreenState();
}

class _AdminOperationsNotificationsScreenState extends State<AdminOperationsNotificationsScreen> {
  List<OperationNotificationItem> get _notifications => AdminOperationsNotificationsBackend.instance.notifications;

  @override
  void initState() {
    super.initState();
    AdminOperationsNotificationsBackend.instance.fetchNotifications();
  }

  void _handleAction(OperationNotificationItem item) {
    AdminOperationsNotificationsBackend.instance.markAsRead(item.id);
    if (item.actionTarget == 'active_users') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen()));
    } else if (item.actionTarget == 'slot_mgmt') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageParkingScreen(initialTabIndex: 1)));
    } else if (item.actionTarget == 'locations') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageParkingScreen(initialTabIndex: 0)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminOperationsNotificationsBackend.instance,
      builder: (context, _) => Theme(
        data: AppTheme.light,
        child: Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Notifikasi Operasional', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ],
                ),
                Text('Peringatan Lapangan, Kapasitas & Palang Gerbang', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  for (var n in _notifications) {
                    AdminOperationsNotificationsBackend.instance.markAsRead(n.id);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Semua notifikasi operasional ditandai telah dibaca.', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFF114177),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text('Tandai Dibaca', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF114177), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildNotificationList(),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF17A18A)),
            const SizedBox(height: 12),
            Text('Semua Lapangan Beroperasi Normal', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            Text('Tidak ada insiden atau peringatan operasional saat ini.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: _notifications.length,
      itemBuilder: (ctx, i) {
        final item = _notifications[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead ? const Color(0xFFE5E7EB) : item.iconColor.withValues(alpha: 0.4),
              width: item.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.bgColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.category.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: item.iconColor,
                                  ),
                                ),
                              ),
                              Text(item.time, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                              color: const Color(0xFF1A1A18),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.isRead ? 'Sudah ditinjau' : 'Belum ditindaklanjuti',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: item.isRead ? const Color(0xFF76777B) : const Color(0xFFD94B4B),
                        fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleAction(item),
                      icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                      label: Text(item.actionLabel, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF114177),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
