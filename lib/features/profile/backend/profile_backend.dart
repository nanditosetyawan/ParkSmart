import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';

/// Backend khusus untuk ProfileScreen (lib/features/profile/profile_screen.dart)
class ProfileBackend extends ChangeNotifier {
  ProfileBackend._();
  static final ProfileBackend instance = ProfileBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userId = '';
  String get userId => _userId;

  String _name = 'Pengguna Baru';
  String _email = '';
  String _phone = '';
  String? _avatarUrl;
  String _memberTier = 'BRONZE';
  int _totalParking = 0;
  int _totalSavings = 0;
  int _walletBalance = 0;
  int _totalSpent = 0;
  int _monthlySpent = 0;
  String _memberHashCode = '#7b9e-4a81-d02f';
  String _primaryVehicle = 'Belum Ada Kendaraan';

  String _kycStatus = 'none'; // 'none', 'pending', 'approved', 'rejected'
  String get kycStatus => _kycStatus;
  bool get isKycVerified => _kycStatus == 'approved';

  String _saranKuliah = '';
  String get saranKuliah => _saranKuliah;

  String _pesanKuliah = '';
  String get pesanKuliah => _pesanKuliah;

  List<Map<String, dynamic>> _userCards = [];
  List<Map<String, dynamic>> get userCards => _userCards;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String? get avatarUrl => _avatarUrl;
  String get memberTier => _memberTier;
  int get totalParking => _totalParking;
  int get totalSavings => _totalSavings;
  int get walletBalance => _walletBalance;
  int get totalSpent => _totalSpent;
  int get monthlySpent => _monthlySpent;
  String get memberHashCode => _memberHashCode;
  String get primaryVehicle => _primaryVehicle;

