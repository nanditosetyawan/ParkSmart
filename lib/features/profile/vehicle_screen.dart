import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../vehicle/add_vehicle_screen.dart';
import '../history/verified_parking_sessions_screen.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF9F2).withValues(alpha: 0.8),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 1))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1C1C18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(Icons.local_parking, size: 24, color: const Color(0xFF114177)),
                          const SizedBox(width: 8),
                          Text('Live Spot Details', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBN229OME29oeIA03JEkx6qFXdwAiS9tjF2BpuYl0hvR-KRhMbz_TvFM6WCf8r3FfXONbNsAuRJAFymMuLXfHc9_GTa3l48rS4pmj3LFXkDTJQw34ftZgSowlpEj41hbbTvfBKg3P2JHB5MfmHQNghgDyk3ewQpsqLqxRHecKK3Y9QxSY1Og5axl9wsXmXNuN4ylTP0yU_d0SB-yYJ_riMPPALuIk5G7brwi5Pkb555Yu3zsk6gd9w-'),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Title Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GARASI DIGITAL', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF45474A), letterSpacing: 0.5)),
                            Text('Kendaraan Terdaftar', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), letterSpacing: -0.5)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFEBE8E1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.add, size: 18, color: Color(0xFF1C1C18)),
                              const SizedBox(width: 4),
                              Text('Tambah', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Main Vehicle Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.06), blurRadius: 32, offset: const Offset(0, 12))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFBBEED4), borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.stars, size: 14, color: Color(0xFF1F4F3C)),
                                    const SizedBox(width: 6),
                                    Text('Kendaraan Utama', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1F4F3C))),
                                  ],
                                ),
                              ),
                              Container(
                                width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFF6F3EC), shape: BoxShape.circle),
                                child: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF45474A)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 176, width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAVnuwsaKhsc7ics-r8dq6xuhI1zrkeHWSoZpyeq7EGmKQYw_C4-dH5RuUyb8nRM_xEGAiy_s1PFU9iUZV8tTt6--jZfseZAh0cZzgeIN9Xb1Ast9BcH5Cokm2HgwLn_xJgSfbo-f_0EtvOuGrZhDzpZKtCkpM02ODxLjayW4pG6ArEONBVHlKbqLWK-KfYXVz7aTTfb1ng9nNOIsi0YE8MOPywan78pT3axi0Zbww-sKrIymmec4yi'), fit: BoxFit.cover),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF020304).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.directions_car, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text('Toyota Raize', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                  Text('Putih Pearl • Milik Pribadi', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF9FD1B8), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('Auto-Gate Siap', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: const Color(0xFFF6F3EC), borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFBBEED4), shape: BoxShape.circle)),
                                        const SizedBox(width: 8),
                                        Text('RFID & ANPR Sensor', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFBBEED4).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                                      child: Text('Terhubung Otomatis', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF5F8F78))),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Golongan Tarif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF45474A))),
                                            const SizedBox(height: 2),
                                            Text('Gol. I (Sedan/SUV)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Masa Berlaku Sensor', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF45474A))),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.verified, size: 16, color: Color(0xFF9FD1B8)),
                                                const SizedBox(width: 4),
                                                Text('Aktif Selamanya', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifiedParkingSessionsScreen()));
                                  },
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(color: const Color(0xFFEBE8E1), borderRadius: BorderRadius.circular(24)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.history, size: 18, color: Color(0xFF1C1C18)),
                                        const SizedBox(width: 8),
                                        Text('Riwayat Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 48, height: 48,
                                decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                                child: const Icon(Icons.tune, size: 20, color: Color(0xFF1C1C18)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Secondary Vehicle Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: const DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuC2INE8soV5VtERzFqCq_woOBEfGDmI5Zu-0dlqbVRg78Q1EudTkTem9Zx80i7YIm2eL9NcERR6RzY3I2bOkWGhGl8rVoWjDsnMoG7WNCBH2Qjk4MNvriFmYoryaKcCmrhRa4jrlyHvb1yR_SIgHAaMl7Vi1aoO60Yeg8k74Z5y5UH0-9Zr90aHvJR6HXs7_C2e6pTZ4IlXF-_WOW9eQ4kdt2OEBPyzBvtfNkO6j4lO4Yv4WSSFX_au'), fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('B 5678 KLM', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFEBE8E1), borderRadius: BorderRadius.circular(12)),
                                          child: Text('Cadangan', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                                        ),
                                      ],
                                    ),
                                    Text('Honda HR-V • Abu-Abu Metalik', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBBEED4), shape: BoxShape.circle)),
                                        const SizedBox(width: 8),
                                        Text('Sensor ANPR Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF45474A))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.pin_drop, size: 16, color: Color(0xFF45474A)),
                                  const SizedBox(width: 6),
                                  Text('Terakhir di Grand Indonesia', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF45474A))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: const Color(0xFFFFDBD2), borderRadius: BorderRadius.circular(20)),
                                child: Text('Jadikan Utama', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF3C0800))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Auto-Debit Setting
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFF6F3EC), borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.contactless, size: 20, color: Color(0xFF1C1C18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Auto-Debit Saldo Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                Text('Palang terbuka otomatis tanpa henti', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                              ],
                            ),
                          ),
                          Switch(
                            value: true,
                            onChanged: (val) {},
                            activeThumbColor: Colors.white, activeTrackColor: const Color(0xFF020304),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Add button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity, height: 64,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF020304), foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                              elevation: 12, shadowColor: const Color(0xFF020304).withValues(alpha: 0.18),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle, size: 22),
                                const SizedBox(width: 8),
                                Text('Tambah Kendaraan Baru', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Mendukung verifikasi plat nomor instan via Samsat Online', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF45474A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
