import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_wallet_screen.dart';
import 'admin_transactions_screen.dart';
import 'revenue_screen.dart';
import 'admin_pricing_screen.dart';

class FinanceNotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final String category; // 'Settlement' | 'Deposit' | 'Refund' | 'Audit'
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String actionLabel;
  final String actionTarget; // 'wallet' | 'transactions' | 'revenue' | 'pricing'
  bool isRead;

  FinanceNotificationItem({
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

class AdminFinanceNotificationsScreen extends StatefulWidget {
  const AdminFinanceNotificationsScreen({super.key});

  @override
  State<AdminFinanceNotificationsScreen> createState() => _AdminFinanceNotificationsScreenState();
}

class _AdminFinanceNotificationsScreenState extends State<AdminFinanceNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<FinanceNotificationItem> _notifications = [
    FinanceNotificationItem(
      id: 'NOTIF-FIN-001',
      title: 'Settlement Midtrans & QRIS Berhasil',
      description: 'Penyelesaian pembayaran harian sebesar Rp 4.250.000 (842 transaksi) berhasil dicairkan ke rekening penampung.',
      time: '10 mnt lalu',
      category: 'Settlement',
      icon: Icons.account_balance,
      iconColor: const Color(0xFF17A18A),
      bgColor: const Color(0xFFD1F2EB),
      actionLabel: 'Lihat Mutasi',
      actionTarget: 'transactions',
      isRead: false,
    ),
    FinanceNotificationItem(
      id: 'NOTIF-FIN-002',
      title: 'Target Omzet Harian Tercapai (+12%)',
      description: 'Pencapaian omset parkir platform telah melampaui target harian Rp 4.000.000 pada pukul 19:30 WIB.',
      time: '25 mnt lalu',
      category: 'Settlement',
      icon: Icons.trending_up,
      iconColor: const Color(0xFF114177),
      bgColor: const Color(0xFFEBF2FA),
      actionLabel: 'Cek Grafik Pendapatan',
      actionTarget: 'revenue',
      isRead: false,
    ),
    FinanceNotificationItem(
      id: 'NOTIF-FIN-003',
      title: 'Injeksi Saldo Dompet Berhasil',
      description: 'Top-up saldo dompet pengguna sebesar Rp 250.000 untuk akun Budi P. telah dikreditkan ke buku besar mutasi.',
      time: '45 mnt lalu',
      category: 'Deposit',
      icon: Icons.account_balance_wallet,
      iconColor: const Color(0xFFD97706),
      bgColor: const Color(0xFFFEF3C7),
      actionLabel: 'Kelola Dompet',
      actionTarget: 'wallet',
      isRead: false,
    ),
    FinanceNotificationItem(
      id: 'NOTIF-FIN-004',
      title: 'Pengajuan Refund Pembatalan Reservasi',
      description: 'Permintaan refund dana parkir Rp 20.000 untuk tiket #BK-3021 (Malioboro Mall) telah diproses kembali ke dompet user.',
      time: '2 jam lalu',
      category: 'Refund',
      icon: Icons.replay,
      iconColor: const Color(0xFFE07A5F),
      bgColor: const Color(0xFFFDECE7),
      actionLabel: 'Audit Transaksi',
      actionTarget: 'transactions',
      isRead: true,
    ),
    FinanceNotificationItem(
      id: 'NOTIF-FIN-005',
      title: 'Peringatan Selisih Rekonsiliasi Tarif',
      description: 'Terdeteksi selisih tarif Rp 5.000 pada loket manual Gerbang 1 Malioboro Mall saat jam pergantian shift petugas.',
      time: '4 jam lalu',
      category: 'Audit',
      icon: Icons.gavel_rounded,
      iconColor: const Color(0xFFD94B4B),
      bgColor: const Color(0xFFFDE8E4),
      actionLabel: 'Tinjau Aturan Tarif',
      actionTarget: 'pricing',
      isRead: true,
    ),
  ];

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

  void _handleAction(FinanceNotificationItem item) {
    setState(() => item.isRead = true);
    if (item.actionTarget == 'transactions') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen()));
    } else if (item.actionTarget == 'wallet') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen()));
    } else if (item.actionTarget == 'revenue') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen()));
    } else if (item.actionTarget == 'pricing') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingScreen()));
    }
  }

  List<FinanceNotificationItem> _getFilteredNotifications(int tabIndex) {
    if (tabIndex == 1) {
      return _notifications.where((n) => n.category == 'Settlement' || n.category == 'Deposit').toList();
    } else if (tabIndex == 2) {
      return _notifications.where((n) => n.category == 'Refund' || n.category == 'Audit').toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

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
                color: const Color(0xFFF1EEE7),
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
                  Text('Notifikasi Finansial', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount baru',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
              Text('Settlement, Arus Kas Masuk & Audit Saldo', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    n.isRead = true;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Semua notifikasi finansial ditandai telah dibaca.', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFFD97706),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Tandai Dibaca', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFD97706), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE4DFD5))),
              ),
              child: TabBar(
                controller: _tabController,
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                labelColor: const Color(0xFFD97706),
                unselectedLabelColor: const Color(0xFF76777B),
                indicatorColor: const Color(0xFFD97706),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Semua (${_notifications.length})'),
                  Tab(text: 'Settlement (${_notifications.where((n) => n.category == "Settlement" || n.category == "Deposit").length})'),
                  Tab(text: 'Refund & Audit (${_notifications.where((n) => n.category == "Refund" || n.category == "Audit").length})'),
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
  }

  Widget _buildNotificationList(int tabIndex) {
    final list = _getFilteredNotifications(tabIndex);

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF17A18A)),
            const SizedBox(height: 12),
            Text('Semua Finansial Terkendali', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            Text('Tidak ada riwayat peringatan atau mutasi mencurigakan.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final item = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead ? const Color(0xFFE4DFD5) : item.iconColor.withValues(alpha: 0.4),
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
              const Divider(height: 1, color: Color(0xFFF1EEE7)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.isRead ? 'Terselesaikan' : 'Memerlukan review',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: item.isRead ? const Color(0xFF76777B) : const Color(0xFFD97706),
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
