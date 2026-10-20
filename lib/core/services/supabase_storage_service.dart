import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/image_compression_util.dart';

/// Service untuk menangani pengunggahan berkas media ke Supabase Storage
/// Mengintegrasikan kompresi brutal ~95% sebelum data dikirim ke storage bucket.
class SupabaseStorageService {
  SupabaseStorageService._();
  static final SupabaseStorageService instance = SupabaseStorageService._();

  SupabaseClient get _client => Supabase.instance.client;

  static const String kycBucket = 'kyc-documents';

  /// Unggah foto KTP atau Selfie KYC dengan kompresi brutal 95%
  /// Mengembalikan Public URL dari dokumen yang berhasil diunggah.
  Future<String?> uploadKycImage({
    required Uint8List rawBytes,
    required String userId,
    required String docType, // 'ktp' atau 'selfie'
  }) async {
    try {
      // 1. Kompresi brutal ~95% terlebih dahulu
      final compressionResult = await ImageCompressionUtil.compressBrutally(
        rawBytes,
        targetWidth: 800,
        quality: 25,
      );

      final fileName = '${userId}_${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '$userId/$fileName';

      // 2. Upload binary ke bucket `kyc-documents`
      await _client.storage.from(kycBucket).uploadBinary(
            storagePath,
            compressionResult.compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // 3. Ambil public URL
      final publicUrl = _client.storage.from(kycBucket).getPublicUrl(storagePath);
      debugPrint('[SupabaseStorage] KYC Upload Berhasil: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[SupabaseStorage] Gagal mengunggah KYC image: $e');
      return null;
    }
  }

  /// Unggah foto kendaraan (Plat nomor / STNK)
  Future<String?> uploadVehicleImage({
    required Uint8List rawBytes,
    required String userId,
    required String docType, // 'plat' atau 'stnk'
  }) async {
    try {
      final compressionResult = await ImageCompressionUtil.compressBrutally(
        rawBytes,
        targetWidth: 800,
        quality: 25,
      );

      final fileName = 'veh_${userId}_${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = 'vehicles/$userId/$fileName';

      await _client.storage.from(kycBucket).uploadBinary(
            storagePath,
            compressionResult.compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from(kycBucket).getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      debugPrint('[SupabaseStorage] Gagal mengunggah Vehicle image: $e');
      return null;
    }
  }
}
