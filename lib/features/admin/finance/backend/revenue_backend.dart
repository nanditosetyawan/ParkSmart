import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk RevenueScreen (revenue_screen.dart)
/// Mengelola analitik pendapatan omzet agregat, tren bulanan, dan breakdown per gedung mitra
/// Terkoneksi ke `public.payments` dan `public.parking_locations` di Supabase
class RevenueBackend extends ChangeNotifier {
  RevenueBackend._();
  static final RevenueBackend instance = RevenueBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTime get _nowWib => DateTime.now().toUtc().add(const Duration(hours: 7));

  DateTime _parseToWib(dynamic val) {
    if (val == null) return _nowWib;
    final dt = DateTime.tryParse(val.toString());
    if (dt == null) return _nowWib;
    return dt.toUtc().add(const Duration(hours: 7));
  }

  // 📅 Tahun Dinamis
  int _activeYear = DateTime.now().year;
  int get dynamicYear => _activeYear;

  int get currentQuarterIndex {
    final m = _nowWib.month;
    return ((m - 1) ~/ 3).clamp(0, 3);
  }

  int get currentQuarter => currentQuarterIndex + 1;

  // 📊 State 4 Kuartal (Q1, Q2, Q3, Q4) untuk Ringkasan
  int availableQuartersCount = 4;
  int latestQuarterIndex = 3;
  int availableWeeksCount = 3;
  int latestWeekIndex = 2;

  List<double> quarterlyRawAmounts = [0.0, 0.0, 0.0, 0.0];
  List<double> quarterlyChartData = [0.0, 0.0, 0.0, 0.0];
  List<String> quarterlyValues = [
    'Rp 0',
    'Rp 0',
    'Rp 0',
    'Rp 0',
  ];
  late List<String> quarterlyDates = [
    'Kuartal 1 (Jan - Mar $_activeYear)',
    'Kuartal 2 (Apr - Jun $_activeYear)',
    'Kuartal 3 (Jul - Sep $_activeYear)',
    'Kuartal 4 (Okt - Des $_activeYear)',
  ];
  List<String> quarterlyXLabels = ['Q1', 'Q2', 'Q3', 'Q4'];
  List<double> quarterlyGrowths = [0.0, 0.0, 0.0, 0.0];
  List<int> quarterlyTrxCounts = [0, 0, 0, 0];

  /// Kuartal yang ditampilkan pada rekapitulasi kuartal.
  /// Aturan:
  /// - Untuk tahun awal berjalan (2026): jika Q1..Q3 belum dimulai/0 transaksi, mulai dari kuartal aktif saat ini (Q4) -> hanya tampil 1 kartu.
  /// - Saat masuk Q1 tahun depan (2027): tahun berganti jadi 2027, Q4 tahun lalu otomatis hilang, hanya Q1 yang tampil.
  /// - Saat masuk Q2: Q1 jangan hilang dulu (tampil Q2 dan Q1).
  /// - Saat masuk Q3: tampil Q3, Q2, Q1.
  /// - Saat masuk Q4: tampil Q4, Q3, Q2, Q1.
  List<int> get displayedQuarterIndices {
    final int currentQIndex = currentQuarterIndex; // 0..3

    int startQIndex = 0;
    if (_activeYear == 2026) {
      startQIndex = currentQIndex;
      for (int i = 0; i < currentQIndex; i++) {
        if (quarterlyTrxCounts[i] > 0 || quarterlyRawAmounts[i] > 0) {
          startQIndex = i;
          break;
        }
      }
    }

    final List<int> list = [];
    for (int i = currentQIndex; i >= startQIndex; i--) {
      list.add(i);
    }
    return list;
  }

  List<double> get monthlyChartData => quarterlyChartData;
  List<String> get monthlyValues => quarterlyValues;
  List<String> get monthlyDates => quarterlyDates;
  List<String> get monthlyGrowths => quarterlyGrowths.map((g) => '${g >= 0 ? '+' : ''}${g.toStringAsFixed(1)}%').toList();
  List<String> get monthlyXLabels => quarterlyXLabels;

