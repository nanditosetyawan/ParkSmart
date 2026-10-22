import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/utils/ticket_status_helper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../home/home_screen.dart' as home;
import '../pin/pin_screen.dart';
import '../pin/backend/pin_backend.dart';
import '../session/checkin_screen.dart';
import 'backend/booking_confirmation_backend.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String? bookingId;
  const BookingConfirmationScreen({super.key, this.bookingId});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    BookingConfirmationBackend.instance.fetchLatestBooking(bookingId: widget.bookingId);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _getRemainingSeconds(DateTime? createdAt) {
    if (createdAt == null) return 179;
    final diff = DateTime.now().difference(createdAt).inSeconds;
    return (179 - diff).clamp(0, 179);
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, BookingConfirmationBackend.instance, CurrencyService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        final backend = BookingConfirmationBackend.instance;
        if (!backend.isLoading && !backend.hasBooking) {
          return Scaffold(
            backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Konfirmasi Reservasi',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF1EEE7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        size: 64,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tidak Ada Reservasi Aktif',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anda belum memiliki tiket reservasi parkir yang sedang diproses.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Kembali ke Beranda'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF020304),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final isUnpaid = backend.ticketStatus == TicketMark.belumDibayar;
                      final remainingSec = _getRemainingSeconds(backend.createdAt);
                      final timerStr = _formatTimer(remainingSec);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _NavBtn(
                                icon: Icons.arrow_back,
                                isDark: isDark,
                                onTap: () => Navigator.pop(context),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isUnpaid
                                      ? (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2))
                                      : (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)),
                                  borderRadius: AppRadii.pillRadius,
                                  border: Border.all(
                                    color: isUnpaid
                                        ? (isDark ? const Color(0xFFEF4444).withValues(alpha: 0.5) : const Color(0xFFFCA5A5))
                                        : (isDark ? const Color(0xFF34D399).withValues(alpha: 0.5) : const Color(0xFFA7F3D0)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUnpaid ? Icons.timer_outlined : Icons.check_circle,
                                      size: 15,
                                      color: isUnpaid
                                          ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                                          : (isDark ? const Color(0xFF34D399) : const Color(0xFF4CAF50)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isUnpaid ? 'Belum Bayar • $timerStr' : 'Reservasi Berhasil',
                                      style: AppTypography.caption(
                                        color: isUnpaid
                                            ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                                            : (isDark ? const Color(0xFF34D399) : const Color(0xFF4CAF50)),
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              _NavBtn(
                                icon: Icons.share_outlined,
                                isDark: isDark,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          if (isUnpaid) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? const Color(0xFFD97706).withValues(alpha: 0.6) : const Color(0xFFF59E0B),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_top_rounded,
                                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selesaikan Pembayaran ($timerStr)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Slot parkir Anda ter-booking selama 2:59 menit. Segera selesaikan pembayaran.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      );
                    },
                  ),

                  // Hero Text
                  Text(
                    'KONFIRMASI KEDATANGAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFFB923C) : AppColors.secondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Slot Siap\nUntuk Anda.',
                    style: AppTypography.displayHero().copyWith(
                      fontSize: 34,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Akses parkir tanpa sentuh aktif otomatis di gerbang masuk.',
                    style: AppTypography.bodySm(
                      color: isDark ? theme.textMuted : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Floating Digital Parking Pass Ticket (TETAP PUTIH DENGAN TEKS SANGAT JELAS)
                  // Floating Digital Parking Pass Ticket (Agak abu-abu di dark mode, selaras dengan kartu lain)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? theme.border : const Color(0xFFE5E2DB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top Header Ribbon
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : Colors.white,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            border: Border(bottom: BorderSide(color: isDark ? theme.border : const Color(0xFFF1EEE7))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_parking,
                                      size: 20,
                                      color: isDark ? const Color(0xFFFB923C) : AppColors.secondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'DIGITAL PARKING PASS',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? theme.textSecondary : const Color(0xFF62615B),
                                          letterSpacing: 1.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TicketMark.getBgColor(BookingConfirmationBackend.instance.ticketStatus, isDark: isDark),
                                  borderRadius: AppRadii.pillRadius,
                                  border: Border.all(color: TicketMark.getBorderColor(BookingConfirmationBackend.instance.ticketStatus, isDark: isDark)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(TicketMark.getIcon(BookingConfirmationBackend.instance.ticketStatus), size: 12, color: TicketMark.getColor(BookingConfirmationBackend.instance.ticketStatus)),
                                    const SizedBox(width: 4),
                                    Text(
                                      BookingConfirmationBackend.instance.ticketStatus,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: TicketMark.getColor(BookingConfirmationBackend.instance.ticketStatus),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Ticket Details (Teks kontras dan jelas di atas kartu)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'LOKASI PARKIR',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? theme.textSecondary : const Color(0xFF7A7874),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        BookingConfirmationBackend.instance.locationName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        BookingConfirmationBackend.instance.locationSub,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: isDark ? theme.textSecondary : const Color(0xFF7A7874),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF9A442D).withValues(alpha: 0.25)
                                          : const Color(0xFFFDE8E1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: isDark
                                          ? Border.all(color: const Color(0xFF9A442D).withValues(alpha: 0.5))
                                          : null,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'SLOT',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFFFB923C) : const Color(0xFFC05621),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          BookingConfirmationBackend.instance.slotCode,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? const Color(0xFFFB923C) : const Color(0xFFC05621),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Plat Nomor di bawah tulisan Lantai 1 dan di atas Kendaraan
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? theme.surfaceField : const Color(0xFFF6F4EE),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? theme.border : const Color(0xFFE5E2DB),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.credit_card_outlined,
                                          size: 16,
                                          color: isDark ? const Color(0xFFFB923C) : const Color(0xFFC05621),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'PLAT NOMOR',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            color: isDark ? theme.textSecondary : const Color(0xFF7A7874),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFD1D5DB),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Text(
                                        BookingConfirmationBackend.instance.plateNumber,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoBox(
                                      icon: Icons.directions_car,
                                      label: 'Kendaraan',
                                      title: BookingConfirmationBackend.instance.vehicleName,
                                      subtitle: 'Kode: ${BookingConfirmationBackend.instance.bookingCode}',
                                      subtitleColor: isDark ? const Color(0xFFFB923C) : const Color(0xFFC05621),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoBox(
                                      icon: Icons.schedule,
                                      label: 'Waktu Valid',
                                      title: BookingConfirmationBackend.instance.validTime,
                                      subtitle: 'Toleransi +15 mnt',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CTA Buttons
                  Builder(
                    builder: (context) {
                      final isUnpaid = backend.ticketStatus == TicketMark.belumDibayar;
                      final remainingSec = _getRemainingSeconds(backend.createdAt);
                      final timerStr = _formatTimer(remainingSec);

                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isUnpaid
                              ? () async {
                                  final hasPin = await PinBackend.instance.hasPin();
                                  if (!context.mounted) return;

                                  final paymentPinScreen = PinScreen(
                                    bookingId: backend.bookingId,
                                    transactionType: 'parkir',
                                    customTitle: 'Konfirmasi PIN Pembayaran',
                                    nextScreen: CheckinScreen(bookingId: backend.bookingId),
                                  );

                                  if (!hasPin) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PinScreen(
                                          transactionType: 'buat pin',
                                          customTitle: 'Buat PIN Transaksi',
                                          backToHome: false,
                                          nextScreen: paymentPinScreen,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => paymentPinScreen,
                                      ),
                                    );
                                  }
                                }
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CheckinScreen(bookingId: backend.bookingId),
                                    ),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUnpaid
                                ? const Color(0xFFDC2626)
                                : (isDark ? Colors.white : AppColors.primary),
                            foregroundColor: isUnpaid ? Colors.white : (isDark ? Colors.black : Colors.white),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isUnpaid ? 'Bayar Sekarang ($timerStr)' : 'Check-in',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isUnpaid ? Colors.white : (isDark ? Colors.black : Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isUnpaid ? Icons.payment_outlined : Icons.arrow_forward,
                                size: 20,
                                color: isUnpaid ? Colors.white : (isDark ? Colors.black : Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Tombol Simpan Saja: Transparan dengan outline putih dan teks putih saat dark mode
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const home.HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? Colors.transparent : const Color(0xFFF1EEE7),
                        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
                        side: BorderSide(
                          color: isDark ? Colors.white : Colors.transparent,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 20,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Simpan Saja',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _NavBtn({required this.icon, required this.onTap, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? theme.card : AppColors.surfaceCard,
          shape: BoxShape.circle,
          border: isDark ? Border.all(color: theme.border) : null,
          boxShadow: const [AppShadows.soft],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final Color? subtitleColor;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardAlt : const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? theme.border : const Color(0xFFEBE6DC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? theme.textSecondary : const Color(0xFF7A7874),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? theme.textSecondary : const Color(0xFF7A7874),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: subtitleColor ?? (isDark ? theme.textSecondary : const Color(0xFF7A7874)),
            ),
          ),
        ],
      ),
    );
  }
}
