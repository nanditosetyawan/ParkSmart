import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': 'usr-001',
      'name': 'Nanda Setiawan',
      'email': 'nanda.setiawan@gmail.com',
      'phone': '+62 812-3456-7890',
      'balance': 45000,
      'avatar': 'N',
    },
    {
      'id': 'usr-002',
      'name': 'Rafi Maulana',
      'email': 'rafi.maulana@gmail.com',
      'phone': '+62 856-7890-1234',
      'balance': 120000,
      'avatar': 'R',
    },
    {
      'id': 'usr-003',
      'name': 'Siti Rahayu',
      'email': 'siti.rahayu@gmail.com',
      'phone': '+62 878-1122-3344',
      'balance': 15000,
      'avatar': 'S',
    },
    {
      'id': 'usr-004',
      'name': 'Dewi Lestari',
      'email': 'dewi.lestari@gmail.com',
      'phone': '+62 813-9988-7766',
      'balance': 230000,
      'avatar': 'D',
    },
    {
      'id': 'usr-005',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@gmail.com',
      'phone': '+62 821-4455-6677',
      'balance': 0,
      'avatar': 'B',
    },
    {
      'id': 'usr-006',
      'name': 'Ahmad Fauzi',
      'email': 'ahmad.fauzi@gmail.com',
      'phone': '+62 812-9911-2233',
      'balance': 85000,
      'avatar': 'A',
    },
    {
      'id': 'usr-007',
      'name': 'Linda Wijaya',
      'email': 'linda.wijaya@gmail.com',
      'phone': '+62 818-4455-6677',
      'balance': 310000,
      'avatar': 'L',
    },
    {
      'id': 'usr-008',
      'name': 'Rizky Pratama',
      'email': 'rizky.pratama@gmail.com',
      'phone': '+62 877-3322-1100',
      'balance': 12500,
      'avatar': 'R',
    },
  ];

  final List<Map<String, dynamic>> _defaultInjections = [
    {
      'userName': 'Nanda Setiawan',
      'userEmail': 'nanda.setiawan@gmail.com',
      'amount': 500000,
      'reason': 'Kompensasi kendala barrier gate B2',
      'time': '1 jam lalu',
      'admin': 'Admin Pusat (Dito)',
      'status': 'Berhasil',
    },
    {
      'userName': 'Siti Rahayu',
      'userEmail': 'siti.rahayu@gmail.com',
      'amount': 50000,
      'reason': 'Bonus KYC KTP Terverifikasi',
      'time': '3 jam lalu',
      'admin': 'Sistem Otomatis',
      'status': 'Berhasil',
    },
    {
      'userName': 'Rafi Maulana',
      'userEmail': 'rafi.maulana@gmail.com',
      'amount': 100000,
      'reason': 'Top-up Manual Kasir Kantor Parkir',
      'time': 'Kemarin, 16:40',
      'admin': 'Admin Lokasi (Central Park)',
      'status': 'Berhasil',
    },
  ];

  late List<Map<String, dynamic>> users = List.from(_defaultUsers);
  late List<Map<String, dynamic>> recentInjections = List.from(_defaultInjections);

  /// Mengambil data pengguna dan saldo dari Supabase
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('users')
          .select('id, full_name, email, phone, wallet_balance')
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
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminWalletBackend] fetchUsers error: $e');
      _errorMessage = e.toString();
      if (users.isEmpty) {
        users = List.from(_defaultUsers);
      }
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
    if (idx != -1) {
      final user = users[idx];
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
      notifyListeners();
    }

    try {
      // 1. Update wallet balance di tabel users
      final userRecord = await _client
          .from('users')
          .select('wallet_balance')
          .eq('id', userId)
          .maybeSingle();

      final current = (userRecord?['wallet_balance'] as num?)?.toInt() ?? 0;
      await _client.from('users').update({
        'wallet_balance': current + amount,
      }).eq('id', userId);

      // 2. Rekam transaksi top-up di tabel payments
      await _client.from('payments').insert({
        'payment_code': 'INJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'amount': amount,
        'payment_method': 'admin_injection',
        'payment_status': 'success',
      });

      return true;
    } catch (e) {
      debugPrint('[AdminWalletBackend] injectBalance error: $e');
      return false;
    }
  }
}
