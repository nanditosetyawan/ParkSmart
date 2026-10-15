import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_kyc_screen.dart';
import 'admin_active_users_screen.dart';
import 'admin_wallet_screen.dart';
import 'admin_feedback_screen.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAction(String action) {
    if (action == 'Tinjau KTP') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen()));
    } else if (action == 'Cek Overstay') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen()));
    } else if (action == 'Cek Dompet') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen()));
    } else if (action == 'Lihat Ulasan') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
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
              setState(() {
                for (var n in _allNotifications) {
                  n.isRead = true;
                }
              });
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
                Tab(text: 'Peringatan & Isu'),
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
          _buildNotificationList(_alertNotifications),
          _buildNotificationList(_systemNotifications),
        ],
      ),
    ));
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

  Widget _buildNotifCard(_NotifItem item) {
    return GestureDetector(
      onTap: () {
        setState(() => item.isRead = true);
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
                            setState(() => item.isRead = true);
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

  final List<_NotifItem> _allNotifications = [
    _NotifItem(icon: Icons.warning_amber, iconColor: Color(0xFFD94B4B), bgColor: Color(0xFFFDE8E4), title: '3 Kendaraan Overstay Terdeteksi', body: 'Central Park Mall · 3 kendaraan melebihi batas waktu parkir yang dibayarkan.', time: '2 menit lalu', isRead: false, action: 'Cek Overstay'),
    _NotifItem(icon: Icons.verified_user, iconColor: Color(0xFFE07A5F), bgColor: Color(0xFFFDECE7), title: '5 Verifikasi KTP Baru', body: 'Ada 5 permintaan identitas pengguna baru yang menunggu tinjauan admin.', time: '15 menit lalu', isRead: false, action: 'Tinjau KTP'),
    _NotifItem(icon: Icons.account_balance_wallet, iconColor: Color(0xFF114177), bgColor: Color(0xFFE3EEFF), title: 'Injeksi Saldo Dompet Sukses', body: 'Admin berhasil menginjeksi saldo Rp 500.000 ke dompet pengguna Nanda Setiawan.', time: '1 jam lalu', isRead: true, action: 'Cek Dompet'),
    _NotifItem(icon: Icons.feedback, iconColor: Color(0xFF17A18A), bgColor: Color(0xFFD1F2EB), title: 'Feedback Baru dari Pengguna', body: 'Pengguna atas nama Rafi M memberikan apresiasi terhadap kecepatan barcode check-out.', time: '2 jam lalu', isRead: true, action: 'Lihat Ulasan'),
    _NotifItem(icon: Icons.local_parking, iconColor: Color(0xFF45474A), bgColor: Color(0xFFF1EEE7), title: 'Fasilitas Baru Aktif', body: 'Lokasi parkir Senayan City Jakarta Selatan telah terhubung ke jaringan ParkSmart.', time: '4 jam lalu', isRead: true),
    _NotifItem(icon: Icons.payments, iconColor: Color(0xFF17A18A), bgColor: Color(0xFFD1F2EB), title: 'Pencapaian Omzet Harian', body: 'Total pendapatan parkir hari ini mencapai Rp 4.2 Jt (12% melebihi estimasi target).', time: '6 jam lalu', isRead: true),
  ];

  List<_NotifItem> get _alertNotifications => _allNotifications.where((n) => n.iconColor == const Color(0xFFD94B4B) || n.iconColor == const Color(0xFFE07A5F)).toList();
  List<_NotifItem> get _systemNotifications => _allNotifications.where((n) => n.iconColor == const Color(0xFF45474A) || n.iconColor == const Color(0xFF17A18A)).toList();
}

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String body;
  final String time;
  bool isRead;
  final String? action;

  _NotifItem({
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
