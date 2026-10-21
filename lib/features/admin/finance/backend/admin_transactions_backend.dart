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

  List<Map<String, dynamic>> transactions = [];

  /// Format tanggal ramah pengguna dalam zona waktu WIB
  String _formatFullDate(dynamic dateRaw) {
    if (dateRaw == null) return '-';
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
    transactions = []; // Selalu reset daftar saat memulai pengambilan data
    notifyListeners();

    try {
      final res = await _client
          .from('payments')
          .select('''
            id,
            transaction_code,
            amount,
            payment_method,
            status,
            transaction_type,
            description,
            blockchain_hash,
            created_at,
            completed_at,
            booking_id,
            session_id,
            users(full_name, phone),
            bookings(
              booking_code,
              booking_status,
              payment_status,
              parking_locations(name),
              parking_slots(slot_code)
            ),
            parking_sessions(
              session_code,
              status,
              plate_number,
              parking_locations(name),
              parking_slots(slot_code)
            )
          ''')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        transactions = res.map<Map<String, dynamic>>((row) {
          final amt = (row['amount'] as num?)?.toInt() ?? 0;
          final statusDb = row['status']?.toString().toLowerCase();

          String statusLabel = 'Berhasil';
          if (statusDb == 'pending') {
            statusLabel = 'Pending';
          } else if (statusDb == 'failed' || statusDb == 'error') {
            statusLabel = 'Gagal';
          } else if (statusDb == 'refunded' || statusDb == 'cancelled') {
            statusLabel = 'Dibatalkan';
          }

          final method = (row['payment_method']?.toString() ?? 'WALLET').toUpperCase();
          final trxType = row['transaction_type']?.toString().toLowerCase() ?? 'parking_payment';
          String type = 'Parkir';
          if (trxType == 'wallet_topup') {
            type = 'Top-up Wallet';
          } else if (trxType == 'wallet_injection') {
            type = 'Injeksi Admin';
          } else if (trxType == 'penalty' || trxType == 'penalty_overstay') {
            type = 'Penalti Overstay';
          } else if (trxType == 'refund') {
            type = 'Refund';
          } else if (trxType == 'cashback') {
            type = 'Cashback';
          }

          final userData = row['users'] as Map<String, dynamic>?;
          final userName = userData?['full_name'] ?? 'Pelanggan ParkSmart';
          final userPhone = userData?['phone'] ?? '-';
          final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'P';

          final bData = row['bookings'] as Map<String, dynamic>?;
          final sData = row['parking_sessions'] as Map<String, dynamic>?;

          final locationName = bData?['parking_locations']?['name']?.toString() ??
              sData?['parking_locations']?['name']?.toString() ??
              '-';
          final slotCode = bData?['parking_slots']?['slot_code']?.toString() ??
              sData?['parking_slots']?['slot_code']?.toString() ??
              '-';

          final createdFull = _formatFullDate(row['created_at']);
          final completedFull = row['completed_at'] != null ? _formatFullDate(row['completed_at']) : createdFull;
          final DateTime? rawDate = row['created_at'] != null ? DateTime.tryParse(row['created_at'].toString()) : null;

          String? ticketMark;
          if (type == 'Parkir') {
            ticketMark = TicketMark.resolve(
              paymentStatus: bData?['payment_status'] ?? (statusDb == 'success' || statusDb == 'paid' ? 'paid' : statusDb),
              bookingStatus: bData?['booking_status'],
              sessionStatus: sData?['status'],
            );
          }

          final hash = row['blockchain_hash']?.toString().isNotEmpty == true
              ? row['blockchain_hash'].toString()
              : '0x${row['id']?.toString().replaceAll('-', '').substring(0, 10)}...';

          return {
            'id': row['transaction_code']?.toString() ?? 'TRX-001',
            'user': {'name': userName, 'phone': userPhone, 'avatar': initial},
            'type': type,
            'location': locationName,
            'slot': slotCode,
            'amount': amt,
            'paymentMethod': method,
            'status': statusLabel,
            'ticketMark': ticketMark,
            'blockchainHash': hash,
            'description': row['description'] ?? 'Transaksi ParkSmart $type',
            'createdAt': createdFull,
            'completedAt': completedFull,
            'rawDate': rawDate,
          };
        }).toList();
      } else {
        transactions = [];
      }
    } catch (e) {
      debugPrint('[AdminTransactionsBackend] fetchTransactions error: $e');
      _errorMessage = e.toString();
      transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String txnId, String newStatus) async {
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

    try {
      String dbStatus = 'pending';
      if (newStatus == 'Berhasil') dbStatus = 'success';
      if (newStatus == 'Gagal') dbStatus = 'failed';
      if (newStatus == 'Refunded' || newStatus == 'Dibatalkan') dbStatus = 'refunded';

      await _client.from('payments').update({
        'status': dbStatus,
        if (dbStatus == 'success') 'completed_at': DateTime.now().toIso8601String(),
      }).eq('transaction_code', txnId);
    } catch (e) {
      debugPrint('[AdminTransactionsBackend] updateStatus db error: $e');
    }
  }
}
