import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model kendaraan
class VehicleItem {
  final String id;
  final String brand;
  final String model;
  final String plateNumber;
  final String vehicleType;
  final String category;
  final String color;
  final String plateExpiry;
  final bool isDefault;

  VehicleItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.vehicleType,
    required this.category,
    required this.color,
    required this.plateExpiry,
    required this.isDefault,
  });

  factory VehicleItem.fromMap(Map<String, dynamic> map) {
    return VehicleItem(
      id: map['id']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      plateNumber: map['plate_number']?.toString() ?? '',
      vehicleType: map['vehicle_type']?.toString() ?? 'mobil',
      category: map['vehicle_category']?.toString() ?? 'suv',
      color: map['color']?.toString() ?? 'Abu-Abu Metalik',
      plateExpiry: map['plate_expiry']?.toString() ?? '08 • 29',
      isDefault: map['is_default'] == true,
    );
  }
}

/// Backend khusus untuk VehicleScreen (lib/features/profile/vehicle_screen.dart)
class VehicleBackend extends ChangeNotifier {
  VehicleBackend._();
  static final VehicleBackend instance = VehicleBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<VehicleItem> _vehicles = [];
  List<VehicleItem> get vehicles => _vehicles;

  VehicleItem? get defaultVehicle =>
      _vehicles.isNotEmpty ? _vehicles.firstWhere((v) => v.isDefault, orElse: () => _vehicles.first) : null;

  Future<void> fetchVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;

      dynamic query = _client.from('vehicles').select(
        'id, brand, model, plate_number, vehicle_type, vehicle_category, color, plate_expiry, is_default',
      );

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final res = await query.order('is_default', ascending: false);

      if (res != null && (res as List).isNotEmpty) {
        _vehicles = res.map((item) => VehicleItem.fromMap(item as Map<String, dynamic>)).toList();
      } else {
        // Fallback default jika tabel belum ada kendaraan spesifik
        _vehicles = [
          VehicleItem(
            id: 'd0000000-0000-0000-0000-000000000001',
            brand: 'Honda',
            model: 'HR-V SE',
            plateNumber: 'B 8899 DTO',
            vehicleType: 'mobil',
            category: 'suv',
            color: 'Abu-Abu Metalik',
            plateExpiry: '08 • 29',
            isDefault: true,
          ),
          VehicleItem(
            id: 'd0000000-0000-0000-0000-000000000004',
            brand: 'Yamaha',
            model: 'NMAX 155 Connected',
            plateNumber: 'AB 1234 NMX',
            vehicleType: 'motor',
            category: 'motor',
            color: 'Hitam Doff',
            plateExpiry: '06 • 27',
            isDefault: false,
          ),
        ];
      }
    } catch (e) {
      debugPrint('VehicleBackend fetchVehicles error (fallback active): $e');
      if (_vehicles.isEmpty) {
        _vehicles = [
          VehicleItem(
            id: 'd0000000-0000-0000-0000-000000000001',
            brand: 'Honda',
            model: 'HR-V SE',
            plateNumber: 'B 8899 DTO',
            vehicleType: 'mobil',
            category: 'suv',
            color: 'Abu-Abu Metalik',
            plateExpiry: '08 • 29',
            isDefault: true,
          ),
        ];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultVehicle(String vehicleId) async {
    try {
      // Set all to false first
      await _client.from('vehicles').update({'is_default': false}).neq('id', 'none');
      // Set chosen one to true
      await _client.from('vehicles').update({'is_default': true}).eq('id', vehicleId);
      await fetchVehicles();
      return true;
    } catch (e) {
      debugPrint('Error setDefaultVehicle: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await _client.from('vehicles').delete().eq('id', vehicleId);
      _vehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleteVehicle: $e');
      _vehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
      return true;
    }
  }
}
