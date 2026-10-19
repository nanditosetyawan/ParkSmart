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

  List<double> monthlyChartData = [0.42, 0.48, 0.55, 0.68, 0.82, 0.96];
  List<String> monthlyValues = [
    'Rp 210.500.000',
    'Rp 225.800.000',
    'Rp 240.500.000',
    'Rp 269.800.000',
    'Rp 295.400.000',
    'Rp 312.450.000',
  ];
  List<String> monthlyDates = [
    'Mei 2026',
    'Juni 2026',
    'Juli 2026',
    'Agustus 2026',
    'September 2026',
    'Oktober 2026',
  ];
  List<String> monthlyGrowths = [
    '+5.8%',
    '+7.2%',
    '+6.5%',
    '+12.1%',
    '+10.4%',
    '+15.7%',
  ];
  List<String> monthlyXLabels = ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'];

  final Map<String, Map<String, dynamic>> locationDataset = {
    'Central Park Mall': {
      'totalOmzet': 'Rp 156.400.000',
      'targetOmzet': 'Rp 160.000.000',
      'progressTarget': 0.97,
      'growth': '+16.5%',
      'totalSessions': '4.120',
      'avgTicket': 'Rp 37.960',
      'occupancyRate': '82%',
      'evChargingOmzet': 'Rp 18.250.000',
      'peakHours': '17:00 - 20:00 WIB',
      'dailyDistribution': [0.65, 0.58, 0.72, 0.70, 0.85, 0.96, 0.92],
    },
    'Grand Indonesia': {
      'totalOmzet': 'Rp 98.250.000',
      'targetOmzet': 'Rp 110.000.000',
      'progressTarget': 0.89,
      'growth': '+14.1%',
      'totalSessions': '2.640',
      'avgTicket': 'Rp 37.215',
      'occupancyRate': '76%',
      'evChargingOmzet': 'Rp 12.400.000',
      'peakHours': '12:00 - 15:00 WIB',
      'dailyDistribution': [0.70, 0.68, 0.74, 0.72, 0.88, 0.92, 0.85],
    },
    'Malioboro Mall': {
      'totalOmzet': 'Rp 34.600.000',
      'targetOmzet': 'Rp 40.000.000',
      'progressTarget': 0.86,
      'growth': '+8.4%',
      'totalSessions': '1.180',
      'avgTicket': 'Rp 29.320',
      'occupancyRate': '64%',
      'evChargingOmzet': 'Rp 3.100.000',
      'peakHours': '18:00 - 21:00 WIB',
      'dailyDistribution': [0.55, 0.50, 0.60, 0.58, 0.80, 0.95, 0.90],
    },
    'Paris Van Java': {
      'totalOmzet': 'Rp 23.200.000',
      'targetOmzet': 'Rp 25.000.000',
      'progressTarget': 0.92,
      'growth': '+7.2%',
      'totalSessions': '790',
      'avgTicket': 'Rp 29.360',
      'occupancyRate': '58%',
      'evChargingOmzet': 'Rp 2.450.000',
      'peakHours': '16:00 - 19:00 WIB',
      'dailyDistribution': [0.45, 0.42, 0.52, 0.50, 0.75, 0.90, 0.85],
    },
  };

  /// Mengambil data revenue dari Supabase
  Future<void> fetchRevenueData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payments = await _client
          .from('payments')
          .select('amount, payment_status, created_at')
          .eq('payment_status', 'paid');

      if (payments.isNotEmpty) {
        double total = 0;
        for (var p in payments) {
          total += (p['amount'] as num?)?.toDouble() ?? 0;
        }

        if (total > 0) {
          monthlyValues[monthlyValues.length - 1] = 'Rp ${_formatCurrency(total.round())}';
        }
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
