import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'car_game_screen.dart';
import 'claws_car_screen.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  int _parkingHighScore = 0;
  int _clawsHighScore = 0;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _parkingHighScore = prefs.getInt('parking_high_score') ?? 0;
        _clawsHighScore = prefs.getInt('claws_car_high_score') ?? 0;
      });
    }
  }

  String _formatScore(int score) {
    if (score == 0) return '0';
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _openParkingGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CarGameScreen()),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _loadScores();
  }

  Future<void> _openClawsGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClawsCarScreen()),
    );
    _loadScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF475569)),
                          ),
                          child: const Icon(Icons.arrow_back, color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'PILIH PERMAINAN',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF34D399),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      _buildGameCard(
                        context: context,
                        icon: Icons.directions_car_rounded,
                        name: 'Parking Challenge',
                        lastScore: _formatScore(_parkingHighScore),
                        color1: const Color(0xFF114177),
                        color2: const Color(0xFF17A18A),
                        onTap: _openParkingGame,
                      ),
                      const SizedBox(height: 20),
                      _buildGameCard(
                        context: context,
                        icon: Icons.precision_manufacturing_rounded,
                        name: 'Claws Car',
                        lastScore: _formatScore(_clawsHighScore),
                        color1: const Color(0xFF7E22CE),
                        color2: const Color(0xFFEC4899),
                        onTap: _openClawsGame,
                      ),
                      const SizedBox(height: 20),
                      _buildGameCard(
                        context: context,
                        icon: Icons.view_comfy_rounded,
                        name: 'Puzzle Valet',
                        lastScore: 'Segera Hadir',
                        color1: const Color(0xFFC2410C),
                        color2: const Color(0xFFEAB308),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Game Puzzle Valet segera hadir di ParkSmart Arcade!',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: const Color(0xFF1E293B),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
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

  Widget _buildGameCard({
    required BuildContext context,
    required IconData icon,
    required String name,
    required String lastScore,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF334155)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color1, color2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Icon(icon, size: 72, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.history, color: Color(0xFF94A3B8), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Last Score: $lastScore',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17A18A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'MAIN',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
