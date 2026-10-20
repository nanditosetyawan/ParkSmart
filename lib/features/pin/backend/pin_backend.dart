import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk PinScreen
/// Menangani verifikasi PIN transaksi dan keamanan dengan tabel `public.users.pin_hash`.
/// Sistem bersifat overwriting (1 baris per pengguna).
class PinBackend extends ChangeNotifier {
  PinBackend._();
  static final PinBackend instance = PinBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Memverifikasi PIN input pengguna terhadap `users.pin_hash`
  Future<bool> verifyPin(String pin, {String? userId}) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      
      // Ambil user dari cache balancer
      final pinData = await DatabaseCacheBalancerService.instance.getBalanced<String?>(
        queryKey: 'user_pin_${uid ?? 'default'}',
        ttl: const Duration(minutes: 10),
        queryFn: () async {
          if (uid != null) {
            final res = await _client.from('users').select('pin_hash').eq('id', uid).maybeSingle();
            return res?['pin_hash']?.toString();
          } else {
            final res = await _client.from('users').select('pin_hash').limit(1).maybeSingle();
            return res?['pin_hash']?.toString();
          }
        },
      );

      // Default PIN jika belum diatur di database adalah '1234'
      final validPin = pinData ?? '1234';
      final isMatch = (pin == validPin);

      if (!isMatch) {
        _errorMessage = 'PIN yang dimasukkan salah. Coba lagi.';
      }
      return isMatch;
    } catch (e) {
      debugPrint('[PinBackend] Error verifikasi PIN: $e');
      // Fallback untuk offline/dev: jika PIN 1234 anggap benar
      return pin == '1234';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Memperbarui PIN pengguna di tabel `public.users` (menimpa row yang ada)
  Future<bool> updatePin(String newPin, {String? userId}) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;

      if (uid != null) {
        await _client.from('users').update({
          'pin_hash': newPin,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', uid);
      } else {
        // Fallback update row pertama jika mode dev tanpa login
        final firstUser = await _client.from('users').select('id').limit(1).maybeSingle();
        if (firstUser != null) {
          await _client.from('users').update({
            'pin_hash': newPin,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', firstUser['id']);
        }
      }

      // Invalidasi cache pin
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_${uid ?? 'default'}');
      return true;
    } catch (e) {
      debugPrint('[PinBackend] Gagal update PIN: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
