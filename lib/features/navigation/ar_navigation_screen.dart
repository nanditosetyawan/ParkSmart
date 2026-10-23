import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ArNavigationScreen extends StatefulWidget {
  final Map<String, dynamic>? destinationParking;
  final LatLng? userPosition;

  const ArNavigationScreen({
    super.key,
    this.destinationParking,
    this.userPosition,
  });

  @override
  State<ArNavigationScreen> createState() => _ArNavigationScreenState();
}

class _ArNavigationScreenState extends State<ArNavigationScreen> {
  final MapController _mapController = MapController();

  LatLng _userPos = const LatLng(-6.1774, 106.7907);
  LatLng _destPos = const LatLng(-6.1788, 106.7916);
  String _destName = '';
  String _destType = '';

  // Rute Jalan Asli OSRM (100% Gratis & Open Source)
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = true;
  double _totalDistanceMeters = 0.0;
  int _totalDurationSeconds = 0;

  // Turn-by-Turn Maneuvers
  List<Map<String, dynamic>> _steps = [];
  int _currentStepIndex = 0;
  bool _isMuted = false;

  DateTime? _lastRerouteTime;
  bool _isGpsLocked = false;
  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();

    if (widget.destinationParking == null) {
      _isLoadingRoute = false;
      return;
    }

    // 1. Tentukan Titik Tujuan Parkir
    final pData = widget.destinationParking!;
    if (pData['point'] is LatLng) {
      _destPos = pData['point'] as LatLng;
    }
    _destName = (pData['name'] ?? 'Tujuan Parkir').toString();
    _destType = (pData['type'] ?? 'Area Parkir').toString();

    // 2. Tentukan Titik Awal Pengguna
    if (widget.userPosition != null) {
      _userPos = widget.userPosition!;
      _isGpsLocked = true;
    } else {
      // Default awal berada di sekitar tujuan parkir (bukan koordinat asal-asalan Jakarta)
      _userPos = _destPos;
    }

    // 3. Ambil GPS riil dan rute jalan raya OSRM
    _initRealGpsAndRoute();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// Inisialisasi posisi GPS pengguna secara riil dan hitung rute tercepat
  Future<void> _initRealGpsAndRoute() async {
    setState(() => _isLoadingRoute = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
        _userPos = LatLng(pos.latitude, pos.longitude);
        _isGpsLocked = true;
      }
    } catch (e) {
      debugPrint('[ArNavigation] GPS init error: $e');
    }

    // Ambil rute jalan raya OSRM dari posisi GPS riil
    await _fetchRoadRoute();

    // Pusatkan peta ke posisi GPS pengguna
    _centerOnUser();

