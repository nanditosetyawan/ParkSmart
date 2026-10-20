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
                .select('full_name, email, phone, is_biometric_enabled')
                .eq('id', uid)
                .maybeSingle();
          } else {
            return await _client
                .from('users')
                .select('full_name, email, phone, is_biometric_enabled')
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
}
