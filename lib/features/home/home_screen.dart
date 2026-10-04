// PS-03 Home — Reconstructed from actual Stitch HTML
// bg: #F6F3EC | Dark floating dock nav: #1C1D1F rounded-[32px]
// Map: SVG vector roads on #ECE8E0 bg, not a real map
// Greeting: text-[34px] font-extrabold
// Active booking card: rounded-[32px] bg-white

import 'package:flutter/material.dart';
import '../sitemap_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../parking/parking_detail_screen.dart';
import '../history/history_screen.dart' as history;
import '../profile/profile_screen.dart' as profile;
import '../game/game_lobby_screen.dart' as game;
import '../ai_assistant/ai_assistant_screen.dart' as ai;
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen()));
          },
          label: const Text('Dev Sitemap'),
          icon: const Icon(Icons.developer_board),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // ─── Scrollable content ─────────────────────────────────
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                // ─── Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, 20, AppSpacing.pageH, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top nav row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Calendar icon button
                          _NavIconBtn(icon: Icons.calendar_today_outlined),
                          // Location pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: AppRadii.pillRadius,
                              boxShadow: const [AppShadows.soft],
                            ),
                            child: Row(children: [
                              Container(width: 8, height: 8,
                                decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('SCBD, Jakarta', style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700)),
                            ]),
                          ),
                          // Notification button
                          _NavIconBtn(icon: Icons.notifications_outlined),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Oversized greeting
                      Text('Halo, Sarah', style: AppTypography.displayLg()),
                      const SizedBox(height: 4),
                      Text('Temukan slot parkir nyaman hari ini', style: AppTypography.bodySm(color: AppColors.textSecondary)),
                    ],
                  ),
                ),

                // ─── Search Bar ─────────────────────────────────
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: AppRadii.pillRadius,
                      boxShadow: const [AppShadows.soft],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(Icons.search, size: 22, color: AppColors.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Cari gedung atau area parkir...', style: AppTypography.bodyMd(color: AppColors.textMuted)),
                        ),
                        Container(
                          width: 36, height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(color: AppColors.surfaceDim, shape: BoxShape.circle),
                          child: const Icon(Icons.tune, size: 18, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Category Pills ─────────────────────────────
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                    children: [
                      _CategoryPill(label: 'Terdekat', icon: Icons.near_me, active: true),
                      _CategoryPill(label: 'Mall', icon: Icons.storefront_outlined),
                      _CategoryPill(label: 'Parkir EV', icon: Icons.bolt, tealIcon: true),
                      _CategoryPill(label: 'Valet', icon: Icons.key_outlined),
                        _CategoryPill(
                          label: 'Games', 
                          icon: Icons.sports_esports, 
                          tealIcon: true,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const game.GameLobbyScreen())),
                        ),
                    ],
                  ),
                ),

                // ─── Hero Map Card ──────────────────────────────
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParkingDetailScreen())),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadii.xl2Radius,
                        border: Border.all(color: Colors.black.withOpacity(0.02)),
                        boxShadow: const [AppShadows.soft],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        // SVG-style map using CustomPaint
                        ClipRRect(
                          borderRadius: AppRadii.lgRadius,
                          child: SizedBox(
                            width: double.infinity, height: 210,
                            child: CustomPaint(
                              painter: _StitchMapPainter(),
                              child: Stack(children: [
                                // Distance badge top-right
                                Positioned(
                                  top: 16, right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceCard.withOpacity(0.95),
                                      borderRadius: AppRadii.pillRadius,
                                      boxShadow: const [AppShadows.soft],
                                    ),
                                    child: Row(children: [
                                      Container(width: 8, height: 8,
                                        decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      Text('350m', style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                                    ]),
                                  ),
                                ),
                                // Center parking pin
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: AppRadii.pillRadius,
                                          boxShadow: const [AppShadows.float],
                                        ),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(Icons.local_parking, size: 16, color: AppColors.secondary),
                                          const SizedBox(width: 6),
                                          Text('Central Park • 24 slot', style: AppTypography.buttonSm(color: AppColors.white)),
                                        ]),
                                      ),
                                      Container(
                                        width: 10, height: 10,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                        transform: Matrix4.rotationZ(0.785),
                                        transformAlignment: Alignment.topCenter,
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                        // Metrics row
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: AppColors.secondarySoft, shape: BoxShape.circle),
                              child: const Icon(Icons.explore_outlined, size: 24, color: AppColors.secondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('KEPADATAN AREA', style: AppTypography.overline(color: AppColors.textSecondary)),
                                Text('Tersedia Lengang (22%)', style: AppTypography.metricMd()),
                              ],
                            )),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('TARIF MULAI', style: AppTypography.overline(color: AppColors.textSecondary)),
                              RichText(text: TextSpan(
                                style: AppTypography.metricMd(),
                                children: [
                                  const TextSpan(text: 'Rp 5.000'),
                                  TextSpan(text: '/j', style: AppTypography.caption(color: AppColors.textSecondary)),
                                ],
                              )),
                            ]),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ),

                // ─── Active Booking Section ─────────────────────
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sesi Parkir Aktif', style: AppTypography.headlineMd()),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.secondarySoft, borderRadius: AppRadii.pillRadius),
                          child: Text('Lantai B2', style: AppTypography.buttonSm(color: AppColors.secondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadii.xl2Radius,
                        border: Border.all(color: Colors.black.withOpacity(0.02)),
                        boxShadow: const [AppShadows.soft],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Parking spot image
                          ClipRRect(
                            borderRadius: AppRadii.imgRadius,
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBJsx7LXeBJaAUStN81EfJ9OnCVmlVfmXRVDoub2mCYF0PIZidBrj0P0BKnSQQ61XyOVPHfeRK_AjHvT4_n19Q4_qfAi5-0c_AtnvOqmHjdEejobI5hupnFTMA62ySz5EK1P6Po3FtWuoFmFfTR5VstawDWIS_2zh3UIgjbVetIvkLALvb2EBtQnUoqR0niPhqqhkXpxobDu16pJPgQJ-hb6JjoFhBlKgY4UIkQVJWw5DpBxelV88Kr',
                              width: 64, height: 64, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64, height: 64, color: AppColors.surfaceDim,
                                child: const Icon(Icons.local_parking, color: AppColors.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('SLOT TERPESAN', style: AppTypography.overline(color: AppColors.secondary)),
                            const SizedBox(height: 2),
                            Text('Central Park Mall', style: AppTypography.headlineSm()),
                            const SizedBox(height: 2),
                            Text('Spot A-12 • Jalur Khusus EV', style: AppTypography.caption(color: AppColors.textSecondary)),
                          ])),
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppColors.surfaceDim, shape: BoxShape.circle),
                            child: const Icon(Icons.qr_code_2, size: 20, color: AppColors.textPrimary),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: AppRadii.lgRadius),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('SISA WAKTU', style: AppTypography.overline(color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text('01:42:18', style: AppTypography.monoLg()),
                              ]),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadii.pillRadius,
                                  boxShadow: const [AppShadows.float]),
                                child: Row(children: [
                                  Text('Buka Tiket', style: AppTypography.buttonSm(color: AppColors.white)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.white),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),

                // ─── Recommendations Section ────────────────────
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rekomendasi Lainnya', style: AppTypography.headlineMd()),
                        Text('Lihat Semua', style: AppTypography.buttonSm(color: AppColors.secondary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Recommendation card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadii.xlRadius,
                        border: Border.all(color: Colors.black.withOpacity(0.02)),
                        boxShadow: const [AppShadows.soft],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: AppRadii.mdRadius,
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuARzILaOzCGSu-s8FDqbU48zMmMyWxJJ46At0mzTeYr6z5scsx6OzMD121EdnOyRogr63BsWgwxhBxanCuSHtnkExY_U0KTsvAZ8gpJQgktHWpKt7_v4t1zjonCwif6Q1-wDg4a94G-s2q-vcWbnS-AJAV9wscZ8ki6Sptsgn0gHXsRS_Wb5gVZaFLVT-bTyvo9E7CP2Qcb2K60CaNVaIVK_lQOI8Gsm8l5UjTdixRrSG7F60Vk2YmK',
                            width: 56, height: 56, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.surfaceDim),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Grand Indonesia West Mall', style: AppTypography.titleMd(), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text('850m • 8 slot kosong', style: AppTypography.caption(color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text('Rp 6.000 / jam', style: AppTypography.caption(color: AppColors.accentTeal).copyWith(fontWeight: FontWeight.w700)),
                        ])),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.surfaceDim, borderRadius: AppRadii.pillRadius),
                          child: Text('Pilih', style: AppTypography.buttonSm()),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),

          // ─── Dark floating dock navigation (fixed bottom) ────────
          Positioned(
            bottom: 24,
            left: AppSpacing.pageH,
            right: AppSpacing.pageH,
            child: Center(
              child: Container(
                height: 68,
                constraints: const BoxConstraints(maxWidth: 360),
                decoration: BoxDecoration(
                  color: AppColors.dockBg,
                  borderRadius: AppRadii.xl2Radius,
                  boxShadow: const [AppShadows.dock],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Active: Home
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: const Icon(Icons.home, size: 22, color: AppColors.white),
                    ),
                    _DockIcon(icon: Icons.receipt_long_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const history.HistoryScreen()))),
                    // Center: Scan/focus rounded-2xl
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.filter_center_focus, size: 24, color: AppColors.white),
                    ),
                    _DockIcon(icon: Icons.auto_awesome_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ai.AiAssistantScreen()))),
                    _DockIcon(icon: Icons.person_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const profile.ProfileScreen()))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map Painter — reproduces the Stitch SVG vector road system ──────────────
