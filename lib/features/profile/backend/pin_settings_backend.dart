import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk PinSettingsScreen
/// Mengelola pengubahan PIN, lupa PIN, dan sinkronisasi preferensi autentikasi biometrik ke database.
class PinSettingsBackend extends ChangeNotifier {
  PinSettingsBackend._();
  static final PinSettingsBackend instance = PinSettingsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isBiometricEnabled = true;
  bool get isBiometricEnabled => _isBiometricEnabled;

  /// Memuat status PIN dan preferensi biometrik pengguna dari tabel `public.users`
  Future<void> loadPinSettings({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;

      final data = await DatabaseCacheBalancerService.instance.getBalanced<Map<String, dynamic>?>(
        queryKey: 'user_pin_settings_${uid ?? 'default'}',
        ttl: const Duration(minutes: 5),
        queryFn: () async {
          if (uid != null) {
            return await _client
                .from('users')
                .select('pin_hash, is_biometric_enabled')
                .eq('id', uid)
                .maybeSingle();
          } else {
            return await _client
                .from('users')
                .select('pin_hash, is_biometric_enabled')
                .limit(1)
                .maybeSingle();
          }
        },
      );

      if (data != null) {
        _isBiometricEnabled = data['is_biometric_enabled'] ?? true;
      }
    } catch (e) {
      debugPrint('[PinSettingsBackend] Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui PIN baru (menggantikan/menimpa nilai di database)
  Future<bool> changePin({
    required String oldPin,
    required String newPin,
    String? userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;

      // Ambil pin_hash saat ini
      Map<String, dynamic>? userRow;
      if (uid != null) {
        userRow = await _client.from('users').select('id, pin_hash').eq('id', uid).maybeSingle();
      } else {
        userRow = await _client.from('users').select('id, pin_hash').limit(1).maybeSingle();
      }

      final currentPin = userRow?['pin_hash']?.toString();
      if (currentPin != null && currentPin.isNotEmpty && oldPin != currentPin) {
        _errorMessage = 'PIN lama salah!';
        return false;
      }

      final targetId = userRow?['id'];
      if (targetId != null) {
        await _client.from('users').update({
          'pin_hash': newPin,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', targetId);
      }

      // Bersihkan cache
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_${uid ?? 'default'}');
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_settings_${uid ?? 'default'}');
      return true;
    } catch (e) {
      debugPrint('[PinSettingsBackend] changePin error: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengubah status biometrik
  Future<bool> toggleBiometric(bool enabled, {String? userId}) async {
    _isBiometricEnabled = enabled;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid != null) {
        await _client.from('users').update({
          'is_biometric_enabled': enabled,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', uid);
      }
      await DatabaseCacheBalancerService.instance.invalidate('user_pin_settings_${uid ?? 'default'}');
      return true;
    } catch (e) {
      debugPrint('[PinSettingsBackend] toggleBiometric error: $e');
      return false;
    }
  }
}
