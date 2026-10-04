import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard, shape: BoxShape.circle,
                    border: Border.all(color: AppColors.warmBorder.withOpacity(0.6)),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
              const SizedBox(height: 28),
              Text('Daftar\nAkun Baru.',
                style: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('Isi data di bawah untuk mulai parkir pintar.', style: AppTypography.bodySm(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              _lbl('Nama Lengkap'),
              _pill('Sarah Natasha'),
              const SizedBox(height: 16),
              _lbl('Email'),
              _pill('nama@email.com', type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _lbl('No. Handphone'),
              _pill('0812 3456 7890', type: TextInputType.phone),
              const SizedBox(height: 16),
              _lbl('Kata Sandi'),
              _pill('Min. 8 karakter', obscure: true),
              const SizedBox(height: 16),
              _lbl('Plat Nomor Kendaraan'),
              _pill('B 1234 XYZ'),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: AppColors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Buat Akun', style: AppTypography.buttonLg(color: AppColors.white)),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward, size: 19),
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

  static Widget _lbl(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
  );

  static Widget _pill(String hint, {TextInputType? type, bool obscure = false}) => Container(
    height: 54,
    decoration: BoxDecoration(
      color: AppColors.surfaceCard, borderRadius: AppRadii.pillRadius,
      border: Border.all(color: AppColors.warmBorder), boxShadow: const [AppShadows.field],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      obscureText: obscure, keyboardType: type,
      decoration: InputDecoration(
        hintText: hint, border: InputBorder.none,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: const Color(0xFFA29F98)),
      ),
      style: GoogleFonts.plusJakartaSans(fontSize: 15),
    ),
  );
}
