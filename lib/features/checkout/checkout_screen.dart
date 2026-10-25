import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../../core/utils/ticket_status_helper.dart';
import '../pin/pin_screen.dart';
import '../pin/backend/pin_backend.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../booking/booking_confirmation_screen.dart';
import '../profile/vehicle_screen.dart';
import '../profile/backend/vehicle_backend.dart';
import '../profile/payment_methods_screen.dart';
import '../profile/backend/payment_methods_backend.dart';
import 'backend/checkout_backend.dart';
import '../booking/backend/booking_confirmation_backend.dart';

const _kSurface = Color(0xFFFCF9F2);
const _kCard = Color(0xFFFFFFFF);
const _kSecondary = Color(0xFF9A442D);
const _kSecondaryFixed = Color(0xFFFFDBD2);
const _kPrimaryContainer = Color(0xFF1C1D1F);
const _kSurfaceContainerLow = Color(0xFFF6F3EC);
const _kSurfaceContainerHigh = Color(0xFFEBE8E1);
const _kOnSurfaceVariant = Color(0xFF45474A);
const _kOutline = Color(0xFF76777B);

class CheckoutScreen extends StatefulWidget {
  final String? existingBookingId;
  const CheckoutScreen({super.key, this.existingBookingId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Timer? _countdownTimer;
  int _remainingSeconds = 179; // 2 menit 59 detik

  @override
  void initState() {
    super.initState();
    _initCheckoutAndHold();
  }

  Future<void> _initCheckoutAndHold() async {
    if (widget.existingBookingId != null && widget.existingBookingId!.isNotEmpty) {
      // 1. Dibuka dari riwayat (Belum Dibayar)
      final ok = await CheckoutBackend.instance.loadFromExistingBooking(widget.existingBookingId!);
      await CheckoutBackend.instance.fetchCheckoutData();

      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data booking tidak ditemukan atau sudah dibatalkan.'.tr)),
        );
        Navigator.pop(context);
        return;
      }

      final createdAt = CheckoutBackend.instance.holdCreatedAt ?? DateTime.now();
      final elapsed = DateTime.now().difference(createdAt).inSeconds;
      final remaining = 179 - elapsed;

      if (remaining <= 0) {
        await CheckoutBackend.instance.cancelHoldBooking();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Batas waktu pembayaran (02:59) telah habis. Slot telah dilepas.'.tr),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      if (mounted) {
        setState(() {
          _remainingSeconds = remaining;
        });
        _startTimer();
      }
    } else {
      // 2. Pertama kali masuk checkout dari pemilihan slot
      await CheckoutBackend.instance.fetchCheckoutData();
      final ok = await CheckoutBackend.instance.createHoldBooking();
      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Slot ini sudah dibooking orang lain atau terjadi kendala. Silakan pilih jadwal/slot lain.'.tr),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pop(context);
        return;
      }

      setState(() {
        _remainingSeconds = 179;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          if (_remainingSeconds == 0) {
            timer.cancel();
            _onTimerExpired();
          }
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _onTimerExpired() async {
    await CheckoutBackend.instance.cancelHoldBooking();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waktu penahanan slot habis (02:59). Slot telah dilepas.'.tr),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _timerDisplay {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeService.instance,
        CheckoutBackend.instance,
        CurrencyService.instance,
        LanguageService.instance,
        PaymentMethodsBackend.instance,
      ]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : _kSurface,
          body: Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 80, 20, 120),
                children: [
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF451A1A) : _kSecondaryFixed,
                          borderRadius: AppRadii.pillRadius,
                          border: Border.all(color: isDark ? const Color(0xFFF97316) : const Color(0xFFE5A99C)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFFFB923C) : _kSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${'Slot Ditahan'.tr} ($_timerDisplay)',
                              style: AppTypography.overline(
                                color: isDark ? const Color(0xFFFED7AA) : const Color(0xFF742814),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Langkah 3 dari 3'.tr,
                        style: AppTypography.caption(
                          color: isDark ? theme.textMuted : _kOutline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Konfirmasi\nReservasi'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tinjau detail parkir pintar Anda sebelum pembayaran otomatis diproses.'.tr,
                    style: AppTypography.bodySm(
                      color: isDark ? theme.textMuted : _kOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Reservation Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : _kCard,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          offset: const Offset(0, 12),
                          blurRadius: 32,
                          spreadRadius: -8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF262C36) : _kSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? const Color(0xFF3B4454) : const Color(0xFFE5E2DB)),
                              ),
                              child: Icon(
                                Icons.local_parking,
                                size: 26,
                                color: isDark ? const Color(0xFF2DD4BF) : _kSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LOKASI TERPILIH'.tr,
                                    style: AppTypography.overline(
                                      color: isDark ? const Color(0xFF94A3B8) : _kOutline,
                                    ),
                                  ),
                                  Text(
                                    CheckoutBackend.instance.locationName.tr,
                                    style: AppTypography.headlineSm(
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E3848) : _kSurfaceContainerHigh,
                                borderRadius: AppRadii.pillRadius,
                                border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFD5D0C6)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timelapse,
                                    size: 16,
                                    color: isDark ? const Color(0xFFFB923C) : _kSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${CheckoutBackend.instance.durationHours} Jam'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Image with overlay
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDT0ZoyfWQcaEzs6MHLz6cuAXmKYUfHvadgETmWMtDwDuHAQhgcLiExY2mDLfNdWUdhWJoyC0sIf_osQTNETlWG6QXuvrzt9oCMDE4d0CREPiJpum3drIn1rtXLXgLl4HsnxtgkPgDgSOSnvn7RdMvWizDgqYP7xfa9hk9A9VxzxR2LlzGcOZRirFyUW3QE4M98E7yAJBDEjo9mQJ74n_PbHdd95axOTGk3heFrVOSVwgMXU9tAad86',
                                width: double.infinity,
                                height: 144,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 144,
                                  color: isDark ? const Color(0xFF1E293B) : _kSurfaceContainerLow,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        (isDark ? theme.card : _kPrimaryContainer).withValues(alpha: 0.85),
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Zona Parkir'.tr,
                                            style: AppTypography.overline(
                                              color: Colors.white.withValues(alpha: 0.9),
                                            ),
                                          ),
                                          Text(
                                            '${CheckoutBackend.instance.floorName.tr} - Slot ${CheckoutBackend.instance.slotCode} • ${CheckoutBackend.instance.slotType.tr}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Jadwal selector
                        const _JadwalSelector(),
                        const SizedBox(height: 8),

                        // Kendaraan terdaftar
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2E3848) : const Color(0xFFF7F5EE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF475569) : const Color(0xFFE2DDD2),
                            ),
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final selected = await Navigator.push<dynamic>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const VehicleScreen(isSelectionMode: true)),
                                );
                                if (selected != null) {
                                  if (selected is VehicleItem) {
                                    CheckoutBackend.instance.selectVehicle({
                                      'id': selected.id,
                                      'brand': selected.brand,
                                      'model': selected.model,
                                      'plate_number': selected.plateNumber,
                                      'vehicle_type': selected.vehicleType,
                                      'vehicle_category': selected.category,
                                      'color': selected.color,
                                    });
                                  } else if (selected is Map<String, dynamic>) {
                                    CheckoutBackend.instance.selectVehicle(selected);
                                  }
                                  if (mounted) setState(() {});
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E232B) : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: isDark ? const Color(0xFF3B4454) : const Color(0xFFE2DDD2)),
                                      ),
                                      child: Icon(
                                        Icons.directions_car_rounded,
                                        size: 20,
                                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1C1D1F),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'KENDARAAN TERDAFTAR'.tr,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            CheckoutBackend.instance.selectedVehicle != null
                                                ? '${CheckoutBackend.instance.selectedVehicle!['brand'] ?? ''} ${CheckoutBackend.instance.selectedVehicle!['model'] ?? ''}'.trim()
                                                : 'Pilih Kendaraan Anda'.tr,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E232B) : Colors.white,
                                        borderRadius: AppRadii.pillRadius,
                                        border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFC6C6CA)),
                                      ),
                                      child: Text(
                                        CheckoutBackend.instance.selectedVehicle != null
                                            ? (CheckoutBackend.instance.selectedVehicle!['plate_number'] ?? '-')
                                            : '+ Pilih',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                      color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Card
                  Builder(
                    builder: (context) {
                      final balance = CheckoutBackend.instance.walletBalance;
                      final selectedMethod = PaymentMethodsBackend.instance.selectedMethod;
                      final isParkSmart = selectedMethod == 'parksmart_pay' || selectedMethod == 'wallet';

                      String methodName = 'ParkSmart Wallet';
                      String methodSubtitle = '${'Saldo'.tr}: ${CurrencyService.instance.format(balance)}';
                      Widget methodIconWidget;

                      if (selectedMethod == 'gopay') {
                        methodName = 'GoPay';
                        methodSubtitle = '';
                        methodIconWidget = Image.asset('assets/images/gopay-seeklogo.png', fit: BoxFit.contain);
                      } else if (selectedMethod == 'ovo') {
                        methodName = 'OVO';
                        methodSubtitle = '';
                        methodIconWidget = Image.asset('assets/images/ovo-seeklogo.png', fit: BoxFit.contain);
                      } else if (selectedMethod == 'shopeepay') {
                        methodName = 'ShopeePay';
                        methodSubtitle = '';
                        methodIconWidget = Image.asset('assets/images/shopee-pay-seeklogo.png', fit: BoxFit.contain);
                      } else {
                        methodName = 'ParkSmart Wallet';
                        methodSubtitle = '${'Saldo'.tr}: ${CurrencyService.instance.format(balance)}';
                        methodIconWidget = Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 22,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                        );
                      }

                      return GestureDetector(
                        onTap: () async {
                          final chosen = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                          );
                          if (chosen != null) {
                            PaymentMethodsBackend.instance.setSelectedMethod(chosen);
                          }
                          await CheckoutBackend.instance.fetchCheckoutData();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : _kCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFFE2DDD2),
                              width: 1,
                            ),
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                padding: isParkSmart ? EdgeInsets.zero : const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: isParkSmart
                                      ? (isDark ? const Color(0xFF134E4A) : const Color(0xFFCCFBF1))
                                      : (isDark ? const Color(0xFF262C36) : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? theme.border : const Color(0xFFE2DDD2),
                                  ),
                                ),
                                child: Center(child: methodIconWidget),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'METODE PEMBAYARAN'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      methodName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    if (methodSubtitle.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        methodSubtitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isParkSmart
                                              ? (isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A))
                                              : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark ? theme.surfaceField : const Color(0xFFF1EFE9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 22,
                                  color: isDark ? Colors.white70 : const Color(0xFF1C1D1F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pricing Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : _kCard,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: const [AppShadows.soft],
                    ),
                    child: Column(
                      children: [
                        _priceRow('Tarif Parkir (${CheckoutBackend.instance.durationHours} Jam • ${CheckoutBackend.instance.slotType})'.tr, CurrencyService.instance.format(CheckoutBackend.instance.subtotal), isDark: isDark),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            color: isDark ? theme.border : const Color(0xFFEAE5DC),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL PEMBAYARAN'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              CurrencyService.instance.format(CheckoutBackend.instance.totalPayment),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFFFB923C) : _kSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Fixed Top Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: isDark ? theme.bg : _kSurface,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF262C36) : const Color(0xFFEBE8E1),
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFD5D0C6)),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Checkout'.tr,
                            style: AppTypography.headlineSm(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Floating Action Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E232B) : _kSurface,
                      border: Border(top: BorderSide(color: isDark ? theme.border : const Color(0xFFEAE5DC))),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          // 0. Validasi saldo HANYA jika metode bayar adalah ParkSmart Pay / Wallet
                          final selectedMethod = PaymentMethodsBackend.instance.selectedMethod;
                          final isParkSmart = selectedMethod == 'parksmart_pay' || selectedMethod == 'wallet';

                          if (isParkSmart) {
                            final currentBal = CheckoutBackend.instance.walletBalance;
                            final totalPay = CheckoutBackend.instance.totalPayment;
                            if (currentBal < totalPay) {
                              // Alihkan ke halaman metode bayar dengan posisi pop up halaman top up sambil ada tulisan tipis saldo tidak cukup
                              final chosen = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PaymentMethodsScreen(
                                    autoOpenTopUp: true,
                                    topUpReason: 'Saldo tidak cukup untuk pembayaran ini',
                                  ),
                                ),
                              );
                              if (chosen != null) {
                                PaymentMethodsBackend.instance.setSelectedMethod(chosen);
                              }
                              await CheckoutBackend.instance.fetchCheckoutData();
                              return;
                            }
                          }
                          // Jika metode selain ParkSmart (GoPay, OVO, ShopeePay), tidak perlu validasi saldo user! Langsung lolos.

                          final now = DateTime.now();
                          final start = CheckoutBackend.instance.scheduledStartTime ?? now;
                          final end = CheckoutBackend.instance.scheduledEndTime ??
                              start.add(Duration(hours: CheckoutBackend.instance.durationHours));

                          // 1. Validasi jam masuk tidak di masa lalu
                          if (start.isBefore(now.subtract(const Duration(minutes: 2)))) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Jam masuk tidak boleh di masa lalu. Silakan atur ulang jam masuk.'.tr),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          // 2. Validasi ketat bentrok slot jam yang sudah diambil
                          final hasConflict = await CheckoutBackend.instance.checkSlotConflict(
                            startTime: start,
                            endTime: end,
                          );

                          if (hasConflict) {
                            if (context.mounted) {
                              final availableSlots = await CheckoutBackend.instance.getAvailableTimeSlotsToday();
                              if (context.mounted) {
                                final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
                                final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogCtx) => _SlotConflictDialog(
                                    slotCode: CheckoutBackend.instance.slotCode,
                                    startStr: startStr,
                                    endStr: endStr,
                                    availableSlots: availableSlots,
                                    onSelectWindow: (w) {
                                      CheckoutBackend.instance.setBookingDetails(
                                        startTime: w.start,
                                        endTime: w.end,
                                        durationHours: (w.end.difference(w.start).inMinutes / 60.0).ceil().clamp(1, 24),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${'Jadwal dialihkan ke'.tr} ${w.label}'),
                                          backgroundColor: const Color(0xFF17A18A),
                                        ),
                                      );
                                    },
                                    onChooseOtherSlot: () {
                                      Navigator.pop(dialogCtx);
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              }
                            }
                            return; // JANGAN DILOLOSKAN PAYMENT!
                          }

                          final booking = await CheckoutBackend.instance.confirmAndCreateBooking();
                          if (booking == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal membuat pesanan. Slot mungkin baru saja dibooking pengguna lain.'.tr),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                            return;
                          }

                          final veh = CheckoutBackend.instance.selectedVehicle;
                          final vehicleName = veh != null ? '${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim() : 'Toyota Land Cruiser';
                          final plateNumber = veh != null ? (veh['plate_number'] ?? 'B 1945 RI') : 'B 1945 RI';
                          final bId = booking['id']?.toString();

                          final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
                          final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

                          BookingConfirmationBackend.instance.setConfirmedPass(
                            bookingCode: booking['booking_code'] ?? '#PS-88210-CP',
                            locationName: CheckoutBackend.instance.locationName.tr,
                            locationSub: '${CheckoutBackend.instance.floorName}, Slot ${CheckoutBackend.instance.slotCode}',
                            slotCode: CheckoutBackend.instance.slotCode,
                            vehicleName: vehicleName.isNotEmpty ? vehicleName : 'Toyota Land Cruiser',
                            plateNumber: plateNumber,
                            validTime: '$startStr - $endStr WIB',
                            bookingId: bId,
                            ticketStatus: TicketMark.belumDibayar,
                            totalPrice: CheckoutBackend.instance.totalPayment,
                          );

                          if (context.mounted) {
                            final hasPin = await PinBackend.instance.hasPin();
                            if (!context.mounted) return;

                            final paymentPinScreen = PinScreen(
                              bookingId: bId,
                              nextScreen: BookingConfirmationScreen(bookingId: bId),
                              transactionType: 'parkir',
                              customTitle: 'Konfirmasi PIN Pembayaran'.tr,
                            );

                            if (!hasPin) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PinScreen(
                                    transactionType: 'buat pin',
                                    customTitle: 'Buat PIN Transaksi'.tr,
                                    backToHome: false,
                                    nextScreen: paymentPinScreen,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => paymentPinScreen,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 2,
                          shadowColor: isDark ? Colors.white24 : Colors.black26,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 18,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Konfirmasi Bayar Sekarang'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _priceRow(String label, String val, {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1C1D1F),
            ),
          ),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1C1D1F),
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog Peringatan Bentrok Jadwal & Rekomendasi Jam Kosong Hari Ini
class _SlotConflictDialog extends StatelessWidget {
  final String slotCode;
  final String startStr;
  final String endStr;
  final List<AvailableTimeWindow> availableSlots;
  final ValueChanged<AvailableTimeWindow> onSelectWindow;
  final VoidCallback onChooseOtherSlot;

