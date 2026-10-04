import 'package:flutter/material.dart';
import '../session/expiring_session_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF14202B)), onPressed: () => Navigator.pop(context)),
        title: Text('Pusat Notifikasi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF14202B))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Simulated Push Notification entry for Expiring Session
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiringSessionScreen()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sesi Berakhir Segera', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF1C1D1F))),
                  const Icon(Icons.chevron_right, color: Color(0xFF1C1D1F)),
                ],
              ),
            ),
          ),

          _buildNotification(
            icon: Icons.timer,
            color: const Color(0xFFE5A33D),
            title: 'Waktu Parkir Hampir Habis',
            message: 'Sesi parkir Anda di Grand Indonesia akan berakhir dalam 15 menit. Ketuk untuk perpanjang.',
            time: '15 Menit Lalu',
            isNew: true,
          ),
          const SizedBox(height: 12),
          _buildNotification(
            icon: Icons.local_offer,
            color: const Color(0xFF17A18A),
            title: 'Promo Akhir Pekan',
            message: 'Dapatkan diskon 20% untuk parkir di seluruh mall area Jakarta Pusat menggunakan ParkSmart Pay.',
            time: '1 Hari Lalu',
            isNew: false,
          ),
          const SizedBox(height: 12),
          _buildNotification(
            icon: Icons.check_circle,
            color: const Color(0xFF006A9A),
            title: 'Pembayaran Berhasil',
            message: 'Pembayaran sebesar Rp 15.000 untuk parkir di Central Park telah berhasil.',
            time: '3 Hari Lalu',
            isNew: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotification({required IconData icon, required Color color, required String title, required String message, required String time, required bool isNew}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? color.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isNew ? color.withValues(alpha: 0.3) : const Color(0xFFD8DEE5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF14202B))),
                    if (isNew) Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(message, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                const SizedBox(height: 8),
                Text(time, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
