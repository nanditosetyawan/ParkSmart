import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/theme_service.dart';
import '../../core/utils/image_compression_util.dart';
import 'custom_camera_screen.dart';
import 'backend/add_vehicle_backend.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String _selectedCategory = 'suv';
  String _selectedColor = 'Abu-Abu Metalik';
  String? _scannedPlate;
  String? _scannedExpiry;
  late final TextEditingController _nameController;

  // Foto fisik kendaraan (opsional) dengan kompresi 70% tidak buram
  Uint8List? _vehiclePhotoBytes;
  bool _isCompressingPhoto = false;
  String? _compressionInfo;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Honda HR-V Special Edition');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickVehiclePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked == null) return;

      setState(() => _isCompressingPhoto = true);

      final rawBytes = await picked.readAsBytes();

      // Kompresi kualitas 70% dengan resolusi tetap tajam (targetWidth: 1200px)
      final compressionResult = await ImageCompressionUtil.compressBrutally(
        rawBytes,
        targetWidth: 1200,
        quality: 70,
      );

      setState(() {
        _vehiclePhotoBytes = compressionResult.compressedBytes;
        _compressionInfo = '${compressionResult.originalSizeFormatted} → ${compressionResult.compressedSizeFormatted} (Hemat ${compressionResult.ratioFormatted})';
        _isCompressingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto kendaraan berhasil dikompres 70%: $_compressionInfo'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isCompressingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto kendaraan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoSourceSheet(BuildContext context) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unggah Foto Kendaraan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih sumber foto (otomatis dikompres 70% jernih):',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: theme.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickVehiclePhoto(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? theme.surfaceField : const Color(0xFF141518),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickVehiclePhoto(ImageSource.gallery);
                    },
                    icon: Icon(Icons.photo_library, size: 18, color: theme.textPrimary),
                    label: Text('Galeri', style: TextStyle(color: theme.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _openCameraScanner() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const CustomCameraScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _scannedPlate = result['plateNumber'];
        _scannedExpiry = result['plateExpiry'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto 2x berhasil diolah! Plat: $_scannedPlate • Masa Berlaku: $_scannedExpiry'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, AddVehicleBackend.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: theme.bg,
          appBar: AppBar(
            backgroundColor: theme.bg.withValues(alpha: 0.95),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'ParkSmart ID',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline, color: theme.textSecondary),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: theme.border, height: 1),
            ),
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100),
                children: [
                  Text(
                    'Tambah Kendaraan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 2. Quick Scan Action Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF3B2720) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF7C2D12) : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Icon(
                            Icons.document_scanner,
                            color: isDark ? const Color(0xFFFB923C) : const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pindai Plat',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'AI OCR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _openCameraScanner,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : const Color(0xFF141518),
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.photo_camera, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Buka Kamera',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Kategori Kendaraan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kategori Kendaraan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      Text(
                        'Penentu Tarif Gerbang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryBtn(
                          icon: Icons.directions_car,
                          title: 'Mobil / SUV',
                          subtitle: 'Golongan I',
                          isSelected: _selectedCategory == 'suv',
                          isDark: isDark,
                          theme: theme,
                          onTap: () => setState(() => _selectedCategory = 'suv'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryBtn(
                          icon: Icons.directions_car_filled_outlined,
                          title: 'Sedan / City',
                          subtitle: 'Golongan I',
                          isSelected: _selectedCategory == 'sedan',
                          isDark: isDark,
                          theme: theme,
                          onTap: () => setState(() => _selectedCategory = 'sedan'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryBtn(
                          icon: Icons.two_wheeler,
                          title: 'Motor Roda 2',
                          subtitle: 'Golongan II',
                          isSelected: _selectedCategory == 'motor',
                          isDark: isDark,
                          theme: theme,
                          onTap: () => setState(() => _selectedCategory = 'motor'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. Nomor Polisi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nomor Polisi (TNKB)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: _openCameraScanner,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _scannedPlate != null
                                      ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                                      : (isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _scannedPlate != null
                                        ? (isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0))
                                        : (isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _scannedPlate != null
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _scannedPlate != null
                                          ? 'Terverifikasi Foto'
                                          : 'Wajib Foto (2x)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _scannedPlate != null
                                            ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                                            : (isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // KOTAK HITAM PLAT (BUKAN INPUT TEKS - HASIL OLAHAN FOTO 2X)
                        GestureDetector(
                          onTap: _openCameraScanner,
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111215),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _scannedPlate != null
                                    ? const Color(0xFF34D399)
                                    : (isDark ? theme.border : const Color(0xFF2B2D33)),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: _scannedPlate == null
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.white12),
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: Color(0xFF34D399),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'AMBIL FOTO PLAT & STNK (2X)',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Ketuk di sini untuk memindai • Gambar tidak disimpan',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 10,
                                                      color: const Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: double.infinity,
                                        color: Colors.white24,
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '-- • --',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF94A3B8),
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          Text(
                                            'IDN',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFA3A3A3),
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _scannedPlate!,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 4,
                                              ),
                                            ),
                                            Text(
                                              'KORLANTAS POLRI',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 8,
                                                color: const Color(0xFFA3A3A3),
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: double.infinity,
                                        color: Colors.white24,
                                        margin: const EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _scannedExpiry ?? '08 • 29',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFFE5E5E5),
                                              letterSpacing: 2,
                                            ),
                                          ),
                                          Text(
                                            'IDN',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFA3A3A3),
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _scannedPlate != null ? Icons.verified : Icons.info_outline,
                              size: 13,
                              color: _scannedPlate != null
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _scannedPlate != null
                                    ? 'Plat dan masa berlaku terisi dari foto (ketuk untuk foto ulang).'
                                    : 'Bukan input teks manual. Wajib difoto 2x (plat & STNK). Gambar hanya diolah.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: _scannedPlate != null
                                      ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                                      : (isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Detail Kendaraan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Detail Kendaraan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            Text(
                              'Merek & Warna',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.directions_car, color: theme.textMuted),
                            suffixIcon: Icon(Icons.edit, color: theme.textMuted),
                            filled: true,
                            fillColor: isDark ? theme.surfaceField : const Color(0xFFF7F5ED),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: isDark ? Colors.white : theme.accent, width: 1.5),
                            ),
                          ),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: theme.divider),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pilihan Warna:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.textSecondary,
                              ),
                            ),
                            Text(
                              _selectedColor,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ColorBtn(
                              color: Colors.white,
                              name: 'Putih Mutiara',
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFF171717),
                              name: 'Hitam Solid',
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              isDarkItem: true,
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFF64748B),
                              name: 'Abu-Abu Metalik',
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              isDarkItem: true,
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFFBE123C),
                              name: 'Merah Maroon',
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              isDarkItem: true,
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFFD6D3D1),
                              name: 'Silver Quartz',
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              theme: theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Input Foto Fisik Kendaraan Sederhana (Dikompres 70% Tidak Buram)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 18, color: theme.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'Foto Fisik Kendaraan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Opsional • Kompres 70%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isCompressingPhoto)
                          Container(
                            height: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDark ? theme.surfaceField : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Mengompres foto 70%...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (_vehiclePhotoBytes != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _vehiclePhotoBytes!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showPhotoSourceSheet(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.75),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.edit, size: 13, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Ganti',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _vehiclePhotoBytes = null;
                                          _compressionInfo = null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626).withValues(alpha: 0.85),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_compressionInfo != null)
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, size: 12, color: Color(0xFF34D399)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _compressionInfo!,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () => _showPhotoSourceSheet(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark ? theme.surfaceField : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.border),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: (isDark ? Colors.white : theme.accent).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 24,
                                      color: isDark ? Colors.white : theme.accent,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pilih Foto Kendaraan (Kamera / Galeri)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Foto jernih & dikompres 70% otomatis tanpa buram',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
              
              // 7. Bottom CTA
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.card.withValues(alpha: 0.95),
                    border: Border(top: BorderSide(color: theme.border)),
                  ),
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: AddVehicleBackend.instance.isLoading
                          ? null
                          : () async {
                              if (_scannedPlate == null || _scannedExpiry == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Wajib mengambil 2 foto: Plat Nomor & Masa Berlaku STNK terlebih dahulu!'),
                                    backgroundColor: Color(0xFFDC2626),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                _openCameraScanner();
                                return;
                              }

                              final success = await AddVehicleBackend.instance.saveVehicle(
                                plateNumber: _scannedPlate!,
                                plateExpiry: _scannedExpiry!,
                                vehicleName: _nameController.text,
                                category: _selectedCategory,
                                color: _selectedColor,
                                vehiclePhotoBytes: _vehiclePhotoBytes,
                              );
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kendaraan berhasil disimpan!'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AddVehicleBackend.instance.errorMessage ?? 'Gagal menyimpan kendaraan'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF141518),
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: AddVehicleBackend.instance.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Simpan Kendaraan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryBtn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final ThemeService theme;
  final VoidCallback onTap;

  const _CategoryBtn({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF141518))
              : (isDark ? theme.surfaceField : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF141518))
                : theme.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : theme.iconColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : theme.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: isSelected
                    ? (isDark ? Colors.black54 : Colors.white70)
                    : theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorBtn extends StatelessWidget {
  final Color color;
  final String name;
  final String selectedColor;
  final Function(String) onSelect;
  final bool isDarkItem;
  final ThemeService theme;

  const _ColorBtn({
    required this.color,
    required this.name,
    required this.selectedColor,
    required this.onSelect,
    this.isDarkItem = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = name == selectedColor;
    return GestureDetector(
      onTap: () => onSelect(name),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: theme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color: isDarkItem ? Colors.white : const Color(0xFF1C1917),
              )
            : null,
      ),
    );
  }
}