    // Dengarkan pergerakan GPS pengguna secara real-time
    _startLocationTracking();
  }

  void _startLocationTracking() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((pos) {
      if (!mounted) return;
      final newPos = LatLng(pos.latitude, pos.longitude);
      _onUserMoved(newPos);
    });
  }

  /// Fungsi saat posisi GPS pengguna bergerak atau posisi GPS riil terdeteksi
  void _onUserMoved(LatLng newPos) {
    if (!mounted) return;

    setState(() {
      _userPos = newPos;
      _isGpsLocked = true;

      // Pangkas garis penunjuk rute mengikuti pergerakan pengguna ke tujuan
      if (_routePoints.length > 1) {
        int closestIdx = 0;
        double minDistance = double.infinity;
        const distCalc = Distance();

        for (int i = 0; i < _routePoints.length; i++) {
          final d = distCalc.as(LengthUnit.Meter, newPos, _routePoints[i]);
          if (d < minDistance) {
            minDistance = d;
            closestIdx = i;
          }
        }

        // Jika jarak ke rute terdekat > 50m (misal baru dapat lock GPS riil dari lokasi awal yang rancu atau belok keluar rute),
        // otomatis hitung ulang rute jalan tercepat dari posisi baru pengguna
        if (minDistance > 50) {
          final now = DateTime.now();
          if (_lastRerouteTime == null || now.difference(_lastRerouteTime!).inSeconds >= 3) {
            _lastRerouteTime = now;
            _fetchRoadRoute();
          }
        } else if (closestIdx > 0) {
          _routePoints = [newPos, ..._routePoints.sublist(closestIdx)];
        } else if (_routePoints.isNotEmpty) {
          _routePoints[0] = newPos;
        }

        // Hitung ulang sisa jarak & waktu secara real-time
        double remainingMeters = 0.0;
        for (int i = 0; i < _routePoints.length - 1; i++) {
          remainingMeters +=
              distCalc.as(LengthUnit.Meter, _routePoints[i], _routePoints[i + 1]);
        }
        _totalDistanceMeters = remainingMeters;
        _totalDurationSeconds =
            ((remainingMeters / 1000) / 25 * 3600).round();
      } else if (!_isLoadingRoute) {
        _fetchRoadRoute();
      }

      // Cek kemajuan belokan
      _checkStepProgress(newPos);
    });

    // Kamera peta otomatis mengikuti pergerakan GPS pengguna
    try {
      _mapController.move(newPos, _mapController.camera.zoom);
    } catch (_) {}
  }

  /// Ambil rute jalan raya asli (OSRM Routing Machine - 100% Gratis & Open Source)
  Future<void> _fetchRoadRoute() async {
    setState(() => _isLoadingRoute = true);

    final distanceMeters =
        const Distance().as(LengthUnit.Meter, _userPos, _destPos);
    // Jika rute jarak jauh (> 30 km), matikan parameter steps agar payload ringan (<200KB) dan respons dalam 1-2 detik
    final withSteps = distanceMeters < 30000;

    final endpoints = [
      'https://router.project-osrm.org/route/v1/driving/'
          '${_userPos.longitude},${_userPos.latitude};${_destPos.longitude},${_destPos.latitude}'
          '?overview=full&geometries=geojson${withSteps ? '&steps=true' : ''}',
      'https://routing.openstreetmap.de/routed-car/route/v1/driving/'
          '${_userPos.longitude},${_userPos.latitude};${_destPos.longitude},${_destPos.latitude}'
          '?overview=full&geometries=geojson${withSteps ? '&steps=true' : ''}',
    ];

    for (final ep in endpoints) {
      try {
        final url = Uri.parse(ep);
        final response = await http
            .get(url, headers: {'User-Agent': 'SmartParking/1.0'})
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final routes = data['routes'] as List<dynamic>?;

          if (routes != null && routes.isNotEmpty) {
            final firstRoute = routes[0];
            _totalDistanceMeters =
                (firstRoute['distance'] as num?)?.toDouble() ?? distanceMeters.toDouble();
            _totalDurationSeconds =
                (firstRoute['duration'] as num?)?.toInt() ?? 240;

            // Ekstrak polyline koordinat jalan raya asli yang meliuk-liuk
            final coords =
                firstRoute['geometry']['coordinates'] as List<dynamic>?;
            if (coords != null && coords.isNotEmpty) {
              _routePoints = coords
                  .map((c) => LatLng(
                        (c[1] as num).toDouble(),
                        (c[0] as num).toDouble(),
                      ))
                  .toList();
            }

            // Ekstrak panduan belokan (maneuver steps)
            _steps = [];
            final legs = firstRoute['legs'] as List<dynamic>?;
            if (legs != null && legs.isNotEmpty) {
              final rawSteps = legs[0]['steps'] as List<dynamic>? ?? [];
              _steps = rawSteps.map((s) {
                final maneuver = s['maneuver'] as Map<String, dynamic>? ?? {};
                final location = maneuver['location'] as List<dynamic>?;
                return {
                  'type': (maneuver['type'] ?? '').toString(),
                  'modifier': (maneuver['modifier'] ?? '').toString(),
                  'name': (s['name'] ?? '').toString(),
                  'distance': (s['distance'] as num?)?.toDouble() ?? 0.0,
                  'location': location != null && location.length >= 2
                      ? LatLng((location[1] as num).toDouble(),
                          (location[0] as num).toDouble())
                      : null,
                };
              }).toList();
            }

            // Jika rute jarak jauh tanpa steps, buat panduan awal jalan yang realistis
            if (_steps.isEmpty && _routePoints.length >= 2) {
              _steps = [
                {
                  'type': 'depart',
                  'modifier': 'straight',
                  'name': 'Ikuti Rute Tercepat Jalan Raya',
                  'distance': 250.0,
                  'location': _routePoints[math.min(1, _routePoints.length - 1)],
                },
                {
                  'type': 'arrive',
                  'modifier': '',
                  'name': _destName,
                  'distance': 0.0,
                  'location': _destPos,
                },
              ];
            }

            if (mounted) {
              setState(() {
                _isLoadingRoute = false;
              });
              // Posisi kamera TETAP di titik GPS pengguna
              _centerOnUser();
            }
            return; // Berhasil!
          }
        }
      } catch (e) {
        continue; // Coba server berikutnya
      }
    }

    // Fallback darurat: jika server routing publik OSRM timeout / terkendala koneksi,
    // buat jalur penghubung langsung agar garis rute biru TIDAK HILANG dari peta
    if (_routePoints.isEmpty) {
      final fallbackDistance = const Distance().as(LengthUnit.Meter, _userPos, _destPos);
      _routePoints = [_userPos, _destPos];
      _totalDistanceMeters = fallbackDistance;
      _totalDurationSeconds = ((fallbackDistance / 1000) / 25 * 3600).round();
      _steps = [
        {
          'type': 'depart',
          'modifier': 'straight',
          'name': 'Arahkan ke $_destName',
          'distance': fallbackDistance,
          'location': _destPos,
        },
        {
          'type': 'arrive',
          'modifier': '',
          'name': _destName,
          'distance': 0.0,
          'location': _destPos,
        },
      ];
    }

    if (mounted) {
      setState(() {
        _isLoadingRoute = false;
      });
      _centerOnUser();
    }
  }

  /// Memperbarui posisi GPS riil dan menghitung ulang rute jalan tercepat
  Future<void> _refreshGpsAndRoute() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('Memperbarui GPS & menghitung rute tercepat...'.tr),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        if (mounted) {
          setState(() {
            _userPos = LatLng(pos.latitude, pos.longitude);
            _isGpsLocked = true;
          });
        }
      }
    } catch (e) {
      debugPrint('[ArNavigation] Manual refresh GPS error: $e');
    }

    await _fetchRoadRoute();
    _centerOnUser();
  }

  /// Peta TETAP berada di posisi GPS pengguna
  void _centerOnUser() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _mapController.move(_userPos, 16.5);
      } catch (_) {}
    });
  }

  /// Cek kemajuan manuver belokan pengguna saat berpindah posisi
  void _checkStepProgress(LatLng current) {
    if (_steps.isEmpty || _currentStepIndex >= _steps.length - 1) return;

    final targetPoint = _steps[_currentStepIndex]['location'] as LatLng?;
    if (targetPoint != null) {
      final distToNextTurn =
          const Distance().as(LengthUnit.Meter, current, targetPoint);
      if (distToNextTurn < 25 && _currentStepIndex < _steps.length - 1) {
        _currentStepIndex++;
      }
    }
  }

  // Format Jarak (contoh: '1.2 km' atau '450m')
  String get _formattedDistance {
    if (_totalDistanceMeters >= 1000) {
      return '${(_totalDistanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${_totalDistanceMeters.round()} m';
  }

  // Format Waktu Tempuh (contoh: '4 mnt' atau '6 jam 28 mnt')
  String get _formattedDuration {
    final totalMinutes = (_totalDurationSeconds / 60).round();
    if (totalMinutes <= 0) return '1 mnt';
    if (totalMinutes < 60) return '$totalMinutes mnt';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (mins == 0) return '$hours jam';
    return '$hours jam $mins mnt';
  }

  // Format Jam Tiba Real-Time (menambahkan waktu yang dibutuhkan ke jam saat ini)
  String get _formattedArrivalTime {
    if (_isLoadingRoute) return '--:-- WIB';
    final arrival =
        DateTime.now().add(Duration(seconds: _totalDurationSeconds));
    final hourStr = arrival.hour.toString().padLeft(2, '0');
    final minStr = arrival.minute.toString().padLeft(2, '0');
    return '$hourStr:$minStr WIB';
  }

  // Ambil instruksi belokan saat ini
  Map<String, dynamic> get _currentManeuver {
    if (_steps.isEmpty) {
      return {
        'icon': Icons.turn_left,
        'title': '50m Belok Kiri'.tr,
        'subtitle': 'Pintu Masuk Barat Basement'.tr,
      };
    }

    final cur = _steps[_currentStepIndex];
    final mod = (cur['modifier'] ?? '').toString();
    final type = (cur['type'] ?? '').toString();
    final dist = (cur['distance'] as num?)?.toDouble() ?? 50.0;
    final road = (cur['name'] ?? '').toString().trim();

    IconData icon = Icons.turn_left;
    String turnText = 'Belok Kiri'.tr;

    if (type == 'arrive') {
      icon = Icons.flag_rounded;
      turnText = 'Tiba di Lokasi Tujuan'.tr;
    } else if (mod.contains('right')) {
      icon = Icons.turn_right;
      turnText = 'Belok Kanan'.tr;
    } else if (mod.contains('left')) {
      icon = Icons.turn_left;
      turnText = 'Belok Kiri'.tr;
    } else if (mod.contains('straight') || type == 'depart') {
      icon = Icons.straight;
      turnText = 'Lurus Terus'.tr;
    } else if (type.contains('roundabout')) {
      icon = Icons.rotate_right_rounded;
      turnText = 'Masuk Bundaran'.tr;
    }

    final distPrefix = dist > 0 ? '${dist.round()}m ' : '';

    return {
      'icon': icon,
      'title': '$distPrefix$turnText',
      'subtitle': road.isNotEmpty ? road : '${'Menuju'.tr} $_destName',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        if (widget.destinationParking == null) {
          return Scaffold(
            backgroundColor: isDark ? theme.bg : const Color(0xFFF6F3EC),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Navigasi Panduan Rute'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF1EEE7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.navigation_outlined,
                        size: 64,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tujuan Parkir Belum Dipilih'.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan pilih tempat parkir tujuan dari peta atau beranda terlebih dahulu untuk memulai panduan rute turn-by-turn.'.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text('Pilih Tempat Parkir'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF020304),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final maneuver = _currentManeuver;

        return Scaffold(
      backgroundColor: isDark ? theme.bg : const Color(0xFFF6F3EC),
      body: Stack(
        children: [
          // ─── 1. PETA FLUTTER MAP ASLI ────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userPos,
                initialZoom: 16.5,
                minZoom: 4.0,
                maxZoom: 19.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Base Tile Layer OpenStreetMap (100% Gratis & Realistis)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileBuilder: isDark ? darkModeTileBuilder : null,
                  userAgentPackageName: 'com.smartparking.app',
                ),

                // Polyline Jalur Rute Asli Jalan Raya (Google Maps Style)
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      // Casing / Bayangan Jalur Luar
                      Polyline(
                        points: _routePoints,
                        color: const Color(0xFF1558B0).withValues(alpha: 0.8),
                        strokeWidth: 8.5,
                      ),
                      // Garis Inti Rute Biru Terang
                      Polyline(
                        points: _routePoints,
                        color: const Color(0xFF1A73E8),
                        strokeWidth: 5.5,
                      ),
                    ],
                  ),

                // Marker Posisi Pengguna & Tujuan Parkir
                MarkerLayer(
                  markers: [
                    // Marker Tujuan Parkir
                    Marker(
                      point: _destPos,
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA4335),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_parking_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Marker Pengguna (GPS Puck & Aura Biru)
                    Marker(
                      point: _userPos,
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Aura Biru Akurasi
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8).withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Puck Utama
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.navigation, color: Colors.white, size: 12),
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

          // Loading bar saat mengambil rute
          if (_isLoadingRoute)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
              ),
            ),

          // ─── 2. FLOATING OVERLAYS UI ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ─── Top Turn-by-Turn Card ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black12,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Tombol Kembali
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: isDark ? theme.chipBg : const Color(0xFF1C1D1F),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              maneuver['icon'] as IconData,
                              color: isDark ? theme.textPrimary : Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Teks Panduan Belokan
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (maneuver['title'] as String).tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                (maneuver['subtitle'] as String).tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: theme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Tombol Suara (Mute / Unmute)
                        GestureDetector(
                          onTap: () {
                            setState(() => _isMuted = !_isMuted);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isMuted
                                    ? 'Panduan suara dinonaktifkan'.tr
                                    : 'Panduan suara diaktifkan'.tr),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isMuted
                                  ? (isDark
                                      ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                                      : const Color(0xFFFCE8E6))
                                  : (isDark ? theme.chipBg : const Color(0xFFF1EEE7)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              size: 20,
                              color: _isMuted
                                  ? const Color(0xFFF87171)
                                  : (isDark ? theme.iconColor : const Color(0xFF45474A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Route HUD Pills (Dapat Digeser + Efek Luntur di Tepi Kiri & Kanan Tanpa Margin Negatif) ──
                SizedBox(
                  height: 40,
                  child: ShaderMask(
                    shaderCallback: (Rect rect) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.05, 0.95, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pill 1: Rute Tercepat
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? theme.card : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isDark ? Border.all(color: theme.border) : null,
                              boxShadow: [
                                BoxShadow(
                                    color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black12,
                                    blurRadius: 6),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.navigation_rounded,
                                  size: 14,
                                  color: _isGpsLocked ? const Color(0xFF10B981) : (isDark ? const Color(0xFFF87171) : const Color(0xFF9A442D)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isGpsLocked ? 'GPS Terkunci'.tr : 'Mencari GPS...'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Pill 2: Estimasi Durasi & Jarak
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF262C36) : const Color(0xFF1C1D1F),
                              borderRadius: BorderRadius.circular(20),
                              border: isDark ? Border.all(color: theme.border) : null,
                              boxShadow: [
                                BoxShadow(
                                    color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black12,
                                    blurRadius: 6),
                              ],
                            ),
                            child: Text(
                              _isLoadingRoute
                                  ? 'Menghitung rute...'
                                  : '$_formattedDuration • $_formattedDistance',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Pill 3: Estimasi Jam Tiba Real-Time (+ waktu perjalanan)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? theme.card : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isDark ? Border.all(color: theme.border) : null,
                              boxShadow: [
                                BoxShadow(
                                    color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black12,
                                    blurRadius: 6),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 13,
                                  color: Color(0xFF1A73E8),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _formattedArrivalTime,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
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

                const Spacer(),

                // ─── Bottom Floating Controls & Destination Card ─────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Floating Aksi: Refresh Rute & My Location GPS
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Tombol Hitung Ulang Rute Tercepat
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: isDark ? theme.card : Colors.white,
                                shape: BoxShape.circle,
                                border: isDark ? Border.all(color: theme.border) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                tooltip: 'Hitung Ulang Rute Tercepat'.tr,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Color(0xFF1A73E8),
                                  size: 22,
                                ),
                                onPressed: _refreshGpsAndRoute,
                              ),
                            ),
                            // 2. Tombol Pusatkan GPS & Perbarui Posisi
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? theme.card : Colors.white,
                                shape: BoxShape.circle,
                                border: isDark ? Border.all(color: theme.border) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                tooltip: 'Pusatkan ke Posisi GPS Anda',
                                icon: Icon(
                                  Icons.my_location,
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1C1D1F),
                                  size: 22,
                                ),
                                onPressed: _refreshGpsAndRoute,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bottom Destination Card (Ramping & Proporsional)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? theme.card : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: isDark ? Border.all(color: theme.border) : null,
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black12,
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Baris Judul Tempat Parkir
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _destName,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: theme.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.verified,
                                            size: 18,
                                            color: Color(0xFF1A73E8),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$_destType • Rute Navigasi Aktif',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: theme.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Baris Aksi: Titik Tiga + Tiba di Lokasi
                            Row(
                              children: [
                                // Tombol Titik Tiga (Opsi Lainnya)
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isDark ? theme.chipBg : const Color(0xFFF1EEE7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.more_horiz,
                                      color: isDark ? theme.iconColor : const Color(0xFF1C1D1F),
                                    ),
                                    onPressed: () {
                                      _showNavigationOptions(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Tombol Utama 'Tiba di Lokasi'
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                const Color(0xFF1E8E3E),
                                            content: Row(
                                              children: [
                                                const Icon(Icons.check_circle,
                                                    color: Colors.white),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                      'Berhasil tiba di $_destName!'.tr),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                        foregroundColor: isDark ? Colors.black : Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Tiba di Lokasi'.tr,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.black : Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.check_circle,
                                            color: isDark ? Colors.black : Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
    );
      },
    );
  }

  void _showNavigationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
          builder: (ctx, _) {
            final theme = ThemeService.instance;
            final isDark = theme.isDarkMode;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? theme.card : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: isDark ? Border.all(color: theme.border) : null,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Opsi Navigasi'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: const Icon(Icons.refresh_rounded,
                            color: Color(0xFF1A73E8)),
                        title: Text(
                          'Hitung Ulang Rute Tercepat'.tr,
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _refreshGpsAndRoute();
                        },
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Icon(
                          Icons.my_location,
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF1C1D1F),
                        ),
                        title: Text(
                          'Pusatkan ke Posisi GPS'.tr,
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _refreshGpsAndRoute();
                        },
                      ),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: const Icon(Icons.close_rounded,
                            color: Color(0xFFEA4335)),
                        title: Text(
                          'Hentikan Navigasi'.tr,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFEA4335),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
