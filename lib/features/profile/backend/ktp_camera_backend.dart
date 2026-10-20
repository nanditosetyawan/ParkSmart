import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk KtpCameraScreen
/// Menangani pengambilan/pemilihan foto KTP dan foto selfie wajah,
/// melakukan kompresi brutal ~95%, mengunggah ke bucket `kyc-documents`,
/// dan mencatat permohonan ke tabel `public.user_kyc` dengan status 'pending'.
class KtpCameraBackend extends ChangeNotifier {
  KtpCameraBackend._();
  static final KtpCameraBackend instance = KtpCameraBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _ktpImageUrl;
  String? get ktpImageUrl => _ktpImageUrl;

  String? _selfieImageUrl;
  String? get selfieImageUrl => _selfieImageUrl;

  /// Mengunggah gambar KTP
  Future<bool> uploadKtpPhoto({
    required Uint8List bytes,
    String? userId,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id ?? 'guest_user';
      final url = await SupabaseStorageService.instance.uploadKycImage(
        rawBytes: bytes,
        userId: uid,
        docType: 'ktp',
      );

      if (url != null) {
        _ktpImageUrl = url;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mengunggah foto KTP ke storage.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Mengunggah foto Selfie dengan KTP
  Future<bool> uploadSelfiePhoto({
    required Uint8List bytes,
    String? userId,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id ?? 'guest_user';
      final url = await SupabaseStorageService.instance.uploadKycImage(
        rawBytes: bytes,
        userId: uid,
        docType: 'selfie',
      );

      if (url != null) {
        _selfieImageUrl = url;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal mengunggah foto selfie ke storage.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  /// Finalisasi submit KYC ke tabel `public.user_kyc`
  Future<bool> submitKycApplication({
    required String nik,
    required String fullName,
    String? birthPlaceCity,
    DateTime? birthDate,
    String? address,
    String? gender,
    String? religion,
    String? occupation,
    String? userId,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uid = userId ?? _client.auth.currentUser?.id;

      // Cari atau fallback ke user pertama jika testing
      String targetUserId;
      if (uid != null) {
        targetUserId = uid;
      } else {
        final existingUser = await _client.from('users').select('id').limit(1).maybeSingle();
        targetUserId = existingUser != null ? existingUser['id'].toString() : '00000000-0000-0000-0000-000000000000';
      }

      final payload = {
        'user_id': targetUserId,
        'nik': nik,
        'full_name': fullName,
        'birth_place_city': birthPlaceCity ?? 'Jakarta',
        'birth_date': birthDate?.toIso8601String().split('T').first ?? '1998-01-01',
        'address': address ?? 'Indonesia',
        'gender': gender ?? 'Laki-laki',
        'religion': religion ?? 'Islam',
        'occupation': occupation ?? 'Karyawan',
        'ktp_image_url': _ktpImageUrl,
        'selfie_image_url': _selfieImageUrl,
        'status': 'pending',
        'submitted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('user_kyc').upsert(payload, onConflict: 'user_id');

      // Invalidasi cache KYC agar admin dan profil langsung membaca data terkini
      await DatabaseCacheBalancerService.instance.invalidatePrefix('kyc_');

      debugPrint('[KtpCameraBackend] Sukses submit KYC ke user_kyc');
      return true;
    } catch (e) {
      debugPrint('[KtpCameraBackend] Gagal submit KYC: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
