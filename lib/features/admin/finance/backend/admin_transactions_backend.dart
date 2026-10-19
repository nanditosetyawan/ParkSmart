import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      'blockchainHash': '0x6f4a...2d8e',
      'description': 'Refund pembatalan booking',
      'createdAt': '2024-03-15 07:30',
      'completedAt': '2024-03-15 07:31',
    },
  ];

  late List<Map<String, dynamic>> transactions = List.from(_defaultTransactions);

  /// Mengambil daftar transaksi dari Supabase
  Future<void> fetchTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('payments')
          .select('id, payment_code, amount, payment_method, payment_status, created_at')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        transactions = res.map<Map<String, dynamic>>((row) {
          final amt = (row['amount'] as num?)?.toInt() ?? 10000;
          final statusDb = row['payment_status']?.toString().toLowerCase();

          String statusLabel = 'Berhasil';
          if (statusDb == 'pending') {
            statusLabel = 'Pending';
          } else if (statusDb == 'failed') {
            statusLabel = 'Gagal';
          } else if (statusDb == 'cancelled') {
            statusLabel = 'Dibatalkan';
          }

          final method = row['payment_method']?.toString() ?? 'QRIS';
          String type = 'Parkir';
          if (method.contains('injection') || method.contains('topup')) {
            type = 'Top-up Wallet';
          }

          return {
            'id': row['payment_code']?.toString() ?? 'TXN-001',
            'user': {'name': 'Pelanggan ParkSmart', 'phone': '+62 812-xxxx-xxxx', 'avatar': 'P'},
            'type': type,
            'location': 'Central Park Mall',
            'slot': 'A-05',
            'amount': amt,
            'paymentMethod': method,
            'status': statusLabel,
            'blockchainHash': '0x${row['id']?.toString().replaceAll('-', '').substring(0, 10)}...',
            'description': 'Transaksi ParkSmart $type',
            'createdAt': row['created_at']?.toString().split('.')[0] ?? '2026-10-20',
            'completedAt': row['created_at']?.toString().split('.')[0] ?? '2026-10-20',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminTransactionsBackend] fetchTransactions error: $e');
      _errorMessage = e.toString();
      if (transactions.isEmpty) {
        transactions = List.from(_defaultTransactions);
      }
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
      }
      notifyListeners();
    }
  }
}

