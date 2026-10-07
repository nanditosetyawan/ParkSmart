import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/feedback_screen.dart' as feedback;

class SessionCheckoutScreen extends StatelessWidget {
  const SessionCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF1C1C18)),
                    ),
                  ),
                  Text('Selesai Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), letterSpacing: -0.5)),
                  Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                    child: const Icon(Icons.verified, size: 20, color: Color(0xFF1C1C18)),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Status Graphic & Thanks
                    Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9), shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF1EEE7), width: 8),
                          ),
                          child: const Icon(Icons.check_circle, size: 34, color: Color(0xFF1B5E20)),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFEBE8E1), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text('Gate Exit 02 • Siap Keluar', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18), letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Terima Kasih, Sarah.', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), height: 1.2, letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        Text('Sesi parkir Anda telah selesai. Palang keluar akan terbuka otomatis saat mendekati Gate Exit 02.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A), height: 1.5)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Receipt Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE5E2DB)),
                        boxShadow: [BoxShadow(color: const Color(0xFF1C1C18).withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                                    child: const Icon(Icons.local_parking, size: 22, color: Color(0xFF1C1C18)),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Toyota Raize', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                      Text('B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
                                child: Text('Basement B2', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Durasi Total', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                                    Text('Waktu (WIB)', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('1 Jam 48 Menit', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                    Text('14:02 - 15:50', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF45474A))),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: Color(0xFFE5E2DB), height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.pin_drop, size: 16, color: Color(0xFF1C1C18)),
                                    const SizedBox(width: 8),
                                    Text('Slot A-05 • Central Park Mall', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RINCIAN TARIF', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), letterSpacing: 1.0)),
                              const SizedBox(height: 8),
                              _ReceiptRow(label: 'Tarif Parkir (2 Jam)', value: 'Rp 10.000'),
                              const SizedBox(height: 4),
                              _ReceiptRow(label: 'Biaya Sensor ANPR', value: 'Rp 1.000'),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Diskon Promo Member', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF2E7D32))),
                                  Text('-Rp 2.000', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(30, (index) => Expanded(child: Container(height: 1, color: index.isEven ? const Color(0xFFC6C6CA) : Colors.transparent))),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Terbayar', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                                  Text('Rp 9.000', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(16)),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check, size: 14, color: Color(0xFF1B5E20)),
                                        const SizedBox(width: 4),
                                        Text('Lunas', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('ParkSmart Pay', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFF1EEE7), height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sensors, size: 16, color: Color(0xFF1B5E20)),
                              const SizedBox(width: 6),
                              Text('Gerbang Siap Terbuka • Sensor Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF1B5E20))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const feedback.FeedbackScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1C18), foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Buka Palang Keluar', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1EEE7), foregroundColor: const Color(0xFF1C1C18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download, size: 20),
                            const SizedBox(width: 8),
                            Text('Unduh Struk / E-Receipt', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
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
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1C1C18))),
      ],
    );
  }
}
