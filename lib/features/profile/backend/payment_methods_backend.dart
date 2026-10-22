import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> fetchBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = ProfileBackend.instance.userId.isNotEmpty
          ? ProfileBackend.instance.userId
          : (_client.auth.currentUser?.id ?? '');

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
    } catch (e) {
      debugPrint('PaymentMethodsBackend fetchBalance fallback: $e');
      _balance = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> topUp(int amount, String method) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newBalance = _balance + amount;
      _balance = newBalance;

      // Simpan lokal
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_wallet_balance', newBalance);

      // Simpan ke Supabase
      try {
        final user = _client.auth.currentUser;
        final userId = user?.id;

        if (userId != null) {
          await _client
              .from('users')
              .update({'wallet_balance': newBalance})
              .eq('auth_user_id', userId);
        } else {
          await _client
              .from('users')
              .update({'wallet_balance': newBalance})
              .eq('id', ProfileBackend.instance.userId);
        }

        // Dapatkan user_id dari tabel users
        String actualUserId = ProfileBackend.instance.userId;
        if (userId != null) {
          final uRow = await _client.from('users').select('id').eq('auth_user_id', userId).maybeSingle();
          if (uRow != null && uRow['id'] != null) {
            actualUserId = uRow['id'].toString();
          }
        }

        // Catat di tabel payments
        await _client.from('payments').insert({
          'transaction_code': 'TOPUP-${DateTime.now().millisecondsSinceEpoch}',
          'user_id': actualUserId,
          'amount': amount,
          'transaction_type': 'wallet_topup',
          'payment_method': method == 'gopay' ? 'gopay' : 'bank_va',
          'description': 'Top Up Saldo ParkSmart Pay',
          'status': 'success',
          'completed_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Supabase topUp remote sync fallback: $e');
      }

      await ProfileBackend.instance.fetchProfile();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
