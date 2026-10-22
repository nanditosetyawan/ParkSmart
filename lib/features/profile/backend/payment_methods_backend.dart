import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../home/backend/home_backend.dart';
import 'profile_backend.dart';

/// Backend khusus untuk PaymentMethodsScreen (lib/features/profile/payment_methods_screen.dart)
class PaymentMethodsBackend extends ChangeNotifier {
  PaymentMethodsBackend._();
  static final PaymentMethodsBackend instance = PaymentMethodsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _balance = 0;
  int get balance => _balance;

  bool _autoDebet = true;
  bool get autoDebet => _autoDebet;

  String _selectedMethod = 'parksmart_pay';
  String get selectedMethod => _selectedMethod;

  final Set<String> _savedMethods = {'gopay'};
  Set<String> get savedMethods => _savedMethods;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> get transactions => _transactions;

  int _totalIncome = 0;
  int get totalIncome => _totalIncome;

  int _totalExpense = 0;
  int get totalExpense => _totalExpense;

  void setSelectedMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  void toggleAutoDebet(bool val) {
    _autoDebet = val;
    notifyListeners();
  }

  void addSavedMethod(String method) {
    _savedMethods.add(method);
    notifyListeners();
  }

  void removeSavedMethod(String method) {
    _savedMethods.remove(method);
    notifyListeners();
  }

  void clear() {
    _balance = 0;
    _transactions = [];
    _totalIncome = 0;
    _totalExpense = 0;
    notifyListeners();
  }

  String _getResolvedUserId() {
    if (ProfileBackend.instance.userId.isNotEmpty) {
      return ProfileBackend.instance.userId;
    }
    if (SessionService.instance.userId != null && SessionService.instance.userId!.isNotEmpty) {
      return SessionService.instance.userId!;
    }
    if (HomeBackend.instance.userId.isNotEmpty) {
      return HomeBackend.instance.userId;
    }
    return '';
  }

