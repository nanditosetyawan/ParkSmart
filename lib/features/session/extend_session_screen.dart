import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';

class ExtendSessionScreen extends StatefulWidget {
  const ExtendSessionScreen({super.key});

  @override
  State<ExtendSessionScreen> createState() => _ExtendSessionScreenState();
}

class _ExtendSessionScreenState extends State<ExtendSessionScreen> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> _options = [
    {'title': '+30 Menit', 'cost': 'Rp 3.000', 'time': 'Hingga 16:32 WIB', 'popular': false},
    {'title': '+1 Jam', 'cost': 'Rp 5.000', 'time': 'Hingga 17:02 WIB', 'popular': true},
    {'title': '+2 Jam', 'cost': 'Rp 9.000', 'time': 'Hingga 18:02 WIB', 'popular': false},
    {'title': '+3 Jam', 'cost': 'Rp 13.000', 'time': 'Hingga 19:02 WIB', 'popular': false},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedOption = _options[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C18)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PARKSMART', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D), letterSpacing: 1.5)),
            Text('Extend Parking Session', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEBE8E1), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF1F4F3C), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('SESI BERJALAN • CENTRAL PARK', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                  ],
                ),
              ),
              Text('Auto-Sync ANPR', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), offset: Offset(0, 8), blurRadius: 30)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_parking, size: 16, color: Color(0xFF9A442D)),
                            const SizedBox(width: 4),
                            Text('Lokasi & Penempatan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Slot A-05', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF020304))),
                        Text('Lantai B2 • Pilar 14', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                      ],
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                      child: const Icon(Icons.directions_car, color: Color(0xFF1C1D1F)),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sisa Waktu Sesi Ini', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                          Text('01:41:19', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF020304))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                            child: Text('Batas Selesai', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          ),
                          const SizedBox(height: 4),
                          Text('16:02 WIB', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 18, color: Color(0xFF76777B)),
                        const SizedBox(width: 8),
                        Text('Toyota Raize • B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFFDBD2).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                      child: Text('Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF7C2E19))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PILIH DURASI TAMBAHAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
              Text('Maks. +4 Jam', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9A442D))),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final option = _options[index];
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1C1D1F) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? const [
                      BoxShadow(color: Color(0x2E1C1D1F), offset: Offset(0, 10), blurRadius: 24)
                    ] : const [
                      BoxShadow(color: Color(0x0A000000), offset: Offset(0, 4), blurRadius: 10)
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(option['title'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF020304))),
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFF9A442D) : const Color(0xFFEBE8E1),
                                ),
                                child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option['cost'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF020304))),
                              Text(option['time'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isSelected ? const Color(0xFF858587) : const Color(0xFF45474A))),
                            ],
                          ),
                        ],
                      ),
                      if (option['popular'])
                        Positioned(
                          top: -4, right: 28,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFC9174), borderRadius: BorderRadius.circular(8)),
                            child: Text('Paling Populer', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF742814))),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WAKTU SELESAI BARU', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                        Row(
                          children: [
                            Text(selectedOption['time'].toString().replaceAll('Hingga ', ''), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF020304))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFFDBD2), borderRadius: BorderRadius.circular(8)),
                              child: Text('(${selectedOption['title']})', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF3C0800))),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('BIAYA TAMBAHAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                        Text(selectedOption['cost'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E2DB)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet, color: Color(0xFF020304))),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Metode Pembayaran', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                            Text('ParkSmart Wallet', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                            Text('Saldo Aktif: Rp 45.000', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF1F4F3C))),
                          ],
                        ),
                      ],
                    ),
                    Text('Ubah >', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Color(0xFF76777B)),
              const SizedBox(width: 12),
              Expanded(child: Text('Perpanjangan otomatis dikonfirmasi ke sistem sensor ANPR & petugas lapangan Central Park Mall tanpa perlu tiket baru.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A)))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x1F0F172A), offset: Offset(0, 8), blurRadius: 24),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF17A18A), size: 64),
                            const SizedBox(height: 16),
                            Text('Perpanjangan Berhasil!', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF14202B))),
                            const SizedBox(height: 8),
                            Text('Sesi parkir Anda telah diperpanjang.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    );
                  }
                );

                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()), 
                      (Route<dynamic> route) => false
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF020304),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Konfirmasi & Bayar ${selectedOption['cost']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
