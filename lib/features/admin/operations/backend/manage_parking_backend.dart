import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/parking_image_service.dart';

/// Backend khusus untuk ManageParkingScreen (manage_parking_screen.dart)
/// Mengatur denah lantai, tarif dasar, tarif EV, master lokasi, dan foto Supabase Storage
/// Terkoneksi ke `public.parking_locations` dan `public.parking_slots` di Supabase
class ManageParkingBackend extends ChangeNotifier {
  ManageParkingBackend._();
  static final ManageParkingBackend instance = ManageParkingBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> locations = [];

  /// Memuat master lokasi dan denah dari Supabase
  Future<void> fetchLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_locations')
          .select('id, code, name, type, city, province, address, latitude, longitude, total_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, operating_hours, status, facilities, images, image_url')
          .order('name', ascending: true);

      if (res.isNotEmpty) {
        locations = res.map<Map<String, dynamic>>((row) {
          final total = (row['total_capacity'] as num?)?.toInt() ?? 100;
          final List<String> imagesList = [];
          if (row['images'] is List) {
            imagesList.addAll(List<String>.from(row['images']));
          }
          final primaryUrl = row['image_url']?.toString();
          if (primaryUrl != null && primaryUrl.isNotEmpty && !imagesList.contains(primaryUrl)) {
            imagesList.insert(0, primaryUrl);
          }

          final statusStr = row['status']?.toString().toLowerCase() ?? 'active';
          String displayStatus = 'Aktif';
          if (statusStr == 'crowded') {
            displayStatus = 'Padat';
          } else if (statusStr == 'full') {
            displayStatus = 'Tutup';
          } else if (statusStr == 'maintenance') {
            displayStatus = 'Maintenance';
          }

          return {
            'id': row['id']?.toString() ?? '',
            'code': row['code']?.toString() ?? '',
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'typeLabel': row['type']?.toString() ?? 'Pusat Perbelanjaan',
            'city': row['city']?.toString() ?? 'Jakarta',
            'province': row['province']?.toString() ?? 'DKI Jakarta',
            'address': row['address']?.toString() ?? '-',
            'latitude': (row['latitude'] as num?)?.toDouble() ?? -6.1754,
            'longitude': (row['longitude'] as num?)?.toDouble() ?? 106.7933,
            'totalSlots': total,
            'occupiedSlots': (total * 0.7).round(),
            'status': displayStatus,
            'floors': ['Lantai B1', 'Lantai B2', 'Lantai B3'],
            'operatingHours': row['operating_hours']?.toString() ?? 'Buka 24 Jam',
            'baseRate': (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000,
            'evRate': (row['hourly_rate_ev'] as num?)?.toInt() ?? 7500,
            'motorRate': (row['hourly_rate_motor'] as num?)?.toInt() ?? 2000,
            'isEvReady': true,
            'description': 'Fasilitas parkir terintegrasi sistem ParkSmart.',
            'checkinRadius': 150,
            'images': imagesList,
            'imageUrl': primaryUrl ?? (imagesList.isNotEmpty ? imagesList.first : ''),
          };
        }).toList();
      } else {
        locations = [];
      }
    } catch (e) {
      debugPrint('[ManageParkingBackend] fetchLocations error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah lokasi parkir baru ke Supabase database `public.parking_locations`
  Future<bool> addParkingLocation(Map<String, dynamic> locData) async {
    try {
      final totalSlots = locData['totalSlots'] as int? ?? 100;
      final images = List<String>.from(locData['images'] ?? []);
      final primaryImage = images.isNotEmpty ? images.first : null;
      final code = 'PKR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final row = {
        'code': code,
        'name': locData['name'],
        'type': locData['typeLabel'] ?? 'Mall / Pusat Perbelanjaan',
        'city': locData['city'] ?? 'Jakarta',
        'province': locData['city'] ?? 'DKI Jakarta',
        'address': locData['address'] ?? '-',
        'latitude': locData['latitude'] ?? -6.1754,
        'longitude': locData['longitude'] ?? 106.7933,
        'total_capacity': totalSlots,
        'car_slots_capacity': (totalSlots * 0.7).round(),
        'motor_slots_capacity': (totalSlots * 0.2).round(),
        'ev_slots_capacity': (totalSlots * 0.1).round(),
        'hourly_rate_mobil': locData['baseRate'] ?? 5000,
        'hourly_rate_motor': locData['motorRate'] ?? 2000,
        'hourly_rate_ev': locData['evRate'] ?? 7500,
        'operating_hours': locData['operatingHours'] ?? 'Buka 24 Jam',
        'status': 'active',
        'image_url': primaryImage,
        'images': images,
        'facilities': ['CCTV 24 Jam', 'Covered Parking', if (locData['isEvReady'] == true) 'EV Charging Station'],
      };

      await _client.from('parking_locations').insert(row);
      await fetchLocations();
      return true;
    } catch (e) {
      debugPrint('[ManageParkingBackend] addParkingLocation error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update lengkap lokasi parkir + bersihkan foto sampah yang dihapus dari Supabase Storage
  Future<bool> updateParkingLocationFull(
    String id,
    Map<String, dynamic> locData, {
    List<String>? deletedImageUrls,
  }) async {
    try {
      // 1. Eksekusi query penghapusan foto-foto yang disilang dari Supabase Storage (anti-sampah)
      if (deletedImageUrls != null && deletedImageUrls.isNotEmpty) {
        debugPrint('[ManageParkingBackend] Menghapus ${deletedImageUrls.length} file gambar dari storage...');
        await ParkingImageService.deleteMultipleLocationImages(deletedImageUrls);
      }

      final images = List<String>.from(locData['images'] ?? []);
      final primaryImage = images.isNotEmpty ? images.first : null;
      final totalSlots = locData['totalSlots'] as int? ?? 100;

      String dbStatus = 'active';
      final s = locData['status']?.toString();
      if (s == 'Padat') {
        dbStatus = 'crowded';
      } else if (s == 'Tutup') {
        dbStatus = 'full';
      } else if (s == 'Maintenance') {
        dbStatus = 'maintenance';
      }

      final updateMap = {
        'name': locData['name'],
        'type': locData['typeLabel'],
        'city': locData['city'],
        'address': locData['address'],
        'latitude': locData['latitude'],
        'longitude': locData['longitude'],
        'total_capacity': totalSlots,
        'car_slots_capacity': (totalSlots * 0.7).round(),
        'motor_slots_capacity': (totalSlots * 0.2).round(),
        'ev_slots_capacity': (totalSlots * 0.1).round(),
        'hourly_rate_mobil': locData['baseRate'],
        'hourly_rate_motor': locData['motorRate'],
        'hourly_rate_ev': locData['evRate'],
        'operating_hours': locData['operatingHours'],
        'status': dbStatus,
        'image_url': primaryImage,
        'images': images,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _client.from('parking_locations').update(updateMap).eq('id', id);
      await fetchLocations();
      return true;
    } catch (e) {
      debugPrint('[ManageParkingBackend] updateParkingLocationFull error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Hapus lokasi parkir beserta semua fotonya di Supabase Storage
  Future<bool> deleteParkingLocation(String id, {List<String>? imagesToDelete}) async {
    try {
      if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
        await ParkingImageService.deleteMultipleLocationImages(imagesToDelete);
      }
      await _client.from('parking_locations').delete().eq('id', id);
      await fetchLocations();
      return true;
    } catch (e) {
      debugPrint('[ManageParkingBackend] deleteParkingLocation error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update pengaturan lokasi & tarif cepat
  Future<bool> updateParkingLocation(String id, Map<String, dynamic> data) async {
    final idx = locations.indexWhere((l) => l['id'] == id);
    if (idx != -1) {
      locations[idx] = {...locations[idx], ...data};
      notifyListeners();
    }

    try {
      await _client.from('parking_locations').update({
        'hourly_rate_mobil': data['baseRate'],
        'hourly_rate_ev': data['evRate'],
        'hourly_rate_motor': data['motorRate'],
        'operating_hours': data['operatingHours'],
      }).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[ManageParkingBackend] updateParkingLocation error: $e');
      return false;
    }
  }
}
