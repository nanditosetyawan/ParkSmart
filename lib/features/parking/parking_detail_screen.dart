// PS-04 Parking Detail
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../favorite/favorite_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../booking/slot_selection_screen.dart';
import '../../core/services/maintenance_service.dart';
import 'backend/parking_detail_backend.dart';

class ParkingDetailScreen extends StatefulWidget {
  final String? locationId;
  const ParkingDetailScreen({super.key, this.locationId});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    ParkingDetailBackend.instance.fetchLocationDetail(locationId: widget.locationId);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : AppColors.surface,
          body: Stack(
            children: [
              // Scrollable content
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  // spacer for fixed header
                  SizedBox(height: MediaQuery.of(context).padding.top + 72),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero image
                        Container(
                          height: 320,
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.xl2Radius,
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFFEAE5DC).withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                offset: const Offset(0, 8),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: AppRadii.xl2Radius,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC16Ol5F2vqF-rrwb2NSlClwfgx4cZLEdCjAmYv0fIi8P73BzoBWClV_VIe4LbU7tiVCWFQ90ca_gZFputPKT7ndqGMzrKIdzAHMVqhYpZQvzuETqY_XoCyIk9lTgv0wZAv6PzegW0J23RJqfYNW7E-Vg0g0OKAvsSlroKUXBr-ByDMjRuW9v6cG1rBVS1pBc7H6xJhYhAtEgLqLmaEEQtvGVBXocMbNqbwaM_evXAvOIwvBxuj-HGg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECE8E0),
                                  ),
                                ),
                                // gradient overlay bottom-up
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.primary.withValues(alpha: 0.0),
                                        AppColors.primary.withValues(alpha: 0.7),
                                      ],
                                      stops: const [0.4, 1.0],
                                    ),
                                  ),
                                ),
                                // Top badges
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Visibility(
                                        visible: false,
                                        maintainSize: true,
                                        maintainAnimation: true,
                                        maintainState: true,
                                        child: _HeroPill(
                                          color: Colors.transparent,
                                          child: SizedBox(width: 100),
                                        ),
                                      ),
                                      _HeroPill(
                                        color: AppColors.primary.withValues(alpha: 0.7),
                                        child: Row(
                                          children: [
                                            Icon(Icons.roofing, size: 15, color: AppColors.white),
                                            const SizedBox(width: 4),
                                            Text('Basement B2', style: AppTypography.caption(color: AppColors.white)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Bottom badges
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  right: 20,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _HeroPill(
                                            color: AppColors.white.withValues(alpha: 0.2),
                                            border: AppColors.white.withValues(alpha: 0.2),
                                            child: Row(
                                              children: [
                                                Icon(Icons.schedule, size: 14, color: AppColors.white),
                                                const SizedBox(width: 4),
                                                Text('24 Jam', style: AppTypography.caption(color: AppColors.white)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _HeroPill(
                                            color: AppColors.white.withValues(alpha: 0.2),
                                            border: AppColors.white.withValues(alpha: 0.2),
                                            child: Row(
                                              children: [
                                                Icon(Icons.ev_station, size: 14, color: AppColors.white),
                                                const SizedBox(width: 4),
                                                Text('EV Ready', style: AppTypography.caption(color: AppColors.white)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      _HeroPill(
                                        color: AppColors.white,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, size: 14, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text('4.8', style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Title & metadata
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(borderRadius: AppRadii.pillRadius),
                              child: Text(
                                'Lobi Utama Mall',
                                style: AppTypography.caption(
                                  color: isDark ? Colors.white : Colors.black,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: AppTypography.caption(
                                color: isDark ? theme.textMuted : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '350m (3 mnt)',
                              style: AppTypography.caption(
                                color: isDark ? Colors.white : Colors.black,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ListenableBuilder(
                          listenable: ParkingDetailBackend.instance,
                          builder: (context, _) {
                            final loc = ParkingDetailBackend.instance.locationDetail;
                            final name = loc?['name'] as String? ?? 'Central Park Mall';
                            final address = loc?['address'] as String? ?? 'Jl. Letjen S. Parman Kav. 28, South Lobby B2, Jakarta Barat';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    letterSpacing: -0.5,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.near_me,
                                      size: 18,
                                      color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF1F4F3C),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: AppTypography.bodySm(
                                          color: isDark ? theme.textMuted : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        // Capacity card
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : AppColors.surfaceCard,
                            borderRadius: AppRadii.xl2Radius,
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFFEAE5DC).withValues(alpha: 0.5),
                            ),
                            boxShadow: const [AppShadows.soft],
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
                                        'KAPASITAS TERSEDIA',
                                        style: AppTypography.overline(
                                          color: isDark ? theme.textMuted : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ListenableBuilder(
                                        listenable: ParkingDetailBackend.instance,
                                        builder: (context, _) {
                                          final available = ParkingDetailBackend.instance.availableSlots;
                                          return Text(
                                            '$available Slot',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.5,
                                              color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                            ),
                                          );
                                        },
                                      ),
                                      Text(
                                        'Siap pakai di Basement B2',
                                        style: AppTypography.bodySm(
                                          color: isDark ? theme.textMuted : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 60, height: 60),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? theme.surfaceField : const Color(0xFF1C1C18),
                                  borderRadius: AppRadii.lgRadius,
                                  border: isDark ? Border.all(color: theme.border) : null,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tips_and_updates_outlined, size: 18, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Zona A lebih dekat ke Lobby Tribeca & Central Park Lift.',
                                        style: AppTypography.bodySm(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Pricing card
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : AppColors.surfaceCard,
                            borderRadius: AppRadii.xl2Radius,
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TARIF PARKIR',
                                style: AppTypography.overline(
                                  color: isDark ? theme.textMuted : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    'Rp 5.000',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: const Color(0xFFD96B43),
                                    ),
                                  ),
                                  Text(
                                    ' / jam pertama',
                                    style: AppTypography.bodySm(
                                      color: isDark ? theme.textMuted : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.more_time,
                                text: 'Rp 3.000 / jam selanjutnya',
                                isDark: isDark,
                              ),
                              _InfoRow(
                                icon: Icons.nights_stay_outlined,
                                text: 'Menginap (12 jam): Rp 30.000',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        // Amenities
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : AppColors.surfaceCard,
                            borderRadius: AppRadii.xl2Radius,
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FASILITAS',
                                style: AppTypography.overline(
                                  color: isDark ? theme.textMuted : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3.2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _AmenityChip(icon: Icons.videocam_outlined, label: 'CCTV 24 Jam', isDark: isDark),
                                  _AmenityChip(icon: Icons.ev_station, label: 'EV Charging', isDark: isDark),
                                  _AmenityChip(icon: Icons.accessible, label: 'Disabilitas', isDark: isDark),
                                  _AmenityChip(icon: Icons.elevator_outlined, label: 'Akses Lift', isDark: isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Fixed top header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: isDark ? theme.bg : AppColors.surface,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _NavBtn(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                            isDark: isDark,
                          ),
                          const SizedBox(),
                          Row(
                            children: [
                              _NavBtn(
                                icon: _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                                isDark: isDark,
                                onTap: () {
                                  setState(() => _bookmarked = !_bookmarked);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const FavoriteScreen()),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _NavBtn(
                                icon: Icons.share_outlined,
                                isDark: isDark,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Floating bottom CTA (Pilih Slot)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      color: isDark ? theme.bg : AppColors.surface,
                      border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          offset: const Offset(0, -4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MULAI DARI',
                                style: AppTypography.overline(
                                  color: isDark ? theme.textMuted : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Rp 5.000 / jam',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                if (MaintenanceService.instance.isBookingMaintenance) {
                                  MaintenanceService.showModularMaintenanceDialog(
                                    context,
                                    title: 'Gateway Booking Sedang Maintenance',
                                    message:
                                        'Layanan pemesanan dan reservasi tiket parkir sementara dinonaktifkan untuk pemeliharaan sistem. Anda tetap dapat menjelajahi peta dan fitur lainnya.',
                                    icon: Icons.event_busy,
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SlotSelectionScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : AppColors.primary,
                                foregroundColor: isDark ? Colors.black : AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pilih Slot',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.black : AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 18,
                                    color: isDark ? Colors.black : AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
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
  }
}

class _HeroPill extends StatelessWidget {
  final Color color;
  final Color? border;
  final Widget child;
  const _HeroPill({required this.color, this.border, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: border != null ? Border.all(color: border!) : null,
        ),
        child: child,
      );
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
          border: Border.all(
            color: isDark ? theme.border : const Color(0xFFEAE5DC).withValues(alpha: 0.6),
          ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoRow({required this.icon, required this.text, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isDark ? const Color(0xFF2DD4BF) : AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.bodyMd(
              color: isDark ? theme.textMuted : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _AmenityChip({required this.icon, required this.label, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? theme.surfaceField : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? theme.border : const Color(0xFFE5E2DB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF45474A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1C1C18),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
