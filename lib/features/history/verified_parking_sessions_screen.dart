import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifiedParkingSessionsScreen extends StatelessWidget {
  const VerifiedParkingSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2).withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C18)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Parking Spot Detail', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(icon: const Icon(Icons.share, color: Color(0xFF45474A)), onPressed: () {}),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Vehicle Context Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E2DB).withValues(alpha: 0.7)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFBBEED4), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, size: 15, color: Color(0xFF002115)),
                          const SizedBox(width: 6),
                          Text('Kendaraan Utama', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF002115))),
                        ],
                      ),
                    ),
                    const SizedBox(),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 96, height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAVnuwsaKhsc7ics-r8dq6xuhI1zrkeHWSoZpyeq7EGmKQYw_C4-dH5RuUyb8nRM_xEGAiy_s1PFU9iUZV8tTt6--jZfseZAh0cZzgeIN9Xb1Ast9BcH5Cokm2HgwLn_xJgSfbo-f_0EtvOuGrZhDzpZKtCkpM02ODxLjayW4pG6ArEONBVHlKbqLWK-KfYXVz7aTTfb1ng9nNOIsi0YE8MOPywan78pT3axi0Zbww-sKrIymmec4yi'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          Text('Toyota Raize • Putih Pearl', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                          const SizedBox(height: 8),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('Total Sesi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                          Text('28 Kali', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Total Durasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                          Text('64 Jam', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Bulan Ini', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                          Text('Rp 284k', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 2. Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'Semua Bulan', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'Oktober 2026', icon: Icons.calendar_today, isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: 'September 2026', isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: 'Mall & Komersil', icon: Icons.local_mall, isSelected: false),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 3. Header List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Sesi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                  const SizedBox(width: 8),
                 
                ],
              ),
              Row(
                children: [
                  Text('Urutkan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                  const Icon(Icons.swap_vert, size: 16, color: Color(0xFF9A442D)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 4. History Items
          _HistoryItem(
            mallName: 'Central Park Mall',
            slot: 'Slot B2-A05 • Pod Otomatis',
            price: 'Rp 9.000',
            paymentMethod: 'Auto-Debit',
            date: 'Hari ini, 24 Okt 2026',
            duration: '1 Jam 45 Mnt',
            timeIn: 'Masuk: 13:30 WIB',
            timeOut: 'Keluar: 15:15 WIB',
            status: 'Selesai',
            icon: Icons.local_parking,
          ),
          const SizedBox(height: 12),
          _HistoryItem(
            mallName: 'Grand Indonesia',
            slot: 'Slot East Mall P3-12',
            price: 'Rp 15.000',
            paymentMethod: 'Auto-Debit',
            date: 'Kemarin, 23 Okt 2026',
            duration: '2 Jam 45 Mnt',
            timeIn: 'Masuk: 18:20 WIB',
            timeOut: 'Keluar: 21:05 WIB',
            status: 'Selesai',
            icon: Icons.corporate_fare,
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF020304),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download, size: 20),
                const SizedBox(width: 8),
                Text('Unduh Rekap Parkir (PDF)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;

  const _FilterChip({required this.label, this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF020304) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [if (isSelected) const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF45474A)),
            const SizedBox(width: 6),
          ],
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF45474A))),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String mallName;
  final String slot;
  final String price;
  final String paymentMethod;
  final String date;
  final String duration;
  final String timeIn;
  final String timeOut;
  final String status;
  final IconData icon;

  const _HistoryItem({
    required this.mallName, required this.slot, required this.price,
    required this.paymentMethod, required this.date, required this.duration,
    required this.timeIn, required this.timeOut, required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E2DB).withValues(alpha: 0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: const Color(0xFF020304)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mallName, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                    Row(
                      children: [
                        const Icon(Icons.pin_drop, size: 14, color: Color(0xFF45474A)),
                        const SizedBox(width: 4),
                        Text(slot, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: Color(0xFF1C1C18)),
                        const SizedBox(width: 6),
                        Text(date, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
                      ],
                    ),
                    Text(duration, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(timeIn, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
                    const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFC6C6CA)),
                    Text(timeOut, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFBBEED4), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 13, color: Color(0xFF002115)),
                    const SizedBox(width: 4),
                    Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF002115))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF1C1D1F), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 15, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('E-Receipt', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
