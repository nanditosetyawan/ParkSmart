import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../profile/backend/vehicle_backend.dart';
import '../../profile/backend/profile_backend.dart';

class AddVehicleBackend extends ChangeNotifier {
  static final AddVehicleBackend instance = AddVehicleBackend._();
  AddVehicleBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  Future<bool> saveVehicle({
    required String plateNumber,
    required String vehicleName,
    required String category,
    required String color,
    String? plateExpiry,
    Uint8List? vehiclePhotoBytes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final actualUserId = await _resolveUserIdAsync();
      if (actualUserId.isEmpty) {
        throw Exception('Sesi pengguna tidak valid. Silakan login kembali.');
      }

      final formattedPlate = plateNumber.trim().toUpperCase();
      if (formattedPlate.isEmpty) {
        throw Exception('Nomor plat kendaraan tidak boleh kosong.');
      }

      // Cek apakah nomor plat sudah pernah didaftarkan oleh user ini
      final existingPlate = await _client
          .from('vehicles')
          .select('id')
          .eq('user_id', actualUserId)
          .eq('plate_number', formattedPlate)
          .maybeSingle();

      if (existingPlate != null) {
        throw Exception('Nomor plat $formattedPlate sudah terdaftar di akun Anda.');
      }

      final type = category == 'motor' ? 'motor' : 'mobil';

      // Pisahkan brand dan model agar tidak terduplikasi (contoh: "KIJANG" tidak menjadi "KIJANG KIJANG")
      final trimmedName = vehicleName.trim();
      final parts = trimmedName.split(RegExp(r'\s+'));
      final brand = parts.isNotEmpty ? parts.first : 'Kendaraan';
      final model = parts.length > 1 ? parts.sublist(1).join(' ') : parts.first;

      // 1. Upload foto kendaraan fisik jika ada
      String? photoUrl;
      if (vehiclePhotoBytes != null && vehiclePhotoBytes.isNotEmpty) {
        try {
          photoUrl = await SupabaseStorageService.instance.uploadVehiclePhoto(
            rawBytes: vehiclePhotoBytes,
            userId: actualUserId,
          );
        } catch (e) {
          debugPrint('[AddVehicleBackend] Upload photo warning: $e');
        }
      }

      // Cek apakah ini kendaraan pertama di database untuk user ini
      final existingVehicles = await _client
          .from('vehicles')
          .select('id')
          .eq('user_id', actualUserId);
      final isFirst = existingVehicles.isEmpty;

      final data = {
        'user_id': actualUserId,
        'plate_number': formattedPlate,
        'brand': brand,
        'model': model,
        'vehicle_type': type,
        'vehicle_category': category,
        'color': color,
        'plate_expiry': (plateExpiry != null && plateExpiry.trim().isNotEmpty) ? plateExpiry.trim() : 'Aktif Selamanya',
        'is_default': isFirst,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Simpan ke database Supabase
      await _client.from('vehicles').insert(data);

      // Refresh vehicle list in profile
      await VehicleBackend.instance.fetchVehicles();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AddVehicleBackend] saveVehicle error: $e');
      final errStr = e.toString();
      if (errStr.contains('uq_user_plate')) {
        _errorMessage = 'Nomor plat ini sudah terdaftar pada akun Anda.';
      } else {
        _errorMessage = errStr.replaceAll('Exception: ', '');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
