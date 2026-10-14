import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/sound_service.dart';

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
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
  double _carAngle = 0.0; // 0 = Horizontal (ke kanan), -pi/2 = Vertikal (ke atas masuk parkir)

  // Nilai Sensor
  double _accelTiltX = 0.0;
  double _accelTiltY = 0.0;


  void _startTheGame() {
    if (!mounted) return;
    setState(() => _sensorsConnected = true);
    if (!_startSoundPlayed) {
      _startSoundPlayed = true;
      SoundService.playStartSound();
    }
  }

  // Status Game & Parkir
  bool _isInSlotA05 = false;
  bool _isParked = false;
  bool _isGameOver = false;
  bool _startSoundPlayed = false;
  int _secondsRemaining = 45;
  int _score = 1450;

  @override
  void initState() {
    super.initState();
    // Kunci landscape dan sembunyikan status bar / indikator baterai (Immersive Full Screen)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    bool accelReady = false;
    bool gyroReady = false;

    // Sensor Akselerometer (Kemiringan Perangkat untuk Menyetir Mobil)
    _accelSub = accelerometerEventStream().listen((event) {
      if (!accelReady) {
        accelReady = true;
        if (gyroReady && mounted) {
          _startTheGame();
        }
      }
      // Di landscape:
      // event.y mengontrol sumbu X (kiri/kanan)
      _accelTiltX = event.y * 0.9;
      // DIBALIK (INVERTED Y-AXIS sesuai permintaan):
      // Saat mengarahkan ke atas gerak ke bawah, dan sebaliknya
      _accelTiltY = event.x * 0.9;
    });

    // Sensor Giroskop (Kecepatan Sudut Rotasi)
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (!gyroReady) {
        gyroReady = true;
        if (accelReady && mounted) {
          _startTheGame();
        }
      }
      _accelTiltX += event.y * 0.35;
      _accelTiltY -= event.x * 0.35; // Dibalik juga
    });

    // Fallback otomatis jika sensor stream idle (misal di emulator/PC)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_sensorsConnected) {
        _startTheGame();
      }
    });

    // Loop Fisika Game (60 FPS / ~16ms)
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted && _sensorsConnected) {
        _updatePhysics();
      }
    });

    // Countdown Timer Permainan
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _secondsRemaining > 0 && !_isParked && !_isGameOver) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 0) {
          _handleGameOver();
        }
      }
    });
  }

  @override
  void dispose() {
    // Pastikan seluruh audio permainan berhenti saat keluar dari layar
    SoundService.stopAllSounds();
    _gameLoopTimer?.cancel();
    _clockTimer?.cancel();
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

  // ==========================================
  // LOGIKA BENDA FISIK, KEMUDI & COLLISION DETECTION
  // ==========================================
  void _updatePhysics() {
    if (_isParked || _isGameOver) return;

    // Akselerasi dari kemiringan perangkat (sensor giroskop & akselerometer)
    _vx += _accelTiltX * 0.28;
    _vy += _accelTiltY * 0.28;

    // Gesekan aspal (damping)
    _vx *= 0.88;
    _vy *= 0.88;

    // Batasi kecepatan maksimum
    _vx = _vx.clamp(-4.0, 4.0);
    _vy = _vy.clamp(-4.0, 4.0);

    // Hitung orientasi sudut mobil (Membelokkan mobil dari Horizontal ke Vertikal)
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
      _carAngle += diff * 0.22; // Belokan kemudi yang responsif
    }

    double nextX = _playerX + _vx;
    double nextY = _playerY + _vy;

    // Batas garis luar parkiran atas (y = 10 s/d 96)
    const double topSlotBottomY = 96.0;
    const double topSlotTopY = 16.0;

    // Koordinat Slot A-05 (READY):
    // Slot ke-5 (indeks 4) dari kiri: 14 + 4*64 = 270.0, lebar 56 -> 270 s/d 326
    const double a05Left = 270.0;
    const double a05Right = 326.0;

    // Batas layar
    final mediaQuery = MediaQuery.of(context);
    final double screenH = mediaQuery.size.height > 200 ? mediaQuery.size.height : 390.0;
    final double screenW = mediaQuery.size.width > 200 ? mediaQuery.size.width : 840.0;
    final double bottomSlotTopY = screenH - 96.0;

    // Pusat mobil (panjang 46, tinggi 28 saat horizontal)
    final double nextCenterX = nextX + 23.0;

    // 1. COLLISION & LOGIKA MASUK SLOT A-05 (READY)
    if (_isInSlotA05) {
      // MOBIL SUDAH BERADA DI DALAM SLOT A-05:
      // Tahan mobil di antara dinding kiri dan kanan slot A-05 (tidak akan pernah terpental keluar!)
      final double clampedCenterX = nextCenterX.clamp(a05Left + 14.0, a05Right - 14.0);
      nextX = clampedCenterX - 23.0;
      nextY = nextY.clamp(topSlotTopY, topSlotBottomY + 25.0);

      // Luruskan mobil menghadap ke atas slot parkir (-pi/2) saat masuk
      double alignDiff = (-math.pi / 2) - _carAngle;
      while (alignDiff > math.pi) {
        alignDiff -= 2 * math.pi;
      }
      while (alignDiff < -math.pi) {
        alignDiff += 2 * math.pi;
      }
      _carAngle += alignDiff * 0.15;

      // Jika pemain memundurkan mobil keluar dari slot kembali ke jalan:
      if (nextY >= topSlotBottomY + 8.0) {
        _isInSlotA05 = false;
      }

      // Deteksi parkir sukses sempurna di dalam slot
      if (nextY <= 38.0 && !_isParked) {
        _isParked = true;
        _score += 500;
        // Hentikan suara mobil inGameCar saat berhasil parkir rapi
        SoundService.stopInGameSound();
        _showSuccessDialog();
      }
    } else {
      // MOBIL BERADA DI LUAR (JALANAN / DRIVEWAY):
      if (nextY < topSlotBottomY) {
        // Pemain mencoba masuk ke baris parkir atas:
        // Cek apakah posisi mobil berada di depan mulut celah slot A-05 (READY)
        final bool isAtA05Opening = (nextCenterX >= (a05Left + 4.0) && nextCenterX <= (a05Right - 4.0));

        if (isAtA05Opening) {
          // Posisi pas di depan celah A-05: BISA MASUK MULUS!
          _isInSlotA05 = true;
          final double clampedCenterX = nextCenterX.clamp(a05Left + 14.0, a05Right - 14.0);
          nextX = clampedCenterX - 23.0;
        } else {
          // Menabrak pembatas slot merah/kuning lain di baris atas:
          // Mengganjal di luar garis pembatas, dilarang menembus masuk!
          nextY = topSlotBottomY;
          _vy = 0;
        }
      }
    }

    // 2. COLLISION DENGAN BARIS BAWAH (SEMUA SLOT BAWAH ADALAH OBJEK PADAT)
    if (nextY + 28.0 > bottomSlotTopY) {
      nextY = bottomSlotTopY - 28.0;
      _vy = 0;
    }

    // 3. BATAS TEPI LAYAR KIRI & KANAN
    nextX = nextX.clamp(8.0, screenW - 46.0 - 8.0);
    nextY = nextY.clamp(topSlotTopY, screenH - 28.0 - 8.0);

    setState(() {
      _playerX = nextX;
      _playerY = nextY;
    });
  }

  // Dialog Konfirmasi Keluar (Bawaan Device Back Navigation)
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
          'Apakah Anda yakin ingin keluar dari simulasi parkir arcade ini?',
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

  // Dialog Berhasil Parkir
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF34D399), width: 2),
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 36),
            ),
            const SizedBox(height: 12),
            Text('PARKIR SEMPURNA!',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Kendaraan Anda berhasil masuk rapi ke slot A-05 (READY).',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      Text('SISA WAKTU', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                      Text('00:${_secondsRemaining.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                    ],
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      Text('TOTAL SKOR', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                      Text('$_score pts',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
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
              backgroundColor: const Color(0xFF17A18A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _resetGame();
            },
            child: Text('Main Lagi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Kembali ke Menu', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GAME OVER: WAKTU HABIS & SOUND DIE.MP3
  // ==========================================
  void _handleGameOver() {
    if (_isGameOver || _isParked) return;
    _isGameOver = true;
    _vx = 0;
    _vy = 0;

    // Memutar sound die.mp3 dari android/app/src/main/res/raw/die.mp3
    SoundService.playGameOverSound();

    _showGameOverDialog();
  }

  void _showGameOverDialog() {
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF87171), width: 2),
              ),
              child: const Icon(Icons.timer_off_rounded, color: Color(0xFFF87171), size: 36),
            ),
            const SizedBox(height: 12),
            Text('WAKTU HABIS!',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Waktu parkir 45 detik Anda telah habis sebelum mobil berhasil masuk ke slot A-05.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      Text('STATUS', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                      Text('TIME OUT',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFF87171))),
                    ],
                  ),
                  Container(width: 1, height: 28, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      Text('SKOR AKHIR', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                      Text('$_score pts',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _resetGame();
            },
            child: Text('Coba Lagi', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Kembali ke Menu', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _playerX = 36.0;
      _playerY = 160.0;
      _vx = 0;
      _vy = 0;
      _carAngle = 0.0;
      _isInSlotA05 = false;
      _isParked = false;
      _isGameOver = false;
      _secondsRemaining = 45;
      _score = 1450;
    });
    // Putar sound start.mp3 saat game diulang
    SoundService.playStartSound();
  }


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

    // Intersep Navigasi Back Device dengan PopScope
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
          // Sentuhan / Geseran jari opsional untuk mengemudi jika sensor flat
          onPanUpdate: (details) {
            setState(() {
              _playerX += details.delta.dx;
              _playerY += details.delta.dy;
              if (details.delta.distance > 0.5) {
                final double target = math.atan2(details.delta.dy, details.delta.dx);
                _carAngle = target;
              }
            });
          },
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ==========================================
                // JALAN RAYA ASPAL BESAR DENGAN MARKA KUNING & PUTIH
                // ==========================================
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

                // ==========================================
                // BARIS PARKIR ATAS + KAPSUL HUD DI POJOK KANAN
                // ==========================================
                Positioned(
                  top: 10,
                  left: 14,
                  right: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deretan mobil atas memanjang sampai mendekati pojok kanan
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildOccupiedSlot('A-01', 'B 2341 S', const Color(0xFFE2E8F0), const Color(0xFF1E293B)),
                              const SizedBox(width: 8),
                              _buildOccupiedSlot('A-02', 'B 9871 Z', const Color(0xFF1D4ED8), const Color(0xFF0F172A)),
                              const SizedBox(width: 8),
                              _buildReservedSlot('A-03'),
                              const SizedBox(width: 8),
                              _buildOccupiedSlot('A-04', 'B 4410 TX', const Color(0xFF065F46), const Color(0xFF022C22)),
                              const SizedBox(width: 8),
                              _buildTargetSlot('A-05'), // SLOT READY TARGET
                              const SizedBox(width: 8),
                              _buildOccupiedSlot('A-06', 'D 1902 AB', const Color(0xFFDC2626), const Color(0xFF0F172A)),
                              const SizedBox(width: 8),
                              _buildOccupiedSlot('A-07', 'B 7721 KK', const Color(0xFF6366F1), const Color(0xFF1E293B)),
                              const SizedBox(width: 8),
                              _buildReservedSlot('A-08'),
                              const SizedBox(width: 8),
                              _buildOccupiedSlot('A-09', 'L 1234 XY', const Color(0xFF0284C7), const Color(0xFF0F172A)),
                              const SizedBox(width: 8),
                              _buildOccupiedSlot('A-10', 'AB 8899 CD', const Color(0xFFD97706), const Color(0xFF1E293B)),
                              const SizedBox(width: 8),
                              _buildOccupiedSlot('A-11', 'B 5500 ZZ', const Color(0xFF475569), const Color(0xFF0F172A)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Kapsul Waktu & Skor Posisi Pojok Kanan Atas
                      _buildHudTower(),
                    ],
                  ),
                ),

                // ==========================================
                // DUPLIKAT BARIS PARKIR BAWAH MEMANJANG PENUH
                // ==========================================
                Positioned(
                  bottom: 10,
                  left: 14,
                  right: 14,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildOccupiedSlot('B-01', 'D 1102 AB', const Color(0xFFDC2626), const Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-02', 'B 8832 KLP', const Color(0xFFF59E0B), const Color(0xFF1E293B)),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-03', 'AB 4921 YY', const Color(0xFF475569), const Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        _buildReservedSlot('B-04'),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-05', 'B 1945 ID', const Color(0xFF0284C7), const Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-06', 'AD 3341 GH', const Color(0xFF10B981), const Color(0xFF022C22)),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-07', 'B 9012 QQ', const Color(0xFF9333EA), const Color(0xFF1E293B)),
                        const SizedBox(width: 8),
                        _buildReservedSlot('B-08'),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-09', 'N 6677 KL', const Color(0xFFE11D48), const Color(0xFF0F172A)),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-10', 'B 4422 WE', const Color(0xFF0D9488), const Color(0xFF022C22)),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-11', 'DK 8181 JK', const Color(0xFFF97316), const Color(0xFF1E293B)),
                        const SizedBox(width: 8),
                        _buildOccupiedSlot('B-12', 'B 3030 TY', const Color(0xFF2563EB), const Color(0xFF0F172A)),
                      ],
                    ),
                  ),
                ),

                // ==========================================
                // MOBIL PEMAIN (MULAI HORIZONTAL, MEMBELOK DENGAN GIROSKOP)
                // ==========================================
                Positioned(
                  left: _playerX,
                  top: _playerY,
                  child: _buildPlayerCar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Mobil Pemain (Bodi Horizontal di Awal, Dapat Berputar Menjadi Vertikal)
  Widget _buildPlayerCar() {
    return Transform.rotate(
      angle: _carAngle,
      child: Container(
        width: 46, // Panjang mobil mendatar saat horizontal
        height: 28, // Lebar mobil
        decoration: BoxDecoration(
          color: const Color(0xFF06B6D4), // Cyan sporty
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.white, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.6),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Lampu Belakang Merah (Sisi Kiri/Belakang)
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
            // Atap Mobil / Label YOU
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
            // Lampu Depan Kuning Menyala (Sisi Kanan/Depan Menghadap Arah Laju)
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

  // Kapsul Waktu & Skor di Pojok Kanan Atas
  Widget _buildHudTower() {
    return Container(
      width: 76,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          // Kapsul Waktu
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Color(0xFFFBBF24), size: 11),
                  const SizedBox(width: 3),
                  Text('WAKTU',
                      style: GoogleFonts.inter(
                          fontSize: 7.5, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 2),
              Text('00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(
                      fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
            ],
          ),
          Container(width: 48, height: 1, color: const Color(0xFF334155)),
          // Kapsul Skor
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Color(0xFF34D399), size: 11),
                  const SizedBox(width: 3),
                  Text('SKOR',
                      style: GoogleFonts.inter(
                          fontSize: 7.5, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 2),
              Text('$_score',
                  style: GoogleFonts.inter(
                      fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
            ],
          ),
        ],
      ),
    );
  }

  // Slot Terisi (Ukuran Mobil & Kotak Luar 50% Skala - Aman dari Overflow)
  Widget _buildOccupiedSlot(String id, String plate, Color carColor, Color windowColor) {
    return Container(
      width: 56,
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
          // Bodi Mobil (Ukuran 30 x 48)
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
                // Kaca Depan
                Container(width: 22, height: 9, decoration: BoxDecoration(color: windowColor, borderRadius: BorderRadius.circular(1.5))),
                // Pelat Nomor
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(plate,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 4.5,
                          fontWeight: FontWeight.bold,
                          color: windowColor == const Color(0xFF1E293B) ? const Color(0xFF1E293B) : Colors.white)),
                ),
                // Kaca Belakang
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

  // Slot Reservasi (Aman dari Overflow)
  Widget _buildReservedSlot(String id) {
    return Container(
      width: 56,
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

  // Slot Target A-05 (READY)
  Widget _buildTargetSlot(String id) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF022C22).withValues(alpha: 0.4),
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
                      Text(id,
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
                  Icon(Icons.keyboard_arrow_down, color: const Color(0xFF34D399), size: 10),
                  Container(
                    width: 34,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.8), style: BorderStyle.solid),
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
}
