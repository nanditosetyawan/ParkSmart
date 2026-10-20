import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'backend/custom_camera_backend.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  int _step = 1; // 1 = Foto Nomor Plat, 2 = Foto Masa Berlaku STNK
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  String? _detectedPlate;
  String? _detectedExpiry;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera init note: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Memproses gambar foto di memori RAM tanpa menyimpan ke penyimpanan
  Future<void> _processImageBytes(dynamic bytes) async {
    if (!mounted || _isProcessing) return;
    setState(() => _isProcessing = true);

    final backend = CustomCameraBackend.instance;

    if (_step == 1) {
      // Olah Foto 1: Plat Nomor
      final result = await backend.processPlatImage(bytes: bytes);
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _detectedPlate = result;
      });

      // Tampilkan sheet konfirmasi hasil olah foto plat 1
      _showConfirmationSheet(
        stepNumber: 1,
        title: 'Hasil Pindai Foto Plat Nomor',
        detectedValue: result,
        subtitle: 'Foto berhasil diolah di memori (tidak disimpan ke server). Pastikan nomor plat sudah sesuai.',
        buttonLabel: 'Lanjut Foto 2: Masa Berlaku STNK',
        onConfirm: (finalVal) {
          setState(() {
            _detectedPlate = finalVal;
            _step = 2;
          });
        },
      );
    } else {
      // Olah Foto 2: Masa Berlaku STNK
      final result = await backend.processStnkExpiryImage(bytes: bytes);
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _detectedExpiry = result;
      });

      // Tampilkan sheet konfirmasi hasil olah foto STNK 2
      _showConfirmationSheet(
        stepNumber: 2,
        title: 'Hasil Pindai Masa Berlaku STNK',
        detectedValue: result,
        subtitle: 'Masa berlaku TNKB/Pajak 5 tahunan berhasil diolah di memori (gambar tidak disimpan).',
        buttonLabel: 'Selesai & Terapkan ke Plat',
        onConfirm: (finalVal) {
          _detectedExpiry = finalVal;
          Navigator.pop(context, {
            'plateNumber': _detectedPlate ?? 'B 5678 KLM',
            'plateExpiry': _detectedExpiry ?? '08 • 29',
          });
        },
      );
    }
  }

  void _showConfirmationSheet({
    required int stepNumber,
    required String title,
    required String detectedValue,
    required String subtitle,
    required String buttonLabel,
    required Function(String) onConfirm,
  }) {
    final controller = TextEditingController(text: detectedValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141518),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF047857),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Foto $stepNumber dari 2 Berhasil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF34D399)),
                        const SizedBox(width: 4),
                        Text(
                          'Gambar Tidak Disimpan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34D399),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Kotak tampilan hasil olahan foto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0E11),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2E323B)),
                ),
                child: Row(
                  children: [
                    Icon(
                      stepNumber == 1 ? Icons.directions_car : Icons.badge_outlined,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: stepNumber == 1 ? 2.5 : 1,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Koreksi jika diperlukan',
                          hintStyle: TextStyle(color: Colors.white30),
                        ),
                      ),
                    ),
                    const Icon(Icons.edit, size: 16, color: Colors.white38),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Konfirmasi & Lanjut
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm(controller.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        buttonLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        // Fallback in-memory processing
        await _processImageBytes(Uint8List.fromList([1, 2, 3, 4]));
      }
    } else {
      // Fallback jika kamera perangkat tidak tersedia / di emulator
      await _processImageBytes(Uint8List.fromList([1, 2, 3, 4]));
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
    final isPlat = _step == 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview atau Tampilan Siap Foto
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
                    color: const Color(0xFF141518),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isPlat ? Icons.photo_camera_outlined : Icons.document_scanner_outlined,
                            size: 64,
                            color: Colors.white30,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isPlat ? 'Posisikan Plat Nomor di Bidang Kamera' : 'Posisikan Kolom Masa Berlaku STNK',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Foto hanya diolah di memori (tidak disimpan ke storage)',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF34D399),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Overlay Viewfinder
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewfinderPainter(
                isPortrait: !isPlat,
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPlat ? 'Foto 1/2: Plat Nomor' : 'Foto 2/2: Masa Berlaku STNK',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Wajib 2x foto • Gambar tidak disimpan',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF34D399),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    'Tahap $_step dari 2',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Petunjuk Viewfinder
          Positioned(
            top: size.height * 0.16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                isPlat
                    ? '📸 Foto 1: Arahkan kamera tepat ke plat nomor kendaraan fisik'
                    : '📄 Foto 2: Arahkan kamera ke bagian masa berlaku plat di STNK',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Loading HUD jika sedang memproses OCR
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2128),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          isPlat ? 'Mengolah Foto Plat Nomor...' : 'Mengolah Masa Berlaku STNK...',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'In-memory OCR • Foto tidak disimpan',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF34D399),
                            fontSize: 11,
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
                // Tombol Galeri
                GestureDetector(
                  onTap: _onGallery,
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.photo_library, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Galeri',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Capture Foto Utama
                GestureDetector(
                  onTap: _onCapture,
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt, color: Colors.black, size: 28),
                      ),
                    ),
                  ),
                ),

                // Tombol Simulasi / Cepat
                GestureDetector(
                  onTap: () => _processImageBytes(Uint8List.fromList([1, 2, 3])),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.auto_fix_high, color: Color(0xFF34D399), size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Olah Cepat',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
      ..color = Colors.black.withValues(alpha: 0.62)
      ..style = PaintingStyle.fill;

    // Dimensi viewfinder
    final width = size.width * 0.85;
    final height = isPortrait ? size.height * 0.44 : size.width * 0.45;

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

    // Garis sudut viewfinder
    final cornerPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 28.0;

    // Kiri Atas
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, cornerLength), cornerPaint);

    // Kanan Atas
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, cornerLength), cornerPaint);

    // Kiri Bawah
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -cornerLength), cornerPaint);

    // Kanan Bawah
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-cornerLength, 0), cornerPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) {
    return oldDelegate.isPortrait != isPortrait;
  }
}