  void setLoggedInUser({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    String? avatarUrl,
    String? memberTier,
    int? walletBalance,
    String? memberHashCode,
  }) {
    _userId = id;
    _name = fullName;
    _email = email;
    _phone = phone;
    if (avatarUrl != null) _avatarUrl = avatarUrl;
    if (memberTier != null) _memberTier = memberTier;
    if (walletBalance != null) _walletBalance = walletBalance;
    if (memberHashCode != null && memberHashCode.isNotEmpty) _memberHashCode = memberHashCode;
    notifyListeners();

    // Simpan ke SharedPreferences agar persist saat restart aplikasi
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_profile_id', id);
      prefs.setString('user_profile_name', fullName);
      prefs.setString('user_profile_email', email);
      prefs.setString('user_profile_phone', phone);
      if (memberHashCode != null) prefs.setString('user_member_hash', memberHashCode);
    });
  }

  void clearProfile() {
    _userId = '';
    _name = 'Pengguna Baru';
    _email = '';
    _phone = '';
    _avatarUrl = null;
    _memberTier = 'BRONZE';
    _totalParking = 0;
    _totalSavings = 0;
    _walletBalance = 0;
    _primaryVehicle = 'Belum Ada Kendaraan';
    _kycStatus = 'none';
    _saranKuliah = '';
    _pesanKuliah = '';
    _userCards = [];
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String targetId = _userId.isNotEmpty
          ? _userId
          : (SessionService.instance.userId ?? prefs.getString('user_profile_id') ?? '');
      String targetEmail = _email.isNotEmpty
          ? _email
          : (SessionService.instance.identifier ?? prefs.getString('user_profile_email') ?? '');

      final user = _client.auth.currentUser;
      final authUserId = user?.id;

      dynamic query = _client.from('users').select(
        'id, full_name, email, phone, member_tier, total_parking_count, total_savings, wallet_balance, total_spent, monthly_spent, member_hash_code, avatar_url, saran_kuliah, pesan_kuliah',
      );

      if (authUserId != null) {
        query = query.eq('auth_user_id', authUserId);
      } else if (targetId.isNotEmpty) {
        query = query.eq('id', targetId);
      } else if (targetEmail.isNotEmpty) {
        query = query.eq('email', targetEmail);
      } else {
        // Tidak ada user yang login / tersimpan. Jangan sembarangan ambil baris pertama di DB!
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await query.limit(1);

      if (response != null && (response as List).isNotEmpty) {
        final data = response.first;
        if (data['id'] != null) {
          _userId = data['id'].toString();
        }
        _name = data['full_name'] ?? _name;
        _email = data['email'] ?? _email;
        _phone = data['phone'] ?? _phone;
        _avatarUrl = data['avatar_url']?.toString();
        _memberTier = (data['member_tier'] ?? 'BRONZE').toString().toUpperCase();
        _totalParking = data['total_parking_count'] ?? 0;
        if (data['total_savings'] != null) {
          _totalSavings = (double.tryParse(data['total_savings'].toString()) ?? 0).toInt();
        } else {
          _totalSavings = 0;
        }
        if (data['wallet_balance'] != null) {
          _walletBalance = (double.tryParse(data['wallet_balance'].toString()) ?? 0).toInt();
        } else {
          _walletBalance = 0;
        }
        if (data['total_spent'] != null) {
          _totalSpent = (double.tryParse(data['total_spent'].toString()) ?? 0).toInt();
        } else {
          _totalSpent = 0;
        }
        if (data['monthly_spent'] != null) {
          _monthlySpent = (double.tryParse(data['monthly_spent'].toString()) ?? 0).toInt();
        } else {
          _monthlySpent = 0;
        }
        _memberHashCode = data['member_hash_code']?.toString() ?? '#7b9e-4a81-d02f';
        _saranKuliah = data['saran_kuliah']?.toString() ?? '';
        _pesanKuliah = data['pesan_kuliah']?.toString() ?? '';

        // Auto-Sync Failsafe: Jika total_spent di-inject manual ke database, pastikan tier sesuai
        String expectedTier = 'BRONZE';
        if (_totalSpent >= 500000) {
          expectedTier = 'PLATINUM';
        } else if (_totalSpent >= 200000) {
          expectedTier = 'GOLD';
        } else if (_totalSpent >= 100000) {
          expectedTier = 'SILVER';
        }

        if (_memberTier != expectedTier && _userId.isNotEmpty) {
          _memberTier = expectedTier;
          // Panggil update agar trigger database menerbitkan kartu & hash code blockchain baru
          try {
            await _client.from('users').update({
              'total_spent': _totalSpent,
              'member_tier': expectedTier,
            }).eq('id', _userId);
          } catch (_) {}
        }

        // Ambil kendaraan utama dari tabel vehicles KHUSUS untuk user yang sedang login
        _primaryVehicle = 'Belum Ada Kendaraan';
        try {
          if (_userId.isNotEmpty) {
            final vehicleRes = await _client
                .from('vehicles')
                .select('brand, model, plate_number')
                .eq('user_id', _userId)
                .order('is_default', ascending: false)
                .limit(1);

            if (vehicleRes.isNotEmpty) {
              final v = vehicleRes.first;
              final brand = v['brand'] ?? '';
              final model = v['model'] ?? '';
              final plate = v['plate_number'] ?? '';
              _primaryVehicle = '$brand $model ($plate)'.trim();
            }
          }
        } catch (_) {}

        // Ambil status verifikasi KYC dari tabel user_kyc
        try {
          if (_userId.isNotEmpty) {
            final kycRes = await _client
                .from('user_kyc')
                .select('status, reject_reason')
                .eq('user_id', _userId)
                .maybeSingle();

            if (kycRes != null) {
              _kycStatus = (kycRes['status'] ?? 'pending').toString().toLowerCase();
            } else {
              _kycStatus = 'none';
            }
          }
        } catch (err) {
          debugPrint('[ProfileBackend] Error query user_kyc: $err');
        }

        // Ambil semua koleksi kartu keanggotaan pengguna dari tabel user_member_cards (Hanya kartu yang sudah dicapai)
        try {
          if (_userId.isNotEmpty) {
            final cardsRes = await _client
                .from('user_member_cards')
                .select('id, card_tier, member_hash_code, tx_hash, is_active, unlocked_at')
                .eq('user_id', _userId)
                .order('created_at', ascending: true);

            final allCards = List<Map<String, dynamic>>.from(cardsRes);
            final allowedTiers = <String>{'regular', 'bronze'};
            if (_totalSpent >= 100000 || _memberTier == 'SILVER' || _memberTier == 'GOLD' || _memberTier == 'PLATINUM') {
              allowedTiers.add('silver');
            }
            if (_totalSpent >= 200000 || _memberTier == 'GOLD' || _memberTier == 'PLATINUM') {
              allowedTiers.add('gold');
            }
            if (_totalSpent >= 500000 || _memberTier == 'PLATINUM') {
              allowedTiers.add('platinum');
            }
            _userCards = allCards.where((c) => allowedTiers.contains((c['card_tier'] ?? '').toString().toLowerCase())).toList();
          }
        } catch (err) {
          debugPrint('[ProfileBackend] Error query user_member_cards: $err');
        }
      }
    } catch (e) {
      debugPrint('ProfileBackend fetchProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyimpan saran & pesan perkuliahan Pemrograman Aplikasi Mobile ke Supabase
  Future<bool> saveKuliahFeedback({
    required String saran,
    required String pesan,
  }) async {
    if (_userId.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final s = saran.trim();
      final p = pesan.trim();

      await _client.from('users').update({
        'saran_kuliah': s,
        'pesan_kuliah': p,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', _userId);

      _saranKuliah = s;
      _pesanKuliah = p;
      return true;
    } catch (e) {
      debugPrint('[ProfileBackend] saveKuliahFeedback error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
