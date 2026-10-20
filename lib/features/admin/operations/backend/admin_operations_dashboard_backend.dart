import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _SessionTimestampEvent {
  final DateTime wibTime;
  _SessionTimestampEvent(this.wibTime);
}

/// Backend khusus untuk AdminOperationsDashboardScreen (admin_operations_dashboard_screen.dart)
/// Menyajikan metrik operasional lapangan, kapasitas lokasi, tingkat okupansi slot, overstay,
/// dan grafik kendaraan parkir 4 minggu per bulan berbasis data riil Supabase & Waktu Server Indonesia WIB.
class AdminOperationsDashboardBackend extends ChangeNotifier {
  AdminOperationsDashboardBackend._();
  static final AdminOperationsDashboardBackend instance = AdminOperationsDashboardBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // KPI Ringkasan
  int _totalLocationsCount = 0;
  int get totalLocationsCount => _totalLocationsCount;

  int _totalSlotsCount = 0;
  int get totalSlotsCount => _totalSlotsCount;

  int _occupiedSlotsCount = 0;
  int get occupiedSlotsCount => _occupiedSlotsCount;

  int _overstaySessionsCount = 0;
  int get overstaySessionsCount => _overstaySessionsCount;

  int _activeSessionsCount = 0;
  int get activeSessionsCount => _activeSessionsCount;

  List<Map<String, dynamic>> _locationsSummary = [];
  List<Map<String, dynamic>> get locationsSummary => _locationsSummary;

  // 📈 Data Grafik Parkir 4 Minggu per Bulan (Maksimal 6 Bulan Terakhir dari Supabase)
  List<String> _availableMonths = [];
  List<String> get availableMonths => _availableMonths;

  final Map<String, Map<String, dynamic>> _monthlyChartData = {};
  Map<String, Map<String, dynamic>> get monthlyChartData => _monthlyChartData;

  /// Waktu saat ini dalam Waktu Indonesia Barat (WIB, UTC+7)
  DateTime get _nowWib => DateTime.now().toUtc().add(const Duration(hours: 7));

  DateTime _parseToWib(dynamic val) {
    if (val == null) return _nowWib;
    final dt = DateTime.tryParse(val.toString());
    if (dt == null) return _nowWib;
    return dt.toUtc().add(const Duration(hours: 7));
  }