  // 🏢 State Per Lokasi (Dinamis dari Supabase)
  List<Map<String, dynamic>> availableLocations = [];
  Map<String, Map<String, dynamic>> locationDataset = {};
  List<Map<String, dynamic>> topContributingLocations = [];
  List<Map<String, dynamic>> get top4Locations => topContributingLocations.take(4).toList();

  // 🚗🏍️ State Analitik Tipe Kendaraan (Global, Sesi Selesai / Completed Saja)
  int completedMobilCount = 0;
  int completedMotorCount = 0;
  double completedMobilRevenue = 0.0;
  double completedMotorRevenue = 0.0;

  int get totalCompletedSessions => completedMobilCount + completedMotorCount;
  double get totalCompletedRevenue => completedMobilRevenue + completedMotorRevenue;

  double get mobilSessionRatio => totalCompletedSessions > 0
      ? (completedMobilCount / totalCompletedSessions) * 100.0
      : 0.0;
  double get motorSessionRatio => totalCompletedSessions > 0
      ? (completedMotorCount / totalCompletedSessions) * 100.0
      : 0.0;

  double get mobilRevenueRatio => totalCompletedRevenue > 0
      ? (completedMobilRevenue / totalCompletedRevenue) * 100.0
      : 0.0;
  double get motorRevenueRatio => totalCompletedRevenue > 0
      ? (completedMotorRevenue / totalCompletedRevenue) * 100.0
      : 0.0;

  double get avgFeeMobil => completedMobilCount > 0
      ? completedMobilRevenue / completedMobilCount
      : 0.0;
  double get avgFeeMotor => completedMotorCount > 0
      ? completedMotorRevenue / completedMotorCount
      : 0.0;

  /// Mengambil data revenue dari Supabase
  Future<void> fetchRevenueData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = _nowWib;

      // 📅 Deteksi tahun dinamis dari transaksi Supabase terbaru
      int calculatedYear = now.year;
      try {
        final latestPayment = await _client
            .from('payments')
            .select('created_at')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        if (latestPayment != null && latestPayment['created_at'] != null) {
          final dt = _parseToWib(latestPayment['created_at']);
          calculatedYear = dt.year;
        }
      } catch (_) {}

      _activeYear = calculatedYear;
      final int currentYear = _activeYear;

      // Perbarui label rentang tanggal kuartal dengan tahun dinamis
      quarterlyDates = [
        'Kuartal 1 (Jan - Mar $currentYear)',
        'Kuartal 2 (Apr - Jun $currentYear)',
        'Kuartal 3 (Jul - Sep $currentYear)',
        'Kuartal 4 (Okt - Des $currentYear)',
      ];

      final int nowMonth = now.month;
      final int nowDay = now.day;

      // 1. Hitung kuartal aktif berjalan
      if (nowMonth <= 3) {
        availableQuartersCount = 1;
      } else if (nowMonth <= 6) {
        availableQuartersCount = 2;
      } else if (nowMonth <= 9) {
        availableQuartersCount = 3;
      } else {
        availableQuartersCount = 4;
      }
      latestQuarterIndex = availableQuartersCount - 1;

      // 2. Hitung minggu aktif berjalan untuk bulan ini
      if (nowDay <= 7) {
        availableWeeksCount = 1;
      } else if (nowDay <= 14) {
        availableWeeksCount = 2;
      } else if (nowDay <= 21) {
        availableWeeksCount = 3;
      } else {
        availableWeeksCount = 4;
      }
      latestWeekIndex = availableWeeksCount - 1;

