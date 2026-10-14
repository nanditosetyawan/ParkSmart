import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrizeCar {
  final String name;
  final int points;
  final Color color;
  final IconData icon;
  final double xRatio; // 0.0 to 1.0 position along bottom rail

  PrizeCar({
    required this.name,
    required this.points,
    required this.color,
    required this.icon,
    required this.xRatio,
  });
}

class ClawsCarScreen extends StatefulWidget {
  const ClawsCarScreen({super.key});

  @override
  State<ClawsCarScreen> createState() => _ClawsCarScreenState();
}

class _ClawsCarScreenState extends State<ClawsCarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _clawDropController;
  late Animation<double> _clawDropAnimation;

  double _craneX = 0.5; // 0.0 to 1.0 (horizontal position)
  bool _isDropping = false;
  PrizeCar? _grabbedCar;
  int _score = 0;
  int _highScore = 0;
  int _attemptsLeft = 5;
  String _statusMessage = 'Arahkan cakar lalu tekan AMBIL!';

  final List<PrizeCar> _cars = [
    PrizeCar(
      name: 'Cyber SUV',
      points: 2000,
      color: const Color(0xFF06B6D4),
      icon: Icons.electric_car_rounded,
      xRatio: 0.15,
    ),
    PrizeCar(
      name: 'Golden Taxi',
      points: 3500,
      color: const Color(0xFFFBBF24),
      icon: Icons.local_taxi_rounded,
      xRatio: 0.32,
    ),
    PrizeCar(
      name: 'Super Sports',
      points: 4000,
      color: const Color(0xFFEF4444),
      icon: Icons.sports_motorsports_rounded,
      xRatio: 0.50,
    ),
    PrizeCar(
      name: 'Retro Cruiser',
      points: 1800,
      color: const Color(0xFF8B5CF6),
      icon: Icons.directions_car_filled_rounded,
      xRatio: 0.68,
    ),
    PrizeCar(
      name: 'Monster Truck',
      points: 2500,
      color: const Color(0xFF10B981),
      icon: Icons.fire_truck_rounded,
      xRatio: 0.85,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();

    _clawDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _clawDropAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _clawDropController,
        curve: Curves.easeInOut,
      ),
    );

    _clawDropController.addListener(_onClawDropTick);
    _clawDropController.addStatusListener(_onClawDropStatus);
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('claws_car_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScoreIfBest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('claws_car_high_score') ?? 0;
      if (_score > current) {
        await prefs.setInt('claws_car_high_score', _score);
        setState(() {
          _highScore = _score;
        });
      }
    } catch (_) {}
  }

  void _onClawDropTick() {
    setState(() {});
  }

  void _onClawDropStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Reached the bottom: check if claw is aligned with any prize car
      PrizeCar? caught;
      for (final car in _cars) {
        final double dist = (car.xRatio - _craneX).abs();
        if (dist < 0.09) {
          caught = car;
          break;
        }
      }

      if (caught != null) {
        HapticFeedback.heavyImpact();
        setState(() {
          _grabbedCar = caught;
          _statusMessage = 'BERHASIL! Menangkap ${caught!.name} (+${caught.points} pts)!';
        });
      } else {
        HapticFeedback.mediumImpact();
        setState(() {
          _statusMessage = 'Meleset! Cakar tidak mengenai mobil.';
        });
      }

      // Claw reels back up
      _clawDropController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      // Back at the top
      if (_grabbedCar != null) {
        _onCarSecured(_grabbedCar!);
      }

      setState(() {
        _isDropping = false;
        _grabbedCar = null;
        if (_attemptsLeft <= 0) {
          _showGameOverModal();
        } else {
          _statusMessage = 'Arahkan cakar lalu tekan AMBIL!';
        }
      });
    }
  }

  void _onCarSecured(PrizeCar car) {
    setState(() {
      _score += car.points;
    });
    _saveHighScoreIfBest();
    HapticFeedback.heavyImpact();
  }

  void _dropClaw() {
    if (_isDropping || _attemptsLeft <= 0) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isDropping = true;
      _grabbedCar = null;
      _attemptsLeft--;
      _statusMessage = 'Cakar sedang meluncur ke bawah...';
    });

    _clawDropController.forward();
  }

  void _moveLeft() {
    if (_isDropping) return;
    setState(() {
      _craneX = (_craneX - 0.06).clamp(0.08, 0.92);
    });
    HapticFeedback.selectionClick();
  }

  void _moveRight() {
    if (_isDropping) return;
    setState(() {
      _craneX = (_craneX + 0.06).clamp(0.08, 0.92);
    });
    HapticFeedback.selectionClick();
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _attemptsLeft = 5;
      _craneX = 0.5;
      _grabbedCar = null;
      _isDropping = false;
      _statusMessage = 'Arahkan cakar lalu tekan AMBIL!';
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
          side: const BorderSide(color: Color(0xFFEC4899), width: 2),
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
                    color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF472B6), width: 2),
                  ),
                  child: const Icon(Icons.precision_manufacturing_rounded, color: Color(0xFFF472B6), size: 28),
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
                  'Koin kesempatan Anda telah habis.',
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
                      backgroundColor: const Color(0xFFEC4899),
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
    _saveHighScoreIfBest();
    _clawDropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                                'CLAWS CAR ARCADE',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFF472B6),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                'Tangkap mobil idamanmu!',
                                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Skor & Koin Badge
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
                                  '$_attemptsLeft',
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

                // Arcade Glass Cabinet Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.6),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double width = constraints.maxWidth;
                            final double height = constraints.maxHeight;

                            final double cranePixelX = _craneX * (width - 44.0);
                            final double dropFraction = _clawDropAnimation.value;
                            // Max drop down to prize shelf (about height - 85)
                            final double maxDropDistance = height - 120.0;
                            final double clawCurrentY = dropFraction * maxDropDistance;

                            return Stack(
                              children: [
                                // Background Grid Lines inside machine
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.1,
                                    child: CustomPaint(
                                      painter: _ArcadeGridPainter(),
                                    ),
                                  ),
                                ),

                                // Top Crane Rail
                                Positioned(
                                  top: 14,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF64748B)),
                                    ),
                                  ),
                                ),

                                // Vertical Wire from crane to claw
                                Positioned(
                                  top: 20,
                                  left: cranePixelX + 21,
                                  child: Container(
                                    width: 3,
                                    height: clawCurrentY + 10,
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),

                                // Crane Gantry (horizontal carriage on the rail)
                                Positioned(
                                  top: 8,
                                  left: cranePixelX,
                                  child: Container(
                                    width: 44,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFEC4899).withValues(alpha: 0.6),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.build_circle_rounded, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),

                                // Mechanical Claw
                                Positioned(
                                  top: 20 + clawCurrentY,
                                  left: cranePixelX,
                                  child: Column(
                                    children: [
                                      // Claw joint
                                      Container(
                                        width: 44,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF472B6),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.settings, size: 12, color: Colors.white),
                                        ),
                                      ),
                                      // Claw Fingers (3 prongs)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Transform.rotate(
                                            angle: (_grabbedCar != null) ? 0.1 : -0.25,
                                            child: Container(
                                              width: 5,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE2E8F0),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 22),
                                          Transform.rotate(
                                            angle: (_grabbedCar != null) ? -0.1 : 0.25,
                                            child: Container(
                                              width: 5,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE2E8F0),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Grabbed Car in claw
                                      if (_grabbedCar != null)
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _grabbedCar!.color,
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _grabbedCar!.color.withValues(alpha: 0.6),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: Icon(_grabbedCar!.icon, size: 24, color: Colors.white),
                                        ),
                                    ],
                                  ),
                                ),

                                // Bottom Prize Shelf with Cars
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                                      border: const Border(
                                        top: BorderSide(color: Color(0xFF334155), width: 2),
                                      ),
                                    ),
                                    child: Stack(
                                      children: _cars.map((car) {
                                        final double carX = car.xRatio * (width - 50.0);
                                        return Positioned(
                                          left: carX,
                                          bottom: 12,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: car.color.withValues(alpha: 0.25),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: car.color, width: 1.5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: car.color.withValues(alpha: 0.3),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(car.icon, color: car.color, size: 24),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '+${car.points}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Status Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                ),

                // Arcade Control Panel (Joystick Left/Right & Big Grab Button)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Move Left Button
                      GestureDetector(
                        onTap: _moveLeft,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
                        ),
                      ),

                      // Big Arcade DROP / AMBIL Button
                      GestureDetector(
                        onTap: _dropClaw,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const RadialGradient(
                              colors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.6),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 24),
                                Text(
                                  'AMBIL',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Move Right Button
                      GestureDetector(
                        onTap: _moveRight,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 30),
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
    );
  }
}

class _ArcadeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 1.0;

    const double step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
