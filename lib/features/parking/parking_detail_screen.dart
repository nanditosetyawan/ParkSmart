// PS-04 Parking Detail — Reconstructed from actual Stitch HTML
// bg: #FAF7F2 | Hero: h-80 rounded-[32px] overflow-hidden
// brand-accent: #D96B43 | charcoal: #1C1C1E
// Back/share buttons: rounded-full bg-white border shadow

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../booking/slot_selection_screen.dart';

class ParkingDetailScreen extends StatefulWidget {
  const ParkingDetailScreen({super.key});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ─── Scrollable content ───────────────────────────────
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // spacer for fixed header
              const SizedBox(height: 72),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Hero image: h-80 rounded-[32px] ─────────
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.xl2Radius,
                        border: Border.all(color: const Color(0xFFEAE5DC).withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), offset: const Offset(0, 8), blurRadius: 30),
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
                              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFECE8E0)),
                            ),
                            // gradient overlay bottom-up
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppColors.primary.withOpacity(0.0), AppColors.primary.withOpacity(0.7)],
                                  stops: const [0.4, 1.0],
                                ),
                              ),
                            ),
                            // Top badges
                            Positioned(
                              top: 16, left: 16, right: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Visibility(

                                    visible: false, maintainSize: true, maintainAnimation: true, maintainState: true,

                                    child: _HeroPill(
                                    color: Colors.transparent,
                                    child: const SizedBox(width: 100),
                                  ),

                                  ),
                                  _HeroPill(
                                    color: AppColors.primary.withOpacity(0.7),
                                    child: Row(children: [
                                      const Icon(Icons.roofing, size: 15, color: AppColors.white),
                                      const SizedBox(width: 4),
                                      Text('Basement B2', style: AppTypography.caption(color: AppColors.white)),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom badges
                            Positioned(
                              bottom: 20, left: 20, right: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    _HeroPill(
                                      color: AppColors.white.withOpacity(0.2),
                                      border: AppColors.white.withOpacity(0.2),
                                      child: Row(children: [
                                        const Icon(Icons.schedule, size: 14, color: AppColors.white),
                                        const SizedBox(width: 4),
                                        Text('24 Jam', style: AppTypography.caption(color: AppColors.white)),
                                      ]),
                                    ),
                                    const SizedBox(width: 8),
                                    _HeroPill(
                                      color: AppColors.white.withOpacity(0.2),
                                      border: AppColors.white.withOpacity(0.2),
                                      child: Row(children: [
                                        const Icon(Icons.ev_station, size: 14, color: AppColors.white),
                                        const SizedBox(width: 4),
                                        Text('EV Ready', style: AppTypography.caption(color: AppColors.white)),
                                      ]),
                                    ),
                                  ]),
                                  _HeroPill(
                                    color: AppColors.white,
                                    child: Row(children: [
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('4.8', style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700)),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── Title & metadata ─────────────────────────
                    const SizedBox(height: 20),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFEFE9DF), borderRadius: AppRadii.pillRadius),
                        child: Text('Lobi Utama Mall', style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: AppTypography.caption(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      Text('350m (3 mnt)', style: AppTypography.caption(color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 10),
                    Text('Central Park Mall',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34, fontWeight: FontWeight.w800,
                        height: 1.15, letterSpacing: -0.5, color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.near_me, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Jl. Letjen S. Parman Kav. 28, South Lobby B2, Jakarta Barat',
                          style: AppTypography.bodySm(color: AppColors.textSecondary),
                        ),
                      ),
                    ]),

                    // ─── Capacity card ────────────────────────────
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadii.xl2Radius,
                        border: Border.all(color: const Color(0xFFEAE5DC).withOpacity(0.5)),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('KAPASITAS TERSEDIA', style: AppTypography.overline(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('28 Slot', style: GoogleFonts.plusJakartaSans(
                                fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5,
                              )),
                              Text('Siap pakai di Basement B2', style: AppTypography.bodySm(color: AppColors.textSecondary)),
                            ]),
                            const SizedBox(width: 60, height: 60),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadii.lgRadius,
                          ),
                          child: Row(children: [
                            const Icon(Icons.tips_and_updates_outlined, size: 18, color: AppColors.accentTeal),
                            const SizedBox(width: 10),
                            Expanded(child: Text('Zona A lebih dekat ke Lobby Tribeca & Central Park Lift.', style: AppTypography.bodySm(color: AppColors.textSecondary))),
                          ]),
                        ),
                      ]),
                    ),

                    // ─── Pricing card ─────────────────────────────
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadii.xl2Radius,
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('TARIF PARKIR', style: AppTypography.overline(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                          Text('Rp 5.000', style: GoogleFonts.plusJakartaSans(
                            fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: const Color(0xFFD96B43),
                          )),
                          Text(' / jam pertama', style: AppTypography.bodySm(color: AppColors.textSecondary)),
                        ]),
                        const SizedBox(height: 12),
                        _InfoRow(icon: Icons.more_time, text: 'Rp 3.000 / jam selanjutnya'),
                        _InfoRow(icon: Icons.nights_stay_outlined, text: 'Menginap (12 jam): Rp 30.000'),
                      ]),
                    ),

                    // ─── Amenities ────────────────────────────────
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadii.xl2Radius,
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('FASILITAS', style: AppTypography.overline(color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3.2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _AmenityChip(icon: Icons.videocam_outlined, label: 'CCTV 24 Jam'),
                            _AmenityChip(icon: Icons.ev_station, label: 'EV Charging'),
                            _AmenityChip(icon: Icons.accessible, label: 'Disabilitas'),
                            _AmenityChip(icon: Icons.elevator_outlined, label: 'Akses Lift'),
                          ],
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Fixed top header ─────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: AppColors.surface.withOpacity(0.85),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                    Text('PARKIR MALL', style: AppTypography.overline(color: AppColors.textMuted)),
                    Row(children: [
                      _NavBtn(icon: _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                        onTap: () => setState(() => _bookmarked = !_bookmarked)),
                      const SizedBox(width: 8),
                      _NavBtn(icon: Icons.share_outlined, onTap: () {}),
                    ]),
                  ],
                ),
              ),
            ),
          ),

          // ─── Floating bottom CTA ──────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), offset: const Offset(0, -4), blurRadius: 20)],
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('MULAI DARI', style: AppTypography.overline(color: AppColors.textSecondary)),
                      Text('Rp 5.000 / jam', style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3,
                      )),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotSelectionScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Pilih Slot', style: AppTypography.buttonLg(color: AppColors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
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
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEAE5DC).withOpacity(0.6)),
        boxShadow: const [AppShadows.soft],
      ),
      child: Icon(icon, size: 20, color: AppColors.textPrimary),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.textMuted),
      const SizedBox(width: 8),
      Text(text, style: AppTypography.bodyMd(color: AppColors.textSecondary)),
    ]),
  );
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text(label, style: AppTypography.labelSm()),
    ]),
  );
}
