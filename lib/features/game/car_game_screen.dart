import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// MODEL PARKIRAN & RINTANGAN RANJAU
// ============================================================
enum SlotStatus {
  occupied, // Terisi mobil lain (penghalang padat)
  reserved, // Ditutup / Khusus (penghalang padat)
  target,   // Target parkir aktif (hijau menyala READY PARK)
  parked,   // Berhasil diparkir oleh pemain dalam ronde ini
}

class ParkingSlotModel {
  final String id;
  final bool isTop; // true: baris atas (A), false: baris bawah (B)
  final int index;  // 0 s/d 10
  SlotStatus status;
  final String plate;
  Color carColor;
  final Color windowColor;

  ParkingSlotModel({
    required this.id,
    required this.isTop,
    required this.index,
    required this.status,
    this.plate = '',
    this.carColor = const Color(0xFF1D4ED8),
    this.windowColor = const Color(0xFF0F172A),
  });

  double get left => 14.0 + index * 62.0;
  double get right => left + 54.0;
  double get centerX => left + 27.0;
}

class MineObstacle {
  final double x;
  final double y;
  final double radius;

  const MineObstacle({
    required this.x,
    required this.y,
    this.radius = 12.0,
  });
}

class RoundDefinition {
  final int roundNumber;
  final bool isBonus;
  final int bonusIndex; // 1 atau 2
  final String title;
  final int targetCars; // Jumlah mobil yang harus diparkir di ronde ini
  final int initialSeconds; // Waktu awal ronde (40 dtk atau khusus 10 dtk di bonus ronde)
  final List<String> targetSlotIds;
  final List<MineObstacle> mines;
  final String hint;

  const RoundDefinition({
    required this.roundNumber,
    this.isBonus = false,
    this.bonusIndex = 0,
    required this.title,
    required this.targetCars,
    this.initialSeconds = 40,
    required this.targetSlotIds,
    required this.mines,
    required this.hint,
  });
}

// ============================================================
// LAYAR UTAMA SIMULASI PARKIR DINAMIS DENGAN BONUS RONDE & SKOR 3X
// ============================================================
class CarGameScreen extends StatefulWidget {
  const CarGameScreen({super.key});

  @override
  State<CarGameScreen> createState() => _CarGameScreenState();
}

