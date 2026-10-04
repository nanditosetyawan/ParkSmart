import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackAdminScreen extends StatelessWidget {
  const FeedbackAdminScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feedback & Isu', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
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
                            Text('Skor Kepuasan', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
                            const Icon(Icons.star, size: 18, color: Color(0xFF17A18A)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('4.8/5.0', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
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
                            Text('Tiket Terbuka', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
                            const Icon(Icons.emergency, size: 18, color: Color(0xFFD94B4B)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('3 ', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                            Text('Isu', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE4DFD5)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Color(0xFF76777B)),
                  hintText: 'Cari plat nomor, nama...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPill('Semua (18)', true),
                  _buildPill('Kendala Gate (5)', false),
                  _buildPill('Slot Penuh (4)', false),
                  _buildPill('Tarif & Biaya (6)', false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ticket List
            _buildTicket(
              name: 'Dimas Pratama',
              vehicle: 'B 2341 S • Fortuner Hitam',
              type: 'Kendala Palang ANPR',
              typeColor: const Color(0xFFD94B4B),
              location: 'Central Park Mall • Pintu Masuk Selatan',
              text: '"Sensor kamera ANPR tadi siang tidak otomatis mendeteksi plat mobil saya, palang tidak terangkat dan harus panggil satpam jaga manual."',
              time: '12 menit lalu',
            ),
            const SizedBox(height: 12),
            _buildTicket(
              name: 'Anisa Rahmawati',
              vehicle: 'B 8821 T • Ioniq 5',
              type: 'Navigasi Slot',
              typeColor: const Color(0xFF1A1A18),
              location: 'Grand Indonesia • Basement 1',
              text: '"Navigasi aplikasi sangat akurat, tapi saran agar lampu indikator di atas slot B-08 diperbaiki karena sempat redup."',
              time: '1 jam lalu',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF114177) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? const Color(0xFF114177) : const Color(0xFFE4DFD5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : const Color(0xFF76777B),
        ),
      ),
    );
  }

  Widget _buildTicket({
    required String name, required String vehicle, required String type,
    required Color typeColor, required String location, required String text,
    required String time,
  }) {
    return Container(
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFF1EEE7),
                    child: Text(name.substring(0, 2).toUpperCase(), style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(vehicle, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(type, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF006A9A)),
              const SizedBox(width: 4),
              Text(location, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(8)),
            child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF1A1A18))),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Color(0xFF76777B)),
                  const SizedBox(width: 4),
                  Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                ],
              ),
              Row(
                children: [
                  if (typeColor == const Color(0xFFD94B4B)) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_in_talk, size: 14, color: Color(0xFF1A1A18)),
                          const SizedBox(width: 4),
                          Text('Telepon', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF114177), borderRadius: BorderRadius.circular(16)),
                    child: Text('Tindak Lanjut', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
