import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../history/history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend/profile_backend.dart';
import 'backend/payment_methods_backend.dart';

import '../checkout/backend/checkout_backend.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final bool autoOpenTopUp;
  final String? topUpReason;

  const PaymentMethodsScreen({
    super.key,
    this.autoOpenTopUp = false,
    this.topUpReason,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _balance = 0;
  bool _autoDebet = false;
  String _selectedMethod = 'parksmart_pay';

  // Set metode yang sudah tersimpan di Metode Tersimpan
  final Set<String> _savedMethods = {};

  @override
  void initState() {
    super.initState();
    _selectedMethod = PaymentMethodsBackend.instance.selectedMethod;
    _savedMethods.addAll(PaymentMethodsBackend.instance.savedMethods);
    _loadBalance();
    CurrencyService.instance.addListener(_onCurrencyChanged);
    ThemeService.instance.addListener(_onThemeChanged);
    LanguageService.instance.addListener(_onLanguageChanged);
    PaymentMethodsBackend.instance.addListener(_onBackendChanged);
    PaymentMethodsBackend.instance.fetchBalance();
    PaymentMethodsBackend.instance.fetchTransactions();

    if (widget.autoOpenTopUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showTopUpSheet(reason: widget.topUpReason);
        }
      });
    }
  }

  void _onBackendChanged() {
    if (mounted) {
      setState(() {
        _balance = PaymentMethodsBackend.instance.balance;
      });
    }
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final profileBal = ProfileBackend.instance.walletBalance;
    final savedBal = prefs.getInt('user_wallet_balance');
    if (mounted) {
      setState(() {
        _balance = savedBal ?? profileBal;
      });
    }
  }

  void _onCurrencyChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    CurrencyService.instance.removeListener(_onCurrencyChanged);
    ThemeService.instance.removeListener(_onThemeChanged);
    LanguageService.instance.removeListener(_onLanguageChanged);
    PaymentMethodsBackend.instance.removeListener(_onBackendChanged);
    super.dispose();
  }

  void _showTopUpSheet({String? reason}) {
    int selectedAmount = 50000;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ListenableBuilder(
        listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
        builder: (sheetCtx, _) {
          final theme = ThemeService.instance;
          final isDark = theme.isDarkMode;

          return StatefulBuilder(
            builder: (dialogCtx, setSheetState) => Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? theme.border : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Top Up ParkSmart Pay'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih nominal isi ulang saldo parkir Anda'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: theme.textSecondary,
                    ),
                  ),
                  if (reason != null && reason.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reason.tr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400, // Tulisan tipis
                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [20000, 50000, 100000, 200000].map((amount) {
                      final isSelected = selectedAmount == amount;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedAmount = amount),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white : const Color(0xFF1C1C18))
                                : (isDark ? theme.surfaceField : const Color(0xFFF6F4EE)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : const Color(0xFF1C1C18))
                                  : theme.border,
                            ),
                          ),
                          child: Text(
                            CurrencyService.instance.format(amount),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : theme.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final success = await PaymentMethodsBackend.instance.topUp(
                          selectedAmount,
                          'bank_va',
                        );
                        if (mounted) {
                          setState(() {
                            _balance = PaymentMethodsBackend.instance.balance;
                          });
                          await CheckoutBackend.instance.fetchCheckoutData();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Top Up ${CurrencyService.instance.format(selectedAmount)} berhasil!'.tr
                                    : 'Gagal memproses Top Up. Silakan coba lagi.'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                              backgroundColor: success
                                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32))
                                  : Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      child: Text(
                        'Konfirmasi Top Up'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHistorySheet() {
    String filterType = 'all'; // 'all', 'in', 'out'
    PaymentMethodsBackend.instance.fetchTransactions();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ListenableBuilder(
        listenable: Listenable.merge([ThemeService.instance, PaymentMethodsBackend.instance, LanguageService.instance]),
        builder: (context, _) {
          final theme = ThemeService.instance;
          final isDark = theme.isDarkMode;
          final backend = PaymentMethodsBackend.instance;

          return StatefulBuilder(
            builder: (context, setSheetState) {
              final allTransactions = backend.transactions;
              final filteredList = allTransactions.where((item) {
                if (filterType == 'in') return item['isIncome'] == true;
                if (filterType == 'out') return item['isIncome'] == false;
                return true;
              }).toList();

              return Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.82,
                ),
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? theme.border : const Color(0xFFD6D0C5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? theme.surfaceField : const Color(0xFF1C1C18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: isDark ? theme.iconColor : Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Riwayat Mutasi Saldo'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Aktivitas ParkSmart Pay & Parkir'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.chipBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: theme.iconColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Balance summary banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E242B), Color(0xFF2D3748)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? theme.border : Colors.transparent,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E242B).withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SALDO PARKSMART PAY'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                 Text(
                                  CurrencyService.instance.format(backend.balance),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildMiniStatBadge(
                                  label: 'Masuk'.tr,
                                  val: '+${CurrencyService.instance.format(backend.totalIncome)}',
                                  color: const Color(0xFF4ADE80),
                                  icon: Icons.south_west_rounded,
                                ),
                                const SizedBox(width: 8),
                                _buildMiniStatBadge(
                                  label: 'Keluar'.tr,
                                  val: '-${CurrencyService.instance.format(backend.totalExpense)}',
                                  color: const Color(0xFFFDBA74),
                                  icon: Icons.north_east_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filter tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildHistoryFilterChip(
                            label: 'Semua'.tr,
                            isSelected: filterType == 'all',
                            onTap: () => setSheetState(() => filterType = 'all'),
                          ),
                          const SizedBox(width: 8),
                          _buildHistoryFilterChip(
                            label: 'Masuk (+)'.tr,
                            isSelected: filterType == 'in',
                            onTap: () => setSheetState(() => filterType = 'in'),
                          ),
                          const SizedBox(width: 8),
                          _buildHistoryFilterChip(
                            label: 'Keluar (-)'.tr,
                            isSelected: filterType == 'out',
                            onTap: () => setSheetState(() => filterType = 'out'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Transactions List
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 48,
                                      color: theme.textSecondary.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Belum ada transaksi',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Riwayat mutasi pengisian saldo (Top Up) atau pembayaran parkir Anda akan otomatis tercatat di sini.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: theme.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              itemCount: filteredList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final tx = filteredList[index];
                                final bool isIncome = tx['isIncome'] as bool;

                                return GestureDetector(
                                  onTap: () => _showTransactionDetailModal(tx),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDark ? theme.surfaceField : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: theme.border,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: isIncome
                                                ? const Color(0xFF15803D).withValues(alpha: isDark ? 0.25 : 0.12)
                                                : const Color(0xFFC05621).withValues(alpha: isDark ? 0.25 : 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isIncome
                                                ? Icons.arrow_downward_rounded
                                                : Icons.local_parking_rounded,
                                            color: isIncome
                                                ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                                                : (isDark ? const Color(0xFFF97316) : const Color(0xFFC05621)),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (tx['title'] as String).tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                (tx['subtitle'] as String).tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  color: theme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                (tx['date'] as String).tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: theme.textSecondary.withValues(alpha: 0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${isIncome ? '+' : '-'}${CurrencyService.instance.format(tx['rawAmount'] as num)}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w800,
                                                color: isIncome
                                                    ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                                                    : theme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7,
                                                vertical: 2.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isIncome
                                                    ? (isDark ? const Color(0xFF15803D).withValues(alpha: 0.25) : const Color(0xFFDCFCE7))
                                                    : theme.chipBg,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                (tx['status'] as String).tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: isIncome
                                                      ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                                                      : theme.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Bottom button: Lihat Semua Riwayat Sesi Parkir
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HistoryScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lihat Detail Sesi Parkir Lengkap'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTransactionDetailModal(Map<String, dynamic> tx) {
    final bool isIncome = tx['isIncome'] as bool;

    showDialog(
      context: context,
      builder: (ctx) => ListenableBuilder(
        listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
        builder: (context, _) {
          final theme = ThemeService.instance;
          final isDark = theme.isDarkMode;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: theme.card,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isIncome
                          ? const Color(0xFF15803D).withValues(alpha: isDark ? 0.25 : 0.12)
                          : const Color(0xFFC05621).withValues(alpha: isDark ? 0.25 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isIncome ? Icons.check_circle_rounded : Icons.local_parking_rounded,
                      color: isIncome
                          ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                          : (isDark ? const Color(0xFFF97316) : const Color(0xFFC05621)),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (tx['title'] as String).tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isIncome ? '+' : '-'}${CurrencyService.instance.format(tx['rawAmount'] as num)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isIncome
                          ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                          : theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: theme.divider, height: 1),
                  const SizedBox(height: 14),
                  _buildDetailRow('No. Referensi'.tr, tx['id'] as String),
                  const SizedBox(height: 8),
                  _buildDetailRow('Waktu Transaksi'.tr, (tx['date'] as String).tr),
                  const SizedBox(height: 8),
                  _buildDetailRow('Metode/Kanal'.tr, (tx['channel'] as String).tr),
                  const SizedBox(height: 8),
                  _buildDetailRow('Keterangan'.tr, (tx['subtitle'] as String).tr),
                  const SizedBox(height: 8),
                  _buildDetailRow('Status'.tr, (tx['status'] as String).tr, isBadge: true, isIncome: isIncome),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.textPrimary,
                        side: BorderSide(color: theme.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      child: Text(
                        'Tutup'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStatBadge({
    required String label,
    required String val,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF1C1C18))
              : (isDark ? theme.surfaceField : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF1C1C18))
                : theme.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : theme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBadge = false, bool isIncome = false}) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: theme.textSecondary,
          ),
        ),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isIncome
                  ? (isDark ? const Color(0xFF15803D).withValues(alpha: 0.25) : const Color(0xFFDCFCE7))
                  : theme.chipBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isIncome
                    ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                    : theme.textSecondary,
              ),
            ),
          )
        else
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ),
      ],
    );
  }

  void _showAddMethodDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ListenableBuilder(
        listenable: ThemeService.instance,
        builder: (context, _) {
          final theme = ThemeService.instance;
          final isDark = theme.isDarkMode;

          return StatefulBuilder(
            builder: (context, setSheetState) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? theme.border : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tambah Metode Pembayaran'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.chipBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 18, color: theme.iconColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Klik untuk memilih atau membatalkan pilihan dompet digital'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opsi 1: GoPay
                  _buildAddOptionTile(
                    ctx: ctx,
                    id: 'gopay',
                    title: 'GoPay',
                    assetPath: 'assets/images/gopay-seeklogo.png',
                    setSheetState: setSheetState,
                  ),
                  const SizedBox(height: 12),

                  // Opsi 2: OVO
                  _buildAddOptionTile(
                    ctx: ctx,
                    id: 'ovo',
                    title: 'OVO',
                    assetPath: 'assets/images/ovo-seeklogo.png',
                    setSheetState: setSheetState,
                  ),
                  const SizedBox(height: 12),

                  // Opsi 3: ShopeePay
                  _buildAddOptionTile(
                    ctx: ctx,
                    id: 'shopeepay',
                    title: 'ShopeePay',
                    assetPath: 'assets/images/shopee-pay-seeklogo.png',
                    setSheetState: setSheetState,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddOptionTile({
    required BuildContext ctx,
    required String id,
    required String title,
    required String assetPath,
    required StateSetter setSheetState,
  }) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
    final bool isSaved = _savedMethods.contains(id);

    return GestureDetector(
      onTap: () {
        if (isSaved) {
          // Klik kedua: UNSELECT / BATAL PILIH
          setState(() {
            _savedMethods.remove(id);
            PaymentMethodsBackend.instance.removeSavedMethod(id);
            if (_selectedMethod == id) {
              _selectedMethod = 'parksmart_pay';
              PaymentMethodsBackend.instance.setSelectedMethod('parksmart_pay');
            }
          });
          setSheetState(() {});
          _showSuccessToast('$title di-unselect & dihapus dari metode tersimpan');
        } else {
          // Klik pertama: SELECT / PILIH
          setState(() {
            _savedMethods.add(id);
            PaymentMethodsBackend.instance.addSavedMethod(id);
            _selectedMethod = id;
            PaymentMethodsBackend.instance.setSelectedMethod(id);
          });
          setSheetState(() {});
          _showSuccessToast('$title berhasil dipilih & ditambahkan');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSaved
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08))
              : theme.surfaceField,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSaved
                ? (isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF1C1C18).withValues(alpha: 0.35))
                : theme.border,
            width: isSaved ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Kiri gambar asset logo
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF262C36) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSaved
                      ? (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1))
                      : theme.border,
                ),
              ),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),

            // Kanan tulisan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (isSaved) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Tersimpan di metode Anda',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Indikator status kanan
            if (isSaved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 13, color: isDark ? Colors.black : Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Selected',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? theme.chipBg : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.border),
                ),
                child: Icon(
                  Icons.add,
                  size: 18,
                  color: theme.iconColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSuccessToast(String message) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final formattedBalance = _balance
            .toString()
            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            PaymentMethodsBackend.instance.setSelectedMethod(_selectedMethod);
            Navigator.pop(context, _selectedMethod);
          },
          child: Scaffold(
            backgroundColor: theme.bg,
            body: SafeArea(
              child: Column(
                children: [
                  // Top App Bar
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.bg.withValues(alpha: 0.95),
                      border: Border(bottom: BorderSide(color: theme.border)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            PaymentMethodsBackend.instance.setSelectedMethod(_selectedMethod);
                            Navigator.pop(context, _selectedMethod);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.chipBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_back, size: 20, color: theme.iconColor),
                          ),
                        ),
                        const SizedBox(width: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? theme.surfaceField : const Color(0xFF1C1C18).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.account_balance_wallet, size: 20, color: theme.iconColor),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Metode Pembayaran'.tr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Balance Card (Selalu bergradien premium gelap seperti Homescreen)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E242B), Color(0xFF0F1318)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? theme.border : Colors.transparent),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.wallet,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'ParkSmart Pay',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFC05621).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFC05621).withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'UTAMA'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: const Color(0xFFFFB088),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Saldo Aktif'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyService.instance.format(_balance),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  // Tombol Top Up Saldo
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _showTopUpSheet,
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add_circle_outline,
                                              size: 18,
                                              color: Color(0xFF111418),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Top Up Saldo'.tr,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF111418),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Tombol Riwayat
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _showHistorySheet,
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.history,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Riwayat'.tr,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Fitur Auto Debet
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.border),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC05621).withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.electric_bolt,
                                  size: 22,
                                  color: Color(0xFFC05621),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bayar Otomatis'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Bayar otomatis & potong saldo saat waktu parkir tersisa 5 menit'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: theme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _autoDebet,
                                activeThumbColor: const Color(0xFFC05621),
                                onChanged: (val) {
                                  setState(() => _autoDebet = val);
                                  _showSuccessToast(
                                    val ? 'Bayar otomatis diaktifkan'.tr : 'Bayar otomatis dinonaktifkan'.tr,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Section Heading: Metode Tersimpan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'METODE TERSIMPAN'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: theme.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showAddMethodDialog,
                              child: Text(
                                '+ Tambah'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE07A5F),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ParkSmart Pay radio option
                        _buildMethodTile(
                          id: 'parksmart_pay',
                          icon: Icons.account_balance_wallet,
                          title: 'ParkSmart Pay',
                          subtitle: 'Saldo Rp $formattedBalance',
                          badge: 'Utama',
                        ),

                        // GoPay Option (jika tersimpan)
                        if (_savedMethods.contains('gopay')) ...[
                          const SizedBox(height: 10),
                          _buildMethodTile(
                            id: 'gopay',
                            assetPath: 'assets/images/gopay-seeklogo.png',
                            title: 'GoPay',
                            subtitle: '0812-****-4321 · Terhubung',
                            badge: 'E-Wallet',
                          ),
                        ],

                        // OVO Option (jika tersimpan)
                        if (_savedMethods.contains('ovo')) ...[
                          const SizedBox(height: 10),
                          _buildMethodTile(
                            id: 'ovo',
                            assetPath: 'assets/images/ovo-seeklogo.png',
                            title: 'OVO',
                            subtitle: '0812-****-4321 · Terhubung',
                            badge: 'E-Wallet',
                          ),
                        ],

                        // ShopeePay Option (jika tersimpan)
                        if (_savedMethods.contains('shopeepay')) ...[
                          const SizedBox(height: 10),
                          _buildMethodTile(
                            id: 'shopeepay',
                            assetPath: 'assets/images/shopee-pay-seeklogo.png',
                            title: 'ShopeePay',
                            subtitle: '0812-****-4321 · Terhubung',
                            badge: 'E-Wallet',
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Button Tambah Metode Pembayaran Lain
                        GestureDetector(
                          onTap: _showAddMethodDialog,
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: theme.surfaceField,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.border,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 19,
                                  color: theme.textPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tambah Metode Pembayaran Lain'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMethodTile({
    required String id,
    String? assetPath,
    IconData? icon,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected && id != 'parksmart_pay') {
            // Klik lagi saat sudah terpilih: unselect kembali ke ParkSmart Pay
            _selectedMethod = 'parksmart_pay';
            PaymentMethodsBackend.instance.setSelectedMethod('parksmart_pay');
            _showSuccessToast('$title di-unselect (Kembali ke ParkSmart Pay)');
          } else {
            // Klik pertama: pilih metode ini
            _selectedMethod = id;
            PaymentMethodsBackend.instance.setSelectedMethod(id);
            _showSuccessToast('$title dipilih sebagai metode bayar');
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF262C36) : const Color(0xFFF9F7F2)) 
              : theme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected 
                ? (isDark ? const Color(0xFFE07A5F) : const Color(0xFF1C1C18)) 
                : theme.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: assetPath != null ? const EdgeInsets.all(6) : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: theme.chipBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: assetPath != null
                  ? Image.asset(assetPath, fit: BoxFit.contain)
                  : Icon(icon, size: 20, color: theme.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.chipBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? const Color(0xFFE07A5F) : const Color(0xFF1C1C18))
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? const Color(0xFFE07A5F) : const Color(0xFF1C1C18))
                      : theme.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 13,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
