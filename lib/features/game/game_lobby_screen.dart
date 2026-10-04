import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameLobbyScreen extends StatelessWidget {
  const GameLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF475569))), child: const Icon(Icons.arrow_back, color: Color(0xFFE2E8F0))),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF114177), Color(0xFF006A9A), Color(0xFF17A18A)]), borderRadius: BorderRadius.circular(32)),
                  child: const Center(child: Icon(Icons.sports_esports, size: 64, color: Colors.white)),
                ),
                const SizedBox(height: 24),
                Text('PARKSMART ARCADE', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF34D399), letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('Uji kemampuan parkir Anda & menangkan SmartPoints!', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8))),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17A18A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('MAINKAN SEKARANG', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFBBF24), size: 20),
                      const SizedBox(width: 8),
                      Text('High Score: 14,500', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFFBBF24))),
                    ],
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
