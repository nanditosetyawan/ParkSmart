import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk GameListScreen
/// Menampilkan daftar game arcade yang aktif, status poin pengguna, dan papan peringkat.
class GameListBackend extends ChangeNotifier {
  GameListBackend._();
  static final GameListBackend instance = GameListBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _userPoints = 0;
  int get userPoints => _userPoints;

  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> get leaderboard => _leaderboard;

  /// Memuat profil poin pengguna dan high score dari `arcade_scores`
  Future<void> fetchGameOverview({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;

      // 1. Ambil poin pengguna
      if (uid != null) {
        final u = await _client.from('users').select('points').eq('id', uid).maybeSingle();
        _userPoints = (u?['points'] as num?)?.toInt() ?? 0;
      }

      // 2. Ambil papan skor tertinggi (score_type = 'highest')
      final lb = await DatabaseCacheBalancerService.instance.getBalanced<List<Map<String, dynamic>>>(
        queryKey: 'arcade_leaderboard',
        ttl: const Duration(minutes: 5),
        queryFn: () async {
          final res = await _client
              .from('arcade_scores')
              .select('game_name, score, played_at, users(full_name, avatar_url)')
              .eq('score_type', 'highest')
              .order('score', ascending: false)
              .limit(10);
          return List<Map<String, dynamic>>.from(res);
        },
      );
      _leaderboard = lb;
    } catch (e) {
      debugPrint('[GameListBackend] Error fetch overview: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
