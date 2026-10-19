import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ArcadeAdminScreen (admin_arcade_screen.dart)
/// Mengatur akses permainan arcade dan skor permainan
/// Terkoneksi ke `public.system_settings` dan `public.arcade_scores` di Supabase
class AdminArcadeBackend extends ChangeNotifier {
  AdminArcadeBackend._();
  static final AdminArcadeBackend instance = AdminArcadeBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isParkingGameActive = true;
  bool get isParkingGameActive => _isParkingGameActive;

  bool _isClawsGameActive = true;
  bool get isClawsGameActive => _isClawsGameActive;

  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  /// Memuat pengaturan arcade dari SharedPreferences dan Supabase
  Future<void> loadArcadeSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isParkingGameActive = prefs.getBool('arcade_parking_active') ?? true;
      _isClawsGameActive = prefs.getBool('arcade_claws_active') ?? true;

      // Ambil dari Supabase system_settings
      final res = await _client
          .from('system_settings')
          .select('value')
          .eq('key', 'feature_toggles')
          .maybeSingle();

      if (res != null && res['value'] is Map) {
        final val = res['value'] as Map<String, dynamic>;
        if (val['is_arcade_active'] != null) {
          _isParkingGameActive = val['is_arcade_active'] == true;
        }
      }

      // Ambil skor teratas dari arcade_scores
      final scores = await _client
          .from('arcade_scores')
          .select('id, user_id, game_name, score, points_earned, played_at')
          .order('score', ascending: false)
          .limit(10);

      if (scores.isNotEmpty) {
        _leaderboard = scores.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[AdminArcadeBackend] loadArcadeSettings error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyimpan status keaktifan game arcade
  Future<bool> saveArcadeSettings({
    required bool isParkingActive,
    required bool isClawsActive,
  }) async {
    _isParkingGameActive = isParkingActive;
    _isClawsGameActive = isClawsActive;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('arcade_parking_active', isParkingActive);
      await prefs.setBool('arcade_claws_active', isClawsActive);

      // Simpan ke Supabase system_settings
      await _client.from('system_settings').upsert({
        'key': 'arcade_config',
        'value': {
          'is_parking_game_active': isParkingActive,
          'is_claws_game_active': isClawsActive,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'description': 'Pengaturan aksesibilitas mini-game arcade & hadiah poin',
      });
      return true;
    } catch (e) {
      debugPrint('[AdminArcadeBackend] saveArcadeSettings error: $e');
      return false;
    }
  }
}
