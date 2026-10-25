import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend/car_game_backend.dart';
import 'backend/claws_car_backend.dart';
import 'backend/game_list_backend.dart';
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
  int _userPoints = 0;
  bool _isParkingActive = true;
  bool _isClawsActive = true;

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
        _userPoints = prefs.getInt('user_arcade_points') ?? 25000;
        _isParkingActive = prefs.getBool('arcade_parking_active') ?? true;
        _isClawsActive = prefs.getBool('arcade_claws_active') ?? true;
      });
    }

    // Sinkronisasi data real-time dari Supabase
    try {
      await Future.wait([
        CarGameBackend.instance.loadUserScores(),
        ClawsCarBackend.instance.loadUserScores(),
        GameListBackend.instance.fetchGameOverview(),
      ]);

      if (mounted) {
        setState(() {
          if (CarGameBackend.instance.highestScore > 0) {
            _parkingHighScore = CarGameBackend.instance.highestScore;
          }
          if (ClawsCarBackend.instance.highestScore > 0) {
            _clawsHighScore = ClawsCarBackend.instance.highestScore;
          }
          if (GameListBackend.instance.userPoints > 0) {
            _userPoints = GameListBackend.instance.userPoints;
          } else if (CarGameBackend.instance.userPoints > 0) {
            _userPoints = CarGameBackend.instance.userPoints;
          }
        });
      }
    } catch (e) {
      debugPrint('[GameListScreen] Error syncing scores from DB: $e');
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
    if (!_isParkingActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game Parking Challenge sedang dinonaktifkan oleh administrator.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
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
    if (!_isClawsActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game Claws Car sedang dinonaktifkan oleh administrator.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClawsCarScreen()),
    );
    _loadScores();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
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
                      Expanded(
                        child: Text(
                          'PILIH PERMAINAN',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF34D399),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatScore(_userPoints)} Pts',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
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
                        lastScore: _isParkingActive ? _formatScore(_parkingHighScore) : 'Nonaktif',
                        color1: const Color(0xFF114177),
                        color2: const Color(0xFF17A18A),
                        onTap: _openParkingGame,
                      ),
                      const SizedBox(height: 20),
                      _buildGameCard(
                        context: context,
                        icon: Icons.precision_manufacturing_rounded,
                        name: 'Claws Car',
                        lastScore: _isClawsActive ? _formatScore(_clawsHighScore) : 'Nonaktif',
                        color1: const Color(0xFF7E22CE),
                        color2: const Color(0xFFEC4899),
                        onTap: _openClawsGame,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
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
