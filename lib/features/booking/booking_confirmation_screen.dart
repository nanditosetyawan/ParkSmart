import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../session/checkin_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Utility Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFBBEED4), borderRadius: AppRadii.pillRadius),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFF002115)),
                        const SizedBox(width: 6),
                        Text('Reservasi Berhasil', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF002115))),
                      ],
                    ),
                  ),
                  _NavBtn(icon: Icons.share_outlined, onTap: () {}),
                ],
              ),
              const SizedBox(height: 24),
              
              // Editorial Headline
              Text('KONFIRMASI KEDATANGAN', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('Slot Siap\nUntuk Anda.', style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('Akses parkir tanpa sentuh aktif otomatis di gerbang masuk.', style: AppTypography.bodySm(color: AppColors.textSecondary)),
              const SizedBox(height: 28),

              // Floating Digital Parking Pass Ticket
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [AppShadows.float],
                ),
                child: Column(
                  children: [
                    // Top Header Ribbon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_parking, size: 20, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Text('DIGITAL PARKING PASS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.0)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: AppRadii.pillRadius, boxShadow: const [AppShadows.soft]),
                            child: Text('#PS-88210-CP', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                    ),
                    
                    // QR Code Area
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [

                          
                          // Ticket Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LOKASI PARKIR', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
                                  Text('Central Park Mall', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
                                  Text('South Lobby, Basement B2', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(color: const Color(0xFFFFDBD2).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  children: [
                                    Text('SLOT', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF7C2E19), letterSpacing: 1.0)),
                                    Text('A-05', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF742814))),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _InfoBox(icon: Icons.directions_car, label: 'Kendaraan', title: 'Toyota Raize', subtitle: 'B 1234 XYZ', subtitleColor: AppColors.secondary)),
                              const SizedBox(width: 12),
                              Expanded(child: _InfoBox(icon: Icons.schedule, label: 'Waktu Valid', title: '14:00 - 16:00', subtitle: 'Toleransi +15 mnt')),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              

              // CTA
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckinScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Check-in', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 52,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1EEE7), foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text('Simpan Saja', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: AppColors.surfaceCard, shape: BoxShape.circle, boxShadow: const [AppShadows.soft]),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final Color? subtitleColor;

  const _InfoBox({required this.icon, required this.label, required this.title, required this.subtitle, this.subtitleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E2DB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: subtitleColor ?? AppColors.textSecondary)),
        ],
      ),
    );
  }
}
