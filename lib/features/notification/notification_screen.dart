import 'package:flutter/material.dart';
import '../session/expiring_session_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE5E2DB))),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1C1C18), size: 20),
          ), 
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Simulated Push Notification entry for Expiring Session
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpiringSessionScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C18),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF1C1C18).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.timer_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sesi Berakhir Segera', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Ketuk untuk melihat detail', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),

          Text('Hari Ini', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFA29F98))),
          const SizedBox(height: 16),
          
          _buildNotification(
            icon: Icons.access_time_filled,
            color: const Color(0xFFD94B4B), // Red for alert
            title: 'Waktu Parkir Hampir Habis',
            message: 'Sesi parkir Anda di Grand Indonesia akan berakhir dalam 15 menit. Ketuk untuk perpanjang.',
            time: '15 Menit Lalu',
            isNew: true,
          ),
          
          const SizedBox(height: 24),
          Text('Minggu Ini', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFA29F98))),
          const SizedBox(height: 16),
          
          _buildNotification(
            icon: Icons.local_offer_rounded,
            color: const Color(0xFF2A9D8F), // Teal for promo
            title: 'Promo Akhir Pekan',
            message: 'Dapatkan diskon 20% untuk parkir di seluruh mall area Jakarta Pusat menggunakan ParkSmart Pay.',
            time: '1 Hari Lalu',
            isNew: false,
          ),
          _buildNotification(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF006A9A), // Blue for success
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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E2DB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18)))),
                    if (isNew) Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 8, top: 6), decoration: const BoxDecoration(color: Color(0xFFD94B4B), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A), height: 1.5)),
                const SizedBox(height: 12),
                Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFA29F98))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
