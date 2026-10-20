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

  String totalPelanggan = '1.576 User';
  String kepuasanCustomer = '4.8 / 5.0';
  String ulasanMasuk = '142 Ulasan Masuk';
  String pertumbuhanKuartalIni = '+31.8% Kuartal 4';
  String get pertumbuhanBulanIni => pertumbuhanKuartalIni;

  int availableQuartersCount = 4;
  int latestQuarterIndex = 3;

  // 📊 State 4 Kuartal (Q1, Q2, Q3, Q4) Pertumbuhan Pelanggan
  List<Map<String, dynamic>> userGrowthQuarterlyData = [
    {
      'quarter': 'Q1',
      'label': 'Kuartal 1 (Jan - Mar 2026)',
      'joined': 320,
      'cumulative': 320,
      'growth': 0.0,
      'growthText': 'Basis Q1',
    },
    {
      'quarter': 'Q2',
      'label': 'Kuartal 2 (Apr - Jun 2026)',
      'joined': 410,
      'cumulative': 730,
      'growth': 28.1,
      'growthText': '+28.1% vs Q1',
    },
    {
      'quarter': 'Q3',
      'label': 'Kuartal 3 (Jul - Sep 2026)',
      'joined': 365,
      'cumulative': 1095,
      'growth': -11.0,
      'growthText': '-11.0% vs Q2',
    },
    {
      'quarter': 'Q4',
      'label': 'Kuartal 4 (Okt - Des 2026)',
      'joined': 481,
      'cumulative': 1576,
      'growth': 31.8,
      'growthText': '+31.8% vs Q3',
    },
  ];

  List<double> quarterlyChartData = [0.45, 0.65, 0.55, 0.90];
  List<String> quarterlyXLabels = ['Q1', 'Q2', 'Q3', 'Q4'];

  List<Map<String, dynamic>> get userGrowthMonthlyData => userGrowthQuarterlyData;

  /// Mengambil data metrik CS dari Supabase
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
      if (userRes.isNotEmpty) {
        final List<int> qCounts = [0, 0, 0, 0];
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

        totalPelanggan = '${_formatNumber(userRes.length)} User';
        final latestGrowth = quarterlyData[latestQuarterIndex]['growth'] as double;
        pertumbuhanKuartalIni = '${latestGrowth >= 0 ? '+' : ''}${latestGrowth.toStringAsFixed(1)}% Kuartal ${latestQuarterIndex + 1}';
      }

      // 3. Query customer_feedbacks dari Supabase
      try {
        final fbRes = await _client.from('customer_feedbacks').select('rating');
        if (fbRes.isNotEmpty) {
          ulasanMasuk = '${_formatNumber(fbRes.length)} Ulasan Masuk';
          final double sumRating = fbRes.fold(0.0, (m, e) => m + ((e['rating'] as num?)?.toDouble() ?? 5.0));
          final double avg = sumRating / fbRes.length;
          kepuasanCustomer = '${avg.toStringAsFixed(1)} / 5.0';
        }
      } catch (e) {
        debugPrint('[AdminCsDashboardBackend] feedback query error: $e');
      }
    } catch (e) {
      debugPrint('[AdminCsDashboardBackend] fetchCsDashboardData error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
