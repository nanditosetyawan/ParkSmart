import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/currency_service.dart';
import '../../home/backend/home_backend.dart';
import '../../profile/backend/profile_backend.dart';

/// Backend khusus untuk FavoriteScreen (lib/features/favorite/favorite_screen.dart)
/// Menggunakan Targeted Column Query & Manajemen Relasi User Favorites Per Akun
class FavoriteBackend extends ChangeNotifier {
  FavoriteBackend._();
  static final FavoriteBackend instance = FavoriteBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Set<String> _favoriteLocationIds = {};
  Set<String> get favoriteLocationIds => _favoriteLocationIds;

  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> get favorites => _favorites;

  /// Helper untuk mendapatkan User ID aktif yang sedang login
  Future<String> _resolveUserId() async {
    if (ProfileBackend.instance.userId.isNotEmpty) {
      return ProfileBackend.instance.userId;
    }
    if (SessionService.instance.userId != null && SessionService.instance.userId!.isNotEmpty) {
      return SessionService.instance.userId!;
    }
    if (HomeBackend.instance.userId.isNotEmpty) {
      return HomeBackend.instance.userId;
    }
    final authUser = _client.auth.currentUser;
    if (authUser != null) {
      try {
        final row = await _client.from('users').select('id').eq('auth_user_id', authUser.id).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }
    final email = SessionService.instance.identifier ?? ProfileBackend.instance.email;
    if (email.isNotEmpty) {
      try {
        final row = await _client.from('users').select('id').eq('email', email).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }
    return '';
  }

  /// Cek apakah suatu tempat parkir merupakan favorit user yang sedang login
  bool isFavorite(String? locationId) {
    if (locationId == null || locationId.isEmpty) return false;
    return _favoriteLocationIds.contains(locationId);
  }

  /// Memuat daftar lokasi parkir favorit dari Supabase KHUSUS user yang sedang login
  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = await _resolveUserId();
      if (uid.isEmpty) {
        _favorites = [];
        _favoriteLocationIds.clear();
        return;
      }

      // 1. Ambil relasi user_favorites spesifik untuk user ini
      final favRows = await _client
          .from('user_favorites')
          .select('location_id, created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      if (favRows.isEmpty) {
        _favorites = [];
        _favoriteLocationIds.clear();
        return;
      }

      final List<String> orderedLocIds = favRows
          .map((r) => r['location_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      _favoriteLocationIds = orderedLocIds.toSet();

      // 2. Targeted Column Query: Hanya mengambil informasi ringkas tempat parkir yang difavoritkan
      final response = await _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, rating, review_count, status, image_url, facilities')
          .filter('id', 'in', orderedLocIds);

      final Map<String, Map<String, dynamic>> locMap = {};
      for (final row in response) {
        locMap[row['id'].toString()] = row;
      }

      final List<Map<String, dynamic>> results = [];
      for (final locId in orderedLocIds) {
        final row = locMap[locId];
        if (row == null) continue;

        final lat = (row['latitude'] as num?)?.toDouble() ?? -6.1788;
        final lng = (row['longitude'] as num?)?.toDouble() ?? 106.7916;
        final rateMobil = (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
        final rateEv = (row['hourly_rate_ev'] as num?)?.toInt() ?? 7500;
        final rateMotor = (row['hourly_rate_motor'] as num?)?.toInt() ?? 2000;
        final capacity = (row['total_capacity'] as int?) ?? 40;
        final facilities = (row['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final bool isEv = facilities.any((f) => f.toLowerCase().contains('ev'));
        final activeRate = isEv ? rateEv : rateMobil;

        results.add({
          'id': row['id'],
          'name': row['name'] ?? 'Spot Parkir',
          'type': row['type'] ?? 'Parkiran Mall',
          'point': LatLng(lat, lng),
          'slots': capacity,
          'isEv': isEv,
          'distance': '500m',
          'price': '${CurrencyService.instance.format(activeRate)} / jam',
          'rating': (row['rating'] as num?)?.toDouble() ?? 4.7,
          'reviews': '${row['review_count'] ?? 1000}',
          'hours': row['status'] == 'open' ? 'Buka 24 Jam' : 'Tutup Sementara',
          'hourly_rate_mobil': rateMobil,
          'hourly_rate_motor': rateMotor,
          'hourly_rate_ev': rateEv,
          'hourly_rate_active': activeRate,
          'photos': [
            row['image_url'] ?? 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
          ],
        });
      }

      _favorites = results;
    } catch (e) {
      debugPrint('[FavoriteBackend] fetchFavorites error: $e');
      _favorites = [];
      _favoriteLocationIds.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sinkronisasi kolom array favorite_location_ids pada tabel users untuk kompatibilitas
  Future<void> _syncUserFavoriteLocationIds(String uid) async {
    try {
      final rows = await _client
          .from('user_favorites')
          .select('location_id')
          .eq('user_id', uid);
      final ids = rows.map((r) => r['location_id'].toString()).toList();
      await _client.from('users').update({
        'favorite_location_ids': ids,
      }).eq('id', uid);
    } catch (e) {
      debugPrint('[FavoriteBackend] _syncUserFavoriteLocationIds warning: $e');
    }
  }

  /// Toggle status favorit (Tambah jika belum ada, Hapus jika sudah ada)
  /// Mengembalikan `true` jika sekarang jadi favorit, `false` jika dihapus dari favorit
  Future<bool> toggleFavorite(String locationId) async {
    try {
      final uid = await _resolveUserId();
      if (uid.isEmpty) return false;

      final bool isCurrentlyFav = _favoriteLocationIds.contains(locationId);

      if (isCurrentlyFav) {
        // Hapus dari user_favorites
        await _client
            .from('user_favorites')
            .delete()
            .eq('user_id', uid)
            .eq('location_id', locationId);

        _favoriteLocationIds.remove(locationId);
        _favorites.removeWhere((item) => item['id']?.toString() == locationId);
        _syncUserFavoriteLocationIds(uid);
        notifyListeners();
        return false;
      } else {
        // Tambahkan ke user_favorites
        await _client.from('user_favorites').upsert({
          'user_id': uid,
          'location_id': locationId,
        });

        _favoriteLocationIds.add(locationId);
        _syncUserFavoriteLocationIds(uid);

        // Ambil detail lokasi untuk langsung disisipkan ke list in-memory
        try {
          final row = await _client
              .from('parking_locations')
              .select('id, code, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, rating, review_count, status, image_url, facilities')
              .eq('id', locationId)
              .maybeSingle();

          if (row != null) {
            final lat = (row['latitude'] as num?)?.toDouble() ?? -6.1788;
            final lng = (row['longitude'] as num?)?.toDouble() ?? 106.7916;
            final rateMobil = (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
            final rateEv = (row['hourly_rate_ev'] as num?)?.toInt() ?? 7500;
            final rateMotor = (row['hourly_rate_motor'] as num?)?.toInt() ?? 2000;
            final capacity = (row['total_capacity'] as int?) ?? 40;
            final facilities = (row['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
            final bool isEv = facilities.any((f) => f.toLowerCase().contains('ev'));
            final activeRate = isEv ? rateEv : rateMobil;

            _favorites.removeWhere((item) => item['id']?.toString() == locationId);
            _favorites.insert(0, {
              'id': row['id'],
              'name': row['name'] ?? 'Spot Parkir',
              'type': row['type'] ?? 'Parkiran Mall',
              'point': LatLng(lat, lng),
              'slots': capacity,
              'isEv': isEv,
              'distance': '500m',
              'price': '${CurrencyService.instance.format(activeRate)} / jam',
              'rating': (row['rating'] as num?)?.toDouble() ?? 4.7,
              'reviews': '${row['review_count'] ?? 1000}',
              'hours': row['status'] == 'open' ? 'Buka 24 Jam' : 'Tutup Sementara',
              'hourly_rate_mobil': rateMobil,
              'hourly_rate_motor': rateMotor,
              'hourly_rate_ev': rateEv,
              'hourly_rate_active': activeRate,
              'photos': [
                row['image_url'] ?? 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
              ],
            });
          }
        } catch (_) {}

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[FavoriteBackend] toggleFavorite error: $e');
      return false;
    }
  }

  /// Menghapus lokasi dari daftar favorit
  Future<void> removeFavorite(String locationId) async {
    await toggleFavorite(locationId);
  }
}

