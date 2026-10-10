import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArNavigationScreen extends StatelessWidget {
  const ArNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EC),
      body: Stack(
        children: [
          // Simulated Map Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEAE5D9),
              child: Stack(
                children: [
                  // Fake route line
                  Positioned(
                    top: 200, left: 100,
                    child: Container(
                      width: 8, height: 400,
                      color: const Color(0xFF9A442D).withValues(alpha: 0.5),
                    ),
                  ),
                  Positioned(
                    top: 600, left: 100,
                    child: Container(
                      width: 150, height: 8,
                      color: const Color(0xFF9A442D).withValues(alpha: 0.5),
                    ),
                  ),
                  // Current location puck
                  Positioned(
                    top: 600, left: 240,
                    child: Container(
                      width: 24, height: 24,
                      decoration: const BoxDecoration(color: Color(0xFF9A442D), shape: BoxShape.circle),
                      child: Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top Navigation Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1C1D1F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.turn_left, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '50m Belok Kiri',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C1C18),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pintu Masuk Barat Basement',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF45474A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol Suara di sisi paling kanan tanpa tombol silang & tanpa overflow
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1EEE7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            size: 20,
                            color: Color(0xFF45474A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Route HUD Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: Row(
                          children: [
                            const Icon(Icons.navigation, size: 14, color: Color(0xFF9A442D)),
                            const SizedBox(width: 4),
                            Text('Rute Tercepat', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFF1C1D1F), borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: Text('4 mnt • 1.2 km', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: Text('15:24 WIB', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // AR Mode Toggle
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.view_in_ar, size: 18, color: Color(0xFF9A442D)),
                          const SizedBox(width: 8),
                          Text('Mode AR', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                  
                  // Floor selection side buttons
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                      child: Column(
                        children: [
                          const Icon(Icons.my_location, size: 20, color: Color(0xFF45474A)),
                          const SizedBox(height: 16),
                          Text('1F', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                          const SizedBox(height: 16),
                          Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF1C1D1F), shape: BoxShape.circle), child: Center(child: Text('B2', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)))),
                          const SizedBox(height: 16),
                          Text('B3', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Bottom Destination Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))]),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Central Park Mall', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, size: 16, color: Color(0xFF9A442D)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Lantai B2 • Slot A-05 • Sensor Siap', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
                              ],
                            ),
                            Column(
                              children: [
                                Text('SLOT', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF45474A))),
                                Text('A-05', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF6F3EC), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.radar, size: 16, color: Color(0xFF9A442D)),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ANPR Fast Track', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                                      Text('B 1234 XYZ (Palang Otomatis Siap)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(Icons.lock_open, size: 16, color: Color(0xFF1F4F3C)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                              child: const Icon(Icons.more_horiz, color: Color(0xFF1C1D1F)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C1D1F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Tiba di Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
