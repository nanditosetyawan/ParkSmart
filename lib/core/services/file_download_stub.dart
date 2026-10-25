import 'dart:io';
import 'package:flutter/foundation.dart';

/// Implementasi penyimpanan file untuk platform non-web (Android, iOS, Desktop)
Future<String?> downloadBytesFile(Uint8List bytes, String filename) async {
  try {
    Directory? targetDir;

    if (Platform.isAndroid) {
      // 1. Coba folder umum Download publik di Android
      final publicDownload = Directory('/storage/emulated/0/Download');
      if (publicDownload.existsSync()) {
        targetDir = publicDownload;
      } else {
        // 2. Coba folder Download alternatif
        final sdcardDownload = Directory('/sdcard/Download');
        if (sdcardDownload.existsSync()) {
          targetDir = sdcardDownload;
        }
      }
    }

    // 3. Fallback jika bukan Android atau folder publik tidak ditemukan
    targetDir ??= Directory.systemTemp;

    final file = File('${targetDir.path}/$filename');
    await file.writeAsBytes(bytes);
    debugPrint('[FileDownloadStub] Berhasil menyimpan file bukti ke: ${file.path}');
    return file.path;
  } catch (e) {
    debugPrint('[FileDownloadStub] Gagal menyimpan file: $e');
    return null;
  }
}
