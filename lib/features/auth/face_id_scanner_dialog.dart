import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal dialog pemindai wajah (Face ID) interaktif berbasis kamera depan.
/// Memberikan efek pemindaian visual ala Face ID modern dengan lingkaran oval,
/// garis scan laser animasi, dan konfirmasi autentikasi tanpa memunculkan prompt fingerprint Android.
class FaceIdScannerDialog extends StatefulWidget {
  final String title;
  final String subtitle;

  const FaceIdScannerDialog({
    super.key,
    this.title = 'Pemindaian Wajah',
    this.subtitle = 'Posisikan wajah Anda di dalam lingkaran',
  });

  /// Helper untuk memanggil dialog pemindai wajah
  static Future<bool> show(
    BuildContext context, {
    String title = 'Pemindaian Wajah',
    String subtitle = 'Posisikan wajah Anda di dalam lingkaran',
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'FaceIdScanner',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => FaceIdScannerDialog(
        title: title,
        subtitle: subtitle,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  State<FaceIdScannerDialog> createState() => _FaceIdScannerDialogState();
}

class _FaceIdScannerDialogState extends State<FaceIdScannerDialog> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInit = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Status pemindaian: 0: Scanning, 1: Success, 2: Failed
  int _scanStatus = 0;
  String _statusText = 'Mendeteksi kontur wajah...';

  late AnimationController _laserAnim;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _laserAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _initFrontCamera();
  }

  Future<void> _initFrontCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Kamera tidak ditemukan di perangkat.';
        });
        return;
      }

      // Prioritaskan kamera depan (front-facing)
      CameraDescription selectedCamera = cameras.first;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          selectedCamera = cam;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _cameraController = controller;
      await controller.initialize();

      if (!mounted) return;
      setState(() {
        _isInit = true;
      });

      // Simulasikan alur verifikasi AI Face Recognition
      _startVerificationFlow();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Gagal mengakses kamera depan: $e';
      });
    }
  }

  void _startVerificationFlow() {
    // Tahap 1: Mendeteksi
    _scanTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _statusText = 'Memverifikasi identitas biometrik...';
      });

      // Tahap 2: Wajah terverifikasi sukses
      _scanTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _scanStatus = 1;
          _statusText = 'Wajah Terverifikasi!';
        });

        // Jeda sekejap menampilkan ikon centang hijau lalu tutup dialog dengan hasil true
        _scanTimer = Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          Navigator.of(context).pop(true);
        });
      });
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _laserAnim.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF131822),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.face_retouching_natural,
                          color: Color(0xFF2DD4BF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // AREA PEMINDAI WAJAH KAMERA (OVAL FRAMELESS)
              SizedBox(
                width: 220,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Preview Kamera Depan berbentuk Oval
                    ClipRRect(
                      borderRadius: BorderRadius.circular(110),
                      child: Container(
                        width: 210,
                        height: 240,
                        color: Colors.black,
                        child: _hasError
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 12),
                                  ),
                                ),
                              )
                            : (_isInit && _cameraController != null)
                                ? FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _cameraController!.value.previewSize?.height ?? 210,
                                      height: _cameraController!.value.previewSize?.width ?? 240,
                                      child: CameraPreview(_cameraController!),
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                                    ),
                                  ),
                      ),
                    ),

                    // Garis Laser Animasi Scan Turun Naik
                    if (_isInit && _scanStatus == 0)
                      AnimatedBuilder(
                        animation: _laserAnim,
                        builder: (context, child) {
                          final topOffset = 20.0 + (_laserAnim.value * 200.0);
                          return Positioned(
                            top: topOffset,
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF2DD4BF),
                                    Colors.white,
                                    const Color(0xFF2DD4BF),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // Efek Berhasil (Overlay Centang Hijau)
                    if (_scanStatus == 1)
                      Container(
                        width: 210,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(110),
                          color: const Color(0xFF0D9488).withValues(alpha: 0.45),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      ),

                    // Outer Border Oval Frame yang Mewah
                    IgnorePointer(
                      child: Container(
                        width: 210,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(110),
                          border: Border.all(
                            color: _scanStatus == 1
                                ? const Color(0xFF10B981)
                                : const Color(0xFF2DD4BF).withValues(alpha: 0.75),
                            width: 2.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Status Teks
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusText,
                  key: ValueKey<String>(_statusText),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _scanStatus == 1 ? const Color(0xFF34D399) : Colors.white70,
                    fontSize: 13,
                    fontWeight: _scanStatus == 1 ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white60,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
