import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ProfileScreen (lib/features/profile/profile_screen.dart)
class ProfileBackend extends ChangeNotifier {
  ProfileBackend._();
  static final ProfileBackend instance = ProfileBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userId = 'e2b8c4d1-7a3f-4e92-8d15-9c64712035ba';
  String get userId => _userId;

  String _name = 'Jokowi Dodo';
  String _email = 'jokowi.dodo@gmail.com';
  String _phone = '+62 811-2345-6789';
  String? _avatarUrl;
  String _memberTier = 'MEMBER';
  int _totalParking = 0;
  int _totalSavings = 0;
  int _walletBalance = 0;
  String _primaryVehicle = 'Belum Ada Kendaraan';

  String _saranKuliah = '';
  String get saranKuliah => _saranKuliah;

  String _pesanKuliah = '';
  String get pesanKuliah => _pesanKuliah;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String? get avatarUrl => _avatarUrl;
  String get memberTier => _memberTier;
  int get totalParking => _totalParking;
  int get totalSavings => _totalSavings;
  int get walletBalance => _walletBalance;
  String get primaryVehicle => _primaryVehicle;

  void setLoggedInUser({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    String? avatarUrl,
    String? memberTier,
    int? walletBalance,
  }) {
    _userId = id;
    _name = fullName;
    _email = email;
    _phone = phone;
    if (avatarUrl != null) _avatarUrl = avatarUrl;
    if (memberTier != null) _memberTier = memberTier;
    if (walletBalance != null) _walletBalance = walletBalance;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _client.auth.currentUser;
      final authUserId = user?.id;

      // Ambil data user dari tabel users
      dynamic query = _client.from('users').select(
        'id, full_name, email, phone, member_tier, total_parking_count, total_savings, wallet_balance, avatar_url, saran_kuliah, pesan_kuliah',
      );

      if (authUserId != null) {
        query = query.eq('auth_user_id', authUserId);
      } else if (_userId.isNotEmpty) {
        query = query.eq('id', _userId);
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
        _memberTier = (data['member_tier'] ?? _memberTier).toString().toUpperCase();
        _totalParking = data['total_parking_count'] ?? _totalParking;
        if (data['total_savings'] != null) {
          _totalSavings = (double.tryParse(data['total_savings'].toString()) ?? 124000).toInt();
        }
        if (data['wallet_balance'] != null) {
          _walletBalance = (double.tryParse(data['wallet_balance'].toString()) ?? 250000).toInt();
        }
        _saranKuliah = data['saran_kuliah']?.toString() ?? '';
        _pesanKuliah = data['pesan_kuliah']?.toString() ?? '';

        // Ambil kendaraan utama dari tabel vehicles
        try {
          final vehicleRes = await _client
              .from('vehicles')
              .select('brand, model, plate_number')
              .eq('is_default', true)
              .limit(1);

          if (vehicleRes.isNotEmpty) {
            final v = vehicleRes.first;
            final brand = v['brand'] ?? '';
            final model = v['model'] ?? '';
            final plate = v['plate_number'] ?? '';
            _primaryVehicle = '$brand $model ($plate)'.trim();
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('ProfileBackend fetchProfile error (using fallback): $e');
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
