import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_transactions_backend.dart';

/// Backend khusus untuk AdminWalletScreen (admin_wallet_screen.dart)
/// Mengelola injeksi saldo dompet, audit mutasi top-up manual, dan daftar saldo pengguna
/// Terkoneksi ke `public.users` dan `public.payments` di Supabase
class AdminWalletBackend extends ChangeNotifier {
  AdminWalletBackend._();
  static final AdminWalletBackend instance = AdminWalletBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> recentInjections = [];
  int totalKasBalance = 0;

  int get totalDepositBalance =>
      users.fold<int>(0, (sum, u) => sum + ((u['balance'] as num?)?.toInt() ?? 0));

  int get activeUsersCount => users.length;

  /// Mengambil data pengguna dan saldo dari Supabase
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('users')
          .select('id, full_name, email, phone, wallet_balance, avatar_url')
          .order('full_name', ascending: true);

      if (res.isNotEmpty) {
        users = res.map<Map<String, dynamic>>((row) {
          final name = row['full_name']?.toString() ?? 'Pengguna';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
          final bal = (row['wallet_balance'] as num?)?.toInt() ?? 0;

          return {
            'id': row['id']?.toString() ?? 'usr-000',
            'name': name,
            'email': row['email']?.toString() ?? '-',
            'phone': row['phone']?.toString() ?? '-',
            'balance': bal,
            'avatar': initial,
            'avatar_url': row['avatar_url']?.toString(),
          };
        }).toList();
      } else {
        users = [];
      }

      // Hitung total saldo kas utama dari system_settings (disinkronkan dengan payments & kas perusahaan)
      try {
        final treasuryRow = await _client
            .from('system_settings')
            .select('value')
            .eq('key', 'company_treasury')
            .maybeSingle();

        int kas = 50000000;
        if (treasuryRow != null && treasuryRow['value'] != null) {
          final val = treasuryRow['value'];
          if (val is Map && val['balance'] != null) {
            kas = (val['balance'] as num).toInt();
          }
        } else {
          // Inisialisasi kas cadangan di system_settings jika belum ada
          await _client.from('system_settings').upsert({
            'key': 'company_treasury',
            'value': {'balance': 50000000, 'initial_capital': 50000000, 'currency': 'IDR'},
            'description': 'Saldo kas utama cadangan operasional ParkSmart ID',
            'updated_at': DateTime.now().toIso8601String(),
          });
          kas = 50000000;
        }
        totalKasBalance = kas;
      } catch (e) {
        debugPrint('[AdminWalletBackend] fetchKas error: $e');
        totalKasBalance = 50000000;
      }

