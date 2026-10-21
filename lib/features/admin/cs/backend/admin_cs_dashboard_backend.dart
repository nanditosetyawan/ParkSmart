import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AdminCsDashboardScreen (admin_cs_dashboard_screen.dart)
/// Mengelola data metrik kepuasan pelanggan, ringkasan user terdaftar, dan tren pertumbuhan akun
/// Terkoneksi ke tabel `public.users` di Supabase
class AdminCsDashboardBackend extends ChangeNotifier {
  AdminCsDashboardBackend._();
  static final AdminCsDashboardBackend instance = AdminCsDashboardBackend._();

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

  String totalPelanggan = '0 User';
  String kepuasanCustomer = '0.0 / 5.0';
  String ulasanMasuk = '0 Ulasan Masuk';
  String pertumbuhanKuartalIni = '0.0% Kuartal 4';
  String get pertumbuhanBulanIni => pertumbuhanKuartalIni;

  int availableQuartersCount = 4;
  int latestQuarterIndex = 3;

  // 📊 State 4 Kuartal (Q1, Q2, Q3, Q4) Pertumbuhan Pelanggan
  List<Map<String, dynamic>> userGrowthQuarterlyData = [
    {
      'quarter': 'Q1',
      'label': 'Kuartal 1 (Jan - Mar 2026)',
      'joined': 0,
      'cumulative': 0,
      'growth': 0.0,
      'growthText': 'Basis Q1',
    },
    {
      'quarter': 'Q2',
      'label': 'Kuartal 2 (Apr - Jun 2026)',
      'joined': 0,
      'cumulative': 0,
      'growth': 0.0,
      'growthText': '0.0% vs Q1',
    },
    {
      'quarter': 'Q3',
      'label': 'Kuartal 3 (Jul - Sep 2026)',
      'joined': 0,
      'cumulative': 0,
      'growth': 0.0,
      'growthText': '0.0% vs Q2',
    },
    {
      'quarter': 'Q4',
      'label': 'Kuartal 4 (Okt - Des 2026)',
      'joined': 0,
      'cumulative': 0,
      'growth': 0.0,
      'growthText': '0.0% vs Q3',
    },
  ];
  List<double> quarterlyChartData = [0.0, 0.0, 0.0, 0.0];
  List<String> quarterlyXLabels = ['Q1', 'Q2', 'Q3', 'Q4'];

  List<Map<String, dynamic>> get userGrowthMonthlyData => userGrowthQuarterlyData;

  RealtimeChannel? _realtimeChannel;