  /// Helper asinkron untuk menjamin User ID aktif tidak pernah kosong
  Future<String> _resolveUserIdAsync() async {
    final direct = _getResolvedUserId();
    if (direct.isNotEmpty) return direct;

    final prefs = await SharedPreferences.getInstance();
    final prefUid = prefs.getString('user_profile_id') ?? prefs.getString('ps_session_user_id');
    if (prefUid != null && prefUid.isNotEmpty) {
      return prefUid;
    }

    final authUser = _client.auth.currentUser;
    if (authUser != null) {
      try {
        final row = await _client.from('users').select('id').eq('auth_user_id', authUser.id).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }

    final email = SessionService.instance.identifier ?? ProfileBackend.instance.email;
    if (email.isNotEmpty) {
      try {
        final row = await _client.from('users').select('id').eq('email', email).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }

    return '';
  }

  Future<void> fetchBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = await _resolveUserIdAsync();

      if (uid.isEmpty) {
        _balance = ProfileBackend.instance.walletBalance;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final res = await _client
          .from('users')
          .select('wallet_balance')
          .eq('id', uid)
          .maybeSingle();

      if (res != null && res['wallet_balance'] != null) {
        _balance = (double.tryParse(res['wallet_balance'].toString()) ?? 0).toInt();
      } else {
        _balance = 0;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_wallet_balance', _balance);
      await fetchTransactions();
    } catch (e) {
      debugPrint('PaymentMethodsBackend fetchBalance fallback: $e');
      _balance = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengambil daftar mutasi transaksi (Top Up dan Pembayaran Parkir) langsung dari database Supabase
  Future<void> fetchTransactions() async {
    try {
      final uid = await _resolveUserIdAsync();
      if (uid.isEmpty) {
        _transactions = [];
        _totalIncome = 0;
        _totalExpense = 0;
        notifyListeners();
        return;
      }

      final response = await _client
          .from('payments')
          .select('id, transaction_code, amount, transaction_type, payment_method, description, status, created_at, completed_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> list = [];
      int income = 0;
      int expense = 0;

      for (var row in response) {
        final amountNum = (row['amount'] as num?)?.toDouble() ?? 0.0;
        final rawAmount = amountNum.toInt();
        final txType = (row['transaction_type'] ?? '').toString().toLowerCase();
        final isIncome = txType == 'wallet_topup' || txType == 'topup' || txType == 'refund';
        final method = (row['payment_method'] ?? '').toString().toLowerCase();
        final code = row['transaction_code']?.toString() ?? 'TRX-${row['id'].toString().substring(0, 8)}';
        final desc = row['description']?.toString() ?? '';
        final statusRaw = (row['status'] ?? 'success').toString().toLowerCase();

        String statusLabel = 'Berhasil';
        if (statusRaw == 'completed' || statusRaw == 'success') {
          statusLabel = isIncome ? 'Berhasil' : 'Selesai';
        } else if (statusRaw == 'pending') {
          statusLabel = 'Menunggu';
        } else if (statusRaw == 'failed') {
          statusLabel = 'Gagal';
        }

        String title = 'Transaksi Saldo';
        String channel = 'ParkSmart Pay';
        String subtitle = desc;

        if (isIncome) {
          title = 'Isi Ulang Saldo (Top Up)';
          if (method == 'gopay') {
            channel = 'E-Wallet GoPay';
            subtitle = subtitle.isNotEmpty ? subtitle : 'GoPay Instant Top-Up';
          } else {
            channel = 'Bank Transfer / VA';
            subtitle = subtitle.isNotEmpty ? subtitle : 'Virtual Account • Sukses';
          }
          if (statusRaw == 'success' || statusRaw == 'completed') {
            income += rawAmount;
          }
        } else {
          title = desc.isNotEmpty ? desc : 'Pembayaran Parkir';
          if (method == 'wallet') {
            channel = 'ParkSmart Auto-Pay';
          } else if (method == 'qris') {
            channel = 'QRIS Digital';
          } else {
            channel = 'ParkSmart Pay';
          }
          if (subtitle.isEmpty) {
            subtitle = 'Potong Saldo ParkSmart Pay';
          }
          if (statusRaw == 'success' || statusRaw == 'completed') {
            expense += rawAmount;
          }
        }

        // Format tanggal (contoh: Hari ini, 22 Okt 2026 • 21:12 WIB)
        final timeStr = row['completed_at'] ?? row['created_at'];
        String formattedDate = '-';
        if (timeStr != null) {
          final dt = DateTime.tryParse(timeStr.toString())?.toLocal();
          if (dt != null) {
            final now = DateTime.now();
            final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
            const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
            final monthName = months[dt.month - 1];
            final timePart = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
            if (isToday) {
              formattedDate = 'Hari ini, ${dt.day} $monthName ${dt.year} • $timePart';
            } else {
              formattedDate = '${dt.day} $monthName ${dt.year} • $timePart';
            }
          }
        }

        list.add({
          'id': code,
          'title': title,
          'subtitle': subtitle,
          'date': formattedDate,
          'rawAmount': rawAmount,
          'isIncome': isIncome,
          'status': statusLabel,
          'channel': channel,
        });
      }

      _transactions = list;
      _totalIncome = income;
      _totalExpense = expense;
      notifyListeners();
    } catch (e) {
      debugPrint('[PaymentMethodsBackend] fetchTransactions error: $e');
    }
  }

  Future<bool> topUp(int amount, String method) async {
    _isLoading = true;
    notifyListeners();

    try {
      final actualUserId = await _resolveUserIdAsync();
      if (actualUserId.isEmpty) {
        debugPrint('[PaymentMethodsBackend] topUp error: User ID tidak ditemukan!');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Ambil saldo terbaru dari database terlebih dahulu untuk akurasi data
      double currentBalance = _balance.toDouble();
      try {
        final uRow = await _client.from('users').select('wallet_balance').eq('id', actualUserId).maybeSingle();
        if (uRow != null && uRow['wallet_balance'] != null) {
          currentBalance = (double.tryParse(uRow['wallet_balance'].toString()) ?? _balance.toDouble());
        }
      } catch (e) {
        debugPrint('[PaymentMethodsBackend] uRow balance fetch warning: $e');
      }

      final newBalance = (currentBalance + amount).toInt();
      _balance = newBalance;

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_wallet_balance', newBalance);

      // Simpan saldo terbaru ke database Supabase
      await _client
          .from('users')
          .update({'wallet_balance': newBalance})
          .eq('id', actualUserId);

      // Catat ke tabel payments untuk audit finansial admin
      final trxCode = 'TOPUP-${DateTime.now().millisecondsSinceEpoch}';
      await _client.from('payments').insert({
        'transaction_code': trxCode,
        'user_id': actualUserId,
        'amount': amount,
        'transaction_type': 'wallet_topup',
        'payment_method': method == 'gopay' ? 'gopay' : 'bank_va',
        'description': 'Top Up Saldo ParkSmart Pay ($method)',
        'status': 'success',
        'completed_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Refresh seluruh backend terkait
      await fetchTransactions();
      await ProfileBackend.instance.fetchProfile();
      await HomeBackend.instance.loadHomeData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[PaymentMethodsBackend] topUp fatal error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
