import 'dart:ui' as ui;
import 'package:flutter/services.dart';
// PS-03 Home — Reconstructed from actual Stitch HTML
// bg: #F6F3EC | Dark floating dock nav: #1C1D1F rounded-[32px]
// Map: SVG vector roads on #ECE8E0 bg, not a real map
// Greeting: text-[34px] font-extrabold
// Active booking card: rounded-[32px] bg-white

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../notification/notification_screen.dart';
import '../session/active_session_screen.dart' as active;
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import '../../widgets/bottom_dock_navigation.dart';
import '../sitemap_screen.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/maintenance_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../map/explore_map_screen.dart';
import '../profile/backend/vehicle_backend.dart';
import '../game/game_lobby_screen.dart' as game;
import 'backend/home_backend.dart';
import '../../core/services/session_service.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/language_service.dart';
import '../../core/services/app_image_cache_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  LatLng? _currentPosition;
  double _heading = 0.0; // Derajat arah hadap kompas & GPS (0 - 360)
  bool _isGpsActive = false;
  String _locationName = 'GPS tidak aktif';
  bool _showLocationOverlay = false;
  DateTime? _pressStartTime;

  Map<String, String> _locationDetails = {
    'jalan': 'Jl. Ring Road Utara No. 18, RT 02 / RW 10',
    'kelurahan': 'Condongcatur',
    'kecamatan': 'Depok',
    'kota': 'Kabupaten Sleman',
    'provinsi': 'Daerah Istimewa Yogyakarta',
    'kodePos': '55281',
  };

  Future<void> _fetchLocationName(Position pos) async {
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        
        // 1. Ekstrak nama Kelurahan / Desa saja untuk pil titik hijau
        String kelurahan = (p.subLocality != null && p.subLocality!.trim().isNotEmpty)
            ? p.subLocality!.trim()
            : ((p.locality != null && p.locality!.trim().isNotEmpty) ? p.locality!.trim() : 'Condongcatur');

        final lowerKel = kelurahan.toLowerCase();
        if (lowerKel.startsWith('kelurahan ')) {
          kelurahan = kelurahan.substring(10).trim();
        } else if (lowerKel.startsWith('kel. ')) {
          kelurahan = kelurahan.substring(5).trim();
        } else if (lowerKel.startsWith('desa ')) {
          kelurahan = kelurahan.substring(5).trim();
        }

        // 2. Ekstrak data lengkap untuk pop-up mengambang
        String jalan = (p.street != null && p.street!.trim().isNotEmpty)
            ? p.street!.trim()
            : ((p.thoroughfare != null && p.thoroughfare!.trim().isNotEmpty) ? p.thoroughfare!.trim() : 'Jl. Ring Road Utara');
        if (p.subThoroughfare != null && p.subThoroughfare!.trim().isNotEmpty && !jalan.contains(p.subThoroughfare!.trim())) {
          jalan = '$jalan No. ${p.subThoroughfare!.trim()}';
        }

        String kecamatan = (p.locality != null && p.locality!.trim().isNotEmpty)
            ? p.locality!.trim()
            : 'Depok';

        String kota = (p.subAdministrativeArea != null && p.subAdministrativeArea!.trim().isNotEmpty)
            ? p.subAdministrativeArea!.trim()
            : 'Kabupaten Sleman';

        String provinsi = (p.administrativeArea != null && p.administrativeArea!.trim().isNotEmpty)
            ? p.administrativeArea!.trim()
            : 'Daerah Istimewa Yogyakarta';

        String kodePos = (p.postalCode != null && p.postalCode!.trim().isNotEmpty)
            ? p.postalCode!.trim()
            : '55281';

        if (mounted) {
          setState(() {
            _locationName = kelurahan;
            _locationDetails = {
              'jalan': jalan,
              'kelurahan': kelurahan,
              'kecamatan': kecamatan,
              'kota': kota,
              'provinsi': provinsi,
              'kodePos': kodePos,
            };
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationName = 'Condongcatur';
          _locationDetails = {
            'jalan': 'Jl. Ring Road Utara No. 18, RT 02 / RW 10',
            'kelurahan': 'Condongcatur',
            'kecamatan': 'Depok',
            'kota': 'Kabupaten Sleman',
            'provinsi': 'Daerah Istimewa Yogyakarta',
            'kodePos': '55281',
          };
        });
      }
    }
  }

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  Timer? _sessionPollTimer;

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Daftarkan listener perubahan status maintenance & bahasa
    LanguageService.instance.addListener(_onLanguageChanged);
    MaintenanceService.instance.addListener(_onMaintenanceChanged);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // Langsung minta akses GPS saat membuka aplikasi agar posisi map relevan
    _initGpsAndOrientation();
    // Ambil data backend Supabase
    HomeBackend.instance.loadHomeData();

    // Polling aktif sesi setiap 6 detik agar jika di-force-out admin / checkout langsung sinkron
    _sessionPollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) {
        HomeBackend.instance.refreshActiveSessions();
      }
    });

    // Periksa status pemeliharaan saat layar pertama kali dipasang (khusus akun pengguna)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (SessionService.instance.isAdmin) return;
      final m = MaintenanceService.instance;
      if (m.isGlobalMaintenance) {
        if (!m.isWarningOnly) {
          MaintenanceService.showGlobalMaintenanceDialog(context);
        } else {
          MaintenanceService.showWarningDialog(context);
        }
      }
    });
  }

  void _onMaintenanceChanged() {
    if (!mounted) return;
    if (SessionService.instance.isAdmin) return;
    final m = MaintenanceService.instance;
    if (m.isGlobalMaintenance && !m.isWarningOnly && !m.isGlobalDialogOpen) {
      MaintenanceService.showGlobalMaintenanceDialog(context);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    LanguageService.instance.removeListener(_onLanguageChanged);
    MaintenanceService.instance.removeListener(_onMaintenanceChanged);
    _sessionPollTimer?.cancel();
    _positionSub?.cancel();
    _magSub?.cancel();
    super.dispose();
  }

  // Traffic / Kepadatan Lalu Lintas Real-Time (100% Gratis & Dinamis)
  int get _trafficDensity {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final isWeekend = now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    if (isWeekend) {
      if (hour >= 11 && hour <= 21) {
        return 72 + ((hour + minute) % 18);
      } else if (hour >= 22 || hour <= 6) {
        return 18 + (minute % 10);
      } else {
        return 42 + (minute % 15);
      }
    } else {
      if ((hour == 7 && minute >= 30) || hour == 8 || (hour == 9 && minute <= 15)) {
        return 86 + ((hour + minute) % 14); // Puncak pagi: 86% - 99% (Macet)
      } else if (hour >= 15 && hour <= 19) {
        return 88 + ((hour + minute) % 13); // Puncak sore/pulang kantor: 88% - 100% (Macet)
      } else if (hour >= 11 && hour <= 13) {
        return 56 + (minute % 16); // Siang: 56% - 71% (Ramai)
      } else if (hour >= 22 || hour <= 5) {
        return 14 + (minute % 12); // Malam: 14% - 25% (Lancar)
      } else {
        return 40 + (minute % 15); // Normal: 40% - 54% (Lancar)
      }
    }
  }

  String get _trafficBadgeText {
    final density = _trafficDensity;
    if (density >= 80) return 'Macet'.tr;
    if (density >= 50) return 'Ramai'.tr;
    return 'Lancar'.tr;
  }

  Color get _trafficStatusColor {
    final density = _trafficDensity;
    if (density >= 80) return const Color(0xFFEA4335); // Merah Macet
    if (density >= 50) return const Color(0xFFFBBC04); // Kuning/Oranye Ramai
    return const Color(0xFF34A853); // Hijau Lancar
  }

  String get _trafficAreaText {
    final density = _trafficDensity;
    if (density >= 95) return 'Macet Total ($density%)'.tr;
    if (density >= 80) return 'Macet Padat ($density%)'.tr;
    if (density >= 65) return 'Padat Merayap ($density%)'.tr;
    if (density >= 45) return 'Ramai Lancar ($density%)'.tr;
    return 'Tersedia Lengang ($density%)'.tr;
  }

  /// Tarik ke bawah (Pull to Refresh) untuk me-reload data parkir & GPS
  Future<void> _refreshGpsLocation() async {
    // Muat ulang data parkir Supabase agar lokasi baru langsung tampil di homescreen
    try {
      await HomeBackend.instance.loadHomeData();
    } catch (_) {}

    try {
      // 1. Cek Service Enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!kIsWeb && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan GPS perangkat belum aktif. Silakan nyalakan GPS di HP Anda.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 2. Minta izin akses lokasi jika belum diberikan
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin akses lokasi belum diizinkan.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 3. Ambil posisi GPS terbaru dengan akurasi tinggi
      Position? freshPos;
      try {
        freshPos = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
            timeLimit: const Duration(seconds: 8),
          ),
        );
      } catch (_) {
        freshPos = await Geolocator.getLastKnownPosition();
      }

      if (freshPos != null && mounted) {
        final userLatLng = LatLng(freshPos.latitude, freshPos.longitude);
        setState(() {
          _isGpsActive = true;
          _currentPosition = userLatLng;
          if (freshPos!.heading >= 0 && freshPos.heading <= 360) {
            _heading = freshPos.heading;
          }
        });

        // Pindahkan mini map di home ke posisi user yang baru
        try {
          _mapController.move(userLatLng, 16.0);
        } catch (_) {}

        // Ambil nama wilayah/alamat
        await _fetchLocationName(freshPos);

        // Restart GPS streaming
        await _initGpsAndOrientation();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E8E3E),
              duration: const Duration(seconds: 2),
              content: Row(
                children: [
                  const Icon(Icons.gps_fixed, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('GPS Terhubung: $_locationName'),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui GPS: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _initGpsAndOrientation() async {
    try {
      // 1. Cek Service Enabled khusus di Mobile
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Jika GPS dimatikan di perangkat: posisi default random / central park dan tanpa panah navigator
          return;
        }
      }

      // 2. Langsung minta akses GPS saat membuka aplikasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Jika izin ditolak: posisi default random dan tanpa panah navigator
        return;
      }

      // 3. Ambil posisi GPS pengguna terkini dengan akurasi tinggi
      Position? initialPos;
      try {
        initialPos = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
            timeLimit: const Duration(seconds: 6),
          ),
        );
      } catch (_) {
        initialPos = await Geolocator.getLastKnownPosition();
      }

      if (initialPos != null && mounted) {
        final userLatLng = LatLng(initialPos.latitude, initialPos.longitude);
        setState(() {
          _isGpsActive = true;
          _currentPosition = userLatLng;
          if (initialPos!.heading >= 0 && initialPos.heading <= 360) {
            _heading = initialPos.heading;
          }
        });
        // Pindahkan map di homescreen ke posisi user yang relevan
        try {
          _mapController.move(userLatLng, 16.0);
        } catch (_) {}
      }

      // 4. Dengarkan stream GPS real-time untuk Android 10 sampai versi terbaru
      final LocationSettings locationSettings;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 1, // update setiap pergeseran 1 meter
          intervalDuration: const Duration(milliseconds: 1000),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1,
        );
      }

      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen((pos) {
        if (!mounted) return;
        bool wasNull = _currentPosition == null;
        setState(() {
          _isGpsActive = true;
          _currentPosition = LatLng(pos.latitude, pos.longitude);
          if (pos.heading > 0 && pos.heading <= 360) {
            _heading = pos.heading;
          }
        });
        if (wasNull) _fetchLocationName(pos);
      });

      // 5. Sensor Magnetometer Kompas (Berotasi sesuai arah fisik hp)
      if (!kIsWeb) {
        try {
          _magSub?.cancel();
          _magSub = magnetometerEventStream().listen((event) {
            if (!mounted) return;
            // Hitung derajat arah hadap hp (0-360 derajat)
            double deg = (math.atan2(event.x, event.y) * 180.0 / math.pi);
            if (deg < 0) deg += 360.0;
            setState(() {
              _heading = deg;
            });
          });
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error init GPS on home: ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen()));
          },
          label: const Text('Dev Sitemap'),
          icon: const Icon(Icons.developer_board),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // ─── Scrollable content (Bisa ditarik ke bawah untuk refresh GPS) ───
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.textPrimary,
              backgroundColor: Colors.white,
              displacement: 40,
              edgeOffset: 10,
              onRefresh: _refreshGpsLocation,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 140),
                children: [
                // ─── Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, 20, AppSpacing.pageH, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top nav row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Calendar icon button
                          Visibility(visible: false, maintainSize: true, maintainAnimation: true, maintainState: true, child: _NavIconBtn(icon: Icons.calendar_today_outlined)),
                          // Location pill (Press & Hold untuk pop-up detail mengambang + blur)
                          Flexible(
                            child: GestureDetector(
                              onTapDown: (_) {
                                _pressStartTime = DateTime.now();
                                setState(() => _showLocationOverlay = true);
                              },
                              onTapUp: (_) {
                                final diff = _pressStartTime != null ? DateTime.now().difference(_pressStartTime!) : Duration.zero;
                                if (diff > const Duration(milliseconds: 300)) {
                                  setState(() => _showLocationOverlay = false);
                                }
                              },
                              onTapCancel: () {
                                setState(() => _showLocationOverlay = false);
                              },
                              onLongPressStart: (_) {
                                setState(() => _showLocationOverlay = true);
                              },
                              onLongPressEnd: (_) {
                                setState(() => _showLocationOverlay = false);
                              },
                              onLongPressCancel: () {
                                setState(() => _showLocationOverlay = false);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCard,
                                  borderRadius: AppRadii.pillRadius,
                                  boxShadow: const [AppShadows.soft],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _BlinkingGpsDot(size: 8),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _isGpsActive && _currentPosition != null ? _locationName : 'GPS tidak aktif',
                                        style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Notification button with dynamic unread badge
                          ListenableBuilder(
                            listenable: HomeBackend.instance,
                            builder: (context, _) {
                              final unread = HomeBackend.instance.unreadNotificationCount;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _NavIconBtn(
                                    icon: Icons.notifications_outlined,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                                  ),
                                  if (unread > 0)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                        child: Text(
                                          unread > 9 ? '9+' : '$unread',
                                          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Oversized dynamic greeting from Supabase
                      ListenableBuilder(
                        listenable: HomeBackend.instance,
                        builder: (context, _) {
                          String name = HomeBackend.instance.userName.trim();
                          if (name.isEmpty || name == 'Pengguna') {
                            final sessName = SessionService.instance.userName?.trim();
                            if (sessName != null && sessName.isNotEmpty) {
                              name = sessName;
                            }
                          }
                          // Tampilkan nama akun pengguna secara utuh (contoh: "user 1", "Aji", "Dito")
                          // Jika terlalu panjang (> 22 karakter), ambil 2 kata pertama
                          String displayName = name.isNotEmpty ? name : 'Pengguna';
                          if (displayName.length > 22) {
                            final parts = displayName.split(' ');
                            if (parts.length > 1) {
                              displayName = '${parts[0]} ${parts[1]}';
                            }
                          }
                          return Text('Halo, $displayName'.tr, style: AppTypography.displayLg());
                        },
                      ),
                      const SizedBox(height: 4),
                      Text('Temukan slot parkir nyaman hari ini'.tr, style: AppTypography.bodySm(color: AppColors.textSecondary)),

                      // ─── Maintenance & Warning Live Banner ──────────────────
                      ListenableBuilder(
                        listenable: MaintenanceService.instance,
                        builder: (context, _) {
                          final service = MaintenanceService.instance;
                          if (!service.isGlobalMaintenance || SessionService.instance.isAdmin) return const SizedBox.shrink();

                          if (service.isWarningOnly) {
                            return GestureDetector(
                              onTap: () => MaintenanceService.showWarningDialog(context),
                              child: Container(
                                margin: const EdgeInsets.only(top: 14),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.warningTitle,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF92400E),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            service.warningMessage,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: const Color(0xFFB45309),
                                              height: 1.35,
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

                          // Full Maintenance Card Banner
                          return Container(
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B0000), Color(0xFFC0392B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC0392B).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, size: 11, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            'SISTEM MAINTENANCE',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => MaintenanceService.showGlobalMaintenanceDialog(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Buka Pop-up',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFC0392B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  service.maintenanceTitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  service.maintenanceMessage,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ─── Search Bar ─────────────────────────────────
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: AppRadii.pillRadius,
                      boxShadow: const [AppShadows.soft],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(Icons.search, size: 22, color: AppColors.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            style: AppTypography.bodyMd(),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari gedung atau area parkir...'.tr,
                              hintStyle: AppTypography.bodyMd(color: AppColors.textMuted),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: ThemeService.instance.isDarkMode
                                    ? Colors.white12
                                    : Colors.black.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const _FilterPopup(),
                            );
                          },
                          child: Container(
                            width: 36, height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration( shape: BoxShape.circle),
                           
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Category Pills ─────────────────────────────
                const SizedBox(height: 16),
                const _CategoryList(),

                // ─── Tampilan Dinamis Berdasarkan Pencarian ─────────
                if (_searchQuery.trim().isNotEmpty) ...[
                  // 1. Susunan Card Hasil Ketik NAIK menjadi pas di bawah tombol kategori
                  //    TANPA ADA TULISAN REKOMENDASI DAN MUAT ULANG
                  _RecommendationsList(searchQuery: _searchQuery),
                  const SizedBox(height: 20),
                  // 2. Card Kepadatan Area PINDAH PALING BAWAH di bawah hasil ketik paling bawah
                  _buildHeroMapCard(),
                  // 3. Card Sesi Aktif (jika ada yang aktif) JUGA PINDAH di bawah Card Kepadatan Area
                  _buildActiveSessionsSection(),
                  SizedBox(height: math.max(MediaQuery.of(context).padding.bottom + 12, 24) + 76),
                ] else ...[
                  // ─── Kondisi Normal Sebelum Mengetik ───
                  const SizedBox(height: 16),
                  _buildHeroMapCard(),
                  _buildActiveSessionsSection(),
                  const _RecommendationsList(searchQuery: ''),
                ],
              ],
            ),
          ),
        ),


          // ─── Dark floating dock navigation (fixed bottom with safe area) ────────
          Positioned(
            bottom: math.max(MediaQuery.of(context).padding.bottom + 12, 24),
            left: AppSpacing.pageH,
            right: AppSpacing.pageH,
            child: Center(
              child: const BottomDockNavigation(activeTab: DockTab.home),
            ),
          ),

          // ─── Floating Address Detail Overlay with Backdrop Blur ────────
          if (_showLocationOverlay) ...[
            // 1. Backdrop blur scrim
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _showLocationOverlay = false),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.42),
                  ),
                ),
              ),
            ),
            // 2. Focused interactive overlay card
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active Pill badge highlight
                      _buildActiveLocationPillHighlight(),
                      const SizedBox(height: 12),
                      // Floating Address Detail Card
                      _buildFloatingAddressCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroMapCard() {
    return Padding(
      key: const ValueKey('hero_map_card'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreMapScreen())),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadii.xl2Radius,
            border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
            boxShadow: const [AppShadows.soft],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // SVG-style map using CustomPaint
            ClipRRect(
              borderRadius: AppRadii.lgRadius,
              child: SizedBox(
                width: double.infinity, height: 210,
                child: Stack(children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition ?? const LatLng(-6.1774, 106.7907), // Relevan GPS atau default random
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.smart_parking',
                      ),
                      MarkerLayer(
                        markers: [
                          // Marker spot parkir terdekat / default
                          Marker(
                            point: const LatLng(-6.1774, 106.7907),
                            width: 200,
                            height: 60,
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: AppRadii.pillRadius,
                                    boxShadow: const [AppShadows.float],
                                  ),
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.local_parking, size: 16, color: AppColors.secondary),
                                    const SizedBox(width: 6),
                                    Text('Central Park • 24 slot', style: AppTypography.buttonSm(color: AppColors.white)),
                                  ]),
                                ),
                                Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                  transform: Matrix4.rotationZ(0.785),
                                  transformAlignment: Alignment.topCenter,
                                ),
                              ],
                            ),
                          ),
                          // JIKA GPS AKTIF: Marker Panah Navigator (assets/images/navigationarrow.png)
                          // Jika GPS dimatikan: tidak ada titik navigator posisi
                          if (_isGpsActive && _currentPosition != null)
                            Marker(
                              point: _currentPosition!,
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Lingkaran aura biru akurasi
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A73E8).withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Item panah sebagai navigator yang menandakan posisi dan berotasi sesuai arah hp & GPS real
                                  Transform.rotate(
                                    angle: (_heading - 45.0) * (math.pi / 180.0),
                                    child: Image.asset(
                                      'assets/images/navigationarrow.png',
                                      width: 38,
                                      height: 38,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  // Traffic badge top-right (Titik kemacetan real-time)
                  Positioned(
                    top: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard.withValues(alpha: 0.95),
                        borderRadius: AppRadii.pillRadius,
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _trafficStatusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _trafficBadgeText,
                            style: AppTypography.caption().copyWith(
                              fontWeight: FontWeight.w700,
                              color: _trafficStatusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            // Metrics row (Hapus tarif, tampilkan Kepadatan Area & Live Traffic)
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _trafficStatusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _trafficDensity >= 80 ? Icons.traffic_rounded : Icons.explore_outlined,
                    size: 24,
                    color: _trafficStatusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KEPADATAN AREA'.tr, style: AppTypography.overline(color: AppColors.textSecondary)),
                      Text(_trafficAreaText, style: AppTypography.metricMd()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _trafficStatusColor.withValues(alpha: 0.1),
                    borderRadius: AppRadii.pillRadius,
                    border: Border.all(color: _trafficStatusColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed_rounded, size: 14, color: _trafficStatusColor),
                      const SizedBox(width: 4),
                      Text(
                        'Live Traffic',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _trafficStatusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildActiveSessionsSection() {
    return ListenableBuilder(
      key: const ValueKey('active_sessions_section'),
      listenable: HomeBackend.instance,
      builder: (context, _) {
        final sessions = HomeBackend.instance.activeSessions;
        if (sessions.isEmpty) {
          return const SizedBox.shrink(); // Sembunyikan jika tidak ada sesi parkir aktif
        }

        return Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'Sesi Parkir Aktif'.tr} (${sessions.length})', style: AppTypography.headlineMd()),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.secondarySoft, borderRadius: AppRadii.pillRadius),
                      child: Text('Live', style: AppTypography.buttonSm(color: AppColors.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...sessions.map((session) {
                  final locName = session['location_name'] ?? 'Spot Parkir';
                  final slotCode = session['slot_code'] ?? 'A-01';
                  final floorName = session['floor_name'] ?? 'Lantai B1';
                  final title = (session['title'] ?? 'SESI PARKIR AKTIF').toString();
                  final imageUrl = session['image_url'] ??
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBJsx7LXeBJaAUStN81EfJ9OnCVmlVfmXRVDoub2mCYF0PIZidBrj0P0BKnSQQ61XyOVPHfeRK_AjHvT4_n19Q4_qfAi5-0c_AtnvOqmHjdEejobI5hupnFTMA62ySz5EK1P6Po3FtWuoFmFfTR5VstawDWIS_2zh3UIgjbVetIvkLALvb2EBtQnUoqR0niPhqqhkXpxobDu16pJPgQJ-hb6JjoFhBlKgY4UIkQVJWw5DpBxelV88Kr';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: AppRadii.xl2Radius,
                        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
                        boxShadow: const [AppShadows.soft],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Parking spot image
                          ClipRRect(
                            borderRadius: AppRadii.imgRadius,
                            child: AppCachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 64, height: 64, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 64, height: 64, color: AppColors.surfaceDim,
                                child: Icon(Icons.local_parking, color: AppColors.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(title.tr, style: AppTypography.overline(color: AppColors.secondary)),
                            const SizedBox(height: 2),
                            Text(locName, style: AppTypography.headlineSm()),
                            const SizedBox(height: 2),
                            Text('Spot $slotCode • $floorName'.tr, style: AppTypography.caption(color: AppColors.textSecondary)),
                          ])),
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(color: Color(0xFF1A1C1E), shape: BoxShape.circle),
                            child: const Icon(Icons.qr_code_2, size: 20, color: Colors.white),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: AppRadii.lgRadius, border: Border.all(color: AppColors.warmBorder)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('SISA WAKTU'.tr, style: AppTypography.overline(color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                _HomeSessionCountdownTimer(endTime: session['end_time']),
                              ]),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => active.ActiveSessionScreen(sessionId: session['id']),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadii.pillRadius,
                                    boxShadow: const [AppShadows.float]),
                                  child: Row(children: [
                                    Text('Buka Tiket'.tr, style: AppTypography.buttonSm(color: AppColors.white)),
                                    const SizedBox(width: 6),
                                    Icon(Icons.arrow_forward, size: 16, color: AppColors.white),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveLocationPillHighlight() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BlinkingGpsDot(size: 9),
          const SizedBox(width: 8),
          Text(
            _isGpsActive && _currentPosition != null ? _locationName : 'GPS tidak aktif',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAddressCard() {
    final lat = _currentPosition?.latitude.toStringAsFixed(6) ?? '-7.755432';
    final lng = _currentPosition?.longitude.toStringAsFixed(6) ?? '110.398712';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.warmBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.satellite_alt_rounded, size: 13, color: Color(0xFF059669)),
                    const SizedBox(width: 5),
                    Text(
                      'GPS PRESISI TINGGI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showLocationOverlay = false),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Kelurahan Display
          Text(
            _locationDetails['kelurahan'] ?? _locationName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF059669)),
              const SizedBox(width: 4),
              Text(
                'Kelurahan aktif • Wilayah terdeteksi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          const SizedBox(height: 14),

          // Detailed Breakdown List
          _buildAddressRow(
            icon: Icons.signpost_outlined,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4F46E5),
            label: 'Alamat / RT / RW',
            value: _locationDetails['jalan'] ?? '-',
          ),
          const SizedBox(height: 10),
          _buildAddressRow(
            icon: Icons.holiday_village_outlined,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            label: 'Kelurahan / Desa',
            value: _locationDetails['kelurahan'] ?? '-',
          ),
          const SizedBox(height: 10),
          _buildAddressRow(
            icon: Icons.apartment_outlined,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            label: 'Kecamatan',
            value: _locationDetails['kecamatan'] ?? '-',
          ),
          const SizedBox(height: 10),
          _buildAddressRow(
            icon: Icons.location_city_outlined,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFD97706),
            label: 'Kabupaten / Kota',
            value: _locationDetails['kota'] ?? '-',
          ),
          const SizedBox(height: 10),
          _buildAddressRow(
            icon: Icons.map_outlined,
            iconBg: const Color(0xFFFAF5FF),
            iconColor: const Color(0xFF9333EA),
            label: 'Provinsi / Daerah',
            value: _locationDetails['provinsi'] ?? '-',
          ),
          const SizedBox(height: 10),
          _buildAddressRow(
            icon: Icons.markunread_mailbox_outlined,
            iconBg: const Color(0xFFFFF1F2),
            iconColor: const Color(0xFFE11D48),
            label: 'Kode Pos',
            value: _locationDetails['kodePos'] ?? '-',
          ),

          const SizedBox(height: 14),

          // Coordinates Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: $lat • Long: $lng',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Touch release hint
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app_outlined, size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  'Lepas sentuhan untuk menutup',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Map Painter — reproduces the Stitch SVG vector road system ──────────────


class _NavIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavIconBtn({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: AppColors.surfaceCard,
      shape: BoxShape.circle,
      boxShadow: const [AppShadows.soft],
    ),
    child: Icon(icon, size: 20, color: AppColors.textPrimary),
  ));
}

class _BlinkingGpsDot extends StatefulWidget {
  final double size;
  const _BlinkingGpsDot({this.size = 8.0});

  @override
  State<_BlinkingGpsDot> createState() => _BlinkingGpsDotState();
}

class _BlinkingGpsDotState extends State<_BlinkingGpsDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final val = _animation.value;
        return SizedBox(
          width: widget.size + 6,
          height: widget.size + 6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse glow (efek radar sinyal GPS aktif)
              Container(
                width: widget.size + (6 * val),
                height: widget.size + (6 * val),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.35 * (1.0 - val * 0.3)),
                ),
              ),
              // Core dot utama (berkedip terang-redup stabil)
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    const Color(0xFF059669),
                    const Color(0xFF34D399),
                    val,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3 + 0.6 * val),
                      blurRadius: 4 + 4 * val,
                      spreadRadius: 1 * val,
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
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool tealIcon;
  final VoidCallback? onTap;
  const _CategoryPill({required this.label, required this.icon, this.active = false, this.tealIcon = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.black : AppColors.surfaceCard,
          borderRadius: AppRadii.pillRadius,
          boxShadow: active ? null : const [AppShadows.soft],
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: active ? AppColors.white : tealIcon ? AppColors.accentTeal : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.labelSm(color: active ? AppColors.white : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}



class _FilterPopup extends StatefulWidget {
  const _FilterPopup();
  @override
  State<_FilterPopup> createState() => _FilterPopupState();
}

class _FilterPopupState extends State<_FilterPopup> {
  final Set<String> _selectedCriteria = {};

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCriteria.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCriteria.remove(label);
          } else {
            _selectedCriteria.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : const Color(0xFFE4DFD5),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF62615B),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.close, size: 20, color: Color(0xFF1A1A18)),
                      ),
                    ),
                  ),
                  Text(
                    'Kriteria',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A18),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFilterChip('Harga'),
                  _buildFilterChip('Terdekat'),
                  _buildFilterChip('Tersedia'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Pilih',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatefulWidget {
  const _CategoryList();
  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HomeBackend.instance,
      builder: (context, _) {
        final selected = HomeBackend.instance.selectedCategory;
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _CategoryPill(
                label: 'Terdekat'.tr, 
                icon: Icons.near_me, 
                active: selected == 'Terdekat',
                onTap: () => HomeBackend.instance.setFilterCategory('Terdekat'),
              ),
              _CategoryPill(
                label: 'Mall'.tr, 
                icon: Icons.storefront_outlined,
                active: selected == 'Mall',
                onTap: () => HomeBackend.instance.setFilterCategory('Mall'),
              ),
              _CategoryPill(
                label: 'Parkir EV'.tr, 
                icon: Icons.bolt, 
                tealIcon: true,
                active: selected == 'Parkir EV',
                onTap: () => HomeBackend.instance.setFilterCategory('Parkir EV'),
              ),
              _CategoryPill(
                label: 'Games'.tr, 
                icon: Icons.sports_esports, 
                tealIcon: true,
                active: selected == 'Games',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const game.GameLobbyScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendationsList extends StatefulWidget {
  final String searchQuery;
  const _RecommendationsList({this.searchQuery = ''});
  @override
  State<_RecommendationsList> createState() => _RecommendationsListState();
}

class _RecommendationsListState extends State<_RecommendationsList> {
  bool _isLoading = false;

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String price,
    required String imageUrl,
    String? rating = '4.8',
    bool isEv = false,
    required Map<String, dynamic> locData,
  }) {
    void openInExplore() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExploreMapScreen(
            initialSelectedParking: locData,
          ),
        ),
      );
    }

    final isDark = ThemeService.instance.isDarkMode;

    return GestureDetector(
      onTap: openInExplore,
      child: Container(
        height: 360,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF2D3542) : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. FULL BACKGROUND IMAGE (Menampilkan mobil & area parkir dengan jelas)
              Positioned.fill(
                child: AppCachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(Icons.local_parking, size: 52, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),

              // 2. BADGE KATEGORI DI POJOK KANAN ATAS
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: isEv ? const Color(0xFF0F766E).withValues(alpha: 0.94) : Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isEv ? Icons.electric_car : Icons.local_parking, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        (isEv ? 'Khusus EV' : 'Mobil & Motor').tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. GRADIEN PUTIH LUNTUR PUDAR (Hanya di ~38% sisi bawah, menyisakan >62% foto mobil jernih tanpa blur)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.surfaceCard,
                        AppColors.surfaceCard.withValues(alpha: 0.98),
                        AppColors.surfaceCard.withValues(alpha: 0.75),
                        AppColors.surfaceCard.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.16, 0.26, 0.34, 0.40],
                    ),
                  ),
                ),
              ),

              // 4. KONTEN INFORMASI & TOMBOL EXPLORE DI SISI BAWAH PUTIH
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Baris Nama Parkiran & Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFF4B400), size: 15),
                                const SizedBox(width: 2),
                                Text(
                                  rating,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Keterangan Jarak & Slot
                      Row(
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            size: 13,
                            color: isDark ? Colors.white : const Color(0xFF5F6368),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF5F6368),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Baris Harga & Tombol Explore
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Keterangan Harga
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TARIF PARKIR'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                price,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F766E),
                                ),
                              ),
                            ],
                          ),
                          // Tombol Explore
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F),
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              elevation: 0,
                            ),
                            icon: Icon(
                              Icons.explore_rounded,
                              size: 16,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                            label: Text(
                              'Explore',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            ),
                            onPressed: openInExplore,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, HomeBackend.instance, CurrencyService.instance, LanguageService.instance]),
      builder: (context, _) {
        final isSearching = widget.searchQuery.trim().isNotEmpty;
        final q = widget.searchQuery.trim().toLowerCase();

        final allLocs = HomeBackend.instance.allLocations.isNotEmpty
            ? HomeBackend.instance.allLocations
            : HomeBackend.instance.recommendedLocations;

        final locations = isSearching
            ? allLocs.where((loc) {
                final name = (loc['name'] ?? '').toString().toLowerCase();
                final address = (loc['address'] ?? '').toString().toLowerCase();
                final city = (loc['city'] ?? '').toString().toLowerCase();
                final type = (loc['type'] ?? '').toString().toLowerCase();
                final code = (loc['code'] ?? '').toString().toLowerCase();
                return name.contains(q) ||
                    address.contains(q) ||
                    city.contains(q) ||
                    type.contains(q) ||
                    code.contains(q);
              }).toList()
            : HomeBackend.instance.recommendedLocations;

        if (isSearching) {
          locations.sort((a, b) {
            final distA = (a['calculated_distance'] as num?)?.toDouble() ?? 99999999.0;
            final distB = (b['calculated_distance'] as num?)?.toDouble() ?? 99999999.0;
            return distA.compareTo(distB);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSearching) ...[
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rekomendasi Lainnya'.tr, style: AppTypography.headlineMd()),
                    GestureDetector(
                      onTap: () async {
                        if (_isLoading) return;
                        setState(() => _isLoading = true);
                        await HomeBackend.instance.refreshFilter();
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      },
                      child: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('Muat Ulang'.tr, style: AppTypography.buttonSm(color: AppColors.secondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Sesuai instruksi: tanpa ada tulisan rekomendasi dan muat ulang,
              // card pas naik di bawah tombol terdekat, mall, parkir ev
              const SizedBox(height: 6),
            ],

            if (locations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        isSearching ? Icons.search_off_rounded : Icons.local_parking_outlined,
                        size: 48,
                        color: ThemeService.instance.textSecondary.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isSearching
                            ? 'Tidak ada tempat parkir yang sesuai dengan "${widget.searchQuery}"'.tr
                            : (HomeBackend.instance.selectedCategory == 'Terdekat'
                                ? 'Belum ada rekomendasi parkir aktif'.tr
                                : 'Belum ada tempat parkir untuk kategori "${HomeBackend.instance.selectedCategory.tr}"'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSearching
                            ? 'Coba gunakan kata kunci pencarian lain'.tr
                            : 'Semua tempat parkir diinput langsung oleh Admin Operasional'.tr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: ThemeService.instance.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (final loc in locations)
                Builder(
                  builder: (context) {
                    final lat = (loc['latitude'] as num?)?.toDouble() ?? -6.1754;
                    final lng = (loc['longitude'] as num?)?.toDouble() ?? 106.7933;
                    final rateMobil = (loc['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
                    final rateEv = (loc['hourly_rate_ev'] as num?)?.toInt() ?? 7500;
                    final rateMotor = (loc['hourly_rate_motor'] as num?)?.toInt() ?? 2000;
                    final selectedCat = HomeBackend.instance.selectedCategory;

                    final vType = VehicleBackend.instance.defaultVehicle?.vehicleType.toLowerCase() ?? 'mobil';
                    int displayRate = rateMobil;
                    String rateSuffix = '/ jam';
                    if (selectedCat == 'Parkir EV' || vType.contains('ev') || vType.contains('electric')) {
                      displayRate = rateEv;
                      rateSuffix = '/ j (EV)';
                    } else if (vType.contains('motor') || vType.contains('bike')) {
                      displayRate = rateMotor;
                    } else {
                      displayRate = rateMobil;
                    }
                    final formattedPrice = '${CurrencyService.instance.format(displayRate)} $rateSuffix';

                    final capacity = (loc['total_capacity'] as num?)?.toInt() ?? 50;
                    final num reviewCountNum = (loc['review_count'] as num?) ?? 0;
                    final double rawRating = (loc['rating'] as num?)?.toDouble() ?? 0.0;
                    final double ratingVal = reviewCountNum == 0 ? 0.0 : rawRating;
                    final reviewsVal = '$reviewCountNum';
                    final facilities = (loc['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                    final isEv = facilities.any((f) => f.toLowerCase().contains('ev'));
                    List<String> photos = [];
                    if (loc['images'] is List) {
                      photos = (loc['images'] as List)
                          .map((e) => e.toString().trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                    }
                    if (photos.isEmpty && loc['image_url'] != null && loc['image_url'].toString().trim().isNotEmpty) {
                      photos.add(loc['image_url'].toString().trim());
                    }
                    if (photos.isEmpty) {
                      photos.add('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80');
                    }
                    final primaryImg = photos.first;

                    final distLabel = loc['distance_label']?.toString();
                    final subText = (distLabel != null && distLabel != '-')
                        ? '$distLabel • ${loc['city'] ?? 'Kota'} • $capacity slot'
                        : '${loc['city'] ?? 'Jakarta'} • $capacity slot kapasitas';

                    final locData = {
                      'id': loc['id'],
                      'name': loc['name'] ?? 'Spot Parkir',
                      'type': loc['type'] ?? 'Parkiran Mall',
                      'point': LatLng(lat, lng),
                      'slots': capacity,
                      'isEv': isEv,
                      'distance': (distLabel != null && distLabel != '-') ? distLabel : '1.2 km',
                      'price': formattedPrice,
                      'rating': ratingVal,
                      'reviews': reviewsVal,
                      'review_count': reviewCountNum,
                      'operating_hours': loc['operating_hours'] ?? 'Buka 24 Jam',
                      'hours': loc['operating_hours'] ?? (loc['status'] == 'active' ? 'Buka 24 Jam' : 'Tutup Sementara'),
                      'status': loc['status'] ?? 'active',
                      'photos': photos,
                      'facilities': facilities,
                      'hourly_rate_mobil': rateMobil,
                      'hourly_rate_ev': rateEv,
                      'hourly_rate_motor': rateMotor,
                      'hourly_rate_active': displayRate,
                    };

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                      child: _buildCard(
                        title: loc['name'] ?? 'Spot Parkir',
                        subtitle: subText,
                        price: formattedPrice,
                        imageUrl: primaryImg,
                        rating: ratingVal.toStringAsFixed(1),
                        isEv: isEv,
                        locData: locData,
                      ),
                    );
                  },
                ),
            if (!isSearching)
              SizedBox(height: math.max(MediaQuery.of(context).padding.bottom + 12, 24) + 76)
            else
              const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

/// Widget timer hitung mundur real-time matematika untuk sesi parkir aktif / reservasi
class _HomeSessionCountdownTimer extends StatefulWidget {
  final dynamic endTime;
  const _HomeSessionCountdownTimer({required this.endTime});

  @override
  State<_HomeSessionCountdownTimer> createState() => _HomeSessionCountdownTimerState();
}

class _HomeSessionCountdownTimerState extends State<_HomeSessionCountdownTimer> {
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _calculateRemaining();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant _HomeSessionCountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _calculateRemaining();
    }
  }

  void _calculateRemaining() {
    if (widget.endTime == null) {
      _remainingSeconds = 0;
      return;
    }
    final dt = DateTime.tryParse(widget.endTime.toString())?.toLocal() ?? DateTime.now();
    final diff = dt.difference(DateTime.now()).inSeconds;
    _remainingSeconds = diff > 0 ? diff : 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = (_remainingSeconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((_remainingSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return Text('$h:$m:$s', style: AppTypography.monoLg());
  }
}