      // 3. Ambil data ringkasan agregat dari public.payments
      try {
        final paymentsRes = await _client
            .from('payments')
            .select('amount, status, transaction_type, created_at, completed_at');

        if (paymentsRes.isNotEmpty) {
          double q1 = 0;
          double q2 = 0;
          double q3 = 0;
          double q4 = 0;
          int c1 = 0;
          int c2 = 0;
          int c3 = 0;
          int c4 = 0;

          for (var row in paymentsRes) {
            final amt = (row['amount'] as num?)?.toDouble() ?? 0;
            final status = (row['status'] ?? '').toString().toLowerCase();
            final trxType = (row['transaction_type'] ?? '').toString().toLowerCase();
            final isSuccess = status == 'success' || status == 'paid';

            if (isSuccess && trxType != 'wallet_injection' && trxType != 'refund') {
              final rawTs = row['completed_at'] ?? row['created_at'];
              final wibDt = _parseToWib(rawTs);

              if (wibDt.year == currentYear) {
                final m = wibDt.month;
                if (m >= 1 && m <= 3) {
                  q1 += amt;
                  c1++;
                } else if (m >= 4 && m <= 6) {
                  q2 += amt;
                  c2++;
                } else if (m >= 7 && m <= 9) {
                  q3 += amt;
                  c3++;
                } else if (m >= 10 && m <= 12) {
                  q4 += amt;
                  c4++;
                }
              }
            }
          }

          if (q1 > 0 || q2 > 0 || q3 > 0 || q4 > 0) {
            quarterlyRawAmounts = [q1, q2, q3, q4];
            quarterlyTrxCounts = [c1, c2, c3, c4];
            quarterlyValues = [
              'Rp ${_formatCurrency(q1.round())}',
              'Rp ${_formatCurrency(q2.round())}',
              'Rp ${_formatCurrency(q3.round())}',
              'Rp ${_formatCurrency(q4.round())}',
            ];

            quarterlyGrowths = [0.0, 0.0, 0.0, 0.0];
            if (q1 > 0) {
              quarterlyGrowths[1] = ((q2 - q1) / q1) * 100.0;
            } else if (q2 > 0) {
              quarterlyGrowths[1] = 100.0;
            }

            if (q2 > 0) {
              quarterlyGrowths[2] = ((q3 - q2) / q2) * 100.0;
            } else if (q3 > 0) {
              quarterlyGrowths[2] = 100.0;
            }

            if (q3 > 0) {
              quarterlyGrowths[3] = ((q4 - q3) / q3) * 100.0;
            } else if (q4 > 0) {
              quarterlyGrowths[3] = 100.0;
            }

            final double maxQ = quarterlyRawAmounts.fold(0.0, (m, v) => v > m ? v : m);
            quarterlyChartData = quarterlyRawAmounts.map((v) {
              if (maxQ <= 0 || v <= 0) return 0.08;
              return 0.18 + (v / maxQ) * 0.77;
            }).toList();
          } else {
            quarterlyRawAmounts = [0.0, 0.0, 0.0, 0.0];
            quarterlyTrxCounts = [0, 0, 0, 0];
            quarterlyValues = ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'];
            quarterlyGrowths = [0.0, 0.0, 0.0, 0.0];
            quarterlyChartData = [0.0, 0.0, 0.0, 0.0];
          }
        } else {
          quarterlyRawAmounts = [0.0, 0.0, 0.0, 0.0];
          quarterlyTrxCounts = [0, 0, 0, 0];
          quarterlyValues = ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'];
          quarterlyGrowths = [0.0, 0.0, 0.0, 0.0];
          quarterlyChartData = [0.0, 0.0, 0.0, 0.0];
        }
      } catch (e) {
        debugPrint('[RevenueBackend] payments fetch error: $e');
      }

      // 4. Ambil data lokasi parkir dan sesi per lokasi dari Supabase
      final locsRes = await _client
          .from('parking_locations')
          .select('id, name, city, code')
          .order('name');

