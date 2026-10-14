import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/sound_service.dart';

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

  // Koordinat horizontal tiap slot (lebar 54, jarak antar slot 8)
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
  final String title;
  final int targetCars; // Jumlah mobil yang harus diparkir di ronde ini
  final List<String> targetSlotIds;
  final List<MineObstacle> mines;
  final String hint;

  const RoundDefinition({
    required this.roundNumber,
    required this.title,
    required this.targetCars,
    required this.targetSlotIds,
    required this.mines,
    required this.hint,
  });
}

// ============================================================
// LAYAR UTAMA SIMULASI PARKIR DINAMIS 10 RONDE
// ============================================================
class CarGameScreen extends StatefulWidget {
  const CarGameScreen({super.key});

  @override
  State<CarGameScreen> createState() => _CarGameScreenState();
}

class _CarGameScreenState extends State<CarGameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _gameLoopTimer;
  Timer? _clockTimer;
  Timer? _toastTimer;

  bool _sensorsConnected = false;
  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;

  // Koordinat & Kecepatan Mobil Pemain
  double _playerX = 36.0;
  double _playerY = 160.0;
  double _vx = 0.0;
  double _vy = 0.0;
  double _carAngle = 0.0; // 0 = Horizontal (ke kanan), -pi/2 = Atas, pi/2 = Bawah

  // Nilai Sensor Kemiringan
  double _accelTiltX = 0.0;
  double _accelTiltY = 0.0;

  // Status Permainan & Progres Ronde
  int _currentRound = 1;
  int _carsParkedInRound = 0;
  int _secondsRemaining = 40; // Awal mulai 40 detik sesuai instruksi
  int _score = 1450;
  bool _isGameOver = false;
  bool _isRoundComplete = false;
  bool _startSoundPlayed = false;

  // Efek Ledakan & Notifikasi Toast
  bool _isExploding = false;
  Offset? _explosionPos;
  String? _toastMessage;

  // Slot Aktif yang sedang dimasuki mobil
  ParkingSlotModel? _activeSlot;

  // Daftar Slot Baris Atas & Baris Bawah
  List<ParkingSlotModel> _topSlots = [];
  List<ParkingSlotModel> _bottomSlots = [];

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
  // DEFINISI 10 RONDE DENGAN TINGKAT KESULITAN BERTINGKAT
  // ============================================================
  final List<RoundDefinition> _rounds = const [
    // Ronde 1: 1 Mobil, tanpa ranjau, slot A-05 di tengah
    RoundDefinition(
      roundNumber: 1,
      title: 'Pemanasan Parkir',
      targetCars: 1,
      targetSlotIds: ['A-05'],
      mines: [],
      hint: 'Ronde 1: Parkirkan 1 mobil ke slot A-05. Jalanan bebas ranjau!',
    ),
    // Ronde 2: 4 Mobil, 1 ranjau di tengah jalan raya
    RoundDefinition(
      roundNumber: 2,
      title: 'Manuver 4 Mobil',
      targetCars: 4,
      targetSlotIds: ['A-03', 'A-08', 'B-04', 'B-07'],
      mines: [
        MineObstacle(x: 390, y: 160),
      ],
      hint: 'Ronde 2: Parkirkan 4 mobil ke slot hijau! Awas ada 1 ranjau di tengah jalan!',
    ),
    // Ronde 3: 3 Mobil berjauhan di ujung kiri dan kanan
    RoundDefinition(
      roundNumber: 3,
      title: 'Target Saling Berjauhan',
      targetCars: 3,
      targetSlotIds: ['A-01', 'B-10', 'A-10'],
      mines: [
        MineObstacle(x: 230, y: 140),
        MineObstacle(x: 480, y: 180),
      ],
      hint: 'Ronde 3: Posisi 3 slot berjauhan di ujung kiri & kanan! Waspadai 2 ranjau!',
    ),
    // Ronde 4: 4 Mobil, 3 ranjau slalom
    RoundDefinition(
      roundNumber: 4,
      title: 'Jalur Berkelok Zig-Zag',
      targetCars: 4,
      targetSlotIds: ['A-04', 'A-07', 'B-03', 'B-08'],
      mines: [
        MineObstacle(x: 200, y: 180),
        MineObstacle(x: 340, y: 140),
        MineObstacle(x: 480, y: 180),
      ],
      hint: 'Ronde 4: 3 ranjau membentuk rintangan slalom! Parkirkan 4 mobil.',
    ),
    // Ronde 5: 4 Mobil, ranjau mulai mendekati pembatas slot
    RoundDefinition(
      roundNumber: 5,
      title: 'Pendekatan Sempit',
      targetCars: 4,
      targetSlotIds: ['A-02', 'A-09', 'B-05', 'B-09'],
      mines: [
        MineObstacle(x: 180, y: 130),
        MineObstacle(x: 310, y: 190),
        MineObstacle(x: 440, y: 130),
        MineObstacle(x: 570, y: 188),
      ],
      hint: 'Ronde 5: 4 ranjau mulai mendekati bibir slot parkir! Atur kecepatan.',
    ),
    // Ronde 6: 5 Mobil, 5 ranjau menjaga jalan utama
    RoundDefinition(
      roundNumber: 6,
      title: 'Zona Ranjau Beruntun',
      targetCars: 5,
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
    // Ronde 7: 5 Mobil, ranjau di depan pendekatan pintu masuk slot
    RoundDefinition(
      roundNumber: 7,
      title: 'Manuver Sempit Masuk Slot',
      targetCars: 5,
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
    // Ronde 8: 5 Mobil, 7 ranjau presisi tinggi
    RoundDefinition(
      roundNumber: 8,
      title: 'Taktik Presisi Ekstrem',
      targetCars: 5,
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
    // Ronde 9: 6 Mobil, 8 ranjau aktif
    RoundDefinition(
      roundNumber: 9,
      title: 'Ladang Ranjau Ahli',
      targetCars: 6,
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
    // Ronde 10: 6 Mobil, 9 ranjau babak pamungkas
    RoundDefinition(
      roundNumber: 10,
      title: 'Master Parkir - Grand Finale',
      targetCars: 6,
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

  RoundDefinition get _currentRoundDef => _rounds[(_currentRound - 1).clamp(0, _rounds.length - 1)];

  @override
  void initState() {
    super.initState();
    // Kunci orientasi landscape & layar penuh immersive
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _initRound(_currentRound);

    bool accelReady = false;
    bool gyroReady = false;

    // Sensor Akselerometer (Kemiringan Perangkat)
    _accelSub = accelerometerEventStream().listen((event) {
      if (!accelReady) {
        accelReady = true;
        if (gyroReady && mounted) {
          _startTheGame();
        }
      }
      _accelTiltX = event.y * 0.9;
      _accelTiltY = event.x * 0.9; // Inverted Y-axis sesuai preferensi kendali
    });

    // Sensor Giroskop
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

    // Fallback otomatis jika sensor idle (misal di simulator/PC)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_sensorsConnected) {
        _startTheGame();
      }
    });

    // Game Physics Loop (~60 FPS)
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted && _sensorsConnected) {
        _updatePhysics();
      }
    });

    // Countdown Timer Permainan (1 Detik)
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _secondsRemaining > 0 && !_isRoundComplete && !_isGameOver) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 0) {
          _handleGameOver(isMine: false);
        }
      }
    });
  }

  void _startTheGame() {
    if (!mounted) return;
    setState(() => _sensorsConnected = true);
    if (!_startSoundPlayed) {
      _startSoundPlayed = true;
      SoundService.playStartSound();
      _showFloatingToast(_currentRoundDef.hint);
    }
  }

  // Menginisialisasi tata letak slot & ranjau untuk ronde tertentu
  void _initRound(int roundNum) {
    final def = _rounds[(roundNum - 1).clamp(0, _rounds.length - 1)];

    final plates = [
      'B 2341 S', 'B 9871 Z', 'B 4410 TX', 'D 1902 AB', 'B 7721 KK',
      'L 1234 XY', 'AB 8899 CD', 'B 5500 ZZ', 'D 1102 AB', 'B 8832 KLP',
      'AB 4921 YY', 'B 1945 ID', 'AD 3341 GH', 'B 9012 QQ', 'N 6677 KL',
      'B 4422 WE', 'DK 8181 JK', 'B 3030 TY', 'H 9988 AA', 'BK 5432 ZY'
    ];

    final colors = [
      const Color(0xFFE2E8F0), const Color(0xFF1D4ED8), const Color(0xFF065F46),
      const Color(0xFFDC2626), const Color(0xFF6366F1), const Color(0xFF0284C7),
      const Color(0xFFD97706), const Color(0xFF475569), const Color(0xFFF59E0B),
      const Color(0xFF9333EA), const Color(0xFFE11D48), const Color(0xFF0D9488)
    ];

    // Inisialisasi 11 Slot Atas (A-01 s/d A-11)
    _topSlots = List.generate(11, (i) {
      final id = 'A-${(i + 1).toString().padLeft(2, '0')}';
      final isTarget = def.targetSlotIds.contains(id);
      SlotStatus status;
      if (isTarget) {
        status = SlotStatus.target;
      } else if ((i + roundNum) % 4 == 0) {
        status = SlotStatus.reserved;
      } else {
        status = SlotStatus.occupied;
      }

      return ParkingSlotModel(
        id: id,
        isTop: true,
        index: i,
        status: status,
        plate: plates[(i * 3 + roundNum) % plates.length],
        carColor: colors[(i * 2 + roundNum) % colors.length],
        windowColor: const Color(0xFF0F172A),
      );
    });

    // Inisialisasi 11 Slot Bawah (B-01 s/d B-11)
    _bottomSlots = List.generate(11, (i) {
      final id = 'B-${(i + 1).toString().padLeft(2, '0')}';
      final isTarget = def.targetSlotIds.contains(id);
      SlotStatus status;
      if (isTarget) {
        status = SlotStatus.target;
      } else if ((i + roundNum + 2) % 5 == 0) {
        status = SlotStatus.reserved;
      } else {
        status = SlotStatus.occupied;
      }

      return ParkingSlotModel(
        id: id,
        isTop: false,
        index: i,
        status: status,
        plate: plates[(i * 5 + roundNum + 3) % plates.length],
        carColor: colors[(i * 3 + roundNum + 1) % colors.length],
        windowColor: const Color(0xFF0F172A),
      );
    });

    _carsParkedInRound = 0;
    _secondsRemaining = 40; // 40 Detik awal tiap ronde sesuai instruksi
    _activeSlot = null;
    _isGameOver = false;
    _isRoundComplete = false;
    _isExploding = false;

    // Reset posisi mobil pemain ke area aman spawn kiri
    _playerX = 36.0;
    _playerY = 160.0;
    _vx = 0.0;
    _vy = 0.0;
    _carAngle = 0.0;
  }

  void _showFloatingToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toastMessage = message);
    _toastTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  @override
  void dispose() {
    SoundService.stopAllSounds();
    _gameLoopTimer?.cancel();
    _clockTimer?.cancel();
    _toastTimer?.cancel();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _pulseController.dispose();
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
    if (_isRoundComplete || _isGameOver || _isExploding) return;

    // Akselerasi dari sensor kemiringan
    _vx += _accelTiltX * 0.28;
    _vy += _accelTiltY * 0.28;

    // Gesekan aspal
    _vx *= 0.88;
    _vy *= 0.88;

    // Batasi kecepatan maksimal
    _vx = _vx.clamp(-4.0, 4.0);
    _vy = _vy.clamp(-4.0, 4.0);

    // Hitung orientasi sudut mobil mengikuti arah gerak
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
    for (final mine in _currentRoundDef.mines) {
      final double dx = nextCenterX - mine.x;
      final double dy = nextCenterY - mine.y;
      final double dist = math.sqrt(dx * dx + dy * dy);
      if (dist < 20.0) {
        // Tabrakan ranjau! Mobil meledak seketika
        _triggerExplosion(mine.x, mine.y);
        _handleGameOver(isMine: true);
        return;
      }
    }

    // 2. DETEKSI & MASUK KE SLOT BARIS ATAS (A)
    if (_activeSlot != null && _activeSlot!.isTop) {
      // Mobil sedang bermanuver di dalam slot atas
      final double clampedCenterX = nextCenterX.clamp(_activeSlot!.left + 12.0, _activeSlot!.right - 12.0);
      nextX = clampedCenterX - 23.0;
      nextY = nextY.clamp(topSlotTopY, topSlotBottomY + 25.0);

      // Luruskan mobil menghadap ke atas (-pi/2)
      double alignDiff = (-math.pi / 2) - _carAngle;
      while (alignDiff > math.pi) {
        alignDiff -= 2 * math.pi;
      }
      while (alignDiff < -math.pi) {
        alignDiff += 2 * math.pi;
      }
      _carAngle += alignDiff * 0.16;

      // Mundur kembali ke jalan raya
      if (nextY >= topSlotBottomY + 8.0) {
        _activeSlot = null;
      }

      // Deteksi berhasil parkir rapi di slot atas
      if (nextY <= 36.0) {
        _onCarParkedSuccess(_activeSlot!);
        return;
      }
    } else if (nextY < topSlotBottomY) {
      // Pemain mencoba masuk ke baris parkir atas dari jalan raya
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
        // Posisi pas di depan mulut slot target: MASUK MULUS!
        _activeSlot = targetCandidate;
        final double clampedCenterX = nextCenterX.clamp(targetCandidate.left + 12.0, targetCandidate.right - 12.0);
        nextX = clampedCenterX - 23.0;
      } else {
        // Menabrak pembatas slot lain: tertahan di luar
        nextY = topSlotBottomY;
        _vy = 0;
      }
    }

    // 3. DETEKSI & MASUK KE SLOT BARIS BAWAH (B)
    if (_activeSlot != null && !_activeSlot!.isTop) {
      // Mobil sedang bermanuver di dalam slot bawah
      final double clampedCenterX = nextCenterX.clamp(_activeSlot!.left + 12.0, _activeSlot!.right - 12.0);
      nextX = clampedCenterX - 23.0;
      nextY = nextY.clamp(bottomSlotTopY - 25.0, bottomSlotBottomY - 28.0);

      // Luruskan mobil menghadap ke bawah (pi/2)
      double alignDiff = (math.pi / 2) - _carAngle;
      while (alignDiff > math.pi) {
        alignDiff -= 2 * math.pi;
      }
      while (alignDiff < -math.pi) {
        alignDiff += 2 * math.pi;
      }
      _carAngle += alignDiff * 0.16;

      // Mundur kembali ke jalan raya
      if (nextY + 28.0 <= bottomSlotTopY - 8.0) {
        _activeSlot = null;
      }

      // Deteksi berhasil parkir rapi di slot bawah
      if (nextY + 28.0 >= bottomSlotBottomY - 14.0) {
        _onCarParkedSuccess(_activeSlot!);
        return;
      }
    } else if (nextY + 28.0 > bottomSlotTopY) {
      // Pemain mencoba masuk ke baris parkir bawah dari jalan raya
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
        // Posisi pas di depan mulut slot target: MASUK MULUS!
        _activeSlot = targetCandidate;
        final double clampedCenterX = nextCenterX.clamp(targetCandidate.left + 12.0, targetCandidate.right - 12.0);
        nextX = clampedCenterX - 23.0;
      } else {
        // Menabrak pembatas slot bawah: tertahan di luar
        nextY = bottomSlotTopY - 28.0;
        _vy = 0;
      }
    }

    // 4. BATAS LUAR LAYAR KIRI & KANAN
    nextX = nextX.clamp(8.0, screenW - 46.0 - 8.0);
    nextY = nextY.clamp(topSlotTopY, screenH - 28.0 - 8.0);

    setState(() {
      _playerX = nextX;
      _playerY = nextY;
    });
  }

  // ============================================================
  // LOGIKA BERHASIL PARKIR 1 MOBIL & PENAMBAHAN WAKTU +10 DETIK
  // ============================================================
  void _onCarParkedSuccess(ParkingSlotModel slot) {
    if (_isRoundComplete || _isGameOver) return;

    setState(() {
      slot.status = SlotStatus.parked;
      slot.carColor = _carPalette[_carsParkedInRound % _carPalette.length];
      _carsParkedInRound++;
      // Setiap kali 1 mobil masuk bertambah 10 detik sesuai instruksi
      _secondsRemaining += 10;
      _score += 500;
      _activeSlot = null;
    });

    HapticFeedback.heavyImpact();

    if (_carsParkedInRound < _currentRoundDef.targetCars) {
      // Masih ada mobil berikutnya di ronde ini: munculkan mobil baru di spawn
      _showFloatingToast(
        '+10 DETIK! Mobil $_carsParkedInRound/${_currentRoundDef.targetCars} Selesai! Mengambil Mobil Berikutnya...',
      );

      setState(() {
        _playerX = 36.0;
        _playerY = 160.0;
        _vx = 0.0;
        _vy = 0.0;
        _carAngle = 0.0;
      });
    } else {
      // Seluruh target mobil di ronde ini telah selesai diparkir!
      _isRoundComplete = true;
      SoundService.stopInGameSound();
      _showRoundClearDialog();
    }
  }

  // Efek Animasi Ledakan Ranjau
  void _triggerExplosion(double x, double y) {
    setState(() {
      _isExploding = true;
      _explosionPos = Offset(x, y);
    });
    HapticFeedback.vibrate();
  }

  // ============================================================
  // PENANGANAN GAME OVER (MENABRAK RANJAU ATAU WAKTU HABIS)
  // ============================================================
  void _handleGameOver({required bool isMine}) {
    if (_isGameOver || _isRoundComplete) return;
    _isGameOver = true;
    _vx = 0;
    _vy = 0;

    // Putar sound die.mp3 (mematikan inGameCar.mp3 otomatis)
    SoundService.playGameOverSound();

    _showGameOverDialog(isMine: isMine);
  }

  void _showGameOverDialog({required bool isMine}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        title: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF87171), width: 2),
              ),
              child: isMine
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/images/bomb.png', fit: BoxFit.contain),
                    )
                  : const Icon(Icons.timer_off_rounded, color: Color(0xFFF87171), size: 34),
            ),
            const SizedBox(height: 10),
            Text(
              isMine ? 'MOBIL MELEDAK!' : 'WAKTU HABIS!',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMine
                  ? 'Mobil Anda menginjak ranjau darat di jalanan! Ronde $_currentRound gagal diselesaikan.'
                  : 'Waktu parkir 40 detik Anda telah habis sebelum seluruh target mobil di Ronde $_currentRound terparkir.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
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
                      Text('RONDE', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                      Text('$_currentRound / 10',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  Container(width: 1, height: 26, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      Text('MOBIL SELESAI', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                      Text('$_carsParkedInRound / ${_currentRoundDef.targetCars}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
                    ],
                  ),
                  Container(width: 1, height: 26, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      Text('TOTAL SKOR', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                      Text('$_score pts',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _retryCurrentRound();
            },
            child: Text('Coba Lagi Ronde $_currentRound',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF475569)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _restartFromRound1();
            },
            child: Text('Mulai Ronde 1',
                style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Keluar ke Menu', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIALOG SELESAI RONDE (ROUND CLEAR)
  // ============================================================
  void _showRoundClearDialog() {
    final bool isLastRound = (_currentRound >= 10);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isLastRound ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
            width: 2,
          ),
        ),
        title: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: (isLastRound ? const Color(0xFFF59E0B) : const Color(0xFF10B981)).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLastRound ? const Color(0xFFFCD34D) : const Color(0xFF34D399),
                  width: 2,
                ),
              ),
              child: Icon(
                isLastRound ? Icons.emoji_events_rounded : Icons.check_circle_rounded,
                color: isLastRound ? const Color(0xFFFCD34D) : const Color(0xFF34D399),
                size: 36,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isLastRound ? 'SELAMAT! MASTER PARKIR!' : 'RONDE $_currentRound SELESAI!',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLastRound
                  ? 'Luar biasa! Anda berhasil menaklukkan seluruh 10 Ronde dan menghindari semua ranjau!'
                  : 'Semua ${_currentRoundDef.targetCars} mobil pada Ronde $_currentRound sukses terparkir dengan aman!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
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
                      Text('SISA WAKTU', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                      Text('$_secondsRemaining dtk',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
                    ],
                  ),
                  Container(width: 1, height: 26, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      Text('TOTAL SKOR', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                      Text('$_score pts',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastRound ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (isLastRound) {
                _restartFromRound1();
              } else {
                _advanceToNextRound();
              }
            },
            child: Text(
              isLastRound ? 'Main Ulang dari Ronde 1' : 'Lanjut ke Ronde ${_currentRound + 1} ➔',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Kembali ke Menu', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _advanceToNextRound() {
    setState(() {
      _currentRound++;
      _initRound(_currentRound);
    });
    SoundService.playStartSound();
    _showFloatingToast(_currentRoundDef.hint);
  }

  void _retryCurrentRound() {
    setState(() {
      _initRound(_currentRound);
    });
    SoundService.playStartSound();
  }

  void _restartFromRound1() {
    setState(() {
      _currentRound = 1;
      _score = 1450;
      _initRound(1);
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
      return Scaffold(
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
      );
    }

    return PopScope(
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
          // Kendali sentuhan geser opsional jika sensor kemiringan flat
          onPanUpdate: (details) {
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
                for (final mine in _currentRoundDef.mines)
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

                // 7. KAPSUL HUD DI POJOK KANAN ATAS
                Positioned(
                  top: 8,
                  right: 10,
                  child: _buildHudTower(),
                ),

                // 8. BANNER TOAST PETUNJUK RONDE
                if (_toastMessage != null)
                  Positioned(
                    top: 102,
                    child: _buildToastBanner(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Bodi Mobil Pemain
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
            // Lampu Belakang Merah
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 2, height: 4, color: const Color(0xFFEF4444)),
                Container(width: 2, height: 4, color: const Color(0xFFEF4444)),
              ],
            ),
            // Kaca Belakang
            Container(
              width: 6,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF083344),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            // Label YOU
            Text('YOU',
                style: GoogleFonts.inter(fontSize: 5.0, fontWeight: FontWeight.w900, color: Colors.white)),
            // Kaca Depan
            Container(
              width: 8,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF083344),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Lampu Depan Menyala
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

  // Widget Rintangan Ranjau Darat
  Widget _buildMineWidget(MineObstacle mine) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Lingkaran Peringatan Berdenyut Merah
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
            // Gambar Ikon Ranjau PNG Transparan
            Image.asset(
              'assets/images/bomb.png',
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            // Indikator Titik Merah Aktif di Pucuk Bom
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

  // Efek Animasi Ledakan
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

  // Banner Petunjuk Terapung di Tengah
  Widget _buildToastBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 14),
          const SizedBox(width: 6),
          Text(
            _toastMessage!,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // Menara HUD (Ronde, Mobil, Waktu, Skor)
  Widget _buildHudTower() {
    return Container(
      width: 80,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155), width: 1.5),
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
          // Ronde & Mobil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('R$_currentRound/10',
                  style: GoogleFonts.inter(
                      fontSize: 8.0, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8))),
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
          Container(width: 66, height: 1, color: const Color(0xFF334155)),
          // Waktu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: Color(0xFFFBBF24), size: 10),
              const SizedBox(width: 2),
              Text('00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                      fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
              const SizedBox(width: 2),
              Text('+10s',
                  style: GoogleFonts.inter(
                      fontSize: 6.5, fontWeight: FontWeight.w900, color: const Color(0xFF34D399))),
            ],
          ),
          Container(width: 66, height: 1, color: const Color(0xFF334155)),
          // Skor
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

  // Builder Slot Berdasarkan Status
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

  // Slot Target Hijau Menyala (READY PARK)
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

  // Slot yang Telah Sukses Diparkir Pemain dalam Ronde Ini
  Widget _buildParkedSlot(ParkingSlotModel slot) {
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
          // Bodi Mobil Pemain yang Sudah Terparkir
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
          Text('+10 Detik',
              style: GoogleFonts.inter(
                  fontSize: 5.0, fontWeight: FontWeight.bold, color: const Color(0xFF34D399))),
        ],
      ),
    );
  }

  // Slot Terisi Mobil Lain
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

  // Slot Reservasi / Ditutup
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
