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

  String totalPelanggan = '1.508 User';
  String kepuasanCustomer = '4.8 / 5.0';
  String ulasanMasuk = '142 Ulasan Masuk';
  String pertumbuhanBulanIni = '+27% bln Oktober';

  List<Map<String, dynamic>> userGrowthMonthlyData = [
    {'month': 'Mei', 'joined': 110, 'cumulative': 480, 'growth': '+12%'},
    {'month': 'Jun', 'joined': 145, 'cumulative': 625, 'growth': '+15%'},
    {'month': 'Jul', 'joined': 180, 'cumulative': 805, 'growth': '+18%'},
    {'month': 'Agu', 'joined': 210, 'cumulative': 1015, 'growth': '+20%'},
    {'month': 'Sep', 'joined': 225, 'cumulative': 1240, 'growth': '+22%'},
    {'month': 'Okt', 'joined': 268, 'cumulative': 1508, 'growth': '+27%'},
  ];

  /// Mengambil data metrik CS dari Supabase
  Future<void> fetchCsDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRes = await _client.from('users').select('id, created_at');
      if (userRes.isNotEmpty) {
        final count = userRes.length;
        totalPelanggan = '$count User';
        if (userGrowthMonthlyData.isNotEmpty) {
          userGrowthMonthlyData.last['cumulative'] = count;
        }
      }
    } catch (e) {
      debugPrint('[AdminCsDashboardBackend] fetchCsDashboardData error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
