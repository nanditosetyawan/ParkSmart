import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../../core/utils/image_compression_util.dart';
import '../../core/utils/stnk_expiry_formatter.dart';
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
  late final TextEditingController _plateController;
  late final TextEditingController _expiryController;

  // Foto fisik kendaraan (opsional) dengan kompresi 70% tidak buram
  Uint8List? _vehiclePhotoBytes;
  bool _isCompressingPhoto = false;
  String? _compressionInfo;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _plateController = TextEditingController();
    _expiryController = TextEditingController(text: '10 • 28');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _expiryController.dispose();
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
              'Unggah Foto Kendaraan'.tr,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih sumber foto (otomatis dikompres 70% jernih):'.tr,
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
                    label: Text('Kamera'.tr),
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
                    label: Text('Galeri'.tr, style: TextStyle(color: theme.textPrimary)),
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
        if (_scannedPlate != null) _plateController.text = _scannedPlate!;
        if (_scannedExpiry != null) _expiryController.text = _scannedExpiry!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto 2x berhasil diolah! Plat: ${_plateController.text} • Masa Berlaku: ${_expiryController.text}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  void _showEditPlateDialog() {
    final tempPlateCtrl = TextEditingController(text: _plateController.text);
    final tempExpiryCtrl = TextEditingController(text: _expiryController.text.isNotEmpty ? _expiryController.text : '10 • 28');
    final isDark = ThemeService.instance.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E232B) : Colors.white,
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Ketik / Edit Plat Nomor Kendaraan'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Masukkan plat nomor kendaraan Anda (bebas menambahkan banyak kendaraan)'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tempPlateCtrl,
                textCapitalization: TextCapitalization.characters,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Nomor Plat (TNKB)'.tr,
                  hintText: 'Contoh: B 1234 ABC',
                  prefixIcon: const Icon(Icons.pin),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2E3848) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tempExpiryCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\s•\.\/\-]')),
                  StnkExpiryInputFormatter(),
                ],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Masa Berlaku STNK (MM • YY)'.tr,
                  hintText: 'MM • YY (Contoh: 10 • 28)',
                  prefixIcon: const Icon(Icons.date_range),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2E3848) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: 'Template otomatis dengan dot pemisah: Bulan • Tahun'.tr,
                  helperStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                  suffixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MM • YY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Template Cepat:'.tr,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          '10 • 28',
                          '12 • 28',
                          '05 • 29',
                          '10 • 30',
                          'Aktif Selamanya',
                        ].map((tpl) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () {
                                tempExpiryCtrl.text = tpl;
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2E3848) : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? Colors.white12 : Colors.black12,
                                  ),
                                ),
                                child: Text(
                                  tpl,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              // Live Plat Preview
              AnimatedBuilder(
                animation: Listenable.merge([tempPlateCtrl, tempExpiryCtrl]),
                builder: (context, _) {
                  final plate = tempPlateCtrl.text.trim().toUpperCase();
                  final exp = tempExpiryCtrl.text.trim();
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 14, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111215),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: plate.isNotEmpty ? const Color(0xFF34D399) : const Color(0xFF2E3848),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                plate.isNotEmpty ? plate : 'B 1234 ABC',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.5,
                                ),
                              ),
                              Text(
                                'KORLANTAS POLRI',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 7.5,
                                  color: const Color(0xFFA3A3A3),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white24,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              exp.isNotEmpty ? exp : '10 • 28',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF34D399),
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'IDN',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFA3A3A3),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final cleanPlate = tempPlateCtrl.text.trim().toUpperCase();
                    if (cleanPlate.isEmpty) return;
                    final rawExpiry = tempExpiryCtrl.text.trim();
                    final formattedExpiry = rawExpiry.isEmpty
                        ? '10 • 28'
                        : (rawExpiry.contains('•') || rawExpiry == 'Aktif Selamanya'
                            ? rawExpiry
                            : StnkExpiryInputFormatter.format(rawExpiry));
                    setState(() {
                      _plateController.text = cleanPlate;
                      _expiryController.text = formattedExpiry;
                      _scannedPlate = cleanPlate;
                      _scannedExpiry = _expiryController.text;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Terapkan Plat'.tr,
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, AddVehicleBackend.instance, LanguageService.instance]),
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
                    'Tambah Kendaraan'.tr,
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
                                'Pindai Plat'.tr,
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
                                'Buka Kamera'.tr,
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
                        'Kategori Kendaraan'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
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
                          title: 'Mobil / SUV'.tr,
                          subtitle: 'Golongan I'.tr,
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
                          title: 'Sedan / City'.tr,
                          subtitle: 'Golongan I'.tr,
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
                          title: 'Motor Roda 2'.tr,
                          subtitle: 'Golongan II'.tr,
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
                              'Nomor Polisi (TNKB)'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            Container(
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
                                        ? 'Terverifikasi Foto'.tr
                                        : 'Wajib Foto (2x)'.tr,
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
                          ],
                        ),
                        const SizedBox(height: 12),

                        // KOTAK HITAM PLAT (KETUK UNTUK EDIT / TAMPILKAN HASIL SCAN)
                        GestureDetector(
                          onTap: _showEditPlateDialog,
                          child: Container(
                            width: double.infinity,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111215),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _plateController.text.isNotEmpty
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
                            child: _plateController.text.isEmpty
                                ? Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.edit_note, color: Colors.white70, size: 22),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Ketuk untuk Masukkan Plat Manual / Foto Kamera'.tr,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _plateController.text,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 4,
                                                ),
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
                                            _expiryController.text.isNotEmpty ? _expiryController.text : '10 • 28',
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
                                      const SizedBox(width: 8),
                                      const Icon(Icons.edit, size: 16, color: Color(0xFF34D399)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openCameraScanner,
                                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                label: Text('Foto Kamera (2x)'.tr, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: theme.border),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showEditPlateDialog,
                                icon: const Icon(Icons.edit, size: 16),
                                label: Text('Ketik Manual'.tr, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: theme.border),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _plateController.text.isNotEmpty ? Icons.verified : Icons.info_outline,
                              size: 13,
                              color: _plateController.text.isNotEmpty
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _plateController.text.isNotEmpty
                                    ? 'Plat siap didaftarkan. Ketuk plat atau tombol "Ketik Manual" jika ingin mengubah.'.tr
                                    : 'Gunakan tombol di atas untuk foto plat atau ketik manual plat kendaraan Anda.'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: _plateController.text.isNotEmpty
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
                              'Detail Kendaraan'.tr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            Text(
                              'Merek & Warna'.tr,
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
                              'Pilihan Warna:'.tr,
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
                              name: 'Putih Mutiara'.tr,
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFF171717),
                              name: 'Hitam Solid'.tr,
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              isDarkItem: true,
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFF64748B),
                              name: 'Abu-Abu Metalik'.tr,
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              isDarkItem: true,
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFFBE123C),
                              name: 'Merah Maroon'.tr,
                              selectedColor: _selectedColor,
                              onSelect: (c) => setState(() => _selectedColor = c),
                              isDarkItem: true,
                              theme: theme,
                            ),
                            const SizedBox(width: 12),
                            _ColorBtn(
                              color: const Color(0xFFD6D3D1),
                              name: 'Silver Quartz'.tr,
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
                                  'Foto Fisik Kendaraan'.tr,
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
                                'Opsional • Kompres 70%'.tr,
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
                                              'Ganti'.tr,
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
                                    'Pilih Foto Kendaraan (Kamera / Galeri)'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Foto jernih & dikompres 70% otomatis tanpa buram'.tr,
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
                              if (_plateController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Nomor plat kendaraan wajib diisi! Silakan scan kamera atau ketik manual.'.tr),
                                    backgroundColor: const Color(0xFFDC2626),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                _showEditPlateDialog();
                                return;
                              }

                              final success = await AddVehicleBackend.instance.saveVehicle(
                                plateNumber: _plateController.text.trim(),
                                plateExpiry: _expiryController.text.trim().isNotEmpty ? _expiryController.text.trim() : '10 • 28',
                                vehicleName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Kendaraan Saya',
                                category: _selectedCategory,
                                color: _selectedColor,
                                vehiclePhotoBytes: _vehiclePhotoBytes,
                              );
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Kendaraan berhasil disimpan!'.tr),
                                      backgroundColor: const Color(0xFF10B981),
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
                                  'Simpan Kendaraan'.tr,
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
