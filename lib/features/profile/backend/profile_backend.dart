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

    // Simpan ke SharedPreferences agar persist saat restart aplikasi
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user_profile_id', id);
      prefs.setString('user_profile_name', fullName);
      prefs.setString('user_profile_email', email);
      prefs.setString('user_profile_phone', phone);
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
    _saranKuliah = '';
    _pesanKuliah = '';
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
        'id, full_name, email, phone, member_tier, total_parking_count, total_savings, wallet_balance, avatar_url, saran_kuliah, pesan_kuliah',
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
        _saranKuliah = data['saran_kuliah']?.toString() ?? '';
        _pesanKuliah = data['pesan_kuliah']?.toString() ?? '';

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
