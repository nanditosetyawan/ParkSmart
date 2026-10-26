import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:sensors_plus/sensors_plus.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MINI COMPASS NEEDLE PAINTER
/// Digunakan pada tombol lingkaran mini 48x48 di ExploreMapScreen
/// ─────────────────────────────────────────────────────────────────────────────
class MiniCompassNeedlePainter extends CustomPainter {
  final bool isDark;

  MiniCompassNeedlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy);

    // Jarum Utara (Merah terang)
    final northPath = Path()
      ..moveTo(cx, cy - r * 0.85) // Ujung jarum atas (Utara)
      ..lineTo(cx + r * 0.28, cy)
      ..lineTo(cx, cy - r * 0.08)
      ..close();

    final northPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawPath(northPath, northPaint);

    // Sisi bayangan jarum utara (agar 3D)
    final northShadowPath = Path()
      ..moveTo(cx, cy - r * 0.85)
      ..lineTo(cx - r * 0.28, cy)
      ..lineTo(cx, cy - r * 0.08)
      ..close();

    final northShadowPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;
    canvas.drawPath(northShadowPath, northShadowPaint);

    // Jarum Selatan (Abu-abu / Slate metalik)
    final southPath = Path()
      ..moveTo(cx, cy + r * 0.85) // Ujung jarum bawah (Selatan)
      ..lineTo(cx + r * 0.28, cy)
      ..lineTo(cx, cy + r * 0.08)
      ..close();

    final southPaint = Paint()
      ..color = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)
      ..style = PaintingStyle.fill;
    canvas.drawPath(southPath, southPaint);

    final southShadowPath = Path()
      ..moveTo(cx, cy + r * 0.85)
      ..lineTo(cx - r * 0.28, cy)
      ..lineTo(cx, cy + r * 0.08)
      ..close();

    final southShadowPaint = Paint()
      ..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    canvas.drawPath(southShadowPath, southShadowPaint);

    // Titik pivot tengah
    final pivotBorder = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.22, pivotBorder);

    final pivotCenter = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.12, pivotCenter);
  }

  @override
  bool shouldRepaint(covariant MiniCompassNeedlePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// FULL COMPASS DIAL PAINTER
/// Menggambar piringan bulat kompas detail dengan derajat, garis skala, arah kardinal
/// ─────────────────────────────────────────────────────────────────────────────
class FullCompassDialPainter extends CustomPainter {
  final bool isDark;

  FullCompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final radius = min(cx, cy) - 12;

    // 1. Lingkaran luar semi-transparan gelap (glassmorphism frameless)
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.45),
          Colors.black.withValues(alpha: 0.60),
          Colors.black.withValues(alpha: 0.75),
        ],
        stops: const [0.0, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Cincin pembatas tipis elegan
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.72, ringPaint..color = Colors.white.withValues(alpha: 0.15));

    // 3. Garis-garis tanda sudut (Ticks) setiap 2 derajat
    final majorTickPaint = Paint()
      ..color = isDark ? Colors.white70 : const Color(0xFF1E293B)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final medTickPaint = Paint()
      ..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = isDark
          ? const Color(0xFF475569).withValues(alpha: 0.8)
          : const Color(0xFF94A3B8)
      ..strokeWidth = 1.0;

    for (int deg = 0; deg < 360; deg += 2) {
      final rad = (deg - 90) * (pi / 180);
      final isMajor = deg % 30 == 0;
      final isMed = deg % 10 == 0 && !isMajor;

      final tickLength = isMajor ? 14.0 : (isMed ? 9.0 : 5.0);
      final rOuter = radius - 4;
      final rInner = rOuter - tickLength;

      final p1 = Offset(cx + rOuter * cos(rad), cy + rOuter * sin(rad));
      final p2 = Offset(cx + rInner * cos(rad), cy + rInner * sin(rad));

      final paint = isMajor ? majorTickPaint : (isMed ? medTickPaint : minorTickPaint);
      canvas.drawLine(p1, p2, paint);
    }

    // 4. Huruf Arah Kardinal (N, E, S, W) & Ordinal (NE, SE, SW, NW)
    final directions = [
      {'deg': 0, 'label': 'N', 'isNorth': true, 'major': true},
      {'deg': 45, 'label': 'NE', 'isNorth': false, 'major': false},
      {'deg': 90, 'label': 'E', 'isNorth': false, 'major': true},
      {'deg': 135, 'label': 'SE', 'isNorth': false, 'major': false},
      {'deg': 180, 'label': 'S', 'isNorth': false, 'major': true},
      {'deg': 225, 'label': 'SW', 'isNorth': false, 'major': false},
      {'deg': 270, 'label': 'W', 'isNorth': false, 'major': true},
      {'deg': 315, 'label': 'NW', 'isNorth': false, 'major': false},
    ];

    for (var d in directions) {
      final deg = d['deg'] as int;
      final label = d['label'] as String;
      final isNorth = d['isNorth'] as bool;
      final isMajor = d['major'] as bool;

      final rad = (deg - 90) * (pi / 180);
      final rText = radius * 0.83;
      final textPos = Offset(cx + rText * cos(rad), cy + rText * sin(rad));

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isNorth ? 18 : (isMajor ? 14 : 11),
            fontWeight: isNorth || isMajor ? FontWeight.w900 : FontWeight.w600,
            color: isNorth
                ? const Color(0xFFEF4444)
                : (isDark
                    ? (isMajor ? Colors.white : const Color(0xFF94A3B8))
                    : (isMajor ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, textPos - Offset(tp.width / 2, tp.height / 2));
    }

    // 5. Angka Derajat setiap 30 derajat (0°, 30°, 60°, ... 330°)
    for (int deg = 0; deg < 360; deg += 30) {
      if (deg % 90 == 0) continue; // Sudah ada N, E, S, W
      final rad = (deg - 90) * (pi / 180);
      final rDeg = radius * 0.63;
      final degPos = Offset(cx + rDeg * cos(rad), cy + rDeg * sin(rad));

      final tp = TextPainter(
        text: TextSpan(
          text: '$deg°',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, degPos - Offset(tp.width / 2, tp.height / 2));
    }

    // 6. Garis silang halus di tengah (Crosshair)
    final crossHairPaint = Paint()
      ..color = isDark
          ? const Color(0xFF334155).withValues(alpha: 0.5)
          : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(cx - radius * 0.25, cy), Offset(cx + radius * 0.25, cy), crossHairPaint);
    canvas.drawLine(Offset(cx, cy - radius * 0.25), Offset(cx, cy + radius * 0.25), crossHairPaint);
  }

  @override
  bool shouldRepaint(covariant FullCompassDialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// FULL COMPASS NEEDLE PAINTER
/// Jarum kompas 3D presisi tinggi dengan bayangan dan pusat metalik
/// ─────────────────────────────────────────────────────────────────────────────
class FullCompassNeedlePainter extends CustomPainter {
  final bool isDark;

  FullCompassNeedlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 24;

    // --- UJUNG UTARA (MERAH 3D) ---
    // Sisi terang kiri
    final nLeft = Path()
      ..moveTo(cx, cy - r * 0.95) // Puncak Utara
      ..lineTo(cx - r * 0.16, cy)
      ..lineTo(cx, cy - r * 0.1)
      ..close();
    canvas.drawPath(
      nLeft,
      Paint()
        ..color = const Color(0xFFFF5252)
        ..style = PaintingStyle.fill,
    );

    // Sisi bayangan kanan
    final nRight = Path()
      ..moveTo(cx, cy - r * 0.95)
      ..lineTo(cx + r * 0.16, cy)
      ..lineTo(cx, cy - r * 0.1)
      ..close();
    canvas.drawPath(
      nRight,
      Paint()
        ..color = const Color(0xFFD32F2F)
        ..style = PaintingStyle.fill,
    );

    // --- UJUNG SELATAN (SILVER / METALIK 3D) ---
    // Sisi terang kiri
    final sLeft = Path()
      ..moveTo(cx, cy + r * 0.95) // Puncak Selatan
      ..lineTo(cx - r * 0.16, cy)
      ..lineTo(cx, cy + r * 0.1)
      ..close();
    canvas.drawPath(
      sLeft,
      Paint()
        ..color = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B)
        ..style = PaintingStyle.fill,
    );

    // Sisi bayangan kanan
    final sRight = Path()
      ..moveTo(cx, cy + r * 0.95)
      ..lineTo(cx + r * 0.16, cy)
      ..lineTo(cx, cy + r * 0.1)
      ..close();
    canvas.drawPath(
      sRight,
      Paint()
        ..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155)
        ..style = PaintingStyle.fill,
    );

    // --- PUSAT HUB PIVOT METALIK ---
    // Cincin luar
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.18,
      Paint()
        ..color = isDark ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill,
    );

    // Cincin batas krom
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.18,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Inti batu rubi / merah
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.10,
      Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant FullCompassNeedlePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// COMPASS DETAIL DIALOG (FRAMELESS FULL SCREEN OVERLAY)
