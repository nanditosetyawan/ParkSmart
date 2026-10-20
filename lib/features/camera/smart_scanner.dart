import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import 'backend/smart_scanner_backend.dart';

class SmartScanner {
  static Future<void> openCameraAndProcess(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    // 1. Buka kamera untuk memfoto
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      return; // Batal foto
    }

    if (!context.mounted) return;
    
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final inputImage = InputImage.fromFilePath(image.path);
    String resultMessage = '';

    try {
      // 2. Coba deteksi Barcode dulu
      final barcodeScanner = BarcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();


      if (barcodes.isNotEmpty) {
        // Jika ketemu barcode, validasi dengan database
        final raw = barcodes.first.displayValue ?? '';
        final valResult = await SmartScannerBackend.instance.validateScannedCode(raw);
        if (valResult['found'] == true) {
          resultMessage = '✅ ${valResult['title']}:\n${valResult['data']}';
        } else {
          resultMessage = 'Teks Barcode/QR:\n$raw';
        }
      } else {
        // 3. Jika tidak ada barcode, kita deteksi benda (Image Labeling)
        final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.7);
        final imageLabeler = ImageLabeler(options: options);
        final labels = await imageLabeler.processImage(inputImage);
        await imageLabeler.close();

        if (labels.isNotEmpty) {
          resultMessage = 'Benda terdeteksi:\n';
          for (final label in labels) {
            resultMessage += '- ${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)\n';
          }
        } else {
          resultMessage = 'Tidak mendeteksi benda apa pun dengan jelas.';
        }
      }
    } catch (e) {
      resultMessage = 'Terjadi kesalahan: $e';
    }

    if (!context.mounted) return;
    // Tutup loading dialog
    Navigator.pop(context);

    final isDark = ThemeService.instance.isDarkMode;

    // Tampilkan hasil
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E232B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? const Color(0xFF333D4E) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        title: Text(
          'Hasil Deteksi Kamera',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1C1C18),
          ),
        ),
        content: Text(
          resultMessage,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.4,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF333333),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1A73E8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}