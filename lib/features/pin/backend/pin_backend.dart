import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';
import '../../../core/services/session_service.dart';
import '../../profile/backend/profile_backend.dart';

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

  String _resolveUserId(String? userId) {
    if (userId != null && userId.isNotEmpty) return userId;
    if (ProfileBackend.instance.userId.isNotEmpty) return ProfileBackend.instance.userId;
    final sessionUid = SessionService.instance.userId;
    if (sessionUid != null && sessionUid.isNotEmpty) return sessionUid;
    return _client.auth.currentUser?.id ?? '';
  }

  /// Memeriksa apakah pengguna sudah memiliki PIN terdaftar di database
  Future<bool> hasPin({String? userId, bool forceRefresh = false}) async {
    try {
      final uid = _resolveUserId(userId);
      final queryKey = 'user_pin_${uid.isNotEmpty ? uid : 'default'}';

      if (forceRefresh) {
        await DatabaseCacheBalancerService.instance.invalidate(queryKey);
        await DatabaseCacheBalancerService.instance.invalidate('user_pin_settings_${uid.isNotEmpty ? uid : 'default'}');
      }

      final pinData = await DatabaseCacheBalancerService.instance.getBalanced<String?>(
        queryKey: queryKey,
        ttl: const Duration(minutes: 2),
        queryFn: () async {
          if (uid.isNotEmpty) {
            final res = await _client.from('users').select('pin_hash').eq('id', uid).maybeSingle();
            return res?['pin_hash']?.toString();
          } else {
            final res = await _client.from('users').select('pin_hash').limit(1).maybeSingle();
            return res?['pin_hash']?.toString();
          }
        },
      );

      return pinData != null && pinData.trim().isNotEmpty;
    } catch (e) {
      debugPrint('[PinBackend] hasPin check error: $e');
      return false;
    }
  }

  /// Memverifikasi PIN input pengguna terhadap `users.pin_hash`
  Future<bool> verifyPin(String pin, {String? userId}) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _resolveUserId(userId);

      // Ambil pin dari database
      final pinData = await DatabaseCacheBalancerService.instance.getBalanced<String?>(
        queryKey: 'user_pin_${uid.isNotEmpty ? uid : 'default'}',
        ttl: const Duration(minutes: 2),
        queryFn: () async {
          if (uid.isNotEmpty) {
            final res = await _client.from('users').select('pin_hash').eq('id', uid).maybeSingle();
            return res?['pin_hash']?.toString();
          } else {
            final res = await _client.from('users').select('pin_hash').limit(1).maybeSingle();
            return res?['pin_hash']?.toString();
          }
        },
      );

      if (pinData == null || pinData.isEmpty) {
        _errorMessage = 'PIN transaksi belum diatur. Silakan buat PIN terlebih dahulu.';
        return false;
      }

      final isMatch = (pin == pinData);

      if (!isMatch) {
        _errorMessage = 'PIN yang dimasukkan salah. Coba lagi.';
      }
      return isMatch;
    } catch (e) {
      debugPrint('[PinBackend] Error verifikasi PIN: $e');
      _errorMessage = 'Gagal memverifikasi PIN. Silakan periksa koneksi Anda.';
      return false;
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
      final uid = _resolveUserId(userId);

      if (uid.isNotEmpty) {
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
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_${uid.isNotEmpty ? uid : 'default'}');
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_default');
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_settings_${uid.isNotEmpty ? uid : 'default'}');
      notifyListeners();
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

  /// Menghapus PIN transaksi pengguna dari database (`users.pin_hash` = null)
  Future<bool> deletePin({String? userId}) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = _resolveUserId(userId);

      if (uid.isNotEmpty) {
        await _client.from('users').update({
          'pin_hash': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', uid);
      } else {
        final firstUser = await _client.from('users').select('id').limit(1).maybeSingle();
        if (firstUser != null) {
          await _client.from('users').update({
            'pin_hash': null,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', firstUser['id']);
        }
      }

      // Bersihkan seluruh cache PIN
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_${uid.isNotEmpty ? uid : 'default'}');
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_default');
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_settings_${uid.isNotEmpty ? uid : 'default'}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[PinBackend] Gagal menghapus PIN: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
