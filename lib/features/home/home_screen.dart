// PS-03 Home — Reconstructed from actual Stitch HTML
// bg: #F6F3EC | Dark floating dock nav: #1C1D1F rounded-[32px]
// Map: SVG vector roads on #ECE8E0 bg, not a real map
// Greeting: text-[34px] font-extrabold
// Active booking card: rounded-[32px] bg-white

import 'package:flutter/material.dart';
import '../notification/notification_screen.dart';
import '../session/active_session_screen.dart' as active;
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_dock_navigation.dart';
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
              padding: const EdgeInsets.only(bottom: 140),
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
                          Visibility(visible: false, maintainSize: true, maintainAnimation: true, maintainState: true, child: _NavIconBtn(icon: Icons.calendar_today_outlined)),
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
                          _NavIconBtn(
                            icon: Icons.notifications_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                          ),
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
                          child: TextField(
                            textInputAction: TextInputAction.done,
                            style: AppTypography.bodyMd(),
                            decoration: InputDecoration(
                              hintText: 'Cari gedung atau area parkir...',
                              hintStyle: AppTypography.bodyMd(color: AppColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const _FilterPopup(),
                            );
                          },
                          child: Container(
                            width: 36, height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(color: AppColors.surfaceDim, shape: BoxShape.circle),
                            child: const Icon(Icons.tune, size: 18, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Category Pills ─────────────────────────────
                const SizedBox(height: 16),
                const _CategoryList(),

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
                            decoration: const BoxDecoration(color: Color(0xFF1A1C1E), shape: BoxShape.circle),
                            child: const Icon(Icons.qr_code_2, size: 20, color: Colors.white),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadii.lgRadius, border: Border.all(color: const Color(0xFFE5E2DB))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('SISA WAKTU', style: AppTypography.overline(color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text('01:42:18', style: AppTypography.monoLg()),
                              ]),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const active.ActiveSessionScreen())),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadii.pillRadius,
                                    boxShadow: const [AppShadows.float]),
                                  child: Row(children: [
                                    Text('Buka Tiket', style: AppTypography.buttonSm(color: AppColors.white)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward, size: 16, color: AppColors.white),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),

                // ─── Recommendations Section ────────────────────
                const _RecommendationsList(),
              ],
            ),
          ),


          // ─── Dark floating dock navigation (fixed bottom) ────────
          Positioned(
            bottom: 24,
            left: AppSpacing.pageH,
            right: AppSpacing.pageH,
            child: Center(
              child: const BottomDockNavigation(activeTab: DockTab.home),
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
  final VoidCallback? onTap;
  const _NavIconBtn({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      shape: BoxShape.circle,
      boxShadow: const [AppShadows.soft],
    ),
    child: Icon(icon, size: 20, color: AppColors.textPrimary),
  ));
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
          color: active ? Colors.black : AppColors.surfaceCard,
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

class _FilterPopup extends StatefulWidget {
  const _FilterPopup();
  @override
  State<_FilterPopup> createState() => _FilterPopupState();
}

class _FilterPopupState extends State<_FilterPopup> {
  final Set<String> _selectedCriteria = {};

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCriteria.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCriteria.remove(label);
          } else {
            _selectedCriteria.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : const Color(0xFFE4DFD5),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF62615B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF1A1A18)),
                      ),
                    ),
                  ),
                  Text(
                    'Kriteria',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A18),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFilterChip('Harga'),
                  _buildFilterChip('Terdekat'),
                  _buildFilterChip('Tersedia'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Pilih',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

class _CategoryList extends StatefulWidget {
  const _CategoryList();
  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  String _selectedCategory = 'Terdekat';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _CategoryPill(
            label: 'Terdekat', 
            icon: Icons.near_me, 
            active: _selectedCategory == 'Terdekat',
            onTap: () => setState(() => _selectedCategory = 'Terdekat'),
          ),
          _CategoryPill(
            label: 'Mall', 
            icon: Icons.storefront_outlined,
            active: _selectedCategory == 'Mall',
            onTap: () => setState(() => _selectedCategory = 'Mall'),
          ),
          _CategoryPill(
            label: 'Parkir EV', 
            icon: Icons.bolt, 
            tealIcon: true,
            active: _selectedCategory == 'Parkir EV',
            onTap: () => setState(() => _selectedCategory = 'Parkir EV'),
          ),
          _CategoryPill(
            label: 'Games', 
            icon: Icons.sports_esports, 
            tealIcon: true,
            active: _selectedCategory == 'Games',
            onTap: () {
              setState(() => _selectedCategory = 'Games');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const game.GameLobbyScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _RecommendationsList extends StatefulWidget {
  const _RecommendationsList();
  @override
  State<_RecommendationsList> createState() => _RecommendationsListState();
}

class _RecommendationsListState extends State<_RecommendationsList> {
  bool _isLoading = false;
  int _extraCount = 0;

  Widget _buildCard(String title, String subtitle, String price, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadii.xlRadius,
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
        boxShadow: const [AppShadows.soft],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        ClipRRect(
          borderRadius: AppRadii.mdRadius,
          child: Image.network(
            imageUrl,
            width: 56, height: 56, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.surfaceDim),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTypography.titleMd(), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.caption(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(price, style: AppTypography.caption(color: AppColors.accentTeal).copyWith(fontWeight: FontWeight.w700)),
        ])),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParkingDetailScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.surfaceDim, borderRadius: AppRadii.pillRadius),
            child: Text('Pilih', style: AppTypography.buttonSm()),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rekomendasi Lainnya', style: AppTypography.headlineMd()),
              GestureDetector(
                onTap: () async {
                  if (_isLoading) return;
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _extraCount++;
                    });
                  }
                },
                child: _isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Lihat Semua', style: AppTypography.buttonSm(color: AppColors.secondary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
          child: _buildCard(
            'Grand Indonesia West Mall', 
            '850m • 8 slot kosong', 
            'Rp 6.000 / jam', 
            'https://lh3.googleusercontent.com/aida-public/AB6AXuARzILaOzCGSu-s8FDqbU48zMmMyWxJJ46At0mzTeYr6z5scsx6OzMD121EdnOyRogr63BsWgwxhBxanCuSHtnkExY_U0KTsvAZ8gpJQgktHWpKt7_v4t1zjonCwif6Q1-wDg4a94G-s2q-vcWbnS-AJAV9wscZ8ki6Sptsgn0gHXsRS_Wb5gVZaFLVT-bTyvo9E7CP2Qcb2K60CaNVaIVK_lQOI8Gsm8l5UjTdixRrSG7F60Vk2YmK'
          ),
        ),
        for (int i = 0; i < _extraCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: _buildCard(
              'Plaza Indonesia (Lantai 2)', 
              '1.2km • Tersedia 12 slot', 
              'Rp 5.000 / jam', 
              'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=500&auto=format&fit=crop&q=60'
            ),
          ),
      ],
    );
  }
}
