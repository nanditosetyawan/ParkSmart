import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _ChartRawEvent {
  final DateTime wibTime;
  final double value;
  _ChartRawEvent(this.wibTime, this.value);
}

/// Backend khusus untuk AdminDashboardScreen
/// Mengumpulkan metrik KPI Super Admin lintas divisi dari Supabase:
/// - Users, Parking Sessions, Payments, Bookings, User KYC, Parking Locations
/// - Kalkulasi chart analitik real-time berbasis Waktu Indonesia Barat (WIB / UTC+7)
class AdminDashboardBackend extends ChangeNotifier {
  AdminDashboardBackend._() {
    _divisionalMetrics = _buildInitialDivisionalMetrics();
  }
  static final AdminDashboardBackend instance = AdminDashboardBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _autoRefreshTimer;

  // KPI Metrics
  int _totalUsersCount = 0;
  int get totalUsersCount => _totalUsersCount;

  int _activeSessionsCount = 0;
  int get activeSessionsCount => _activeSessionsCount;

  double _todayRevenue = 0;
  double get todayRevenue => _todayRevenue;

  int _todayBookingsCount = 0;
  int get todayBookingsCount => _todayBookingsCount;

  int _pendingKycCount = 0;
  int get pendingKycCount => _pendingKycCount;

  int _activeLocationsCount = 0;
  int get activeLocationsCount => _activeLocationsCount;

  // Pending KYC List for Quick Review Widget (Kosong jika tidak ada antrean)
  List<Map<String, dynamic>> _pendingKycList = [];
  List<Map<String, dynamic>> get pendingKycList => _pendingKycList;

  // Real-Time Calculated Divisional Metrics for Mountain Chart
  late List<Map<String, dynamic>> _divisionalMetrics;
  List<Map<String, dynamic>> get divisionalMetrics => _divisionalMetrics;

  /// Waktu saat ini dalam Waktu Indonesia Barat (WIB, UTC+7)
  DateTime get _nowWib => DateTime.now().toUtc().add(const Duration(hours: 7));

