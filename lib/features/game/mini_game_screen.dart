import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                border: const Border(bottom: BorderSide(color: Color(0xFF334155))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF475569))),
                        child: const Icon(Icons.arrow_back, color: Color(0xFFE2E8F0), size: 20),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF114177), Color(0xFF006A9A), Color(0xFF17A18A)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('PARKSMART ARCADE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF34D399), letterSpacing: 1)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.2), border: Border.all(color: const Color(0xFF17A18A).withValues(alpha: 0.4)), borderRadius: BorderRadius.circular(12)),
                                child: Text('Mini Game', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Level 3: Mall Basement A-05', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(width: 6),
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), border: Border.all(color: const Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: Color(0xFFFBBF24), size: 16),
                            const SizedBox(width: 8),
                            Text('WAKTU', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                            const SizedBox(width: 8),
                            Text('00:45', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFFCD34D))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), border: Border.all(color: const Color(0xFF334155)), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFF34D399), size: 16),
                            const SizedBox(width: 8),
                            Text('SKOR', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                            const SizedBox(width: 8),
                            Text('1.450 pts', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                        child: const Icon(Icons.volume_up, color: Color(0xFFCBD5E1), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                        child: const Icon(Icons.pause, color: Color(0xFFE2E8F0), size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Game Area (Arena)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A222D),
                ),
                child: Stack(
                  children: [
                    // Road Divider
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 4,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Center(
                      child: Text('LAJUR KENDARAAN SATU ARAH', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 2)),
                    ),

                    // Top Row Slots
                    Positioned(
                      top: 16, left: 40,
                      child: Row(
                        children: [
                          _buildOccupiedSlot('A-01', 'B 2341 S', const Color(0xFFE2E8F0), const Color(0xFF1E293B)),
                          const SizedBox(width: 20),
                          _buildOccupiedSlot('A-02', 'B 9871 Z', const Color(0xFF1D4ED8), const Color(0xFF0F172A)),
                          const SizedBox(width: 20),
                          _buildReservedSlot('A-03'),
                          const SizedBox(width: 20),
                          _buildOccupiedSlot('A-04', 'B 4410 TX', const Color(0xFF065F46), const Color(0xFF022C22)),
                          const SizedBox(width: 20),
                          _buildTargetSlot('A-05'),
                        ],
                      ),
                    ),

                    // Pillar
                    Positioned(
                      top: 40, left: 260,
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF64748B), width: 2)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('P-12', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFFFCD34D))),
                            Container(width: 32, height: 4, color: const Color(0xFFFBBF24)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupiedSlot(String id, String plate, Color carColor, Color windowColor) {
    return Container(
      width: 112, height: 176,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF450A0A).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.7), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF87171))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4))),
                child: Text('TERISI', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFFF87171))),
              ),
            ],
          ),
          Container(
            width: 64, height: 112,
            decoration: BoxDecoration(color: carColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF94A3B8), width: 2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 48, height: 24, color: windowColor),
                Text(plate, style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.bold, color: windowColor == const Color(0xFF1E293B) ? const Color(0xFF1E293B) : Colors.white)),
                Container(width: 48, height: 16, color: windowColor),
              ],
            ),
          ),
          Text('Kendaraan', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildReservedSlot(String id) {
    return Container(
      width: 112, height: 176,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF475569), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(4)),
                child: Text('RESERVASI', style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFFCBD5E1))),
              ),
            ],
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF59E0B), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFCD34D), width: 2)),
            child: Center(
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle)),
                ),
              ),
            ),
          ),
          Text('Tutup (Khusus)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
        ],
      ),
    );
  }

  Widget _buildTargetSlot(String id) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 128, height: 176,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF022C22).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF17A18A).withValues(alpha: 0.3 + 0.3 * _pulseController.value),
                blurRadius: 15 + 10 * _pulseController.value,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(id, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.5))),
                    child: Text('TARGET', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF6EE7B7), letterSpacing: 1)),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.keyboard_arrow_down, color: const Color(0xFF34D399), size: 24),
                  Container(
                    width: 80, height: 112,
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.8), style: BorderStyle.solid)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SENSOR ANPR', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
                          Text('AKTIF', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
