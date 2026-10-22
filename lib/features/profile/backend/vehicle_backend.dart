import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import 'profile_backend.dart';

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
  final String? photoUrl;
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
    this.photoUrl,
    required this.isDefault,
  });

  /// Nama kendaraan yang bersih dan tidak terduplikasi (contoh: 'KIJANG' bukan 'KIJANG KIJANG')
  String get displayName {
    final b = brand.trim();
    final m = model.trim();
    if (b.isEmpty) return m.isNotEmpty ? m : 'Kendaraan';
    if (m.isEmpty) return b;
    if (m.toLowerCase() == b.toLowerCase()) return b;
    if (m.toLowerCase().startsWith(b.toLowerCase())) return m;
    return '$b $m';
  }

  factory VehicleItem.fromMap(Map<String, dynamic> map) {
    return VehicleItem(
      id: map['id']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      plateNumber: map['plate_number']?.toString() ?? '',
      vehicleType: map['vehicle_type']?.toString() ?? 'mobil',
      category: map['vehicle_category']?.toString() ?? 'suv',
      color: map['color']?.toString() ?? 'Abu-Abu Metalik',
      plateExpiry: map['plate_expiry']?.toString() ?? 'Aktif Selamanya',
      photoUrl: map['photo_url']?.toString(),
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

  void clearVehicles() {
    _vehicles = [];
    notifyListeners();
  }

  Future<String> _resolveUserIdAsync() async {
    final sessionUid = SessionService.instance.userId;
    if (sessionUid != null && sessionUid.trim().isNotEmpty) {
      return sessionUid.trim();
    }

    final profileUid = ProfileBackend.instance.userId;
    if (profileUid.trim().isNotEmpty) {
      return profileUid.trim();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('ps_session_user_id') ?? prefs.getString('user_profile_id');
      if (savedId != null && savedId.trim().isNotEmpty) {
        return savedId.trim();
      }
    } catch (_) {}

    final authUser = _client.auth.currentUser;
    if (authUser != null) {
      try {
        final row = await _client.from('users').select('id').eq('auth_user_id', authUser.id).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }

    final email = SessionService.instance.identifier ?? ProfileBackend.instance.email;
    if (email.trim().isNotEmpty) {
      try {
        final row = await _client.from('users').select('id').eq('email', email.trim()).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }

    return '';
  }

  Future<void> fetchVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _resolveUserIdAsync();

      if (userId.isEmpty) {
        _vehicles = [];
        return;
      }

      final res = await _client
          .from('vehicles')
          .select('id, brand, model, plate_number, vehicle_type, vehicle_category, color, plate_expiry, photo_url, is_default')
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      if (res.isNotEmpty) {
        _vehicles = res.map((item) => VehicleItem.fromMap(item)).toList();
      } else {
        _vehicles = [];
      }
    } catch (e) {
      debugPrint('VehicleBackend fetchVehicles error: $e');
      _vehicles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultVehicle(String vehicleId) async {
    try {
      final userId = await _resolveUserIdAsync();
      if (userId.isEmpty) return false;

      // Set all user's vehicles to false first
      await _client.from('vehicles').update({'is_default': false}).eq('user_id', userId);
      // Set chosen one to true
      await _client.from('vehicles').update({'is_default': true}).eq('id', vehicleId).eq('user_id', userId);
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

  /// Update photo_url kendaraan di database dan refresh list
  Future<bool> updateVehiclePhoto(String vehicleId, String photoUrl) async {
    try {
      await _client
          .from('vehicles')
          .update({'photo_url': photoUrl, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', vehicleId);
      // Update lokal juga agar UI langsung refresh
      _vehicles = _vehicles.map((v) {
        if (v.id == vehicleId) {
          return VehicleItem(
            id: v.id,
            brand: v.brand,
            model: v.model,
            plateNumber: v.plateNumber,
            vehicleType: v.vehicleType,
            category: v.category,
            color: v.color,
            plateExpiry: v.plateExpiry,
            photoUrl: photoUrl,
            isDefault: v.isDefault,
          );
        }
        return v;
      }).toList();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updateVehiclePhoto: $e');
      return false;
    }
  }
}
