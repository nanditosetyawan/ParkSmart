import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk SettingsScreen
/// Menghubungkan pengaturan aplikasi profil dengan tabel `public.users` dan `public.system_settings`.
class SettingsBackend extends ChangeNotifier {
  SettingsBackend._();
  static final SettingsBackend instance = SettingsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic> _userSettings = {
    'full_name': 'Arya Raditya',
    'email': 'arya.raditya@gmail.com',
    'phone': '+62 812-3456-7890',
    'theme_mode': 'system',
    'is_biometric_enabled': true,
  };
  Map<String, dynamic> get userSettings => _userSettings;

  /// Memuat profil dan preferensi pengguna dari database
  Future<void> fetchUserSettings({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;

      final data = await DatabaseCacheBalancerService.instance.getBalanced<Map<String, dynamic>?>(
        queryKey: 'user_profile_settings_${uid ?? 'default'}',
        ttl: const Duration(minutes: 5),
        queryFn: () async {
          if (uid != null) {
            return await _client
                .from('users')
                .select('full_name, email, phone, theme_mode, is_biometric_enabled')
                .eq('id', uid)
                .maybeSingle();
          } else {
            return await _client
                .from('users')
                .select('full_name, email, phone, theme_mode, is_biometric_enabled')
                .limit(1)
                .maybeSingle();
          }
        },
      );

      if (data != null) {
        _userSettings = {
          'full_name': data['full_name'] ?? _userSettings['full_name'],
          'email': data['email'] ?? _userSettings['email'],
          'phone': data['phone'] ?? _userSettings['phone'],
          'theme_mode': data['theme_mode'] ?? 'system',
          'is_biometric_enabled': data['is_biometric_enabled'] ?? true,
        };
      }
    } catch (e) {
      debugPrint('[SettingsBackend] Fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sinkronisasi theme_mode ke database
  Future<void> updateThemeMode(String themeMode, {String? userId}) async {
    _userSettings['theme_mode'] = themeMode;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid != null) {
        await _client.from('users').update({
          'theme_mode': themeMode,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', uid);
      }
      await DatabaseCacheBalancerService.instance.invalidate('user_profile_settings_${uid ?? 'default'}');
    } catch (e) {
      debugPrint('[SettingsBackend] updateThemeMode error: $e');
    }
  }
}
