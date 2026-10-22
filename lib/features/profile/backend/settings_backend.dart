import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';
import '../../../core/services/session_service.dart';
import 'profile_backend.dart';

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
    'full_name': 'Pengguna',
    'email': '',
    'phone': '',
    'avatar_url': null,
    'is_biometric_enabled': false,
  };
  Map<String, dynamic> get userSettings => _userSettings;

  /// Memuat profil dan preferensi pengguna dari database
  Future<void> fetchUserSettings({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ??
          (ProfileBackend.instance.userId.isNotEmpty
              ? ProfileBackend.instance.userId
              : (SessionService.instance.userId ?? ''));

      if (uid.isEmpty) {
        _userSettings = {
          'full_name': ProfileBackend.instance.name,
          'email': ProfileBackend.instance.email,
          'phone': ProfileBackend.instance.phone,
          'avatar_url': ProfileBackend.instance.avatarUrl,
          'is_biometric_enabled': false,
        };
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = await DatabaseCacheBalancerService.instance.getBalanced<Map<String, dynamic>?>(
        queryKey: 'user_profile_settings_$uid',
        ttl: const Duration(minutes: 5),
        queryFn: () async {
          return await _client
              .from('users')
              .select('full_name, email, phone, avatar_url, is_biometric_enabled')
              .eq('id', uid)
              .maybeSingle();
        },
      );

      if (data != null) {
        _userSettings = {
          'full_name': data['full_name'] ?? ProfileBackend.instance.name,
          'email': data['email'] ?? ProfileBackend.instance.email,
          'phone': data['phone'] ?? ProfileBackend.instance.phone,
          'avatar_url': data['avatar_url'] ?? ProfileBackend.instance.avatarUrl,
          'is_biometric_enabled': data['is_biometric_enabled'] ?? false,
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
