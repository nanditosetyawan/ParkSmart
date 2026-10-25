import 'dart:typed_data';
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart' as platform_download;

/// Layanan terpusat untuk mengunduh dan menyimpan berkas (seperti bukti transaksi PNG)
/// Mendukung Web, Android, iOS, dan Desktop secara transparan.
class FileDownloadService {
  FileDownloadService._();
  static final FileDownloadService instance = FileDownloadService._();

  /// Mengunduh atau menyimpan data byte gambar sebagai file PNG
  Future<String?> downloadPng(Uint8List bytes, String filename) async {
    return platform_download.downloadBytesFile(bytes, filename);
  }
}
