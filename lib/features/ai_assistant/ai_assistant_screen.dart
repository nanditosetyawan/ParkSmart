import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_results_screen.dart';
import '../home/home_screen.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF14202B)), onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false)),
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: Color(0xFF17A18A)),
            const SizedBox(width: 8),
            Text('AI Parking Assistant', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF14202B))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAiMessage('Halo! Saya AI ParkSmart. Lokasi mana yang ingin Anda tuju hari ini?'),
                const SizedBox(height: 16),
                _buildUserMessage('Saya mau ke Grand Indonesia jam 2 siang.'),
                const SizedBox(height: 16),
                _buildAiMessage('Baik. Pada jam 14:00, Grand Indonesia (West Mall) diprediksi padat (Surge). Namun ada 12 slot EV dan 5 slot reguler yang bisa direservasi dari sekarang. Ingin saya bantu reservasi?'),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiResultsScreen())),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text('Ya, Lihat Rekomendasi (PS-10)', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFD8DEE5)))),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F3F3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Ketik pesan...', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(color: Color(0xFF114177), shape: BoxShape.circle),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.smart_toy, size: 16, color: Color(0xFF17A18A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF14202B))),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildUserMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF114177),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
