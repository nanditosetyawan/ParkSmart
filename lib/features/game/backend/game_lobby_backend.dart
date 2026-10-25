import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';
import 'game_user_helper.dart';

/// Backend khusus untuk GameLobbyScreen
/// Menampilkan statistik arcade dan status reward pengguna sebelum masuk ke game
class GameLobbyBackend extends ChangeNotifier {
  GameLobbyBackend._();
  static final GameLobbyBackend instance = GameLobbyBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _userPoints = 0;
  int get userPoints => _userPoints;

  int _highestRacing = 0;
  int _highestClaw = 0;

  int get highestRacing => _highestRacing;
  int get highestClaw => _highestClaw;

  /// Memuat statistik lobby arcade
  Future<void> fetchLobbyStats({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = await GameUserHelper.resolveUserId(userId);
      if (uid == null) return;

      final res = await DatabaseCacheBalancerService.instance.getBalanced<Map<String, dynamic>>(
        queryKey: 'arcade_lobby_$uid',
        ttl: const Duration(minutes: 3),
        queryFn: () async {
          final user = await _client.from('users').select('points').eq('id', uid).maybeSingle();
          final scores = await _client
              .from('arcade_scores')
              .select('game_name, score, score_type')
              .eq('user_id', uid)
              .eq('score_type', 'highest');

          return {
            'points': (user?['points'] as num?)?.toInt() ?? 0,
            'scores': scores,
          };
        },
      );

      _userPoints = res['points'] as int;
      final scoresList = res['scores'] as List;
      for (final s in scoresList) {
        final g = s['game_name']?.toString();
        final sc = (s['score'] as num?)?.toInt() ?? 0;
        if (g == 'car_racing') _highestRacing = sc;
        if (g == 'claw_crane') _highestClaw = sc;
      }
    } catch (e) {
      debugPrint('[GameLobbyBackend] Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
