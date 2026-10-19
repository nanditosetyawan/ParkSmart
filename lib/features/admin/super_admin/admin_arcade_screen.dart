import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArcadeAdminScreen extends StatefulWidget {
  const ArcadeAdminScreen({super.key});

  @override
  State<ArcadeAdminScreen> createState() => _ArcadeAdminScreenState();
}

class _ArcadeAdminScreenState extends State<ArcadeAdminScreen> {
  // Toggle Status Game
  bool _isParkingGameActive = true;
  bool _isClawsGameActive = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isParkingGameActive = prefs.getBool('arcade_parking_active') ?? true;
        _isClawsGameActive = prefs.getBool('arcade_claws_active') ?? true;
      });
    }
  }

  Future<void> _saveArcadeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('arcade_parking_active', _isParkingGameActive);
    await prefs.setBool('arcade_claws_active', _isClawsGameActive);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfigurasi akses permainan berhasil disimpan!'),
          backgroundColor: Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Arcade & Hadiah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Super Admin · Kontrol Akses Permainan Arcade',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── INFO CARD: ATURAN KONVERSI SISTEM (HARDCODED) ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              
            ),
            const SizedBox(height: 20),

            // ─── SEGMEN KONTROL AKSES PERMAINAN ───
            Row(
              children: [
                Text(
                  'Katalog & Kontrol Akses Game',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
              
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Aktifkan atau matikan ketersediaan game arcade untuk pengguna',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),

            // CARD GAME 1: Game Mobil (Parking Challenge)
            _buildGameCard(
              title: 'Parking Challenge (Game Mobil)',
              subtitle: 'Simulasi manuver & parkir mobil 2D',
              icon: Icons.directions_car_rounded,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              isActive: _isParkingGameActive,
              onToggle: (v) => setState(() => _isParkingGameActive = v),
              description: 'Pengguna dapat bermain game simulasi parkir mobil untuk mengumpulkan poin reward harian.',
            ),
            const SizedBox(height: 14),

            // CARD GAME 2: Claws Car (Mesin Capit Mobil)
            _buildGameCard(
              title: 'Claws Car (Mesin Capit Mobil)',
              subtitle: 'Arcade capit virtual berhadiah uang rupiah & miniatur',
              icon: Icons.precision_manufacturing_rounded,
              iconBg: const Color(0xFFFAF5FF),
              iconColor: const Color(0xFF9333EA),
              isActive: _isClawsGameActive,
              onToggle: (v) => setState(() => _isClawsGameActive = v),
              description: 'Pengguna menggunakan claw machine virtual untuk mencapit hadiah uang tunai rupiah dan masuk ke saldo.',
            ),
            const SizedBox(height: 28),

            // ─── TOMBOL SIMPAN PENGATURAN ───
            ElevatedButton(
              onPressed: _saveArcadeSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Simpan Pengaturan Arcade',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required bool isActive,
    required ValueChanged<bool> onToggle,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFFE2E8F0) : const Color(0xFFFECACA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Name & Toggle Switch
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isActive,
                activeThumbColor: const Color(0xFF0F172A),
                activeTrackColor: const Color(0xFFCBD5E1),
                onChanged: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Status Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                  size: 13,
                  color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 5),
                Text(
                  isActive
                      ? 'Status: Aktif (Pengguna dapat bermain)'
                      : 'Status: Nonaktif (Terkunci untuk pengguna)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
