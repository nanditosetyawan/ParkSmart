import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ManageParkingScreen (manage_parking_screen.dart)
/// Mengatur denah lantai, tarif dasar, tarif EV, dan fasilitas per lokasi
/// Terkoneksi ke `public.parking_locations` dan `public.parking_slots` di Supabase
class ManageParkingBackend extends ChangeNotifier {
  ManageParkingBackend._();
  static final ManageParkingBackend instance = ManageParkingBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _defaultLocations = [
    {
      'id': 'loc_1',
      'name': 'Central Park Mall',
      'typeLabel': 'Mall / Pusat Perbelanjaan',
      'city': 'Jakarta Barat',
      'address': 'Jl. Letjen S. Parman No.28, Tanjung Duren',
      'latitude': -6.1754,
      'longitude': 106.7933,
      'totalSlots': 300,
      'occupiedSlots': 240,
      'status': 'Aktif',
      'floors': ['Lantai B1', 'Lantai B2', 'Lantai B3'],
      'operatingHours': '06:00 - 23:00',
      'baseRate': 5000,
      'evRate': 7500,
      'motorRate': 2000,
      'isEvReady': true,
      'description': 'Gedung parkir multi-lantai dengan zona khusus EV charging di Lantai B2 dan sensor terpadu.',
      'checkinRadius': 100,
      'images': [
        'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600&auto=format&fit=crop&q=80',
      ],
    },
    {
      'id': 'loc_2',
      'name': 'Grand Indonesia',
      'typeLabel': 'Pusat Perbelanjaan Premium',
      'city': 'Jakarta Pusat',
      'address': 'Jl. M.H. Thamrin No.1, Menteng',
      'latitude': -6.1951,
      'longitude': 106.8230,
      'totalSlots': 450,
      'occupiedSlots': 415,
      'status': 'Aktif',
      'floors': ['Lantai B1', 'Lantai B2'],
      'operatingHours': 'Buka 24 Jam',
      'baseRate': 6000,
      'evRate': 8500,
      'motorRate': 3000,
      'isEvReady': true,
      'description': 'Fasilitas parkir modern di jantung ibu kota dengan akses langsung ke East & West Mall.',
      'checkinRadius': 150,
      'images': [
        'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
      ],
    },
  ];

  late List<Map<String, dynamic>> locations = List.from(_defaultLocations);

  /// Memuat master lokasi dan denah
  Future<void> fetchLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_locations')
          .select('id, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, operating_hours, status, facilities, images')
          .order('name', ascending: true);

      if (res.isNotEmpty) {
        locations = res.map<Map<String, dynamic>>((row) {
          final total = (row['total_capacity'] as num?)?.toInt() ?? 100;
          return {
            'id': row['id']?.toString() ?? 'loc_1',
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'typeLabel': row['type']?.toString() ?? 'Pusat Perbelanjaan',
            'city': row['city']?.toString() ?? 'Jakarta',
            'address': row['address']?.toString() ?? '-',
            'latitude': (row['latitude'] as num?)?.toDouble() ?? -6.1754,
            'longitude': (row['longitude'] as num?)?.toDouble() ?? 106.7933,
            'totalSlots': total,
            'occupiedSlots': (total * 0.7).round(),
            'status': row['status'] == 'active' ? 'Aktif' : 'Nonaktif',
            'floors': ['Lantai B1', 'Lantai B2', 'Lantai B3'],
            'operatingHours': row['operating_hours']?.toString() ?? 'Buka 24 Jam',
            'baseRate': (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000,
            'evRate': (row['hourly_rate_ev'] as num?)?.toInt() ?? 7500,
            'motorRate': (row['hourly_rate_motor'] as num?)?.toInt() ?? 2000,
            'isEvReady': true,
            'description': 'Fasilitas parkir terintegrasi sistem ParkSmart.',
            'checkinRadius': 150,
            'images': (row['images'] is List) ? List<String>.from(row['images']) : [],
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[ManageParkingBackend] fetchLocations error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update pengaturan lokasi & tarif
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
