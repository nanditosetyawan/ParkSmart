import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_storage_service.dart';

/// Backend khusus untuk CustomCameraScreen
/// Menangani pengambilan/pemindaian foto plat nomor dan STNK kendaraan,
/// melakukan kompresi brutal ~95%, dan menyimpan ke storage/database.
class CustomCameraBackend extends ChangeNotifier {
  CustomCameraBackend._();
  static final CustomCameraBackend instance = CustomCameraBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _platImageUrl;
  String? get platImageUrl => _platImageUrl;

  String? _stnkImageUrl;
  String? get stnkImageUrl => _stnkImageUrl;

  /// Upload foto plat nomor kendaraan
  Future<bool> uploadPlatImage({
    required Uint8List bytes,
    String? userId,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id ?? 'vehicle_guest';
      final url = await SupabaseStorageService.instance.uploadVehicleImage(
        rawBytes: bytes,
        userId: uid,
        docType: 'plat',
      );

      if (url != null) {
        _platImageUrl = url;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mengunggah foto plat nomor.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Upload foto STNK kendaraan
  Future<bool> uploadStnkImage({
    required Uint8List bytes,
    String? userId,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id ?? 'vehicle_guest';
      final url = await SupabaseStorageService.instance.uploadVehicleImage(
        rawBytes: bytes,
        userId: uid,
        docType: 'stnk',
      );

      if (url != null) {
        _stnkImageUrl = url;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mengunggah foto STNK.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Reset state setelah foto selesai digunakan
  void reset() {
    _platImageUrl = null;
    _stnkImageUrl = null;
    _errorMessage = null;
    notifyListeners();
  }
}
