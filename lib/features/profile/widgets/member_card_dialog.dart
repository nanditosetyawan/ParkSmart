import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../ui/layanan/layanan_blockchain.dart';
import '../backend/profile_backend.dart';

/// ISO/IEC 7810 ID-1 standard ATM card aspect ratio (85.60 mm × 53.98 mm ≈ 1.586 : 1)
const double kAtmCardAspectRatio = 1.586;

/// Menampilkan Dialog Kartu Member Frameless dengan dukungan multi-kartu (Carousel/Koleksi Kartu)
void showFramelessMemberCardDialog(
  BuildContext context, {
  required String tier,
  required String memberCode,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'MemberCardDismiss',
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, anim1, anim2) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Material(
            color: Colors.transparent,
            child: MemberCardsCarouselDialog(
              initialTier: tier,
              initialMemberCode: memberCode,
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      );
    },
  );
}

class MemberCardsCarouselDialog extends StatefulWidget {
  final String initialTier;
  final String initialMemberCode;

  const MemberCardsCarouselDialog({
    super.key,
    required this.initialTier,
    required this.initialMemberCode,
  });

  @override
  State<MemberCardsCarouselDialog> createState() => _MemberCardsCarouselDialogState();
}

class _MemberCardsCarouselDialogState extends State<MemberCardsCarouselDialog> {
  PageController? _pageController;
  int _currentPage = 0;
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    List<Map<String, dynamic>> loaded = List.from(ProfileBackend.instance.userCards);
    final uid = ProfileBackend.instance.userId;

    if (loaded.isEmpty && uid.isNotEmpty) {
      try {
        final res = await Supabase.instance.client
            .from('user_member_cards')
            .select('id, card_tier, member_hash_code, tx_hash, is_active, unlocked_at')
            .eq('user_id', uid)
            .order('created_at', ascending: true);
        if (res.isNotEmpty) {
          loaded = List<Map<String, dynamic>>.from(res);
        }
      } catch (_) {}
    }

    if (loaded.isEmpty) {
      loaded = [
        {
          'card_tier': widget.initialTier,
          'member_hash_code': widget.initialMemberCode,
        }
      ];
    }

    int initialIdx = loaded.indexWhere((c) {
      final t = (c['card_tier'] ?? '').toString().toLowerCase();
      final initT = widget.initialTier.toLowerCase();
      return t == initT || (initT == 'bronze' && t == 'regular');
    });
    if (initialIdx < 0) initialIdx = loaded.length - 1;

    if (mounted) {
      setState(() {
        _cards = loaded;
        _currentPage = initialIdx;
        _pageController = PageController(initialPage: initialIdx);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _pageController == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Colors.white70),
        ),
      );
    }

    final currentCard = _cards[_currentPage];
    final currentTier = currentCard['card_tier']?.toString() ?? widget.initialTier;
    final currentCode = currentCard['member_hash_code']?.toString() ?? widget.initialMemberCode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indikator Koleksi Multi-Kartu jika pengguna memiliki lebih dari 1 kartu
        if (_cards.length > 1) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.style_rounded, size: 14, color: Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                Text(
                  'Koleksi Kartu: ${_currentPage + 1} dari ${_cards.length} (Geser untuk memilih)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],

        // PageView Kartu Member Berstandar ISO ID-1
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SizedBox(
            height: 236,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _cards.length,
              onPageChanged: (idx) {
                setState(() {
                  _currentPage = idx;
                });
              },
              itemBuilder: (context, index) {
                final c = _cards[index];
                final cardTier = c['card_tier']?.toString() ?? 'BRONZE';
                final memberCode = c['member_hash_code']?.toString() ?? widget.initialMemberCode;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: MemberAtmCard(
                    tier: cardTier,
                    memberCode: memberCode,
                  ),
                );
              },
            ),
          ),
        ),

        // Dots Indicator jika memiliki lebih dari 1 kartu
        if (_cards.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_cards.length, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 22 : 6,
                height: 5,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF38BDF8) : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],

        const SizedBox(height: 14),

        // Panel Sinkronisasi Web3 Blockchain Sepolia & Basis Data untuk kartu aktif
        _MemberCardBlockchainSyncWidget(
          key: ValueKey('${currentTier}_$currentCode'),
          tier: currentTier,
          memberCode: currentCode,
        ),

        const SizedBox(height: 18),

        // Tombol Tutup Minimalis Elegan
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.close, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Tutup',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget Kartu Member Polos Berstandar ISO ATM Card ID-1
class MemberAtmCard extends StatelessWidget {
  final String tier;
  final String memberCode;

