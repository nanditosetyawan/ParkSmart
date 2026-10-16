import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../home/home_screen.dart' as home;
import '../session/checkin_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                          borderRadius: AppRadii.pillRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 15,
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reservasi Berhasil',
                              style: AppTypography.caption(
                                color: isDark ? const Color(0xFF34D399) : const Color(0xFF4CAF50),
                              ).copyWith(fontWeight: FontWeight.w600),
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_parking,
                                    size: 20,
                                    color: isDark ? const Color(0xFFFB923C) : AppColors.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'DIGITAL PARKING PASS',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? theme.textSecondary : const Color(0xFF62615B),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadii.pillRadius,
                                  border: isDark ? null : Border.all(color: const Color(0xFFE5E2DB)),
                                ),
                                child: Text(
                                  '#PS-88210-CP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
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
                                        'Central Park Mall',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'South Lobby, Basement B2',
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
                                          'A-05',
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
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoBox(
                                      icon: Icons.directions_car,
                                      label: 'Kendaraan',
                                      title: 'Toyota Raize',
                                      subtitle: 'B 1234 XYZ',
                                      subtitleColor: isDark ? const Color(0xFFFB923C) : const Color(0xFFC05621),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoBox(
                                      icon: Icons.schedule,
                                      label: 'Waktu Valid',
                                      title: '14:00 - 16:00',
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
                  // Tombol Check-in: PUTIH dengan teks & panah HITAM saat dark mode
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckinScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : AppColors.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Check-in',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ],
                      ),
                    ),
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
