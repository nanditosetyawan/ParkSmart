import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
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
  late final TextEditingController _plateController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: 'B 5678 KLM');
    _nameController = TextEditingController(text: 'Honda HR-V Special Edition');
  }

  @override
  void dispose() {
    _plateController.dispose();
    _nameController.dispose();
    super.dispose();
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
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomCameraScreen()));
                          },
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Format Resmi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111215),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFF2B2D33),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextField(
                                      controller: _plateController,
                                      textCapitalization: TextCapitalization.characters,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 4,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
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
                                    '08 • 29',
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
                              final success = await AddVehicleBackend.instance.saveVehicle(
                                plateNumber: _plateController.text,
                                vehicleName: _nameController.text,
                                category: _selectedCategory,
                                color: _selectedColor,
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
