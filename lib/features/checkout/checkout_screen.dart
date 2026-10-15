import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../pin/pin_screen.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../booking/booking_confirmation_screen.dart';
import '../profile/vehicle_screen.dart';

const _kSurface = Color(0xFFFCF9F2);
const _kCard = Color(0xFFFFFFFF);
const _kSecondary = Color(0xFF9A442D);
const _kSecondaryFixed = Color(0xFFFFDBD2);
const _kPrimaryContainer = Color(0xFF1C1D1F);
const _kSurfaceContainerLow = Color(0xFFF6F3EC);
const _kSurfaceContainerHigh = Color(0xFFEBE8E1);
const _kOnSurfaceVariant = Color(0xFF45474A);
const _kOutline = Color(0xFF76777B);

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
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
                          color: isDark ? const Color(0xFF3B1E1E) : _kSecondaryFixed,
                          borderRadius: AppRadii.pillRadius,
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
                              'Slot Ditahan (02:59)',
                              style: AppTypography.overline(
                                color: isDark ? const Color(0xFFFED7AA) : const Color(0xFF742814),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Langkah 3 dari 3',
                        style: AppTypography.caption(
                          color: isDark ? theme.textMuted : _kOutline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Konfirmasi\nReservasi',
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
                    'Tinjau detail parkir pintar Anda sebelum pembayaran otomatis diproses.',
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
                                color: isDark ? theme.surfaceField : _kSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
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
                                    'LOKASI TERPILIH',
                                    style: AppTypography.overline(
                                      color: isDark ? theme.textMuted : _kOutline,
                                    ),
                                  ),
                                  Text(
                                    'Central Park Mall',
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
                                color: isDark ? theme.surfaceField : _kSurfaceContainerHigh,
                                borderRadius: AppRadii.pillRadius,
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
                                    '2 Jam',
                                    style: AppTypography.labelMd(
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
                                            'Zona Parkir',
                                            style: AppTypography.overline(
                                              color: Colors.white.withValues(alpha: 0.9),
                                            ),
                                          ),
                                          Text(
                                            'Basement B2 - Slot A-05',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: AppRadii.pillRadius,
                                        ),
                                        child: Text(
                                          'Sensor Aktif',
                                          style: AppTypography.caption(color: Colors.white),
                                        ),
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
                            color: isDark ? theme.surfaceField : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? theme.border : _kOutline.withValues(alpha: 0.3),
                            ),
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const VehicleScreen()),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car_outlined,
                                      size: 20,
                                      color: isDark ? Colors.white : _kOnSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'KENDARAAN TERDAFTAR',
                                            style: AppTypography.overline(
                                              color: isDark ? theme.textMuted : _kOutline,
                                            ),
                                          ),
                                          Text(
                                            'Toyota Raize',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? theme.card : _kSurfaceContainerHigh,
                                        borderRadius: AppRadii.pillRadius,
                                        border: isDark ? Border.all(color: theme.border) : null,
                                      ),
                                      child: Text(
                                        'B 1234 XYZ',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                      color: isDark ? theme.textMuted : _kOutline,
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
                        _priceRow('Tarif Parkir', 'Rp 10.000', isDark: isDark),
                        _priceRow('Biaya Layanan', 'Rp 2.000', isDark: isDark),
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
                              'TOTAL PEMBAYARAN',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              'Rp 12.000',
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
                                color: isDark ? theme.card : _kSurfaceContainerHigh.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: isDark ? Border.all(color: theme.border) : null,
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
                            'Checkout',
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
                      color: isDark ? theme.bg : _kSurface,
                      border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PinScreen(
                              nextScreen: BookingConfirmationScreen(),
                              transactionType: 'parkir',
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : _kPrimaryContainer,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Konfirmasi Bayar Sekarang',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
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
    final theme = ThemeService.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? theme.textMuted : _kOnSurfaceVariant,
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

class _JadwalSelector extends StatefulWidget {
  const _JadwalSelector();
  @override
  State<_JadwalSelector> createState() => _JadwalSelectorState();
}

class _JadwalSelectorState extends State<_JadwalSelector> {
  TimeOfDay _arrivalTime = const TimeOfDay(hour: 14, minute: 0);
  final int _durationHours = 2;

  void _showTimePicker() async {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _arrivalTime,
      helpText: 'PILIH JAM KEDATANGAN',
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
    if (selectedTime != null) {
      setState(() {
        _arrivalTime = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    final endTime = TimeOfDay(
      hour: (_arrivalTime.hour + _durationHours) % 24,
      minute: _arrivalTime.minute,
    );
    final startStr = '${_arrivalTime.hour.toString().padLeft(2, '0')}:${_arrivalTime.minute.toString().padLeft(2, '0')}';
    final endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.surfaceField : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? theme.border : _kOutline.withValues(alpha: 0.3),
        ),
        boxShadow: const [AppShadows.soft],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showTimePicker,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: isDark ? Colors.white : _kOnSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JADWAL KEDATANGAN',
                        style: AppTypography.overline(
                          color: isDark ? theme.textMuted : _kOutline,
                        ),
                      ),
                      Text(
                        '$startStr - $endStr WIB',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_calendar,
                  size: 20,
                  color: isDark ? const Color(0xFF2DD4BF) : _kPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