class _StitchMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // bg
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFECE8E0));

    // green patches
    final patch = Paint()..color = const Color(0xFFDEE8DF).withOpacity(0.9);
    final path1 = Path()
      ..moveTo(-20, 160)..quadraticBezierTo(60, 110, 120, 190)..lineTo(-20, 220)..close();
    canvas.drawPath(path1, patch);
    final path2 = Path()
      ..moveTo(size.width * (240/350), 20)
      ..quadraticBezierTo(size.width * (300/350), 0, size.width * (360/350), 40)
      ..lineTo(size.width * (370/350), 120)..lineTo(size.width * (260/350), 90)..close();
    canvas.drawPath(path2, patch);

    // roads
    final road = Paint()
      ..color = const Color(0xFFFAF7F2)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    road.strokeWidth = 26 * size.width / 350;
    canvas.drawLine(Offset(0, size.height * (100/210)), Offset(size.width, size.height * (120/210)), road);
    road.strokeWidth = 24 * size.width / 350;
    canvas.drawLine(Offset(size.width * (175/350), -10), Offset(size.width * (175/350), size.height + 10), road);
    road.strokeWidth = 12 * size.width / 350;
    canvas.drawLine(Offset(size.width * (60/350), 0), Offset(size.width * (60/350), size.height), road);
    road.strokeWidth = 14 * size.width / 350;
    canvas.drawLine(Offset(size.width * (290/350), 0), Offset(size.width * (290/350), size.height), road);

    // route dashes
    final dash = Paint()
      ..color = const Color(0xFFE07A5F)
      ..strokeWidth = 4 * size.width / 350
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dashPath = Path()
      ..moveTo(size.width * (60/350), size.height * (100/210))
      ..quadraticBezierTo(size.width * (120/350), size.height * (95/210), size.width * (175/350), size.height * (105/210));
    _drawDashedPath(canvas, dashPath, dash, 4, 6, size.width / 350);

    // user dot
    final cx = size.width * (60/350);
    final cy = size.height * (100/210);
    canvas.drawCircle(Offset(cx, cy), 14 * size.width / 350, Paint()..color = const Color(0x261C1D1F));
    canvas.drawCircle(Offset(cx, cy), 7 * size.width / 350, Paint()..color = const Color(0xFF1C1D1F));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, double dashLen, double gapLen, double scale) {
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        final end = (dist + dashLen * scale).clamp(0.0, m.length);
        canvas.drawPath(m.extractPath(dist, end), paint);
        dist += (dashLen + gapLen) * scale;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _NavIconBtn extends StatelessWidget {
  final IconData icon;
  const _NavIconBtn({required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      shape: BoxShape.circle,
      boxShadow: const [AppShadows.soft],
    ),
    child: Icon(icon, size: 20, color: AppColors.textPrimary),
  );
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool tealIcon;
  final VoidCallback? onTap;
  const _CategoryPill({required this.label, required this.icon, this.active = false, this.tealIcon = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceCard,
          borderRadius: AppRadii.pillRadius,
          boxShadow: active ? null : const [AppShadows.soft],
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: active ? AppColors.white : tealIcon ? AppColors.accentTeal : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.labelSm(color: active ? AppColors.white : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _DockIcon({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 44, height: 44,
      child: Icon(icon, size: 22, color: AppColors.white.withOpacity(0.55)),
    ),
  );
}