  const _SlotConflictDialog({
    required this.slotCode,
    required this.startStr,
    required this.endStr,
    required this.availableSlots,
    required this.onSelectWindow,
    required this.onChooseOtherSlot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E232B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Icon & Title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_busy_rounded,
                    color: Colors.redAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot Penuh pada Jam Tersebut'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Slot $slotCode sudah terisi untuk $startStr - $endStr'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? const Color(0xFF333C4A) : const Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 14),

            Text(
              availableSlots.isEmpty
                  ? 'Status Ketersediaan Hari Ini:'.tr
                  : 'Pilih Jadwal Jam Tersedia Hari Ini:'.tr,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 10),

            // Scrollable list of available slots
            if (availableSlots.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262C36) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.do_not_disturb_on_rounded, size: 32, color: Colors.redAccent),
                    const SizedBox(height: 8),
                    Text(
                      'Slot ini sudah penuh total untuk sisa hari ini.'.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan kembali dan pilih slot parkir lain.'.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: availableSlots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final window = availableSlots[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262C36) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF17A18A).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.access_time_filled_rounded,
                              size: 18,
                              color: Color(0xFF17A18A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  window.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${'Tersedia'.tr} (${window.durationLabel.tr})',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF17A18A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              onSelectWindow(window);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF17A18A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Pilih'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onChooseOtherSlot,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : const Color(0xFF475569),
                      side: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Pilih Slot Lain'.tr,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (availableSlots.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF114177),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Atur Jam Manual'.tr,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JadwalSelector extends StatefulWidget {
  const _JadwalSelector();
  @override
  State<_JadwalSelector> createState() => _JadwalSelectorState();
}

class _JadwalSelectorState extends State<_JadwalSelector> {
  late TimeOfDay _arrivalTime;
  late TimeOfDay _departureTime;

  @override
  void initState() {
    super.initState();
    CheckoutBackend.instance.addListener(_onBackendDetailsChanged);
    _initTimes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncToBackend();
      _checkAndShowConflictModal();
    });
  }

  @override
  void dispose() {
    CheckoutBackend.instance.removeListener(_onBackendDetailsChanged);
    super.dispose();
  }

  void _onBackendDetailsChanged() {
    final start = CheckoutBackend.instance.scheduledStartTime;
    final end = CheckoutBackend.instance.scheduledEndTime;
    if (start != null && end != null) {
      final newArr = TimeOfDay(hour: start.hour, minute: start.minute);
      final newDep = TimeOfDay(hour: end.hour, minute: end.minute);
      if (newArr != _arrivalTime || newDep != _departureTime) {
        if (mounted) {
          setState(() {
            _arrivalTime = newArr;
            _departureTime = newDep;
          });
        }
      }
    }
  }

  void _initTimes() {
    final now = DateTime.now();
    final bStart = CheckoutBackend.instance.scheduledStartTime ?? now;
    final effectiveStart = bStart.isBefore(now) ? now : bStart;

    _arrivalTime = TimeOfDay(hour: effectiveStart.hour, minute: effectiveStart.minute);

    final endHour = (_arrivalTime.hour + 1).clamp(0, 23);
    final endMinute = endHour == 23 ? 59 : _arrivalTime.minute;
    _departureTime = TimeOfDay(hour: endHour, minute: endMinute);
  }

  int _calculateDuration(TimeOfDay inTime, TimeOfDay outTime) {
    int inMinutes = inTime.hour * 60 + inTime.minute;
    int outMinutes = outTime.hour * 60 + outTime.minute;
    if (outMinutes <= inMinutes) {
      outMinutes = (inMinutes + 60).clamp(0, 23 * 60 + 59);
    }
    final diff = outMinutes - inMinutes;
    final hours = (diff / 60.0).ceil();
    return hours < 1 ? 1 : hours;
  }

  void _syncToBackend() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, _arrivalTime.hour, _arrivalTime.minute);
    var end = DateTime(now.year, now.month, now.day, _departureTime.hour, _departureTime.minute);

