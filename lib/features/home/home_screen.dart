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
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../map/explore_map_screen.dart';
import '../game/game_lobby_screen.dart' as game;
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  double _heading = 0.0; // Derajat arah hadap kompas & GPS (0 - 360)
  bool _isGpsActive = false;
  String _locationName = 'GPS tidak aktif';

  Future<void> _fetchLocationName(Position pos) async {
    try {
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String locality = p.subLocality ?? p.locality ?? '';
        String adminArea = p.administrativeArea ?? '';
        String combined = [locality, adminArea].where((e) => e.isNotEmpty).join(', ');
        if (combined.isEmpty) combined = 'Lokasi Anda (GPS)';
        
        if (mounted) {
          setState(() {
            _locationName = combined;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _locationName = 'Lokasi Anda (GPS)');
    }
  }

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  @override
  void initState() {
    super.initState();
    // Langsung minta akses GPS saat membuka aplikasi agar posisi map relevan
    _initGpsAndOrientation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _magSub?.cancel();
    super.dispose();
  }

  String get _distanceText {
    if (_currentPosition == null) return '350m';
    final d = const Distance().as(LengthUnit.Meter, _currentPosition!, const LatLng(-6.1774, 106.7907));
    if (d >= 1000) {
      return 'km';
    }
    return 'm';
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
          // ─── Scrollable content ─────────────────────────────────
          SafeArea(
            bottom: false,
            child: ListView(
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
                          // Location pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: AppRadii.pillRadius,
                              boxShadow: const [AppShadows.soft],
                            ),
                            child: Row(children: [
                              Container(width: 8, height: 8,
                                decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(_isGpsActive && _currentPosition != null ? _locationName : 'GPS tidak aktif', style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700)),
                            ]),
                          ),
                          // Notification button
                          _NavIconBtn(
                            icon: Icons.notifications_outlined,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Oversized greeting
                      Text('Halo, Sarah', style: AppTypography.displayLg()),
                      const SizedBox(height: 4),
                      Text('Temukan slot parkir nyaman hari ini', style: AppTypography.bodySm(color: AppColors.textSecondary)),
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
                            textInputAction: TextInputAction.done,
                            style: AppTypography.bodyMd(),
                            decoration: InputDecoration(
                              hintText: 'Cari gedung atau area parkir...',
                              hintStyle: AppTypography.bodyMd(color: AppColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
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
                            decoration: const BoxDecoration(color: AppColors.surfaceDim, shape: BoxShape.circle),
                            child: const Icon(Icons.tune, size: 18, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Category Pills ─────────────────────────────
                const SizedBox(height: 16),
                const _CategoryList(),

                // ─── Hero Map Card ──────────────────────────────
                const SizedBox(height: 16),
                Padding(
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
                                                const Icon(Icons.local_parking, size: 16, color: AppColors.secondary),
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
                              // Distance badge top-right
                              Positioned(
                                top: 16, right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceCard.withValues(alpha: 0.95),
                                    borderRadius: AppRadii.pillRadius,
                                    boxShadow: const [AppShadows.soft],
                                  ),
                                  child: Row(children: [
                                    Container(width: 8, height: 8,
                                      decoration: const BoxDecoration(color: AppColors.accentTeal, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text(_distanceText, style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                                  ]),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        // Metrics row
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: AppColors.secondarySoft, shape: BoxShape.circle),
                              child: const Icon(Icons.explore_outlined, size: 24, color: AppColors.secondary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('KEPADATAN AREA', style: AppTypography.overline(color: AppColors.textSecondary)),
                                Text('Tersedia Lengang (22%)', style: AppTypography.metricMd()),
                              ],
                            )),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('TARIF MULAI', style: AppTypography.overline(color: AppColors.textSecondary)),
                              RichText(text: TextSpan(
                                style: AppTypography.metricMd(),
                                children: [
                                  const TextSpan(text: 'Rp 5.000'),
                                  TextSpan(text: '/j', style: AppTypography.caption(color: AppColors.textSecondary)),
                                ],
                              )),
                            ]),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ),

                // ─── Active Booking Section ─────────────────────
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sesi Parkir Aktif', style: AppTypography.headlineMd()),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.secondarySoft, borderRadius: AppRadii.pillRadius),
                          child: Text('Lantai B2', style: AppTypography.buttonSm(color: AppColors.secondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
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
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBJsx7LXeBJaAUStN81EfJ9OnCVmlVfmXRVDoub2mCYF0PIZidBrj0P0BKnSQQ61XyOVPHfeRK_AjHvT4_n19Q4_qfAi5-0c_AtnvOqmHjdEejobI5hupnFTMA62ySz5EK1P6Po3FtWuoFmFfTR5VstawDWIS_2zh3UIgjbVetIvkLALvb2EBtQnUoqR0niPhqqhkXpxobDu16pJPgQJ-hb6JjoFhBlKgY4UIkQVJWw5DpBxelV88Kr',
                              width: 64, height: 64, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64, height: 64, color: AppColors.surfaceDim,
                                child: const Icon(Icons.local_parking, color: AppColors.secondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('SLOT TERPESAN', style: AppTypography.overline(color: AppColors.secondary)),
                            const SizedBox(height: 2),
                            Text('Central Park Mall', style: AppTypography.headlineSm()),
                            const SizedBox(height: 2),
                            Text('Spot A-12 • Jalur Khusus EV', style: AppTypography.caption(color: AppColors.textSecondary)),
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
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: AppRadii.lgRadius, border: Border.all(color: const Color(0xFFE5E2DB))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('SISA WAKTU', style: AppTypography.overline(color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text('01:42:18', style: AppTypography.monoLg()),
                              ]),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const active.ActiveSessionScreen())),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadii.pillRadius,
                                    boxShadow: const [AppShadows.float]),
                                  child: Row(children: [
                                    Text('Buka Tiket', style: AppTypography.buttonSm(color: AppColors.white)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward, size: 16, color: AppColors.white),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),

                // ─── Recommendations Section ────────────────────
                const _RecommendationsList(),
              ],
            ),
          ),


          // ─── Dark floating dock navigation (fixed bottom) ────────
          Positioned(
            bottom: 24,
            left: AppSpacing.pageH,
            right: AppSpacing.pageH,
            child: Center(
              child: const BottomDockNavigation(activeTab: DockTab.home),
            ),
          ),
        ],
      ),
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
      decoration: const BoxDecoration(
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
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF1A1A18)),
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
  String _selectedCategory = 'Terdekat';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _CategoryPill(
            label: 'Terdekat', 
            icon: Icons.near_me, 
            active: _selectedCategory == 'Terdekat',
            onTap: () => setState(() => _selectedCategory = 'Terdekat'),
          ),
          _CategoryPill(
            label: 'Mall', 
            icon: Icons.storefront_outlined,
            active: _selectedCategory == 'Mall',
            onTap: () => setState(() => _selectedCategory = 'Mall'),
          ),
          _CategoryPill(
            label: 'Parkir EV', 
            icon: Icons.bolt, 
            tealIcon: true,
            active: _selectedCategory == 'Parkir EV',
            onTap: () => setState(() => _selectedCategory = 'Parkir EV'),
          ),
          _CategoryPill(
            label: 'Games', 
            icon: Icons.sports_esports, 
            tealIcon: true,
            active: _selectedCategory == 'Games',
            onTap: () {
              setState(() => _selectedCategory = 'Games');
              Navigator.push(context, MaterialPageRoute(builder: (_) => const game.GameLobbyScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _RecommendationsList extends StatefulWidget {
  const _RecommendationsList();
  @override
  State<_RecommendationsList> createState() => _RecommendationsListState();
}

class _RecommendationsListState extends State<_RecommendationsList> {
  bool _isLoading = false;
  int _extraCount = 0;

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

    return GestureDetector(
      onTap: openInExplore,
      child: Container(
        height: 360,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
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
                        isEv ? 'Khusus EV' : 'Mobil & Motor',
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
                        Colors.white,
                        Colors.white.withValues(alpha: 0.98),
                        Colors.white.withValues(alpha: 0.75),
                        Colors.white.withValues(alpha: 0.15),
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
                                color: const Color(0xFF1C1D1F),
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
                                    color: const Color(0xFF1F1F1F),
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
                          const Icon(Icons.near_me_outlined, size: 13, color: Color(0xFF5F6368)),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5F6368),
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
                                'TARIF PARKIR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF76777B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                price,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                            ],
                          ),
                          // Tombol Explore
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C1D1F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.explore_rounded, size: 16),
                            label: Text(
                              'Explore',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rekomendasi Lainnya', style: AppTypography.headlineMd()),
              GestureDetector(
                onTap: () async {
                  if (_isLoading) return;
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _extraCount++;
                    });
                  }
                },
                child: _isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Lihat Semua', style: AppTypography.buttonSm(color: AppColors.secondary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
          child: _buildCard(
            title: 'Grand Indonesia West Mall', 
            subtitle: '850m • 8 slot kosong', 
            price: 'Rp 6.000 / jam', 
            imageUrl: 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
            rating: '4.8',
            locData: const {
              'name': 'Grand Indonesia West Mall',
              'type': 'Parkiran Mall',
              'point': LatLng(-6.1953, 106.8208),
              'slots': 8,
              'isEv': false,
              'distance': '850m',
              'price': 'Rp 6.000 / jam',
              'rating': 4.8,
              'reviews': '1.820',
              'hours': 'Buka • Tutup pukul 22.00 WIB',
              'photos': [
                'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
                'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
              ],
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
          child: _buildCard(
            title: 'Central Park Mall Parking', 
            subtitle: '350m • 42 slot tersedia', 
            price: 'Rp 5.000 / jam', 
            imageUrl: 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
            rating: '4.7',
            isEv: true,
            locData: const {
              'name': 'Central Park Mall Parking',
              'type': 'Parkiran Mall',
              'point': LatLng(-6.1788, 106.7916),
              'slots': 42,
              'isEv': true,
              'distance': '350m',
              'price': 'Rp 5.000 / jam',
              'rating': 4.7,
              'reviews': '1.420',
              'hours': 'Buka • Tutup pukul 22.00 WIB',
              'photos': [
                'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
                'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
              ],
            },
          ),
        ),
        for (int i = 0; i < _extraCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: _buildCard(
              title: 'Plaza Indonesia (Lantai 2)', 
              subtitle: '1.2km • Tersedia 12 slot', 
              price: 'Rp 5.000 / jam', 
              imageUrl: 'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80',
              rating: '4.6',
              locData: const {
                'name': 'Plaza Indonesia (Lantai 2)',
                'type': 'Parkiran Mall',
                'point': LatLng(-6.1928, 106.8228),
                'slots': 12,
                'isEv': false,
                'distance': '1.2km',
                'price': 'Rp 5.000 / jam',
                'rating': 4.6,
                'reviews': '1.150',
                'hours': 'Buka • Tutup pukul 22.00 WIB',
                'photos': [
                  'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80',
                  'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
                ],
              },
            ),
          ),
        const SizedBox(height: 36),
      ],
    );
  }
}
