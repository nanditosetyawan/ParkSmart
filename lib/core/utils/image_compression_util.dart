import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Hasil kompresi gambar dengan metrik ukuran
class CompressionResult {
  final Uint8List compressedBytes;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final double compressionRatio; // Dalam persen, misal 95.4%

  CompressionResult({
    required this.compressedBytes,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.compressionRatio,
  });

  String get originalSizeFormatted => '${(originalSizeBytes / 1024).toStringAsFixed(1)} KB';
  String get compressedSizeFormatted => '${(compressedSizeBytes / 1024).toStringAsFixed(1)} KB';
  String get ratioFormatted => '${compressionRatio.toStringAsFixed(1)}%';
}

/// Utility Kompresi Gambar Brutal (~95% Pengurangan Ukuran)
/// Dirancang untuk mengompres foto KTP, STNK, dan Selfie sebelum diunggah ke Supabase Storage.
class ImageCompressionUtil {
  /// Kompresi brutal ~95% terhadap bytes gambar.
  /// [targetWidth]: Batas lebar maksimum (default: 800px untuk mempertahankan keterbacaan teks KTP)
  /// [quality]: Kualitas JPEG (default: 25 untuk mencapai rasio ~95%)
  static Future<CompressionResult> compressBrutally(
    Uint8List rawBytes, {
    int targetWidth = 800,
    int quality = 25,
  }) async {
    final originalSize = rawBytes.lengthInBytes;

    // Jalankan decoding & encoding di background thread/isolate agar UI tetap 60fps
    final compressedBytes = await compute(_processCompression, {
      'bytes': rawBytes,
      'targetWidth': targetWidth,
      'quality': quality,
    });

    final compressedSize = compressedBytes.lengthInBytes;
    final savedBytes = originalSize - compressedSize;
    final ratio = originalSize > 0 ? (savedBytes / originalSize) * 100 : 0.0;

    debugPrint(
      '[ImageCompressor] Kompresi Berhasil: '
      '${(originalSize / 1024).toStringAsFixed(1)} KB -> ${(compressedSize / 1024).toStringAsFixed(1)} KB '
      '(Hemat: ${ratio.toStringAsFixed(1)}%)',
    );

    return CompressionResult(
      compressedBytes: compressedBytes,
      originalSizeBytes: originalSize,
      compressedSizeBytes: compressedSize,
      compressionRatio: ratio,
    );
  }

  /// Worker fungsi untuk compute isolate
  static Uint8List _processCompression(Map<String, dynamic> params) {
    final Uint8List inputBytes = params['bytes'];
    final int targetWidth = params['targetWidth'];
    final int quality = params['quality'];

    // 1. Decode gambar
    final originalImage = img.decodeImage(inputBytes);
    if (originalImage == null) {
      // Jika decode gagal, kembalikan bytes asli
      return inputBytes;
    }

    // 2. Resize proporsional jika lebar melebihi batas
    img.Image resizedImage = originalImage;
    if (originalImage.width > targetWidth) {
      resizedImage = img.copyResize(
        originalImage,
        width: targetWidth,
        interpolation: img.Interpolation.average,
      );
    }

    // 3. Encode kembali ke JPEG dengan kompresi agresif (quality: 20-25)
    final compressedJpg = img.encodeJpg(resizedImage, quality: quality);
    return Uint8List.fromList(compressedJpg);
  }
}
