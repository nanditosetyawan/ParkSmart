import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiResultsScreen extends StatelessWidget {
  const AiResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF14202B)), onPressed: () => Navigator.pop(context)),
        title: Text('Hasil Rekomendasi AI', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF14202B))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF114177), Color(0xFF006A9A), Color(0xFF17A18A)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Rekomendasi Terbaik', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Grand Indonesia - West Mall (Basement 1)', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Paling sesuai dengan kriteria Anda: Akses cepat ke lobi, tersedia charger EV, dan tarif terjangkau.', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Reservasi Slot B-08 (EV)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Alternatif Lain', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF14202B))),
          const SizedBox(height: 12),
          _buildAlternativeCard('Grand Indonesia - East Mall', 'Lebih jauh jalan kaki, namun tarif lebih murah (Rp 4.000/jam)', 'Tersedia 12 Slot'),
          const SizedBox(height: 12),
          _buildAlternativeCard('Plaza Indonesia', 'Bersebelahan, namun akses keluar masuk sedikit padat.', 'Tersedia 5 Slot'),
        ],
      ),
    );
  }

  Widget _buildAlternativeCard(String title, String desc, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD8DEE5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF14202B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
