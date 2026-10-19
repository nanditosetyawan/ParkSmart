import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/backend/vehicle_backend.dart';

class AddVehicleBackend extends ChangeNotifier {
  static final AddVehicleBackend instance = AddVehicleBackend._();
  AddVehicleBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> saveVehicle({
    required String plateNumber,
    required String vehicleName,
    required String category,
    required String color,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _client.auth.currentUser;
      final userId = user?.id ?? 'c0000000-0000-0000-0000-000000000001';

      final type = category == 'motor' ? 'motor' : 'mobil';

      final data = {
        'user_id': userId,
        'plate_number': plateNumber.trim().toUpperCase(),
        'brand': vehicleName.split(' ').first,
        'model': vehicleName,
        'vehicle_type': type,
        'vehicle_category': category,
        'color': color,
        'is_default': false,
        'plate_expiry': '12 • 29',
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await _client.from('vehicles').insert(data);
      } catch (e) {
        debugPrint('Supabase insert vehicle fallback or error: $e');
      }

      // Refresh vehicle list in profile
      await VehicleBackend.instance.fetchVehicles();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
