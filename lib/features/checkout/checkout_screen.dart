import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_radii.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_typography.dart';
import '../booking/booking_confirmation_screen.dart';

const _kSurface = Color(0xFFFCF9F2);
const _kCard = Color(0xFFFFFFFF);
const _kSecondary = Color(0xFF9A442D);
const _kSecondaryFixed = Color(0xFFFFDBD2);
const _kPrimaryContainer = Color(0xFF1C1D1F);
const _kSurfaceContainerLow = Color(0xFFF6F3EC);
const _kSurfaceContainerHigh = Color(0xFFEBE8E1);
const _kOnSurfaceVariant = Color(0xFF45474A);
const _kOutline = Color(0xFF76777B);

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 72, 20, 120),
          children: [
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _kSecondaryFixed, borderRadius: AppRadii.pillRadius),
                child: Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: _kSecondary, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Slot Ditahan (09:59)', style: AppTypography.overline(color: const Color(0xFF742814))),
                ]),
              ),
              Text('Langkah 3 dari 3', style: AppTypography.caption(color: _kOutline)),
            ]),
            const SizedBox(height: 8),
            Text('Konfirmasi\nReservasi',
              style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.15)),
            const SizedBox(height: 4),
            Text('Tinjau detail parkir pintar Anda sebelum pembayaran otomatis diproses.',
              style: AppTypography.bodySm(color: _kOnSurfaceVariant)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withOpacity(0.06), offset: const Offset(0, 12), blurRadius: 32, spreadRadius: -8)],
              ),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: _kSurfaceContainerLow, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_parking, size: 26, color: _kSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('LOKASI TERPILIH', style: AppTypography.overline(color: _kOutline)),
                    Text('Central Park Mall', style: AppTypography.headlineSm()),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: _kSurfaceContainerHigh, borderRadius: AppRadii.pillRadius),
                    child: Row(children: [
                      const Icon(Icons.timelapse, size: 16, color: _kSecondary),
                      const SizedBox(width: 4),
                      Text('2 Jam', style: AppTypography.labelMd()),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(children: [
                    Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDT0ZoyfWQcaEzs6MHLz6cuAXmKYUfHvadgETmWMtDwDuHAQhgcLiExY2mDLfNdWUdhWJoyC0sIf_osQTNETlWG6QXuvrzt9oCMDE4d0CREPiJpum3drIn1rtXLXgLl4HsnxtgkPgDgSOSnvn7RdMvWizDgqYP7xfa9hk9A9VxzxR2LlzGcOZRirFyUW3QE4M98E7yAJBDEjo9mQJ74n_PbHdd95axOTGk3heFrVOSVwgMXU9tAad86',
                      width: double.infinity, height: 144, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 144, color: _kSurfaceContainerLow),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                        decoration: BoxDecoration(gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, _kPrimaryContainer.withOpacity(0.8)])),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Zona Parkir', style: AppTypography.overline(color: Colors.white.withOpacity(0.9))),
                            Text('Basement B2 - Slot A-05', style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: AppRadii.pillRadius),
                            child: Text('Sensor Aktif', style: AppTypography.caption(color: Colors.white)),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _kSurfaceContainerLow, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: _kOnSurfaceVariant),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('JADWAL KEDATANGAN', style: AppTypography.overline(color: _kOutline)),
                      Text('Hari ini, 24 Okt  14:00 - 16:00 WIB',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: _kSurfaceContainerLow, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.directions_car_outlined, size: 20, color: _kOnSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('KENDARAAN TERDAFTAR', style: AppTypography.overline(color: _kOutline)),
                      Text('Toyota Raize', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _kSurfaceContainerHigh, borderRadius: AppRadii.pillRadius),
                      child: Text('B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(16), boxShadow: const [AppShadows.soft]),
              child: Column(children: [
                _priceRow('Tarif Parkir', 'Rp 10.000'),
                _priceRow('Biaya Layanan', 'Rp 2.000'),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFEAE5DC))),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('TOTAL PEMBAYARAN', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  Text('Rp 12.000', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: _kSecondary)),
                ]),
              ]),
            ),
          ],
        ),
        Positioned(top: 0, left: 0, right: 0,
          child: SafeArea(bottom: false,
            child: Container(
              height: 64, color: _kSurface.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: _kSurfaceContainerHigh.withOpacity(0.6), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Checkout', style: AppTypography.headlineSm()),
              ]),
            ),
          ),
        ),
        Positioned(bottom: 0, left: 0, right: 0,
          child: SafeArea(top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              color: _kSurface,
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingConfirmationScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimaryContainer, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.pillRadius),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.lock_outline, size: 18),
                    const SizedBox(width: 8),
                    Text('Konfirmasi Bayar Sekarang',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  static Widget _priceRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _kOnSurfaceVariant)),
      Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1C1D1F))),
    ]),
  );
}