      // Ambil log injeksi saldo dari payments
      try {
        final injRes = await _client
            .from('payments')
            .select('id, transaction_code, amount, description, created_at, users(full_name, email, avatar_url)')
            .eq('transaction_type', 'wallet_injection')
            .order('created_at', ascending: false)
            .limit(10);

        if (injRes.isNotEmpty) {
          recentInjections = injRes.map<Map<String, dynamic>>((row) {
            final u = row['users'] as Map<String, dynamic>?;
            final uName = u?['full_name']?.toString() ?? 'Pengguna';
            final uEmail = u?['email']?.toString() ?? '-';
            final uAvatar = u?['avatar_url']?.toString();
            final amt = (row['amount'] as num?)?.toInt() ?? 0;
            final reason = row['description']?.toString() ?? 'Injeksi Saldo Manual';
            final timeStr = row['created_at'] != null ? row['created_at'].toString().substring(0, 16) : '-';

            return {
              'userName': uName,
              'userEmail': uEmail,
              'userAvatar': uAvatar,
              'amount': amt,
              'reason': reason,
              'time': timeStr,
              'admin': 'Admin Finansial',
              'status': 'Berhasil',
            };
          }).toList();
        } else {
          recentInjections = [];
        }
      } catch (e) {
        debugPrint('[AdminWalletBackend] fetchInjections error: $e');
        recentInjections = [];
      }
    } catch (e) {
      debugPrint('[AdminWalletBackend] fetchUsers error: $e');
      _errorMessage = e.toString();
      users = [];
      recentInjections = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eksekusi Injeksi Saldo ke User
  Future<bool> injectBalance({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    final idx = users.indexWhere((u) => u['id'] == userId);
    final user = idx != -1 ? users[idx] : null;
    if (user != null) {
      user['balance'] = (user['balance'] as int) + amount;

      recentInjections.insert(0, {
        'userName': user['name'],
        'userEmail': user['email'],
        'amount': amount,
        'reason': reason,
        'time': 'Baru saja',
        'admin': 'Admin Finansial',
        'status': 'Berhasil',
      });
    }

    // Saldo kas perusahaan terpotong di memori
    totalKasBalance = (totalKasBalance - amount) > 0 ? (totalKasBalance - amount) : 0;
    notifyListeners();

    try {
      // 1. Update wallet balance di tabel users
      final userRecord = await _client
          .from('users')
          .select('wallet_balance')
          .eq('id', userId)
          .maybeSingle();

      final current = (userRecord?['wallet_balance'] as num?)?.toInt() ?? 0;
      final newBalance = current + amount;
      await _client.from('users').update({
        'wallet_balance': newBalance,
      }).eq('id', userId);

      // 2. Potong saldo kas perusahaan di system_settings secara sinkron database
      try {
        final treasuryRow = await _client
            .from('system_settings')
            .select('value')
            .eq('key', 'company_treasury')
            .maybeSingle();

        int currentKas = totalKasBalance;
        if (treasuryRow != null && treasuryRow['value'] != null) {
          final val = treasuryRow['value'];
          if (val is Map && val['balance'] != null) {
            currentKas = (val['balance'] as num).toInt();
          }
        }
        final updatedKas = (currentKas - amount) > 0 ? (currentKas - amount) : 0;
        await _client.from('system_settings').upsert({
          'key': 'company_treasury',
          'value': {
            'balance': updatedKas,
            'last_injection': amount,
            'last_user_id': userId,
            'currency': 'IDR',
          },
          'description': 'Saldo kas utama cadangan operasional ParkSmart ID',
          'updated_at': DateTime.now().toIso8601String(),
        });
        totalKasBalance = updatedKas;
      } catch (e) {
        debugPrint('[AdminWalletBackend] deduct kas error: $e');
      }

      // 3. Rekam transaksi pengeluaran/injeksi di tabel payments
      await _client.from('payments').insert({
        'transaction_code': 'INJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'user_id': userId,
        'transaction_type': 'wallet_injection',
        'payment_method': 'admin_manual',
        'amount': amount,
        'description': reason,
        'status': 'success',
        'completed_at': DateTime.now().toIso8601String(),
      });

      // 4. Catat audit log aktivitas
      try {
        await _client.from('admin_audit_logs').insert({
          'admin_name': 'Admin Finansial',
          'role': 'Admin Finansial',
          'action': 'Injeksi Saldo Dompet $amount ke User ${user?['name'] ?? userId}',
          'device_model': 'Portal Finansial Admin',
          'status': 'Berhasil',
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}

      // 5. Rekam notifikasi ke tabel system_notifications untuk Admin Finansial & User bersangkutan
      try {
        final formattedAmt = 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
        final recipientName = user?['name'] ?? 'Pengguna';

        // A. Notifikasi ke Portal Admin Finansial
        await _client.from('system_notifications').insert({
          'recipient_user_id': userId,
          'target_role': 'finance',
          'title': 'Injeksi Saldo Dompet',
          'message': 'Berhasil menambahkan saldo $formattedAmt ke dompet $recipientName. Keterangan: $reason',
          'notification_type': 'success',
          'action_type': 'wallet_injection',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        // B. Notifikasi ke User yang bersangkutan
        await _client.from('system_notifications').insert({
          'recipient_user_id': userId,
          'target_role': 'user',
          'title': 'Saldo Dompet Masuk',
          'message': 'Saldo sebesar $formattedAmt telah ditambahkan ke dompet digital Anda oleh Admin Finansial. Keterangan: $reason',
          'notification_type': 'wallet_injection',
          'action_type': 'wallet',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('[AdminWalletBackend] insert notifications error: $e');
      }

      // Sinkronkan data pengguna dan seluruh total saldo dari database secara real-time
      await fetchUsers();
      AdminTransactionsBackend.instance.fetchTransactions();
      return true;
    } catch (e) {
      debugPrint('[AdminWalletBackend] injectBalance error: $e');
      return false;
    }
  }
}
