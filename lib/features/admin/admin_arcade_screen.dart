import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArcadeAdminScreen extends StatefulWidget {
  const ArcadeAdminScreen({super.key});

  @override
  State<ArcadeAdminScreen> createState() => _ArcadeAdminScreenState();
}

class _ArcadeAdminScreenState extends State<ArcadeAdminScreen> {
  bool _isMiniGameActive = true;
  bool _isQuizActive = true;
  bool _isCheckinStreakActive = true;

  final TextEditingController _rank1Ctrl = TextEditingController(text: '500');
  final TextEditingController _participationCtrl = TextEditingController(text: '50');
  final TextEditingController _pointRateCtrl = TextEditingController(text: '10');

  @override
  void dispose() {
    _rank1Ctrl.dispose();
    _participationCtrl.dispose();
    _pointRateCtrl.dispose();
    super.dispose();
  }

  void _saveArcadeSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konfigurasi reward & gamifikasi berhasil disimpan!'),
        backgroundColor: Color(0xFF17A18A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arcade & Rewards', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Manajemen Gamifikasi & SmartPoints', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Stat Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Poin Ditukarkan', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                      const SizedBox(height: 4),
                      Text('342.800 Pts', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      const SizedBox(height: 4),
                      Text('Setara Rp 3.428.000 voucher', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF17A18A))),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5A33D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.stars, color: Color(0xFFE5A33D), size: 26),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Features Toggle
          Text('Status Fitur Gamifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Mini Game Mobil (ParkSmart Arcade)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Pengguna dapat bermain game simulasi saat menunggu', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _isMiniGameActive,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _isMiniGameActive = v),
                ),
                const Divider(color: Color(0xFFF1EEE7), height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Kuis Harian & Tips Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Pertanyaan trivia keselamatan berkendara', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _isQuizActive,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _isQuizActive = v),
                ),
                const Divider(color: Color(0xFFF1EEE7), height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Bonus Streak Check-in 7 Hari', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Hadiah berlipat untuk parkir rutin berturut-turut', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _isCheckinStreakActive,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _isCheckinStreakActive = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Configuration Input
          Text('Pengaturan Nilai SmartPoints', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Column(
              children: [
                _buildInputRow('Reward Peringkat 1 Harian (Pts)', _rank1Ctrl),
                const SizedBox(height: 12),
                _buildInputRow('Reward Partisipasi Game (Pts)', _participationCtrl),
                const SizedBox(height: 12),
                _buildInputRow('Konversi 1 Poin = (Rp)', _pointRateCtrl),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: _saveArcadeSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF114177),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_outlined, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text('Simpan Pengaturan Arcade', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController ctrl) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EEE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 10)),
            ),
          ),
        ),
      ],
    );
  }
}