  DateTime _parseToWib(dynamic val) {
    if (val == null) return _nowWib;
    final dt = DateTime.tryParse(val.toString());
    if (dt == null) return _nowWib;
    return dt.toUtc().add(const Duration(hours: 7));
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Baru saja';
    try {
      final date = DateTime.tryParse(timestamp.toString());
      if (date == null) return 'Baru saja';
      final diff = DateTime.now().difference(date);
      if (diff.isNegative || diff.inSeconds < 60) {
        return 'Baru saja';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} menit lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} jam lalu';
      } else if (diff.inDays < 30) {
        return '${diff.inDays} hari lalu';
      } else if (diff.inDays < 365) {
        final months = (diff.inDays / 30).floor();
        return '$months bulan lalu';
      } else {
        final years = (diff.inDays / 365).floor();
        return '$years tahun lalu';
      }
    } catch (_) {
      return 'Baru saja';
    }
  }

  /// Mulai polling berkala agar chart 1 Hari, 1 Minggu, 1 Bulan, dan 1 Tahun
  /// terus sinkron dengan waktu server WIB secara otomatis.
  void startPeriodicMetrics() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchDashboardMetrics(silent: true);
    });
  }

  void stopPeriodicMetrics() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Memuat metrik & ringkasan dari Supabase
  Future<void> fetchDashboardMetrics({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      // 1. Total Users
      final usersRes = await _client
          .from('users')
          .select('id, created_at')
          .order('created_at', ascending: true);
      _totalUsersCount = usersRes.length;

      // 2. Active Sessions & All Sessions
      final sessionsRes = await _client
          .from('parking_sessions')
          .select('id, total_fee, created_at, status')
          .order('created_at', ascending: true);
      
      _activeSessionsCount = sessionsRes
          .where((s) => s['status']?.toString().toLowerCase() == 'active')
          .length;

      // 3. Pending KYC
      final kycRes = await _client
          .from('user_kyc')
          .select('id, user_id, full_name, nik, birth_place_city, birth_date, address, submitted_at, status, ktp_image_url, selfie_image_url, gender')
          .eq('status', 'pending')
          .order('submitted_at', ascending: false);

      _pendingKycCount = kycRes.length;
      _pendingKycList = kycRes.map<Map<String, dynamic>>((row) {
        return {
          'id': row['id']?.toString() ?? 'KYC-001',
          'user_id': row['user_id']?.toString(),
          'name': row['full_name']?.toString() ?? 'Pengguna',
          'nik': row['nik']?.toString() ?? '-',
          'submittedAt': _formatTimeAgo(row['submitted_at']),
          'status': 'Menunggu',
          'city': row['birth_place_city']?.toString() ?? 'Indonesia',
          'dob': row['birth_date']?.toString() ?? '-',
          'address': row['address']?.toString() ?? '-',
          'gender': (row['gender']?.toString() ?? 'LAKI-LAKI').toUpperCase(),
          'ktp_image_url': row['ktp_image_url'],
          'selfie_image_url': row['selfie_image_url'],
        };
      }).toList();

      // 4. Locations Count
      final locRes = await _client
          .from('parking_locations')
          .select('id')
          .eq('status', 'active')
          .count(CountOption.exact);
      _activeLocationsCount = locRes.count;

      // 5. Payments & Bookings
      final paymentRes = await _client
          .from('payments')
          .select('amount, created_at, status')
          .order('created_at', ascending: true);

      final bookingRes = await _client
          .from('bookings')
          .select('id, total_price, created_at, payment_status')
          .order('created_at', ascending: true);

      // Hitung Pendapatan Hari Ini
      final now = _nowWib;
      double todayIncome = 0;
      for (final p in paymentRes) {
        final st = p['status']?.toString().toLowerCase();
        if (st == 'success' || st == 'completed' || st == 'settlement') {
          final wib = _parseToWib(p['created_at']);
          if (wib.year == now.year && wib.month == now.month && wib.day == now.day) {
            todayIncome += (p['amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }
      _todayRevenue = todayIncome;

      // Hitung Total Booking Hari Ini
      int todayBk = 0;
      for (final b in bookingRes) {
        final wib = _parseToWib(b['created_at']);
        if (wib.year == now.year && wib.month == now.month && wib.day == now.day) {
          todayBk++;
        }
      }
      _todayBookingsCount = todayBk;

      // ─────────────────────────────────────────────────────────────
      // PROSES DATA RAW UNTUK GRAFIK ANALITIK 3 METRIK
      // ─────────────────────────────────────────────────────────────

      // A. Events Pendapatan
      final List<_ChartRawEvent> revenueEvents = [];
      for (final p in paymentRes) {
        final st = p['status']?.toString().toLowerCase();
        if (st == 'success' || st == 'completed' || st == 'settlement' || st == 'paid') {
          final amt = (p['amount'] as num?)?.toDouble() ?? 0.0;
          revenueEvents.add(_ChartRawEvent(_parseToWib(p['created_at']), amt));
        }
      }
      // Jika pembayaran masih kosong, ambil dari total_fee parkir selesai sebagai fallback
      if (revenueEvents.isEmpty) {
        for (final s in sessionsRes) {
          final fee = (s['total_fee'] as num?)?.toDouble() ?? 0.0;
          if (fee > 0) {
            revenueEvents.add(_ChartRawEvent(_parseToWib(s['created_at']), fee));
          }
        }
      }

      // B. Events Total Transaksi (Kombinasi Booking & Sesi Parkir)
      final List<_ChartRawEvent> transactionEvents = [];
      for (final s in sessionsRes) {
        transactionEvents.add(_ChartRawEvent(_parseToWib(s['created_at']), 1.0));
      }
      for (final b in bookingRes) {
        transactionEvents.add(_ChartRawEvent(_parseToWib(b['created_at']), 1.0));
      }

      // C. Events Customer Aktif / Registrasi
      final List<_ChartRawEvent> customerEvents = [];
      for (final u in usersRes) {
        customerEvents.add(_ChartRawEvent(_parseToWib(u['created_at']), 1.0));
      }

      // Bangun metrik terintegrasi untuk 3 pilihan chart:
      // 0: Pendapatan, 1: Total, 2: Customer
      _divisionalMetrics = [
        {
          'title': 'Pendapatan Global',
          'division': 'Divisi Finansial',
          'accentColor': const Color(0xFF17A18A),
          'icon': Icons.trending_up,
          'periods': _computePeriodsForMetric(
            events: revenueEvents,
            metricType: 0,
          ),
        },
        {
          'title': 'Total Transaksi',
          'division': 'Divisi Finansial',
          'accentColor': const Color(0xFF114177),
          'icon': Icons.book_online,
          'periods': _computePeriodsForMetric(
            events: transactionEvents,
            metricType: 1,
          ),
        },
        {
          'title': 'Customer Aktif',
          'division': 'Divisi Customer Service (CS)',
          'accentColor': const Color(0xFF6D28D9),
          'icon': Icons.people_outline,
          'periods': _computePeriodsForMetric(
            events: customerEvents,
            metricType: 2,
          ),
        },
      ];
    } catch (e) {
      debugPrint('[AdminDashboardBackend] fetchDashboardMetrics error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menghitung 4 periode (1 Hari, 1 Minggu, 1 Bulan, 1 Tahun) secara diskrit
  /// berdasarkan waktu server Indonesia WIB (UTC+7).
  List<Map<String, dynamic>> _computePeriodsForMetric({
    required List<_ChartRawEvent> events,
    required int metricType, // 0: Pendapatan, 1: Total, 2: Customer
  }) {
    final now = _nowWib;

    // ─────────────────────────────────────────────────────────────
    // 0: TAB 1 HARI (7 Checkpoint: 00:00, 04:00, 08:00, 12:00, 16:00, 20:00, 23:59)
    // ─────────────────────────────────────────────────────────────
    final List<double> dayRaw = List.filled(7, 0.0);
    final todayEvents = events.where((e) =>
        e.wibTime.year == now.year &&
        e.wibTime.month == now.month &&
        e.wibTime.day == now.day).toList();

    // Sesi 00:00 (10 Menit Pertama: 00:00 - 00:10 WIB)
    // Selama 10 menit jika ada data masuk dijumlah dan langsung ditampilkan.
    // Jika lewat 10 menit maka stop (nilai dibekukan pada total 10 menit tersebut).
    for (final e in todayEvents) {
      if (e.wibTime.hour == 0 && e.wibTime.minute <= 10) {
        if (now.hour == 0 && now.minute <= 10) {
          if (e.wibTime.minute <= now.minute) {
            dayRaw[0] += e.value;
          }
        } else {
          dayRaw[0] += e.value;
        }
      }
    }

    // Sesi 04:00 (Menjumlah semua dari 10 menit setelah 00:00 sampai 04:00)
    if (now.hour > 0 || (now.hour == 0 && now.minute > 10)) {
      for (final e in todayEvents) {
        final isAfter10Min = (e.wibTime.hour > 0) || (e.wibTime.hour == 0 && e.wibTime.minute > 10);
        final isBefore04 = e.wibTime.hour < 4 || (e.wibTime.hour == 4 && e.wibTime.minute == 0);
        if (isAfter10Min && isBefore04) {
          if (now.hour < 4) {
            if (e.wibTime.isBefore(now) || e.wibTime.isAtSameMomentAs(now)) {
              dayRaw[1] += e.value;
            }
          } else {
            dayRaw[1] += e.value;
          }
        }
      }
    }

    // Sesi 08:00 (04:00 sampai 08:00 saja secara diskrit)
    if (now.hour >= 4) {
      for (final e in todayEvents) {
        final isAfter04 = e.wibTime.hour > 4 || (e.wibTime.hour == 4 && e.wibTime.minute > 0);
        final isBefore08 = e.wibTime.hour < 8 || (e.wibTime.hour == 8 && e.wibTime.minute == 0);
        if (isAfter04 && isBefore08) {
          if (now.hour < 8) {
            if (e.wibTime.isBefore(now) || e.wibTime.isAtSameMomentAs(now)) {
              dayRaw[2] += e.value;
            }
          } else {
            dayRaw[2] += e.value;
          }
        }
      }
    }

    // Sesi 12:00 (08:00 sampai 12:00 saja)
    if (now.hour >= 8) {
      for (final e in todayEvents) {
        final isAfter08 = e.wibTime.hour > 8 || (e.wibTime.hour == 8 && e.wibTime.minute > 0);
        final isBefore12 = e.wibTime.hour < 12 || (e.wibTime.hour == 12 && e.wibTime.minute == 0);
        if (isAfter08 && isBefore12) {
          if (now.hour < 12) {
            if (e.wibTime.isBefore(now) || e.wibTime.isAtSameMomentAs(now)) {
              dayRaw[3] += e.value;
            }
          } else {
            dayRaw[3] += e.value;
          }
        }
      }
    }

    // Sesi 16:00 (12:00 sampai 16:00 saja)
    if (now.hour >= 12) {
      for (final e in todayEvents) {
        final isAfter12 = e.wibTime.hour > 12 || (e.wibTime.hour == 12 && e.wibTime.minute > 0);
        final isBefore16 = e.wibTime.hour < 16 || (e.wibTime.hour == 16 && e.wibTime.minute == 0);
        if (isAfter12 && isBefore16) {
          if (now.hour < 16) {
            if (e.wibTime.isBefore(now) || e.wibTime.isAtSameMomentAs(now)) {
              dayRaw[4] += e.value;
            }
          } else {
            dayRaw[4] += e.value;
          }
        }
      }
    }

    // Sesi 20:00 (16:00 sampai 20:00 saja)
    if (now.hour >= 16) {
      for (final e in todayEvents) {
        final isAfter16 = e.wibTime.hour > 16 || (e.wibTime.hour == 16 && e.wibTime.minute > 0);
        final isBefore20 = e.wibTime.hour < 20 || (e.wibTime.hour == 20 && e.wibTime.minute == 0);
        if (isAfter16 && isBefore20) {
          if (now.hour < 20) {
            if (e.wibTime.isBefore(now) || e.wibTime.isAtSameMomentAs(now)) {
              dayRaw[5] += e.value;
            }
          } else {
            dayRaw[5] += e.value;
          }
        }
      }
    }

    // Sesi 23:59 (20:00 sampai 23:59 saja)
    if (now.hour >= 20) {
      for (final e in todayEvents) {
        final isAfter20 = e.wibTime.hour > 20 || (e.wibTime.hour == 20 && e.wibTime.minute > 0);
        if (isAfter20) {
          if (e.wibTime.isBefore(now) || e.wibTime.isAtSameMomentAs(now)) {
            dayRaw[6] += e.value;
          }
        }
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 1: TAB 1 MINGGU (7 Hari: Sen, Sel, Rab, Kam, Jum, Sab, Min)
    // Tunggu hari selesai baru diambil per hari tanpa ditambah hari sebelumnya.
    // ─────────────────────────────────────────────────────────────
    final List<double> weekRaw = List.filled(7, 0.0);
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    for (int d = 0; d < 7; d++) {
      if (d + 1 > now.weekday) {
        weekRaw[d] = 0.0; // Hari belum berlangsung
      } else {
        final targetDate = monday.add(Duration(days: d));
        double daySum = 0;
        for (final e in events) {
          if (e.wibTime.year == targetDate.year &&
              e.wibTime.month == targetDate.month &&
              e.wibTime.day == targetDate.day) {
            daySum += e.value;
          }
        }
        weekRaw[d] = daySum; // Nilai mandiri hari tersebut
      }
    }

    // ─────────────────────────────────────────────────────────────
    // 2: TAB 1 BULAN (4 Titik: 01, 02, 03, 04 Per Minggu)
    // Nunggu 1 minggu ada berapa ditotal lalu dimunculkan minggu ke-2
    // khusus ke-2 tanpa ditotal dengan minggu pertama.
    // ─────────────────────────────────────────────────────────────
    final List<double> monthRaw = List.filled(4, 0.0);
    final thisMonthEvents = events.where((e) =>
        e.wibTime.year == now.year && e.wibTime.month == now.month).toList();

    // Minggu 1: Tgl 1 - 7
    if (now.day >= 1) {
      double w1 = 0;
      for (final e in thisMonthEvents) {
        if (e.wibTime.day >= 1 && e.wibTime.day <= 7) {
          w1 += e.value;
        }
      }
      monthRaw[0] = w1;
    }

    // Minggu 2: Tgl 8 - 14 (Khusus minggu ke-2)
    if (now.day >= 8) {
      double w2 = 0;
      for (final e in thisMonthEvents) {
        if (e.wibTime.day >= 8 && e.wibTime.day <= 14) {
          w2 += e.value;
        }
      }
      monthRaw[1] = w2;
    }

    // Minggu 3: Tgl 15 - 21 (Khusus minggu ke-3)
    if (now.day >= 15) {
      double w3 = 0;
      for (final e in thisMonthEvents) {
        if (e.wibTime.day >= 15 && e.wibTime.day <= 21) {
          w3 += e.value;
        }
      }
      monthRaw[2] = w3;
    }

    // Minggu 4: Tgl 22 - Akhir Bulan (Khusus minggu ke-4)
    if (now.day >= 22) {
      double w4 = 0;
      for (final e in thisMonthEvents) {
        if (e.wibTime.day >= 22) {
          w4 += e.value;
        }
      }
      monthRaw[3] = w4;
    }

    // ─────────────────────────────────────────────────────────────
    // 3: TAB 1 TAHUN (4 Titik: Q1, Q2, Q3, Q4)
    // Nunggu 1 Kuartal selesai baru ditampilkan secara mandiri.
    // ─────────────────────────────────────────────────────────────
    final List<double> yearRaw = List.filled(4, 0.0);
    final thisYearEvents = events.where((e) => e.wibTime.year == now.year).toList();

    // Q1: Bulan 1 - 3 (Jan - Mar)
    if (now.month >= 1) {
      double q1 = 0;
      for (final e in thisYearEvents) {
        if (e.wibTime.month >= 1 && e.wibTime.month <= 3) {
          q1 += e.value;
        }
      }
      yearRaw[0] = q1;
    }

    // Q2: Bulan 4 - 6 (Apr - Jun, khusus Q2)
    if (now.month >= 4) {
      double q2 = 0;
      for (final e in thisYearEvents) {
        if (e.wibTime.month >= 4 && e.wibTime.month <= 6) {
          q2 += e.value;
        }
      }
      yearRaw[1] = q2;
    }

    // Q3: Bulan 7 - 9 (Jul - Sep, khusus Q3)
    if (now.month >= 7) {
      double q3 = 0;
      for (final e in thisYearEvents) {
        if (e.wibTime.month >= 7 && e.wibTime.month <= 9) {
          q3 += e.value;
        }
      }
      yearRaw[2] = q3;
    }

    // Q4: Bulan 10 - 12 (Okt - Des, khusus Q4)
    if (now.month >= 10) {
      double q4 = 0;
      for (final e in thisYearEvents) {
        if (e.wibTime.month >= 10 && e.wibTime.month <= 12) {
          q4 += e.value;
        }
      }
      yearRaw[3] = q4;
    }

    // Format dan gabungkan ke dalam 4 period dictionary
    return [
      _formatPeriodPayload(
        periodIndex: 0,
        rawValues: dayRaw,
        metricType: metricType,
        xLabels: ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'],
        pointDates: ['00:00 WIB', '04:00 WIB', '08:00 WIB', '12:00 WIB', '16:00 WIB', '20:00 WIB', '23:59 WIB'],
      ),
      _formatPeriodPayload(
        periodIndex: 1,
        rawValues: weekRaw,
        metricType: metricType,
        xLabels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
        pointDates: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
      ),
      _formatPeriodPayload(
        periodIndex: 2,
        rawValues: monthRaw,
        metricType: metricType,
        xLabels: ['01', '02', '03', '04'],
        pointDates: [
          'Minggu 01 (Tgl 1-7)',
          'Minggu 02 (Tgl 8-14)',
          'Minggu 03 (Tgl 15-21)',
          'Minggu 04 (Tgl 22-Akhir)',
        ],
      ),
      _formatPeriodPayload(
        periodIndex: 3,
        rawValues: yearRaw,
        metricType: metricType,
        xLabels: ['Q1', 'Q2', 'Q3', 'Q4'],
        pointDates: [
          'Kuartal 1 (Jan - Mar)',
          'Kuartal 2 (Apr - Jun)',
          'Kuartal 3 (Jul - Sep)',
          'Kuartal 4 (Okt - Des)',
        ],
      ),
    ];
  }

  Map<String, dynamic> _formatPeriodPayload({
    required int periodIndex,
    required List<double> rawValues,
    required int metricType,
    required List<String> xLabels,
    required List<String> pointDates,
  }) {
    final double total = rawValues.fold(0.0, (s, v) => s + v);

    // Hitung indeks data terakhir yang memiliki nilai > 0
    int lastDataIndex = -1;
    for (int i = rawValues.length - 1; i >= 0; i--) {
      if (rawValues[i] > 0) {
        lastDataIndex = i;
        break;
      }
    }

    // activePointCount:
    // - 0 jika semua data kosong (lastDataIndex == -1)
    // - 1 jika hanya ada 1 titik pertama yang ada data (lastDataIndex == 0)
    // - 2 jika ada titik 0 dan 1 (lastDataIndex == 1)
    // - dst (lastDataIndex + 1)
    final int activePointCount = lastDataIndex >= 0 ? (lastDataIndex + 1) : 0;

    // Normalisasi curve antara 0.0 s/d 0.95
    final double maxVal = rawValues.fold(0.0, (m, v) => v > m ? v : m);
    final List<double> chartData = rawValues.map((v) {
      if (maxVal <= 0 || v <= 0) return 0.0; // 0.0 tepat di garis dasar / baselineY
      if (activePointCount == 1) return 0.50; // Titik tunggal tampil di ketinggian sedang (posisi ga dibawah)
      return 0.15 + (v / maxVal) * 0.80;
    }).toList();

    // Format string untuk setiap titik kursor
    final List<String> pointValues = rawValues.map((v) {
      if (metricType == 0) {
        return _formatCurrencyPoint(v);
      } else if (metricType == 1) {
        return '${v.toInt()} tx';
      } else {
        return '${v.toInt()} User';
      }
    }).toList();

    // Header value utama
    String headerValue;
    if (metricType == 0) {
      headerValue = _formatRupiah(total);
    } else if (metricType == 1) {
      headerValue = '${_formatNumber(total.toInt())} Transaksi';
    } else {
      headerValue = '${_formatNumber(total.toInt())} Pengguna';
    }

    // Growth percentage calculation
    String growth = '+0%';
    if (activePointCount >= 2) {
      final prevVal = rawValues[activePointCount - 2];
      final currVal = rawValues[activePointCount - 1];
      if (prevVal > 0) {
        final pct = ((currVal - prevVal) / prevVal) * 100;
        growth = '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%';
      } else if (currVal > 0) {
        growth = '+100%';
      } else {
        growth = '+0%';
      }
    } else if (activePointCount == 1) {
      growth = '+100%';
    }

    return {
      'value': headerValue,
      'growth': growth,
      'chartData': chartData,
      'rawValues': rawValues,
      'activePointCount': activePointCount,
      'pointValues': pointValues,
      'pointDates': pointDates,
      'xLabels': xLabels,
    };
  }

  // ─────────────────────────────────────────────────────────────
  // FORMATTING UTILITIES (MANDIRI / TANPA DEPENDENCY TAMBAHAN)
  // ─────────────────────────────────────────────────────────────

  String _formatCurrencyPoint(double val) {
    if (val <= 0) return 'Rp 0';
    if (val >= 1000000000) return 'Rp ${(val / 1000000000).toStringAsFixed(1)} M';
    if (val >= 1000000) return 'Rp ${(val / 1000000).toStringAsFixed(1)} Jt';
    if (val >= 1000) return 'Rp ${(val / 1000).toStringAsFixed(0)} Rb';
    return 'Rp ${val.toInt()}';
  }

  String _formatRupiah(num val) {
    if (val <= 0) return 'Rp 0';
    final s = val.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  String _formatNumber(int val) {
    if (val <= 0) return '0';
    final s = val.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  /// Template default sebelum data Supabase dimuat
  List<Map<String, dynamic>> _buildInitialDivisionalMetrics() {
    return [
      {
        'title': 'Pendapatan Global',
        'division': 'Divisi Finansial',
        'accentColor': const Color(0xFF17A18A),
        'icon': Icons.trending_up,
        'periods': [
          // 0: 1 Hari (7 titik)
          {
            'value': 'Rp 0',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'],
            'pointDates': ['00:00 WIB', '04:00 WIB', '08:00 WIB', '12:00 WIB', '16:00 WIB', '20:00 WIB', '23:59 WIB'],
            'xLabels': ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'],
          },
          // 1: 1 Minggu (7 titik)
          {
            'value': 'Rp 0',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'],
            'pointDates': ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
            'xLabels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
          },
          // 2: 1 Bulan (4 titik per minggu: 01, 02, 03, 04)
          {
            'value': 'Rp 0',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'],
            'pointDates': [
              'Minggu 01 (Tgl 1-7)',
              'Minggu 02 (Tgl 8-14)',
              'Minggu 03 (Tgl 15-21)',
              'Minggu 04 (Tgl 22-Akhir)',
            ],
            'xLabels': ['01', '02', '03', '04'],
          },
          // 3: 1 Tahun (4 titik per kuartal: Q1, Q2, Q3, Q4)
          {
            'value': 'Rp 0',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'],
            'pointDates': [
              'Kuartal 1 (Jan - Mar)',
              'Kuartal 2 (Apr - Jun)',
              'Kuartal 3 (Jul - Sep)',
              'Kuartal 4 (Okt - Des)',
            ],
            'xLabels': ['Q1', 'Q2', 'Q3', 'Q4'],
          },
        ],
      },
      {
        'title': 'Total Transaksi',
        'division': 'Divisi Finansial',
        'accentColor': const Color(0xFF114177),
        'icon': Icons.book_online,
        'periods': [
          {
            'value': '0 Transaksi',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 tx', '0 tx', '0 tx', '0 tx', '0 tx', '0 tx', '0 tx'],
            'pointDates': ['00:00 WIB', '04:00 WIB', '08:00 WIB', '12:00 WIB', '16:00 WIB', '20:00 WIB', '23:59 WIB'],
            'xLabels': ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'],
          },
          {
            'value': '0 Transaksi',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 tx', '0 tx', '0 tx', '0 tx', '0 tx', '0 tx', '0 tx'],
            'pointDates': ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
            'xLabels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
          },
          {
            'value': '0 Transaksi',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 tx', '0 tx', '0 tx', '0 tx'],
            'pointDates': [
              'Minggu 01 (Tgl 1-7)',
              'Minggu 02 (Tgl 8-14)',
              'Minggu 03 (Tgl 15-21)',
              'Minggu 04 (Tgl 22-Akhir)',
            ],
            'xLabels': ['01', '02', '03', '04'],
          },
          {
            'value': '0 Transaksi',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 tx', '0 tx', '0 tx', '0 tx'],
            'pointDates': [
              'Kuartal 1 (Jan - Mar)',
              'Kuartal 2 (Apr - Jun)',
              'Kuartal 3 (Jul - Sep)',
              'Kuartal 4 (Okt - Des)',
            ],
            'xLabels': ['Q1', 'Q2', 'Q3', 'Q4'],
          },
        ],
      },
      {
        'title': 'Customer Aktif',
        'division': 'Divisi Customer Service (CS)',
        'accentColor': const Color(0xFF6D28D9),
        'icon': Icons.people_outline,
        'periods': [
          {
            'value': '0 Pengguna',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 User', '0 User', '0 User', '0 User', '0 User', '0 User', '0 User'],
            'pointDates': ['00:00 WIB', '04:00 WIB', '08:00 WIB', '12:00 WIB', '16:00 WIB', '20:00 WIB', '23:59 WIB'],
            'xLabels': ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59'],
          },
          {
            'value': '0 Pengguna',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 User', '0 User', '0 User', '0 User', '0 User', '0 User', '0 User'],
            'pointDates': ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
            'xLabels': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
          },
          {
            'value': '0 Pengguna',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 User', '0 User', '0 User', '0 User'],
            'pointDates': [
              'Minggu 01 (Tgl 1-7)',
              'Minggu 02 (Tgl 8-14)',
              'Minggu 03 (Tgl 15-21)',
              'Minggu 04 (Tgl 22-Akhir)',
            ],
            'xLabels': ['01', '02', '03', '04'],
          },
          {
            'value': '0 Pengguna',
            'growth': '+0%',
            'chartData': [0.0, 0.0, 0.0, 0.0],
            'rawValues': [0.0, 0.0, 0.0, 0.0],
            'activePointCount': 0,
            'pointValues': ['0 User', '0 User', '0 User', '0 User'],
            'pointDates': [
              'Kuartal 1 (Jan - Mar)',
              'Kuartal 2 (Apr - Jun)',
              'Kuartal 3 (Jul - Sep)',
              'Kuartal 4 (Okt - Des)',
            ],
            'xLabels': ['Q1', 'Q2', 'Q3', 'Q4'],
          },
        ],
      },
    ];
  }
}
