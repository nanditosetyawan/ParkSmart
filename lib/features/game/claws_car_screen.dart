import '../../theme/app_theme.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/sound_service.dart';
import 'backend/claws_car_backend.dart';

// ============================================================================
// MODEL ITEM DALAM MESIN CAPIT (KOIN, IKAN, BATU)
// Setiap biji adalah individu mandiri dengan posisi, rotasi, & fisika sendiri
// ============================================================================
enum ClawItemType { coin, ikan, batu }

class ClawItem {
  final String id;
  final ClawItemType type;
  double normalizedX; // 0.0 s/d 1.0 pada lebar dasar etalase
  double normalizedY; // 0.0 (atas) s/d 1.0 (lantai dasar)
  double pixelX;
  double pixelY;
  double vx;
  double vy;
  double rotation;
  double vRot;
  int layer; // 0 = lapis bawah, 1 = lapis atas (bertumpuk)
  bool isGrabbed;
  bool isDropped;

  ClawItem({
    required this.id,
    required this.type,
    required this.normalizedX,
    required this.normalizedY,
    this.pixelX = 0.0,
    this.pixelY = 0.0,
    this.vx = 0.0,
    this.vy = 0.0,
    this.rotation = 0.0,
    this.vRot = 0.0,
    required this.layer,
    this.isGrabbed = false,
    this.isDropped = false,
  });

  String get assetPath {
    switch (type) {
      case ClawItemType.coin:
        return 'assets/images/coin.png';
      case ClawItemType.ikan:
        return 'assets/images/ikan.png';
      case ClawItemType.batu:
        return 'assets/images/batu.png';
    }
  }

  String get displayName {
    switch (type) {
      case ClawItemType.coin:
        return 'Koin Emas';
      case ClawItemType.ikan:
        return 'Ikan';
      case ClawItemType.batu:
        return 'Batu';
    }
  }
}

class ClawsCarScreen extends StatefulWidget {
  const ClawsCarScreen({super.key});

  @override
  State<ClawsCarScreen> createState() => _ClawsCarScreenState();
}

