import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

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
        // Jika ketemu barcode
        resultMessage = 'Teks Barcode/QR:\n${barcodes.first.displayValue}';
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

    // Tampilkan hasil
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hasil Deteksi Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(resultMessage, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}