import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../vehicle/add_vehicle_screen.dart';
import '../history/verified_parking_sessions_screen.dart';
import 'backend/vehicle_backend.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  @override
  void initState() {
    super.initState();
    VehicleBackend.instance.fetchVehicles();
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
              'Hapus Kendaraan?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apakah Anda yakin ingin menghapus kendaraan ini?',
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
                        'Batal',
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
                          const SnackBar(content: Text('Kendaraan berhasil dihapus')),
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
                        'Hapus',
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
      listenable: Listenable.merge([ThemeService.instance, VehicleBackend.instance]),
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
                                'Live Spot Details',
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
                              'GARASI DIGITAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Kendaraan Terdaftar',
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
                              'Belum Ada Kendaraan Terdaftar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan nomor plat kendaraan Anda untuk kemudahan deteksi otomatis gate ANPR dan reservasi slot parkir.',
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
                                      'Kendaraan Utama',
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
                                onTap: () => _showDeleteVehiclePopup(context, VehicleBackend.instance.defaultVehicle?.id),
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
                          Container(
                            height: 176,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(
                                  (VehicleBackend.instance.defaultVehicle?.photoUrl != null &&
                                          VehicleBackend.instance.defaultVehicle!.photoUrl!.isNotEmpty)
                                      ? VehicleBackend.instance.defaultVehicle!.photoUrl!
                                      : 'https://lh3.googleusercontent.com/aida-public/AB6AXuAVnuwsaKhsc7ics-r8dq6xuhI1zrkeHWSoZpyeq7EGmKQYw_C4-dH5RuUyb8nRM_xEGAiy_s1PFU9iUZV8tTt6--jZfseZAh0cZzgeIN9Xb1Ast9BcH5Cokm2HgwLn_xJgSfbo-f_0EtvOuGrZhDzpZKtCkpM02ODxLjayW4pG6ArEONBVHlKbqLWK-KfYXVz7aTTfb1ng9nNOIsi0YE8MOPywan78pT3axi0Zbww-sKrIymmec4yi',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: const EdgeInsets.all(10),
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
                                          ? '${VehicleBackend.instance.defaultVehicle!.brand} ${VehicleBackend.instance.defaultVehicle!.model}'
                                          : 'Toyota Raize',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                                    '${VehicleBackend.instance.defaultVehicle?.color ?? 'Abu-Abu Metalik'} • Milik Pribadi',
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
                                                'Golongan Tarif',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Gol. I (Sedan/SUV)',
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
                                                'Masa Berlaku',
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
                                                      'Aktif Selamanya',
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifiedParkingSessionsScreen()));
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
                                          'Riwayat Parkir',
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
                  
                  // Secondary Vehicle Card
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
                                decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 6),
                                    Text('Cadangan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showDeleteVehiclePopup(context),
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
                          Container(
                            height: 176,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuC2INE8soV5VtERzFqCq_woOBEfGDmI5Zu-0dlqbVRg78Q1EudTkTem9Zx80i7YIm2eL9NcERR6RzY3I2bOkWGhGl8rVoWjDsnMoG7WNCBH2Qjk4MNvriFmYoryaKcCmrhRa4jrlyHvb1yR_SIgHAaMl7Vi1aoO60Yeg8k74Z5y5UH0-9Zr90aHvJR6HXs7_C2e6pTZ4IlXF-_WOW9eQ4kdt2OEBPyzBvtfNkO6j4lO4Yv4WSSFX_au'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: const EdgeInsets.all(10),
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
                                    Text('Honda HR-V', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
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
                                    'B 5678 KLM',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Abu-Abu Metalik • Milik Pribadi',
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
                                                'Golongan Tarif',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: theme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Gol. I (Sedan/SUV)',
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
                                                'Masa Berlaku',
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
                                                      'Aktif Selamanya',
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifiedParkingSessionsScreen()));
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
                                          'Riwayat Parkir',
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
                                  onTap: () {},
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F766E) : const Color(0xFF1F4F3C),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Jadikan Utama',
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
                  ),
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
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
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
                            'Tambah Kendaraan Baru',
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
}