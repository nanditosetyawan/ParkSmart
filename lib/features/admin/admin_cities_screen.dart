import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCitiesScreen extends StatefulWidget {
  const AdminCitiesScreen({super.key});

  @override
  State<AdminCitiesScreen> createState() => _AdminCitiesScreenState();
}

class _AdminCitiesScreenState extends State<AdminCitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRegion = 'Semua';

  final List<String> _regions = [
    'Semua',
    'Jawa',
    'Sumatera',
    'Bali & Nusa Tenggara',
    'Kalimantan',
    'Sulawesi',
  ];

  final List<Map<String, dynamic>> _cities = [
    {'name': 'Jakarta Pusat', 'province': 'DKI Jakarta', 'region': 'Jawa', 'locations': 18, 'isActive': true},
    {'name': 'Jakarta Barat', 'province': 'DKI Jakarta', 'region': 'Jawa', 'locations': 14, 'isActive': true},
    {'name': 'Jakarta Selatan', 'province': 'DKI Jakarta', 'region': 'Jawa', 'locations': 20, 'isActive': true},
    {'name': 'Surabaya', 'province': 'Jawa Timur', 'region': 'Jawa', 'locations': 12, 'isActive': true},
    {'name': 'Bandung', 'province': 'Jawa Barat', 'region': 'Jawa', 'locations': 9, 'isActive': true},
    {'name': 'Yogyakarta', 'province': 'D.I. Yogyakarta', 'region': 'Jawa', 'locations': 7, 'isActive': true},
    {'name': 'Semarang', 'province': 'Jawa Tengah', 'region': 'Jawa', 'locations': 6, 'isActive': true},
    {'name': 'Denpasar', 'province': 'Bali', 'region': 'Bali & Nusa Tenggara', 'locations': 8, 'isActive': true},
    {'name': 'Medan', 'province': 'Sumatera Utara', 'region': 'Sumatera', 'locations': 5, 'isActive': true},
    {'name': 'Palembang', 'province': 'Sumatera Selatan', 'region': 'Sumatera', 'locations': 4, 'isActive': true},
    {'name': 'Makassar', 'province': 'Sulawesi Selatan', 'region': 'Sulawesi', 'locations': 5, 'isActive': true},
    {'name': 'Balikpapan', 'province': 'Kalimantan Timur', 'region': 'Kalimantan', 'locations': 3, 'isActive': true},
    {'name': 'Malang', 'province': 'Jawa Timur', 'region': 'Jawa', 'locations': 4, 'isActive': true},
    {'name': 'Surakarta (Solo)', 'province': 'Jawa Tengah', 'region': 'Jawa', 'locations': 3, 'isActive': true},
    {'name': 'Batam', 'province': 'Kepulauan Riau', 'region': 'Sumatera', 'locations': 2, 'isActive': false},
    {'name': 'Padang', 'province': 'Sumatera Barat', 'region': 'Sumatera', 'locations': 0, 'isActive': false},
    {'name': 'Pekanbaru', 'province': 'Riau', 'region': 'Sumatera', 'locations': 0, 'isActive': false},
    {'name': 'Banjarmasin', 'province': 'Kalimantan Selatan', 'region': 'Kalimantan', 'locations': 0, 'isActive': false},
    {'name': 'Pontianak', 'province': 'Kalimantan Barat', 'region': 'Kalimantan', 'locations': 0, 'isActive': false},
    {'name': 'Manado', 'province': 'Sulawesi Utara', 'region': 'Sulawesi', 'locations': 0, 'isActive': false},
    {'name': 'Mataram', 'province': 'Nusa Tenggara Barat', 'region': 'Bali & Nusa Tenggara', 'locations': 0, 'isActive': false},
    {'name': 'Kupang', 'province': 'Nusa Tenggara Timur', 'region': 'Bali & Nusa Tenggara', 'locations': 0, 'isActive': false},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCities {
    return _cities.where((c) {
      final matchesSearch = c['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          c['province'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesRegion = _selectedRegion == 'Semua' || c['region'] == _selectedRegion;
      return matchesSearch && matchesRegion;
    }).toList();
  }

  void _showAddCityDialog() {
    final nameCtrl = TextEditingController();
    final provCtrl = TextEditingController();
    String selectedReg = 'Jawa';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Text('Tambah Kota Operasional', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Kota / Kabupaten',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: provCtrl,
                decoration: InputDecoration(
                  labelText: 'Provinsi',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedReg,
                decoration: InputDecoration(
                  labelText: 'Wilayah Regional',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _regions.where((r) => r != 'Semua').map((r) => DropdownMenuItem(value: r, child: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedReg = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && provCtrl.text.isNotEmpty) {
                  setState(() {
                    _cities.insert(0, {
                      'name': nameCtrl.text,
                      'province': provCtrl.text,
                      'region': selectedReg,
                      'locations': 0,
                      'isActive': true,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kota ${nameCtrl.text} berhasil ditambahkan!'),
                      backgroundColor: const Color(0xFF17A18A),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114177),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _cities.where((c) => c['isActive'] == true).length;
    final totalLocations = _cities.fold<int>(0, (sum, c) => sum + (c['locations'] as int));

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Master Kota & Wilayah', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Manajemen Jangkauan Operasional ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined, color: Color(0xFF114177)),
            onPressed: _showAddCityDialog,
            tooltip: 'Tambah Kota',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Stat overview
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatCard('Total Kota', '${_cities.length}', const Color(0xFF114177), const Color(0xFFE3EEFF)),
                    const SizedBox(width: 10),
                    _buildStatCard('Kota Aktif', '$activeCount', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                    const SizedBox(width: 10),
                    _buildStatCard('Lokasi Parkir', '$totalLocations', const Color(0xFFE07A5F), const Color(0xFFFDECE7)),
                  ],
                ),
                const SizedBox(height: 14),

                // Search box
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: Color(0xFF76777B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                          decoration: InputDecoration(
                            hintText: 'Cari kota atau provinsi...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Region filter chips
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _regions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final reg = _regions[index];
                final isSelected = _selectedRegion == reg;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRegion = reg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF114177) : const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        reg,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF45474A),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Cities List
          Expanded(
            child: _filteredCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_outlined, size: 48, color: Color(0xFF76777B)),
                        const SizedBox(height: 12),
                        Text('Tidak ada kota yang cocok', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredCities.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      final bool isActive = city['isActive'] as bool;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE4DFD5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFD1F2EB) : const Color(0xFFF1EEE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.location_city,
                                size: 22,
                                color: isActive ? const Color(0xFF17A18A) : const Color(0xFF76777B),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(city['name'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1EEE7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(city['region'], style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(city['province'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.local_parking, size: 12, color: Color(0xFF114177)),
                                      const SizedBox(width: 4),
                                      Text('${city['locations']} Lokasi Terdaftar', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isActive,
                              activeThumbColor: const Color(0xFF17A18A),
                              onChanged: (val) {
                                setState(() {
                                  city['isActive'] = val;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatCard(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
