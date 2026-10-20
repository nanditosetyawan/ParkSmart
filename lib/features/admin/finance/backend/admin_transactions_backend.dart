import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/ticket_status_helper.dart';

/// Backend khusus untuk AdminTransactionsScreen (admin_transactions_screen.dart)
/// Mengelola riwayat audit transaksi keuangan (Parkir, Top-up, Denda Overstay, Refund)
/// Terkoneksi ke tabel `public.payments` di Supabase
class AdminTransactionsBackend extends ChangeNotifier {
  AdminTransactionsBackend._();
  static final AdminTransactionsBackend instance = AdminTransactionsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _defaultTransactions = [
    {
      'id': 'TXN-20240315-001',
      'user': {'name': 'Nanda Setiawan', 'phone': '+62 812-3456-7890', 'avatar': 'N'},
      'type': 'Parkir',
      'location': 'Central Park Mall',
      'slot': 'A-05',
      'amount': 28000,
      'paymentMethod': 'Wallet',
      'status': 'Berhasil',
      'ticketMark': TicketMark.ready,
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
      'ticketMark': null,
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
      'ticketMark': TicketMark.aktif,
      'blockchainHash': '0x9d2e...5c4f',
      'description': 'Parkir 4 jam (EV) + Charging',
      'createdAt': '2024-03-15 09:00',
      'completedAt': '2024-03-15 09:00',
    },
    {
      'id': 'TXN-20240315-004',
      'user': {'name': 'Dewi Lestari', 'phone': '+62 813-9988-7766', 'avatar': 'D'},
      'type': 'Penalti Overstay',
      'location': 'Grand Indonesia',
      'slot': 'B-12',
      'amount': 15000,
      'paymentMethod': 'QRIS',
      'status': 'Berhasil',
      'ticketMark': TicketMark.selesai,
      'blockchainHash': '0x1b5c...8e3a',
      'description': 'Denda overstay 1 jam 15 mnt',
      'createdAt': '2024-03-15 08:45',
      'completedAt': '2024-03-15 08:46',
    },
    {
      'id': 'TXN-20240315-005',
      'user': {'name': 'Budi Santoso', 'phone': '+62 821-4455-6677', 'avatar': 'B'},
      'type': 'Refund',
      'location': 'Central Park Mall',
      'slot': 'A-02',
      'amount': 28000,
      'paymentMethod': 'Wallet',
      'status': 'Berhasil',
      'ticketMark': TicketMark.dibatalkan,
      'blockchainHash': '0x6f4a...2d8e',
      'description': 'Refund pembatalan booking',
      'createdAt': '2024-03-15 07:30',
      'completedAt': '2024-03-15 07:31',
    },
    {
      'id': 'TXN-20240315-006',
      'user': {'name': 'Dewi Anggraini', 'phone': '+62 813-1122-9988', 'avatar': 'D'},
      'type': 'Parkir',
      'location': 'Central Park Mall',
      'slot': 'C-04',
      'amount': 15000,
      'paymentMethod': 'Virtual Account Mandiri',
      'status': 'Pending',
      'ticketMark': TicketMark.belumDibayar,
      'blockchainHash': '0x3c7a...4e1d',
      'description': 'Reservasi Tiket Parkir (Motor)',
      'createdAt': '2024-03-15 14:30',
      'completedAt': null,
    },
  ];

  late List<Map<String, dynamic>> transactions = List.from(_defaultTransactions);

  /// Mengambil daftar transaksi dari Supabase
  String _formatFullDate(dynamic dateRaw) {
    if (dateRaw == null) return '20 Oktober 2026';
    try {
      final dt = DateTime.parse(dateRaw.toString()).toLocal();
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final day = dt.day;
      final month = months[dt.month - 1];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute WIB';
    } catch (_) {
      return dateRaw.toString();
    }
  }

  /// Mengambil daftar transaksi dari Supabase (terkoneksi ke public.payments)
  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('payments')
          .select('id, transaction_code, amount, payment_method, status, transaction_type, description, created_at, completed_at, booking_id, session_id, users(full_name, phone), bookings(booking_code, booking_status, payment_status), parking_sessions(session_code, status)')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        transactions = res.map<Map<String, dynamic>>((row) {
          final amt = (row['amount'] as num?)?.toInt() ?? 10000;
          final statusDb = row['status']?.toString().toLowerCase();

          String statusLabel = 'Berhasil';
          if (statusDb == 'pending') {
            statusLabel = 'Pending';
          } else if (statusDb == 'failed') {
            statusLabel = 'Gagal';
          } else if (statusDb == 'refunded') {
            statusLabel = 'Refunded';
          }

          final method = row['payment_method']?.toString().toUpperCase() ?? 'WALLET';
          final trxType = row['transaction_type']?.toString().toLowerCase() ?? 'parking_payment';
          String type = 'Parkir';
          if (trxType == 'wallet_topup' || trxType == 'wallet_injection') {
            type = 'Top-up Wallet';
          } else if (trxType == 'penalty') {
            type = 'Penalti Overstay';
          } else if (trxType == 'refund') {
            type = 'Refund';
          }

          final userData = row['users'] as Map<String, dynamic>?;
          final userName = userData?['full_name'] ?? 'Pelanggan ParkSmart';
          final userPhone = userData?['phone'] ?? '+62 812-3456-7890';
          final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'P';

          final createdFull = _formatFullDate(row['created_at']);
          final completedFull = row['completed_at'] != null ? _formatFullDate(row['completed_at']) : createdFull;

          String? ticketMark;
          if (type == 'Parkir') {
            final bData = row['bookings'] as Map<String, dynamic>?;
            final sData = row['parking_sessions'] as Map<String, dynamic>?;
            ticketMark = TicketMark.resolve(
              paymentStatus: bData?['payment_status'] ?? (statusDb == 'completed' ? 'paid' : statusDb),
              bookingStatus: bData?['booking_status'],
              sessionStatus: sData?['status'],
            );
          }

          return {
            'id': row['transaction_code']?.toString() ?? 'TRX-001',
            'user': {'name': userName, 'phone': userPhone, 'avatar': initial},
            'type': type,
            'location': 'Central Park Mall',
            'slot': 'A-05',
            'amount': amt,
            'paymentMethod': method,
            'status': statusLabel,
            'ticketMark': ticketMark,
            'blockchainHash': '0x${row['id']?.toString().replaceAll('-', '').substring(0, 10)}...',
            'description': row['description'] ?? 'Transaksi ParkSmart $type',
            'createdAt': createdFull,
            'completedAt': completedFull,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminTransactionsBackend] fetchTransactions error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateStatus(String txnId, String newStatus) {
    final idx = transactions.indexWhere((t) => t['id'] == txnId);
    if (idx != -1) {
      transactions[idx]['status'] = newStatus;
      if (newStatus == 'Berhasil') {
        transactions[idx]['completedAt'] = DateTime.now().toString().split('.')[0];
        transactions[idx]['blockchainHash'] =
            '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}...';
        if (transactions[idx]['ticketMark'] == TicketMark.belumDibayar) {
          transactions[idx]['ticketMark'] = TicketMark.ready;
        }
      }
      notifyListeners();
    }
  }
}
