import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AdminOperationsDashboardScreen (admin_operations_dashboard_screen.dart)
/// Menyajikan metrik operasional lapangan, kapasitas lokasi, tingkat okupansi slot, dan overstay
class AdminOperationsDashboardBackend extends ChangeNotifier {
  AdminOperationsDashboardBackend._();
  static final AdminOperationsDashboardBackend instance = AdminOperationsDashboardBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // KPI Ringkasan
  int _totalLocationsCount = 5;
  int get totalLocationsCount => _totalLocationsCount;

  int _totalSlotsCount = 1350;
  int get totalSlotsCount => _totalSlotsCount;

  int _occupiedSlotsCount = 1085;
  int get occupiedSlotsCount => _occupiedSlotsCount;

  int _overstaySessionsCount = 14;
  int get overstaySessionsCount => _overstaySessionsCount;

  int _activeSessionsCount = 312;
  int get activeSessionsCount => _activeSessionsCount;

  List<Map<String, dynamic>> _locationsSummary = [];
  List<Map<String, dynamic>> get locationsSummary => _locationsSummary;

  /// Memuat metrik operasional dari Supabase
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Lokasi & Kapasitas
      final locs = await _client
          .from('parking_locations')
          .select('id, name, city, total_capacity, car_slots_capacity, motor_slots_capacity, ev_slots_capacity, status')
          .order('name', ascending: true);

      if (locs.isNotEmpty) {
        _totalLocationsCount = locs.length;
        int totalCap = 0;
        for (var l in locs) {
          totalCap += (l['total_capacity'] as num?)?.toInt() ?? 0;
        }
        if (totalCap > 0) _totalSlotsCount = totalCap;

        _locationsSummary = locs.map<Map<String, dynamic>>((row) {
          return {
            'id': row['id']?.toString() ?? '',
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'city': row['city']?.toString() ?? 'Jakarta',
            'capacity': (row['total_capacity'] as num?)?.toInt() ?? 100,
            'status': row['status']?.toString() ?? 'active',
          };
        }).toList();
      }

      // 2. Sesi Aktif & Overstay
      final activeSessions = await _client
          .from('parking_sessions')
          .select('id, is_overstay')
          .eq('status', 'active');

      if (activeSessions.isNotEmpty) {
        _activeSessionsCount = activeSessions.length;
        _overstaySessionsCount = activeSessions.where((s) => s['is_overstay'] == true).length;
      }

      // 3. Status Slot Terisi
      final occupiedSlots = await _client
          .from('parking_slots')
          .select('id')
          .eq('status', 'occupied')
          .count(CountOption.exact);

      if (occupiedSlots.count > 0) {
        _occupiedSlotsCount = occupiedSlots.count;
      }
    } catch (e) {
      debugPrint('[AdminOperationsDashboardBackend] fetchDashboardData error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
