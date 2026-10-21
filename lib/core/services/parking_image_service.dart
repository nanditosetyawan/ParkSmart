import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Layanan Kompresi & Penyimpanan Foto Lokasi Parkir ke Supabase Storage
/// - Mengompresi resolusi & ukuran file (JPEG) di semua platform (Web, Android, iOS, Windows)
/// - Mengunggah ke bucket `parking-locations`
/// - Menghapus foto lama/salah saat diedit agar storage bersih tanpa sampah
class ParkingImageService {
  static const String bucketName = 'parking-locations';

  /// Kompresi gambar Uint8List menggunakan pure Dart image processing
  /// Menjaga aspek rasio, membatasi ukuran maksimal 1280px, kualitas JPEG 78%
  static Uint8List compressImageBytes(Uint8List originalBytes, {int maxDimension = 1280, int quality = 78}) {
    try {
      final decoded = img.decodeImage(originalBytes);
      if (decoded == null) return originalBytes;

      img.Image processed = decoded;
      if (decoded.width > maxDimension || decoded.height > maxDimension) {
        if (decoded.width >= decoded.height) {
          processed = img.copyResize(decoded, width: maxDimension);
        } else {
          processed = img.copyResize(decoded, height: maxDimension);
        }
      }

      final compressed = img.encodeJpg(processed, quality: quality);
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('[ParkingImageService] Compression error: $e. Using original bytes.');
      return originalBytes;
    }
  }

  /// Kompresi & Upload gambar ke Supabase Storage bucket `parking-locations`
  /// Mengembalikan Public URL dari file yang diupload
  static Future<String?> uploadLocationImage(Uint8List rawBytes, {String? customFileName}) async {
    try {
      final compressed = compressImageBytes(rawBytes);
      final fileName = customFileName ??
          'loc_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}.jpg';

      await Supabase.instance.client.storage.from(bucketName).uploadBinary(
            fileName,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      debugPrint('[ParkingImageService] Berhasil upload foto lokasi: $publicUrl (${compressed.length ~/ 1024} KB)');
      return publicUrl;
    } catch (e) {
      debugPrint('[ParkingImageService] Upload error: $e');
      return null;
    }
  }

  /// Menghapus file spesifik dari Supabase Storage berdasarkan Public URL-nya
  /// Hanya menghapus jika file memang berada di bucket `parking-locations`
  static Future<bool> deleteLocationImage(String publicUrl) async {
    try {
      if (publicUrl.isEmpty || !publicUrl.contains('/$bucketName/')) {
        return false;
      }

      // Ambil path relatif setelah nama bucket
      final pathPart = publicUrl.split('/$bucketName/').last.split('?').first;
      if (pathPart.isEmpty) return false;

      final res = await Supabase.instance.client.storage
          .from(bucketName)
          .remove([pathPart]);

      debugPrint('[ParkingImageService] Berhasil hapus file sampah storage: $pathPart');
      return res.isNotEmpty;
    } catch (e) {
      debugPrint('[ParkingImageService] Delete error: $e');
      return false;
    }
  }

  /// Menghapus sekumpulan file dari Supabase Storage sekaligus
  static Future<void> deleteMultipleLocationImages(Iterable<String> publicUrls) async {
    final pathsToDelete = <String>[];
    for (final url in publicUrls) {
      if (url.contains('/$bucketName/')) {
        final path = url.split('/$bucketName/').last.split('?').first;
        if (path.isNotEmpty) {
          pathsToDelete.add(path);
        }
      }
    }

    if (pathsToDelete.isNotEmpty) {
      try {
        await Supabase.instance.client.storage
            .from(bucketName)
            .remove(pathsToDelete);
        debugPrint('[ParkingImageService] Berhasil membersihkan ${pathsToDelete.length} file sampah dari bucket');
      } catch (e) {
        debugPrint('[ParkingImageService] Bulk delete error: $e');
      }
    }
  }
}
