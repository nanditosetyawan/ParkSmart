import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk FavoriteScreen (lib/features/favorite/favorite_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *)
class FavoriteBackend extends ChangeNotifier {
  FavoriteBackend._();
  static final FavoriteBackend instance = FavoriteBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> get favorites => _favorites;

  /// Memuat daftar lokasi parkir favorit dari Supabase
  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Targeted Column Query: Hanya mengambil informasi ringkas tempat parkir favorit
      final response = await _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, rating, review_count, status, image_url, facilities')
          .order('rating', ascending: false);

      if (response.isNotEmpty) {
        _favorites = response.map<Map<String, dynamic>>((row) {
          final lat = (row['latitude'] as num?)?.toDouble() ?? -6.1788;
          final lng = (row['longitude'] as num?)?.toDouble() ?? 106.7916;
          final rateMobil = (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
          final capacity = (row['total_capacity'] as int?) ?? 40;
          final facilities = (row['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
          final bool isEv = facilities.any((f) => f.toLowerCase().contains('ev'));

          return {
            'id': row['id'],
            'name': row['name'] ?? 'Spot Parkir',
            'type': row['type'] ?? 'Parkiran Mall',
            'point': LatLng(lat, lng),
            'slots': capacity,
            'isEv': isEv,
            'distance': '500m',
            'price': 'Rp ${rateMobil.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} / jam',
            'rating': (row['rating'] as num?)?.toDouble() ?? 4.7,
            'reviews': '${row['review_count'] ?? 1000}',
            'hours': row['status'] == 'open' ? 'Buka 24 Jam' : 'Tutup Sementara',
            'photos': [
              row['image_url'] ?? 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
            ],
          };
        }).toList();
      } else {
        _favorites = [];
      }
    } catch (e) {
      debugPrint('[FavoriteBackend] fetchFavorites error: $e');
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menghapus lokasi dari daftar favorit
  void removeFavorite(String id) {
    _favorites.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }
}
