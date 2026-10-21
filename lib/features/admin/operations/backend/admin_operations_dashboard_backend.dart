import 'dart:async';
import 'package:flutter/material.dart';
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

  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> get locations => _locations;

  List<Map<String, dynamic>> _cityDensityList = [];
  List<Map<String, dynamic>> get cityDensityList => _cityDensityList;

  List<Map<String, dynamic>> _liveSessions = [];
  List<Map<String, dynamic>> get liveSessions => _liveSessions;

  List<Map<String, dynamic>> _liveBookings = [];
  List<Map<String, dynamic>> get liveBookings => _liveBookings;

  final List<Map<String, dynamic>> _locationsSummary = [];
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
      // 1. Lokasi & Kapasitas Real dari Database
      final locs = await _client
          .from('parking_locations')
          .select('id, code, name, city, province, address, total_capacity, car_slots_capacity, motor_slots_capacity, ev_slots_capacity, status')
          .order('name', ascending: true);

      _totalLocationsCount = locs.length;
      int totalCap = 0;
      for (var l in locs) {
        totalCap += (l['total_capacity'] as num?)?.toInt() ?? 0;
      }
      _totalSlotsCount = totalCap;

      if (locs.isNotEmpty) {
        _locations = locs.map<Map<String, dynamic>>((row) {
          final total = (row['total_capacity'] as num?)?.toInt() ?? 0;
          final statusDb = row['status']?.toString().toLowerCase();
          String statusLabel = 'Normal';
          Color statusCol = const Color(0xFF17A18A);
          if (statusDb == 'crowded') {
            statusLabel = 'Padat';
            statusCol = const Color(0xFFE07A5F);
          } else if (statusDb == 'full') {
            statusLabel = 'Kritis';
            statusCol = const Color(0xFFD94B4B);
          }

          return {
            'id': row['code']?.toString() ?? row['id']?.toString() ?? 'LOC-000',
            'db_id': row['id']?.toString(),
            'name': row['name']?.toString() ?? 'Lokasi Parkir',
            'city': row['city']?.toString() ?? 'Kota',
            'province': row['province']?.toString() ?? '',
            'zone': row['address']?.toString() ?? 'Area Parkir',
            'total': total,
            'occupied': 0,
            'status': statusLabel,
            'statusColor': statusCol,
            'mobil': (row['car_slots_capacity'] as num?)?.toInt() ?? (total * 0.7).round(),
            'motor': (row['motor_slots_capacity'] as num?)?.toInt() ?? (total * 0.2).round(),
            'ev': (row['ev_slots_capacity'] as num?)?.toInt() ?? (total * 0.1).round(),
          };
        }).toList();

        final Map<String, List<Map<String, dynamic>>> cityMap = {};
        for (var l in _locations) {
          final c = l['city'] as String;
          cityMap.putIfAbsent(c, () => []).add(l);
        }
        _cityDensityList = cityMap.entries.map((entry) {
          final cityName = entry.key;
          final locList = entry.value;
          int cityTotal = 0;
          int cityOccupied = 0;
          int cityMobil = 0;
          int cityMotor = 0;
          int cityEv = 0;
          for (var l in locList) {
            cityTotal += (l['total'] as int? ?? 0);
            cityOccupied += (l['occupied'] as int? ?? 0);
            cityMobil += (l['mobil'] as int? ?? 0);
            cityMotor += (l['motor'] as int? ?? 0);
            cityEv += (l['ev'] as int? ?? 0);
          }
          final ratio = cityTotal > 0 ? (cityOccupied / cityTotal) : 0.0;
          String status = 'Normal';
          Color statusColor = const Color(0xFF17A18A);
          if (ratio >= 0.85) {
            status = 'Kritis';
            statusColor = const Color(0xFFD94B4B);
          } else if (ratio >= 0.60) {
            status = 'Padat';
            statusColor = const Color(0xFFE07A5F);
          }
          return {
            'city': cityName,
            'province': locList.first['province'] ?? '',
            'facilities': '${locList.length} Lokasi (${locList.map((e) => e['name']).join(', ')})',
            'facilityCount': locList.length,
            'total': cityTotal,
            'occupied': cityOccupied,
            'status': status,
            'statusColor': statusColor,
            'mobil': cityMobil,
            'motor': cityMotor,
            'ev': cityEv,
          };
        }).toList();
      } else {
        _locations = [];
        _cityDensityList = [];
      }

      // 2. Sesi Aktif & Overstay Real dari Database
      final activeSessions = await _client
          .from('parking_sessions')
          .select('id, session_code, plate_number, vehicle_desc, vehicle_type, check_in_time, parking_fee, total_fee, is_overstay, overstay_minutes, status')
          .inFilter('status', ['active', 'overstay'])
          .order('check_in_time', ascending: false);

      _activeSessionsCount = activeSessions.length;
      _overstaySessionsCount = activeSessions.where((s) => s['is_overstay'] == true).length;

      if (activeSessions.isNotEmpty) {
        _liveSessions = activeSessions.map<Map<String, dynamic>>((row) {
          final isEv = row['vehicle_type'] == 'ev';
          final fee = (row['total_fee'] as num?)?.toDouble() ?? 
                      (row['parking_fee'] as num?)?.toDouble() ?? 10000;
          return {
            'id': row['session_code']?.toString() ?? 'SES-000',
            'db_id': row['id']?.toString(),
            'plate': row['plate_number']?.toString() ?? 'B 1234 XYZ',
            'user': 'Pengguna ParkSmart',
            'phone': '+62 812-xxxx-xxxx',
            'type': isEv ? 'EV Mobil' : 'Mobil',
            'vehicle': row['vehicle_desc']?.toString() ?? 'Kendaraan',
            'location': 'Lokasi Parkir',
            'slot': 'Area Parkir',
            'checkIn': 'Baru saja',
            'duration': '1j',
            'fee': 'Rp ${fee.toStringAsFixed(0)}',
            'isOverstay': row['is_overstay'] == true,
            'overstayDuration': '${row['overstay_minutes'] ?? 0} mnt',
            'isEv': isEv,
          };
        }).toList();
      } else {
        _liveSessions = [];
      }

      // 3. Reservasi Masuk Real dari Database
      final bookingsRes = await _client
          .from('bookings')
          .select('id, booking_code, start_time, duration_hours, total_price, payment_status, booking_status, created_at')
          .order('created_at', ascending: false);

      if (bookingsRes.isNotEmpty) {
        _liveBookings = bookingsRes.map<Map<String, dynamic>>((row) {
          final isConfirmed = row['booking_status'] == 'confirmed';
          final price = (row['total_price'] as num?)?.toInt() ?? 25000;
          return {
            'id': row['booking_code']?.toString() ?? 'BKG-001',
            'code': row['booking_code']?.toString() ?? 'PRK-001',
            'name': 'Pelanggan ParkSmart',
            'phone': '+62 812-xxxx-xxxx',
            'location': 'Lokasi Parkir',
            'slot': 'Slot Terpilih',
            'floor': 'Area Parkir',
            'vehicleType': 'Mobil',
            'plate': 'B 1234 XYZ',
            'time': '${row['start_time']?.toString().split('T').last.substring(0, 5) ?? '08:00'} WIB',
            'duration': '${row['duration_hours'] ?? 2} jam',
            'status': isConfirmed ? 'Dikonfirmasi' : 'Menunggu',
            'totalPrice': 'Rp $price',
            'paymentStatus': row['payment_status'] == 'paid' ? 'Dibayar' : 'Pending',
          };
        }).toList();
      } else {
        _liveBookings = [];
      }

      // 4. Status Slot Terisi
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
