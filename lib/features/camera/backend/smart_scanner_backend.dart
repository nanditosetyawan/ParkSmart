import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk SmartScanner (Kamera Scanner QR & Deteksi Kendaraan)
/// Menangani validasi kode QR tiket parkir, kode slot IoT, dan plat nomor kendaraan
/// terhadap tabel `public.bookings`, `public.parking_slots`, dan `public.vehicles`.
class SmartScannerBackend extends ChangeNotifier {
  SmartScannerBackend._();
  static final SmartScannerBackend instance = SmartScannerBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Memvalidasi teks QR / Barcode yang dipindai kamera terhadap database
  Future<Map<String, dynamic>> validateScannedCode(String rawCode) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trimmed = rawCode.trim();

      // 1. Cek apakah cocok dengan kode reservasi / tiket parkir
      final booking = await _client
          .from('bookings')
          .select('id, booking_code, parking_slot_id, vehicle_id, start_time, end_time, status, total_amount')
          .or('booking_code.eq.$trimmed,id.eq.$trimmed')
          .limit(1)
          .maybeSingle();

      if (booking != null) {
        return {
          'type': 'booking',
          'found': true,
          'title': 'Tiket Parkir Terverifikasi',
          'data': booking,
        };
      }

      // 2. Cek apakah cocok dengan kode slot parkir
      final slot = await _client
          .from('parking_slots')
          .select('id, slot_code, floor_level, slot_type, status, location_id')
          .or('slot_code.eq.$trimmed,id.eq.$trimmed')
          .limit(1)
          .maybeSingle();

      if (slot != null) {
        return {
          'type': 'slot',
          'found': true,
          'title': 'Slot Parkir Terdeteksi',
          'data': slot,
        };
      }

      // 3. Cek apakah cocok dengan plat nomor kendaraan
      final vehicle = await _client
          .from('vehicles')
          .select('id, license_plate, vehicle_type, brand, model')
          .eq('license_plate', trimmed)
          .limit(1)
          .maybeSingle();

      if (vehicle != null) {
        return {
          'type': 'vehicle',
          'found': true,
          'title': 'Kendaraan Terdaftar',
          'data': vehicle,
        };
      }

      // 4. Default: Teks QR umum
      return {
        'type': 'raw_text',
        'found': false,
        'title': 'Teks Barcode/QR',
        'content': trimmed,
      };
    } catch (e) {
      debugPrint('[SmartScannerBackend] Error validasi QR: $e');
      return {
        'type': 'raw_text',
        'found': false,
        'title': 'Hasil Pindaian',
        'content': rawCode,
      };
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
