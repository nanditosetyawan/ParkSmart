import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../favorite/backend/favorite_backend.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../booking/slot_selection_screen.dart';
import '../../core/services/maintenance_service.dart';
import 'backend/parking_detail_backend.dart';
import '../checkout/backend/checkout_backend.dart';
import '../booking/backend/slot_selection_backend.dart';
import '../../core/services/app_image_cache_service.dart';

class ParkingDetailScreen extends StatefulWidget {
  final String? locationId;
  const ParkingDetailScreen({super.key, this.locationId});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  late final PageController _heroPhotoController;
  int _currentPhotoIndex = 0;
  Position? _userPosition;
  String _selectedVehicleRateType = 'mobil'; // 'mobil', 'ev', 'motor'

  @override
  void initState() {
    super.initState();
    _heroPhotoController = PageController();
    ParkingDetailBackend.instance.fetchLocationDetail(locationId: widget.locationId);
    FavoriteBackend.instance.fetchFavorites();
    _loadUserGps();
  }

  Future<void> _loadUserGps() async {
    try {
      final pos = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 3),
            ),
          );
      if (mounted) {
        setState(() {
          _userPosition = pos;
        });
      }
    } catch (_) {}
  }

  String _getDistanceAndDuration(Map<String, dynamic>? loc) {
    if (loc == null) return '350m (3 mnt)';
    final locLat = (loc['latitude'] as num?)?.toDouble();
    final locLng = (loc['longitude'] as num?)?.toDouble();
    if (locLat == null || locLng == null) return '350m (3 mnt)';

    if (_userPosition != null) {
      final meters = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        locLat,
        locLng,
      );
      final String distStr;
      if (meters < 1000) {
        distStr = '${meters.round()}m';
      } else {
        distStr = '${(meters / 1000).toStringAsFixed(1)} km';
      }
      final int mins = (meters / 500).round().clamp(1, 180);
      return '$distStr ($mins mnt)';
    }
    return '1.2 km (5 mnt)';
  }

  @override
  void dispose() {
    _heroPhotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, ParkingDetailBackend.instance, FavoriteBackend.instance, CurrencyService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final backend = ParkingDetailBackend.instance;

        if (!backend.isLoading && !backend.hasLocation) {
          return Scaffold(
            backgroundColor: isDark ? theme.bg : AppColors.surface,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Detail Tempat Parkir'.tr,
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
                        Icons.location_off_outlined,
                        size: 64,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Lokasi Parkir Tidak Ditemukan'.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data lokasi tempat parkir belum terdaftar atau tidak ditemukan di sistem.'.tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: Text('Kembali ke Peta'.tr),
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

        return Scaffold(
          backgroundColor: isDark ? theme.bg : AppColors.surface,
          body: Stack(
            children: [
              // Scrollable content
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  // spacer for fixed header
                  SizedBox(height: MediaQuery.of(context).padding.top + 72),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero image
                        Builder(
                          builder: (context) {
                            final loc = backend.locationDetail;
                            List<String> photos = [];
                            if (loc != null && loc['images'] is List) {
                              photos = (loc['images'] as List)
                                  .map((e) => e.toString().trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                            }
                            if (photos.isEmpty && loc != null && loc['image_url'] != null && loc['image_url'].toString().trim().isNotEmpty) {
                              photos.add(loc['image_url'].toString().trim());
                            }
                            if (photos.isEmpty) {
                              photos.add('https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80');
                            }

                            final ratingStr = (loc?['rating'] as num?)?.toStringAsFixed(1) ?? '4.8';
                            final typeStr = loc?['type']?.toString() ?? 'Basement B2';
                            final isOpen24 = loc?['status'] == 'active';
                            final facilities = (loc?['facilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                            final isEv = facilities.any((f) => f.toLowerCase().contains('ev'));

                            return Container(
                              height: 320,
                              decoration: BoxDecoration(
                                borderRadius: AppRadii.xl2Radius,
                                border: Border.all(
                                  color: isDark ? theme.border : const Color(0xFFEAE5DC).withValues(alpha: 0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    offset: const Offset(0, 8),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: AppRadii.xl2Radius,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    PageView.builder(
                                      controller: _heroPhotoController,
                                      itemCount: photos.length,
                                      onPageChanged: (idx) {
                                        setState(() => _currentPhotoIndex = idx);
                                      },
                                      itemBuilder: (context, idx) {
                                        return AppCachedNetworkImage(
                                          imageUrl: photos[idx],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFECE8E0),
                                            child: const Center(
                                              child: Icon(Icons.local_parking, size: 48, color: Color(0xFF9CA3AF)),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // gradient overlay bottom-up
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            AppColors.primary.withValues(alpha: 0.0),
                                            AppColors.primary.withValues(alpha: 0.7),
                                          ],
                                          stops: const [0.4, 1.0],
                                        ),
                                      ),
                                    ),
                                    // Top badges
                                    Positioned(
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (photos.length > 1)
                                            _HeroPill(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    '${_currentPhotoIndex + 1}/${photos.length}',
                                                    style: AppTypography.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            )
                                          else
                                            const SizedBox(),
                                          _HeroPill(
                                            color: AppColors.primary.withValues(alpha: 0.7),
                                            child: Row(
                                              children: [
                                                Icon(Icons.roofing, size: 15, color: AppColors.white),
                                                const SizedBox(width: 4),
                                                Text(typeStr, style: AppTypography.caption(color: AppColors.white)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Bottom badges
                                    Positioned(
                                      bottom: 20,
                                      left: 20,
                                      right: 20,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              _HeroPill(
                                                color: AppColors.white.withValues(alpha: 0.2),
                                                border: AppColors.white.withValues(alpha: 0.2),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.schedule, size: 14, color: AppColors.white),
                                                    const SizedBox(width: 4),
                                                    Text(isOpen24 ? '24 Jam'.tr : 'Tutup Sementara'.tr, style: AppTypography.caption(color: AppColors.white)),
                                                  ],
                                                ),
                                              ),
                                              if (isEv) ...[
                                                const SizedBox(width: 8),
                                                _HeroPill(
                                                  color: AppColors.white.withValues(alpha: 0.2),
                                                  border: AppColors.white.withValues(alpha: 0.2),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.ev_station, size: 14, color: AppColors.white),
                                                      const SizedBox(width: 4),
                                                      Text('EV Ready', style: AppTypography.caption(color: AppColors.white)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          _HeroPill(
                                            color: AppColors.white,
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(ratingStr, style: AppTypography.caption().copyWith(fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Dots indicator if multiple photos
                                    if (photos.length > 1)
                                      Positioned(
                                        bottom: 6,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(photos.length, (dotIdx) {
                                            final isSel = dotIdx == _currentPhotoIndex;
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                              width: isSel ? 16 : 6,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: isSel ? Colors.white : Colors.white.withValues(alpha: 0.45),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Title & metadata
                        const SizedBox(height: 20),
                        ListenableBuilder(
                          listenable: ParkingDetailBackend.instance,
                          builder: (context, _) {
                            final loc = ParkingDetailBackend.instance.locationDetail;
                            final facilityType = (loc?['type']?.toString().trim().isNotEmpty == true)
                                ? loc!['type'].toString().trim()
                                : 'Fasilitas Parkir'.tr;
                            final distDuration = _getDistanceAndDuration(loc);

                            return Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF1EEE7),
                                    borderRadius: AppRadii.pillRadius,
                                  ),
                                  child: Text(
                                    facilityType.tr,
                                    style: AppTypography.caption(
                                      color: isDark ? Colors.white : Colors.black,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•',
                                  style: AppTypography.caption(
                                    color: isDark ? theme.textMuted : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  distDuration,
                                  style: AppTypography.caption(
                                    color: isDark ? Colors.white : Colors.black,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ListenableBuilder(
                          listenable: ParkingDetailBackend.instance,
                          builder: (context, _) {
                            final loc = ParkingDetailBackend.instance.locationDetail;
                            final name = loc?['name'] as String? ?? 'Lokasi Parkir'.tr;
                            final address = loc?['address'] as String? ?? '-';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    letterSpacing: -0.5,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.near_me,
                                      size: 18,
                                      color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF1F4F3C),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        address,
                                        style: AppTypography.bodySm(
                                          color: isDark ? theme.textMuted : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        // Capacity card
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : AppColors.surfaceCard,
                            borderRadius: AppRadii.xl2Radius,
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFFEAE5DC).withValues(alpha: 0.5),
                            ),
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'KAPASITAS TERSEDIA'.tr,
                                        style: AppTypography.overline(
                                          color: isDark ? theme.textMuted : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ListenableBuilder(
                                        listenable: Listenable.merge([ParkingDetailBackend.instance, CurrencyService.instance]),
                                        builder: (context, _) {
                                          final available = ParkingDetailBackend.instance.availableSlots;
                                          final floors = ParkingDetailBackend.instance.floors;
                                          final primaryFloor = floors.isNotEmpty ? floors.first : 'Lantai 1';
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$available Slot'.tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.5,
                                                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                                ),
                                              ),
                                              Text(
                                                available > 0 ? 'Siap pakai di $primaryFloor'.tr : 'Belum ada slot yang dialokasikan'.tr,
                                                style: AppTypography.bodySm(
                                                  color: isDark ? theme.textMuted : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 60, height: 60),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? theme.surfaceField : const Color(0xFF1C1C18),
                                  borderRadius: AppRadii.lgRadius,
                                  border: isDark ? Border.all(color: theme.border) : null,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tips_and_updates_outlined, size: 18, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Zona A lebih dekat ke Lobby Tribeca & Central Park Lift.'.tr,
                                        style: AppTypography.bodySm(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Pricing card
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : AppColors.surfaceCard,
                            borderRadius: AppRadii.xl2Radius,
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TARIF PARKIR BERDASARKAN TIPE'.tr,
                                    style: AppTypography.overline(
                                      color: isDark ? theme.textMuted : AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _selectedVehicleRateType == 'ev'
                                        ? '⚡ EV Charging'
                                        : (_selectedVehicleRateType == 'motor' ? '🛵 Motor' : '🚗 Mobil'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedVehicleRateType == 'ev'
                                          ? const Color(0xFF17A18A)
                                          : const Color(0xFFD96B43),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Selector Pills: Mobil, EV, Motor
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildRateTypeChip(
                                      label: 'Mobil'.tr,
                                      icon: Icons.directions_car,
                                      typeKey: 'mobil',
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildRateTypeChip(
                                      label: '⚡ EV',
                                      icon: Icons.bolt,
                                      typeKey: 'ev',
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildRateTypeChip(
                                      label: 'Motor'.tr,
                                      icon: Icons.two_wheeler,
                                      typeKey: 'motor',
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ListenableBuilder(
                                listenable: Listenable.merge([ParkingDetailBackend.instance, CurrencyService.instance]),
                                builder: (context, _) {
                                  final loc = ParkingDetailBackend.instance.locationDetail;
                                  final rateMobil = (loc?['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
                                  final rateEv = (loc?['hourly_rate_ev'] as num?)?.toInt() ?? 7500;
                                  final rateMotor = (loc?['hourly_rate_motor'] as num?)?.toInt() ?? 2000;

                                  final activeRate = _selectedVehicleRateType == 'ev'
                                      ? rateEv
                                      : (_selectedVehicleRateType == 'motor' ? rateMotor : rateMobil);
                                  final rateStr = CurrencyService.instance.format(activeRate);

                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        rateStr,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          color: _selectedVehicleRateType == 'ev'
                                              ? const Color(0xFF17A18A)
                                              : const Color(0xFFD96B43),
                                        ),
                                      ),
                                      Text(
                                        ' / jam'.tr,
                                        style: AppTypography.bodySm(
                                          color: isDark ? theme.textMuted : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                             
                            ],
                          ),
                        ),

                        // Amenities
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : AppColors.surfaceCard,
                            borderRadius: AppRadii.xl2Radius,
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: const [AppShadows.soft],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'FASILITAS'.tr,
                                style: AppTypography.overline(
                                  color: isDark ? theme.textMuted : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AmenityChip(icon: Icons.videocam_outlined, label: 'CCTV 24 Jam'.tr, isDark: isDark),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _AmenityChip(icon: Icons.ev_station, label: 'EV Charging', isDark: isDark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AmenityChip(icon: Icons.accessible, label: 'Disabilitas'.tr, isDark: isDark),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _AmenityChip(icon: Icons.elevator_outlined, label: 'Akses Lift'.tr, isDark: isDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 90),
                      ],
                    ),
                  ),
                ],
              ),

              // Fixed top header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: isDark ? theme.bg : AppColors.surface,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _NavBtn(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                            isDark: isDark,
                          ),
                          const SizedBox(),
                          Row(
                            children: [
                              Builder(
                                builder: (ctx) {
                                  final currentLocId = backend.locationDetail?['id']?.toString() ?? widget.locationId;
                                  final isFav = currentLocId != null && FavoriteBackend.instance.isFavorite(currentLocId);
                                  return _NavBtn(
                                    icon: isFav ? Icons.favorite : Icons.favorite_border,
                                    iconColor: isFav ? const Color(0xFFEF4444) : null,
                                    isDark: isDark,
                                    onTap: () async {
                                      if (currentLocId == null || currentLocId.isEmpty) return;
                                      final added = await FavoriteBackend.instance.toggleFavorite(currentLocId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  added ? Icons.favorite : Icons.favorite_border,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  added
                                                      ? 'Ditambahkan ke parkir favorit'.tr
                                                      : 'Dihapus dari parkir favorit'.tr,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: added ? const Color(0xFFEF4444) : const Color(0xFF475569),
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _NavBtn(
                                icon: Icons.share_outlined,
                                isDark: isDark,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Floating bottom CTA (Pilih Slot)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      color: isDark ? theme.bg : AppColors.surface,
                      border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          offset: const Offset(0, -4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MULAI DARI'.tr,
                                style: AppTypography.overline(
                                  color: isDark ? theme.textMuted : AppColors.textSecondary,
                                ),
                              ),
                               ListenableBuilder(
                                 listenable: Listenable.merge([ParkingDetailBackend.instance, CurrencyService.instance]),
                                 builder: (context, _) {
                                   final loc = ParkingDetailBackend.instance.locationDetail;
                                   final rateMobil = (loc?['hourly_rate_mobil'] as num?)?.toInt() ?? 5000;
                                   final rateEv = (loc?['hourly_rate_ev'] as num?)?.toInt() ?? 7500;
                                   final rateMotor = (loc?['hourly_rate_motor'] as num?)?.toInt() ?? 2000;

                                   final activeRate = _selectedVehicleRateType == 'ev'
                                       ? rateEv
                                       : (_selectedVehicleRateType == 'motor' ? rateMotor : rateMobil);
                                   final rateStr = CurrencyService.instance.format(activeRate);
                                   return Text(
                                     '$rateStr ${'/ jam'.tr}',
                                     style: GoogleFonts.plusJakartaSans(
                                       fontSize: 18,
                                       fontWeight: FontWeight.w800,
                                       letterSpacing: -0.3,
                                       color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                     ),
                                   );
                                 },
                               ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                if (MaintenanceService.instance.isBookingMaintenance) {
                                  MaintenanceService.showModularMaintenanceDialog(
                                    context,
                                    title: 'Gateway Booking Sedang Maintenance'.tr,
                                    message:
                                        'Layanan pemesanan dan reservasi tiket parkir sementara dinonaktifkan untuk pemeliharaan sistem. Anda tetap dapat menjelajahi peta dan fitur lainnya.'.tr,
                                    icon: Icons.event_busy,
                                  );
                                  return;
                                }
                                final loc = ParkingDetailBackend.instance.locationDetail;
                                if (loc != null) {
                                  if (ParkingDetailBackend.instance.availableSlots <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFFDC2626),
                                        content: Text('Belum ada slot parkir yang dialokasikan di lokasi ini.'.tr),
                                      ),
                                    );
                                    return;
                                  }
                                  final locId = loc['id']?.toString();
                                  final locName = loc['name']?.toString() ?? 'Lokasi Parkir';
                                  final hourly = _selectedVehicleRateType == 'ev'
                                      ? ((loc['hourly_rate_ev'] as num?)?.toDouble() ?? 7500.0)
                                      : (_selectedVehicleRateType == 'motor'
                                          ? ((loc['hourly_rate_motor'] as num?)?.toDouble() ?? 2000.0)
                                          : ((loc['hourly_rate_mobil'] as num?)?.toDouble() ?? 5000.0));
                                  final slotTypeLabel = _selectedVehicleRateType == 'ev'
                                      ? 'Slot EV'
                                      : (_selectedVehicleRateType == 'motor' ? 'Slot Motor' : 'Slot Reguler');
                                  CheckoutBackend.instance.setBookingDetails(
                                    locationId: locId,
                                    locationName: locName,
                                    slotType: slotTypeLabel,
                                    hourlyRate: hourly,
                                    durationHours: 1,
                                  );
                                  SlotSelectionBackend.instance.fetchSlots(locationId: locId);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SlotSelectionScreen(
                                        locationId: locId,
                                        locationName: locName,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : AppColors.primary,
                                foregroundColor: isDark ? Colors.black : AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pilih Slot'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.black : AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 18,
                                    color: isDark ? Colors.black : AppColors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRateTypeChip({
    required String label,
    required IconData icon,
    required String typeKey,
    required bool isDark,
  }) {
    final isSelected = _selectedVehicleRateType == typeKey;
    final activeColor = typeKey == 'ev' ? const Color(0xFF17A18A) : const Color(0xFF114177);
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleRateType = typeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final Color color;
  final Color? border;
  final Widget child;
  const _HeroPill({required this.color, this.border, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: border != null ? Border.all(color: border!) : null,
        ),
        child: child,
      );
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;
  const _NavBtn({
    required this.icon,
    required this.onTap,
    this.isDark = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? theme.card : AppColors.surfaceCard,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? theme.border : const Color(0xFFEAE5DC).withValues(alpha: 0.6),
          ),
          boxShadow: const [AppShadows.soft],
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? (isDark ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}


class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _AmenityChip({required this.icon, required this.label, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? theme.surfaceField : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? theme.border : const Color(0xFFE5E2DB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF45474A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1C1C18),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
