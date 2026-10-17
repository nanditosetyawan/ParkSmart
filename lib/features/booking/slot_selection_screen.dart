// PS-05 Slot Selection
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../checkout/checkout_screen.dart';
import '../../core/services/maintenance_service.dart';

// Stitch Material3 slot colors
const _kSecondary = Color(0xFF9A442D);
const _kPrimaryContainer = Color(0xFF1C1D1F);
const _kTertiaryFixed = Color(0xFFBBEED4);
const _kSurfaceContainerLow = Color(0xFFF6F3EC);
const _kSurfaceContainerHigh = Color(0xFFEBE8E1);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);

class SlotSelectionScreen extends StatefulWidget {
  const SlotSelectionScreen({super.key});
  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  String? _selectedSlot = 'A-05';
  int _selectedFloor = 1; // B2 is index 1

  final _floors = ['Lantai B1', 'Lantai B2', 'Lantai B3', 'Lantai B4 (Khusus Valet)'];

  @override
  void initState() {
    super.initState();
    if (MaintenanceService.instance.isBookingMaintenance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
          MaintenanceService.showModularMaintenanceDialog(
            context,
            title: 'Gateway Booking Sedang Maintenance',
            message:
                'Layanan pemesanan dan reservasi tiket parkir sementara dinonaktifkan untuk pemeliharaan sistem. Anda tetap dapat menjelajahi peta dan fitur lainnya.',
            icon: Icons.event_busy,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          body: Stack(
            children: [
              // Scrollable content
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 72),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // Summary card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : _kSurfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                offset: const Offset(0, 12),
                                blurRadius: 32,
                                spreadRadius: -8,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // location + ANPR badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 18, color: Color(0xFFFB923C)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Central Park Mall • 350m',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                          color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // slot count
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '28 Slot',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Siap pakai di Basement B2',
                                        style: AppTypography.bodySm(
                                          color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Align(
                                        widthFactor: 0.75,
                                        child: _AmenityBadge(color: _kTertiaryFixed, icon: Icons.ev_station),
                                      ),
                                      Align(
                                        widthFactor: 0.75,
                                        child: _AmenityBadge(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFEBE8E1),
                                          icon: Icons.accessible,
                                        ),
                                      ),
                                      const _CountBadge(count: '+4'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // tip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? theme.surfaceField : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? theme.border : const Color(0xFFE5E2DB),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tips_and_updates_outlined, size: 18, color: Color(0xFF2DD4BF)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Zona A lebih dekat ke Lobby Tribeca & Central Park Lift.',
                                        style: AppTypography.bodySm(
                                          color: isDark ? Colors.white : const Color(0xFF45474A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Floor selector tabs
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _floors.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final active = i == _selectedFloor;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedFloor = i;
                                  _selectedSlot = null;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? (isDark ? Colors.white : _kPrimaryContainer)
                                        : (isDark ? theme.card : _kSurfaceContainerLowest),
                                    borderRadius: AppRadii.pillRadius,
                                    border: isDark && !active ? Border.all(color: theme.border) : null,
                                    boxShadow: const [AppShadows.soft],
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _floors[i],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: active
                                              ? (isDark ? Colors.black : const Color(0xFFFCF9F2))
                                              : (isDark ? Colors.white : const Color(0xFF45474A)),
                                        ),
                                      ),
                                      if (active) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF9A442D) : const Color(0xFFFC9174),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Terpilih',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.black87 : const Color(0xFFFCF9F2).withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Parking map canvas
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? theme.surfaceField : _kSurfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Zone A
                              _ZoneLabel(label: 'Zona A', count: '3 Tersedia', isDark: isDark),
                              const SizedBox(height: 8),
                              GridView.count(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3 / 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildSlot('A-03', true, isDark: isDark),
                                  _buildSlot('A-04', false, isDark: isDark),
                                  _buildSlot('A-05', true, isSelected: _selectedSlot == 'A-05', isDark: isDark),
                                  _buildSlot('A-06', false, isDark: isDark),
                                ],
                              ),

                              // Circulation aisle
                              const SizedBox(height: 12),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? theme.card : _kSurfaceContainerHigh.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: isDark ? Border.all(color: theme.border) : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.east,
                                      size: 14,
                                      color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Jalur Sirkulasi B2',
                                      style: AppTypography.caption(
                                        color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.navigation_outlined,
                                      size: 14,
                                      color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Satu Arah',
                                      style: AppTypography.caption(
                                        color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Zone B
                              _ZoneLabel(label: 'Zona B', count: '2 Tersedia', isDark: isDark),
                              const SizedBox(height: 8),
                              GridView.count(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3 / 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildSlot('B-01', false, isDark: isDark),
                                  _buildSlot('B-02', true, isSelected: _selectedSlot == 'B-02', isDark: isDark),
                                  _buildSlot('B-03', false, isEV: true, isDark: isDark),
                                  _buildSlot('B-04', true, isEV: true, isSelected: _selectedSlot == 'B-04', isDark: isDark),
                                ],
                              ),

                              // Legend
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _LegendItem(
                                    color: isDark ? theme.card : _kSurfaceContainerLowest,
                                    label: 'Tersedia',
                                    border: isDark ? Colors.white : const Color(0xFFC6C6CA),
                                    isDark: isDark,
                                  ),
                                  _LegendItem(
                                    color: isDark ? const Color(0xFF1E293B) : _kSurfaceContainerHigh.withValues(alpha: 0.6),
                                    label: 'Terisi Mobil',
                                    isDark: isDark,
                                  ),
                                  _LegendItem(
                                    color: isDark ? Colors.white : _kPrimaryContainer,
                                    label: 'Pilihan Anda',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),

              // Fixed header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: isDark ? theme.bg : const Color(0xFFFCF9F2),
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                'Slot Selection',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom floating summary / CTA
              if (_selectedSlot != null)
                Positioned(
                  bottom: 16,
                  left: AppSpacing.pageH,
                  right: AppSpacing.pageH,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : _kSurfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          offset: const Offset(0, 16),
                          blurRadius: 40,
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL PEMBAYARAN AWAL',
                                  style: AppTypography.overline(
                                    color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rp 5.000',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  '(1 Jam Pertama)',
                                  style: AppTypography.caption(
                                    color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : _kPrimaryContainer,
                              borderRadius: AppRadii.pillRadius,
                              boxShadow: const [AppShadows.float],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Lanjut Bayar',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.black : const Color(0xFFFCF9F2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: isDark ? Colors.black : const Color(0xFFFCF9F2),
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
        );
      },
    );
  }

  Widget _buildSlot(String id, bool isAvailable, {bool isSelected = false, bool isEV = false, bool isDark = false}) {
    final theme = ThemeService.instance;
    final selected = isSelected;
    Color bg;
    Color? border;
    Widget icon;
    Widget label;

    if (selected) {
      bg = isDark ? Colors.white : _kPrimaryContainer;
      border = null;
      icon = Icon(
        Icons.check_circle,
        size: 18,
        color: isDark ? Colors.black : const Color(0xFFFCF9F2),
      );
      label = Text(
        'Pilihan',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.black : const Color(0xFFFCF9F2),
        ),
      );
    } else if (!isAvailable) {
      bg = isDark ? const Color(0xFF1E293B) : _kSurfaceContainerHigh.withValues(alpha: 0.6);
      border = null;
      icon = Icon(
        Icons.directions_car,
        size: 18,
        color: isDark ? theme.textMuted : const Color(0xFF45474A),
      );
      label = Text(
        'Terisi',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: isDark ? theme.textMuted : const Color(0xFF45474A),
        ),
      );
    } else {
      bg = isDark ? theme.card : _kSurfaceContainerLowest;
      border = isDark ? Colors.white : const Color(0xFFC6C6CA);
      icon = isEV
          ? Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: _kTertiaryFixed, shape: BoxShape.circle),
              child: const Icon(Icons.bolt, size: 14, color: Color(0xFF002115)),
            )
          : const SizedBox();
      label = Text(
        'Siap',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: isDark ? theme.textMuted : const Color(0xFF45474A),
        ),
      );
    }

    return GestureDetector(
      onTap: isAvailable ? () => setState(() => _selectedSlot = selected ? null : id) : null,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: border != null
                    ? Border.all(
                        color: border,
                        width: (isDark && border == Colors.white) ? 1.5 : 1.0,
                      )
                    : null,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: (isDark ? Colors.white : _kPrimaryContainer).withValues(alpha: 0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ]
                    : const [AppShadows.soft],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    id,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? (isDark ? Colors.black : const Color(0xFFFCF9F2))
                          : (isDark ? Colors.white : const Color(0xFF1C1C18)),
                    ),
                  ),
                  icon,
                  Padding(padding: const EdgeInsets.only(bottom: 6), child: label),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9A442D),
                      borderRadius: AppRadii.pillRadius,
                    ),
                    child: Text(
                      'Dipilih',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final String label;
  final String count;
  final bool isDark;
  const _ZoneLabel({required this.label, required this.count, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isDark ? theme.textMuted : const Color(0xFF45474A),
          ),
        ),
        Text(
          count,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFFB923C) : _kSecondary,
          ),
        ),
      ],
    );
  }
}

class _AmenityBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _AmenityBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [AppShadows.soft]),
        child: Icon(icon, size: 16, color: const Color(0xFF002115)),
      );
}

class _CountBadge extends StatelessWidget {
  final String count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: Color(0xFFFC9174), shape: BoxShape.circle),
        child: Center(
          child: Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF742814),
            ),
          ),
        ),
      );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? border;
  final bool isDark;
  const _LegendItem({required this.color, required this.label, this.border, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border != null ? Border.all(color: border!) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? theme.textMuted : const Color(0xFF45474A),
          ),
        ),
      ],
    );
  }
}
