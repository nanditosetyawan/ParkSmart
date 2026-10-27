import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';
import 'game_user_helper.dart';

/// Backend khusus untuk CarGameScreen (Game Balapan & Parkir Mobil)
/// Menangani sinkronisasi skor dan reward poin ke database Supabase:
/// - Tabel `public.arcade_scores`:
///   * 1 baris untuk rekor tertinggi ('highest')
///   * 1 baris untuk skor sesi saat ini ('current') yang selalu ditimpa
/// - Tabel `public.users`:
///   * Kolom `points` bertambah sesuai skor yang diperoleh pengguna
class CarGameBackend extends ChangeNotifier {
  CarGameBackend._();
  static final CarGameBackend instance = CarGameBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  int _highestScore = 0;
  int get highestScore => _highestScore;

  int _currentScore = 0;
  int get currentScore => _currentScore;

  int _userPoints = 0;
  int get userPoints => _userPoints;

  static const String gameName = 'car_racing';

  /// Memuat skor tertinggi, skor sesi terakhir, dan total poin pengguna dari Supabase
  Future<void> loadUserScores({String? userId}) async {
    try {
      final uid = await GameUserHelper.resolveUserId(userId);
      final prefs = await SharedPreferences.getInstance();

      if (uid == null) {
        _highestScore = 0;
        _userPoints = 0;
        _currentScore = 0;
        notifyListeners();
        return;
      }

      final highKey = 'parking_high_score_$uid';
      final pointsKey = 'user_arcade_points_$uid';

      _highestScore = prefs.getInt(highKey) ?? 0;
      _userPoints = prefs.getInt(pointsKey) ?? 0;

      // 1. Ambil skor dari Supabase arcade_scores milik user ini
      final scores = await _client
          .from('arcade_scores')
          .select('score, score_type')
          .eq('user_id', uid)
          .eq('game_name', gameName);

      int dbHighest = 0;
      for (final s in scores) {
        final type = s['score_type']?.toString();
        final sc = (s['score'] as num?)?.toInt() ?? 0;
        if (type == 'highest') {
          if (sc > dbHighest) dbHighest = sc;
        } else if (type == 'current') {
          _currentScore = sc;
        }
      }
      _highestScore = dbHighest > _highestScore ? dbHighest : _highestScore;

      // 2. Ambil poin pengguna dari Supabase users
      final user = await _client.from('users').select('points').eq('id', uid).maybeSingle();
      if (user != null && user['points'] != null) {
        _userPoints = (user['points'] as num).toInt();
        await prefs.setInt(pointsKey, _userPoints);
      }
      await prefs.setInt(highKey, _highestScore);

      notifyListeners();
      debugPrint('[CarGameBackend] Loaded scores for user $uid: High=$_highestScore, Pts=$_userPoints');
    } catch (e) {
      debugPrint('[CarGameBackend] Load score error: $e');
    }
  }

  /// Menyimpan skor game parkir mobil dan menambahkan poin reward ke tabel `users`
  /// Menggunakan logika UPSERT (maksimal 2 baris per game: 'highest' & 'current').
  Future<void> saveGameResult({
    required int score,
    required int pointsEarned,
    String? userId,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final uid = await GameUserHelper.resolveUserId(userId);
      final prefs = await SharedPreferences.getInstance();
      _currentScore = score;
      if (score > _highestScore) {
        _highestScore = score;
      }

      if (uid == null) {
        // Mode offline / dev guest
        if (pointsEarned > 0) {
          _userPoints += pointsEarned;
        }
        return;
      }

      final highKey = 'parking_high_score_$uid';
      final pointsKey = 'user_arcade_points_$uid';
      await prefs.setInt(highKey, _highestScore);

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

      // 2. Cek dan perbarui skor tertinggi (score_type = 'highest') jika melampaui rekor
      if (score >= _highestScore) {
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
      }

      // 3. Tambahkan poin reward ke akun pengguna di tabel `public.users`
      if (pointsEarned > 0) {
        final user = await _client.from('users').select('points').eq('id', uid).maybeSingle();
        final currentPoints = (user?['points'] as num?)?.toInt() ?? 0;
        final newPoints = currentPoints + pointsEarned;

        await _client.from('users').update({
          'points': newPoints,
          'updated_at': now,
        }).eq('id', uid);

        _userPoints = newPoints;
        await prefs.setInt(pointsKey, newPoints);
        await DatabaseCacheBalancerService.instance.invalidatePrefix('user_');
      }

      debugPrint('[CarGameBackend] Sukses simpan skor Car Game ke DB: $score, Pts Earned: $pointsEarned, Total Pts: $_userPoints');
    } catch (e) {
      debugPrint('[CarGameBackend] Error saveGameResult: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Reset memory state saat logout / ganti akun
  void clear() {
    _highestScore = 0;
    _currentScore = 0;
    _userPoints = 0;
    notifyListeners();
  }
}
