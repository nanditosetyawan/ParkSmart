import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ProfileScreen (lib/features/profile/profile_screen.dart)
class ProfileBackend extends ChangeNotifier {
  ProfileBackend._();
  static final ProfileBackend instance = ProfileBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userId = 'c0000000-0000-0000-0000-000000000001';
  String get userId => _userId;

  String _name = 'Jokowi Dodo';
  String _email = 'jokowi.dodo@gmail.com';
  String _phone = '+62 812-3456-7890';
  String _memberTier = 'MEMBER';
  int _totalParking = 0;
  int _totalSavings = 0;
  int _walletBalance = 0;
  String _primaryVehicle = 'Belum Ada Kendaraan';

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get memberTier => _memberTier;
  int get totalParking => _totalParking;
  int get totalSavings => _totalSavings;
  int get walletBalance => _walletBalance;
  String get primaryVehicle => _primaryVehicle;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _client.auth.currentUser;
      final authUserId = user?.id;

      // Ambil data user dari tabel users
      dynamic query = _client.from('users').select(
        'id, full_name, email, phone, member_tier, total_parking_count, total_savings, wallet_balance',
      );

      if (authUserId != null) {
        query = query.eq('auth_user_id', authUserId);
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
        _memberTier = (data['member_tier'] ?? _memberTier).toString().toUpperCase();
        _totalParking = data['total_parking_count'] ?? _totalParking;
        if (data['total_savings'] != null) {
          _totalSavings = (double.tryParse(data['total_savings'].toString()) ?? 124000).toInt();
        }
        if (data['wallet_balance'] != null) {
          _walletBalance = (double.tryParse(data['wallet_balance'].toString()) ?? 250000).toInt();
        }

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
}
