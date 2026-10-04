import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArcadeAdminScreen extends StatelessWidget {
  const ArcadeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, size: 16, color: Color(0xFF114177)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                Text('Akun / Admin', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Kontrol Arcade & Rewards', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status Mini Game (PS-20)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    Switch(value: true, onChanged: (val) {}, activeThumbColor: const Color(0xFF17A18A)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Aktifkan game ini untuk memungkinkan pengguna mendapatkan SmartPoints tambahan saat waktu luang.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Konfigurasi Hadiah (SmartPoints)', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 12),

          _buildConfigItem('Reward Peringkat 1 Harian', '500 Pts'),
          const SizedBox(height: 8),
          _buildConfigItem('Reward Partisipasi (Main 3x)', '50 Pts'),
          const SizedBox(height: 8),
          _buildConfigItem('Faktor Konversi Poin ke Rupiah', '1 Pts = Rp 10'),
          
        ],
      ),
    );
  }

  Widget _buildConfigItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF006A9A))),
        ],
      ),
    );
  }
}
