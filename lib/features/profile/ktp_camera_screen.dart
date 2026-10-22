import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'backend/ktp_camera_backend.dart';
import 'backend/profile_backend.dart';

class KtpCameraScreen extends StatefulWidget {
  const KtpCameraScreen({super.key});

  @override
  State<KtpCameraScreen> createState() => _KtpCameraScreenState();
}

class _KtpCameraScreenState extends State<KtpCameraScreen> {
  int _step = 1; // 1 = Foto KTP, 2 = Selfie KTP
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _processingStatus = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _processImageBytes(Uint8List bytes) async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
      _processingStatus = _step == 1 
          ? 'Mengompres brutal (~95%) & Mengunggah KTP...' 
          : 'Mengompres brutal (~95%) & Mengunggah Selfie...';
    });

    final backend = KtpCameraBackend.instance;
    final currentUid = ProfileBackend.instance.userId.isNotEmpty ? ProfileBackend.instance.userId : null;
    final currentUName = ProfileBackend.instance.name.isNotEmpty ? ProfileBackend.instance.name : 'Pengguna';

    if (_step == 1) {
      final success = await backend.uploadKtpPhoto(bytes: bytes, userId: currentUid);
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto KTP berhasil dikompresi 95% & diunggah! Lanjut tahap selfie.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _step = 2;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(backend.errorMessage ?? 'Gagal mengunggah foto KTP.'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } else {
      final success = await backend.uploadSelfiePhoto(bytes: bytes, userId: currentUid);
      if (!mounted) return;

      if (success) {
        setState(() {
          _processingStatus = 'Menyimpan pengajuan KYC ke database...';
        });

        // Submit pengajuan KYC ke Supabase user_kyc
        final submitSuccess = await backend.submitKycApplication(
          userId: currentUid,
          nik: '3171012304950001',
          fullName: currentUName,
          birthPlaceCity: 'Surakarta',
          birthDate: DateTime(1961, 6, 21),
          address: 'Jl. Kutai Utara, Solo',
          gender: 'Laki-laki',
          religion: 'Islam',
          occupation: 'Wirausaha',
        );

        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });

        if (submitSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: const Color(0xFF1E232B),
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'KYC Berhasil Diajukan',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Foto KTP & Selfie berhasil dikompresi 95% dan diunggah ke Supabase Storage (kyc-documents). Berkas telah tersimpan di antrean verifikasi Super Admin (ACC).',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context); // Kembali ke profil
                  },
                  child: Text(
                    'Selesai',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(backend.errorMessage ?? 'Gagal menyimpan pengajuan KYC.'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(backend.errorMessage ?? 'Gagal mengunggah foto selfie.'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _onCapture() async {
    if (_isProcessing) return;

    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final XFile file = await _controller!.takePicture();
        final bytes = await file.readAsBytes();
        await _processImageBytes(bytes);
      } catch (e) {
        debugPrint('Error taking picture: $e');
      }
    }
  }

  Future<void> _onGallery() async {
    if (_isProcessing) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        await _processImageBytes(bytes);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isKtp = _step == 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: _isCameraInitialized && _controller != null
                ? SizedBox(
                    width: size.width,
                    height: size.height,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.previewSize?.height ?? size.width,
                        height: _controller!.value.previewSize?.width ?? size.height,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF1C1D1F),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),

          // Overlay Viewfinder
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewfinderPainter(
                isPortrait: !isKtp, 
              ),
            ),
          ),

          // Top Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isKtp ? 'Foto KTP Fisik' : 'Selfie Bersama KTP',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
                  child: Text(
                    'Tahap $_step dari 2',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Minimalist Hint
          Positioned(
            top: size.height * 0.15,
            left: 20,
            right: 20,
            child: Text(
              isKtp 
                  ? 'Arahkan kamera ke KTP hingga pas di dalam kotak. Teks akan dikompresi brutal 95% otomatis.' 
                  : 'Posisikan wajah dan KTP dengan jelas. Hindari pantulan cahaya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, shadows: [
                Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1))
              ]),
            ),
          ),

          // Processing Loading Indicator Overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E232B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _processingStatus,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gallery Button
                GestureDetector(
                  onTap: _onGallery,
                  child: Column(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.photo_library, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text('Galeri', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // Capture Button
                GestureDetector(
                  onTap: _onCapture,
                  child: Container(
                    width: 72, height: 72,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),

                // Flash Toggle
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.flash_off, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text('Flash', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  final bool isPortrait;

  _ViewfinderPainter({required this.isPortrait});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final width = size.width * 0.85;
    final height = isPortrait ? size.height * 0.6 : size.width * 0.55;
    
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16))),
    );

    canvas.drawPath(path, paint);

    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 32.0;

    // Top Left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, cornerLength), cornerPaint);

    // Top Right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, cornerLength), cornerPaint);

    // Bottom Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -cornerLength), cornerPaint);

    // Bottom Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) {
    return oldDelegate.isPortrait != isPortrait;
  }
}
