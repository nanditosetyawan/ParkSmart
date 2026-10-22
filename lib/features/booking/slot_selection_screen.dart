// PS-05 Slot Selection
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/theme_service.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../checkout/checkout_screen.dart';
import '../../core/services/maintenance_service.dart';
import '../../core/services/currency_service.dart';
import 'backend/slot_selection_backend.dart';
import '../checkout/backend/checkout_backend.dart';

// Stitch Material3 slot colors
const _kSecondary = Color(0xFF9A442D);
const _kPrimaryContainer = Color(0xFF1C1D1F);
const _kTertiaryFixed = Color(0xFFBBEED4);
const _kSurfaceContainerLow = Color(0xFFF6F3EC);
const _kSurfaceContainerHigh = Color(0xFFEBE8E1);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);

class SlotSelectionScreen extends StatefulWidget {
  final String? locationId;
  final String? locationName;
  const SlotSelectionScreen({super.key, this.locationId, this.locationName});

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  String? _selectedSlot;
  int _selectedFloor = 0;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    if (MaintenanceService.instance.isBookingMaintenance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
          MaintenanceService.showModularMaintenanceDialog(
            context,
            title: 'Gateway Booking Sedang Maintenance',
            message:
                'Layanan pemesanan dan reservasi tiket parkir sementara dinonaktifkan untuk pemeliharaan sistem. Anda tetap dapat menjelajahi peta dan fitur lainnya.',
            icon: Icons.event_busy,
          );
        }
      });
    }

    _loadUserGps();
    final targetLocId = widget.locationId ?? CheckoutBackend.instance.locationId;
    SlotSelectionBackend.instance.fetchSlots(locationId: targetLocId);
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

  String _getDistanceText(Map<String, dynamic>? loc) {
    if (loc == null) return '350m';
    final locLat = (loc['latitude'] as num?)?.toDouble();
    final locLng = (loc['longitude'] as num?)?.toDouble();
    if (locLat == null || locLng == null) return '350m';

    if (_userPosition != null) {
      final meters = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        locLat,
        locLng,
      );
      if (meters < 1000) {
        return '${meters.round()}m';
      } else {
        return '${(meters / 1000).toStringAsFixed(1)} km';
      }
    }
    return '1.2 km';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, SlotSelectionBackend.instance, CurrencyService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        if (!SlotSelectionBackend.instance.isLoading && SlotSelectionBackend.instance.currentLocation == null) {
          return Scaffold(
            backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Pilih Slot Parkir',
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
                        Icons.grid_off_outlined,
                        size: 64,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Denah Slot Parkir Belum Tersedia',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lokasi parkir belum dipilih atau belum ada denah slot yang terdaftar di lokasi ini.',
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
                      label: const Text('Kembali ke Peta'),
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
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          body: Stack(
            children: [
              // Scrollable content
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 72),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // Summary card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : _kSurfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: isDark ? Border.all(color: theme.border) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                offset: const Offset(0, 12),
                                blurRadius: 32,
                                spreadRadius: -8,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // location + ANPR badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 18, color: Color(0xFFFB923C)),
                                      const SizedBox(width: 6),
                                      ListenableBuilder(
                                        listenable: SlotSelectionBackend.instance,
                                        builder: (context, _) {
                                          final loc = SlotSelectionBackend.instance.currentLocation;
                                          final locName = loc?['name']?.toString() ?? widget.locationName ?? 'Lokasi Parkir';
                                          final dist = _getDistanceText(loc);
                                          return Text(
                                            '$locName • $dist',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                              color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // slot count
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListenableBuilder(
                                        listenable: SlotSelectionBackend.instance,
                                        builder: (context, _) {
                                          final count = SlotSelectionBackend.instance.availableCount;
                                          return Text(
                                            '$count Slot',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.5,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          );
                                        },
                                      ),
                                      Builder(
                                        builder: (context) {
                                          final floors = SlotSelectionBackend.instance.floors;
                                          final fName = (floors.isNotEmpty && _selectedFloor < floors.length)
                                              ? floors[_selectedFloor]
                                              : 'Lantai 1';
                                          return Text(
                                            'Siap pakai di $fName',
                                            style: AppTypography.bodySm(
                                              color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Align(
                                        widthFactor: 0.75,
                                        child: _AmenityBadge(color: _kTertiaryFixed, icon: Icons.ev_station),
                                      ),
                                      Align(
                                        widthFactor: 0.75,
                                        child: _AmenityBadge(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFEBE8E1),
                                          icon: Icons.accessible,
                                        ),
                                      ),
                                      const _CountBadge(count: '+4'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // tip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? theme.surfaceField : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? theme.border : const Color(0xFFE5E2DB),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tips_and_updates_outlined, size: 18, color: Color(0xFF2DD4BF)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Zona A untuk Mobil Reguler. Zona B untuk Stasiun EV Charging & Campuran.',
                                        style: AppTypography.bodySm(
                                          color: isDark ? Colors.white : const Color(0xFF45474A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Floor selector tabs
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final floors = SlotSelectionBackend.instance.floors;
                            if (_selectedFloor >= floors.length) {
                              _selectedFloor = 0;
                            }
                            return SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: floors.length,
                                separatorBuilder: (context, index) => const SizedBox(width: 8),
                                itemBuilder: (_, i) {
                                  final active = i == _selectedFloor;
                                  return GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedFloor = i;
                                      _selectedSlot = null;
                                      final targetId = widget.locationId ?? CheckoutBackend.instance.locationId;
                                      SlotSelectionBackend.instance.fetchSlots(
                                        locationId: targetId,
                                        floorName: floors[i],
                                      );
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? (isDark ? Colors.white : _kPrimaryContainer)
                                            : (isDark ? theme.card : _kSurfaceContainerLowest),
                                        borderRadius: AppRadii.pillRadius,
                                        border: isDark && !active ? Border.all(color: theme.border) : null,
                                        boxShadow: const [AppShadows.soft],
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            floors[i],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: active
                                                  ? (isDark ? Colors.black : const Color(0xFFFCF9F2))
                                                  : (isDark ? Colors.white : const Color(0xFF45474A)),
                                            ),
                                          ),
                                          if (active) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF9A442D) : const Color(0xFFFC9174),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Terpilih',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? Colors.black87 : const Color(0xFFFCF9F2).withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        // Parking map canvas
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final floors = SlotSelectionBackend.instance.floors;
                            final activeFloorName = (floors.isNotEmpty && _selectedFloor < floors.length)
                                ? floors[_selectedFloor]
                                : 'Lantai 1';
                            final zoneASlots = SlotSelectionBackend.instance.zoneASlots;
                            final zoneBSlots = SlotSelectionBackend.instance.zoneBSlots;

                            final zoneAAvailable = zoneASlots.where((s) => s['status']?.toString().toLowerCase() == 'available').length;
                            final zoneBAvailable = zoneBSlots.where((s) => s['status']?.toString().toLowerCase() == 'available').length;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? theme.surfaceField : _kSurfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark ? Border.all(color: theme.border) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Zone A Header
                                  _ZoneLabel(
                                    label: 'Zona A (Posisi Atas)',
                                    count: '$zoneAAvailable Tersedia',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 8),

                                  // Baris Slot Zona A (Swipeable Horizontal, Tanpa Overflow)
                                  if (zoneASlots.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: isDark ? theme.card : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isDark ? theme.border : const Color(0xFFE5E7EB)),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.crop_free_rounded, size: 28, color: isDark ? theme.textMuted : const Color(0xFF94A3B8)),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Belum ada slot di Zona A ($activeFloorName)',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: zoneASlots.map((slot) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: SizedBox(
                                              width: 78,
                                              height: 104,
                                              child: _buildSlotCard(slot, isDark: isDark),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                  // Circulation aisle
                                  const SizedBox(height: 14),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDark ? theme.card : _kSurfaceContainerHigh.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                      border: isDark ? Border.all(color: theme.border) : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.east,
                                          size: 14,
                                          color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Jalur Sirkulasi $activeFloorName',
                                          style: AppTypography.caption(
                                            color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.navigation_outlined,
                                          size: 14,
                                          color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Satu Arah',
                                          style: AppTypography.caption(
                                            color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Zone B Header
                                  _ZoneLabel(
                                    label: 'Zona B (Posisi Bawah - EV Ready)',
                                    count: '$zoneBAvailable Tersedia',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 8),

                                  // Baris Slot Zona B (Swipeable Horizontal, Tanpa Overflow)
                                  if (zoneBSlots.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: isDark ? theme.card : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isDark ? theme.border : const Color(0xFFE5E7EB)),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.bolt_outlined, size: 28, color: Color(0xFF17A18A)),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Belum ada slot di Zona B ($activeFloorName)',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: zoneBSlots.map((slot) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: SizedBox(
                                              width: 78,
                                              height: 104,
                                              child: _buildSlotCard(slot, isDark: isDark),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                  // Legend
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _LegendItem(
                                        color: isDark ? theme.card : _kSurfaceContainerLowest,
                                        label: 'Tersedia',
                                        border: isDark ? Colors.white : const Color(0xFFC6C6CA),
                                        isDark: isDark,
                                      ),
                                      _LegendItem(
                                        color: isDark ? const Color(0xFF1E293B) : _kSurfaceContainerHigh.withValues(alpha: 0.6),
                                        label: 'Terisi Mobil',
                                        isDark: isDark,
                                      ),
                                      _LegendItem(
                                        color: const Color(0xFF114177),
                                        label: 'Pilihan Anda',
                                        isDark: isDark,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: MediaQuery.of(context).padding.bottom + 140),
                      ],
                    ),
                  ),
                ],
              ),

              // Fixed header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: isDark ? theme.bg : const Color(0xFFFCF9F2),
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark ? theme.card : _kSurfaceContainerHigh.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                    border: isDark ? Border.all(color: theme.border) : null,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 20,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Slot Selection',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom floating summary / CTA
              if (_selectedSlot != null)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: AppSpacing.pageH,
                  right: AppSpacing.pageH,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : _kSurfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          offset: const Offset(0, 16),
                          blurRadius: 40,
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL PEMBAYARAN AWAL',
                                  style: AppTypography.overline(
                                    color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyService.instance.format(
                                    SlotSelectionBackend.instance.getHourlyRateForSlot(_selectedSlot),
                                  ),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  '(1 Jam Pertama • ${SlotSelectionBackend.instance.getSlotTypeLabel(_selectedSlot)})',
                                  style: AppTypography.caption(
                                    color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final floors = SlotSelectionBackend.instance.floors;
                            final activeFloorName = (floors.isNotEmpty && _selectedFloor < floors.length)
                                ? floors[_selectedFloor]
                                : 'Lantai 1';
                            final loc = SlotSelectionBackend.instance.currentLocation;
                            final rate = SlotSelectionBackend.instance.getHourlyRateForSlot(_selectedSlot);
                            final slotType = SlotSelectionBackend.instance.getSlotTypeLabel(_selectedSlot);

                            final matchSlot = SlotSelectionBackend.instance.slots.firstWhere(
                              (s) => (s['slot_code']?.toString() ?? s['code']?.toString()) == _selectedSlot,
                              orElse: () => {},
                            );
                            final slotId = matchSlot['id']?.toString();

                            final now = DateTime.now();
                            final start = DateTime(now.year, now.month, now.day, now.hour, now.minute);
                            final endHour = (now.hour + 1).clamp(0, 23);
                            final endMinute = endHour == 23 ? 59 : now.minute;
                            final end = DateTime(now.year, now.month, now.day, endHour, endMinute);

                            CheckoutBackend.instance.setBookingDetails(
                              locationId: loc?['id']?.toString(),
                              locationName: loc?['name']?.toString() ?? 'Pakuwon Mall',
                              slotId: slotId,
                              slotCode: _selectedSlot ?? 'A-01',
                              floorName: activeFloorName,
                              slotType: slotType,
                              hourlyRate: rate,
                              durationHours: 1,
                              startTime: start,
                              endTime: end,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : _kPrimaryContainer,
                              borderRadius: AppRadii.pillRadius,
                              boxShadow: const [AppShadows.float],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Lanjut Bayar',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.black : const Color(0xFFFCF9F2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: isDark ? Colors.black : const Color(0xFFFCF9F2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot, {bool isDark = false}) {
    final theme = ThemeService.instance;
    final String slotCode = slot['slot_code']?.toString() ?? slot['code']?.toString() ?? '-';
    final statusStr = (slot['status']?.toString() ?? 'available').toLowerCase();
    final bool isAvailable = statusStr == 'available';
    final bool isSelected = _selectedSlot == slotCode;

    final slotTypeStr = (slot['slot_type']?.toString() ?? slot['type']?.toString() ?? 'mobil').toLowerCase();
    final bool isEV = slotTypeStr == 'ev';
    final bool isDifabel = slotTypeStr == 'difabel' || slotTypeStr.contains('disabilitas');
    final bool isMotor = slotTypeStr == 'motor';
    final bool isVip = slotTypeStr == 'vip';

    final Color badgeColor = isEV
        ? const Color(0xFF17A18A)
        : (isDifabel
            ? const Color(0xFF8B5CF6)
            : (isMotor
                ? const Color(0xFFF59E0B)
                : (isVip ? const Color(0xFFEAB308) : const Color(0xFF114177))));

    String typeLabel = 'Reguler';
    if (isEV) {
      typeLabel = '⚡ EV';
    } else if (isDifabel) {
      typeLabel = '♿ Difabel';
    } else if (isMotor) {
      typeLabel = '🛵 Motor';
    } else if (isVip) {
      typeLabel = '👑 VIP';
    }

    Color bg;
    Border? border;

    if (isSelected) {
      bg = const Color(0xFF114177);
      border = Border.all(color: const Color(0xFF114177), width: 1.5);
    } else if (!isAvailable) {
      bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
      border = Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    } else {
      bg = isDark ? theme.card : (isEV ? const Color(0xFFE8F7F4) : Colors.white);
      border = Border.all(
        color: isEV ? const Color(0xFF17A18A) : (isDark ? theme.border : const Color(0xFFE5E7EB)),
        width: isEV ? 1.5 : 1,
      );
    }

    return GestureDetector(
      onTap: isAvailable ? () => setState(() => _selectedSlot = isSelected ? null : slotCode) : null,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 78,
          height: 104,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: border,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF114177).withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ]
                : const [AppShadows.soft],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  typeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : badgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                slotCode,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1A1A18)),
                ),
              ),
              const SizedBox(height: 4),
              if (isSelected)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 10, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      'Pilihan',
                      style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                )
              else if (!isAvailable)
                Text(
                  'Terisi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                )
              else
                Text(
                  'Tersedia',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF17A18A),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final String label;
  final String count;
  final bool isDark;
  const _ZoneLabel({required this.label, required this.count, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isDark ? theme.textMuted : const Color(0xFF45474A),
          ),
        ),
        Text(
          count,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFFB923C) : _kSecondary,
          ),
        ),
      ],
    );
  }
}

class _AmenityBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _AmenityBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [AppShadows.soft]),
        child: Icon(icon, size: 16, color: const Color(0xFF002115)),
      );
}

class _CountBadge extends StatelessWidget {
  final String count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: Color(0xFFFC9174), shape: BoxShape.circle),
        child: Center(
          child: Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF742814),
            ),
          ),
        ),
      );
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color? border;
  final bool isDark;
  const _LegendItem({required this.color, required this.label, this.border, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: border != null ? Border.all(color: border!) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? theme.textMuted : const Color(0xFF45474A),
          ),
        ),
      ],
    );
  }
}