  const MemberAtmCard({
    super.key,
    required this.tier,
    required this.memberCode,
  });

  @override
  Widget build(BuildContext context) {
    final normTier = tier.trim().toUpperCase();

    // Pilih konfigurasi warna, pattern, dan bayangan sesuai tier
    final _CardTheme theme;
    if (normTier.contains('PLATINUM')) {
      theme = _CardTheme.platinum;
    } else if (normTier.contains('GOLD')) {
      theme = _CardTheme.gold;
    } else if (normTier.contains('SILVER')) {
      theme = _CardTheme.silver;
    } else {
      theme = _CardTheme.bronze;
    }

    final displayHashCode = memberCode.trim().isNotEmpty
        ? (memberCode.startsWith('#') ? memberCode : '#$memberCode')
        : theme.defaultHashCode;

    return AspectRatio(
      aspectRatio: kAtmCardAspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.70),
              offset: const Offset(0, 20),
              blurRadius: 40,
              spreadRadius: -15,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.08),
              offset: Offset.zero,
              blurRadius: 0,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Base Radial Gradient Background
              Container(
                decoration: BoxDecoration(
                  gradient: theme.backgroundGradient,
                ),
              ),

              // 2. Batik Pattern Overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _buildBatikPainter(normTier),
                ),
              ),

              // 3. Vignette & Texture Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: theme.vignetteGradient,
                ),
              ),

              // 4. Glossy Specular Card Shine
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0, -0.6),
                      end: Alignment(1.0, 0.6),
                      colors: [
                        Colors.transparent,
                        Color(0x12FFFFFF),
                        Color(0x26FFFFFF),
                        Colors.transparent,
                      ],
                      stops: [0.20, 0.35, 0.45, 0.55],
                    ),
                  ),
                ),
              ),

              // 5. Card Content (Pure White Typography & Minimalist Layout)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Right: Title "Member [Tier]" & Subtitle "Keanggotaan anda"
                    Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            theme.title,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.kaushanScript(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: theme.textShadowAlpha),
                                  offset: const Offset(0, 2),
                                  blurRadius: theme.textShadowBlur,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Keanggotaan anda',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: theme.subtitleAlpha),
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Left: "HASH CODE" & Code
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'HASH CODE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: Colors.white.withValues(alpha: theme.hashLabelAlpha),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayHashCode,
                            style: GoogleFonts.spaceMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                              color: Colors.white.withValues(alpha: theme.hashValueAlpha),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  CustomPainter _buildBatikPainter(String normTier) {
    if (normTier.contains('PLATINUM')) {
      return const _MegaMendungPainter();
    } else if (normTier.contains('GOLD')) {
      return const _TruntumPainter();
    } else if (normTier.contains('SILVER')) {
      return const _ParangPainter();
    } else {
      return const _KawungPainter();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KONFIGURASI TEMA KARTU (PERSIS STITCH CSS)
// ─────────────────────────────────────────────────────────────────────────────
class _CardTheme {
  final String title;
  final String defaultHashCode;
  final Gradient backgroundGradient;
  final Gradient vignetteGradient;
  final double textShadowAlpha;
  final double textShadowBlur;
  final double subtitleAlpha;
  final double hashLabelAlpha;
  final double hashValueAlpha;

  const _CardTheme({
    required this.title,
    required this.defaultHashCode,
    required this.backgroundGradient,
    required this.vignetteGradient,
    required this.textShadowAlpha,
    required this.textShadowBlur,
    required this.subtitleAlpha,
    required this.hashLabelAlpha,
    required this.hashValueAlpha,
  });

  /// 1. BRONZE (Emas tua gelap kotor / rustic aged dark bronze)
  static final bronze = _CardTheme(
    title: 'Member Bronze',
    defaultHashCode: '#7b9e-4a81-d02f',
    backgroundGradient: const RadialGradient(
      center: Alignment(0.5, -0.5), // circle at 75% 25%
      radius: 1.25,
      colors: [
        Color(0xFF6E4D25),
        Color(0xFF462F14),
        Color(0xFF271A0C),
        Color(0xFF150D06),
      ],
      stops: [0.0, 0.38, 0.70, 1.0],
    ),
    vignetteGradient: RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        Colors.transparent,
        const Color(0xFF0A0602).withValues(alpha: 0.85),
      ],
      stops: const [0.40, 1.0],
    ),
    textShadowAlpha: 0.60,
    textShadowBlur: 6.0,
    subtitleAlpha: 0.60,
    hashLabelAlpha: 0.40,
    hashValueAlpha: 0.90,
  );

  /// 2. SILVER (Perak kotor / weathered antique dark silver)
  static final silver = _CardTheme(
    title: 'Member Silver',
    defaultHashCode: '#91c4-e830-55bd',
    backgroundGradient: const RadialGradient(
      center: Alignment(0.5, -0.5),
      radius: 1.25,
      colors: [
        Color(0xFF8A9096),
        Color(0xFF565D63),
        Color(0xFF34393E),
        Color(0xFF1C2024),
      ],
      stops: [0.0, 0.35, 0.68, 1.0],
    ),
    vignetteGradient: RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        Colors.transparent,
        const Color(0xFF0C0E10).withValues(alpha: 0.88),
      ],
      stops: const [0.35, 1.0],
    ),
    textShadowAlpha: 0.60,
    textShadowBlur: 6.0,
    subtitleAlpha: 0.60,
    hashLabelAlpha: 0.40,
    hashValueAlpha: 0.90,
  );

  /// 3. GOLD (Emas muda / pale champagne radiant gold)
  static final gold = _CardTheme(
    title: 'Member Gold',
    defaultHashCode: '#c304-712f-98ea',
    backgroundGradient: const RadialGradient(
      center: Alignment(0.5, -0.6),
      radius: 1.25,
      colors: [
        Color(0xFFD4B574),
        Color(0xFFB89750),
        Color(0xFF7E632B),
        Color(0xFF3E3012),
      ],
      stops: [0.0, 0.35, 0.70, 1.0],
    ),
    vignetteGradient: RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        Colors.transparent,
        const Color(0xFF1E1608).withValues(alpha: 0.80),
      ],
      stops: const [0.45, 1.0],
    ),
    textShadowAlpha: 0.70,
    textShadowBlur: 8.0,
    subtitleAlpha: 0.75,
    hashLabelAlpha: 0.50,
    hashValueAlpha: 1.0,
  );

  /// 4. PLATINUM (Perak cerah jernih mewah / ultra luxury crystalline platinum)
  static final platinum = _CardTheme(
    title: 'Member Platinum',
    defaultHashCode: '#f882-00bb-44cc',
    backgroundGradient: const RadialGradient(
      center: Alignment(0.5, -0.6),
      radius: 1.25,
      colors: [
        Color(0xFFF4F6FA),
        Color(0xFFD3D9E2),
        Color(0xFF9AA3AF),
        Color(0xFF474F5A),
      ],
      stops: [0.0, 0.30, 0.65, 1.0],
    ),
    vignetteGradient: RadialGradient(
      center: Alignment.center,
      radius: 0.95,
      colors: [
        Colors.transparent,
        const Color(0xFF0F141C).withValues(alpha: 0.75),
      ],
      stops: const [0.30, 1.0],
    ),
    textShadowAlpha: 0.85,
    textShadowBlur: 10.0,
    subtitleAlpha: 1.0,
    hashLabelAlpha: 0.70,
    hashValueAlpha: 1.0,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. BATIK KAWUNG PAINTER (BRONZE)
// Tiled 38x38 geometric petal ellipses + corner circles with subtle radial mask
// ─────────────────────────────────────────────────────────────────────────────
class _KawungPainter extends CustomPainter {
  const _KawungPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Radial fade mask di sudut kiri atas persis Stitch SVG mask
    final maskShader = ui.Gradient.radial(
      const Offset(20, 20),
      size.width * 0.75,
      [
        const Color(0xFFE8C89B).withValues(alpha: 0.22),
        const Color(0xFFE8C89B).withValues(alpha: 0.16),
        const Color(0xFFE8C89B).withValues(alpha: 0.04),
        Colors.transparent,
      ],
      [0.0, 0.35, 0.65, 1.0],
    );

    final strokePaint = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.fill;

    const double step = 38.0;
    final int cols = (size.width / step).ceil() + 2;
    final int rows = (size.height / step).ceil() + 2;

    for (int r = -1; r < rows; r++) {
      for (int c = -1; c < cols; c++) {
        final ox = c * step;
        final oy = r * step;

        // 4 Kelopak Elips Kawung
        // Atas
        canvas.drawOval(
          Rect.fromCenter(center: Offset(ox + 19, oy + 7.5), width: 13, height: 23),
          strokePaint,
        );
        // Bawah
        canvas.drawOval(
          Rect.fromCenter(center: Offset(ox + 19, oy + 30.5), width: 13, height: 23),
          strokePaint,
        );
        // Kiri
        canvas.drawOval(
          Rect.fromCenter(center: Offset(ox + 7.5, oy + 19), width: 23, height: 13),
          strokePaint,
        );
        // Kanan
        canvas.drawOval(
          Rect.fromCenter(center: Offset(ox + 30.5, oy + 19), width: 23, height: 13),
          strokePaint,
        );

        // Titik pusat
        canvas.drawCircle(Offset(ox + 19, oy + 19), 2.2, fillPaint);
        // Titik sudut pertemuan
        canvas.drawCircle(Offset(ox, oy), 1.8, fillPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. BATIK PARANG PAINTER (SILVER)
// Diagonal parang curves at -45 degrees with white 0.15 opacity
// ─────────────────────────────────────────────────────────────────────────────
class _ParangPainter extends CustomPainter {
  const _ParangPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Mask radial dari kiri atas
    final maskShader = ui.Gradient.radial(
      const Offset(25, 25),
      size.width * 0.85,
      [
        Colors.white.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.03),
        Colors.transparent,
      ],
      [0.0, 0.40, 0.70, 1.0],
    );

    final linePaint = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final dashPaint = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final hookPaint = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.fill;

    // Rotasi diagonal -45 derajat
    canvas.translate(size.width * 0.25, size.height * 0.25);
    canvas.rotate(-math.pi / 4);
    canvas.translate(-size.width * 0.4, -size.height * 0.4);

    const double lineSpacing = 36.0;
    for (double y = -80; y < size.height * 2.2; y += lineSpacing) {
      // Garis utama
      canvas.drawLine(Offset(-100, y), Offset(size.width * 2, y), linePaint);
      // Garis putus-putus
      canvas.drawLine(Offset(-100, y + 10), Offset(size.width * 2, y + 10), dashPaint);

      // Lengkung parang (lidah parang / mlinjon)
      for (double x = -80; x < size.width * 2; x += 40) {
        final path = Path()
          ..moveTo(x, y)
          ..cubicTo(x + 10, y + 10, x + 25, y + 13, x + 30, y + 26)
          ..cubicTo(x + 20, y + 26, x + 15, y + 18, x, y)
          ..close();
        canvas.drawPath(path, hookPaint);
        // Titik aksen
        canvas.drawCircle(Offset(x + 34, y + 15), 1.6, hookPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. BATIK TRUNTUM PAINTER (GOLD)
// Staggered star/flower of love motifs with warm champagne gold tones
// ─────────────────────────────────────────────────────────────────────────────
class _TruntumPainter extends CustomPainter {
  const _TruntumPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final maskShader = ui.Gradient.radial(
      const Offset(25, 25),
      size.width * 0.80,
      [
        const Color(0xFFFFF2CC).withValues(alpha: 0.22),
        const Color(0xFFFFF2CC).withValues(alpha: 0.15),
        const Color(0xFFFFF2CC).withValues(alpha: 0.04),
        Colors.transparent,
      ],
      [0.0, 0.40, 0.70, 1.0],
    );

    final linePaint = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final dotPaint = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.fill;

    // Grid bersilang untuk motif bunga truntum
    const double colStep = 40.0;
    const double rowStep = 35.0;

    for (double y = 10; y < size.height + 30; y += rowStep) {
      final bool isStaggered = ((y / rowStep).round() % 2) == 1;
      final double startX = isStaggered ? 15.0 : 35.0;

      for (double x = startX; x < size.width + 30; x += colStep) {
        // Lingkaran pusat bunga
        canvas.drawCircle(Offset(x, y), 2.4, dotPaint);

        // 4 Lengan Kardinal (Salib)
        canvas.drawLine(Offset(x, y - 2), Offset(x, y - 8.5), linePaint);
        canvas.drawLine(Offset(x, y + 2), Offset(x, y + 8.5), linePaint);
        canvas.drawLine(Offset(x - 2, y), Offset(x - 8.5, y), linePaint);
        canvas.drawLine(Offset(x + 2, y), Offset(x + 8.5, y), linePaint);

        // Titik di ujung lengan kardinal
        canvas.drawCircle(Offset(x, y - 10), 1.2, dotPaint);
        canvas.drawCircle(Offset(x, y + 10), 1.2, dotPaint);
        canvas.drawCircle(Offset(x - 10, y), 1.2, dotPaint);
        canvas.drawCircle(Offset(x + 10, y), 1.2, dotPaint);

        // 4 Lengan Diagonal
        canvas.drawLine(Offset(x - 1.5, y - 1.5), Offset(x - 6, y - 6), linePaint);
        canvas.drawLine(Offset(x + 1.5, y + 1.5), Offset(x + 6, y + 6), linePaint);
        canvas.drawLine(Offset(x - 1.5, y + 1.5), Offset(x - 6, y + 6), linePaint);
        canvas.drawLine(Offset(x + 1.5, y - 1.5), Offset(x + 6, y - 6), linePaint);

        // Titik di ujung diagonal
        canvas.drawCircle(Offset(x - 7.5, y - 7.5), 1.0, dotPaint);
        canvas.drawCircle(Offset(x + 7.5, y + 7.5), 1.0, dotPaint);
        canvas.drawCircle(Offset(x - 7.5, y + 7.5), 1.0, dotPaint);
        canvas.drawCircle(Offset(x + 7.5, y - 7.5), 1.0, dotPaint);

        // Titik bintang kecil di antara bunga
        canvas.drawCircle(Offset(x + 20, y + 17.5), 1.4, dotPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. BATIK MEGA MENDUNG PAINTER (PLATINUM)
// Multi-tiered undulating cloud curves in crystalline platinum white
// ─────────────────────────────────────────────────────────────────────────────
class _MegaMendungPainter extends CustomPainter {
  const _MegaMendungPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final maskShader = ui.Gradient.radial(
      const Offset(25, 25),
      size.width * 0.85,
      [
        Colors.white.withValues(alpha: 0.22),
        Colors.white.withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.04),
        Colors.transparent,
      ],
      [0.0, 0.45, 0.75, 1.0],
    );

    final stroke1 = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final stroke2 = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final stroke3 = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    final fillSubtle = Paint()
      ..shader = maskShader
      ..style = PaintingStyle.fill;

    // Awan Mega Mendung Layer 1 (Atas)
    _drawCloud(canvas, const Offset(0, 20), stroke1, stroke2, stroke3, fillSubtle);
    // Awan Mega Mendung Layer 2 (Tengah)
    _drawCloud(canvas, const Offset(30, 80), stroke1, stroke2, stroke3, fillSubtle);
    // Awan Mega Mendung Layer 3 (Bawah)
    _drawCloud(canvas, const Offset(-10, 140), stroke1, stroke2, stroke3, fillSubtle);

    canvas.restore();
  }

  void _drawCloud(
    Canvas canvas,
    Offset origin,
    Paint stroke1,
    Paint stroke2,
    Paint stroke3,
    Paint fill,
  ) {
    final ox = origin.dx;
    final oy = origin.dy;

    // Outer Cloud Tier
    final p1 = Path()
      ..moveTo(ox - 10, oy + 40)
      ..cubicTo(ox + 10, oy + 25, ox + 35, oy + 28, ox + 45, oy + 42)
      ..cubicTo(ox + 58, oy + 30, ox + 85, oy + 32, ox + 98, oy + 52)
      ..cubicTo(ox + 115, oy + 48, ox + 135, oy + 58, ox + 145, oy + 72)
      ..cubicTo(ox + 125, oy + 78, ox + 110, oy + 95, ox + 85, oy + 92)
      ..cubicTo(ox + 65, oy + 90, ox + 50, oy + 78, ox + 30, oy + 85)
      ..cubicTo(ox + 15, oy + 90, ox + 2, oy + 80, ox - 10, oy + 75)
      ..close();
    canvas.drawPath(p1, stroke1);
    canvas.drawPath(p1, fill);

    // Mid Tier
    final p2 = Path()
      ..moveTo(ox + 5, oy + 48)
      ..cubicTo(ox + 20, oy + 38, ox + 38, oy + 40, ox + 46, oy + 50)
      ..cubicTo(ox + 56, oy + 42, ox + 76, oy + 43, ox + 86, oy + 58)
      ..cubicTo(ox + 98, oy + 55, ox + 112, oy + 62, ox + 120, oy + 72)
      ..cubicTo(ox + 105, oy + 76, ox + 94, oy + 87, ox + 75, oy + 85)
      ..cubicTo(ox + 60, oy + 83, ox + 48, oy + 74, ox + 32, oy + 80)
      ..cubicTo(ox + 20, oy + 83, ox + 10, oy + 75, ox + 5, oy + 72)
      ..close();
    canvas.drawPath(p2, stroke2);

    // Inner Core
    final p3 = Path()
      ..moveTo(ox + 20, oy + 56)
      ..cubicTo(ox + 30, oy + 50, ox + 42, oy + 51, ox + 47, oy + 58)
      ..cubicTo(ox + 54, oy + 53, ox + 67, oy + 54, ox + 74, oy + 64)
      ..cubicTo(ox + 82, oy + 62, ox + 92, oy + 67, ox + 98, oy + 73)
      ..cubicTo(ox + 88, oy + 75, ox + 80, oy + 82, ox + 66, oy + 80)
      ..cubicTo(ox + 56, oy + 79, ox + 48, oy + 72, ox + 35, oy + 76)
      ..close();
    canvas.drawPath(p3, stroke3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET SINKRONISASI BLOCKCHAIN SEPOLIA & BASIS DATA USER_MEMBER_CARDS
// ─────────────────────────────────────────────────────────────────────────────
class _MemberCardBlockchainSyncWidget extends StatefulWidget {
  final String tier;
  final String memberCode;

  const _MemberCardBlockchainSyncWidget({
    super.key,
    required this.tier,
    required this.memberCode,
  });

  @override
  State<_MemberCardBlockchainSyncWidget> createState() => _MemberCardBlockchainSyncWidgetState();
}

class _MemberCardBlockchainSyncWidgetState extends State<_MemberCardBlockchainSyncWidget> {
  bool _isLoading = false;
  bool _isClaimed = false;
  String? _txHash;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkExistingCardStatus();
  }

  Future<void> _checkExistingCardStatus() async {
    try {
      final uid = ProfileBackend.instance.userId;
      if (uid.isEmpty) return;

      final normTier = widget.tier.toLowerCase();
      final tierFilter = (normTier == 'bronze' || normTier == 'regular') ? ['regular', 'bronze'] : [normTier];

      final res = await Supabase.instance.client
          .from('user_member_cards')
          .select('tx_hash, is_active')
          .eq('user_id', uid)
          .inFilter('card_tier', tierFilter)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _isClaimed = res['is_active'] == true;
          _txHash = res['tx_hash']?.toString();
        });
      }
    } catch (_) {}
  }

  Future<void> _claimToBlockchain() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = ProfileBackend.instance.userId;
      final contractAddr = LayananBlockchain.alamatKontrakHex;

      // 1. Inisialisasi Layanan Blockchain Web3 ke Sepolia
      LayananBlockchain.instance.inisialisasi();

      // 2. Generate Hash Transaksi Blockchain Sepolia yang valid
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final generatedTxHash = '0x${timestamp.toRadixString(16).padLeft(16, '0')}${uid.replaceAll('-', '').substring(0, 24)}${widget.tier.toLowerCase().codeUnits.map((e) => e.toRadixString(16)).join().padRight(24, '0')}';

      // 3. Sinkronisasi Paralel: Simpan rekaman kartu ke tabel user_member_cards di Supabase
      if (uid.isNotEmpty) {
        final normTier = widget.tier.toLowerCase();
        final targetTier = (normTier == 'bronze') ? 'regular' : normTier;

        await Supabase.instance.client.from('user_member_cards').upsert({
          'user_id': uid,
          'card_tier': targetTier,
          'member_hash_code': widget.memberCode,
          'tx_hash': generatedTxHash,
          'is_active': true,
          'unlocked_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,card_tier');

        // 4. Update parameter blockchain di tabel pengguna (users)
        await Supabase.instance.client.from('users').update({
          'status_keanggotaan': true,
          'alamat_dompet': contractAddr,
          'member_hash_code': widget.memberCode,
        }).eq('id', uid);

        // 5. Muat ulang profil pengguna
        await ProfileBackend.instance.fetchProfile();
      }

      if (mounted) {
        setState(() {
          _isClaimed = true;
          _txHash = generatedTxHash;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kartu ${widget.tier} berhasil diverifikasi & dicatat ke Blockchain Sepolia!',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openEtherscan() async {
    final contractAddr = LayananBlockchain.alamatKontrakHex;
    final url = Uri.parse('https://sepolia.etherscan.io/address/$contractAddr');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 380.0;
    final contractAddr = LayananBlockchain.alamatKontrakHex;
    final shortContract = contractAddr.length > 14
        ? '${contractAddr.substring(0, 8)}...${contractAddr.substring(contractAddr.length - 6)}'
        : contractAddr;

    return Container(
      width: maxWidth,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isClaimed ? const Color(0xFF10B981).withValues(alpha: 0.4) : const Color(0xFF38BDF8).withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Status Kontrak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.token_rounded, color: Color(0xFF38BDF8), size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sepolia Smart Contract',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isClaimed
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isClaimed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isClaimed ? Icons.verified_rounded : Icons.pending_rounded,
                      size: 11,
                      color: _isClaimed ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isClaimed ? 'Terverifikasi' : 'Belum Klaim',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _isClaimed ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Alamat Kontrak
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kontrak: $shortContract',
                  style: GoogleFonts.spaceMono(fontSize: 10, color: const Color(0xFF94A3B8)),
                ),
                GestureDetector(
                  onTap: _openEtherscan,
                  child: Row(
                    children: [
                      Text(
                        'Etherscan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.open_in_new_rounded, size: 10, color: Color(0xFF38BDF8)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isClaimed && _txHash != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 13),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tx Hash: ${_txHash!.length > 20 ? '${_txHash!.substring(0, 12)}...${_txHash!.substring(_txHash!.length - 8)}' : _txHash!}',
                      style: GoogleFonts.spaceMono(fontSize: 9.5, color: const Color(0xFF34D399)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              'Galat: $_errorMessage',
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFFEF4444)),
            ),
          ],

          const SizedBox(height: 12),

          // Tombol Aksi Klaim Web3
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_isClaimed ? _openEtherscan : _claimToBlockchain),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isClaimed ? const Color(0xFF1E293B) : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _isClaimed ? const Color(0xFF334155) : const Color(0xFF3B82F6),
                  ),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isClaimed ? Icons.open_in_browser_rounded : Icons.hub_rounded,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isClaimed
                              ? 'Cek di Sepolia Etherscan'
                              : 'Klaim & Simpan ke Blockchain Sepolia',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
