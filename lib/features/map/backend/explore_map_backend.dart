import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Targeted Column Query: Hanya mengambil kolom yang dibutuhkan oleh marker peta & pop-up
      var query = _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, hourly_rate_ev, rating, review_count, status, image_url, facilities');

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        query = query.ilike('name', '%${searchQuery.trim()}%');
      }

      final response = await query.order('rating', ascending: false);

      _locations = response.map<Map<String, dynamic>>((row) {
        final lat = (row['latitude'] as num?)?.toDouble() ?? -6.1754;
        final lng = (row['longitude'] as num?)?.toDouble() ?? 106.7933;
        final rateMobil = (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
        final capacity = (row['total_capacity'] as int?) ?? 50;
        final facilities = (row['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final bool isEv = facilities.any((f) => f.toLowerCase().contains('ev'));

        return {
          'id': row['id'],
          'name': row['name'] ?? 'Spot Parkir',
          'type': row['type'] ?? 'Parkir Resmi',
          'point': LatLng(lat, lng),
          'slots': capacity,
          'isEv': isEv,
          'distance': '1.2 km',
          'price': 'Rp ${rateMobil.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} / jam',
          'rating': (row['rating'] as num?)?.toDouble() ?? 4.5,
          'reviews': '${row['review_count'] ?? 0}',
          'hours': row['status'] == 'active' ? 'Buka 24 Jam' : 'Tutup Sementara',
          'photos': [
            if (row['image_url'] != null && row['image_url'].toString().isNotEmpty)
              row['image_url'].toString()
            else
              'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
          ],
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
