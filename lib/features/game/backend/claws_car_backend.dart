import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk ClawsCarScreen (Game Mesin Capit Mobil)
/// Menangani pencatatan skor game capit mobil ke tabel `public.arcade_scores`.
/// Menerapkan aturan overwriting:
/// - Tepat 1 baris untuk rekor tertinggi ('highest')
/// - Tepat 1 baris untuk skor sesi saat ini ('current') yang selalu ditimpa
/// - Menambah poin reward ke akun pengguna di tabel `public.users`.
class ClawsCarBackend extends ChangeNotifier {
  ClawsCarBackend._();
  static final ClawsCarBackend instance = ClawsCarBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  int _highestScore = 0;
  int get highestScore => _highestScore;

  int _currentScore = 0;
  int get currentScore => _currentScore;

  static const String gameName = 'claw_crane';

  /// Memuat skor tertinggi dan skor terakhir pengguna
  Future<void> loadUserScores({String? userId}) async {
    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid == null) return;

      final scores = await _client
          .from('arcade_scores')
          .select('score, score_type')
          .eq('user_id', uid)
          .eq('game_name', gameName);

      for (final s in scores) {
        final type = s['score_type']?.toString();
        final sc = (s['score'] as num?)?.toInt() ?? 0;
        if (type == 'highest') {
          _highestScore = sc;
        } else if (type == 'current') {
          _currentScore = sc;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[ClawsCarBackend] Load score error: $e');
    }
  }

  /// Menyimpan skor capit mobil saat permainan selesai
  Future<void> saveGameResult({
    required int score,
    required int pointsEarned,
    String? userId,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid == null) {
        _currentScore = score;
        if (score > _highestScore) _highestScore = score;
        return;
      }

      final now = DateTime.now().toIso8601String();

      // 1. Timpa skor saat ini (score_type = 'current')
      await _client.from('arcade_scores').upsert(
        {
          'user_id': uid,
          'game_name': gameName,
          'score': score,
          'points_earned': pointsEarned,
          'score_type': 'current',
          'played_at': now,
        },
        onConflict: 'user_id,game_name,score_type',
      );
      _currentScore = score;

      // 2. Cek dan update skor tertinggi (score_type = 'highest') jika rekor baru
      if (score > _highestScore) {
        await _client.from('arcade_scores').upsert(
          {
            'user_id': uid,
            'game_name': gameName,
            'score': score,
            'points_earned': pointsEarned,
            'score_type': 'highest',
            'played_at': now,
          },
          onConflict: 'user_id,game_name,score_type',
        );
        _highestScore = score;
      }

      // 3. Tambahkan poin ke profil user
      if (pointsEarned > 0) {
        final user = await _client.from('users').select('points').eq('id', uid).maybeSingle();
        final currentPoints = (user?['points'] as num?)?.toInt() ?? 0;
        await _client.from('users').update({
          'points': currentPoints + pointsEarned,
          'updated_at': now,
        }).eq('id', uid);

        await DatabaseCacheBalancerService.instance.invalidatePrefix('user_');
      }

      debugPrint('[ClawsCarBackend] Sukses simpan skor Claw Crane: $score');
    } catch (e) {
      debugPrint('[ClawsCarBackend] Error saveGameResult: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Menukar poin ke koin capit (Claw Crane) dan mengurangi saldo poin di tabel users
  Future<void> exchangePointsForCoins({
    required int pointsToDeduct,
    required int coinsToAdd,
  }) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;

      final user = await _client.from('users').select('points').eq('id', uid).maybeSingle();
      final currentPoints = (user?['points'] as num?)?.toInt() ?? 0;
      final newPoints = (currentPoints - pointsToDeduct).clamp(0, 999999999);

      await _client.from('users').update({
        'points': newPoints,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);

      await DatabaseCacheBalancerService.instance.invalidatePrefix('user_');
      debugPrint('[ClawsCarBackend] Berhasil konversi: -$pointsToDeduct poin, +$coinsToAdd koin capit. Sisa poin: $newPoints');
    } catch (e) {
      debugPrint('[ClawsCarBackend] Error exchangePointsForCoins: $e');
    }
  }
}
