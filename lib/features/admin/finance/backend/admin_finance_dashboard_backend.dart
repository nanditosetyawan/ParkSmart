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

  DateTime get _nowWib => DateTime.now().toUtc().add(const Duration(hours: 7));

  DateTime _parseToWib(dynamic val) {
    if (val == null) return _nowWib;
    final dt = DateTime.tryParse(val.toString());
    if (dt == null) return _nowWib;
    return dt.toUtc().add(const Duration(hours: 7));
  }

  // 📊 State 4 Kuartal (Q1, Q2, Q3, Q4)
  int availableQuartersCount = 4;
  int latestQuarterIndex = 3;
  List<double> quarterlyRawAmounts = [245000000, 210000000, 280000000, 315500000];
  List<double> quarterlyChartData = [0.55, 0.38, 0.72, 0.95];
  List<String> quarterlyValues = [
    'Rp 245.000.000',
    'Rp 210.000.000',
    'Rp 280.000.000',
    'Rp 315.500.000',
  ];
  List<String> quarterlyDates = [
    'Kuartal 1 (Jan - Mar 2026)',
    'Kuartal 2 (Apr - Jun 2026)',
    'Kuartal 3 (Jul - Sep 2026)',
    'Kuartal 4 (Okt - Des 2026)',
  ];
  List<String> quarterlyXLabels = ['Q1', 'Q2', 'Q3', 'Q4'];
  List<double> quarterlyGrowths = [0.0, -14.3, 33.3, 12.7];

  String get totalMonthlyOmzet => quarterlyValues[latestQuarterIndex.clamp(0, quarterlyValues.length - 1)];
  String get monthlyGrowth =>
      '${quarterlyGrowths[latestQuarterIndex.clamp(0, quarterlyGrowths.length - 1)] >= 0 ? '+' : ''}${quarterlyGrowths[latestQuarterIndex.clamp(0, quarterlyGrowths.length - 1)].toStringAsFixed(1)}%';
  String get currentMonthLabel => quarterlyDates[latestQuarterIndex.clamp(0, quarterlyDates.length - 1)];
  List<double> get mountainChartData => quarterlyChartData;
  List<String> get mountainXLabels => quarterlyXLabels;

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
      final now = _nowWib;
      final int currentYear = now.year;
      final int nowMonth = now.month;

      // 1. Tentukan jumlah kuartal yang sudah berjalan / aktif pada tahun ini
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

      // 2. Ambil seluruh transaksi pembayaran sukses dari database
      final paymentsRes = await _client
          .from('payments')
          .select('id, transaction_code, amount, payment_method, status, transaction_type, description, created_at, completed_at')
          .order('created_at', ascending: false);

      if (paymentsRes.isNotEmpty) {
        double q1 = 0;
        double q2 = 0;
        double q3 = 0;
        double q4 = 0;

        double totalPaid = 0;
        int countSuccess = 0;

        for (var row in paymentsRes) {
          final amt = (row['amount'] as num?)?.toDouble() ?? 0;
          final status = (row['status'] ?? '').toString().toLowerCase();
          final isSuccess = status == 'success' || status == 'paid';

          if (isSuccess) {
            totalPaid += amt;
            countSuccess++;

            final rawTs = row['completed_at'] ?? row['created_at'];
            final wibDt = _parseToWib(rawTs);

            if (wibDt.year == currentYear) {
              final m = wibDt.month;
              if (m >= 1 && m <= 3) {
                q1 += amt;
              } else if (m >= 4 && m <= 6) {
                q2 += amt;
              } else if (m >= 7 && m <= 9) {
                q3 += amt;
              } else if (m >= 10 && m <= 12) {
                q4 += amt;
              }
            }
          }
        }

        if (countSuccess > 0) {
          successTrxCount = countSuccess;
          successTrxVolume = 'Rp ${_formatCurrency(totalPaid.round())}';
        }

        // Jika ada transaksi di kuartal tahun ini, perbarui angka kuartal
        if (q1 > 0 || q2 > 0 || q3 > 0 || q4 > 0) {
          quarterlyRawAmounts = [q1, q2, q3, q4];
          quarterlyValues = [
            'Rp ${_formatCurrency(q1.round())}',
            'Rp ${_formatCurrency(q2.round())}',
            'Rp ${_formatCurrency(q3.round())}',
            'Rp ${_formatCurrency(q4.round())}',
          ];

          // Kalkulasi persentase kenaikan/penurunan kuartal
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
          // Jika tidak ada transaksi sama sekali di tahun ini
          quarterlyRawAmounts = [0.0, 0.0, 0.0, 0.0];
          quarterlyValues = ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'];
          quarterlyGrowths = [0.0, 0.0, 0.0, 0.0];
          quarterlyChartData = [0.0, 0.0, 0.0, 0.0];
        }

        recentTransactions = paymentsRes.take(5).map<Map<String, dynamic>>((p) {
          final amt = (p['amount'] as num?)?.toInt() ?? 0;
          final method = (p['payment_method'] ?? 'WALLET').toString().toUpperCase();
          final type = (p['transaction_type'] ?? 'parking_payment').toString();
          final isIncome = type != 'refund';

          IconData icon = Icons.account_balance_wallet;
          Color iconBg = const Color(0xFFFEF3C7);
          Color iconColor = const Color(0xFFD97706);

          if (method == 'QRIS') {
            icon = Icons.qr_code_2;
            iconBg = const Color(0xFFD1F2EB);
            iconColor = const Color(0xFF17A18A);
          } else if (type == 'refund') {
            icon = Icons.replay;
            iconBg = const Color(0xFFFDE8E4);
            iconColor = const Color(0xFFD94B4B);
          }

          return {
            'icon': icon,
            'iconBg': iconBg,
            'iconColor': iconColor,
            'title': p['description'] ?? 'Transaksi ParkSmart #$method',
            'subtitle': 'Kode #${p['transaction_code'] ?? 'TRX-001'}',
            'amount': '${isIncome ? '+' : '-'}Rp ${_formatCurrency(amt)}',
            'isIncome': isIncome,
            'time': p['created_at'] != null ? p['created_at'].toString().substring(0, 10) : 'Hari ini',
          };
        }).toList();
      } else {
        // DATABASE KOSONG (0 BARIS DI PUBLIC.PAYMENTS)
        successTrxCount = 0;
        successTrxVolume = 'Rp 0';
        quarterlyRawAmounts = [0.0, 0.0, 0.0, 0.0];
        quarterlyValues = ['Rp 0', 'Rp 0', 'Rp 0', 'Rp 0'];
        quarterlyGrowths = [0.0, 0.0, 0.0, 0.0];
        quarterlyChartData = [0.0, 0.0, 0.0, 0.0];
        recentTransactions = [];
      }

      // 3. Ambil total deposit saldo pengguna
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
