import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';
import '../../profile/backend/payment_methods_backend.dart';
import '../../profile/backend/profile_backend.dart';
import 'game_user_helper.dart';

/// Backend khusus untuk ClawsCarScreen (Game Mesin Capit Mobil)
/// Menangani pencatatan skor game capit mobil ke tabel `public.arcade_scores`.
/// Menerapkan aturan overwriting:
/// - Tepat 1 baris untuk rekor tertinggi ('highest')
/// - Tepat 1 baris untuk skor sesi saat ini ('current') yang selalu ditimpa
/// - Menambah poin reward ke akun pengguna di tabel `public.users`.
/// - Menangani penukaran Poin -> Koin Capit di database Supabase.
/// - Menangani injeksi hadiah koin/uang tunai langsung ke saldo akun pengguna.
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

  int _userPoints = 0;
  int get userPoints => _userPoints;

  int _clawCoins = 5;
  int get clawCoins => _clawCoins;

  static const String gameName = 'claw_crane';

  /// Memuat skor tertinggi, skor sesi terakhir, dan saldo poin pengguna dari Supabase
  Future<void> loadUserScores({String? userId}) async {
    try {
      final uid = await GameUserHelper.resolveUserId(userId);
      final prefs = await SharedPreferences.getInstance();

      if (uid == null) {
        _highestScore = 0;
        _userPoints = 0;
        _clawCoins = 5;
        _currentScore = 0;
        notifyListeners();
        return;
      }

      final highKey = 'claws_car_high_score_$uid';
      final pointsKey = 'user_arcade_points_$uid';
      final coinsKey = 'claws_car_coins_$uid';

      _highestScore = prefs.getInt(highKey) ?? 0;
      _userPoints = prefs.getInt(pointsKey) ?? 0;
      _clawCoins = prefs.getInt(coinsKey) ?? 5;

      // 1. Ambil skor dari Supabase arcade_scores
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

      // 2. Ambil poin dan koin capit dari Supabase users
      final user = await _client.from('users').select('points, claw_coins').eq('id', uid).maybeSingle();
      if (user != null) {
        if (user['points'] != null) {
          _userPoints = (user['points'] as num).toInt();
          await prefs.setInt(pointsKey, _userPoints);
        }
        if (user['claw_coins'] != null) {
          _clawCoins = (user['claw_coins'] as num).toInt();
          await prefs.setInt(coinsKey, _clawCoins);
        }
      }
      await prefs.setInt(highKey, _highestScore);

      notifyListeners();
      debugPrint('[ClawsCarBackend] Loaded scores for user $uid: High=$_highestScore, Pts=$_userPoints, Coins=$_clawCoins');
    } catch (e) {
      debugPrint('[ClawsCarBackend] Load score error: $e');
    }
  }

  /// Menyimpan skor capit mobil saat permainan selesai dan menambahkan poin reward ke tabel `users`
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
        if (pointsEarned > 0) {
          _userPoints += pointsEarned;
        }
        return;
      }

      final highKey = 'claws_car_high_score_$uid';
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

      // 2. Cek dan update skor tertinggi (score_type = 'highest') jika rekor baru
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

      // 3. Tambahkan poin ke profil user
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

      debugPrint('[ClawsCarBackend] Sukses simpan skor Claw Crane ke DB: $score, Pts: $_userPoints');
    } catch (e) {
      debugPrint('[ClawsCarBackend] Error saveGameResult: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Reset state memori saat logout / pergantian user
  void clear() {
    _highestScore = 0;
    _currentScore = 0;
    _clawCoins = 5;
    _userPoints = 0;
    notifyListeners();
  }

  /// Mengurangi koin capit saat memainkan mesin dan sinkron ke tabel users
  Future<void> consumeCoin({String? userId}) async {
    try {
      final uid = await GameUserHelper.resolveUserId(userId);
      final coinsKey = uid != null ? 'claws_car_coins_$uid' : 'claws_car_coins';
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = prefs.getInt(coinsKey) ?? _clawCoins;
      final newCoins = (currentCoins - 1).clamp(0, 999999);
      _clawCoins = newCoins;
      await prefs.setInt(coinsKey, newCoins);

      if (uid != null) {
        await _client.from('users').update({
          'claw_coins': newCoins,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', uid);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[ClawsCarBackend] Error consumeCoin: $e');
    }
  }

  /// Menukar poin ke koin capit (Claw Crane) dan mengurangi saldo poin serta menambah koin di tabel users
  Future<void> exchangePointsForCoins({
    required int pointsToDeduct,
    required int coinsToAdd,
    String? userId,
  }) async {
    try {
      final uid = await GameUserHelper.resolveUserId(userId);
      final coinsKey = uid != null ? 'claws_car_coins_$uid' : 'claws_car_coins';
      final pointsKey = uid != null ? 'user_arcade_points_$uid' : 'user_arcade_points';
      final prefs = await SharedPreferences.getInstance();

      final currentCoins = prefs.getInt(coinsKey) ?? _clawCoins;
      final newCoins = currentCoins + coinsToAdd;
      _clawCoins = newCoins;
      await prefs.setInt(coinsKey, newCoins);

      if (uid == null) {
        _userPoints = (_userPoints - pointsToDeduct).clamp(0, 999999999);
        await prefs.setInt(pointsKey, _userPoints);
        notifyListeners();
        return;
      }

      final user = await _client.from('users').select('points, claw_coins').eq('id', uid).maybeSingle();
      final currentPoints = (user?['points'] as num?)?.toInt() ?? 0;
      final newPoints = (currentPoints - pointsToDeduct).clamp(0, 999999999);

      await _client.from('users').update({
        'points': newPoints,
        'claw_coins': newCoins,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);

      _userPoints = newPoints;
      await prefs.setInt(pointsKey, newPoints);
      await DatabaseCacheBalancerService.instance.invalidatePrefix('user_');
      notifyListeners();

      debugPrint('[ClawsCarBackend] Berhasil konversi DB: -$pointsToDeduct poin, +$coinsToAdd koin capit. Sisa poin: $newPoints, Koin: $newCoins');
    } catch (e) {
      debugPrint('[ClawsCarBackend] Error exchangePointsForCoins: $e');
    }
  }

  /// Menginjeksi hadiah uang tunai langsung ke saldo akun pengguna di Supabase
  Future<int?> injectPrizeMoney({required int amount, String? userId}) async {
    try {
      final uid = await GameUserHelper.resolveUserId(userId);

      if (uid != null && uid.isNotEmpty) {
        // 1. Ambil saldo saat ini dari database
        final userRow = await _client.from('users').select('wallet_balance').eq('id', uid).maybeSingle();
        final currentBalance = (userRow?['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        final newBalance = currentBalance + amount;

        // 2. Update saldo di tabel users
        await _client.from('users').update({
          'wallet_balance': newBalance,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', uid);

        // 3. Catat transaksi di tabel payments
        final txnCode = 'CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        await _client.from('payments').insert({
          'transaction_code': txnCode,
          'user_id': uid,
          'transaction_type': 'wallet_topup',
          'payment_method': 'wallet',
          'amount': amount,
          'description': 'Hadiah Koin Mesin Capit Claws Car (Rp $amount)',
          'status': 'success',
          'completed_at': DateTime.now().toIso8601String(),
        });

        // 4. Update SharedPreferences per user
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_wallet_balance_$uid', newBalance.toInt());
        await prefs.setInt('user_wallet_balance', newBalance.toInt());

        // 5. Invalidate cache dan perbarui backend
        await DatabaseCacheBalancerService.instance.invalidatePrefix('user_');
        PaymentMethodsBackend.instance.fetchBalance();
        ProfileBackend.instance.fetchProfile();

        debugPrint('[ClawsCarBackend] Berhasil inject Rp $amount ke user $uid. Saldo baru: Rp $newBalance');
        return newBalance.toInt();
      }
    } catch (e) {
      debugPrint('[ClawsCarBackend] Error injectPrizeMoney: $e');
    }
    return null;
  }
}