  String _formatMonthYear(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  /// Memuat metrik operasional & chart kendaraan dari Supabase
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

      _totalLocationsCount = locs.length;
      int totalCap = 0;
      for (var l in locs) {
        totalCap += (l['total_capacity'] as num?)?.toInt() ?? 0;
      }
      _totalSlotsCount = totalCap;

      _locationsSummary = locs.map<Map<String, dynamic>>((row) {
        return {
          'id': row['id']?.toString() ?? '',
          'name': row['name']?.toString() ?? 'Lokasi Parkir',
          'city': row['city']?.toString() ?? 'Indonesia',
          'capacity': (row['total_capacity'] as num?)?.toInt() ?? 100,
          'status': row['status']?.toString() ?? 'active',
        };
      }).toList();

      // 2. Sesi Aktif & Overstay
      final activeSessions = await _client
          .from('parking_sessions')
          .select('id, is_overstay')
          .eq('status', 'active');

      _activeSessionsCount = activeSessions.length;
      _overstaySessionsCount = activeSessions.where((s) => s['is_overstay'] == true).length;

      // 3. Status Slot Terisi
      final occupiedSlots = await _client
          .from('parking_slots')
          .select('id')
          .eq('status', 'occupied')
          .count(CountOption.exact);

      _occupiedSlotsCount = occupiedSlots.count;

      // 4. Seluruh Sesi Parkir untuk Kalkulasi Chart 4 Minggu per Bulan
      final allSessionsRes = await _client
          .from('parking_sessions')
          .select('id, check_in_time, created_at')
          .order('created_at', ascending: false);

      final List<_SessionTimestampEvent> sessionEvents = [];
      for (final s in allSessionsRes) {
        final rawTs = s['check_in_time'] ?? s['created_at'];
        if (rawTs != null) {
          sessionEvents.add(_SessionTimestampEvent(_parseToWib(rawTs)));
        }
      }

      // Ambil daftar bulan unik yang ada datanya di database
      final Set<String> distinctMonthKeys = {};
      final List<DateTime> distinctMonthDates = [];

      for (final ev in sessionEvents) {
        final key = '${ev.wibTime.year}-${ev.wibTime.month.toString().padLeft(2, '0')}';
        if (!distinctMonthKeys.contains(key)) {
          distinctMonthKeys.add(key);
          distinctMonthDates.add(DateTime(ev.wibTime.year, ev.wibTime.month, 1));
        }
      }

      // Urutkan bulan dari yang terbaru (descending)
      distinctMonthDates.sort((a, b) => b.compareTo(a));

      // Aturan pengguna: "6 bulan terakhir dihitung dari saat ini, kalau kosong muncul kosong, jika ada 3 maka 3, kalau 8 ambil 6 terakhir"
      final targetMonths = distinctMonthDates.take(6).toList();
      _availableMonths = targetMonths.map((d) => _formatMonthYear(d)).toList();

      _monthlyChartData.clear();

      final now = _nowWib;

      for (final monthDate in targetMonths) {
        final monthLabel = _formatMonthYear(monthDate);
        final year = monthDate.year;
        final month = monthDate.month;

        final sessionsInMonth = sessionEvents.where((e) =>
            e.wibTime.year == year && e.wibTime.month == month).toList();

        // Tentukan batas minggu aktif berdasarkan waktu server WIB saat ini
        int availableWeeksCount = 4;
        if (year > now.year || (year == now.year && month > now.month)) {
          availableWeeksCount = 0; // Bulan di masa depan
        } else if (year == now.year && month == now.month) {
          // Bulan sedang berlangsung
          if (now.day < 8) {
            availableWeeksCount = 1;
          } else if (now.day < 15) {
            availableWeeksCount = 2;
          } else if (now.day < 22) {
            availableWeeksCount = 3;
          } else {
            availableWeeksCount = 4;
          }
        }

        // Kalkulasi 4 minggu diskrit (mandiri)
        int w1 = 0;
        int w2 = 0;
        int w3 = 0;
        int w4 = 0;

        for (final s in sessionsInMonth) {
          final day = s.wibTime.day;
          if (day >= 1 && day <= 7) {
            w1++;
          } else if (day >= 8 && day <= 14) {
            w2++;
          } else if (day >= 15 && day <= 21) {
            w3++;
          } else if (day >= 22) {
            w4++;
          }
        }

        final rawValues = [w1, w2, w3, w4];

        // Normalisasi chart
        final int maxVal = rawValues.fold(0, (m, v) => v > m ? v : m);
        final List<double> chartData = rawValues.map((v) {
          if (maxVal <= 0 || v <= 0) return 0.05;
          return 0.15 + (v / maxVal) * 0.80;
        }).toList();

        // Hitung persentase kenaikan/penurunan vs minggu sebelumnya
        final List<double> percentages = [0.0, 0.0, 0.0, 0.0];
        for (int i = 1; i < 4; i++) {
          final prev = rawValues[i - 1];
          final cur = rawValues[i];
          if (prev == 0) {
            percentages[i] = cur > 0 ? 100.0 : 0.0;
          } else {
            percentages[i] = ((cur - prev) / prev) * 100.0;
          }
        }

        final int latestWeekIndex = (availableWeeksCount > 0 ? availableWeeksCount - 1 : 0).clamp(0, 3);

        _monthlyChartData[monthLabel] = {
          'monthLabel': monthLabel,
          'availableWeeksCount': availableWeeksCount,
          'latestWeekIndex': latestWeekIndex,
          'rawValues': rawValues,
          'chartData': chartData,
          'pointValues': rawValues.map((v) => '$v Unit').toList(),
          'pointDates': [
            'Minggu 1 (Tgl 1-7)',
            'Minggu 2 (Tgl 8-14)',
            'Minggu 3 (Tgl 15-21)',
            'Minggu 4 (Tgl 22-Akhir)',
          ],
          'xLabels': ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'],
          'percentages': percentages,
        };
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
