import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/supabase_storage_service.dart';
import '../../core/services/language_service.dart';
import '../vehicle/add_vehicle_screen.dart';
import '../history/verified_parking_sessions_screen.dart';
import 'backend/vehicle_backend.dart';

class VehicleScreen extends StatefulWidget {
  final bool isSelectionMode;
  const VehicleScreen({super.key, this.isSelectionMode = false});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    VehicleBackend.instance.fetchVehicles();
  }

  /// Upload foto kendaraan yang sudah ada
  Future<void> _uploadPhotoForVehicle(String vehicleId) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked == null) return;

      setState(() => _isUploadingPhoto = true);

      final rawBytes = await picked.readAsBytes();

      final photoUrl = await SupabaseStorageService.instance.uploadVehiclePhoto(
        rawBytes: rawBytes,
        userId: vehicleId, // path unique per vehicle
      );

      if (photoUrl != null) {
        await VehicleBackend.instance.updateVehiclePhoto(vehicleId, photoUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto kendaraan berhasil diupload!'.tr),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengupload foto kendaraan'.tr),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  /// Widget foto kendaraan: tampilkan foto nyata atau placeholder
  Widget _buildVehiclePhotoWidget(String? photoUrl, String vehicleId, bool isDark) {
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    return GestureDetector(
      onTap: _isUploadingPhoto ? null : () => _uploadPhotoForVehicle(vehicleId),
      child: Stack(
        children: [
          Container(
            height: 176,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 176,
                      errorBuilder: (_, e, s) => _photoPlaceholder(isDark),
                    ),
                  )
                : _photoPlaceholder(isDark),
          ),
          // Overlay "Ganti Foto" atau "Tambah Foto" di pojok kanan atas
          Positioned(
            top: 10,
            right: 10,
            child: _isUploadingPhoto
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          hasPhoto ? 'Ganti Foto'.tr : 'Tambah Foto'.tr,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap untuk tambah foto'.tr,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteVehiclePopup(BuildContext context, [String? vehicleId]) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
    final targetId = vehicleId ?? VehicleBackend.instance.defaultVehicle?.id ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hapus Kendaraan?'.tr,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apakah Anda yakin ingin menghapus kendaraan ini?'.tr,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? theme.surfaceField : const Color(0xFF1C1C18),
                        borderRadius: BorderRadius.circular(24),
                        border: isDark ? Border.all(color: theme.border) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Batal'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? theme.textPrimary : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      if (targetId.isNotEmpty) {
                        await VehicleBackend.instance.deleteVehicle(targetId);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kendaraan berhasil dihapus'.tr)),
                        );
                      }
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935), // Red
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Hapus'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, VehicleBackend.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: theme.bg,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.bg.withValues(alpha: 0.95),
                    border: Border(bottom: BorderSide(color: theme.border.withValues(alpha: 0.5))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
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
                                color: theme.chipBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.arrow_back, size: 20, color: theme.iconColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Icon(Icons.local_parking, size: 24, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177)),
                              const SizedBox(width: 8),
                              Text(
                                widget.isSelectionMode ? 'Pilih Kendaraan'.tr : 'Live Spot Details',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(top: 16, bottom: 120),
                children: [
                  // Title Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isSelectionMode ? 'PILIH KENDARAAN PARKIR'.tr : 'GARASI DIGITAL'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              widget.isSelectionMode ? 'Pilih Kendaraan Anda'.tr : 'Kendaraan Terdaftar'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (VehicleBackend.instance.vehicles.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: theme.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_car_outlined,
                                size: 36,
                                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Belum Ada Kendaraan Terdaftar'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan nomor plat kendaraan Anda untuk kemudahan deteksi otomatis gate ANPR dan reservasi slot parkir.'.tr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: theme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.border),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF1C1D1F).withValues(alpha: 0.06),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFBBEED4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      size: 14,
                                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF1F4F3C),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Kendaraan Utama'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF1F4F3C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final prim = VehicleBackend.instance.defaultVehicle;
                                  if (prim != null) {
                                    _showVehicleOptions(context, prim, true);
                                  } else {
                                    _showDeleteVehiclePopup(context);
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isDark ? theme.surfaceField : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.border),
                                  ),
                                  child: Icon(Icons.more_horiz, size: 18, color: theme.iconColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Foto kendaraan utama — dari storage atau placeholder
                          Stack(
                            children: [
                              _buildVehiclePhotoWidget(
                                VehicleBackend.instance.defaultVehicle?.photoUrl,
                                VehicleBackend.instance.defaultVehicle?.id ?? '',
                                isDark,
                              ),
                              // Label nama kendaraan di pojok kiri bawah
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF020304).withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.directions_car, size: 14, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        VehicleBackend.instance.defaultVehicle != null
                                            ? VehicleBackend.instance.defaultVehicle!.displayName
                                            : '',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    VehicleBackend.instance.defaultVehicle?.plateNumber ?? 'B 8899 DTO',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${VehicleBackend.instance.defaultVehicle?.color ?? 'Abu-Abu Metalik'} • Milik Pribadi'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.zero,
                            decoration: const BoxDecoration(color: Colors.transparent),
                            child: Column(
                              children: [
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDark ? theme.surfaceField : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: theme.border),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Golongan Tarif'.tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Gol. I (${(VehicleBackend.instance.defaultVehicle?.category ?? 'SUV').toUpperCase()})'.tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isDark ? theme.surfaceField : Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: theme.border),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Masa Berlaku'.tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(top: 2),
                                                    child: Icon(Icons.verified, size: 16, color: Color.fromARGB(255, 122, 211, 167)),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      (VehicleBackend.instance.defaultVehicle?.plateExpiry != null &&
                                                              VehicleBackend.instance.defaultVehicle!.plateExpiry.isNotEmpty)
                                                          ? VehicleBackend.instance.defaultVehicle!.plateExpiry.tr
                                                          : 'Aktif Selamanya'.tr,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: theme.textPrimary,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
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
                              ],
                            ),
                          ),
                          if (widget.isSelectionMode) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final prim = VehicleBackend.instance.defaultVehicle;
                                  if (prim != null) {
                                    Navigator.pop(context, prim);
                                  }
                                },
                                icon: const Icon(Icons.check_circle_rounded, size: 20),
                                label: Text(
                                  'Gunakan Kendaraan Ini'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VerifiedParkingSessionsScreen(
                                          vehicleId: VehicleBackend.instance.defaultVehicle?.id,
                                          vehicleItem: VehicleBackend.instance.defaultVehicle,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isDark ? theme.surfaceField : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: theme.border),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.history, size: 18, color: theme.iconColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Riwayat Parkir'.tr,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textPrimary,
                                          ),
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
                  ),
                  const SizedBox(height: 20),
                  // Kendaraan Cadangan (Hanya muncul jika di database terdapat lebih dari 1 kendaraan)
                  if (VehicleBackend.instance.vehicles.length > 1) ...[
                    ...VehicleBackend.instance.vehicles.where((v) => v.id != (VehicleBackend.instance.defaultVehicle?.id ?? '')).map((secVehicle) {
                      return _buildSecondaryVehicleCard(context, secVehicle, isDark, theme);
                    }),
                  ],
                  const SizedBox(height: 20),
                  ],
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.bg.withValues(alpha: 0.0),
                        theme.bg.withValues(alpha: 0.9),
                        theme.bg,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
                        await VehicleBackend.instance.fetchVehicles();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF020304),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        elevation: 12,
                        shadowColor: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Tambah Kendaraan Baru'.tr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
      ],
    ),
  ),
);
      },
    );
  }

  void _showVehicleOptions(BuildContext context, VehicleItem vehicle, bool isPrimary) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              vehicle.displayName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            Text(
              vehicle.plateNumber,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (!isPrimary) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.stars, color: Color(0xFF10B981), size: 22),
                ),
                title: Text(
                  'Jadikan Kendaraan Utama'.tr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Pilihan default otomatis untuk setiap reservasi parkir'.tr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final ok = await VehicleBackend.instance.setDefaultVehicle(vehicle.id);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${vehicle.displayName} sekarang menjadi kendaraan utama.'),
                        backgroundColor: const Color(0xFF15803D),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 24),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
              ),
              title: Text(
                'Hapus Kendaraan'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEF4444),
                ),
              ),
              subtitle: Text(
                'Hapus kendaraan ini dari daftar garasi Anda'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: theme.textSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteVehiclePopup(context, vehicle.id);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryVehicleCard(BuildContext context, VehicleItem vehicle, bool isDark, dynamic theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF1C1D1F).withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cadangan'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showVehicleOptions(context, vehicle, false),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? theme.surfaceField : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.border),
                    ),
                    child: Icon(Icons.more_horiz, size: 18, color: theme.iconColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Foto kendaraan cadangan — dari storage atau placeholder
            Stack(
              children: [
                _buildVehiclePhotoWidget(
                  vehicle.photoUrl,
                  vehicle.id,
                  isDark,
                ),
                // Label nama kendaraan di pojok kiri bawah
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020304).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          vehicle.vehicleType.toLowerCase().contains('motor') ? Icons.two_wheeler : Icons.directions_car,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.displayName,
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.plateNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      '${vehicle.color} • Milik Pribadi'.tr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? theme.surfaceField : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Golongan Tarif'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Gol. I (${vehicle.category.toUpperCase()})'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? theme.surfaceField : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Masa Berlaku'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(Icons.verified, size: 16, color: Color.fromARGB(255, 122, 211, 167)),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        vehicle.plateExpiry.isNotEmpty ? vehicle.plateExpiry.tr : 'Aktif Selamanya'.tr,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                ],
              ),
            ),
            if (widget.isSelectionMode) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, vehicle);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    'Gunakan Kendaraan Ini'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifiedParkingSessionsScreen(
                            vehicleId: vehicle.id,
                            vehicleItem: vehicle,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? theme.surfaceField : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 18, color: theme.iconColor),
                          const SizedBox(width: 8),
                          Text(
                            'Riwayat Parkir'.tr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final ok = await VehicleBackend.instance.setDefaultVehicle(vehicle.id);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${vehicle.displayName} berhasil dijadikan Kendaraan Utama!'),
                            backgroundColor: const Color(0xFF15803D),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F766E) : const Color(0xFF114177),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Text(
                          'Jadikan Utama'.tr,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}