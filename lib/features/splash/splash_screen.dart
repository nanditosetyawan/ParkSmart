import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/session_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../admin/super_admin/admin_dashboard_screen.dart';
import '../admin/operations/admin_operations_dashboard_screen.dart';
import '../admin/finance/admin_finance_dashboard_screen.dart';
import '../admin/cs/admin_cs_dashboard_screen.dart';

/// SplashScreen dengan rendering GPU Hardware-Accelerated:
/// - Menggunakan RepaintBoundary untuk mengalokasikan tekstur GPU layer terisolasi.
/// - Fase 1: Animasi cairan berputar naik-turun (fluid vortex & wave dynamics).
/// - Fase 2: Kemunculan logo aplikasi secara perlahan (fade-in & smooth scale).
/// - Fase 3: Ledakan/luapan cairan multi-warna sesuai palet tema ParkSmart (Terracotta, Sunset Orange, Electric Teal, Golden Amber).
/// - Fase 4: Transisi luntur (smooth cross-dissolve) menuju halaman Login atau Dashboard jika sesi aktif.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasNavigated = false;

  // Daftar partikel gelembung cairan dinamis
  final List<_FluidBubble> _bubbles = List.generate(
    28,
    (index) => _FluidBubble(
      seed: index * 0.37,
      size: 4.0 + (index % 5) * 3.5,
      speed: 0.6 + (index % 4) * 0.4,
      hueOffset: (index * 13) % 360,
    ),
  );

  @override
  void initState() {
    super.initState();

    // Controller utama berdurasi ~3.2 detik untuk seluruh sekuens
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToDestination();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToDestination() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final session = SessionService.instance;
    Widget destination;

    if (session.isLoggedIn) {
      if (session.userType == 'admin') {
        final role = (session.adminRole ?? '').toLowerCase();
        if (role.contains('super')) {
          destination = const AdminDashboardScreen();
        } else if (role.contains('operasional') || role.contains('ops')) {
          destination = const AdminOperationsDashboardScreen();
        } else if (role.contains('finansial') || role.contains('finance')) {
          destination = const AdminFinanceDashboardScreen();
        } else if (role.contains('cs') || role.contains('support')) {
          destination = const AdminCsDashboardScreen();
        } else {
          destination = const AdminDashboardScreen();
        }
      } else {
        destination = const HomeScreen();
      }
    } else {
      destination = const LoginScreen();
    }

    // Transisi luntur lembut (fade cross-dissolve)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12), // Deep Obsidian Canvas
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToDestination, // Tap to skip
        child: RepaintBoundary(
          // Memaksa GPU layer tekstur tersendiri agar animasi 60-120fps tanpa beban CPU
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;

              // Timeline Progress:
              // Phase 1 (0.00 - 0.45): Vortex Swirl & Fluid Bobbing
              // Phase 2 (0.30 - 0.75): Logo Fade & Smooth Scale In
              // Phase 3 (0.55 - 0.95): Thematic Multi-Color Liquid Surge
              // Phase 4 (0.88 - 1.00): Fade Out To Next Screen

              // Kurva Logo
              final logoFade = Interval(0.28, 0.65, curve: Curves.easeOutCubic)
                  .transform(progress);
              final logoScale = Interval(0.25, 0.68, curve: Curves.easeOutBack)
                  .transform(progress);

              // Kurva Liquid Surge (Cairan Tema Ramai)
              final surgeProgress = Interval(0.48, 0.95, curve: Curves.easeInOut)
                  .transform(progress);

              // Fade Out Keseluruhan ke Background Putih/Gelap
              final screenOpacity = 1.0 -
                  Interval(0.92, 1.0, curve: Curves.easeIn).transform(progress);

              return Opacity(
                opacity: screenOpacity.clamp(0.0, 1.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Layer 1: GPU Fluid Vortex & Dynamic Wave Simulation
                    CustomPaint(
                      painter: _GpuFluidVortexPainter(
                        animationValue: progress,
                        surgeProgress: surgeProgress,
                        bubbles: _bubbles,
                      ),
                      size: Size.infinite,
                    ),

                    // Layer 2: Center Content (App Logo & Brand Identity)
                    Center(
                      child: Opacity(
                        opacity: logoFade.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.75 + (0.35 * logoScale),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Container Logo dengan Glow GPU Shader
                              Container(
                                width: 110,
                                height: 110,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                                  border: Border.all(
                                    color: const Color(0xFFF97316).withValues(alpha: 0.6),
                                    width: 2.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF97316).withValues(alpha: 0.4),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                                      blurRadius: 45,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.local_parking_rounded,
                                    size: 55,
                                    color: Color(0xFFF97316),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Nama Aplikasi
                              Text(
                                'ParkSmart',
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFFF97316).withValues(alpha: 0.6),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Tagline
                              Text(
                                'Smart, Seamless & Secure Parking',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Layer 3: Tombol Lewati Halus (Tap hint)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: progress > 0.4 && progress < 0.9 ? 0.6 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'Ketuk di mana saja untuk lanjut',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Model data untuk partikel gelembung fluida
class _FluidBubble {
  final double seed;
  final double size;
  final double speed;
  final double hueOffset;

  _FluidBubble({
    required this.seed,
    required this.size,
    required this.speed,
    required this.hueOffset,
  });
}

/// Painter Kustom GPU Accelerated
/// Menggambar pusaran cairan (Vortex), gelombang sinusoida berlapis,
/// gelembung melayang, dan luapan warna tema ParkSmart.
class _GpuFluidVortexPainter extends CustomPainter {
  final double animationValue; // 0.0 -> 1.0
  final double surgeProgress; // 0.0 -> 1.0
  final List<_FluidBubble> bubbles;

  _GpuFluidVortexPainter({
    required this.animationValue,
    required this.surgeProgress,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Vortex Spiral Swirling di Latar Belakang (Fase 1 & 2)
    _drawSwirlingVortex(canvas, size, center);

    // 2. Gelombang Cairan Naik-Turun Dasar (Teal & Cyan)
    _drawBaseFluidWaves(canvas, size);

    // 3. Gelombang Luapan Warna Tema Meriah (Fase 3: Orange, Terracotta, Amber)
    if (surgeProgress > 0.01) {
      _drawThematicColorSurge(canvas, size);
    }

    // 4. Partikel Gelembung Cairan Mengambang
    _drawFloatingBubbles(canvas, size);
  }

  /// Menggambar pusaran spiral fluida organik di sekitar pusat layar
  void _drawSwirlingVortex(Canvas canvas, Size size, Offset center) {
    final swirlRotation = animationValue * math.pi * 4.0; // Berputar 2 putaran penuh
    final maxRadius = size.width * 0.75;

    final vortexPaint = Paint()..style = PaintingStyle.stroke;

    // 4 pita spiral pusaran cairan
    for (int ring = 0; ring < 4; ring++) {
      final ringProgress = (animationValue * 1.5 + ring * 0.25) % 1.0;
      final radius = 25.0 + ringProgress * maxRadius;
      final bobbing = math.sin(animationValue * math.pi * 3.0 + ring) * 18.0;

      final startAngle = swirlRotation + (ring * math.pi / 2.0);
      final sweepAngle = math.pi * (0.8 + 0.4 * math.sin(animationValue * 5.0));

      final rect = Rect.fromCircle(
        center: Offset(center.dx, center.dy + bobbing),
        radius: radius,
      );

      // Warna spiral bergantian dari Teal ke Sunset Orange
      final color = ring % 2 == 0
          ? const Color(0xFF0D9488).withValues(alpha: 0.18 * (1.0 - ringProgress))
          : const Color(0xFFF97316).withValues(alpha: 0.22 * (1.0 - ringProgress));

      vortexPaint.color = color;
      vortexPaint.strokeWidth = 3.5 + (ring * 1.5);
      canvas.drawArc(rect, startAngle, sweepAngle, false, vortexPaint);
    }
  }

  /// Menggambar gelombang cairan dasar (naik-turun harmonik)
  void _drawBaseFluidWaves(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ketinggian gelombang dasar naik turun
    final baseElevation = h * 0.78 + math.sin(animationValue * math.pi * 2.5) * 35.0;

    // Layer Ombak Belakang (Deep Cyan/Teal)
    final backWavePath = Path();
    backWavePath.moveTo(0, h);
    backWavePath.lineTo(0, baseElevation);

    for (double x = 0; x <= w; x += 6) {
      final y = baseElevation +
          math.sin((x / w * 2.5 * math.pi) + (animationValue * math.pi * 3.5)) * 22.0 +
          math.cos((x / w * 1.8 * math.pi) - (animationValue * math.pi * 2.0)) * 14.0;
      backWavePath.lineTo(x, y);
    }

    backWavePath.lineTo(w, h);
    backWavePath.close();

    final backWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D9488).withValues(alpha: 0.45),
          const Color(0xFF064E3B).withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, baseElevation - 30, w, h - baseElevation + 30));

    canvas.drawPath(backWavePath, backWavePaint);
  }

  /// Menggambar luapan cairan warna-warni tema ParkSmart yang ramai (Fase 3)
  void _drawThematicColorSurge(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tingkat kenaikan cairan tema: naik dari bawah menembus separuh layar
    final surgeHeight = h - (surgeProgress * h * 0.65);

    // Layer 1: Ombak Sunset Orange & Golden Amber
    final orangePath = Path();
    orangePath.moveTo(0, h);
    orangePath.lineTo(0, surgeHeight);

    for (double x = 0; x <= w; x += 5) {
      final y = surgeHeight +
          math.sin((x / w * 3.2 * math.pi) - (animationValue * math.pi * 4.5)) * 28.0 * surgeProgress +
          math.cos((x / w * 4.0 * math.pi) + (animationValue * math.pi * 3.0)) * 16.0;
      orangePath.lineTo(x, y);
    }

    orangePath.lineTo(w, h);
    orangePath.close();

    final orangePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.70 * surgeProgress),
          const Color(0xFFC05621).withValues(alpha: 0.85 * surgeProgress),
          const Color(0xFF7C2D12).withValues(alpha: 0.95 * surgeProgress),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, surgeHeight - 35, w, h - surgeHeight + 35));

    canvas.drawPath(orangePath, orangePaint);

    // Layer 2: Ombak Puncak Keemasan (Golden Crest Wave)
    final crestPath = Path();
    final crestHeight = surgeHeight + 15.0;
    crestPath.moveTo(0, h);
    crestPath.lineTo(0, crestHeight);

    for (double x = 0; x <= w; x += 5) {
      final y = crestHeight +
          math.cos((x / w * 3.0 * math.pi) + (animationValue * math.pi * 5.0)) * 20.0 * surgeProgress +
          math.sin((x / w * 2.2 * math.pi) - (animationValue * math.pi * 2.5)) * 12.0;
      crestPath.lineTo(x, y);
    }

    crestPath.lineTo(w, h);
    crestPath.close();

    final crestPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFBBF24).withValues(alpha: 0.60 * surgeProgress),
          const Color(0xFFF59E0B).withValues(alpha: 0.35 * surgeProgress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, crestHeight - 20, w, 60));

    canvas.drawPath(crestPath, crestPaint);
  }

  /// Menggambar butiran gelembung cairan melayang mengikuti aliran
  void _drawFloatingBubbles(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bubblePaint = Paint()..style = PaintingStyle.fill;

    for (final b in bubbles) {
      // Posisi X mengayun sinusoidal
      final x = (w * (0.1 + 0.8 * ((b.seed * 7.3) % 1.0))) +
          math.sin(animationValue * math.pi * 3.0 * b.speed + b.seed) * 25.0;

      // Posisi Y mengalir naik dari bawah ke atas
      final normalizedY = (1.1 - ((animationValue * b.speed + b.seed) % 1.2));
      final y = h * normalizedY;

      // Warna bertransisi antara Orange, Cyan, dan Amber
      final color = (b.hueOffset % 3 == 0)
          ? const Color(0xFFF97316).withValues(alpha: 0.55)
          : (b.hueOffset % 3 == 1)
              ? const Color(0xFF0D9488).withValues(alpha: 0.50)
              : const Color(0xFFF59E0B).withValues(alpha: 0.60);

      bubblePaint.color = color;
      canvas.drawCircle(Offset(x, y), b.size, bubblePaint);

      // Specular highlight pada gelembung
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x - b.size * 0.3, y - b.size * 0.3), b.size * 0.28, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GpuFluidVortexPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.surgeProgress != surgeProgress;
  }
}