class _CarGameScreenState extends State<CarGameScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bonusIntroController;
  late Animation<double> _bonusIntroFadeAnimation;

  Timer? _gameLoopTimer;
  Timer? _clockTimer;

  bool _sensorsConnected = false;
  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;

  // Koordinat & Kecepatan Mobil Pemain
  double _playerX = 36.0;
  double _playerY = 160.0;
  double _vx = 0.0;
  double _vy = 0.0;
  double _carAngle = 0.0;

  // Nilai Sensor Kemiringan
  double _accelTiltX = 0.0;
  double _accelTiltY = 0.0;

  // Status Permainan, Ronde & Skor
  int _currentRound = 1;
  bool _isBonusRound = false;
  int _bonusRoundIndex = 0; // 1 = Bonus Ronde 1, 2 = Bonus Ronde 2
  bool _isShowingBonusIntro = false;
  int _carsParkedInRound = 0;
  int _secondsRemaining = 40;
  int _score = 0; // Selalu reset mulai dari 0 sesuai instruksi
  bool _isGameOver = false;
  bool _isRoundComplete = false;
  bool _startSoundPlayed = false;

  // Efek Ledakan & Notifikasi Toast
  bool _isExploding = false;
  Offset? _explosionPos;

  // Slot Aktif yang sedang dimasuki mobil
  ParkingSlotModel? _activeSlot;

  // Daftar Slot Baris Atas & Baris Bawah
  List<ParkingSlotModel> _topSlots = [];
  List<ParkingSlotModel> _bottomSlots = [];

  // Ranjau & Target Slot Dinamis Teracak per Sesi/Ronde (Tingkat Kesulitan Tetap Terjaga)
  List<MineObstacle> _activeMines = [];
  Set<String> _activeTargetSlotIds = {};

  // Palet Warna Mobil Pemain untuk Setiap Mobil yang Diparkir
  final List<Color> _carPalette = const [
    Color(0xFF06B6D4), // Cyan Sporty
    Color(0xFFF97316), // Neon Orange
    Color(0xFF10B981), // Emerald Green
    Color(0xFFEC4899), // Hot Magenta
    Color(0xFF8B5CF6), // Royal Purple
    Color(0xFFFBBF24), // Vibrant Gold
    Color(0xFF3B82F6), // Electric Blue
  ];

  // ============================================================
  // DEFINISI 10 RONDE UTAMA
  // ============================================================
  final List<RoundDefinition> _mainRounds = const [
    RoundDefinition(
      roundNumber: 1,
      title: 'Pemanasan Parkir',
      targetCars: 1,
      initialSeconds: 40,
      targetSlotIds: ['A-05'],
      mines: [],
      hint: 'Ronde 1: Parkirkan 1 mobil ke slot A-05. Jalanan bebas ranjau!',
    ),
    RoundDefinition(
      roundNumber: 2,
      title: 'Manuver 4 Mobil',
      targetCars: 4,
      initialSeconds: 40,
      targetSlotIds: ['A-03', 'A-08', 'B-04', 'B-07'],
      mines: [
        MineObstacle(x: 390, y: 160),
      ],
      hint: 'Ronde 2: Parkirkan 4 mobil ke slot hijau! Awas ada 1 ranjau di tengah jalan!',
    ),
    RoundDefinition(
      roundNumber: 3,
      title: 'Target Saling Berjauhan',
      targetCars: 3,
      initialSeconds: 40,
      targetSlotIds: ['A-01', 'B-10', 'A-10'],
      mines: [
        MineObstacle(x: 230, y: 140),
        MineObstacle(x: 480, y: 180),
      ],
      hint: 'Ronde 3: Posisi 3 slot berjauhan di ujung kiri & kanan! Waspadai 2 ranjau!',
    ),
    RoundDefinition(
      roundNumber: 4,
      title: 'Jalur Berkelok Zig-Zag',
      targetCars: 4,
      initialSeconds: 40,
      targetSlotIds: ['A-04', 'A-07', 'B-03', 'B-08'],
      mines: [
        MineObstacle(x: 200, y: 180),
        MineObstacle(x: 340, y: 140),
        MineObstacle(x: 480, y: 180),
      ],
      hint: 'Ronde 4: 3 ranjau membentuk rintangan slalom! Parkirkan 4 mobil.',
    ),
    RoundDefinition(
      roundNumber: 5,
      title: 'Pendekatan Sempit',
      targetCars: 4,
      initialSeconds: 40,
      targetSlotIds: ['A-02', 'A-09', 'B-05', 'B-09'],
      mines: [
        MineObstacle(x: 180, y: 130),
        MineObstacle(x: 310, y: 190),
        MineObstacle(x: 440, y: 130),
        MineObstacle(x: 570, y: 188),
      ],
      hint: 'Ronde 5: 4 ranjau mulai mendekati bibir slot parkir! Atur kecepatan.',
    ),
    RoundDefinition(
      roundNumber: 6,
      title: 'Zona Ranjau Beruntun',
      targetCars: 5,
      initialSeconds: 40,
      targetSlotIds: ['A-03', 'A-06', 'A-10', 'B-02', 'B-07'],
      mines: [
        MineObstacle(x: 170, y: 145),
        MineObstacle(x: 275, y: 185),
        MineObstacle(x: 385, y: 135),
        MineObstacle(x: 495, y: 185),
        MineObstacle(x: 605, y: 145),
      ],
      hint: 'Ronde 6: 5 ranjau menjaga koridor jalan. Parkirkan 5 armada mobil!',
    ),
    RoundDefinition(
      roundNumber: 7,
      title: 'Manuver Sempit Masuk Slot',
      targetCars: 5,
      initialSeconds: 40,
      targetSlotIds: ['A-01', 'A-05', 'A-08', 'B-04', 'B-09'],
      mines: [
        MineObstacle(x: 160, y: 122),
        MineObstacle(x: 240, y: 200),
        MineObstacle(x: 330, y: 122),
        MineObstacle(x: 420, y: 200),
        MineObstacle(x: 510, y: 122),
        MineObstacle(x: 600, y: 170),
      ],
      hint: 'Ronde 7: 6 ranjau dekat pintu masuk! Belok tegak lurus saat masuk slot.',
    ),
    RoundDefinition(
      roundNumber: 8,
      title: 'Taktik Presisi Ekstrem',
      targetCars: 5,
      initialSeconds: 40,
      targetSlotIds: ['A-02', 'A-07', 'A-11', 'B-03', 'B-06'],
      mines: [
        MineObstacle(x: 160, y: 200),
        MineObstacle(x: 230, y: 122),
        MineObstacle(x: 305, y: 160),
        MineObstacle(x: 380, y: 122),
        MineObstacle(x: 455, y: 200),
        MineObstacle(x: 530, y: 122),
        MineObstacle(x: 610, y: 200),
      ],
      hint: 'Ronde 8: 7 ranjau menjebak area parkir! Dapatkan bonus +10 detik per mobil.',
    ),
    RoundDefinition(
      roundNumber: 9,
      title: 'Ladang Ranjau Ahli',
      targetCars: 6,
      initialSeconds: 40,
      targetSlotIds: ['A-03', 'A-05', 'A-09', 'B-02', 'B-05', 'B-08'],
      mines: [
        MineObstacle(x: 155, y: 122),
        MineObstacle(x: 220, y: 200),
        MineObstacle(x: 285, y: 122),
        MineObstacle(x: 350, y: 200),
        MineObstacle(x: 415, y: 122),
        MineObstacle(x: 480, y: 200),
        MineObstacle(x: 545, y: 122),
        MineObstacle(x: 620, y: 165),
      ],
      hint: 'Ronde 9: 8 ranjau aktif! Butuh ketenangan mengemudi tingkat tinggi.',
    ),
    RoundDefinition(
      roundNumber: 10,
      title: 'Master Parkir - Grand Finale',
      targetCars: 6,
      initialSeconds: 40,
      targetSlotIds: ['A-01', 'A-04', 'A-07', 'A-10', 'B-04', 'B-07'],
      mines: [
        MineObstacle(x: 150, y: 122),
        MineObstacle(x: 210, y: 200),
        MineObstacle(x: 270, y: 122),
        MineObstacle(x: 330, y: 200),
        MineObstacle(x: 390, y: 122),
        MineObstacle(x: 450, y: 200),
        MineObstacle(x: 510, y: 122),
        MineObstacle(x: 570, y: 200),
        MineObstacle(x: 640, y: 160),
      ],
      hint: 'Ronde 10: 9 ranjau! Buktikan keahlian Anda dan jadilah Master Parkir sejati!',
    ),
  ];

  // ============================================================
  // DEFINISI BONUS RONDE (DI ANTARA RONDE 4 & 9, TIDAK MASUK 10 ASLI)
  // Waktu khusus 10 detik, 6 mobil, bom lebih banyak, skor 3x lipat (4500)
  // ============================================================
  final RoundDefinition _bonusRound1Def = const RoundDefinition(
    roundNumber: 4,
    isBonus: true,
    bonusIndex: 1,
    title: 'Bonus Ronde 1: Rush Hour 10 Detik',
    targetCars: 6,
    initialSeconds: 10, // Khusus 10 detik saja
    targetSlotIds: ['A-02', 'A-05', 'A-09', 'B-03', 'B-06', 'B-10'],
    mines: [
      MineObstacle(x: 160, y: 130),
      MineObstacle(x: 210, y: 190),
      MineObstacle(x: 270, y: 130),
      MineObstacle(x: 325, y: 190),
      MineObstacle(x: 385, y: 130),
      MineObstacle(x: 440, y: 190),
      MineObstacle(x: 495, y: 130),
      MineObstacle(x: 550, y: 190),
      MineObstacle(x: 605, y: 130),
      MineObstacle(x: 655, y: 180),
    ],
    hint: '⚡ BONUS 3X RONDE 1: Waktu 10 detik! 6 mobil! Skor 4500 pts per mobil! ⚡',
  );

  final RoundDefinition _bonusRound2Def = const RoundDefinition(
    roundNumber: 8,
    isBonus: true,
    bonusIndex: 2,
    title: 'Bonus Ronde 2: Inferno Slalom 10 Detik',
    targetCars: 6,
    initialSeconds: 10, // Khusus 10 detik saja
    targetSlotIds: ['A-01', 'A-04', 'A-08', 'B-02', 'B-07', 'B-11'],
    mines: [
      MineObstacle(x: 155, y: 185),
      MineObstacle(x: 205, y: 125),
      MineObstacle(x: 255, y: 160),
      MineObstacle(x: 305, y: 195),
      MineObstacle(x: 355, y: 125),
      MineObstacle(x: 405, y: 165),
      MineObstacle(x: 455, y: 195),
      MineObstacle(x: 505, y: 125),
      MineObstacle(x: 555, y: 165),
      MineObstacle(x: 605, y: 195),
      MineObstacle(x: 645, y: 130),
      MineObstacle(x: 685, y: 165),
    ],
    hint: '🔥 BONUS 3X RONDE 2: Waktu 10 detik! 12 ranjau padat! Skor 4500 pts! 🔥',
  );

  RoundDefinition get _currentRoundDef {
    if (_isBonusRound) {
      return _bonusRoundIndex == 1 ? _bonusRound1Def : _bonusRound2Def;
    }
    return _mainRounds[(_currentRound - 1).clamp(0, _mainRounds.length - 1)];
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Controller untuk Transisi Masuk Ronde Bonus (Layar hitam & teks Bonus 3x memudar)
    _bonusIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _bonusIntroFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _bonusIntroController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
      ),
    );

    _bonusIntroController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isShowingBonusIntro = false;
          });
        }
      }
    });

    _initRound();

    bool accelReady = false;
    bool gyroReady = false;

    _accelSub = accelerometerEventStream().listen((event) {
      if (!accelReady) {
        accelReady = true;
        if (gyroReady && mounted) {
          _startTheGame();
        }
      }
      _accelTiltX = event.y * 0.9;
      _accelTiltY = event.x * 0.9;
    });

    _gyroSub = gyroscopeEventStream().listen((event) {
      if (!gyroReady) {
        gyroReady = true;
        if (accelReady && mounted) {
          _startTheGame();
        }
      }
      _accelTiltX += event.y * 0.35;
      _accelTiltY -= event.x * 0.35;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_sensorsConnected) {
        _startTheGame();
      }
    });

    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted && _sensorsConnected) {
        _updatePhysics();
      }
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Countdown hanya berjalan saat permainan aktif dan tidak sedang menampilkan intro transisi
      if (mounted &&
          _secondsRemaining > 0 &&
          !_isRoundComplete &&
          !_isGameOver &&
          !_isShowingBonusIntro) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 0) {
          _handleGameOver(isMine: false);
        }
      }
    });
  }


  Future<void> _saveHighScoreIfBest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentBest = prefs.getInt('parking_high_score') ?? 0;
      if (_score > currentBest) {
        await prefs.setInt('parking_high_score', _score);
      }
      if (_score > 0) {
        final currentPoints = prefs.getInt('user_arcade_points') ?? 25000;
        await prefs.setInt('user_arcade_points', currentPoints + _score);
      }
    } catch (e) {
      debugPrint('[CarGame] Error saving high score: $e');
    }
  }

  void _startTheGame() {
    if (!mounted) return;
    setState(() => _sensorsConnected = true);
    if (!_startSoundPlayed) {
      _startSoundPlayed = true;
      SoundService.playStartSound();
    }
  }

  void _playBonusIntro() {
    setState(() {
      _isShowingBonusIntro = true;
    });
    _bonusIntroController.reset();
    _bonusIntroController.forward();
    SoundService.playStartSound(isBonus: true);
    HapticFeedback.heavyImpact();
  }

  void _initRound() {
    final def = _currentRoundDef;
    final random = math.Random();

    // 1. RANDOMISASI TARGET SLOTS (JUMLAH TARGET TETAP KONSISTEN SESUAI LEVEL KESULITAN)
    final List<String> allSlotIds = [
      ...List.generate(11, (i) => 'A-${(i + 1).toString().padLeft(2, '0')}'),
      ...List.generate(11, (i) => 'B-${(i + 1).toString().padLeft(2, '0')}'),
    ]..shuffle(random);

    if (def.targetCars == 1) {
      final middleSlots = allSlotIds.where((id) {
        final idx = int.tryParse(id.substring(2)) ?? 1;
        return idx >= 2 && idx <= 10;
      }).toList();
      _activeTargetSlotIds = {
        middleSlots.isNotEmpty ? middleSlots[random.nextInt(middleSlots.length)] : allSlotIds.first
      };
    } else {
      _activeTargetSlotIds = allSlotIds.take(def.targetCars).toSet();
    }

    final plates = [
      'B 2341 S', 'B 9871 Z', 'B 4410 TX', 'D 1902 AB', 'B 7721 KK',
      'L 1234 XY', 'AB 8899 CD', 'B 5500 ZZ', 'D 1102 AB', 'B 8832 KLP',
      'AB 4921 YY', 'B 1945 ID', 'AD 3341 GH', 'B 9012 QQ', 'N 6677 KL',
      'B 4422 WE', 'DK 8181 JK', 'B 3030 TY', 'H 9988 AA', 'BK 5432 ZY'
    ]..shuffle(random);

    final colors = [
      const Color(0xFFE2E8F0), const Color(0xFF1D4ED8), const Color(0xFF065F46),
      const Color(0xFFDC2626), const Color(0xFF6366F1), const Color(0xFF0284C7),
      const Color(0xFFD97706), const Color(0xFF475569), const Color(0xFFF59E0B),
      const Color(0xFF9333EA), const Color(0xFFE11D48), const Color(0xFF0D9488)
    ]..shuffle(random);

    _topSlots = List.generate(11, (i) {
      final id = 'A-${(i + 1).toString().padLeft(2, '0')}';
      final isTarget = _activeTargetSlotIds.contains(id);
      SlotStatus status;
      if (isTarget) {
        status = SlotStatus.target;
      } else if (random.nextInt(3) == 0) {
        status = SlotStatus.reserved;
      } else {
        status = SlotStatus.occupied;
      }

      return ParkingSlotModel(
        id: id,
        isTop: true,
        index: i,
        status: status,
        plate: plates[i % plates.length],
        carColor: colors[i % colors.length],
        windowColor: const Color(0xFF0F172A),
      );
    });

    _bottomSlots = List.generate(11, (i) {
      final id = 'B-${(i + 1).toString().padLeft(2, '0')}';
      final isTarget = _activeTargetSlotIds.contains(id);
      SlotStatus status;
      if (isTarget) {
        status = SlotStatus.target;
      } else if (random.nextInt(3) == 0) {
        status = SlotStatus.reserved;
      } else {
        status = SlotStatus.occupied;
      }

      return ParkingSlotModel(
        id: id,
        isTop: false,
        index: i,
        status: status,
        plate: plates[(i + 11) % plates.length],
        carColor: colors[(i + 6) % colors.length],
        windowColor: const Color(0xFF0F172A),
      );
    });

    // 2. RANDOMISASI POSISI RANJAU (JUMLAH RANJAU PERSIS SESUAI TINGKAT KESULITAN LEVEL)
    final int requiredMines = def.mines.length;
    _activeMines = [];

    if (requiredMines > 0) {
      final targetCentersTop = _topSlots.where((s) => s.status == SlotStatus.target).map((s) => s.centerX).toList();
      final targetCentersBottom = _bottomSlots.where((s) => s.status == SlotStatus.target).map((s) => s.centerX).toList();

      int attempts = 0;
      while (_activeMines.length < requiredMines && attempts < 1500) {
        attempts++;
        // Area jalur jalan (X: 130 s/d 680, Y: 122 s/d 252)
        final double mx = 130.0 + random.nextDouble() * 550.0;
        final double my = 122.0 + random.nextDouble() * 130.0;

        // Jauhkan dari titik spawn pemain di X=36, Y=160
        final double dSpawn = math.sqrt((mx - 36.0) * (mx - 36.0) + (my - 160.0) * (my - 160.0));
        if (dSpawn < 95.0) continue;

        // Jauhkan dari mulut slot target baris atas agar mobil bisa masuk
        if (my < 135.0 && targetCentersTop.any((cx) => (mx - cx).abs() < 28.0)) continue;

        // Jauhkan dari mulut slot target baris bawah agar mobil bisa masuk
        if (my > 240.0 && targetCentersBottom.any((cx) => (mx - cx).abs() < 28.0)) continue;

        // Jaga jarak antar ranjau minimal 52px agar selalu ada celah slalom
        bool tooClose = false;
        for (final m in _activeMines) {
          final double d = math.sqrt((mx - m.x) * (mx - m.x) + (my - m.y) * (my - m.y));
          if (d < 52.0) {
            tooClose = true;
            break;
          }
        }
        if (tooClose) continue;

        _activeMines.add(MineObstacle(
          x: double.parse(mx.toStringAsFixed(1)),
          y: double.parse(my.toStringAsFixed(1)),
        ));
      }

      // Cadangan fallback jika batas jarak sangat padat
      if (_activeMines.length < requiredMines) {
        for (final fallbackMine in def.mines) {
          if (_activeMines.length >= requiredMines) break;
          _activeMines.add(fallbackMine);
        }
      }
    }

    _carsParkedInRound = 0;
    _secondsRemaining = def.initialSeconds; // 40 detik normal, 10 detik khusus bonus ronde
    _activeSlot = null;
    _isGameOver = false;
    _isRoundComplete = false;
    _isExploding = false;

    _playerX = 36.0;
    _playerY = 160.0;
    _vx = 0.0;
    _vy = 0.0;
    _carAngle = 0.0;
  }

  @override
  void dispose() {
    _saveHighScoreIfBest();
    SoundService.stopAllSounds();
    _gameLoopTimer?.cancel();
    _clockTimer?.cancel();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _pulseController.dispose();
    _bonusIntroController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  // ============================================================
  // LOGIKA FISIKA, COLLISION DETECTION & PARKIR
  // ============================================================
  void _updatePhysics() {
    // Fisika dijeda jika sedang menampilkan intro transisi ronde bonus
    if (_isRoundComplete || _isGameOver || _isExploding || _isShowingBonusIntro) return;

    _vx += _accelTiltX * 0.28;
    _vy += _accelTiltY * 0.28;

    _vx *= 0.88;
    _vy *= 0.88;

    _vx = _vx.clamp(-4.0, 4.0);
    _vy = _vy.clamp(-4.0, 4.0);

    final double speed = math.sqrt(_vx * _vx + _vy * _vy);
    if (speed > 0.20) {
      final double targetAngle = math.atan2(_vy, _vx);
      double diff = targetAngle - _carAngle;
      while (diff > math.pi) {
        diff -= 2 * math.pi;
      }
      while (diff < -math.pi) {
        diff += 2 * math.pi;
      }
      _carAngle += diff * 0.22;
    }

    double nextX = _playerX + _vx;
    double nextY = _playerY + _vy;

    final mediaQuery = MediaQuery.of(context);
    final double screenH = mediaQuery.size.height > 200 ? mediaQuery.size.height : 390.0;
    final double screenW = mediaQuery.size.width > 200 ? mediaQuery.size.width : 840.0;

    final double topSlotBottomY = 94.0;
    final double topSlotTopY = 14.0;
    final double bottomSlotTopY = screenH - 94.0;
    final double bottomSlotBottomY = screenH - 14.0;

    final double nextCenterX = nextX + 23.0;
    final double nextCenterY = nextY + 14.0;

    // 1. DETEKSI TABRAKAN DENGAN RANJAU (MINE COLLISION)
    for (final mine in _activeMines) {
      final double dx = nextCenterX - mine.x;
      final double dy = nextCenterY - mine.y;
      final double dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 20.0) {
        _triggerExplosion(mine.x, mine.y);
        _handleGameOver(isMine: true);
        return;
      }
    }

    // 2. DETEKSI & MASUK KE SLOT BARIS ATAS (A)
    if (_activeSlot != null && _activeSlot!.isTop) {
      final double clampedCenterX = nextCenterX.clamp(_activeSlot!.left + 12.0, _activeSlot!.right - 12.0);
      nextX = clampedCenterX - 23.0;
      nextY = nextY.clamp(topSlotTopY, topSlotBottomY + 25.0);

      double alignDiff = (-math.pi / 2) - _carAngle;
      while (alignDiff > math.pi) {
        alignDiff -= 2 * math.pi;
      }
      while (alignDiff < -math.pi) {
        alignDiff += 2 * math.pi;
      }
      _carAngle += alignDiff * 0.16;

      if (nextY >= topSlotBottomY + 8.0) {
        _activeSlot = null;
      }

      if (nextY <= 36.0) {
        _onCarParkedSuccess(_activeSlot!);
        return;
      }
    } else if (nextY < topSlotBottomY) {
      ParkingSlotModel? targetCandidate;
      for (final s in _topSlots) {
        if (s.status == SlotStatus.target &&
            nextCenterX >= (s.left + 4.0) &&
            nextCenterX <= (s.right - 4.0)) {
          targetCandidate = s;
          break;
        }
      }

      if (targetCandidate != null) {
        _activeSlot = targetCandidate;
        final double clampedCenterX = nextCenterX.clamp(targetCandidate.left + 12.0, targetCandidate.right - 12.0);
        nextX = clampedCenterX - 23.0;
      } else {
        nextY = topSlotBottomY;
        _vy = 0;
      }
    }

    // 3. DETEKSI & MASUK KE SLOT BARIS BAWAH (B)
    if (_activeSlot != null && !_activeSlot!.isTop) {
      final double clampedCenterX = nextCenterX.clamp(_activeSlot!.left + 12.0, _activeSlot!.right - 12.0);
      nextX = clampedCenterX - 23.0;
      nextY = nextY.clamp(bottomSlotTopY - 25.0, bottomSlotBottomY - 28.0);

      double alignDiff = (math.pi / 2) - _carAngle;
      while (alignDiff > math.pi) {
        alignDiff -= 2 * math.pi;
      }
      while (alignDiff < -math.pi) {
        alignDiff += 2 * math.pi;
      }
      _carAngle += alignDiff * 0.16;

      if (nextY + 28.0 <= bottomSlotTopY - 8.0) {
        _activeSlot = null;
      }

      if (nextY + 28.0 >= bottomSlotBottomY - 14.0) {
        _onCarParkedSuccess(_activeSlot!);
        return;
      }
    } else if (nextY + 28.0 > bottomSlotTopY) {
      ParkingSlotModel? targetCandidate;
      for (final s in _bottomSlots) {
        if (s.status == SlotStatus.target &&
            nextCenterX >= (s.left + 4.0) &&
            nextCenterX <= (s.right - 4.0)) {
          targetCandidate = s;
          break;
        }
      }

      if (targetCandidate != null) {
        _activeSlot = targetCandidate;
        final double clampedCenterX = nextCenterX.clamp(targetCandidate.left + 12.0, targetCandidate.right - 12.0);
        nextX = clampedCenterX - 23.0;
      } else {
        nextY = bottomSlotTopY - 28.0;
        _vy = 0;
      }
    }

    nextX = nextX.clamp(8.0, screenW - 46.0 - 8.0);
    nextY = nextY.clamp(topSlotTopY, screenH - 28.0 - 8.0);

    setState(() {
      _playerX = nextX;
      _playerY = nextY;
    });
  }

  // ============================================================
  // LOGIKA BERHASIL PARKIR 1 MOBIL
  // Di Ronde Bonus: Skor naik 3x lipat (4500 poin) & TIDAK ADA PENAMBAHAN WAKTU
  // ============================================================
  void _onCarParkedSuccess(ParkingSlotModel slot) {
    if (_isRoundComplete || _isGameOver) return;

    final int scoreEarned = _isBonusRound ? (1500 * 3) : 1500; // 3x lipat di bonus ronde

    setState(() {
      slot.status = SlotStatus.parked;
      slot.carColor = _carPalette[_carsParkedInRound % _carPalette.length];
      _carsParkedInRound++;
      _score += scoreEarned;

      // HANYA ronde biasa yang menambah waktu +10 detik.
      // Sesuai instruksi: "tidak ada penambahan waktu per mobil disini" pada ronde bonus!
      if (!_isBonusRound) {
        _secondsRemaining += 10;
      }

      _activeSlot = null;
    });

    HapticFeedback.heavyImpact();

    _saveHighScoreIfBest();

    if (_carsParkedInRound < _currentRoundDef.targetCars) {
      setState(() {
        _playerX = 36.0;
        _playerY = 160.0;
        _vx = 0.0;
        _vy = 0.0;
        _carAngle = 0.0;
      });
    } else {
      _isRoundComplete = true;
      SoundService.stopInGameSound();
      _showRoundClearDialog();
    }
  }

  void _triggerExplosion(double x, double y) {
    setState(() {
      _isExploding = true;
      _explosionPos = Offset(x, y);
    });
    HapticFeedback.vibrate();
  }

  // ============================================================
  // PENANGANAN GAME OVER (SISA TOMBOL MERAH SAJA, FULL WIDTH, RESET KE RONDE 1)
  // ============================================================
  void _handleGameOver({required bool isMine}) {
    if (_isGameOver || _isRoundComplete) return;

    // Jika kalah di Ronde Bonus (gagal masukin mobil/waktu habis/kena ranjau),
    // jangan kalah (game over), tapi kembali ke ronde normal lanjutan sebelum masuk bonus!
    if (_isBonusRound) {
      _handleBonusFailed(isMine: isMine);
      return;
    }

    _isGameOver = true;
    _vx = 0;
    _vy = 0;

    SoundService.playGameOverSound();
    _saveHighScoreIfBest();
    _showGameOverDialog(isMine: isMine);
  }

  void _handleBonusFailed({required bool isMine}) {
    _isGameOver = true;
    _vx = 0;
    _vy = 0;

    SoundService.stopInGameSound();
    SoundService.playGameOverSound();
    _saveHighScoreIfBest();

    final int targetRound = _bonusRoundIndex == 1 ? 5 : 9;
    _showBonusFailedDialog(isMine: isMine, targetRound: targetRound);
  }

  void _continueFromBonusToNormal(int targetRound) {
    setState(() {
      _isGameOver = false;
      _isBonusRound = false;
      _bonusRoundIndex = 0;
      _isShowingBonusIntro = false;
      _currentRound = targetRound;
      _initRound();
    });
    SoundService.playStartSound(isBonus: false);
  }

  void _showBonusFailedDialog({required bool isMine, required int targetRound}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 340,
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFCD34D), width: 2),
                  ),
                  child: isMine
                      ? Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset('assets/images/bomb.png', fit: BoxFit.contain),
                        )
                      : const Icon(Icons.timer_off_rounded, color: Color(0xFFFCD34D), size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  isMine ? 'MOBIL MELEDAK!' : 'WAKTU BONUS HABIS!',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tantangan bonus berakhir. Skor Anda tetap tersimpan (+${_carsParkedInRound * 4500} pts)! Melanjutkan ke Ronde $targetRound normal.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5, height: 1.3),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('RONDE', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text('BONUS $_bonusRoundIndex',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                        ],
                      ),
                      Container(width: 1, height: 22, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          Text('MOBIL SELESAI', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text('$_carsParkedInRound / ${_currentRoundDef.targetCars}',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                        ],
                      ),
                      Container(width: 1, height: 22, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          Text('TOTAL SKOR', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text('$_score pts',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _continueFromBonusToNormal(targetRound);
                    },
                    child: Text(
                      'Lanjut ke Ronde $targetRound',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  void _showGameOverDialog({required bool isMine}) {
    _saveHighScoreIfBest();
    final String currentRoundText = _isBonusRound
        ? 'BONUS $_bonusRoundIndex'
        : '$_currentRound / 10';

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
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 340,
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF87171), width: 2),
                  ),
                  child: isMine
                      ? Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset('assets/images/bomb.png', fit: BoxFit.contain),
                        )
                      : const Icon(Icons.timer_off_rounded, color: Color(0xFFF87171), size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  isMine ? 'MOBIL MELEDAK!' : 'WAKTU HABIS!',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  isMine
                      ? 'Mobil Anda menginjak ranjau darat di jalanan! Permainan berakhir.'
                      : 'Waktu parkir Anda telah habis sebelum seluruh target mobil terparkir.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5, height: 1.3),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('RONDE', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text(currentRoundText,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      Container(width: 1, height: 22, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          Text('MOBIL SELESAI', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text('$_carsParkedInRound / ${_currentRoundDef.targetCars}',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                        ],
                      ),
                      Container(width: 1, height: 22, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          Text('TOTAL SKOR', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text('$_score pts',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _restartFromRound1();
                    },
                    child: Text(
                      'Coba Lagi',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  // ============================================================
  // DIALOG SELESAI RONDE (ROUND CLEAR)
  // Tombol hijau tanpa panah, tombol lanjut dan kembali selebar container atas
  // ============================================================
  void _showRoundClearDialog() {
    final bool isGrandFinale = (!_isBonusRound && _currentRound >= 10);

    String nextButtonText;
    if (isGrandFinale) {
      nextButtonText = 'Main Ulang dari Ronde 1';
    } else if (!_isBonusRound && _currentRound == 4) {
      nextButtonText = 'Lanjut ke Bonus';
    } else if (!_isBonusRound && _currentRound == 8) {
      nextButtonText = 'Lanjut ke Bonus';
    } else if (_isBonusRound) {
      nextButtonText = 'Lanjut ke Ronde ${_bonusRoundIndex == 1 ? 5 : 9}';
    } else {
      nextButtonText = 'Lanjut ke Ronde ${_currentRound + 1}';
    }

    String clearTitle;
    String clearDesc;
    if (isGrandFinale) {
      clearTitle = 'SELAMAT! MASTER PARKIR!';
      clearDesc = 'Luar biasa! Anda berhasil menaklukkan seluruh 10 Ronde dan 2 Bonus Ronde!';
    } else if (_isBonusRound) {
      clearTitle = 'BONUS RONDE $_bonusRoundIndex SELESAI!';
      clearDesc = 'Hebat sekali! 6 mobil dalam waktu cepat berhasil diparkir dengan skor 3x lipat!';
    } else {
      clearTitle = 'RONDE $_currentRound SELESAI!';
      clearDesc = 'Semua ${_currentRoundDef.targetCars} mobil pada Ronde $_currentRound sukses terparkir!';
    }

    _saveHighScoreIfBest();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isGrandFinale ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 340,
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isGrandFinale ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isGrandFinale ? const Color(0xFFFCD34D) : const Color(0xFF34D399),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isGrandFinale ? Icons.emoji_events_rounded : Icons.check_circle_rounded,
                    color: isGrandFinale ? const Color(0xFFFCD34D) : const Color(0xFF34D399),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  clearTitle,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  clearDesc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11.5, height: 1.3),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('SISA WAKTU', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text('$_secondsRemaining dtk',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
                        ],
                      ),
                      Container(width: 1, height: 22, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          Text('TOTAL SKOR', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                          Text('$_score pts',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGrandFinale ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (isGrandFinale) {
                        _restartFromRound1();
                      } else {
                        _advanceToNextRound();
                      }
                    },
                    child: Text(
                      nextButtonText,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  void _advanceToNextRound() {
    setState(() {
      if (!_isBonusRound) {
        if (_currentRound == 4) {
          _isBonusRound = true;
          _bonusRoundIndex = 1;
        } else if (_currentRound == 8) {
          _isBonusRound = true;
          _bonusRoundIndex = 2;
        } else {
          _currentRound++;
        }
      } else {
        if (_bonusRoundIndex == 1) {
          _isBonusRound = false;
          _bonusRoundIndex = 0;
          _currentRound = 5;
        } else if (_bonusRoundIndex == 2) {
          _isBonusRound = false;
          _bonusRoundIndex = 0;
          _currentRound = 9;
        }
      }
      _initRound();
    });

    // Jika masuk ronde bonus, tampilkan efek layar hitam + teks Rock Bonus 3x yang memudar
    if (_isBonusRound) {
      _playBonusIntro();
    } else {
      SoundService.playStartSound();
    }
  }

  void _restartFromRound1() {
    setState(() {
      _currentRound = 1;
      _isBonusRound = false;
      _bonusRoundIndex = 0;
      _isShowingBonusIntro = false;
      _score = 0; // Reset ke 0 saat coba lagi mulai dari ronde 1
      _initRound();
    });
    SoundService.playStartSound();
  }

  Future<bool> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 24),
            const SizedBox(width: 10),
            Text('Keluar Permainan?',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari tantangan parkir arcade ini?',
          style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Yakin Keluar',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  // ============================================================
  // TAMPILAN WIDGET (UI)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    if (!_sensorsConnected) {
      return Theme(
        data: AppTheme.light,
        child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF34D399)),
              const SizedBox(height: 24),
              Text('Menghubungkan Sensor Kendaraan...',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Pastikan Gyroscope & Accelerometer aktif.',
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF475569)),
                  ),
                  child: Text('Batal',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ));
    }

    return Theme(
      data: AppTheme.light,
      child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog();
        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF131922),
        body: GestureDetector(
          onPanUpdate: (details) {
            if (_isShowingBonusIntro) return;
            setState(() {
              _playerX += details.delta.dx;
              _playerY += details.delta.dy;
              if (details.delta.distance > 0.5) {
                _carAngle = math.atan2(details.delta.dy, details.delta.dx);
              }
            });
          },
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. JALAN RAYA ASPAL UTAMA
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F252E),
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Color(0xFFFBBF24),
                          width: 3.0,
                        ),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final dashCount = (constraints.maxWidth / 36).floor();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            dashCount > 0 ? dashCount : 24,
                            (index) => Container(
                              width: 20,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 2. BARIS PARKIR ATAS (A-01 s/d A-11)
                Positioned(
                  top: 8,
                  left: 14,
                  right: 94,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: _topSlots.map((slot) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildSlotWidget(slot),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // 3. BARIS PARKIR BAWAH (B-01 s/d B-11)
                Positioned(
                  bottom: 8,
                  left: 14,
                  right: 14,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: _bottomSlots.map((slot) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildSlotWidget(slot),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // 4. RINTANGAN RANJAU DARAT (MINES)
                for (final mine in _activeMines)
                  Positioned(
                    left: mine.x - 14,
                    top: mine.y - 14,
                    child: _buildMineWidget(mine),
                  ),

                // 5. MOBIL PEMAIN
                if (!_isExploding)
                  Positioned(
                    left: _playerX,
                    top: _playerY,
                    child: _buildPlayerCar(),
                  ),

                // 6. EFEK VISUAL LEDAKAN
                if (_isExploding && _explosionPos != null)
                  Positioned(
                    left: _explosionPos!.dx - 32,
                    top: _explosionPos!.dy - 32,
                    child: _buildExplosionEffect(),
                  ),

                // 7. OVERLAY BERKEDIP MERAH TRANSPARAN KHUSUS BONUS RONDE
                if (_isBonusRound)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final double alpha = 0.08 + (0.07 * _pulseController.value);
                          final double borderAlpha = 0.35 + (0.35 * _pulseController.value);
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: alpha),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withValues(alpha: borderAlpha),
                                width: 3.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // 8. KAPSUL HUD DI POJOK KANAN ATAS
                Positioned(
                  top: 8,
                  right: 10,
                  child: _buildHudTower(),
                ),

                // 9. BANNER TOAST PETUNJUK RONDE (DINONAKTIFKAN SESUAI INSTRUKSI)

                // 10. EFEK TRANSISI MASUK BONUS RONDE (LAYAR HITAM + TEKS ROCK BONUS 3X MEMUDAR)
                if (_isShowingBonusIntro)
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _bonusIntroFadeAnimation,
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.local_fire_department, color: Color(0xFFF87171), size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SPECIAL BONUS STAGE',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFFFCA5A5),
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Tulisan BONUS 3X dengan GoogleFonts.rockSalt bergaya Rock & Api
                              Text(
                                'Bonus 3x',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.rockSalt(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFBBF24),
                                  letterSpacing: 2.0,
                                  shadows: const [
                                    Shadow(color: Color(0xFFEF4444), blurRadius: 28, offset: Offset(0, 0)),
                                    Shadow(color: Color(0xFFDC2626), blurRadius: 14, offset: Offset(2, 3)),
                                    Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF475569)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.flash_on, color: Color(0xFFFBBF24), size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      '+4500 PTS PER MOBIL  •  WAKTU HANYA 10 DETIK (NO +TIME)',
                                      style: GoogleFonts.inter(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildPlayerCar() {
    final Color currentCarColor = _carPalette[_carsParkedInRound % _carPalette.length];

    return Transform.rotate(
      angle: _carAngle,
      child: Container(
        width: 46,
        height: 28,
        decoration: BoxDecoration(
          color: currentCarColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: currentCarColor.withValues(alpha: 0.6),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 2, height: 4, color: const Color(0xFFEF4444)),
                Container(width: 2, height: 4, color: const Color(0xFFEF4444)),
              ],
            ),
            Container(
              width: 6,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF083344),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            Text('YOU',
                style: GoogleFonts.inter(fontSize: 5.0, fontWeight: FontWeight.w900, color: Colors.white)),
            Container(
              width: 8,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF083344),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 2, height: 4, color: const Color(0xFFFDE047)),
                Container(width: 2, height: 4, color: const Color(0xFFFDE047)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMineWidget(MineObstacle mine) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32 + (4 * _pulseController.value),
              height: 32 + (4 * _pulseController.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withValues(alpha: 0.2 + (0.2 * _pulseController.value)),
                border: Border.all(
                  color: const Color(0xFFF87171).withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
            ),
            Image.asset(
              'assets/images/bomb.png',
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            Positioned(
              top: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pulseController.value > 0.5 ? const Color(0xFFEF4444) : const Color(0xFFFDE047),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFEF4444), blurRadius: 4, spreadRadius: 1),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExplosionEffect() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFEF4444).withValues(alpha: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0xFFF59E0B), blurRadius: 20, spreadRadius: 6),
          BoxShadow(color: Color(0xFFEF4444), blurRadius: 35, spreadRadius: 12),
        ],
      ),
      child: const Center(
        child: Icon(Icons.flash_on_rounded, color: Color(0xFFFDE047), size: 40),
      ),
    );
  }



  Widget _buildHudTower() {
    final String roundBadgeText = _isBonusRound ? 'BONUS $_bonusRoundIndex' : 'R$_currentRound/10';

    return Container(
      width: 82,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isBonusRound ? const Color(0xFFEF4444) : const Color(0xFF334155),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                roundBadgeText,
                style: GoogleFonts.inter(
                  fontSize: _isBonusRound ? 7.0 : 8.0,
                  fontWeight: FontWeight.bold,
                  color: _isBonusRound ? const Color(0xFFF87171) : const Color(0xFF38BDF8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('$_carsParkedInRound/${_currentRoundDef.targetCars}',
                    style: GoogleFonts.inter(
                        fontSize: 7.5, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
              ),
            ],
          ),
          Container(width: 68, height: 1, color: const Color(0xFF334155)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: Color(0xFFFBBF24), size: 10),
              const SizedBox(width: 2),
              Text('00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                      fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
              // HANYA tampilkan tag +10s jika BUKAN ronde bonus!
              if (!_isBonusRound) ...[
                const SizedBox(width: 2),
                Text('+10s',
                    style: GoogleFonts.inter(
                        fontSize: 6.5, fontWeight: FontWeight.w900, color: const Color(0xFF34D399))),
              ],
            ],
          ),
          Container(width: 68, height: 1, color: const Color(0xFF334155)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFF34D399), size: 10),
              const SizedBox(width: 2),
              Text('$_score',
                  style: GoogleFonts.inter(
                      fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlotWidget(ParkingSlotModel slot) {
    switch (slot.status) {
      case SlotStatus.target:
        return _buildTargetSlot(slot);
      case SlotStatus.parked:
        return _buildParkedSlot(slot);
      case SlotStatus.reserved:
        return _buildReservedSlot(slot.id);
      case SlotStatus.occupied:
        return _buildOccupiedSlot(slot.id, slot.plate, slot.carColor, slot.windowColor);
    }
  }

  Widget _buildTargetSlot(ParkingSlotModel slot) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 54,
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF022C22).withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF10B981), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF17A18A).withValues(alpha: 0.25 + 0.25 * _pulseController.value),
                blurRadius: 8 + 6 * _pulseController.value,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 2),
                      Text(slot.id,
                          style: GoogleFonts.inter(
                              fontSize: 6.5, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
                    ],
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    slot.isTop ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: const Color(0xFF34D399),
                    size: 10,
                  ),
                  Container(
                    width: 34,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF34D399).withValues(alpha: 0.8),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('READY',
                              style: GoogleFonts.inter(
                                  fontSize: 5.5, fontWeight: FontWeight.w900, color: const Color(0xFF6EE7B7))),
                          const SizedBox(height: 1),
                          Text('PARK',
                              style: GoogleFonts.inter(
                                  fontSize: 4.0, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParkedSlot(ParkingSlotModel slot) {
    final String ptsText = _isBonusRound ? '+4500 Pts' : '+1500 Pts';

    return Container(
      width: 54,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF34D399), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(slot.id,
                  style: GoogleFonts.inter(
                      fontSize: 6.5, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.6)),
                ),
                child: Text('PARKIR',
                    style: GoogleFonts.inter(
                        fontSize: 4.5, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
              ),
            ],
          ),
          Container(
            width: 30,
            height: 48,
            decoration: BoxDecoration(
              color: slot.carColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: slot.carColor.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 22,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF083344),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                Text('YOU',
                    style: GoogleFonts.inter(
                        fontSize: 5.0, fontWeight: FontWeight.w900, color: Colors.white)),
                Container(
                  width: 22,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF083344),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          ),
          Text(ptsText,
              style: GoogleFonts.inter(
                  fontSize: 5.0,
                  fontWeight: FontWeight.bold,
                  color: _isBonusRound ? const Color(0xFFFCD34D) : const Color(0xFF34D399))),
        ],
      ),
    );
  }

  Widget _buildOccupiedSlot(String id, String plate, Color carColor, Color windowColor) {
    return Container(
      width: 54,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF450A0A).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.7), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id,
                  style: GoogleFonts.inter(
                      fontSize: 6.5, fontWeight: FontWeight.bold, color: const Color(0xFFF87171))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                ),
                child: Text('TERISI',
                    style: GoogleFonts.inter(fontSize: 4.5, fontWeight: FontWeight.bold, color: const Color(0xFFF87171))),
              ),
            ],
          ),
          Container(
            width: 30,
            height: 48,
            decoration: BoxDecoration(
              color: carColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF94A3B8), width: 1.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 22, height: 9, decoration: BoxDecoration(color: windowColor, borderRadius: BorderRadius.circular(1.5))),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(plate,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 4.5,
                          fontWeight: FontWeight.bold,
                          color: windowColor == const Color(0xFF1E293B) ? const Color(0xFF1E293B) : Colors.white)),
                ),
                Container(width: 22, height: 6, decoration: BoxDecoration(color: windowColor, borderRadius: BorderRadius.circular(1.5))),
              ],
            ),
          ),
          Text('Kendaraan',
              style: GoogleFonts.inter(fontSize: 5.0, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildReservedSlot(String id) {
    return Container(
      width: 54,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF475569), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id,
                  style: GoogleFonts.inter(
                      fontSize: 6.5, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text('RESV',
                    style: GoogleFonts.inter(fontSize: 4.5, fontWeight: FontWeight.bold, color: const Color(0xFFCBD5E1))),
              ),
            ],
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
            ),
            child: Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Container(width: 4.5, height: 4.5, decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle)),
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Tutup (Khusus)',
                style: GoogleFonts.inter(fontSize: 5.0, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
          ),
        ],
      ),
    );
  }
}

// Backward compatibility alias
typedef MiniGameScreen = CarGameScreen;