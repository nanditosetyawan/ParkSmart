import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';

class AiResultsScreen extends StatelessWidget {
  const AiResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        return Scaffold(
          backgroundColor: theme.bg,
          appBar: AppBar(
            backgroundColor: theme.bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Hasil Rekomendasi AI',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF114177), Color(0xFF006A9A), Color(0xFF17A18A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Rekomendasi Terbaik',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Grand Indonesia - West Mall (Basement 1)',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paling sesuai dengan kriteria Anda: Akses cepat ke lobi, tersedia charger EV, dan tarif terjangkau.',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Reservasi Slot B-08 (EV)',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Alternatif Lain',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildAlternativeCard('Grand Indonesia - East Mall', 'Lebih jauh jalan kaki, namun tarif lebih murah (Rp 4.000/jam)', 'Tersedia 12 Slot', theme),
              const SizedBox(height: 12),
              _buildAlternativeCard('Plaza Indonesia', 'Bersebelahan, namun akses keluar masuk sedikit padat.', 'Tersedia 5 Slot', theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlternativeCard(String title, String desc, String status, ThemeService theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: theme.chipBg, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  status,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: theme.textMuted)),
        ],
      ),
    );
  }
}
