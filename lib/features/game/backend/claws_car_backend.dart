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

  static const String gameName = 'claw_crane';

  /// Memuat skor tertinggi, skor sesi terakhir, dan saldo poin pengguna dari Supabase
  Future<void> loadUserScores({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highestScore = prefs.getInt('claws_car_high_score') ?? 0;
      _userPoints = prefs.getInt('user_arcade_points') ?? 25000;

      final uid = await GameUserHelper.resolveUserId(userId);
      if (uid == null) {
        notifyListeners();
        return;
      }

      // 1. Ambil skor dari Supabase arcade_scores
      final scores = await _client
          .from('arcade_scores')
          .select('score, score_type')
          .eq('user_id', uid)
          .eq('game_name', gameName);

      for (final s in scores) {
        final type = s['score_type']?.toString();
        final sc = (s['score'] as num?)?.toInt() ?? 0;
        if (type == 'highest') {
          if (sc > _highestScore) _highestScore = sc;
        } else if (type == 'current') {
          _currentScore = sc;
        }
      }

      // 2. Ambil poin dari Supabase users
      final user = await _client.from('users').select('points').eq('id', uid).maybeSingle();
      if (user != null && user['points'] != null) {
        _userPoints = (user['points'] as num).toInt();
        await prefs.setInt('user_arcade_points', _userPoints);
      }
      await prefs.setInt('claws_car_high_score', _highestScore);

      notifyListeners();
      debugPrint('[ClawsCarBackend] Loaded scores for user $uid: High=$_highestScore, Pts=$_userPoints');
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
      final prefs = await SharedPreferences.getInstance();
      _currentScore = score;
      if (score > _highestScore) {
        _highestScore = score;
      }
      await prefs.setInt('claws_car_high_score', _highestScore);

      final uid = await GameUserHelper.resolveUserId(userId);
      if (uid == null) {
        if (pointsEarned > 0) {
          _userPoints += pointsEarned;
          await prefs.setInt('user_arcade_points', _userPoints);
        }
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
        await prefs.setInt('user_arcade_points', newPoints);
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

  /// Menukar poin ke koin capit (Claw Crane) dan mengurangi saldo poin di tabel users
  Future<void> exchangePointsForCoins({
    required int pointsToDeduct,
    required int coinsToAdd,
    String? userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCoins = prefs.getInt('claws_car_coins') ?? 5;
      await prefs.setInt('claws_car_coins', currentCoins + coinsToAdd);

      final uid = await GameUserHelper.resolveUserId(userId);
      if (uid == null) {
        _userPoints = (_userPoints - pointsToDeduct).clamp(0, 999999999);
        await prefs.setInt('user_arcade_points', _userPoints);
        return;
      }

      final user = await _client.from('users').select('points').eq('id', uid).maybeSingle();
      final currentPoints = (user?['points'] as num?)?.toInt() ?? 0;
      final newPoints = (currentPoints - pointsToDeduct).clamp(0, 999999999);

      await _client.from('users').update({
        'points': newPoints,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uid);

      _userPoints = newPoints;
      await prefs.setInt('user_arcade_points', newPoints);
      await DatabaseCacheBalancerService.instance.invalidatePrefix('user_');

      debugPrint('[ClawsCarBackend] Berhasil konversi DB: -$pointsToDeduct poin, +$coinsToAdd koin capit. Sisa poin: $newPoints');
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

        // 4. Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
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
