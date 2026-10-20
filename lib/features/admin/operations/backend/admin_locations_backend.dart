import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk LocationsScreen (admin_locations_screen.dart)
/// Mengelola master data lokasi parkir fisik, tarif dasar, kapasitas dan kota
/// Terkoneksi ke `public.parking_locations` di Supabase
class AdminLocationsBackend extends ChangeNotifier {
  AdminLocationsBackend._();
  static final AdminLocationsBackend instance = AdminLocationsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _defaultLocations = [
    {
      'id': 'LOC-001',
      'name': 'Central Park Mall',
      'city': 'Jakarta Barat',
      'address': 'Jl. Letjen S. Parman No. 28, Tanjung Duren',
      'floors': 'Basement (B1 - B3)',
      'capacity': 300,
      'occupied': 240,
      'carSlots': 220,
      'motorSlots': 60,
      'evSlots': 20,
      'hourlyRate': 5000,
      'status': 'Aktif Normal',
      'statusColor': const Color(0xFF17A18A),
    },
    {
      'id': 'LOC-002',
      'name': 'Grand Indonesia',
      'city': 'Jakarta Pusat',
      'address': 'Jl. M.H. Thamrin No. 1, Menteng',
      'floors': 'East & West Mall (B1 - B2)',
      'capacity': 450,
      'occupied': 415,
      'carSlots': 350,
      'motorSlots': 80,
      'evSlots': 20,
      'hourlyRate': 6000,
      'status': 'Padat',
      'statusColor': const Color(0xFFE07A5F),
    },
    {
      'id': 'LOC-003',
      'name': 'Pacific Place SCBD',
      'city': 'Jakarta Selatan',
      'address': 'Jl. Jend. Sudirman Kav. 52-53, SCBD',
      'floors': 'Basement P1 - P3',
      'capacity': 200,
      'occupied': 200,
      'carSlots': 160,
      'motorSlots': 25,
      'evSlots': 15,
      'hourlyRate': 8000,
      'status': 'Penuh',
      'statusColor': const Color(0xFFD94B4B),
    },
    {
      'id': 'LOC-004',
      'name': 'Malioboro Mall',
      'city': 'Yogyakarta',
      'address': 'Jl. Malioboro No. 52-58, Sosromenduran',
      'floors': 'Gedung Parkir Terpadu L1 - L3',
      'capacity': 150,
      'occupied': 95,
      'carSlots': 100,
      'motorSlots': 40,
      'evSlots': 10,
      'hourlyRate': 3000,
      'status': 'Aktif Normal',
      'statusColor': const Color(0xFF17A18A),
    },
    {
      'id': 'LOC-005',
      'name': 'Tunjungan Plaza 6',
      'city': 'Surabaya',
      'address': 'Jl. Embong Malang No. 21-31, Tegalsari',
      'floors': 'Basement B1 - B4',
      'capacity': 350,
      'occupied': 120,
      'carSlots': 260,
      'motorSlots': 70,
      'evSlots': 20,
      'hourlyRate': 4000,
      'status': 'Aktif Normal',
      'statusColor': const Color(0xFF17A18A),
    },
  ];

  late List<Map<String, dynamic>> locations = List.from(_defaultLocations);

  /// Memuat daftar lokasi parkir dari Supabase
  Future<void> fetchLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_locations')
          .select('id, code, name, city, address, total_capacity, car_slots_capacity, motor_slots_capacity, ev_slots_capacity, hourly_rate_mobil, status')
          .order('name', ascending: true);

      if (res.isNotEmpty) {
        locations = res.map<Map<String, dynamic>>((row) {
          final statusDb = row['status']?.toString().toLowerCase();
          String statusLabel = 'Aktif Normal';
          Color statusCol = const Color(0xFF17A18A);

          if (statusDb == 'crowded') {
            statusLabel = 'Padat';
            statusCol = const Color(0xFFE07A5F);
          } else if (statusDb == 'full') {
            statusLabel = 'Penuh';
            statusCol = const Color(0xFFD94B4B);
          } else if (statusDb == 'maintenance') {
            statusLabel = 'Maintenance';
            statusCol = const Color(0xFFF59E0B);
          }

          final totalCap = (row['total_capacity'] as num?)?.toInt() ?? 100;
          final occupied = (totalCap * 0.75).round(); // estimasi okupansi bila belum ada realtime sensor

          return {
            'id': row['id']?.toString() ?? 'LOC-000',
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'city': row['city']?.toString() ?? 'Jakarta',
            'address': row['address']?.toString() ?? '-',
            'floors': 'Basement (B1 - B2)',
            'capacity': totalCap,
            'occupied': occupied,
            'carSlots': (row['car_slots_capacity'] as num?)?.toInt() ?? (totalCap * 0.8).round(),
            'motorSlots': (row['motor_slots_capacity'] as num?)?.toInt() ?? (totalCap * 0.15).round(),
            'evSlots': (row['ev_slots_capacity'] as num?)?.toInt() ?? (totalCap * 0.05).round(),
            'hourlyRate': (row['hourly_rate_mobil'] as num?)?.toInt() ?? 5000,
            'status': statusLabel,
            'statusColor': statusCol,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminLocationsBackend] fetchLocations error: $e');
      _errorMessage = e.toString();
      if (locations.isEmpty) {
        locations = List.from(_defaultLocations);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tambah lokasi baru
  Future<bool> addLocation(Map<String, dynamic> loc) async {
    locations.insert(0, loc);
    notifyListeners();

    try {
      final imgUrl = loc['imageUrl']?.toString() ??
          loc['image_url']?.toString() ??
          'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80';

      await _client.from('parking_locations').insert({
        'code': 'LOC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'name': loc['name'] ?? 'Lokasi Baru',
        'city': loc['city'] ?? 'Jakarta',
        'province': 'Indonesia',
        'address': loc['address'] ?? '-',
        'latitude': loc['latitude'] ?? -6.1754,
        'longitude': loc['longitude'] ?? 106.7933,
        'total_capacity': loc['capacity'] ?? 100,
        'car_slots_capacity': loc['carSlots'] ?? 80,
        'motor_slots_capacity': loc['motorSlots'] ?? 15,
        'ev_slots_capacity': loc['evSlots'] ?? 5,
        'hourly_rate_mobil': loc['hourlyRate'] ?? 5000,
        'status': 'active',
        'image_url': imgUrl,
        'images': [imgUrl],
      });
      await fetchLocations();
      return true;
    } catch (e) {
      debugPrint('[AdminLocationsBackend] addLocation error: $e');
      return false;
    }
  }

  /// Perbarui lokasi
  Future<bool> updateLocation(String id, Map<String, dynamic> updated) async {
    final idx = locations.indexWhere((l) => l['id'] == id);
    if (idx != -1) {
      locations[idx] = updated;
      notifyListeners();
    }

    try {
      await _client.from('parking_locations').update({
        'name': updated['name'],
        'city': updated['city'],
        'address': updated['address'],
        'total_capacity': updated['capacity'],
        'hourly_rate_mobil': updated['hourlyRate'],
      }).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[AdminLocationsBackend] updateLocation error: $e');
      return false;
    }
  }

  /// Hapus lokasi
  Future<bool> deleteLocation(String id) async {
    locations.removeWhere((l) => l['id'] == id);
    notifyListeners();

    try {
      await _client.from('parking_locations').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[AdminLocationsBackend] deleteLocation error: $e');
      return false;
    }
  }
}
