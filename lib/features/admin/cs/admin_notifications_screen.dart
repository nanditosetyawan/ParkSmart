import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_feedback_screen.dart';
import 'backend/admin_notifications_backend.dart';

typedef _NotifItem = CsNotificationItem;

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AdminNotificationsBackend.instance.fetchNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAction(String action) {
    if (action == 'Tinjau KTP') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses Dibatasi: Verifikasi identitas e-KTP (KYC) dikelola oleh Super Admin.'),
          backgroundColor: Color(0xFF0D9488),
        ),
      );
    } else if (action == 'Cek Overstay') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses Dibatasi: Tindakan ini adalah wewenang Divisi Operasional.'),
          backgroundColor: Color(0xFF114177),
        ),
      );
    } else if (action == 'Cek Dompet') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses Dibatasi: Tindakan ini adalah wewenang Divisi Finansial.'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
    } else if (action == 'Lihat Ulasan') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminNotificationsBackend.instance,
      builder: (context, _) {
        return Theme(
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifikasi Admin', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  Text('Pemberitahuan Sistem & Keamanan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    AdminNotificationsBackend.instance.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Semua notifikasi ditandai telah dibaca')),
                    );
                  },
                  child: Text('Tandai Semua', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF114177), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE4DFD5)))),
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                    labelColor: const Color(0xFF114177),
                    unselectedLabelColor: const Color(0xFF76777B),
                    indicatorColor: const Color(0xFF114177),
                    indicatorWeight: 2,
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Aktivitas Sistem'),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(_allNotifications),
                _buildNotificationList(_systemNotifications),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildNotificationList(List<_NotifItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 48, color: Color(0xFF76777B)),
            const SizedBox(height: 12),
            Text('Tidak ada notifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B))),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildNotifCard(item);
      },
    );
  }

  Widget _buildNotifCard(CsNotificationItem item) {
    return GestureDetector(
      onTap: () {
        AdminNotificationsBackend.instance.markAsRead(item.id);
        if (item.action != null) _handleAction(item.action!);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.isRead ? const Color(0xFFE4DFD5) : const Color(0xFFB8D0FF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: item.bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(item.icon, size: 22, color: item.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      ),
                      if (!item.isRead)
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF114177), shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.body, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A), height: 1.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Color(0xFF76777B)),
                      const SizedBox(width: 4),
                      Text(item.time, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                      if (item.action != null) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            AdminNotificationsBackend.instance.markAsRead(item.id);
                            _handleAction(item.action!);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(8)),
                            child: Text(item.action!, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CsNotificationItem> get _allNotifications =>
      AdminNotificationsBackend.instance.allNotifications;

  List<CsNotificationItem> get _systemNotifications => _allNotifications
      .where((n) =>
          n.iconColor == const Color(0xFF45474A) ||
          n.iconColor == const Color(0xFF17A18A))
      .toList();
}

