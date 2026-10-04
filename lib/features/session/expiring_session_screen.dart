import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'session_checkout_screen.dart';

class ExpiringSessionScreen extends StatefulWidget {
  const ExpiringSessionScreen({super.key});

  @override
  State<ExpiringSessionScreen> createState() => _ExpiringSessionScreenState();
}

class _ExpiringSessionScreenState extends State<ExpiringSessionScreen> {
  late Timer _timer;
  int _remainingSeconds = 9 * 60 + 45; // 00:09:45

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int hrs = _remainingSeconds ~/ 3600;
    int mins = (_remainingSeconds % 3600) ~/ 60;
    int secs = _remainingSeconds % 60;
    return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

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
                border: Border(bottom: BorderSide(color: const Color(0xFFE5E2DB).withValues(alpha: 0.6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFF1EEE7), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE5E2DB))),
                      child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1C1C18)),
                    ),
                  ),
                  Text('Sesi Berakhir Segera', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), letterSpacing: -0.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFDBD2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFFB4A1).withValues(alpha: 0.6))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE07A5F), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('MENDESAK', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF7C2E19), letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Warning Card & Countdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: const Color(0xFFE5E2DB).withValues(alpha: 0.8)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 176, height: 176,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE07A5F), width: 10), // Simplified gauge
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('SISA WAKTU', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF76777B), letterSpacing: 1.5)),
                                Text(_formattedTime, style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF1C1C18), fontFeatures: const [FontFeature.tabularFigures()], letterSpacing: -1.0)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.schedule, size: 14, color: Color(0xFFE07A5F)),
                                    const SizedBox(width: 4),
                                    Text('16:02 WIB', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFE07A5F))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Waktu Parkir Hampir Habis', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), letterSpacing: -0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'Batas toleransi keluar adalah 16:02 WIB. Perpanjang sekarang untuk menghindari tarif denda overstay otomatis.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Extensions
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PILIHAN PERPANJANGAN CEPAT', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), letterSpacing: 0.5)),
                            Text('Tarif normal', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _ExtensionButton(time: '+30 Menit', price: 'Rp 2.500', isSelected: true)),
                            const SizedBox(width: 8),
                            Expanded(child: _ExtensionButton(time: '+1 Jam', price: 'Rp 5.000', isSelected: false)),
                            const SizedBox(width: 8),
                            Expanded(child: _ExtensionButton(time: '+2 Jam', price: 'Rp 10.000', isSelected: false)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Session Details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E2DB).withValues(alpha: 0.8)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFF6F3EC), shape: BoxShape.circle), child: const Icon(Icons.local_parking, size: 18, color: Color(0xFF1C1C18))),
                                  const SizedBox(width: 8),
                                  Text('Rincian Parkir Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFBBEED4).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
                                child: Text('Sesi Berjalan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF004A3E))),
                              )
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                          _DetailRow(icon: Icons.pin_drop, label: 'Lokasi Slot', value: 'Central Park Mall • Slot A-05'),
                          const SizedBox(height: 12),
                          _DetailRow(icon: Icons.directions_car, label: 'Kendaraan', value: 'Toyota Raize • B 1234 XYZ'),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1EEE7), height: 1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet, size: 16, color: Color(0xFF76777B)),
                                  const SizedBox(width: 6),
                                  Text('Biaya Saat Ini', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                                ],
                              ),
                              Text('Rp 9.000', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF1C1C18))),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1D1F), foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle, size: 20),
                            const SizedBox(width: 8),
                            Text('Perpanjang Durasi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionCheckoutScreen())),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1EEE7), foregroundColor: const Color(0xFF1C1C18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Color(0xFFE5E2DB))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.exit_to_app, size: 18, color: Color(0xFF76777B)),
                            const SizedBox(width: 8),
                            Text('Siap Check-out Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified, size: 15, color: Color(0xFF004A3E)),
                        const SizedBox(width: 6),
                        Text('Denda overstay otomatis Rp 5.000/jam via ParkSmart Wallet', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                      ],
                    ),
                    const SizedBox(height: 24),
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

class _ExtensionButton extends StatelessWidget {
  final String time;
  final String price;
  final bool isSelected;
  
  const _ExtensionButton({required this.time, required this.price, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFF6F3EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFFE5E2DB), width: isSelected ? 2 : 1),
      ),
      child: Column(
        children: [
          Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
          const SizedBox(height: 2),
          Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFF76777B))),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF76777B)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
          ],
        ),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
      ],
    );
  }
}
