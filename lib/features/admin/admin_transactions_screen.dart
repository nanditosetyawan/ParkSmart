import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedTypeFilter = 'Semua';
  String _selectedStatusFilter = 'Semua';
  DateTimeRange? _dateRange;

  final List<String> _typeFilters = ['Semua', 'Parkir', 'Top-up Wallet', 'Refund', 'Cashback', 'Penalty', 'Injeksi Admin'];
  final List<String> _statusFilters = ['Semua', 'Berhasil', 'Pending', 'Gagal', 'Dibatalkan'];

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN-20240315-001',
      'user': {'name': 'Nanda Setiawan', 'phone': '+62 812-3456-7890', 'avatar': 'N'},
      'type': 'Parkir',
      'location': 'Central Park Mall',
      'slot': 'A-05',
      'amount': 28000,
      'paymentMethod': 'Wallet',
      'status': 'Berhasil',
      'blockchainHash': '0x7a3f...9b2c',
      'description': 'Parkir 4 jam (Mobil)',
      'createdAt': '2024-03-15 12:30',
      'completedAt': '2024-03-15 12:30',
    },
    {
      'id': 'TXN-20240315-002',
      'user': {'name': 'Rafi Maulana', 'phone': '+62 856-7890-1234', 'avatar': 'R'},
      'type': 'Top-up Wallet',
      'location': '-',
      'slot': '-',
      'amount': 100000,
      'paymentMethod': 'Virtual Account BCA',
      'status': 'Berhasil',
      'blockchainHash': '0x4e8b...1f7a',
      'description': 'Top-up saldo via VA BCA',
      'createdAt': '2024-03-15 10:15',
      'completedAt': '2024-03-15 10:16',
    },
    {
      'id': 'TXN-20240315-003',
      'user': {'name': 'Siti Rahayu', 'phone': '+62 878-1122-3344', 'avatar': 'S'},
      'type': 'Parkir',
      'location': 'Pacific Place SCBD',
      'slot': 'EV-03',
      'amount': 40000,
      'paymentMethod': 'Wallet',
      'status': 'Berhasil',
      'blockchainHash': '0x9d2e...5c4f',
      'description': 'Parkir 4 jam (EV) + Charging',
      'createdAt': '2024-03-15 17:00',
      'completedAt': '2024-03-15 17:00',
    },
    {
      'id': 'TXN-20240315-004',
      'user': {'name': 'Budi Santoso', 'phone': '+62 813-9988-7766', 'avatar': 'B'},
      'type': 'Refund',
      'location': 'Malioboro Mall',
      'slot': 'M-08',
      'amount': 12000,
      'paymentMethod': 'Wallet (Refund)',
      'status': 'Berhasil',
      'blockchainHash': '0x1f5a...8e3b',
      'description': 'Refund pembatalan booking BKG-20240314-005',
      'createdAt': '2024-03-15 14:20',
      'completedAt': '2024-03-15 14:21',
    },
    {
      'id': 'TXN-20240314-005',
      'user': {'name': 'Dewi Lestari', 'phone': '+62 821-4455-6677', 'avatar': 'D'},
      'type': 'Cashback',
      'location': 'Tunjungan Plaza 6',
      'slot': '-',
      'amount': 15000,
      'paymentMethod': 'Wallet (Cashback)',
      'status': 'Berhasil',
      'blockchainHash': '0x3c7d...2f9e',
      'description': 'Cashback member Gold 5%',
      'createdAt': '2024-03-14 18:30',
      'completedAt': '2024-03-14 18:30',
    },
    {
      'id': 'TXN-20240314-006',
      'user': {'name': 'Andi Wijaya', 'phone': '+62 812-1111-2222', 'avatar': 'A'},
      'type': 'Injeksi Admin',
      'location': '-',
      'slot': '-',
      'amount': 500000,
      'paymentMethod': 'Admin Manual',
      'status': 'Berhasil',
      'blockchainHash': '0x8b2e...4a1d',
      'description': 'Injeksi saldo kompensasi error sistem',
      'createdAt': '2024-03-14 11:00',
      'completedAt': '2024-03-14 11:00',
      'adminNote': 'Ditinjau oleh Super Admin: Dito Pratama',
    },
    {
      'id': 'TXN-20240313-007',
      'user': {'name': 'Maya Sari', 'phone': '+62 856-3333-4444', 'avatar': 'M'},
      'type': 'Parkir',
      'location': 'Central Park Mall',
      'slot': 'A-02',
      'amount': 28000,
      'paymentMethod': 'QRIS',
      'status': 'Berhasil',
      'blockchainHash': '0x5f9a...7c3e',
      'description': 'Parkir 4 jam (Mobil)',
      'createdAt': '2024-03-13 19:00',
      'completedAt': '2024-03-13 19:01',
    },
    {
      'id': 'TXN-20240313-008',
      'user': {'name': 'Rizki Pratama', 'phone': '+62 878-5555-6666', 'avatar': 'R'},
      'type': 'Penalty',
      'location': 'Grand Indonesia',
      'slot': 'EV-01',
      'amount': 75000,
      'paymentMethod': 'Wallet',
      'status': 'Berhasil',
      'blockchainHash': '0x2d8e...6b1f',
      'description': 'Denda overstay 2.5 jam (Rp 30.000/jam)',
      'createdAt': '2024-03-13 14:30',
      'completedAt': '2024-03-13 14:30',
    },
    {
      'id': 'TXN-20240312-009',
      'user': {'name': 'Siti Rahayu', 'phone': '+62 878-1122-3344', 'avatar': 'S'},
      'type': 'Top-up Wallet',
      'location': '-',
      'slot': '-',
      'amount': 250000,
      'paymentMethod': 'Credit Card (Visa)',
      'status': 'Pending',
      'blockchainHash': '-',
      'description': 'Top-up saldo menunggu verifikasi bank',
      'createdAt': '2024-03-12 16:45',
      'completedAt': null,
    },
    {
      'id': 'TXN-20240312-010',
      'user': {'name': 'Budi Santoso', 'phone': '+62 813-9988-7766', 'avatar': 'B'},
      'type': 'Parkir',
      'location': 'Malioboro Mall',
      'slot': 'M-08',
      'amount': 12000,
      'paymentMethod': 'Wallet',
      'status': 'Gagal',
      'blockchainHash': '-',
      'description': 'Saldo tidak mencukupi saat check-out',
      'createdAt': '2024-03-12 13:00',
      'completedAt': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    final q = _searchController.text.toLowerCase();
    return _transactions.where((t) {
      final matchesSearch = t['id'].toString().toLowerCase().contains(q) ||
          t['user']['name'].toString().toLowerCase().contains(q) ||
          t['user']['phone'].toString().toLowerCase().contains(q) ||
          t['location'].toString().toLowerCase().contains(q) ||
          t['description'].toString().toLowerCase().contains(q);

      if (!matchesSearch) return false;

      final matchesType = _selectedTypeFilter == 'Semua' || t['type'] == _selectedTypeFilter;
      final matchesStatus = _selectedStatusFilter == 'Semua' || t['status'] == _selectedStatusFilter;

      if (_dateRange != null) {
        try {
          final created = DateTime.parse(t['createdAt']);
          if (created.isBefore(_dateRange!.start) || created.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        } catch (_) {}
      }

      return matchesType && matchesStatus;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedByUser {
    final groups = <String, List<Map<String, dynamic>>>{};
    for (var t in _filteredTransactions) {
      final userId = t['user']['name'];
      groups.putIfAbsent(userId, () => []).add(t);
    }
    return groups;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Parkir':
        return const Color(0xFF114177);
      case 'Top-up Wallet':
        return const Color(0xFF17A18A);
      case 'Refund':
        return const Color(0xFF7C3AED);
      case 'Cashback':
        return const Color(0xFFE5A33D);
      case 'Penalty':
        return const Color(0xFFD94B4B);
      case 'Injeksi Admin':
        return const Color(0xFFE07A5F);
      default:
        return const Color(0xFF76777B);
    }
  }

  Color _getTypeBg(String type) {
    switch (type) {
      case 'Parkir':
        return const Color(0xFFE3EEFF);
      case 'Top-up Wallet':
        return const Color(0xFFD1F2EB);
      case 'Refund':
        return const Color(0xFFF0E8FF);
      case 'Cashback':
        return const Color(0xFFFEF3E2);
      case 'Penalty':
        return const Color(0xFFFDE8E4);
      case 'Injeksi Admin':
        return const Color(0xFFFDECE7);
      default:
        return const Color(0xFFF1EEE7);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Berhasil':
        return const Color(0xFF17A18A);
      case 'Pending':
        return const Color(0xFFE07A5F);
      case 'Gagal':
        return const Color(0xFFD94B4B);
      case 'Dibatalkan':
        return const Color(0xFF76777B);
      default:
        return const Color(0xFF76777B);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Berhasil':
        return const Color(0xFFD1F2EB);
      case 'Pending':
        return const Color(0xFFFDECE7);
      case 'Gagal':
        return const Color(0xFFFDE8E4);
      case 'Dibatalkan':
        return const Color(0xFFF1EEE7);
      default:
        return const Color(0xFFF1EEE7);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Parkir':
        return Icons.local_parking;
      case 'Top-up Wallet':
        return Icons.add_card;
      case 'Refund':
        return Icons.money_off;
      case 'Cashback':
        return Icons.card_giftcard;
      case 'Penalty':
        return Icons.warning_amber;
      case 'Injeksi Admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.receipt;
    }
  }

  void _showTransactionDetail(Map<String, dynamic> txn) {
    final typeColor = _getTypeColor(txn['type']);
    final typeBg = _getTypeBg(txn['type']);
    final statusColor = _getStatusColor(txn['status']);
    final statusBg = _getStatusBg(txn['status']);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detail Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        Text(txn['id'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(txn['status'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // User
                Row(
                  children: [
                    Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(txn['user']['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF114177))))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(txn['user']['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(txn['user']['phone'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ])),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Amount
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(16)),
                      child: Icon(_getTypeIcon(txn['type']), size: 28, color: typeColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(txn['type'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: typeColor)),
                      Text(txn['description'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(txn['amount'] >= 0 ? '+Rp ${_formatNumber(txn['amount'])}' : '-Rp ${_formatNumber(txn['amount'].abs())}', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: txn['amount'] >= 0 ? const Color(0xFF17A18A) : const Color(0xFFD94B4B))),
                      Text(txn['paymentMethod'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Details
                _buildSectionTitle('Detail Transaksi'),
                const SizedBox(height: 12),
                if (txn['location'] != '-') _buildInfoRow('Lokasi', txn['location']),
                if (txn['slot'] != '-') _buildInfoRow('Slot', txn['slot']),
                _buildInfoRow('Metode Bayar', txn['paymentMethod']),
                _buildInfoRow('Dibuat', _formatDateTime(txn['createdAt'])),
                if (txn['completedAt'] != null) _buildInfoRow('Diselesaikan', _formatDateTime(txn['completedAt'])),
                if (txn['adminNote'] != null) _buildInfoRow('Catatan Admin', txn['adminNote']),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Blockchain
                _buildSectionTitle('Verifikasi Blockchain'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.verified, size: 18, color: Color(0xFF17A18A)),
                        const SizedBox(width: 8),
                        Text('Hash Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      ]),
                      const SizedBox(height: 8),
                      SelectableText(
                        txn['blockchainHash'],
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A), fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                      if (txn['blockchainHash'] != '-') ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: OutlinedButton.icon(onPressed: () => _copyToClipboard(txn['blockchainHash']), icon: const Icon(Icons.copy, size: 16), label: Text('Salin Hash', style: GoogleFonts.plusJakartaSans(fontSize: 12)))),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton.icon(onPressed: () => _verifyOnExplorer(txn['blockchainHash']), icon: const Icon(Icons.open_in_new, size: 16), label: Text('Verifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 12)))),
                        ]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Actions for admin
                if (txn['status'] == 'Pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _markAsFailed(txn);
                          },
                          icon: const Icon(Icons.close, size: 18, color: Color(0xFFD94B4B)),
                          label: Text('Tandai Gagal', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD94B4B)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _markAsSuccess(txn);
                          },
                          icon: const Icon(Icons.check, size: 18, color: Colors.white),
                          label: Text('Tandai Berhasil', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsSuccess(Map<String, dynamic> txn) {
    setState(() {
      final idx = _transactions.indexWhere((t) => t['id'] == txn['id']);
      if (idx != -1) {
        _transactions[idx]['status'] = 'Berhasil';
        _transactions[idx]['completedAt'] = DateTime.now().toString().split('.')[0];
        _transactions[idx]['blockchainHash'] = '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}...${DateTime.now().microsecond.toRadixString(16).padLeft(4, '0')}';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi ditandai berhasil', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  void _markAsFailed(Map<String, dynamic> txn) {
    setState(() {
      final idx = _transactions.indexWhere((t) => t['id'] == txn['id']);
      if (idx != -1) {
        _transactions[idx]['status'] = 'Gagal';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi ditandai gagal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFFD94B4B), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hash disalin: $text', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF114177), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  void _verifyOnExplorer(String hash) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Membuka explorer untuk: $hash', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF114177), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  void _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: _dateRange,
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF114177))), child: child!),
    );
    if (range != null) setState(() => _dateRange = range);
  }

  void _clearDateRange() => setState(() => _dateRange = null);

  Widget _buildSectionTitle(String title) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)));

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor ?? const Color(0xFF1A1A18))),
      ]),
    );
  }

  String _formatDateTime(String dt) {
    try {
      final d = DateTime.parse(dt);
      return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt;
    }
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _transactions.where((t) => t['amount'] > 0 && t['status'] == 'Berhasil').fold<int>(0, (sum, t) => sum + (t['amount'] as int));
    final totalExpense = _transactions.where((t) => t['amount'] < 0 && t['status'] == 'Berhasil').fold<int>(0, (sum, t) => sum + (t['amount'] as int).abs());
    final totalPending = _transactions.where((t) => t['status'] == 'Pending').length;
    final totalFailed = _transactions.where((t) => t['status'] == 'Gagal').length;

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context), child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)))),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Manajemen Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          Text('Riwayat Lengkap & Verifikasi Blockchain', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.download_outlined, color: Color(0xFF114177)), onPressed: _exportCSV, tooltip: 'Export CSV'),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stat overview
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatCard('Total Masuk', 'Rp ${_formatNumber(totalIncome)}', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                    const SizedBox(width: 10),
                    _buildStatCard('Total Keluar', 'Rp ${_formatNumber(totalExpense)}', const Color(0xFFD94B4B), const Color(0xFFFDE8E4)),
                    const SizedBox(width: 10),
                    _buildStatCard('Netto', 'Rp ${_formatNumber(totalIncome - totalExpense)}', const Color(0xFF114177), const Color(0xFFE3EEFF)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.search, size: 20, color: Color(0xFF76777B)),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _searchController, onChanged: (_) => setState(() {}), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)), decoration: InputDecoration(hintText: 'Cari ID, nama, lokasi, deskripsi...', hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: InputBorder.none, isDense: true))),
                  ]),
                ),
              ],
            ),
          ),

          // Filters
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), itemCount: _typeFilters.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) {
              final f = _typeFilters[i];
              final sel = _selectedTypeFilter == f;
              return GestureDetector(onTap: () => setState(() => _selectedTypeFilter = f), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? _getTypeColor(f) : const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(f, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.w500, color: sel ? Colors.white : const Color(0xFF45474A))))));
            }),
          ),
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), itemCount: _statusFilters.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) {
              final f = _statusFilters[i];
              final sel = _selectedStatusFilter == f;
              return GestureDetector(onTap: () => setState(() => _selectedStatusFilter = f), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: sel ? _getStatusColor(f) : const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)), child: Center(child: Text(f, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.w500, color: sel ? Colors.white : const Color(0xFF45474A))))));
            }),
          ),
          // Date range
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: _dateRange != null ? const Color(0xFF114177) : const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.calendar_today, size: 14, color: _dateRange != null ? Colors.white : const Color(0xFF76777B)),
                      const SizedBox(width: 6),
                      Text(_dateRange != null ? '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}' : 'Rentang Tanggal', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: _dateRange != null ? FontWeight.bold : FontWeight.w500, color: _dateRange != null ? Colors.white : const Color(0xFF45474A))),
                    ]),
                  ),
                ),
                if (_dateRange != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _clearDateRange, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(20)), child: Text('Hapus', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))))),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
              labelColor: const Color(0xFF114177),
              unselectedLabelColor: const Color(0xFF76777B),
              indicatorColor: const Color(0xFF114177),
              indicatorWeight: 2,
              tabs: const [Tab(text: 'Semua Transaksi'), Tab(text: 'Per User')],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_filteredTransactions),
                _buildGroupedByUserList(),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> txns) {
    if (txns.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.receipt_long, size: 48, color: Color(0xFF76777B)), const SizedBox(height: 12), Text('Tidak ada transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B)))]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: txns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final t = txns[i];
        final typeColor = _getTypeColor(t['type']);
        final typeBg = _getTypeBg(t['type']);
        final statusColor = _getStatusColor(t['status']);
        final statusBg = _getStatusBg(t['status']);

        return GestureDetector(
          onTap: () => _showTransactionDetail(t),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(12)), child: Icon(_getTypeIcon(t['type']), size: 22, color: typeColor)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t['type'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(t['description'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${t['amount'] >= 0 ? '+' : '-'}Rp ${_formatNumber(t['amount'].abs())}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: t['amount'] >= 0 ? const Color(0xFF17A18A) : const Color(0xFFD94B4B))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)), child: Text(t['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
                    ]),
                  ],
                ),
                const SizedBox(height: 10),
                Row(children: [
                  if (t['location'] != '-') Expanded(child: Text('📍 ${t['location']} • Slot ${t['slot']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(_formatDateTime(t['createdAt']), style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  const SizedBox(width: 12),
                  Text(t['user']['name'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Text('Hash: ${t['blockchainHash']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B), fontFeatures: [FontFeature.tabularFigures()]), overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  if (t['status'] == 'Pending') Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFDECE7), borderRadius: BorderRadius.circular(6)), child: Text('Perlu Tindakan', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFE07A5F)))),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedByUserList() {
    final grouped = _groupedByUser;
    if (grouped.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.people_outline, size: 48, color: Color(0xFF76777B)), const SizedBox(height: 12), Text('Tidak ada data user', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B)))]));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final entry = grouped.entries.elementAt(i);
        final userName = entry.key;
        final userTxns = entry.value;
        final user = userTxns.first['user'];
        final totalAmount = userTxns.fold<int>(0, (sum, t) => sum + (t['amount'] as int));
        final successCount = userTxns.where((t) => t['status'] == 'Berhasil').length;

        return GestureDetector(
          onTap: () => _showUserTransactionsDetail(userName, userTxns),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
            child: Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(user['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF114177))))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(userName, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  Text(user['phone'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(6)), child: Text('$successCount/${userTxns.length} sukses', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF45474A)))),
                    const SizedBox(width: 8),
                    Text('Total: ${totalAmount >= 0 ? '+' : '-'}Rp ${_formatNumber(totalAmount.abs())}', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: totalAmount >= 0 ? const Color(0xFF17A18A) : const Color(0xFFD94B4B))),
                  ]),
                ])),
                const Icon(Icons.chevron_right, color: Color(0xFF76777B)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUserTransactionsDetail(String userName, List<Map<String, dynamic>> txns) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transaksi: $userName', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 20),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final t = txns[i];
                    final typeColor = _getTypeColor(t['type']);
                    final typeBg = _getTypeBg(t['type']);
                    final statusColor = _getStatusColor(t['status']);
                    final statusBg = _getStatusBg(t['status']);
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showTransactionDetail(t);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE4DFD5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(10)),
                              child: Icon(_getTypeIcon(t['type']), size: 20, color: typeColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t['type'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                  Text('${t['location']} • ${t['slot']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${t['amount'] >= 0 ? '+' : '-'}Rp ${_formatNumber(t['amount'].abs())}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: t['amount'] >= 0 ? const Color(0xFF17A18A) : const Color(0xFFD94B4B)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(t['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exportCSV() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export CSV transaksi (${_filteredTransactions.length} records)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF114177), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  Widget _buildStatCard(String label, String value, Color color, Color bg) {
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 2), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color))])));
  }
}