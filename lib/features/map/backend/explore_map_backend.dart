import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/currency_service.dart';

/// Backend khusus untuk ExploreMapScreen (lib/features/map/explore_map_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk performa peta yang cepat & lancar
class ExploreMapBackend extends ChangeNotifier {
  ExploreMapBackend._();
  static final ExploreMapBackend instance = ExploreMapBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> get locations => _locations;

  /// Memuat daftar lokasi parkir dari Supabase untuk ditampilkan di peta
  Future<void> fetchMapLocations({String? category, String? searchQuery}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Targeted Column Query: Mengambil detail lokasi lengkap termasuk operating_hours
      var query = _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, rating, review_count, status, image_url, images, facilities, operating_hours');

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('name', '%${searchQuery.trim()}%');
      }

      final response = await query.order('rating', ascending: false);

      // Ambil ketersediaan slot aktual berdasarkan tabel public.parking_slots per location_id
      final List<dynamic> slotsData = await _client
          .from('parking_slots')
          .select('id, location_id, status');

      final Map<String, List<dynamic>> slotsByLocation = {};
      for (final s in slotsData) {
        final locId = s['location_id']?.toString();
        if (locId != null) {
          slotsByLocation.putIfAbsent(locId, () => []).add(s);
        }
      }

      _locations = response.map<Map<String, dynamic>>((row) {
        final locId = row['id']?.toString() ?? '';
        final lat = (row['latitude'] as num?)?.toDouble() ?? -6.1754;
        final lng = (row['longitude'] as num?)?.toDouble() ?? 106.7933;
        final rateMobil = (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
        final rateEv = (row['hourly_rate_ev'] as num?)?.toInt() ?? 7500;
        final rateMotor = (row['hourly_rate_motor'] as num?)?.toInt() ?? 2000;
        final capacity = (row['total_capacity'] as int?) ?? 50;
        final facilities = (row['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final bool isEv = facilities.any((f) => f.toLowerCase().contains('ev'));

        // Hitung slot tersedia riil berdasarkan denah slot (status == 'available')
        final locationSlots = slotsByLocation[locId] ?? [];
        final int availableCount = locationSlots.where((s) => s['status'] == 'available').length;
        final int actualAvailableSlots = locationSlots.isNotEmpty ? availableCount : capacity;

        // Rating: jika belum ada ulasan (review_count == 0), rating adalah 0.0
        final num reviewCount = (row['review_count'] as num?) ?? 0;
        final double rawRating = (row['rating'] as num?)?.toDouble() ?? 0.0;
        final double effectiveRating = reviewCount == 0 ? 0.0 : rawRating;

        final String opHours = row['operating_hours']?.toString().trim() ?? 'Buka 24 Jam';

        List<String> photos = [];
        if (row['images'] is List) {
          photos = (row['images'] as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
        if (photos.isEmpty && row['image_url'] != null && row['image_url'].toString().trim().isNotEmpty) {
          photos.add(row['image_url'].toString().trim());
        }
        if (photos.isEmpty) {
          photos.add('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80');
        }

        return {
          'id': row['id'],
          'name': row['name'] ?? 'Spot Parkir',
          'type': row['type'] ?? 'Parkir Resmi',
          'point': LatLng(lat, lng),
          'slots': actualAvailableSlots,
          'available_slots': actualAvailableSlots,
          'total_capacity': capacity,
          'isEv': isEv,
          'distance': '1.2 km',
          'price': '${CurrencyService.instance.format(rateMobil)} / jam',
          'rating': effectiveRating,
          'reviews': '$reviewCount',
          'review_count': reviewCount,
          'operating_hours': opHours.isNotEmpty ? opHours : 'Buka 24 Jam',
          'hours': opHours.isNotEmpty ? opHours : (row['status'] == 'active' ? 'Buka 24 Jam' : 'Tutup Sementara'),
          'status': row['status'] ?? 'active',
          'hourly_rate_mobil': rateMobil,
          'hourly_rate_motor': rateMotor,
          'hourly_rate_ev': rateEv,
          'hourly_rate_active': rateMobil,
          'photos': photos,
          'image_url': photos.first,
          'facilities': facilities,
        };
      }).toList();
    } catch (e) {
      debugPrint('[ExploreMapBackend] fetchMapLocations error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
