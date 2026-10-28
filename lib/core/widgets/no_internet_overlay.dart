import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/network_security_service.dart';
import '../services/language_service.dart';

/// Overlay Pop-up Pengaman Jaringan Global (User & Admin)
/// Muncul otomatis di atas seluruh layar saat internet tidak tersedia,
/// dan otomatis tertutup saat internet pulih kembali.
class NoInternetOverlay extends StatelessWidget {
  const NoInternetOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NetworkSecurityService.instance,
      builder: (context, _) {
        final service = NetworkSecurityService.instance;
        if (service.hasConnection) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1E232B) : Colors.white;
        final titleColor = isDark ? Colors.white : const Color(0xFF1A1A18);
        final descColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF5A5B60);

        return PopScope(
          canPop: false,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                // 1. Semi-transparent Backdrop & Blur Filter
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.65),
                    ),
                  ),
                ),

                // 2. Center Modal Dialog Box
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Ikon Wi-Fi Putus / Sinyal Hilang
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE8E4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFCA5A5),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.wifi_off_rounded,
                                size: 38,
                                color: Color(0xFFD94B4B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Badge Status: KONEKSI TERPUTUS
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'TIDAK ADA KONEKSI'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFDC2626),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Judul Pop-up
                          Text(
                            'Internet Tidak Tersedia'.tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Isi Pesan Penjelasan
                          Text(
                            'Koneksi internet Anda terputus. Pastikan perangkat Anda terhubung ke jaringan Wi-Fi atau data seluler untuk melanjutkan penggunaan ParkSmart.'.tr,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: descColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tombol 1: Cek Jaringan (Biru Utama)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                service.openNetworkSettings();
                              },
                              icon: const Icon(
                                Icons.settings_suggest_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Cek Jaringan'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF114177),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Tombol 2: Keluar Aplikasi (Merah Danger)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                service.exitApp();
                              },
                              icon: const Icon(
                                Icons.exit_to_app_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Keluar Aplikasi'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD94B4B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Tombol / Indikator Coba Hubungkan Ulang (Manual Retry)
                          GestureDetector(
                            onTap: service.isChecking
                                ? null
                                : () => service.checkConnection(force: true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (service.isChecking) ...[
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF114177)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Memeriksa koneksi...'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                                      ),
                                    ),
                                  ] else ...[
                                    Icon(
                                      Icons.refresh_rounded,
                                      size: 16,
                                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Coba Hubungkan Lagi'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ],
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
          ),
        );
      },
    );
  }
}
