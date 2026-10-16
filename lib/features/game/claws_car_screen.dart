import '../../theme/app_theme.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClawsCarScreen extends StatefulWidget {
  const ClawsCarScreen({super.key});

  @override
  State<ClawsCarScreen> createState() => _ClawsCarScreenState();
}

class _ClawsCarScreenState extends State<ClawsCarScreen>
    with TickerProviderStateMixin {
  // Posisi horizontal crane (0.0 = ujung kiri lubang pembuangan, 1.0 = ujung kanan)
  double _craneX = 0.5;

  // Animasi turun & naik capit
  late AnimationController _dropController;
  late Animation<double> _dropAnimation;

  // Postur capit:
  // 0.0 = Menguncup normal (posisi awal santai)
  // 1.0 = Membuka kuncup capitan (terbuka lebar siap mencapit)
  // 2.0 = Menguncup lagi (menjepit erat hadiah di dasar)
  double _clawPose = 0.0;
  late AnimationController _clawPoseController;

  // Animasi horizontal carriage saat meluncur otomatis ke lubang pembuangan
  late AnimationController _chuteTravelController;
  late Animation<double> _chuteTravelAnimation;
  double _chuteStartCraneX = 0.5;

  // Animasi pintu penutup lubang pembuangan (3D perspective flap door dengan efek buka-tutup natural)
  late AnimationController _flapController;
  late Animation<double> _flapAnimation;

  // Animasi lampu running atap marquee
  late AnimationController _marqueeLightController;

  // Status joystick interaktif
  Offset _joystickOffset = Offset.zero;
  double _joystickX = 0.0; // -1.0 (kiri penuh) s/d +1.0 (kanan penuh)
  Timer? _continuousMoveTimer;
  late AnimationController _joystickSpringController;
  late Animation<Offset> _joystickSpringAnimation;

  // Status tombol merah (efek turun saat ditekan)
  bool _isCapitButtonPressed = false;

  // Status operasional mesin
  bool _isOperating = false;
  int _score = 0;
  int _highScore = 0;
  int _credits = 5;

  @override
  void initState() {
    super.initState();

    // 1. Kunci rotasi ke portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _loadHighScore();

    // Controller turun & naik capit
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _dropAnimation = CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeInOutQuad,
    );

    // Controller transisi postur capit (0.0 = menguncup normal, 1.0 = terbuka lebar, 2.0 = menjepit)
    _clawPoseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Controller travel carriage ke lubang pembuangan
    _chuteTravelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _chuteTravelAnimation = CurvedAnimation(
      parent: _chuteTravelController,
      curve: Curves.easeInOutCubic,
    );
    _chuteTravelController.addListener(() {
      setState(() {
        _craneX = _chuteStartCraneX + (0.10 - _chuteStartCraneX) * _chuteTravelAnimation.value;
      });
    });

    // Controller pintu flap 3D lubang pembuangan dengan gerakan buka-tutup natural (berayun buka lalu balik menutup membal)
    _flapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _flapAnimation = TweenSequence<double>([
      // 1. Terdorong ke dalam oleh hadiah jatuh (0.0 -> 1.0)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 28,
      ),
      // 2. Berayun kembali dan membal sedikit keluar (-0.16)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: -0.16).chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 26,
      ),
      // 3. Membal berayun ke dalam lagi sedikit (0.08)
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.16, end: 0.08).chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 22,
      ),
      // 4. Meredam dan kembali diam menutup normal (0.0)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.08, end: 0.0).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 24,
      ),
    ]).animate(_flapController);

    // Controller running lights marquee
    _marqueeLightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Controller pegas joystick kembali ke tengah saat dilepas
    _joystickSpringAnimation = const AlwaysStoppedAnimation(Offset.zero);
    _joystickSpringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _joystickSpringController.addListener(() {
      setState(() {
        _joystickOffset = _joystickSpringAnimation.value;
        _joystickX = (_joystickOffset.dx / 38.0).clamp(-1.0, 1.0);
      });
    });

    // Game loop 60fps untuk gerakan crane kontinu saat joystick ditahan/diseret
    _continuousMoveTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isOperating && _joystickX.abs() > 0.04) {
        setState(() {
          _craneX = (_craneX + _joystickX * 0.014).clamp(0.08, 0.92);
        });
      }
    });
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _highScore = prefs.getInt('claws_car_high_score') ?? 0;
      });
    }
  }

  Future<void> _saveHighScoreIfBest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('claws_car_high_score') ?? 0;
      if (_score > current) {
        await prefs.setInt('claws_car_high_score', _score);
        if (mounted) {
          setState(() {
            _highScore = _score;
          });
        }
      }
    } catch (_) {}
  }

  // Helper untuk menganimasikan transisi postur capit secara halus
  Future<void> _animateClawPose(
    double target, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    _clawPoseController.duration = duration;
    final double start = _clawPose;
    final tween = Tween<double>(begin: start, end: target);
    final curved = CurvedAnimation(parent: _clawPoseController, curve: curve);
    void listener() {
      setState(() {
        _clawPose = tween.evaluate(curved);
      });
    }

    _clawPoseController.addListener(listener);
    _clawPoseController.reset();
    await _clawPoseController.forward();
    _clawPoseController.removeListener(listener);
    curved.dispose();
    if (mounted) {
      setState(() {
        _clawPose = target;
      });
    }
  }

  // ============================================================
  // LOGIKA ALUR CAPIT LENGKAP:
  // 1. Awal: Menguncup normal (santai, tidak over-menguncup)
  // 2. Klik: Membuka kuncup capitan dulu
  // 3. Turun ke barang dalam kondisi terbuka lebar
  // 4. Di dasar barang: Menguncup lagi / menjepit erat hadiah
  // 5. Naik pas udah mentok ke atas
  // 6. Geser ke lubang pembuangan hadiah di sebelah kiri
  // 7. Di atas lubang hadiah: Terbuka kuncupnya melepaskan hadiah
  // 8. Tutup lubang hadiah: Berayun buka-tutup natural (buka ke dalam lalu membal menutup)
  // 9. Rel kembali ke tengah dan capit kembali menguncup normal
  // ============================================================
  Future<void> _triggerClawAction() async {
    if (_isOperating || _credits <= 0) return;

    setState(() {
      _isOperating = true;
      _credits--;
    });
    HapticFeedback.heavyImpact();

    // 1. Dari posisi awal "menguncup normal", MEMBUKA KUNCUP CAPITAN DULU
    await _animateClawPose(1.0, duration: const Duration(milliseconds: 280), curve: Curves.easeOutBack);
    HapticFeedback.lightImpact();

    // 2. Dalam kondisi TERBUKA LEBAR, capit meluncur TURUN ke barang
    await _dropController.forward();
    HapticFeedback.mediumImpact();

    // 3. Di dasar barang, capit MENGUNCUP LAGI (menjepit erat hadiah)
    await _animateClawPose(2.0, duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 160));

    // 4. Dalam kondisi MENJEPIT, capit NAIK PAS UDAH MENTOK ke atas
    await _dropController.reverse();

    // 5. Meluncur geser ke lubang pembuangan hadiah di sebelah kiri
    _chuteStartCraneX = _craneX;
    await _chuteTravelController.forward();
    _chuteTravelController.reset();
    _craneX = 0.10;

    // 6. Di atas lubang hadiah, TERBUKA KUNCUPNYA untuk melepaskan hadiah
    await _animateClawPose(1.0, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    HapticFeedback.heavyImpact();

    // 7. Tutup lubang hadiah berayun buka-tutup secara natural
    _flapController.forward(from: 0.0);

    // Tambah skor & simpan high score
    setState(() {
      _score += 1500;
    });
    _saveHighScoreIfBest();

    await Future.delayed(const Duration(milliseconds: 800));

    // 8. Rel bergerak kembali ke posisi tengah santai, dan capit kembali MENGUNCUP NORMAL
    _chuteStartCraneX = _craneX;
    final centerTween = Tween<double>(begin: _craneX, end: 0.50);
    final returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final returnAnim = CurvedAnimation(parent: returnController, curve: Curves.easeInOut);
    returnController.addListener(() {
      setState(() {
        _craneX = centerTween.evaluate(returnAnim);
      });
    });

    await Future.wait([
      returnController.forward(),
      _animateClawPose(0.0, duration: const Duration(milliseconds: 550), curve: Curves.easeInOut),
    ]);
    returnController.dispose();

    if (mounted) {
      setState(() {
        _craneX = 0.50;
        _clawPose = 0.0; // Kembali menguncup normal
        _isOperating = false;
        if (_credits <= 0) {
          _showGameOverModal();
        }
      });
    }
  }

  // ============================================================
  // JOYSTICK INTERAKSI FLEKSIBEL (SENTUH DI MANA SAJA DALAM AREA)
  // ============================================================
  void _onJoystickPanDown(DragDownDetails details, BoxConstraints constraints) {
    if (_isOperating) return;
    _joystickSpringController.stop();
    _updateJoystick(details.localPosition, constraints);
  }

  void _onJoystickPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_isOperating) return;
    _updateJoystick(details.localPosition, constraints);
  }

  void _updateJoystick(Offset localPos, BoxConstraints constraints) {
    final Offset center = Offset(constraints.maxWidth * 0.5, constraints.maxHeight * 0.55);
    final double rawDx = localPos.dx - center.dx;
    final double rawDy = localPos.dy - center.dy;

    const double maxRadius = 38.0;
    final double dx = rawDx.clamp(-maxRadius, maxRadius);
    final double dy = rawDy.clamp(-maxRadius * 0.5, maxRadius * 0.5);

    setState(() {
      _joystickOffset = Offset(dx, dy);
      _joystickX = (dx / maxRadius).clamp(-1.0, 1.0);
    });
  }

  void _onJoystickPanEnd(DragEndDetails details) {
    _springJoystickToCenter();
  }

  void _onJoystickPanCancel() {
    _springJoystickToCenter();
  }

  void _springJoystickToCenter() {
    _joystickSpringAnimation = Tween<Offset>(
      begin: _joystickOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _joystickSpringController,
      curve: Curves.elasticOut,
    ));
    _joystickSpringController.forward(from: 0.0);
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _credits = 5;
      _craneX = 0.50;
      _isOperating = false;
      _clawPose = 0.0;
    });
  }

  void _showGameOverModal() {
    _saveHighScoreIfBest();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 340,
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF87171), width: 2),
                  ),
                  child: const Icon(Icons.precision_manufacturing_rounded, color: Color(0xFFF87171), size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  'PERMAINAN SELESAI!',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kredit koin kesempatan Anda telah habis.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('SKOR AKHIR', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                          Text('$_score pts',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          Text('HIGH SCORE', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                          Text('$_highScore pts',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _restartGame();
                    },
                    child: Text(
                      'Main Lagi (5 Koin)',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Kembali ke Menu',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n == 0) return '0';
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  void dispose() {
    _continuousMoveTimer?.cancel();
    _saveHighScoreIfBest();
    _dropController.dispose();
    _clawPoseController.dispose();
    _chuteTravelController.dispose();
    _flapController.dispose();
    _marqueeLightController.dispose();
    _joystickSpringController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // 1. TOP HEADER & STATUS BAR
            // ============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF475569)),
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFFE2E8F0), size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CLAWS CAR 3D',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFF472B6),
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Arcade Claw Machine',
                            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _formatNumber(_score),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFEC4899)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded, color: Color(0xFFEC4899), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$_credits',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ============================================================
            // 2. VIEWPORT 3D: MESIN CAPIT RAKSASA TINGGI PENUH & RUANGAN 3D
            // (Tinggi dimaksimalkan ke atas dan ke bawah sesuai permintaan)
            // ============================================================
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _dropAnimation,
                  _clawPoseController,
                  _flapAnimation,
                  _marqueeLightController,
                ]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ClawMachine3DScenePainter(
                      craneX: _craneX,
                      dropProgress: _dropAnimation.value,
                      clawPose: _clawPose,
                      flapProgress: _flapAnimation.value,
                      marqueePhase: _marqueeLightController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // ============================================================
            // 3. KONTROL DI HP (HINT DIHILANGKAN TOTAL)
            // Kiri: Joystick dengan dudukan bawahController & stik atasController
            // Kanan: Tombol merah 3D murni kode dengan efek turun saat diklik
            // ============================================================
            Container(
              height: 145,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- KIRI: DUDUKAN & STIK JOYSTICK ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const double joyBoxWidth = 135.0;
                      const double joyBoxHeight = 130.0;

                      final double tiltAngle = (_joystickOffset.dx / 38.0) * (math.pi / 7.5);

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanDown: (d) => _onJoystickPanDown(d, const BoxConstraints(maxWidth: joyBoxWidth, maxHeight: joyBoxHeight)),
                        onPanUpdate: (d) => _onJoystickPanUpdate(d, const BoxConstraints(maxWidth: joyBoxWidth, maxHeight: joyBoxHeight)),
                        onPanEnd: _onJoystickPanEnd,
                        onPanCancel: _onJoystickPanCancel,
                        child: SizedBox(
                          width: joyBoxWidth,
                          height: joyBoxHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Dudukan Joystick (bawahController.png)
                              Positioned(
                                bottom: 12,
                                child: Image.asset(
                                  'assets/images/bawahController.png',
                                  width: 118,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // Stik Pegangan (atasController.png) dinaikkan posisinya secara vertikal pas di lubang socket
                              Positioned(
                                bottom: 56,
                                child: Transform(
                                  alignment: Alignment.bottomCenter,
                                  transform: Matrix4.translationValues(_joystickOffset.dx, _joystickOffset.dy * 0.35, 0)
                                    ..rotateZ(tiltAngle),
                                  child: Image.asset(
                                    'assets/images/atasController.png',
                                    width: 54,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // --- KANAN: TOMBOL MERAH ARCADE DENGAN EFEK TEKAN TURUN ---
                  GestureDetector(
                    onTapDown: (_) {
                      setState(() => _isCapitButtonPressed = true);
                    },
                    onTapUp: (_) {
                      setState(() => _isCapitButtonPressed = false);
                      _triggerClawAction();
                    },
                    onTapCancel: () {
                      setState(() => _isCapitButtonPressed = false);
                    },
                    child: SizedBox(
                      width: 95,
                      height: 95,
                      child: Center(
                        child: _buildRealisticRedArcadeButton(isPressed: _isCapitButtonPressed),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // ============================================================
  // WIDGET KODE TOMBOL MERAH 3D (MIRIP GAMBAR REFERENSI DENGAN EFEK TURUN)
  // ============================================================
  Widget _buildRealisticRedArcadeButton({required bool isPressed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      curve: Curves.easeOut,
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Bezel logam luar (Outer Chrome/Steel Ring)
        gradient: const SweepGradient(
          colors: [
            Color(0xFFE2E8F0),
            Color(0xFF94A3B8),
            Color(0xFF334155),
            Color(0xFFE2E8F0),
            Color(0xFFCBD5E1),
            Color(0xFF475569),
            Color(0xFFE2E8F0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          if (!isPressed)
            BoxShadow(
              color: const Color(0xFFDC2626).withValues(alpha: 0.35),
              blurRadius: 14,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        // Cincin groove dalam
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
          ),
          child: Center(
            // Kubah Merah Arcade yang turun saat ditekan
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              transform: Matrix4.translationValues(0, isPressed ? 3.5 : 0, 0),
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.25, -0.35),
                  radius: 0.85,
                  colors: [
                    Color(0xFFFF4D4D), // Highlight merah terang
                    Color(0xFFDC2626), // Merah arcade
                    Color(0xFF991B1B), // Merah gelap
                    Color(0xFF580C0C), // Bayangan lekukan dasar
                  ],
                ),
                boxShadow: isPressed
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF450A0A),
                          offset: const Offset(0, 4),
                          blurRadius: 3,
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  // Pantulan cahaya kilau oval melengkung di atas kubah (Specular highlight)
                  Positioned(
                    top: 6,
                    left: 12,
                    child: Container(
                      width: 24,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.65),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'CAPIT',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOM PAINTER: MESIN CAPIT 3D TINGGI MAKSIMAL + LOGIKA BANGUN RUANG
// ============================================================
class _ClawMachine3DScenePainter extends CustomPainter {
  final double craneX; // 0.0 to 1.0
  final double dropProgress; // 0.0 to 1.0
  final double clawPose; // 0.0 = menguncup normal, 1.0 = terbuka lebar, 2.0 = menjepit rapat
  final double flapProgress; // -0.16 s/d 1.0 (berayun buka tutup natural)
  final double marqueePhase; // 0.0 to 1.0

  _ClawMachine3DScenePainter({
    required this.craneX,
    required this.dropProgress,
    required this.clawPose,
    required this.flapProgress,
    required this.marqueePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ------------------------------------------------------------
    // A. RUANG 3D: TEMBOK BELAKANG & TEMBOK SAMPING
    // ------------------------------------------------------------
    final double horizonY = h * 0.40;

    // Dinding aula arcade belakang
    final backWallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
      ).createShader(Rect.fromLTRB(0, 0, w, horizonY));
    canvas.drawRect(Rect.fromLTRB(0, 0, w, horizonY), backWallPaint);

    // Garis neon aksen arcade di tembok belakang
    final neonLinePaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.22)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, horizonY * 0.35), Offset(w, horizonY * 0.35), neonLinePaint);
    canvas.drawLine(Offset(0, horizonY * 0.70), Offset(w, horizonY * 0.70), neonLinePaint);

    // ------------------------------------------------------------
    // B. RUANG 3D: LANTAI PERSPEKTIF (TILED FLOOR)
    // ------------------------------------------------------------
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B0F19), Color(0xFF020617)],
      ).createShader(Rect.fromLTRB(0, horizonY, w, h));
    canvas.drawRect(Rect.fromLTRB(0, horizonY, w, h), floorPaint);

    // Garis ubin perspektif menuju titik lenyap
    final tilePaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.12)
      ..strokeWidth = 1.2;

    final Offset vanishingPoint = Offset(w * 0.5, horizonY * 0.95);
    for (int i = -6; i <= 6; i++) {
      final double bottomX = w * 0.5 + i * (w * 0.14);
      canvas.drawLine(vanishingPoint, Offset(bottomX, h), tilePaint);
    }
    for (double f = 0.1; f <= 1.0; f += 0.15) {
      final double y = horizonY + (h - horizonY) * math.pow(f, 2.0);
      canvas.drawLine(Offset(0, y), Offset(w, y), tilePaint);
    }

    // ------------------------------------------------------------
    // C. DIMENSI KOTAK 3D MESIN CAPIT (DIKECILKAN HEIGHT-NYA SECARA PROPORSIONAL)
    // ------------------------------------------------------------
    final double boxW = w * 0.76;
    final double boxLeft = (w - boxW) * 0.42;
    final double boxRight = boxLeft + boxW;

    // Proporsi height mesin dan posisi vertikal diturunkan ke bawah agar tidak banyak ruang kosong di bawah:
    final double marqueeTop = h * 0.15;
    final double marqueeHeight = h * 0.08;
    final double glassTop = marqueeTop + marqueeHeight;

    final double glassHeight = h * 0.36; // Etalase kaca proporsional
    final double bodyTop = glassTop + glassHeight;

    final double bodyHeight = h * 0.33; // Body bawah proporsional
    final double boxBottom = bodyTop + bodyHeight; // h * 0.92, pas di lantai atas kontrol panel

    // Vektor kedalaman 3D rusuk
    const double depthDx = 30.0;
    const double depthDy = -18.0;

    // 1. Bayangan mesin di lantai
    final shadowPath = Path()
      ..moveTo(boxLeft - 12, boxBottom + 4)
      ..lineTo(boxRight + depthDx + 12, boxBottom + depthDy + 4)
      ..lineTo(boxRight + 8, boxBottom + 18)
      ..lineTo(boxLeft - 4, boxBottom + 18)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // ------------------------------------------------------------
    // D. SISI SAMPING KEDALAMAN 3D (RIGHT SIDE DEPTH FACES)
    // ------------------------------------------------------------
    // Sisi samping kanan atap marquee
    final rightMarqueePath = Path()
      ..moveTo(boxRight, marqueeTop)
      ..lineTo(boxRight + depthDx, marqueeTop + depthDy)
      ..lineTo(boxRight + depthDx, glassTop + depthDy)
      ..lineTo(boxRight, glassTop)
      ..close();
    canvas.drawPath(
      rightMarqueePath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7E22CE), Color(0xFF4C1D95)],
        ).createShader(rightMarqueePath.getBounds()),
    );

    // Sisi samping kanan kaca transparan (depth glass)
    final rightGlassPath = Path()
      ..moveTo(boxRight, glassTop)
      ..lineTo(boxRight + depthDx, glassTop + depthDy)
      ..lineTo(boxRight + depthDx, bodyTop + depthDy)
      ..lineTo(boxRight, bodyTop)
      ..close();
    canvas.drawPath(
      rightGlassPath,
      Paint()..color = const Color(0xFF0EA5E9).withValues(alpha: 0.15),
    );
    canvas.drawPath(
      rightGlassPath,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Sisi samping kanan body bawah
    final rightBodyPath = Path()
      ..moveTo(boxRight, bodyTop)
      ..lineTo(boxRight + depthDx, bodyTop + depthDy)
      ..lineTo(boxRight + depthDx, boxBottom + depthDy)
      ..lineTo(boxRight, boxBottom)
      ..close();
    canvas.drawPath(
      rightBodyPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B21A8), Color(0xFF3B0764)],
        ).createShader(rightBodyPath.getBounds()),
    );

    // Rusuk luar samping
    final rusukPaint = Paint()
      ..color = const Color(0xFFF472B6).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(boxRight + depthDx, marqueeTop + depthDy), Offset(boxRight + depthDx, boxBottom + depthDy), rusukPaint);
    canvas.drawLine(Offset(boxRight, boxBottom), Offset(boxRight + depthDx, boxBottom + depthDy), rusukPaint);

    // ------------------------------------------------------------
    // E. ATAP ATAS 3D (TOP ROOF FACE)
    // ------------------------------------------------------------
    final topRoofPath = Path()
      ..moveTo(boxLeft, marqueeTop)
      ..lineTo(boxLeft + depthDx, marqueeTop + depthDy)
      ..lineTo(boxRight + depthDx, marqueeTop + depthDy)
      ..lineTo(boxRight, marqueeTop)
      ..close();
    canvas.drawPath(
      topRoofPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFFA855F7), Color(0xFF7E22CE)],
        ).createShader(topRoofPath.getBounds()),
    );

    // ------------------------------------------------------------
    // F. RUANG DALAM KACA (POLOSAN DULU)
    // ------------------------------------------------------------
    final innerBackRect = Rect.fromLTRB(boxLeft + 4, glassTop + 4, boxRight - 4, bodyTop);
    final innerBackPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      ).createShader(innerBackRect);
    canvas.drawRect(innerBackRect, innerBackPaint);

    // Lantai dalam etalase mesin capit
    final innerFloorPath = Path()
      ..moveTo(boxLeft + 4, bodyTop)
      ..lineTo(boxLeft + depthDx * 0.7, bodyTop + depthDy * 0.7)
      ..lineTo(boxRight + depthDx * 0.7, bodyTop + depthDy * 0.7)
      ..lineTo(boxRight - 4, bodyTop)
      ..close();
    canvas.drawPath(
      innerFloorPath,
      Paint()..color = const Color(0xFF334155),
    );

    // Kumpulan barang hadiah (capsule & mini arcade cars) di dasar lantai kaca
    final prizeColors = [
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
    ];
    for (int i = 0; i < prizeColors.length; i++) {
      final double px = boxLeft + 24.0 + i * ((boxW - 48.0) / (prizeColors.length - 1));
      final double py = bodyTop - 6.0 + (i % 2 == 0 ? -3.0 : 2.0);
      final prizeRect = Rect.fromCenter(center: Offset(px, py), width: 22, height: 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(prizeRect, const Radius.circular(6)),
        Paint()..color = prizeColors[i],
      );
      // Highlight kilau kapsul hadiah
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(prizeRect.left + 3, prizeRect.top + 2, 7, 5),
          const Radius.circular(3),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }

    // ------------------------------------------------------------
    // G. MEKANISME PENGGERAK CAPIT & REL ATAS
    // Rel dan carriage bergerak smooth ke kanan/kiri mengikuti joystick
    // ------------------------------------------------------------
    final double railY = glassTop + 14.0;
    // Batang rel atas
    canvas.drawLine(
      Offset(boxLeft + 12, railY),
      Offset(boxRight - 12, railY),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(boxLeft + 12, railY - 1),
      Offset(boxRight - 12, railY - 1),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );

    // Posisi horizontal carriage penggerak
    final double cranePixelX = boxLeft + 28.0 + craneX * (boxW - 56.0);
    final trolleyRect = Rect.fromCenter(center: Offset(cranePixelX, railY), width: 34, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trolleyRect, const Radius.circular(4)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFCBD5E1), Color(0xFF475569)],
        ).createShader(trolleyRect),
    );

    // Perhitungan jarak turun kabel baja
    final double maxDropDistance = (bodyTop - railY) - 46.0;
    final double clawCurrentY = railY + 8.0 + dropProgress * maxDropDistance;

    // Kabel baja vertikal
    canvas.drawLine(
      Offset(cranePixelX, railY + 8),
      Offset(cranePixelX, clawCurrentY),
      Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 2.5,
    );

    // Kepala capit besi (Steel Hub)
    final hubRect = Rect.fromCenter(center: Offset(cranePixelX, clawCurrentY + 8), width: 22, height: 14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(hubRect, const Radius.circular(4)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFF64748B), Color(0xFF334155)],
        ).createShader(hubRect),
    );

    canvas.drawCircle(
      Offset(cranePixelX, clawCurrentY + 8),
      3.5,
      Paint()..color = Colors.white,
    );

    // ------------------------------------------------------------
    // ANIMASI CAPIT BESI (ARAH ROTASI KINI DIBALIK / REVERSED):
    // Sudut positif pada lengan kiri memutar keluar ke arah kiri (-X).
    // Sudut negatif pada lengan kanan memutar keluar ke arah kanan (+X).
    //
    // 0.0 = Menguncup normal (idle santai, gap ~11px, tidak menyilang)
    // 1.0 = Membuka kuncup capitan (terbuka lebar ke luar, gap ~43px)
    // 2.0 = Menguncup lagi (menjepit erat hadiah di dasar, gap ~2.6px)
    // ------------------------------------------------------------
    double angleLeft;
    double angleRight;
    double angleCenter;

    if (clawPose <= 1.0) {
      final double t = clawPose.clamp(0.0, 1.0);
      // Dari Menguncup Normal (+0.14) -> Membuka Lebar (+0.62)
      angleLeft = 0.14 + t * 0.48;
      // Dari Menguncup Normal (-0.14) -> Membuka Lebar (-0.62)
      angleRight = -0.14 - t * 0.48;
      angleCenter = t * 0.18;
    } else {
      final double t = (clawPose - 1.0).clamp(0.0, 1.0);
      // Dari Membuka Lebar (+0.62) -> Menjepit Rapat (+0.01)
      angleLeft = 0.62 - t * 0.61;
      // Dari Membuka Lebar (-0.62) -> Menjepit Rapat (-0.01)
      angleRight = -0.62 + t * 0.61;
      angleCenter = 0.18 * (1.0 - t);
    }

    final bool isOpen = clawPose > 0.4 && clawPose < 1.6;
    _drawWideSteelProng(canvas, Offset(cranePixelX - 7, clawCurrentY + 14), angleLeft, isLeft: true, isOpen: isOpen);
    _drawWideSteelProng(canvas, Offset(cranePixelX + 7, clawCurrentY + 14), angleRight, isLeft: false, isOpen: isOpen);
    _drawWideSteelProng(canvas, Offset(cranePixelX, clawCurrentY + 16), angleCenter, isCenter: true, isOpen: isOpen);

    // ------------------------------------------------------------
    // H. KACA DEPAN DENGAN EFEK PANTULAN GLASS (SPECULAR GLARE)
    // ------------------------------------------------------------
    final frontGlassRect = Rect.fromLTRB(boxLeft, glassTop, boxRight, bodyTop);

    canvas.drawRect(
      frontGlassRect,
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.07),
    );

    // Pantulan diagonal 1
    final glarePath1 = Path()
      ..moveTo(boxLeft + 20, glassTop)
      ..lineTo(boxLeft + 70, glassTop)
      ..lineTo(boxLeft + 30, bodyTop)
      ..lineTo(boxLeft, bodyTop)
      ..close();
    canvas.drawPath(
      glarePath1,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.03),
          ],
        ).createShader(frontGlassRect),
    );

    // Pantulan diagonal 2
    final glarePath2 = Path()
      ..moveTo(boxRight - 55, glassTop)
      ..lineTo(boxRight - 35, glassTop)
      ..lineTo(boxRight - 15, bodyTop)
      ..lineTo(boxRight - 35, bodyTop)
      ..close();
    canvas.drawPath(
      glarePath2,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.02),
          ],
        ).createShader(frontGlassRect),
    );

    // Tiang sudut kaca krom
    final cornerPostPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
      ).createShader(frontGlassRect)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(boxLeft, glassTop), Offset(boxLeft, bodyTop), cornerPostPaint);
    canvas.drawLine(Offset(boxRight, glassTop), Offset(boxRight, bodyTop), cornerPostPaint);
    canvas.drawLine(Offset(boxLeft, glassTop), Offset(boxRight, glassTop), cornerPostPaint);

    // ------------------------------------------------------------
    // I. ATAP / MARQUEE DEPAN DENGAN TEKS & LAMPU BERKEDIP
    // ------------------------------------------------------------
    final marqueeRect = Rect.fromLTRB(boxLeft, marqueeTop, boxRight, glassTop);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        marqueeRect,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD946EF), Color(0xFF9333EA)],
        ).createShader(marqueeRect),
    );

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        marqueeRect,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      Paint()
        ..color = const Color(0xFFF472B6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Teks Marquee
    final textPainter = TextPainter(
      text: TextSpan(
        text: '★ CLAWS CAR ★',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          shadows: [
            Shadow(color: const Color(0xFFF43F5E), blurRadius: 10),
            Shadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(1, 2)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        boxLeft + (boxW - textPainter.width) * 0.5,
        marqueeTop + (marqueeHeight - textPainter.height) * 0.5,
      ),
    );

    // Lampu running neon
    final int lightCount = 9;
    for (int i = 0; i < lightCount; i++) {
      final double lx = boxLeft + 16.0 + i * ((boxW - 32.0) / (lightCount - 1));
      final bool isLit = ((i + (marqueePhase * lightCount).toInt()) % 2 == 0);
      canvas.drawCircle(
        Offset(lx, marqueeTop + 8),
        3.0,
        Paint()..color = isLit ? const Color(0xFFFDE047) : const Color(0xFF713F12),
      );
    }

    // ------------------------------------------------------------
    // J. BODY BAWAH 3D & KONSOL KONTROL MENONJOL KE DEPAN
    // ------------------------------------------------------------
    final bodyRect = Rect.fromLTRB(boxLeft, bodyTop, boxRight, boxBottom);
    canvas.drawRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9333EA), Color(0xFF6B21A8), Color(0xFF3B0764)],
        ).createShader(bodyRect),
    );

    // Konsol miring menonjol ke depan
    final double shelfTop = bodyTop + 5.0;
    final double shelfHeight = 32.0;

    final shelfPath = Path()
      ..moveTo(boxLeft + 10, shelfTop)
      ..lineTo(boxRight - 10, shelfTop)
      ..lineTo(boxRight - 4, shelfTop + shelfHeight)
      ..lineTo(boxLeft + 4, shelfTop + shelfHeight)
      ..close();
    canvas.drawPath(
      shelfPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC084FC), Color(0xFF7E22CE)],
        ).createShader(Rect.fromLTRB(boxLeft, shelfTop, boxRight, shelfTop + shelfHeight)),
    );
    canvas.drawPath(
      shelfPath,
      Paint()
        ..color = const Color(0xFFF472B6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Detail dekoratif di konsol kontrol
    canvas.drawCircle(Offset(boxLeft + 45, shelfTop + 16), 6, Paint()..color = const Color(0xFF1E293B));
    canvas.drawLine(
      Offset(boxLeft + 45, shelfTop + 16),
      Offset(boxLeft + 42, shelfTop + 7),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(boxLeft + 42, shelfTop + 7), 4.5, Paint()..color = const Color(0xFFEF4444));

    canvas.drawCircle(Offset(boxLeft + 72, shelfTop + 16), 4.5, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(Offset(boxLeft + 86, shelfTop + 16), 4.5, Paint()..color = const Color(0xFF10B981));

    // Lubang koin
    final coinSlotRect = Rect.fromCenter(center: Offset(boxRight - 48, shelfTop + 16), width: 18, height: 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(coinSlotRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawLine(
      Offset(boxRight - 48, shelfTop + 12),
      Offset(boxRight - 48, shelfTop + 20),
      Paint()
        ..color = const Color(0xFFFDE047)
        ..strokeWidth = 1.8,
    );

    // ------------------------------------------------------------
    // K. LUBANG PENGELUARAN HADIAH 3D DENGAN PINTU FLAP BERAYUN 3D
    // Berayun buka-tutup natural: terbuka masuk ke dalam lalu membal menutup
    // ------------------------------------------------------------
    final double chuteW = boxW * 0.34;
    final double chuteH = 50.0;
    final double chuteX = boxLeft + 16.0;
    final double chuteY = boxBottom - chuteH - 14.0;

    final chuteRect = Rect.fromLTWH(chuteX, chuteY, chuteW, chuteH);

    // Bingkai luar lubang
    canvas.drawRRect(
      RRect.fromRectAndRadius(chuteRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ).createShader(chuteRect),
    );

    // Rongga kedalaman 3D hitam lubang hadiah
    final innerChuteRect = Rect.fromLTWH(chuteX + 4, chuteY + 4, chuteW - 8, chuteH - 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerChuteRect, const Radius.circular(6)),
      Paint()..color = Colors.black,
    );

    // PINTU FLAP LOGAM DENGAN PERSPEKTIF 3D DEPAN-BELAKANG (LOGIKA BANGUN RUANG)
    // Saat flapProgress berayun (0.0 -> 1.0 -> -0.16 -> 0.08 -> 0.0):
    // Pintu berayun masuk ke dalam rongga mesin lalu membal natural kembali ke posisi normal menutup rapat.
    final double swingAngle = flapProgress * (math.pi / 2.8);
    final double flapLen = (chuteH - 14) * math.cos(swingAngle);
    final double insetX = 6.0 * math.sin(swingAngle);

    final flapTopY = chuteY + 5.0;
    final flapBotY = flapTopY + flapLen;

    final flapPath = Path()
      ..moveTo(chuteX + 8, flapTopY)
      ..lineTo(chuteX + chuteW - 8, flapTopY)
      ..lineTo(chuteX + chuteW - 8 - insetX, flapBotY)
      ..lineTo(chuteX + 8 + insetX, flapBotY)
      ..close();

    // Shader logam flap berbayang saat berayun ke dalam
    canvas.drawPath(
      flapPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF94A3B8),
            Color.lerp(const Color(0xFF334155), const Color(0xFF0F172A), flapProgress.clamp(0.0, 1.0))!,
          ],
        ).createShader(flapPath.getBounds()),
    );
    // Garis tepi 3D flap
    canvas.drawPath(
      flapPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Border neon pada lubang pengeluaran hadiah
    canvas.drawRRect(
      RRect.fromRectAndRadius(chuteRect, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Label "PRIZE WIN"
    final prizeLabel = TextPainter(
      text: const TextSpan(
        text: 'PRIZE WIN',
        style: TextStyle(
          color: Color(0xFF38BDF8),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    prizeLabel.paint(
      canvas,
      Offset(chuteX + (chuteW - prizeLabel.width) * 0.5, chuteY + chuteH - 11),
    );
  }

  // Helper menggambar cakar capit baja lebar (prongs wide open & separated)
  void _drawWideSteelProng(
    Canvas canvas,
    Offset origin,
    double angle, {
    bool isLeft = false,
    bool isCenter = false,
    bool isOpen = true,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final prongPath = Path();
    prongPath.moveTo(0, 0);

    // Ruas atas cakar mengarah keluar lebar
    final double upperDx = isLeft ? -7 : (isCenter ? 0 : 7);
    prongPath.lineTo(upperDx, 16);

    // Lengkungan cakar bawah
    final double curveDx = isLeft ? -14 : (isCenter ? 0 : 14);
    final double tipDx = isLeft ? 2 : (isCenter ? 0 : -2);
    prongPath.quadraticBezierTo(curveDx, 32, tipDx, 36);

    // Ujung kait cakar tajam
    prongPath.lineTo(tipDx + (isLeft ? 4 : (isCenter ? 0 : -4)), 33);
    prongPath.quadraticBezierTo(curveDx * 0.7, 28, upperDx * 0.5, 14);
    prongPath.close();

    final steelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isCenter
            ? [const Color(0xFF94A3B8), const Color(0xFF334155)]
            : [const Color(0xFFFFFFFF), const Color(0xFFCBD5E1), const Color(0xFF64748B)],
      ).createShader(prongPath.getBounds());
    canvas.drawPath(prongPath, steelPaint);

    canvas.drawPath(
      prongPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ClawMachine3DScenePainter oldDelegate) {
    return oldDelegate.craneX != craneX ||
        oldDelegate.dropProgress != dropProgress ||
        oldDelegate.clawPose != clawPose ||
        oldDelegate.flapProgress != flapProgress ||
        oldDelegate.marqueePhase != marqueePhase;
  }
}
