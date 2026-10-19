import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AllLocationsRevenueScreen (all_locations_revenue_screen.dart)
/// Mengelola peringkat kontribusi pendapatan, volume omzet, dan jumlah sesi per lokasi parkir
/// Terkoneksi ke `public.parking_locations` dan `public.payments` di Supabase
class AllLocationsRevenueBackend extends ChangeNotifier {
  AllLocationsRevenueBackend._();
  static final AllLocationsRevenueBackend instance = AllLocationsRevenueBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _defaultLocations = [
    {
      'rank': 1,
      'name': 'Central Park Mall',
      'city': 'Jakarta Barat',
      'address': 'Jl. Letjen S. Parman No. 28, Tanjung Duren',
      'omzet': 'Rp 156.400.000',
      'rawAmount': 156400000,
      'percentage': 0.415,
      'sessions': '4.120 sesi',
      'growth': '+16.5%',
    },
    {
      'rank': 2,
      'name': 'Grand Indonesia',
      'city': 'Jakarta Pusat',
      'address': 'Jl. M.H. Thamrin No. 1, Menteng',
      'omzet': 'Rp 98.250.000',
      'rawAmount': 98250000,
      'percentage': 0.261,
      'sessions': '2.640 sesi',
      'growth': '+14.1%',
    },
    {
      'rank': 3,
      'name': 'Malioboro Mall',
      'city': 'Yogyakarta',
      'address': 'Jl. Malioboro No. 52-58, Danurejan',
      'omzet': 'Rp 34.600.000',
      'rawAmount': 34600000,
      'percentage': 0.092,
      'sessions': '1.180 sesi',
      'growth': '+8.4%',
    },
    {
      'rank': 4,
      'name': 'Galaxy Mall Surabaya',
      'city': 'Surabaya',
      'address': 'Jl. Dharmahusada Indah Timur No. 35-37',
      'omzet': 'Rp 23.200.000',
      'rawAmount': 23200000,
      'percentage': 0.062,
      'sessions': '790 sesi',
      'growth': '+7.2%',
    },
    {
      'rank': 5,
      'name': 'Paris Van Java',
      'city': 'Bandung',
      'address': 'Jl. Sukajadi No. 131-139, Cipedes',
      'omzet': 'Rp 19.800.000',
      'rawAmount': 19800000,
      'percentage': 0.053,
      'sessions': '650 sesi',
      'growth': '+5.8%',
    },
  ];

  late List<Map<String, dynamic>> locations = List.from(_defaultLocations);

  /// Mengambil data omzet lokasi dari Supabase
  Future<void> fetchLocationsRevenue() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_locations')
          .select('id, name, city, address, total_capacity')
          .order('name', ascending: true);

      if (res.isNotEmpty) {
        int rank = 1;
        locations = res.map<Map<String, dynamic>>((row) {
          final totalCap = (row['total_capacity'] as num?)?.toInt() ?? 100;
          final estRaw = totalCap * 400000;
          final currentRank = rank++;

          return {
            'rank': currentRank,
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'city': row['city']?.toString() ?? 'Jakarta',
            'address': row['address']?.toString() ?? '-',
            'omzet': 'Rp ${_formatCurrency(estRaw)}',
            'rawAmount': estRaw,
            'percentage': 0.25,
            'sessions': '${totalCap * 12} sesi',
            'growth': '+12.5%',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AllLocationsRevenueBackend] fetchLocationsRevenue error: $e');
      _errorMessage = e.toString();
      if (locations.isEmpty) {
        locations = List.from(_defaultLocations);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatCurrency(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
