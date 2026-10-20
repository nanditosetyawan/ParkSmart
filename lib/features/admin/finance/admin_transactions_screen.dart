import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/ticket_status_helper.dart';
import 'backend/admin_transactions_backend.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTypeFilter = 'Semua';
  String _selectedStatusFilter = 'Semua';
  String _selectedDirectionFilter = 'Semua'; // 'Semua', 'Masuk', 'Keluar'
  DateTimeRange? _dateRange;

  final List<String> _statusFilters = ['Semua', 'Berhasil', 'Pending', 'Gagal', 'Dibatalkan'];

  List<Map<String, dynamic>> get _transactions =>
      AdminTransactionsBackend.instance.transactions;

  @override
  void initState() {
    super.initState();
    AdminTransactionsBackend.instance.fetchTransactions();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isIncome(String type) => type == 'Parkir' || type == 'Top-up Wallet' || type == 'Penalty';

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

      if (_selectedDirectionFilter == 'Masuk' && !_isIncome(t['type'])) return false;
      if (_selectedDirectionFilter == 'Keluar' && _isIncome(t['type'])) return false;

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

  bool get _hasActiveFilters =>
      _selectedTypeFilter != 'Semua' ||
      _selectedStatusFilter != 'Semua' ||
      _selectedDirectionFilter != 'Semua' ||
      _dateRange != null ||
      _searchController.text.isNotEmpty;

  void _resetAllFilters() {
    setState(() {
      _selectedTypeFilter = 'Semua';
      _selectedStatusFilter = 'Semua';
      _selectedDirectionFilter = 'Semua';
      _dateRange = null;
      _searchController.clear();
    });
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
        return const Color(0xFFF3F4F6);
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
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFF3F4F6);
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
    final isIncome = _isIncome(txn['type']);
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
                    Row(
                      children: [
                        if (txn['ticketMark'] != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: TicketMark.getBgColor(txn['ticketMark']),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: TicketMark.getBorderColor(txn['ticketMark'])),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(TicketMark.getIcon(txn['ticketMark']), size: 12, color: TicketMark.getColor(txn['ticketMark'])),
                                const SizedBox(width: 4),
                                Text(
                                  txn['ticketMark'],
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: TicketMark.getColor(txn['ticketMark'])),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(txn['status'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 16),

                // User
                Row(
                  children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(txn['user']['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF114177))))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(txn['user']['name'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(txn['user']['phone'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ])),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 16),

                // Amount
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(14)),
                      child: Icon(_getTypeIcon(txn['type']), size: 24, color: typeColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(txn['type'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: typeColor)),
                      Text(txn['description'], style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF76777B))),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${isIncome ? '+' : '-'}Rp ${_formatNumber(txn['amount'])}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: isIncome ? const Color(0xFF17A18A) : const Color(0xFFD94B4B))),
                      Text(txn['paymentMethod'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 16),

                // Details
                _buildSectionTitle('Informasi Lengkap'),
                const SizedBox(height: 10),
                if (txn['location'] != '-') _buildInfoRow('Lokasi', txn['location']),
                if (txn['slot'] != '-') _buildInfoRow('Slot', txn['slot']),
                if (txn['ticketMark'] != null) _buildInfoRow('Status Tiket', txn['ticketMark']),
                _buildInfoRow('Metode Bayar', txn['paymentMethod']),
                _buildInfoRow('Dibuat', _formatDateTime(txn['createdAt'])),
                if (txn['completedAt'] != null) _buildInfoRow('Diselesaikan', _formatDateTime(txn['completedAt'])),
                if (txn['adminNote'] != null) _buildInfoRow('Catatan Admin', txn['adminNote']),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 16),


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
                          icon: const Icon(Icons.close, size: 16, color: Color(0xFFD94B4B)),
                          label: Text('Tandai Gagal', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD94B4B)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _markAsSuccess(txn);
                          },
                          icon: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: Text('Tandai Berhasil', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAsSuccess(Map<String, dynamic> txn) {
    AdminTransactionsBackend.instance.updateStatus(txn['id'], 'Berhasil');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi ditandai berhasil', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  void _markAsFailed(Map<String, dynamic> txn) {
    AdminTransactionsBackend.instance.updateStatus(txn['id'], 'Gagal');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi ditandai gagal', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFFD94B4B), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
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

  Widget _buildSectionTitle(String title) => Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)));

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required bool isActive,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (_) => items.map((item) {
        return PopupMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.plusJakartaSans(fontSize: 12.5)),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF114177).withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF114177) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isActive ? const Color(0xFF114177) : const Color(0xFF76777B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF114177) : const Color(0xFF1A1A18),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 14, color: isActive ? const Color(0xFF114177) : const Color(0xFF76777B)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? bg : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 13, color: color),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF76777B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> t) {
    final isIncome = _isIncome(t['type']);
    final amountColor = isIncome ? const Color(0xFF17A18A) : const Color(0xFFD94B4B);
    final typeColor = _getTypeColor(t['type']);
    final typeBg = _getTypeBg(t['type']);
    final statusColor = _getStatusColor(t['status']);
    final statusBg = _getStatusBg(t['status']);

    return GestureDetector(
      onTap: () => _showTransactionDetail(t),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
            // Top Row: Type Icon + Type & ID Badge + Amount & Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: typeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_getTypeIcon(t['type']), size: 20, color: typeColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t['type'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A18),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? const Color(0xFF17A18A).withValues(alpha: 0.1)
                                  : const Color(0xFFD94B4B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isIncome ? 'MASUK' : 'KELUAR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: amountColor,
                              ),
                            ),
                          ),
                          if (t['ticketMark'] != null) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: TicketMark.getBgColor(t['ticketMark']),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: TicketMark.getBorderColor(t['ticketMark']), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(TicketMark.getIcon(t['ticketMark']), size: 9, color: TicketMark.getColor(t['ticketMark'])),
                                  const SizedBox(width: 3),
                                  Text(
                                    t['ticketMark'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: TicketMark.getColor(t['ticketMark']),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t['id'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF76777B),
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}Rp ${_formatNumber(t['amount'])}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t['status'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFF3F4F6), height: 1),
            const SizedBox(height: 10),

            // Bottom Row: User name, location / method, and date
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFFE3EEFF),
                  child: Text(
                    t['user']['avatar'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF114177),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    t['user']['name'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A18),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t['location'] != '-' ? t['location'] : t['paymentMethod'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF76777B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDateTime(t['createdAt']),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF76777B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminTransactionsBackend.instance,
      builder: (context, _) {
        final totalIncome = _transactions.where((t) => _isIncome(t['type']) && t['status'] == 'Berhasil').fold<int>(0, (sum, t) => sum + (t['amount'] as int));
        final totalExpense = _transactions.where((t) => !_isIncome(t['type']) && t['status'] == 'Berhasil').fold<int>(0, (sum, t) => sum + (t['amount'] as int).abs());

        final txns = _filteredTransactions;

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
              Text('Manajemen Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('Riwayat Transaksi Finansial Masuk & Keluar', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          actions: const [
            SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // ==========================================
            // 1. KOTAK RINGKASAN MASUK / KELUAR / NETTO
            // ==========================================
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatCard(
                        label: 'Total Masuk',
                        value: 'Rp ${_formatNumber(totalIncome)}',
                        icon: Icons.arrow_downward_rounded,
                        color: const Color(0xFF17A18A),
                        bg: const Color(0xFFE8F7F3),
                        isSelected: _selectedDirectionFilter == 'Masuk',
                        onTap: () {
                          setState(() {
                            _selectedDirectionFilter = _selectedDirectionFilter == 'Masuk' ? 'Semua' : 'Masuk';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        label: 'Total Keluar',
                        value: 'Rp ${_formatNumber(totalExpense)}',
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFFD94B4B),
                        bg: const Color(0xFFFDE8E4),
                        isSelected: _selectedDirectionFilter == 'Keluar',
                        onTap: () {
                          setState(() {
                            _selectedDirectionFilter = _selectedDirectionFilter == 'Keluar' ? 'Semua' : 'Keluar';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search Bar
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Color(0xFF76777B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF1A1A18)),
                            decoration: InputDecoration(
                              hintText: 'Cari ID, user, lokasi, atau deskripsi...',
                              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _searchController.clear()),
                            child: const Icon(Icons.clear, size: 16, color: Color(0xFF76777B)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. SEDERHANA: SINGLE BAR FILTER BUBBLES
            // ==========================================
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Segment Arah Transaksi
                    Row(
                      children: ['Semua', 'Masuk', 'Keluar'].map((dir) {
                        final isSel = _selectedDirectionFilter == dir;
                        Color selColor = const Color(0xFF114177);
                        if (dir == 'Masuk') selColor = const Color(0xFF17A18A);
                        if (dir == 'Keluar') selColor = const Color(0xFFD94B4B);

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDirectionFilter = dir),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSel ? selColor : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel ? selColor : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                dir == 'Semua' ? 'Semua' : (dir == 'Masuk' ? 'Uang Masuk (+)' : 'Uang Keluar (-)'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? Colors.white : const Color(0xFF45474A),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 6),

                    // Dropdown Status
                    _buildFilterDropdown(
                      label: _selectedStatusFilter == 'Semua' ? 'Status' : _selectedStatusFilter,
                      icon: Icons.filter_alt_outlined,
                      isActive: _selectedStatusFilter != 'Semua',
                      items: _statusFilters,
                      onSelected: (val) => setState(() => _selectedStatusFilter = val),
                    ),
                    const SizedBox(width: 6),

                    // Modern Styled Date Range Picker
                    GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: _dateRange != null ? const Color(0xFF114177).withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _dateRange != null ? const Color(0xFF114177) : const Color(0xFFE5E7EB),
                            width: _dateRange != null ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: _dateRange != null ? const Color(0xFF114177) : const Color(0xFF76777B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _dateRange != null
                                  ? '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}'
                                  : 'Rentang Tanggal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: _dateRange != null ? FontWeight.bold : FontWeight.w500,
                                color: _dateRange != null ? const Color(0xFF114177) : const Color(0xFF1A1A18),
                              ),
                            ),
                            if (_dateRange != null) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _clearDateRange,
                                child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF114177)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Clear all filters if any active
                    if (_hasActiveFilters) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _resetAllFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.refresh, size: 12, color: Color(0xFFD94B4B)),
                              const SizedBox(width: 4),
                              Text('Reset', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Info baris jumlah hasil
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menampilkan ${txns.length} transaksi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF76777B), fontWeight: FontWeight.w500),
                  ),
                  if (_hasActiveFilters)
                    Text(
                      'Filter Aktif',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF114177), fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),

            // ==========================================
            // 3. KOTAK TABEL TRANSAKSI MASUK KELUAR
            // ==========================================
            Expanded(
              child: txns.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.receipt_long_outlined, size: 30, color: Color(0xFF76777B)),
                          ),
                          const SizedBox(height: 12),
                          Text('Tidak ada transaksi ditemukan', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          const SizedBox(height: 4),
                          Text('Coba ubah kata kunci atau reset filter', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                          if (_hasActiveFilters) ...[
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _resetAllFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF114177),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: Text('Reset Semua Filter', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: txns.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildTransactionCard(txns[i]),
                    ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}