class _ClawsCarScreenState extends State<ClawsCarScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Posisi horizontal crane (0.0 = ujung kiri lubang pembuangan, 1.0 = ujung kanan)
  double _craneX = 0.5;

  // Animasi turun & naik capit
  late AnimationController _dropController;
  double _dropProgress = 0.0;

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
  int _userPoints = 25000; // Poin akumulasi dari game Parking Challenge
  int _credits = 5; // Koin capit untuk bermain

  // ============================================================
  // ITEM & SENSOR FISIKA
  // ============================================================
  List<ClawItem> _items = [];
  ClawItem? _heldItem; // Item yang sedang dicapit saat ini

  // Cache gambar ui.Image untuk rendering CustomPainter
  ui.Image? _coinImage;
  ui.Image? _fishImage;
  ui.Image? _rockImage;

  // Batas area kaca etalase mesin capit (dihitung dinamis oleh painter)
  double _chamberMinX = 0.0;
  double _chamberMaxX = 300.0;
  double _chamberMinY = 0.0;
  double _chamberMaxY = 300.0;
  double _maxDropDistance = 150.0;
  bool _hasInitialPositions = false;

  // Sensor HP Shake (Kocok)
  StreamSubscription<AccelerometerEvent>? _accelSub;
  DateTime _lastShakeTime = DateTime.now();
  Timer? _physicsTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Putar musik claws (musiccrawls.mp3) nonstop secara loop tak terbatas selama halaman terbuka
    SoundService.startClawsMusic();

    // 1. Kunci rotasi ke portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _loadUserData();
    _loadAssetImages();
    _items = _generateDefaultItems();
    _initSensors();

    // Controller turun & naik capit
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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

    // Controller pintu flap 3D lubang pembuangan dengan gerakan buka-tutup natural
    _flapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    _flapAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 28,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: -0.16).chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.16, end: 0.08).chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 22,
      ),
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

  // ============================================================
  // INISIALISASI 2 LAPIS ITEM BERTUMPUK KE ATAS FLAT 2D DI DALAM KACA MESIN CAPIT
  // ============================================================
  List<ClawItem> _generateDefaultItems() {
    final List<ClawItem> list = [];

    // Lapis 0 (Bawah): 6 butir item mandiri di lantai dasar etalase
    final layer0Types = [
      ClawItemType.batu,
      ClawItemType.coin,
      ClawItemType.ikan,
      ClawItemType.batu,
      ClawItemType.coin,
      ClawItemType.ikan,
    ];
    for (int i = 0; i < layer0Types.length; i++) {
      final double normX = 0.08 + i * (0.84 / (layer0Types.length - 1));
      list.add(ClawItem(
        id: 'L0_$i',
        type: layer0Types[i],
        normalizedX: normX,
        normalizedY: 1.0, // Duduk tepat di lantai dasar flat 2D
        rotation: (i % 2 == 0 ? 0.06 : -0.08) * (i + 1),
        layer: 0,
      ));
    }

    // Lapis 1 (Atas): 5 butir item mandiri bertumpuk ke atas (bertimpuk 2D) di celah lapis 0
    final layer1Types = [
      ClawItemType.coin,
      ClawItemType.ikan,
      ClawItemType.batu,
      ClawItemType.coin,
      ClawItemType.ikan,
    ];
    for (int i = 0; i < layer1Types.length; i++) {
      final double normX = 0.164 + i * (0.672 / (layer1Types.length - 1));
      list.add(ClawItem(
        id: 'L1_$i',
        type: layer1Types[i],
        normalizedX: normX,
        normalizedY: 0.82, // Bertumpuk ke atas di atas lapis 0
        rotation: (i % 2 == 0 ? -0.12 : 0.14) * (i + 1),
        layer: 1,
      ));
    }

    return list;
  }

  // Decode gambar aset menjadi ui.Image dengan ukuran teroptimasi
  Future<void> _loadAssetImages() async {
    try {
      _coinImage = await _decodeAssetImage('assets/images/coin.png', 100, 100);
      _fishImage = await _decodeAssetImage('assets/images/ikan.png', 100, 100);
      _rockImage = await _decodeAssetImage('assets/images/batu.png', 100, 100);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('[ClawsCar] Error decoding asset images: $e');
    }
  }

  Future<ui.Image> _decodeAssetImage(String path, int targetWidth, int targetHeight) async {
    final byteData = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  // ============================================================
  // SENSOR HP KOCOK (SHAKE DETECTOR) & FISIKA LOMPAT DI DALAM KACA
  // ============================================================
  void _initSensors() {
    try {
      _accelSub = accelerometerEventStream().listen((event) {
        final double gX = event.x / 9.80665;
        final double gY = event.y / 9.80665;
        final double gZ = event.z / 9.80665;
        final double gForce = math.sqrt(gX * gX + gY * gY + gZ * gZ);

        // Ambang batas g-force gerakan kocok HP
        if (gForce > 2.2) {
          final now = DateTime.now();
          if (now.difference(_lastShakeTime).inMilliseconds > 380) {
            _lastShakeTime = now;
            _shakeItems(gForce: gForce, dirX: -gX);
          }
        }
      });
    } catch (e) {
      debugPrint('[ClawsCar] Accelerometer stream warning: $e');
    }
  }

  /// Memicu efek kocok pada semua item di dalam etalase kaca
  void _shakeItems({double gForce = 2.4, double dirX = 0.0}) {
    if (_isOperating) return; // Jangan kocok saat capit sedang aktif bergerak turun
    HapticFeedback.mediumImpact();

    final rnd = math.Random();
    for (final item in _items) {
      if (item.isGrabbed || item.isDropped) continue;
      // Lompatan vertikal mandiri ke atas
      item.vy = - (rnd.nextDouble() * 10.0 + 7.5);
      // Menggelinding ke kanan atau ke kiri secara mandiri beda-beda arah
      final double spread = (rnd.nextDouble() - 0.5) * 15.0;
      final double bias = dirX.abs() > 0.2 ? (dirX > 0 ? 3.5 : -3.5) : 0.0;
      item.vx = spread + bias;
      // Rotasi menggelinding mandiri
      item.vRot = (rnd.nextDouble() - 0.5) * 0.55;
    }

    _startPhysicsLoop();
  }

  void _startPhysicsLoop() {
    if (_physicsTimer != null && _physicsTimer!.isActive) return;
    const double itemSize = 48.0;

    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      bool hasActiveMovement = false;
      const double gravity = 0.70;

      for (final item in _items) {
        if (item.isGrabbed || item.isDropped) continue;

        // Cek dasar pijakan bertumpuk 2D (flat 2D stacking)
        double itemFloor = _chamberMaxY;
        for (final other in _items) {
          if (other == item || other.isGrabbed || other.isDropped) continue;
          // Jika ada item lain yang berada di bawahnya secara horizontal berdekatan
          if ((other.pixelX - item.pixelX).abs() < itemSize * 0.78 && other.pixelY > item.pixelY) {
            final double stackFloor = other.pixelY - itemSize * 0.82;
            if (stackFloor < itemFloor) {
              itemFloor = stackFloor;
            }
          }
        }

        if (item.vy.abs() > 0.05 || item.vx.abs() > 0.05 || item.pixelY < itemFloor) {
          hasActiveMovement = true;
          item.pixelX += item.vx;
          item.pixelY += item.vy;
          item.rotation += item.vRot;
          item.vy += gravity;

          // Batas Kaca Kiri (tidak boleh tembus kaca)
          if (item.pixelX < _chamberMinX) {
            item.pixelX = _chamberMinX;
            item.vx = -item.vx * 0.50; // Membal dari kaca kiri
          }
          // Batas Kaca Kanan (tidak boleh tembus kaca)
          if (item.pixelX > _chamberMaxX) {
            item.pixelX = _chamberMaxX;
            item.vx = -item.vx * 0.50; // Membal dari kaca kanan
          }
          // Batas Kaca Atas (di bawah rel capit, jangan sampai keluar mesin)
          if (item.pixelY < _chamberMinY) {
            item.pixelY = _chamberMinY;
            item.vy = 0.0;
          }
          // Batas Dasar Lantai atau Tumpukan di atas barang lain
          if (item.pixelY >= itemFloor) {
            item.pixelY = itemFloor;
            if (item.vy > 1.2) {
              item.vy = -item.vy * 0.35; // Membal di tumpukan/lantai
            } else {
              item.vy = 0.0;
            }
            // Gesekan menggelinding
            item.vx *= 0.88;
            item.vRot *= 0.85;

            if (item.vx.abs() < 0.1) item.vx = 0.0;
            if (item.vy.abs() < 0.1) item.vy = 0.0;
            if (item.vRot.abs() < 0.02) item.vRot = 0.0;
          }
        }
      }

      if (mounted) {
        setState(() {});
      }

      if (!hasActiveMovement) {
        timer.cancel();
        _physicsTimer = null;
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _highScore = prefs.getInt('claws_car_high_score') ?? 0;
        _userPoints = prefs.getInt('user_arcade_points') ?? 25000;
        _credits = prefs.getInt('claws_car_coins') ?? 5;
      });
    }

    // Sinkronisasi data skor & poin terbaru dari Supabase Database
    await ClawsCarBackend.instance.loadUserScores();
    if (mounted) {
      setState(() {
        if (ClawsCarBackend.instance.highestScore > 0) {
          _highScore = ClawsCarBackend.instance.highestScore;
        }
        if (ClawsCarBackend.instance.userPoints > 0) {
          _userPoints = ClawsCarBackend.instance.userPoints;
        }
      });
    }
  }

  // ============================================================
  // POP UP TUKAR POIN KE KOIN SAAT KOIN HABIS (PILIH YA ATAU TIDAK)
  // ============================================================
  void _showOutOfCoinsPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.8),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.monetization_on_rounded, color: Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Koin Capit Habis!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Koin capit Anda telah habis. Apakah Anda ingin menukar poin dari game Parking Challenge menjadi koin capit sekarang?',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Aturan: 10.000 Poin = 1 Koin Capit\nPoin Anda: ${_formatNumber(_userPoints)} Pts',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Tidak',
              style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showCoinConversionDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Ya, Tukar Sekarang',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showCoinConversionDialog() {
    int exchangeCoins = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final int requiredPoints = exchangeCoins * 10000;
          final bool canAfford = _userPoints >= requiredPoints;

          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF334155), width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.currency_exchange_rounded, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tukar Poin Jadi Koin Capit',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '10.000 Poin = 1 Koin Capit',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
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
                          Text('Poin Tersedia', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 14),
                              const SizedBox(width: 3),
                              Text(
                                '${_formatNumber(_userPoints)} Pts',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          Text('Koin Saat Ini', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: Color(0xFF10B981), size: 14),
                              const SizedBox(width: 3),
                              Text(
                                '$_credits Koin',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Jumlah Koin yang Ingin Ditukar:',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFE2E8F0)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: exchangeCoins > 1
                          ? () => setDialogState(() => exchangeCoins--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981)),
                      ),
                      child: Text(
                        '$exchangeCoins Koin',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: (_userPoints >= (exchangeCoins + 1) * 10000)
                          ? () => setDialogState(() => exchangeCoins++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Membutuhkan ${_formatNumber(requiredPoints)} Poin',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: canAfford ? const Color(0xFF38BDF8) : const Color(0xFFEF4444),
                  ),
                ),
                if (!canAfford) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Poin kurang ${_formatNumber(requiredPoints - _userPoints)} Pts. Kumpulkan poin di game Parking Challenge!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFFF87171)),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Tutup', style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                onPressed: canAfford
                    ? () {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);
                        setState(() {
                          _userPoints -= requiredPoints;
                          _credits += exchangeCoins;
                        });
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setInt('user_arcade_points', _userPoints);
                          prefs.setInt('claws_car_coins', _credits);
                        });
                        ClawsCarBackend.instance.exchangePointsForCoins(
                          pointsToDeduct: requiredPoints,
                          coinsToAdd: exchangeCoins,
                        );
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('🎉 Berhasil menukar $exchangeCoins koin capit!'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF334155),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Tukar Koin', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // POP UP MUNCUL DARI LUBANG BUANG DARI KECIL LALU MEMBESAR
  // BERUBAH JADI TEKS HADIAH SESUAI RULES USER + TOMBOL OKE
  // ============================================================
  Future<void> _showChuteEmergenceDialog(ClawItem? wonItem) async {
    final bool isCoin = wonItem != null && wonItem.type == ClawItemType.coin;
    int? updatedWallet;

    if (isCoin) {
      // Inject otomatis uang Rp 1.000 ke saldo user yang sedang main di Supabase
      updatedWallet = await ClawsCarBackend.instance.injectPrizeMoney(amount: 1000);
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('user_wallet_balance') ?? 0;
      if (updatedWallet == null) {
        updatedWallet = current + 1000;
        await prefs.setInt('user_wallet_balance', updatedWallet);
      }

      setState(() {
        _score += 2000;
      });
      _saveHighScoreIfBest();

      ClawsCarBackend.instance.saveGameResult(
        score: _score,
        pointsEarned: 10,
      );
    }

    if (!mounted) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Chute Emergence Prize',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 550),
      transitionBuilder: (context, anim1, anim2, child) {
        // Efek animasi: muncul dari titik lubang buang di kiri bawah (scale dari kecil membesar)
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          alignment: const Alignment(-0.55, 0.60), // Berakar dari koordinat lubang pengeluaran hadiah
          scale: curved,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isCoin ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCoin
                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                        : const Color(0xFFEF4444).withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gambar Item yang Keluar dari Lubang Buang (Coin, Ikan, Batu, atau Silang Luput)
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: isCoin
                          ? const Color(0xFF10B981).withValues(alpha: 0.18)
                          : const Color(0xFFEF4444).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCoin ? const Color(0xFF34D399) : const Color(0xFFF87171),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: wonItem != null
                          ? Image.asset(
                              wonItem.assetPath,
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.close_rounded, color: Color(0xFFF87171), size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TEKS RULES UTAMA SESUAI INSTRUKSI USER:
                  // - Jika coin: "selamat dapat 1000 rupiah"
                  // - Jika selain coin: "zonk" dan "tidak ada hadiah"
                  Text(
                    isCoin ? 'selamat dapat 1000 rupiah' : 'zonk',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isCoin ? const Color(0xFF34D399) : const Color(0xFFEF4444),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    isCoin
                        ? 'Saldo Rp 1.000 otomatis telah di-inject ke akun ParkSmart Pay Anda!'
                        : 'tidak ada hadiah',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (isCoin && updatedWallet != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Saldo Terkini: Rp ${_formatNumber(updatedWallet)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // TOMBOL OKE DI BAWAH TEKS SESUAI INSTRUKSI USER
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCoin ? const Color(0xFF10B981) : const Color(0xFF334155),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'OKE',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      if (_score > 0) {
        ClawsCarBackend.instance.saveGameResult(
          score: _score,
          pointsEarned: 0,
        );
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

  // Helper untuk menganimasikan turun & naik capit secara halus dengan kedalaman dinamis
  Future<void> _animateClawDrop(
    double target, {
    Duration? duration,
    Curve curve = Curves.easeInOutQuad,
  }) async {
    final double start = _dropProgress;
    final double distance = (target - start).abs();
    final animDuration = duration ?? Duration(milliseconds: (1400 * distance).round().clamp(350, 1400));
    _dropController.duration = animDuration;

    final tween = Tween<double>(begin: start, end: target);
    final curved = CurvedAnimation(parent: _dropController, curve: curve);
    void listener() {
      setState(() {
        _dropProgress = tween.evaluate(curved);
      });
    }

    _dropController.addListener(listener);
    _dropController.reset();
    await _dropController.forward();
    _dropController.removeListener(listener);
    curved.dispose();
    if (mounted) {
      setState(() {
        _dropProgress = target;
      });
    }
  }

  // ============================================================
  // LOGIKA AKSI CAPIT LENGKAP:
  // 1. Cek Koin (Jika habis, muncul pop-up konfirmasi tukar poin)
  // 2. Buka kuncup capit lebar
  // 3. Deteksi item kandidat di bawah capit: YANG PALING ATAS DIKENAI TERCAPIT
  //    (Hanya 1 item individu mandiri yang terangkat)
  // 4. Meluncur turun cukup sampai barang pertama (paling atas) yang didapat,
  //    TIDAK meluncur sampai mentok bawah jika ada tumpukan barang!
  // 5. Menguncup erat menjepit item
  // 6. Naik mentok ke atas membawa item
  // 7. Geser ke lubang pembuangan di sebelah kiri
  // 8. Di atas lubang, capit terbuka melepaskan item jatuh ke lubang buang
  // 9. Pintu flap berayun buka-tutup natural
  // 10. Item berkurang dari etalase mesin
  // 11. Muncul dari lubang buang dari kecil membesar jadi teks rules user + OKE
  // 12. Rel kembali ke tengah
  // ============================================================
  Future<void> _triggerClawAction() async {
    if (_isOperating) return;
    if (_credits <= 0) {
      _showOutOfCoinsPrompt();
      return;
    }

    setState(() {
      _isOperating = true;
      _credits--;
      _heldItem = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('claws_car_coins', _credits);
    HapticFeedback.heavyImpact();

    // 1. Dari posisi awal, MEMBUKA KUNCUP CAPITAN DULU
    await _animateClawPose(1.0, duration: const Duration(milliseconds: 280), curve: Curves.easeOutBack);
    HapticFeedback.lightImpact();

    // 2. Deteksi item yang tepat berada di bawah capit horizontal crane:
    final double cranePixelX = _chamberMinX + _craneX * (_chamberMaxX - _chamberMinX);
    final availableItems = _items.where((it) => !it.isGrabbed && !it.isDropped).toList();

    const double grabRadius = 34.0;
    final candidates = availableItems.where((it) {
      return (it.pixelX - cranePixelX).abs() < grabRadius;
    }).toList();

    // "saat ada 2 barang bertumpuk kan otomatis yang tercapit yang paling atas,
    // capit tidak meluncur sampai mentok bawah cukup sampai barang pertama yang didapat"
    ClawItem? targetItem;
    double targetDrop = 1.0;

    if (candidates.isNotEmpty) {
      // Sort berdasarkan pixelY terkecil (posisi vertikal paling atas / lapis teratas di layar)
      candidates.sort((a, b) => a.pixelY.compareTo(b.pixelY));
      targetItem = candidates.first;

      // Hitung kedalaman capit: berhenti tepat di barang pertama (paling atas) yang didapat!
      // Tidak meluncur sampai mentok bawah lantai jika ada barang di atasnya.
      if (_maxDropDistance > 0 && _chamberMaxY > 0) {
        final double heightAboveFloor = (_chamberMaxY - targetItem.pixelY).clamp(0.0, _maxDropDistance);
        final double targetClawDist = _maxDropDistance - heightAboveFloor;
        targetDrop = (targetClawDist / _maxDropDistance).clamp(0.20, 1.0);
      }
    }

    // 3. Meluncur TURUN ke barang dalam kondisi TERBUKA LEBAR
    // Berhenti tepat di barang pertama yang didapat (atau dasar lantai jika tidak ada barang)
    await _animateClawDrop(targetDrop, curve: Curves.easeInOutQuad);
    HapticFeedback.mediumImpact();

    if (targetItem != null) {
      targetItem.isGrabbed = true;
      _heldItem = targetItem;
    }

    // 4. Di posisi barang tersebut, capit MENGUNCUP LAGI (menjepit erat hadiah jika kena)
    await _animateClawPose(2.0, duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 160));

    // 5. Dalam kondisi MENJEPIT, capit NAIK MENTOK ke atas (kembali ke 0.0) membawa item
    await _animateClawDrop(0.0, curve: Curves.easeInOutQuad);

    // 6. Meluncur geser ke lubang pembuangan hadiah di sebelah kiri
    _chuteStartCraneX = _craneX;
    await _chuteTravelController.forward();
    _chuteTravelController.reset();
    _craneX = 0.10;

    // 7. Di atas lubang hadiah, capit TERBUKA KUNCUPNYA melepaskan hadiah
    await _animateClawPose(1.0, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    HapticFeedback.heavyImpact();

    // Item terlepas dan jatuh masuk ke rongga lubang buang
    if (targetItem != null) {
      targetItem.isGrabbed = false;
      targetItem.isDropped = true;
      // Kurangi item dari mesin etalase secara permanen untuk sesi ini
      _items.remove(targetItem);
    }

    // 8. Tutup flap lubang hadiah berayun buka-tutup natural
    _flapController.forward(from: 0.0);

    await Future.delayed(const Duration(milliseconds: 300));

    // 9. Muncul dari lubang buang dari kecil membesar dan berubah jadi teks
    if (mounted) {
      await _showChuteEmergenceDialog(targetItem);
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // 10. Rel bergerak kembali ke posisi tengah santai, dan capit kembali MENGUNCUP NORMAL
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
        _clawPose = 0.0;
        _heldItem = null;
        _isOperating = false;
      });

      // Jika koin habis, tampilkan pop up ajakan tukar poin
      if (_credits <= 0) {
        _showOutOfCoinsPrompt();
      }
    }
  }

  // ============================================================
  // JOYSTICK INTERAKSI FLEKSIBEL
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

  String _formatNumber(int n) {
    if (n == 0) return '0';
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      SoundService.stopClawsMusic();
    } else if (state == AppLifecycleState.resumed) {
      SoundService.startClawsMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SoundService.stopClawsMusic();
    _accelSub?.cancel();
    _physicsTimer?.cancel();
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
              // 1. TOP HEADER & STATUS BAR DENGAN TOMBOL KOCOK
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
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CLAWS CAR 3D',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFF472B6),
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Best: $_highScore',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Tombol Kocok HP (Sensor Shake Simulator)
                        
                        const SizedBox(width: 6),

                        // Poin dari Game Parking Challenge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 15),
                              const SizedBox(width: 3),
                              Text(
                                '${_formatNumber(_userPoints)} Pts',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Tombol Koin Capit
                        GestureDetector(
                          onTap: _showCoinConversionDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on_rounded, color: Color(0xFF10B981), size: 15),
                                const SizedBox(width: 3),
                                Text(
                                  '$_credits',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Container(
                                  padding: const EdgeInsets.all(1.5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, size: 8, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ============================================================
              // 2. VIEWPORT 3D: MESIN CAPIT DENGAN ETALASE KACA DAN ITEM REAL
              // ============================================================
              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _dropController,
                    _clawPoseController,
                    _flapAnimation,
                    _marqueeLightController,
                  ]),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ClawMachine3DScenePainter(
                        craneX: _craneX,
                        dropProgress: _dropProgress,
                        clawPose: _clawPose,
                        flapProgress: _flapAnimation.value,
                        marqueePhase: _marqueeLightController.value,
                        items: _items,
                        heldItem: _heldItem,
                        coinImage: _coinImage,
                        fishImage: _fishImage,
                        rockImage: _rockImage,
                        onBoundsCalculated: (minX, maxX, minY, maxY, maxDropDist) {
                          _chamberMinX = minX;
                          _chamberMaxX = maxX;
                          _chamberMinY = minY;
                          _chamberMaxY = maxY;
                          _maxDropDistance = maxDropDist;

                          // Inisialisasi posisi piksel awal item di dalam etalase kaca jika belum ada
                          if (!_hasInitialPositions && _items.isNotEmpty) {
                            _hasInitialPositions = true;
                            const double itemSize = 48.0;
                            for (final it in _items) {
                              it.pixelX = minX + it.normalizedX * (maxX - minX);
                              if (it.layer == 0) {
                                it.pixelY = maxY; // Tepat di lantai dasar flat 2D
                              } else {
                                it.pixelY = maxY - itemSize * 0.82; // Bertimpuk ke atas flat 2D di atas lapis 0
                              }
                            }
                          }
                        },
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),

              // ============================================================
              // 3. KONTROL JOYSTICK & TOMBOL CAPIT REALISTIS
              // ============================================================
              Container(
                height: 145,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Joystick Dudukan & Stik
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
                                Positioned(
                                  bottom: 12,
                                  child: Image.asset(
                                    'assets/images/bawahController.png',
                                    width: 118,
                                    fit: BoxFit.contain,
                                  ),
                                ),
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

                    // Tombol Merah Arcade
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
      ),
    );
  }

  // Widget Tombol Merah 3D
  Widget _buildRealisticRedArcadeButton({required bool isPressed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      curve: Curves.easeOut,
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
          ),
          child: Center(
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
                    Color(0xFFFF4D4D),
                    Color(0xFFDC2626),
                    Color(0xFF991B1B),
                    Color(0xFF580C0C),
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
// CUSTOM PAINTER: MESIN CAPIT 3D TINGGI MAKSIMAL + ITEM DALAM KACA
// ============================================================
class _ClawMachine3DScenePainter extends CustomPainter {
  final double craneX; // 0.0 to 1.0
  final double dropProgress; // 0.0 to 1.0
  final double clawPose; // 0.0 = menguncup normal, 1.0 = terbuka lebar, 2.0 = menjepit rapat
  final double flapProgress; // -0.16 s/d 1.0
  final double marqueePhase; // 0.0 to 1.0
  final List<ClawItem> items;
  final ClawItem? heldItem;
  final ui.Image? coinImage;
  final ui.Image? fishImage;
  final ui.Image? rockImage;
  final void Function(double minX, double maxX, double minY, double maxY, double maxDropDistance)? onBoundsCalculated;

  _ClawMachine3DScenePainter({
    required this.craneX,
    required this.dropProgress,
    required this.clawPose,
    required this.flapProgress,
    required this.marqueePhase,
    required this.items,
    this.heldItem,
    this.coinImage,
    this.fishImage,
    this.rockImage,
    this.onBoundsCalculated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ------------------------------------------------------------
    // A. RUANG 3D: TEMBOK BELAKANG & TEMBOK SAMPING
    // ------------------------------------------------------------
    final double horizonY = h * 0.40;

    final backWallPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
      ).createShader(Rect.fromLTRB(0, 0, w, horizonY));
    canvas.drawRect(Rect.fromLTRB(0, 0, w, horizonY), backWallPaint);

    final neonLinePaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.22)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, horizonY * 0.35), Offset(w, horizonY * 0.35), neonLinePaint);
    canvas.drawLine(Offset(0, horizonY * 0.70), Offset(w, horizonY * 0.70), neonLinePaint);

    // ------------------------------------------------------------
    // B. RUANG 3D: LANTAI PERSPEKTIF
    // ------------------------------------------------------------
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B0F19), Color(0xFF020617)],
      ).createShader(Rect.fromLTRB(0, horizonY, w, h));
    canvas.drawRect(Rect.fromLTRB(0, horizonY, w, h), floorPaint);

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
    // C. DIMENSI KOTAK 3D MESIN CAPIT
    // ------------------------------------------------------------
    final double boxW = w * 0.76;
    final double boxLeft = (w - boxW) * 0.42;
    final double boxRight = boxLeft + boxW;

    final double marqueeTop = h * 0.15;
    final double marqueeHeight = h * 0.08;
    final double glassTop = marqueeTop + marqueeHeight;

    final double glassHeight = h * 0.36; // Etalase kaca
    final double bodyTop = glassTop + glassHeight;

    final double bodyHeight = h * 0.33; // Body bawah
    final double boxBottom = bodyTop + bodyHeight;

    const double depthDx = 30.0;
    const double depthDy = -18.0;

    // Bayangan mesin di lantai
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
    // D. SISI SAMPING KEDALAMAN 3D
    // ------------------------------------------------------------
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

    final rusukPaint = Paint()
      ..color = const Color(0xFFF472B6).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(boxRight + depthDx, marqueeTop + depthDy), Offset(boxRight + depthDx, boxBottom + depthDy), rusukPaint);
    canvas.drawLine(Offset(boxRight, boxBottom), Offset(boxRight + depthDx, boxBottom + depthDy), rusukPaint);

    // ------------------------------------------------------------
    // E. ATAP ATAS 3D
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
    // F. RUANG DALAM KACA & LANTAI ETALASE
    // ------------------------------------------------------------
    final innerBackRect = Rect.fromLTRB(boxLeft + 4, glassTop + 4, boxRight - 4, bodyTop);
    final innerBackPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
      ).createShader(innerBackRect);
    canvas.drawRect(innerBackRect, innerBackPaint);

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

    // ------------------------------------------------------------
    // G. MENGGAMBAR ITEM-ITEM DI DALAM KACA (UKURAN 1.5 CM / ~48px)
    // KOIN, IKAN, DAN BATU BERTUMPUK 2 LAPIS MANDIRI
    // ------------------------------------------------------------
    const double itemSize = 48.0; // 1.5 cm di layar mobile standard (160 dpi)
    const double itemRadius = itemSize * 0.5;

    final double minChamberX = boxLeft + 16.0 + itemRadius;
    final double maxChamberX = boxRight - 16.0 - itemRadius;
    final double minChamberY = glassTop + 28.0 + itemRadius;
    final double maxChamberY = bodyTop - 6.0 - itemRadius;
    final double railY = glassTop + 14.0;
    final double maxDropDistance = (bodyTop - railY) - 46.0;

    if (onBoundsCalculated != null) {
      onBoundsCalculated!(minChamberX, maxChamberX, minChamberY, maxChamberY, maxDropDistance);
    }

    // Gambar seluruh item mandiri yang ada di dalam mesin
    // Diurutkan berdasarkan pixelY menurun agar lapis dasar (pixelY lebih besar) digambar di awal,
    // dan lapis atas yang bertimpuk ke atas (pixelY lebih kecil) digambar di atasnya tanpa sembunyi di belakang
    final renderItems = items.where((it) => !it.isGrabbed && !it.isDropped).toList();
    renderItems.sort((a, b) => b.pixelY.compareTo(a.pixelY));

    for (final item in renderItems) {
      canvas.save();
      final double ix = item.pixelX != 0.0 ? item.pixelX : (minChamberX + item.normalizedX * (maxChamberX - minChamberX));
      final double iy = item.pixelY != 0.0
          ? item.pixelY
          : (item.layer == 0 ? maxChamberY : maxChamberY - itemSize * 0.82);

      // Hanya item lapis dasar atau yang menyentuh lantai yang menampilkan bayangan lantai
      if (item.layer == 0 || (iy - maxChamberY).abs() < 6.0) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(ix, maxChamberY + itemRadius * 0.65), width: itemSize * 0.75, height: 7),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }

      canvas.translate(ix, iy);
      canvas.rotate(item.rotation);

      ui.Image? targetImg;
      if (item.type == ClawItemType.coin) targetImg = coinImage;
      if (item.type == ClawItemType.ikan) targetImg = fishImage;
      if (item.type == ClawItemType.batu) targetImg = rockImage;

      if (targetImg != null) {
        final src = Rect.fromLTWH(0, 0, targetImg.width.toDouble(), targetImg.height.toDouble());
        final dst = Rect.fromCenter(center: Offset.zero, width: itemSize, height: itemSize);
        canvas.drawImageRect(targetImg, src, dst, Paint()..filterQuality = FilterQuality.medium);
      } else {
        // Fallback drawing jika image decoding asinkron sedang berlangsung
        final circlePaint = Paint()
          ..color = item.type == ClawItemType.coin
              ? const Color(0xFFFBBF24)
              : (item.type == ClawItemType.ikan ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8));
        canvas.drawCircle(Offset.zero, itemRadius, circlePaint);
      }
      canvas.restore();
    }

    // ------------------------------------------------------------
    // H. MEKANISME PENGGERAK CAPIT & REL ATAS
    // ------------------------------------------------------------
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

    final double cranePixelX = boxLeft + 28.0 + craneX * (boxW - 56.0);
    final trolleyRect = Rect.fromCenter(center: Offset(cranePixelX, railY), width: 34, height: 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(trolleyRect, const Radius.circular(4)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFCBD5E1), Color(0xFF475569)],
        ).createShader(trolleyRect),
    );

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

    // JIKA ADA ITEM YANG SEDANG DICAPIT: GAMBAR DI UJUNG CAPITAN
    if (heldItem != null && heldItem!.isGrabbed) {
      canvas.save();
      final double hx = cranePixelX;
      final double hy = clawCurrentY + 22.0;
      canvas.translate(hx, hy);
      canvas.rotate(heldItem!.rotation);

      ui.Image? targetImg;
      if (heldItem!.type == ClawItemType.coin) targetImg = coinImage;
      if (heldItem!.type == ClawItemType.ikan) targetImg = fishImage;
      if (heldItem!.type == ClawItemType.batu) targetImg = rockImage;

      if (targetImg != null) {
        final src = Rect.fromLTWH(0, 0, targetImg.width.toDouble(), targetImg.height.toDouble());
        final dst = Rect.fromCenter(center: Offset.zero, width: itemSize, height: itemSize);
        canvas.drawImageRect(targetImg, src, dst, Paint()..filterQuality = FilterQuality.medium);
      }
      canvas.restore();
    }

    // ------------------------------------------------------------
    // ANIMASI CAPIT BESI
    // ------------------------------------------------------------
    double angleLeft;
    double angleRight;
    double angleCenter;

    if (clawPose <= 1.0) {
      final double t = clawPose.clamp(0.0, 1.0);
      angleLeft = 0.14 + t * 0.48;
      angleRight = -0.14 - t * 0.48;
      angleCenter = t * 0.18;
    } else {
      final double t = (clawPose - 1.0).clamp(0.0, 1.0);
      angleLeft = 0.62 - t * 0.61;
      angleRight = -0.62 + t * 0.61;
      angleCenter = 0.18 * (1.0 - t);
    }

    final bool isOpen = clawPose > 0.4 && clawPose < 1.6;
    _drawWideSteelProng(canvas, Offset(cranePixelX - 7, clawCurrentY + 14), angleLeft, isLeft: true, isOpen: isOpen);
    _drawWideSteelProng(canvas, Offset(cranePixelX + 7, clawCurrentY + 14), angleRight, isLeft: false, isOpen: isOpen);
    _drawWideSteelProng(canvas, Offset(cranePixelX, clawCurrentY + 16), angleCenter, isCenter: true, isOpen: isOpen);

    // ------------------------------------------------------------
    // I. KACA DEPAN DENGAN EFEK PANTULAN GLASS (SPECULAR GLARE)
    // Menjadikan item berada secara realistis DI DALAM KACA
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
    // J. ATAP / MARQUEE DEPAN DENGAN TEKS & LAMPU BERKEDIP
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
    // K. BODY BAWAH 3D & KONSOL KONTROL
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

    // Detail konsol kontrol
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
    // L. LUBANG PENGELUARAN HADIAH 3D DENGAN PINTU FLAP BERAYUN
    // ------------------------------------------------------------
    final double chuteW = boxW * 0.34;
    final double chuteH = 50.0;
    final double chuteX = boxLeft + 16.0;
    final double chuteY = boxBottom - chuteH - 14.0;

    final chuteRect = Rect.fromLTWH(chuteX, chuteY, chuteW, chuteH);

    canvas.drawRRect(
      RRect.fromRectAndRadius(chuteRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ).createShader(chuteRect),
    );

    final innerChuteRect = Rect.fromLTWH(chuteX + 4, chuteY + 4, chuteW - 8, chuteH - 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerChuteRect, const Radius.circular(6)),
      Paint()..color = Colors.black,
    );

    // Pintu flap logam berayun 3D
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
    canvas.drawPath(
      flapPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(chuteRect, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

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

    final double upperDx = isLeft ? -7 : (isCenter ? 0 : 7);
    prongPath.lineTo(upperDx, 16);

    final double curveDx = isLeft ? -14 : (isCenter ? 0 : 14);
    final double tipDx = isLeft ? 2 : (isCenter ? 0 : -2);
    prongPath.quadraticBezierTo(curveDx, 32, tipDx, 36);

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
    return true; // Repaint selalu aktif untuk mendukung fisika dan animasi capit
  }
}
