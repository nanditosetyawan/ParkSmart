import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../notification/notification_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'session_checkout_screen.dart';
import 'extend_session_screen.dart';
import '../navigation/ar_navigation_screen.dart';

class ActiveSessionScreen extends StatefulWidget {
  const ActiveSessionScreen({super.key});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late Timer _timer;
  int _remainingSeconds = 3600 + (42 * 60) + 15; // 1:42:15

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
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFECE7DE).withValues(alpha: 0.6)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                      child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1C1D1F)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE7DE).withValues(alpha: 0.6)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFE07A5F), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('SESI AKTIF', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1C1D1F), letterSpacing: 1.0)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFECE7DE).withValues(alpha: 0.6)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                      child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF1C1D1F)),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 120),
                    child: Column(
                      children: [
                        // Countdown Section
                        Center(
                          child: SizedBox(
                            width: 360, height: 280,
                            child: CustomPaint(
                              painter: ArcGaugePainter(progress: _remainingSeconds / 7200), // Assuming 2 hours total
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFFE8F6F3), shape: BoxShape.circle),
                                        child: const Icon(Icons.bolt, size: 17, color: Color(0xFF17A18A)),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('SISA WAKTU PARKIR', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF7D7A75), letterSpacing: 1.0)),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () {
                                          // DEBUG: Fast forward to 10:02 to test the 10-minute trigger
                                          setState(() {
                                            _remainingSeconds = 602;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mempercepat waktu ke 10:02...')));
                                        },
                                        child: Text(_formattedTime, style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w800, color: const Color(0xFF1C1D1F), fontFeatures: const [FontFeature.tabularFigures()], letterSpacing: -1.0)),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE7DE).withValues(alpha: 0.6))),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.schedule, size: 14, color: Color(0xFF17A18A)),
                                            const SizedBox(width: 6),
                                            Text('Batas Selesai 16:02 WIB', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF7D7A75))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Pills
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _ActionPill(
                                icon: Icons.near_me, 
                                label: 'Navigasi AR', 
                                color: const Color(0xFFE07A5F),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArNavigationScreen())),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionPill(
                                icon: Icons.more_time, 
                                label: 'Perpanjang', 
                                color: const Color(0xFFE07A5F),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExtendSessionScreen())),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ActionPill(
                                icon: Icons.headphones, 
                                label: 'Bantuan', 
                                color: const Color(0xFF1C1D1F),
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Main Card Info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8))]),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('LOKASI PARKIR', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF7D7A75), letterSpacing: 1.0)),
                                      const SizedBox(height: 4),
                                      Text('Central Park Mall', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F), letterSpacing: -0.5)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.storefront, size: 14, color: Color(0xFFE07A5F)),
                                          const SizedBox(width: 6),
                                          Text('Lantai B2 • Pilar No. 14', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF7D7A75))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('NOMOR SLOT', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF7D7A75), letterSpacing: 1.0)),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(color: const Color(0xFFFDF2EE), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF8D8CF))),
                                        child: Text('A-05', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFC0563C))),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFECE7DE), height: 1)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFECE7DE).withValues(alpha: 0.4))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Biaya Terhitung', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF7D7A75))),
                                          const SizedBox(height: 2),
                                          Text('Rp 9.000', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F), letterSpacing: -0.5)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(20)),
                                            child: Text('Lunas di Muka', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF047857))),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFECE7DE).withValues(alpha: 0.4))),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Kendaraan Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF7D7A75))),
                                          const SizedBox(height: 2),
                                          Text('Toyota Raize', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F))),
                                          const SizedBox(height: 4),
                                          Text('B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF7D7A75), letterSpacing: 1.0)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.login, size: 16, color: Color(0xFFA5A29D)),
                                      const SizedBox(width: 6),
                                      Text('Masuk 14:02 WIB', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF7D7A75))),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.flag, size: 16, color: Color(0xFFA5A29D)),
                                      const SizedBox(width: 6),
                                      Text('Durasi Paket: 2 Jam', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF7D7A75))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom CTA
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [const Color(0xFFFAF7F2), const Color(0xFFFAF7F2).withValues(alpha: 0.95), const Color(0xFFFAF7F2).withValues(alpha: 0.0)]),
                      ),
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionCheckoutScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C1D1F), foregroundColor: const Color(0xFFFAF7F2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            elevation: 8, shadowColor: const Color(0xFF1C1D1F).withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Check Out Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionPill({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFECE7DE).withValues(alpha: 0.8)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF1C1D1F)), overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}


class ArcGaugePainter extends CustomPainter {
  final double progress;
  final int totalSegments = 5;

  ArcGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Move center even higher and expand radius for a spacious look
    final center = Offset(size.width / 2, size.height - 85);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final startAngle = math.pi; // Left
    final sweepAngle = math.pi; // Half circle

    final gapAngle = 0.15; 
    final segmentSweep = (sweepAngle - (gapAngle * (totalSegments - 1))) / totalSegments;

    int activeSegments = (progress * totalSegments).ceil();
    if (activeSegments > totalSegments) activeSegments = totalSegments;
    if (activeSegments < 0) activeSegments = 0;
    
    // Use a smaller circle to bring the legs closer together but keep the top perfectly round
    final arcRect = Rect.fromCircle(center: center, radius: 140);

    for (int i = 0; i < totalSegments; i++) {
      if (i < activeSegments) {
        paint.color = const Color(0xFF17A18A); // Success Green
      } else {
        paint.color = const Color(0xFFEBE8E1); // Empty color
      }
      
      final currentStartAngle = startAngle + (i * (segmentSweep + gapAngle));
      
      canvas.drawArc(
        arcRect,
        currentStartAngle,
        segmentSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ArcGaugePainter oldDelegate) => oldDelegate.progress != progress;
}
