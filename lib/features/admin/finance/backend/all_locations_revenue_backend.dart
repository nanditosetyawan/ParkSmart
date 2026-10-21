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

  List<Map<String, dynamic>> locations = [];

  /// Mengambil data omzet lokasi dari Supabase
  Future<void> fetchLocationsRevenue() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final locsRes = await _client
          .from('parking_locations')
          .select('id, name, city, address, total_capacity')
          .order('name', ascending: true);

      if (locsRes.isNotEmpty) {
        // Ambil sesi parkir untuk mengakumulasi pendapatan riil per lokasi
        List<dynamic> sessions = [];
        try {
          final sRes = await _client
              .from('parking_sessions')
              .select('location_id, total_fee, status');
          sessions = sRes;
        } catch (_) {}

        final Map<String, double> revenueMap = {};
        final Map<String, int> sessionCountMap = {};

        for (var s in sessions) {
          final locId = s['location_id']?.toString() ?? '';
          final fee = (s['total_fee'] as num?)?.toDouble() ?? 0.0;
          final status = s['status']?.toString().toLowerCase() ?? '';
          if (locId.isNotEmpty) {
            sessionCountMap[locId] = (sessionCountMap[locId] ?? 0) + 1;
            if (status == 'completed' || status == 'paid') {
              revenueMap[locId] = (revenueMap[locId] ?? 0.0) + fee;
            }
          }
        }

        final double totalAllRevenue = revenueMap.values.fold(0.0, (sum, val) => sum + val);

        final List<Map<String, dynamic>> computed = locsRes.map<Map<String, dynamic>>((row) {
          final id = row['id']?.toString() ?? '';
          final rev = revenueMap[id] ?? 0.0;
          final sessCount = sessionCountMap[id] ?? 0;
          final pct = totalAllRevenue > 0 ? (rev / totalAllRevenue) : 0.0;

          return {
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'city': row['city']?.toString() ?? 'Indonesia',
            'address': row['address']?.toString() ?? '-',
            'omzet': 'Rp ${_formatCurrency(rev.round())}',
            'rawAmount': rev,
            'percentage': pct,
            'sessions': '$sessCount sesi',
            'growth': '0.0%',
          };
        }).toList();

        // Urutkan berdasarkan omzet tertinggi
        computed.sort((a, b) => (b['rawAmount'] as num).compareTo(a['rawAmount'] as num));

        // Tambahkan peringkat
        for (int i = 0; i < computed.length; i++) {
          computed[i]['rank'] = i + 1;
        }

        locations = computed;
      } else {
        locations = [];
      }
    } catch (e) {
      debugPrint('[AllLocationsRevenueBackend] fetchLocationsRevenue error: $e');
      _errorMessage = e.toString();
      locations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatCurrency(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