      if (locsRes.isEmpty) {
        availableLocations = [];
        locationDataset = {};
        topContributingLocations = [];
      } else {
        availableLocations = List<Map<String, dynamic>>.from(locsRes);

        // Ambil semua sesi parkir untuk diagregasi per lokasi dan rasio kendaraan global
        final sessionsRes = await _client
            .from('parking_sessions')
            .select('location_id, total_fee, check_in_time, status, vehicle_type');

        // Peta agregasi per location_id
        final Map<String, List<double>> locQuarterlySums = {};
        final Map<String, List<double>> locWeeklySums = {};
        final Map<String, double> locTotalYearSums = {};
        double totalAllLocationsYear = 0.0;

        int mobCount = 0;
        int motCount = 0;
        double mobRev = 0.0;
        double motRev = 0.0;

        for (var loc in availableLocations) {
          final String locId = loc['id'].toString();
          locQuarterlySums[locId] = [0.0, 0.0, 0.0, 0.0];
          locWeeklySums[locId] = [0.0, 0.0, 0.0, 0.0];
          locTotalYearSums[locId] = 0.0;
        }

        for (var s in sessionsRes) {
          final String status = (s['status'] ?? '').toString().toLowerCase();
          final String vType = (s['vehicle_type'] ?? '').toString().toLowerCase();
          final double fee = (s['total_fee'] as num?)?.toDouble() ?? 0.0;

          // 🚗🏍️ Hitung global rasio kendaraan: HANYA SESI SELESAI (COMPLETED)
          // Mengabaikan yang masih masuk / proses / aktif
          if (status == 'completed') {
            if (vType == 'mobil' || vType == 'car' || vType == 'ev') {
              mobCount++;
              mobRev += fee;
            } else if (vType == 'motor' || vType == 'motorcycle') {
              motCount++;
              motRev += fee;
            }
          }

          final String locId = (s['location_id'] ?? '').toString();
          if (!locQuarterlySums.containsKey(locId)) continue;

          final DateTime dt = _parseToWib(s['check_in_time']);

          // Hitung kuartal untuk tahun berjalan
          if (dt.year == currentYear) {
            final int m = dt.month;
            int qIndex = 0;
            if (m >= 1 && m <= 3) {
              qIndex = 0;
            } else if (m >= 4 && m <= 6) {
              qIndex = 1;
            } else if (m >= 7 && m <= 9) {
              qIndex = 2;
            } else {
              qIndex = 3;
            }

            locQuarterlySums[locId]![qIndex] += fee;
            locTotalYearSums[locId] = (locTotalYearSums[locId] ?? 0.0) + fee;
            totalAllLocationsYear += fee;

            // Hitung minggu untuk bulan berjalan
            if (m == nowMonth) {
              final int d = dt.day;
              int wIndex = 0;
              if (d >= 1 && d <= 7) {
                wIndex = 0;
              } else if (d >= 8 && d <= 14) {
                wIndex = 1;
              } else if (d >= 15 && d <= 21) {
                wIndex = 2;
              } else {
                wIndex = 3;
              }

              locWeeklySums[locId]![wIndex] += fee;
            }
          }
        }

        completedMobilCount = mobCount;
        completedMotorCount = motCount;
        completedMobilRevenue = mobRev;
        completedMotorRevenue = motRev;

        final Map<String, Map<String, dynamic>> newDataset = {};

        for (var loc in availableLocations) {
          final String locId = loc['id'].toString();
          final String locName = loc['name'] ?? 'Lokasi';
          final String locCity = loc['city'] ?? '';
          final String locCode = loc['code'] ?? '';

          final List<double> qAmounts = locQuarterlySums[locId] ?? [0.0, 0.0, 0.0, 0.0];
          final List<double> wAmounts = locWeeklySums[locId] ?? [0.0, 0.0, 0.0, 0.0];
          final double totalLocYear = locTotalYearSums[locId] ?? 0.0;

          // Hitung persentase kontribusi
          final double contributionRatio = totalAllLocationsYear > 0 ? (totalLocYear / totalAllLocationsYear) * 100.0 : 0.0;
          final String contributionStr = '${contributionRatio.toStringAsFixed(1)}%';

          // Hitung pertumbuhan kuartal (Q1, Q2, Q3, Q4)
          final List<double> qGrowths = [0.0, 0.0, 0.0, 0.0];
          for (int i = 1; i < 4; i++) {
            final prev = qAmounts[i - 1];
            final curr = qAmounts[i];
            if (prev > 0) {
              qGrowths[i] = ((curr - prev) / prev) * 100.0;
            } else if (curr > 0) {
              qGrowths[i] = 100.0;
            }
          }

          // Hitung pertumbuhan minggu (W1, W2, W3, W4)
          final List<double> wGrowths = [0.0, 0.0, 0.0, 0.0];
          for (int i = 1; i < 4; i++) {
            final prev = wAmounts[i - 1];
            final curr = wAmounts[i];
            if (prev > 0) {
              wGrowths[i] = ((curr - prev) / prev) * 100.0;
            } else if (curr > 0) {
              wGrowths[i] = 100.0;
            }
          }

          // Normalisasi kurva chart untuk kuartal (1 Tahun)
          final double maxQ = qAmounts.fold(0.0, (m, v) => v > m ? v : m);
          final List<double> qChartData = qAmounts.map((v) {
            if (maxQ <= 0 || v <= 0) return 0.08;
            return 0.18 + (v / maxQ) * 0.77;
          }).toList();

          // Normalisasi kurva chart untuk minggu (1 Bulan)
          final double maxW = wAmounts.fold(0.0, (m, v) => v > m ? v : m);
          final List<double> wChartData = wAmounts.map((v) {
            if (maxW <= 0 || v <= 0) return 0.08;
            return 0.18 + (v / maxW) * 0.77;
          }).toList();

          newDataset[locName] = {
            'id': locId,
            'name': locName,
            'city': locCity,
            'code': locCode,
            'totalOmzet': 'Rp ${_formatCurrency(totalLocYear.round())}',
            'contribution': contributionStr,
            // 1 Bulan (4 Minggu)
            'monthRawAmounts': wAmounts,
            'monthData': wChartData,
            'monthValues': wAmounts.map((v) => 'Rp ${_formatCurrency(v.round())}').toList(),
            'monthDates': ['Minggu 1 (1 - 7 Okt)', 'Minggu 2 (8 - 14 Okt)', 'Minggu 3 (15 - 21 Okt)', 'Minggu 4 (22 - 31 Okt)'],
            'monthLabels': ['W1', 'W2', 'W3', 'W4'],
            'monthGrowths': wGrowths,
            // 1 Tahun (4 Kuartal)
            'yearRawAmounts': qAmounts,
            'yearData': qChartData,
            'yearValues': qAmounts.map((v) => 'Rp ${_formatCurrency(v.round())}').toList(),
            'yearDates': [
              'Kuartal 1 (Jan - Mar $currentYear)',
              'Kuartal 2 (Apr - Jun $currentYear)',
              'Kuartal 3 (Jul - Sep $currentYear)',
              'Kuartal 4 (Okt - Des $currentYear)',
            ],
            'yearLabels': ['Q1', 'Q2', 'Q3', 'Q4'],
            'yearGrowths': qGrowths,
          };
        }

        locationDataset = newDataset;

        final List<Map<String, dynamic>> locList = [];
        for (var loc in availableLocations) {
          final String locId = loc['id'].toString();
          final String locName = loc['name'] ?? 'Lokasi';
          final String locCity = loc['city'] ?? '';
          final double totalLocYear = locTotalYearSums[locId] ?? 0.0;
          final double ratio = totalAllLocationsYear > 0 ? (totalLocYear / totalAllLocationsYear) : 0.0;
          locList.add({
            'name': locName,
            'city': locCity,
            'omzet': 'Rp ${_formatCurrency(totalLocYear.round())}',
            'rawOmzet': totalLocYear,
            'ratio': ratio,
          });
        }
        locList.sort((a, b) => (b['rawOmzet'] as num).compareTo(a['rawOmzet'] as num));
        topContributingLocations = locList;
      }
    } catch (e) {
      debugPrint('[RevenueBackend] fetchRevenueData error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatCurrency(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