/// Layar frameless modern menampilkan kompas bulat detail, jarum gerak, angka, arah
/// ─────────────────────────────────────────────────────────────────────────────
class CompassDetailDialog extends StatefulWidget {
  final LatLng? userPosition;

  const CompassDetailDialog({
    super.key,
    this.userPosition,
  });

  @override
  State<CompassDetailDialog> createState() => _CompassDetailDialogState();
}

class _CompassDetailDialogState extends State<CompassDetailDialog>
    with SingleTickerProviderStateMixin {
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  double _filteredHeadingDeg = 0.0;

  // Nilai gravitasi untuk kompensasi kemiringan (tilt compensation)
  double _ax = 0.0, _ay = 9.8, _az = 0.0;

  @override
  void initState() {
    super.initState();
    _startRealSensor();
  }

  void _startRealSensor() {
    if (kIsWeb) return;

    try {
      // 1. Baca Accelerometer untuk kompensasi kemiringan
      _accelSub = accelerometerEventStream().listen((acc) {
        _ax = acc.x;
        _ay = acc.y;
        _az = acc.z;
      }, onError: (_) {});

      // 2. Baca Magnetometer rill asli perangkat
      _magSub = magnetometerEventStream().listen((mag) {
        double mx = mag.x;
        double my = mag.y;
        double mz = mag.z;

        // Kompensasi kemiringan jika accelerometer tersedia
        double normAcc = sqrt(_ax * _ax + _ay * _ay + _az * _az);
        double rad;
        if (normAcc > 0.5) {
          double pitch = asin((_ay / normAcc).clamp(-1.0, 1.0));
          double roll = asin((-_ax / normAcc).clamp(-1.0, 1.0));

          double cosP = cos(pitch);
          double sinP = sin(pitch);
          double cosR = cos(roll);
          double sinR = sin(roll);

          double xH = mx * cosR + mz * sinR;
          double yH = mx * sinP * sinR + my * cosP - mz * sinP * cosR;
          rad = atan2(-xH, yH);
        } else {
          // Komputasi 2D standar magnetometer
          rad = atan2(-mx, my);
        }

        double targetDeg = (rad * 180 / pi + 360) % 360;

        if (mounted) {
          setState(() {
            // Circular smoothing agar jarum bergerak halus seperti kompas mekanik asli
            double diff = targetDeg - _filteredHeadingDeg;
            while (diff < -180) {
              diff += 360;
            }
            while (diff > 180) {
              diff -= 360;
            }
            _filteredHeadingDeg = (_filteredHeadingDeg + diff * 0.22 + 360) % 360;
          });
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _magSub?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }

  String _getDirectionName(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'Utara (N)';
    if (deg >= 22.5 && deg < 67.5) return 'Timur Laut (NE)';
    if (deg >= 67.5 && deg < 112.5) return 'Timur (E)';
    if (deg >= 112.5 && deg < 157.5) return 'Tenggara (SE)';
    if (deg >= 157.5 && deg < 202.5) return 'Selatan (S)';
    if (deg >= 202.5 && deg < 247.5) return 'Barat Daya (SW)';
    if (deg >= 247.5 && deg < 292.5) return 'Barat (W)';
    return 'Barat Laut (NW)';
  }

  @override
  Widget build(BuildContext context) {
    final headingInt = _filteredHeadingDeg.round();
    final directionName = _getDirectionName(_filteredHeadingDeg);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Backdrop semi-transparan menggelap halus (frameless agar peta di belakang tetap terlihat)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),

          // 2. Konten Utama Kompas Frameless
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar: Hanya tombol Tutup (X) di kanan atas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tombol Tutup (X)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.45),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // 3. Bulat Kompas Detail (Frameless Circle)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Aura Glow Luar
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A73E8).withValues(alpha: 0.15),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      // Piringan Dial Kompas
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CustomPaint(
                          painter: FullCompassDialPainter(isDark: true),
                        ),
                      ),

                      // Jarum Kompas Berputar Mengikuti Arah Utara Riil Bumi
                      Transform.rotate(
                        angle: -(_filteredHeadingDeg * pi / 180),
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: CustomPaint(
                            painter: FullCompassNeedlePainter(isDark: true),
                          ),
                        ),
                      ),

                      // Penanda Indeks Arah Hadap Atas (Top Index Pointer)
                      Positioned(
                        top: 2,
                        child: Container(
                          width: 4,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // 4. Panel Informasi Digital (Angka & Arah) - Semi-transparan menggelap frameless
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Angka Derajat & Arah
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$headingInt',
                            style: GoogleFonts.outfit(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '°',
                            style: GoogleFonts.outfit(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            directionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Koordinat GPS jika tersedia
                      if (widget.userPosition != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.white60,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.userPosition!.latitude.toStringAsFixed(5)}°, ${widget.userPosition!.longitude.toStringAsFixed(5)}°',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 4),
                      Text(
                        'Arahkan bagian atas ponsel ke tujuan Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
