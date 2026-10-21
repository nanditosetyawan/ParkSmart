import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ParkingDetailScreen (lib/features/parking/parking_detail_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *)
class ParkingDetailBackend extends ChangeNotifier {
  ParkingDetailBackend._();
  static final ParkingDetailBackend instance = ParkingDetailBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _locationDetail;
  Map<String, dynamic>? get locationDetail => _locationDetail;
  bool get hasLocation => _locationDetail != null;

  int _totalSlots = 0;
  int get totalSlots => _totalSlots;

  int _availableSlots = 0;
  int get availableSlots => _availableSlots;

  /// Memuat informasi detail tempat parkir & ketersediaan slot aktual
  Future<void> fetchLocationDetail({String? locationId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Targeted Column Query: Detail Lokasi
      var locQuery = _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, total_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, rating, review_count, status, image_url, images, facilities');

      final locData = locationId != null
          ? await locQuery.eq('id', locationId).maybeSingle()
          : await locQuery.order('rating', ascending: false).limit(1).maybeSingle();

      if (locData != null) {
        _locationDetail = locData;
        _totalSlots = (locData['total_capacity'] as int?) ?? _totalSlots;

        // 2. Targeted Column Query: Slot parkir untuk menghitung slot kosong
        final actualLocId = locData['id'];
        final slotsData = await _client
            .from('parking_slots')
            .select('id, status')
            .eq('location_id', actualLocId);

        if (slotsData.isNotEmpty) {
          _totalSlots = slotsData.length;
          _availableSlots = slotsData.where((s) => s['status'] == 'available').length;
        } else {
          _availableSlots = 0;
        }
      }
    } catch (e) {
      debugPrint('[ParkingDetailBackend] fetchLocationDetail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
