import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String _selectedCategory = 'suv';
  String _selectedColor = 'Abu-Abu Metalik';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFBF7).withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF141518)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ParkSmart ID', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF141518))),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF5E6066)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E3DB), height: 1),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 100),
            children: [
              Text('Tambah Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF141518))),
              const SizedBox(height: 4),
              Text('Daftarkan kendaraan untuk akses otomatis gerbang parkir.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF5E6066))),
              
              const SizedBox(height: 20),
              
              // 2. Quick Scan Action Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E3DB)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
                      child: const Icon(Icons.document_scanner, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pindai Plat', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF141518))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                            child: Text('AI OCR', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF065F46))),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF141518),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_camera, size: 16),
                          const SizedBox(width: 6),
                          Text('Buka Kamera', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
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
                  Text('Kategori Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141518))),
                  Text('Penentu Tarif Gerbang', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF5E6066))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _CategoryBtn(
                    icon: Icons.directions_car, title: 'Mobil / SUV', subtitle: 'Golongan I',
                    isSelected: _selectedCategory == 'suv',
                    onTap: () => setState(() => _selectedCategory = 'suv'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _CategoryBtn(
                    icon: Icons.directions_car_filled_outlined, title: 'Sedan / City', subtitle: 'Golongan I',
                    isSelected: _selectedCategory == 'sedan',
                    onTap: () => setState(() => _selectedCategory = 'sedan'),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _CategoryBtn(
                    icon: Icons.two_wheeler, title: 'Motor Roda 2', subtitle: 'Golongan II',
                    isSelected: _selectedCategory == 'motor',
                    onTap: () => setState(() => _selectedCategory = 'motor'),
                  )),
                ],
              ),

              const SizedBox(height: 20),

              // 4. Nomor Polisi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E3DB)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nomor Polisi (TNKB)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141518))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFA7F3D0))),
                          child: Row(
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('Format Resmi', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF047857))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 70,
                      decoration: BoxDecoration(color: const Color(0xFF111215), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2B2D33), width: 2)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('B 5678 KLM', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4)),
                                Text('KORLANTAS POLRI • ANPR READY', style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFFA3A3A3), letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: double.infinity, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 12)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('08 • 29', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFE5E5E5), letterSpacing: 2)),
                              Text('IDN', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFA3A3A3), letterSpacing: 1)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E3DB)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Detail Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141518))),
                        Text('Merek & Warna', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF78716C))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: 'Honda HR-V Special Edition'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.directions_car, color: Color(0xFFA8A29E)),
                        suffixIcon: const Icon(Icons.edit, color: Color(0xFFA8A29E)),
                        filled: true,
                        fillColor: const Color(0xFFF7F5ED),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5E5))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5E5))),
                      ),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF141518)),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF5F5F4)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pilihan Warna:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF57534E))),
                        Text(_selectedColor, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF141518))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ColorBtn(color: Colors.white, name: 'Putih Mutiara', selectedColor: _selectedColor, onSelect: (c) => setState(() => _selectedColor = c)),
                        const SizedBox(width: 12),
                        _ColorBtn(color: const Color(0xFF171717), name: 'Hitam Solid', selectedColor: _selectedColor, onSelect: (c) => setState(() => _selectedColor = c), isDark: true),
                        const SizedBox(width: 12),
                        _ColorBtn(color: const Color(0xFF64748B), name: 'Abu-Abu Metalik', selectedColor: _selectedColor, onSelect: (c) => setState(() => _selectedColor = c), isDark: true),
                        const SizedBox(width: 12),
                        _ColorBtn(color: const Color(0xFFBE123C), name: 'Merah Maroon', selectedColor: _selectedColor, onSelect: (c) => setState(() => _selectedColor = c), isDark: true),
                        const SizedBox(width: 12),
                        _ColorBtn(color: const Color(0xFFD6D3D1), name: 'Silver Quartz', selectedColor: _selectedColor, onSelect: (c) => setState(() => _selectedColor = c)),
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
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: const Border(top: BorderSide(color: Color(0xFFE5E3DB))),
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF141518),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 20),
                      const SizedBox(width: 8),
                      Text('Simpan Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBtn extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryBtn({required this.icon, required this.title, required this.subtitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF141518) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF141518) : const Color(0xFFE5E3DB), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? Colors.white : const Color(0xFF57534E)),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF141518))),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isSelected ? Colors.white70 : const Color(0xFF78716C))),
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
  final bool isDark;

  const _ColorBtn({required this.color, required this.name, required this.selectedColor, required this.onSelect, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final isSelected = name == selectedColor;
    return GestureDetector(
      onTap: () => onSelect(name),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD6D3D1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: isSelected ? Icon(Icons.check, size: 16, color: isDark ? Colors.white : const Color(0xFF1C1917)) : null,
      ),
    );
  }
}
