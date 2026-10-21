import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_wallet_screen.dart';
import 'backend/admin_finance_notifications_backend.dart';

class FinanceNotificationItem {
  final String id;
  final String title;
  final String userName;
  final String userId;
  final String amount;
  final String description;
  final String status; // 'Berhasil' | 'Gagal'
  final String time;
  bool isRead;

  FinanceNotificationItem({
    required this.id,
    required this.title,
    required this.userName,
    required this.userId,
    required this.amount,
    required this.description,
    required this.status,
    required this.time,
    this.isRead = false,
  });
}

class AdminFinanceNotificationsScreen extends StatefulWidget {
  const AdminFinanceNotificationsScreen({super.key});

  @override
  State<AdminFinanceNotificationsScreen> createState() =>
      _AdminFinanceNotificationsScreenState();
}

class _AdminFinanceNotificationsScreenState
    extends State<AdminFinanceNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<FinanceNotificationItem> get _notifications =>
      AdminFinanceNotificationsBackend.instance.notifications;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    AdminFinanceNotificationsBackend.instance.fetchNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAction(FinanceNotificationItem item) {
    AdminFinanceNotificationsBackend.instance.markAsRead(item.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminWalletScreen()),
    );
  }

  List<FinanceNotificationItem> _getFilteredNotifications(int tabIndex) {
    if (tabIndex == 1) {
      return _notifications.where((n) => n.status == 'Berhasil').toList();
    } else if (tabIndex == 2) {
      return _notifications.where((n) => n.status == 'Gagal').toList();
    }
    return _notifications;
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminFinanceNotificationsBackend.instance,
      builder: (context, _) {
        return Theme(
          data: AppTheme.light,
          child: Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
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
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Color(0xFF1A1A18),
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifikasi Injeksi Saldo',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Status Riwayat Injeksi Saldo Dompet Admin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF76777B),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    AdminFinanceNotificationsBackend.instance.fetchNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Memperbarui notifikasi...', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFF114177),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF114177)),
                  tooltip: 'Perbarui Notifikasi',
                ),
                TextButton(
                  onPressed: () {
                    for (var n in _notifications) {
                      AdminFinanceNotificationsBackend.instance.markAsRead(n.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Semua notifikasi injeksi saldo ditandai telah dibaca.',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: const Color(0xFF114177),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Tandai Dibaca',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF114177),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    labelColor: const Color(0xFF114177),
                    unselectedLabelColor: const Color(0xFF76777B),
                    indicatorColor: const Color(0xFF114177),
                    indicatorWeight: 3,
                    tabs: [
                      Tab(text: 'Semua (${_notifications.length})'),
                      Tab(
                        text:
                            'Berhasil (${_notifications.where((n) => n.status == "Berhasil").length})',
                      ),
                      Tab(
                        text:
                            'Gagal (${_notifications.where((n) => n.status == "Gagal").length})',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(0),
                _buildNotificationList(1),
                _buildNotificationList(2),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildNotificationList(int tabIndex) {
    final list = _getFilteredNotifications(tabIndex);

    return RefreshIndicator(
      onRefresh: () => AdminFinanceNotificationsBackend.instance.fetchNotifications(),
      color: const Color(0xFF114177),
      child: list.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabIndex == 2
                              ? Icons.check_circle_outline_rounded
                              : Icons.notifications_none_rounded,
                          size: 48,
                          color: tabIndex == 2
                              ? const Color(0xFF17A18A)
                              : const Color(0xFF76777B),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tabIndex == 2
                              ? 'Tidak Ada Injeksi Saldo Gagal'
                              : 'Tidak Ada Notifikasi Injeksi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A18),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tabIndex == 2
                              ? 'Semua proses injeksi saldo berhasil terselesaikan dengan baik.'
                              : 'Belum ada riwayat aktivitas injeksi saldo terbaru.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF76777B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: list.length,
              itemBuilder: (ctx, i) {
        final item = list[i];
        final isSuccess = item.status == 'Berhasil';
        final statusColor = isSuccess
            ? const Color(0xFF17A18A)
            : const Color(0xFFD94B4B);
        final statusBg = isSuccess
            ? const Color(0xFFD1F2EB)
            : const Color(0xFFFDE8E4);
        final statusIcon = isSuccess
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? const Color(0xFFE5E7EB)
                  : statusColor.withValues(alpha: 0.4),
              width: item.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 22),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'INJEKSI ${item.status.toUpperCase()}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              Text(
                                item.time,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF76777B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: const Color(0xFF1A1A18),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF45474A),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSuccess
                          ? 'Terselesaikan di Dompet'
                          : 'Perlu Tindakan Lanjutan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isSuccess
                            ? const Color(0xFF76777B)
                            : const Color(0xFFD94B4B),
                        fontWeight: isSuccess
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleAction(item),
                      icon: Icon(
                        isSuccess
                            ? Icons.account_balance_wallet_outlined
                            : Icons.replay_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: Text(
                        isSuccess ? 'Kelola Dompet' : 'Coba Injeksi Lagi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess
                            ? const Color(0xFF114177)
                            : const Color(0xFFD94B4B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
    ),
  );
}
}
