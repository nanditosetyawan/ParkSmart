import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/currency_service.dart';
import '../notification/notification_screen.dart';
import '../../core/services/language_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'session_checkout_screen.dart';
import 'extend_session_screen.dart';
import '../navigation/ar_navigation_screen.dart';
import 'backend/active_session_backend.dart';
import 'backend/session_checkout_backend.dart';

class ActiveSessionScreen extends StatefulWidget {
  final String? sessionId;
  const ActiveSessionScreen({super.key, this.sessionId});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late Timer _timer;
  int _remainingSeconds = 3600 + (42 * 60) + 15; // 1:42:15

  @override
  void initState() {
    super.initState();
    ActiveSessionBackend.instance.fetchActiveSession(sessionId: widget.sessionId).then((_) {
      if (mounted) {
        setState(() {
          _remainingSeconds = ActiveSessionBackend.instance.remainingSeconds;
        });
      }
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            if (_remainingSeconds == 0) {
              _onSessionExpired();
            }
          } else {
            _timer.cancel();
          }
        });
      }
    });
  }

  void _onSessionExpired() async {
    _timer.cancel();
    final sId = widget.sessionId ?? ActiveSessionBackend.instance.sessionId;
    await SessionCheckoutBackend.instance.fetchCheckoutDetails(sessionId: sId);
    await SessionCheckoutBackend.instance.completeSessionCheckout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas waktu parkir telah habis. Sesi parkir otomatis diselesaikan.'),
          backgroundColor: Color(0xFF17A18A),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionCheckoutScreen(sessionId: sId),
        ),
      );
    }
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
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, ActiveSessionBackend.instance, CurrencyService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFAF7F2),
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFFECE7DE).withValues(alpha: 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? theme.card : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? theme.border : const Color(0xFFECE7DE).withValues(alpha: 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE07A5F),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SESI AKTIF'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationScreen()),
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFFECE7DE).withValues(alpha: 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_none,
                            size: 20,
                            color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: !ActiveSessionBackend.instance.hasActiveSession
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.no_crash_outlined,
                                    size: 40,
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Tidak Ada Sesi Parkir Aktif'.tr,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Saat kendaraan Anda check-in di gate parkir, timer dan detail spot akan muncul secara otomatis di sini.'.tr,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white : const Color(0xFF114177),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Kembali ke Beranda'.tr,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 120),
                        child: Column(
                          children: [
                            // Countdown Section
                            Center(
                              child: SizedBox(
                                width: 360,
                                height: 280,
                                child: CustomPaint(
                                  painter: ArcGaugePainter(
                                    progress: _remainingSeconds / 7200,
                                    isDark: isDark,
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8F6F3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.bolt, size: 17, color: Color(0xFF17A18A)),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'SISA WAKTU PARKIR'.tr,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          GestureDetector(
                                            onTap: () {
                                              // DEBUG: Fast forward to 10:02 to test the 10-minute trigger
                                              setState(() {
                                                _remainingSeconds = 602;
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Mempercepat waktu ke 10:02...')),
                                              );
                                            },
                                            child: Text(
                                              _formattedTime,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 48,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                                fontFeatures: const [FontFeature.tabularFigures()],
                                                letterSpacing: -1.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isDark ? theme.surfaceField : const Color(0xFFF1EEE7),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isDark ? theme.border : const Color(0xFFECE7DE).withValues(alpha: 0.6),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.schedule, size: 14, color: Color(0xFF17A18A)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Batas Selesai ${ActiveSessionBackend.instance.deadlineFormatted}'.tr,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                                  ),
                                                ),
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
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ArNavigationScreen(
                                          destinationParking: ActiveSessionBackend.instance.destinationParking,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ActionPill(
                                    icon: Icons.more_time,
                                    label: 'Perpanjang',
                                    color: const Color(0xFFE07A5F),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExtendSessionScreen(
                                          sessionId: ActiveSessionBackend.instance.sessionId,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ActionPill(
                                    icon: Icons.headphones,
                                    label: 'Bantuan',
                                    color: isDark ? Colors.white : const Color(0xFF1C1D1F),
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
                              decoration: BoxDecoration(
                                color: isDark ? theme.card : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: isDark ? Border.all(color: theme.border) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'LOKASI PARKIR'.tr,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              ActiveSessionBackend.instance.locationName,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(top: 2),
                                                  child: Icon(Icons.storefront, size: 14, color: Color(0xFFE07A5F)),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    '${ActiveSessionBackend.instance.locationSub} • Pilar No. 14',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 13,
                                                      color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'NOMOR SLOT'.tr,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFDF2EE),
                                              borderRadius: BorderRadius.circular(24),
                                              border: Border.all(
                                                color: isDark ? const Color(0xFF7F2D2D) : const Color(0xFFF8D8CF),
                                              ),
                                            ),
                                            child: Text(
                                              ActiveSessionBackend.instance.slotCode,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? const Color(0xFFF87171) : const Color(0xFFC0563C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Divider(
                                      color: isDark ? theme.border : const Color(0xFFECE7DE),
                                      height: 1,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isDark ? theme.surfaceField : Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDark ? theme.border : const Color(0xFFECE7DE).withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Biaya Terhitung'.tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                CurrencyService.instance.format(ActiveSessionBackend.instance.currentFee),
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  'Lunas di Muka'.tr,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isDark ? theme.surfaceField : Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDark ? theme.border : const Color(0xFFECE7DE).withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Kendaraan Aktif'.tr,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                ActiveSessionBackend.instance.vehicleName,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                ActiveSessionBackend.instance.plateNumber,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
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
                                          Icon(
                                            Icons.login,
                                            size: 16,
                                            color: isDark ? theme.textMuted : const Color(0xFFA5A29D),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Masuk ${ActiveSessionBackend.instance.checkInFormatted}'.tr,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            size: 16,
                                            color: isDark ? theme.textMuted : const Color(0xFFA5A29D),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Durasi Paket: ${ActiveSessionBackend.instance.durationHours} Jam'.tr,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: isDark ? theme.textMuted : const Color(0xFF7D7A75),
                                            ),
                                          ),
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
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                isDark ? theme.bg : const Color(0xFFFAF7F2),
                                (isDark ? theme.bg : const Color(0xFFFAF7F2)).withValues(alpha: 0.95),
                                (isDark ? theme.bg : const Color(0xFFFAF7F2)).withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SessionCheckoutScreen(
                                    sessionId: widget.sessionId ?? ActiveSessionBackend.instance.sessionId,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF1C1D1F),
                                foregroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAF7F2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                elevation: 8,
                                shadowColor: Colors.black.withValues(alpha: 0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Check Out Parkir'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
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
      },
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
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? theme.card : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? theme.border : const Color(0xFFECE7DE).withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArcGaugePainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final int totalSegments = 5;

  ArcGaugePainter({required this.progress, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
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

    final arcRect = Rect.fromCircle(center: center, radius: 140);

    for (int i = 0; i < totalSegments; i++) {
      if (i < activeSegments) {
        paint.color = const Color(0xFF17A18A); // Success Green
      } else {
        paint.color = isDark ? const Color(0xFF334155) : const Color(0xFFEBE8E1); // Empty color
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
  bool shouldRepaint(covariant ArcGaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isDark != isDark;
}