    // Tetap pada hari yang sama (maksimal 23:59 hari ini)
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      if (start.hour >= 23) {
        end = DateTime(now.year, now.month, now.day, 23, 59);
      } else {
        end = DateTime(now.year, now.month, now.day, start.hour + 1, start.minute);
      }
    }

    final hours = _calculateDuration(_arrivalTime, _departureTime);
    CheckoutBackend.instance.setBookingDetails(
      durationHours: hours,
      startTime: start,
      endTime: end,
    );
  }

  Future<void> _checkAndShowConflictModal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, _arrivalTime.hour, _arrivalTime.minute);
    final end = DateTime(now.year, now.month, now.day, _departureTime.hour, _departureTime.minute);

    final hasConflict = await CheckoutBackend.instance.checkSlotConflict(
      startTime: start,
      endTime: end,
    );

    if (hasConflict && mounted) {
      final availableSlots = await CheckoutBackend.instance.getAvailableTimeSlotsToday();
      if (!mounted) return;
      _showConflictDialog(availableSlots, start, end);
    }
  }

  void _showConflictDialog(List<AvailableTimeWindow> availableSlots, DateTime start, DateTime end) {
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SlotConflictDialog(
        slotCode: CheckoutBackend.instance.slotCode,
        startStr: startStr,
        endStr: endStr,
        availableSlots: availableSlots,
        onSelectWindow: (window) {
          setState(() {
            _arrivalTime = TimeOfDay(hour: window.start.hour, minute: window.start.minute);
            _departureTime = TimeOfDay(hour: window.end.hour, minute: window.end.minute);
            _syncToBackend();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${'Jadwal dialihkan ke'.tr} ${window.label}'),
              backgroundColor: const Color(0xFF17A18A),
            ),
          );
        },
        onChooseOtherSlot: () {
          Navigator.pop(ctx);
          Navigator.pop(context); // Kembali ke denah slot
        },
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(TimeOfDay initial, String title) async {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: title,
      builder: (context, child) {
        if (isDark) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF2DD4BF),
                onPrimary: Color(0xFF0F172A),
                surface: Color(0xFF1E232B),
                onSurface: Colors.white,
              ),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: const Color(0xFF1E232B),
                hourMinuteColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF333C4A);
                  }
                  return const Color(0xFF262C36);
                }),
                hourMinuteTextColor: Colors.white,
                hourMinuteShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                dayPeriodColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF2DD4BF);
                  }
                  return const Color(0xFF262C36);
                }),
                dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF0F172A);
                  }
                  return Colors.white;
                }),
                dayPeriodBorderSide: const BorderSide(color: Color(0xFF2D3542)),
                dayPeriodShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                dialBackgroundColor: const Color(0xFF262C36),
                dialHandColor: const Color(0xFF2DD4BF),
                dialTextColor: Colors.white,
                entryModeIconColor: Colors.white70,
                helpTextStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                cancelButtonStyle: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF94A3B8),
                ),
                confirmButtonStyle: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2DD4BF),
                ),
              ),
            ),
            child: child!,
          );
        }

        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kPrimaryContainer,
              onPrimary: Colors.white,
              surface: _kSurface,
              onSurface: _kOnSurfaceVariant,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: _kSurface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dayPeriodBorderSide: const BorderSide(color: _kPrimaryContainer),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              dialHandColor: _kPrimaryContainer,
              dialBackgroundColor: _kCard,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _showArrivalTimePicker() async {
    final selectedTime = await _pickTime(_arrivalTime, 'PILIH JAM KEDATANGAN (HARI INI)'.tr);
    if (selectedTime == null) return;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final selMinutes = selectedTime.hour * 60 + selectedTime.minute;

    // Batasi jam tidak boleh di masa lalu (toleransi 1 menit jika tepat pada menit saat ini)
    if (selMinutes < nowMinutes - 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jam masuk tidak boleh di masa lalu (Jam saat ini ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}).'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Batas maksimal masuk hari ini 23:45
    if (selMinutes >= 23 * 60 + 55) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maksimal jam kedatangan pukul 23:45 untuk pemesanan hari ini.'.tr),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() {
      _arrivalTime = selectedTime;
      final depMinutes = _departureTime.hour * 60 + _departureTime.minute;
      if (depMinutes <= selMinutes) {
        final newDepHour = (_arrivalTime.hour + 1).clamp(0, 23);
        final newDepMinute = newDepHour == 23 ? 59 : _arrivalTime.minute;
        _departureTime = TimeOfDay(hour: newDepHour, minute: newDepMinute);
      }
      _syncToBackend();
    });

    _checkAndShowConflictModal();
  }

  void _showDepartureTimePicker() async {
    final selectedTime = await _pickTime(_departureTime, 'PILIH JAM KELUAR (HARI INI)'.tr);
    if (selectedTime == null) return;

    final arrMinutes = _arrivalTime.hour * 60 + _arrivalTime.minute;
    final selMinutes = selectedTime.hour * 60 + selectedTime.minute;

    if (selMinutes <= arrMinutes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jam keluar harus setelah jam masuk (${_arrivalTime.hour.toString().padLeft(2, '0')}:${_arrivalTime.minute.toString().padLeft(2, '0')}) dan maksimal 23:59 hari ini.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() {
      _departureTime = selectedTime;
      _syncToBackend();
    });

    _checkAndShowConflictModal();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    final durationHours = _calculateDuration(_arrivalTime, _departureTime);
    final startStr = '${_arrivalTime.hour.toString().padLeft(2, '0')}:${_arrivalTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${_departureTime.hour.toString().padLeft(2, '0')}:${_departureTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E3848) : const Color(0xFFF7F5EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2DDD2),
        ),
        boxShadow: const [AppShadows.soft],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF38BDF8) : _kPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'JADWAL RESERVASI'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E232B) : Colors.white,
                  borderRadius: AppRadii.pillRadius,
                  border: Border.all(
                    color: isDark ? const Color(0xFF2DD4BF) : _kPrimaryContainer,
                  ),
                ),
                child: Text(
                  '$durationHours Jam Durasi'.tr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF2DD4BF) : _kPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Jam Kedatangan Card
              Expanded(
                child: InkWell(
                  onTap: _showArrivalTimePicker,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E232B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3B4454) : const Color(0xFFE2DDD2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.login_rounded, size: 13, color: isDark ? const Color(0xFF38BDF8) : _kPrimaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              'JAM MASUK'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$startStr WIB',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Icon(Icons.edit, size: 12, color: isDark ? const Color(0xFF2DD4BF) : _kPrimaryContainer),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                ),
              ),
              // Jam Keluar Card
              Expanded(
                child: InkWell(
                  onTap: _showDepartureTimePicker,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E232B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3B4454) : const Color(0xFFE2DDD2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 13, color: isDark ? const Color(0xFFFB923C) : _kSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'JAM KELUAR'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$endStr WIB',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Icon(Icons.edit, size: 12, color: isDark ? const Color(0xFFFB923C) : _kSecondary),
                          ],
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
    );
  }
}
