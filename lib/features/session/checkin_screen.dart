import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import 'active_session_screen.dart';
import '../booking/backend/booking_confirmation_backend.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    BookingConfirmationBackend.instance.fetchLatestBooking();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleCheckin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      _showGateOpenModal();
    }
  }

  void _showGateOpenModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181C22) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: isDark ? const Border(top: BorderSide(color: Color(0xFF2D3542), width: 1.5)) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Indicator handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                  border: isDark ? Border.all(color: const Color(0xFF059669), width: 2) : null,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 36,
                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Palang Telah Terbuka',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan maju perlahan menuju Basement B2. Navigasi slot A-05 telah dipandu di layar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveSessionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F),
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lanjutkan Navigasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, BookingConfirmationBackend.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFF9F9F9),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E232B) : const Color(0xFFE8E8E8).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2D3542) : const Color(0xFFC3C6D1).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: isDark ? Colors.white : const Color(0xFF1A1C1C),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kembali',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1A1C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang di\nCentral Park Mall.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sistem ANPR mendeteksi plat nomor Anda pada radius 50 meter dari Gate 01 South Entrance.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Radar / Signal Graphic Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E232B) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 180,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 176,
                                        height: 176,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 144,
                                      height: 144,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? Colors.white24 : const Color(0xFF1C1D1F).withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 96,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF262C36) : const Color(0xFFFCF9F2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.directions_car,
                                        color: isDark ? Colors.black : Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF262C36) : const Color(0xFFFCF9F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, size: 14, color: Color(0xFF047857)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Terverifikasi Otomatis di Gerbang Masuk',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Jarak saat ini: ~15 meter ke portal palang',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Booking Detail Card (Dark mode styled, distinct from background)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E232B) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333D4E) : const Color(0xFFE5E2DB),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'KODE BOOKING',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        BookingConfirmationBackend.instance.bookingCode,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 13,
                                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Valid',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                                  height: 1,
                                ),
                              ),
                              Row(
                                children: [
                                  // Inner Box 1: Plat Nomor Kendaraan
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF28303C) : const Color(0xFFFCF9F2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF3D4758) : const Color(0xFFE5E2DB),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Plat Nomor Kendaraan',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            BookingConfirmationBackend.instance.plateNumber,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            BookingConfirmationBackend.instance.vehicleName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF45474A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Inner Box 2: Slot Reservasi
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF28303C) : const Color(0xFFFCF9F2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF3D4758) : const Color(0xFFE5E2DB),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Slot Reservasi',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline.alphabetic,
                                            children: [
                                              Text(
                                                BookingConfirmationBackend.instance.slotCode,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1C1D1F),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                BookingConfirmationBackend.instance.locationSub,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF76777B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.near_me,
                                                size: 12,
                                                color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                'Dekat Lift Utama',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
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
                              const SizedBox(height: 16),
                              // Inner Box 3: Info Box
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF28303C) : const Color(0xFFF6F3EC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF3D4758) : const Color(0xFFE5E2DB),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_rounded,
                                      size: 20,
                                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1C1D1F),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Palang akan terangkat otomatis saat plat nomor terbaca. Anda juga dapat menekan tombol di bawah bila sistem palang belum terbuka.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF45474A),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Actions: Tombol Masuk Gerbang PUTIH, font teks HITAM saat dark mode
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleCheckin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F),
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: isDark ? Colors.black : Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Masuk Gerbang & Buka Palang',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.black : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