  /// Memulai langganan Realtime Supabase untuk perubahan di parking_locations, customer_feedbacks, dan users
  void initRealtimeSubscription() {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = _client.channel('public:admin_cs_dashboard')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'parking_locations',
          callback: (payload) {
            debugPrint('[AdminCsDashboardBackend] Realtime update dari parking_locations');
            fetchCsDashboardData();
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'customer_feedbacks',
          callback: (payload) {
            debugPrint('[AdminCsDashboardBackend] Realtime update dari customer_feedbacks');
            fetchCsDashboardData();
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            debugPrint('[AdminCsDashboardBackend] Realtime update dari users');
            fetchCsDashboardData();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('[AdminCsDashboardBackend] initRealtimeSubscription error: $e');
    }
  }

  /// Melepas langganan realtime
  void disposeRealtime() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  /// Mengambil data metrik CS dari Supabase secara real-time
  Future<void> fetchCsDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = _nowWib;
      final int currentYear = now.year;
      final int nowMonth = now.month;

      // 1. Tentukan kuartal aktif saat ini
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

      // 2. Query users dari Supabase
      final userRes = await _client.from('users').select('id, created_at, status');
      final List<int> qCounts = [0, 0, 0, 0];

      if (userRes.isNotEmpty) {
        for (var u in userRes) {
          final dt = _parseToWib(u['created_at']);
          if (dt.year == currentYear) {
            final m = dt.month;
            if (m >= 1 && m <= 3) {
              qCounts[0]++;
            } else if (m >= 4 && m <= 6) {
              qCounts[1]++;
            } else if (m >= 7 && m <= 9) {
              qCounts[2]++;
            } else {
              qCounts[3]++;
            }
          }
        }

        totalPelanggan = '${_formatNumber(userRes.length)} User';
      } else {
        totalPelanggan = '0 User';
      }

      // Susun data per kuartal
      final List<Map<String, dynamic>> quarterlyData = [];
      int runningCumulative = 0;
      final List<String> qNames = ['Q1', 'Q2', 'Q3', 'Q4'];
      final List<String> qLabels = [
        'Kuartal 1 (Jan - Mar $currentYear)',
        'Kuartal 2 (Apr - Jun $currentYear)',
        'Kuartal 3 (Jul - Sep $currentYear)',
        'Kuartal 4 (Okt - Des $currentYear)',
      ];

      for (int i = 0; i < 4; i++) {
        final joined = qCounts[i];
        runningCumulative += joined;
        double growth = 0.0;
        String growthText = 'Basis Q1';
        if (i > 0) {
          final prev = qCounts[i - 1];
          if (prev > 0) {
            growth = ((joined - prev) / prev) * 100.0;
          } else if (joined > 0) {
            growth = 100.0;
          }
          growthText = '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}% vs Q$i';
        }

        quarterlyData.add({
          'quarter': qNames[i],
          'label': qLabels[i],
          'joined': joined,
          'cumulative': runningCumulative,
          'growth': growth,
          'growthText': growthText,
        });
      }

      userGrowthQuarterlyData = quarterlyData;

      final maxJoined = qCounts.fold(0, (m, v) => v > m ? v : m);
      quarterlyChartData = qCounts.map((v) {
        if (maxJoined <= 0 || v <= 0) return 0.08;
        return 0.18 + (v / maxJoined) * 0.77;
      }).toList();

      if (userRes.isNotEmpty) {
        final latestGrowth = quarterlyData[latestQuarterIndex]['growth'] as double;
        pertumbuhanKuartalIni = '${latestGrowth >= 0 ? '+' : ''}${latestGrowth.toStringAsFixed(1)}% Kuartal ${latestQuarterIndex + 1}';
      } else {
        pertumbuhanKuartalIni = '0.0% Kuartal ${latestQuarterIndex + 1}';
      }

      // 3. Query SEMUA lokasi parkir untuk rating bintang & ulasan kepuasan customer
      try {
        final locRes = await _client
            .from('parking_locations')
            .select('id, name, rating, review_count');

        // Ambil juga customer_feedbacks jika ada feedback tercatat
        List<dynamic> fbRes = [];
        try {
          fbRes = await _client.from('customer_feedbacks').select('rating');
        } catch (_) {}

        int totalLocationReviews = 0;
        double weightedRatingSum = 0.0;
        double unweightedRatingSum = 0.0;
        int locationsWithRating = 0;

        for (var loc in locRes) {
          final double r = (loc['rating'] as num?)?.toDouble() ?? 0.0;
          final int c = (loc['review_count'] as num?)?.toInt() ?? 0;
          totalLocationReviews += c;
          weightedRatingSum += (r * c);
          if (r > 0) {
            unweightedRatingSum += r;
            locationsWithRating++;
          }
        }

        int totalFeedbackReviews = fbRes.length;
        double feedbackRatingSum = 0.0;
        for (var f in fbRes) {
          feedbackRatingSum += ((f['rating'] as num?)?.toDouble() ?? 5.0);
        }

        final int totalAllReviews = totalLocationReviews + totalFeedbackReviews;

        if (totalAllReviews > 0) {
          final double totalRatingPoints = weightedRatingSum + feedbackRatingSum;
          final double avg = totalRatingPoints / totalAllReviews;
          kepuasanCustomer = '${avg.toStringAsFixed(1)} / 5.0';
          ulasanMasuk = '${_formatNumber(totalAllReviews)} Ulasan Masuk';
        } else if (locationsWithRating > 0) {
          final double avg = unweightedRatingSum / locationsWithRating;
          kepuasanCustomer = '${avg.toStringAsFixed(1)} / 5.0';
          ulasanMasuk = '0 Ulasan Masuk';
        } else {
          kepuasanCustomer = '0.0 / 5.0';
          ulasanMasuk = '0 Ulasan Masuk';
        }
      } catch (e) {
        debugPrint('[AdminCsDashboardBackend] locations & feedback query error: $e');
        kepuasanCustomer = '0.0 / 5.0';
        ulasanMasuk = '0 Ulasan Masuk';
      }
    } catch (e) {
      debugPrint('[AdminCsDashboardBackend] fetchCsDashboardData error: $e');
      _errorMessage = e.toString();
      totalPelanggan = '0 User';
      kepuasanCustomer = '0.0 / 5.0';
      ulasanMasuk = '0 Ulasan Masuk';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatNumber(dynamic n) {
    if (n == null) return '0';
    final int val = (n is num) ? n.toInt() : (int.tryParse(n.toString()) ?? 0);
    return val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
