import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_shadows.dart';
import 'active_session_screen.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleCheckin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => _isLoading = false);
      _showGateOpenModal();
    });
  }

  void _showGateOpenModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: const Color(0xFFD1FAE5), shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 32, color: Color(0xFF065F46)),
              ),
              const SizedBox(height: 16),
              Text('Palang Telah Terbuka', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F))),
              const SizedBox(height: 8),
              Text(
                'Silakan maju perlahan menuju Basement B2. Navigasi slot A-05 telah dipandu di layar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close modal
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ActiveSessionScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C1D1F), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text('Lanjutkan Navigasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16), // safe area bottom
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
                      height: 40, padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC3C6D1).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A1C1C)),
                          const SizedBox(width: 6),
                          Text('Kembali', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1C1C))),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Check-in Gerbang', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1C1C))),
                    ],
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8).withValues(alpha: 0.6), shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC3C6D1).withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.help_outline, size: 20, color: Color(0xFF1A1C1C)),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Pill & Headline
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF022C22).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF065F46).withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text('GEOFENCE & ANPR GATE 01 AKTIF', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B), letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Selamat Datang di\nCentral Park Mall.', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2, color: const Color(0xFF1C1D1F), letterSpacing: -0.5)),
                    const SizedBox(height: 12),
                    Text('Sistem ANPR mendeteksi plat nomor Anda pada radius 50 meter dari Gate 01 South Entrance.', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A), height: 1.5)),
                    
                    const SizedBox(height: 24),
                    
                    // Radar / Signal Graphic Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE5E2DB)),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(width: 176, height: 176, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 1))),
                                ),
                                Container(width: 144, height: 144, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1C1D1F).withValues(alpha: 0.1)))),
                                Container(width: 96, height: 96, decoration: BoxDecoration(color: const Color(0xFFFCF9F2), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE5E2DB)))),
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(color: const Color(0xFF1C1D1F), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 4))]),
                                  child: const Icon(Icons.directions_car, color: Colors.white, size: 26),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFCF9F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, size: 14, color: Color(0xFF047857)),
                                const SizedBox(width: 6),
                                Text('Terverifikasi Otomatis di Gerbang Masuk', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1C1D1F))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Jarak saat ini: ~15 meter ke portal palang', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Booking Detail Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE5E2DB)),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('KODE BOOKING', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF76777B), letterSpacing: 0.5)),
                                  Text('PS-20261024-8842', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFA7F3D0))),
                                child: Row(
                                  children: [
                                    const Icon(Icons.verified, size: 13, color: Color(0xFF065F46)),
                                    const SizedBox(width: 4),
                                    Text('Valid', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF065F46))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFE5E2DB), height: 1)),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: const Color(0xFFFCF9F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Plat Nomor Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                                      const SizedBox(height: 4),
                                      Text('B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F))),
                                      Text('Toyota Raize', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: const Color(0xFFFCF9F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Slot Reservasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text('A-05', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F))),
                                          const SizedBox(width: 4),
                                          Text('Basement B2', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.near_me, size: 12, color: Color(0xFF065F46)),
                                          const SizedBox(width: 2),
                                          Text('Dekat Lift Utama', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF065F46))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: const Color(0xFFF6F3EC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info, size: 20, color: Color(0xFF1C1D1F)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('Palang akan terangkat otomatis saat plat nomor terbaca. Anda juga dapat menekan tombol di bawah bila sistem palang belum terbuka.',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A), height: 1.5)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Actions
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleCheckin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1D1F), foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Masuk Gerbang & Buka Palang', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
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
