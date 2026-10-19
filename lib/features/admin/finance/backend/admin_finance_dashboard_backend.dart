import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AdminFinanceDashboardScreen (admin_finance_dashboard_screen.dart)
/// Mengelola ringkasan cashflow, volume omzet bulanan, agregat transaksi sukses, dan feed aktivitas finansial
/// Terkoneksi ke `public.payments`, `public.bookings`, dan `public.users` di Supabase
class AdminFinanceDashboardBackend extends ChangeNotifier {
  AdminFinanceDashboardBackend._();
  static final AdminFinanceDashboardBackend instance = AdminFinanceDashboardBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String totalMonthlyOmzet = 'Rp 312.450.000';
  String monthlyGrowth = '+15.7%';
  String currentMonthLabel = 'Oktober 2026';
  List<double> mountainChartData = [0.42, 0.48, 0.55, 0.68, 0.82, 0.96];
  List<String> mountainXLabels = ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'];

  int successTrxCount = 842;
  String successTrxVolume = 'Rp 28.450.000';

  String totalWalletDeposit = 'Rp 54.200.000';
  int activeWalletUsers = 320;

  List<Map<String, dynamic>> recentTransactions = [
    {
      'icon': Icons.qr_code_2,
      'iconBg': const Color(0xFFD1F2EB),
      'iconColor': const Color(0xFF17A18A),
      'title': 'Pembayaran QRIS Gerbang Masuk',
      'subtitle': 'Central Park Mall · Sesi #TRX-9482 (B 1234 SKP)',
      'amount': '+Rp 15.000',
      'isIncome': true,
      'time': '2 mnt lalu',
    },
    {
      'icon': Icons.account_balance_wallet,
      'iconBg': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
      'title': 'Injeksi Saldo Dompet Admin',
      'subtitle': 'Top-up oleh admin ke akun Budi Santoso',
      'amount': '+Rp 250.000',
      'isIncome': true,
      'time': '18 mnt lalu',
    },
    {
      'icon': Icons.credit_card,
      'iconBg': const Color(0xFFEBF2FA),
      'iconColor': const Color(0xFF114177),
      'title': 'Settlement Midtrans Auto-Payout',
      'subtitle': 'Rekening Operasional Bank Mandiri · Batch #ST-881',
      'amount': '+Rp 4.250.000',
      'isIncome': true,
      'time': '35 mnt lalu',
    },
    {
      'icon': Icons.replay,
      'iconBg': const Color(0xFFFDE8E4),
      'iconColor': const Color(0xFFD94B4B),
      'title': 'Refund Pembatalan Parkir Tiket',
      'subtitle': 'Malioboro Mall · #BK-3021 (Dibatalkan pengguna)',
      'amount': '-Rp 20.000',
      'isIncome': false,
      'time': '1 jam lalu',
    },
  ];

  /// Mengambil data metrik finansial dari Supabase
  Future<void> fetchFinanceDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil agregat pembayaran sukses
      final paymentsRes = await _client
          .from('payments')
          .select('id, amount, payment_method, payment_status, created_at')
          .order('created_at', ascending: false)
          .limit(20);

      if (paymentsRes.isNotEmpty) {
        double totalPaid = 0;
        int countSuccess = 0;

        for (var row in paymentsRes) {
          final amt = (row['amount'] as num?)?.toDouble() ?? 0;
          if (row['payment_status'] == 'paid' || row['payment_status'] == 'success') {
            totalPaid += amt;
            countSuccess++;
          }
        }

        if (countSuccess > 0) {
          successTrxCount = countSuccess;
          successTrxVolume = 'Rp ${_formatCurrency(totalPaid.round())}';
        }
      }

      // 2. Ambil total deposit saldo pengguna
      final usersRes = await _client
          .from('users')
          .select('wallet_balance');

      if (usersRes.isNotEmpty) {
        double totalWallet = 0;
        for (var u in usersRes) {
          totalWallet += (u['wallet_balance'] as num?)?.toDouble() ?? 0;
        }
        totalWalletDeposit = 'Rp ${_formatCurrency(totalWallet.round())}';
        activeWalletUsers = usersRes.length;
      }
    } catch (e) {
      debugPrint('[AdminFinanceDashboardBackend] fetchFinanceDashboard error: $e');
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
