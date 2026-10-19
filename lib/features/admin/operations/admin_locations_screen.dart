import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_slot_management_screen.dart';
import 'backend/admin_locations_backend.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'Semua';

  final List<String> _cities = ['Semua', 'Jakarta Barat', 'Jakarta Pusat', 'Jakarta Selatan', 'Yogyakarta', 'Surabaya', 'Bandung'];

  List<Map<String, dynamic>> get _locations => AdminLocationsBackend.instance.locations;

  @override
  void initState() {
    super.initState();
    AdminLocationsBackend.instance.fetchLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredLocations {
    return _locations.where((loc) {
      final matchesSearch = loc['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          loc['address'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          loc['city'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCity = _selectedCity == 'Semua' || loc['city'] == _selectedCity;
      return matchesSearch && matchesCity;
    }).toList();
  }

  void _showAddLocationDialog({Map<String, dynamic>? loc}) {
    final isEdit = loc != null;
    final nameCtrl = TextEditingController(text: loc?['name'] ?? '');
    final addressCtrl = TextEditingController(text: loc?['address'] ?? '');
    final capacityCtrl = TextEditingController(text: loc?['capacity']?.toString() ?? '');
    final rateCtrl = TextEditingController(text: loc?['hourlyRate']?.toString() ?? '5000');
    String cityVal = loc?['city'] ?? 'Jakarta Barat';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEdit ? 'Edit Lokasi Parkir' : 'Tambah Lokasi Baru', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: Color(0xFF76777B))),
                ],
              ),
              const Divider(color: Color(0xFFF3F4F6)),
              const SizedBox(height: 8),

              // 1. Upload Foto Lokasi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF114177).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF114177), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Foto Lokasi / Gedung', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          Text('Unggah foto tampak depan atau gerbang parkir', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Foto gedung berhasil dipilih!'), backgroundColor: Color(0xFF114177), duration: Duration(seconds: 1)),
                        );
                      },
                      child: Text('Pilih Foto', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Nama Lokasi
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Gedung / Lokasi',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Kota & Alamat
              DropdownButtonFormField<String>(
                initialValue: cityVal,
                decoration: InputDecoration(
                  labelText: 'Kota Operasional',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _cities.where((c) => c != 'Semua').map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                onChanged: (v) {
                  if (v != null) cityVal = v;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Jumlah Slot & 5. Tarif
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah Slot Parkir',
                        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: rateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tarif Parkir (Rp/Jam)',
                        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty && capacityCtrl.text.isNotEmpty) {
                      final nav = Navigator.of(context);
                      final sm = ScaffoldMessenger.of(context);
                      if (isEdit) {
                        final updated = Map<String, dynamic>.from(loc);
                        updated['name'] = nameCtrl.text;
                        updated['city'] = cityVal;
                        updated['address'] = addressCtrl.text.isEmpty ? loc['address'] : addressCtrl.text;
                        updated['capacity'] = int.tryParse(capacityCtrl.text) ?? loc['capacity'];
                        updated['hourlyRate'] = int.tryParse(rateCtrl.text) ?? loc['hourlyRate'];
                        await AdminLocationsBackend.instance.updateLocation(loc['id'].toString(), updated);
                      } else {
                        final newLoc = {
                          'id': 'LOC-00${_locations.length + 1}',
                          'name': nameCtrl.text,
                          'city': cityVal,
                          'address': addressCtrl.text.isEmpty ? 'Alamat belum diatur' : addressCtrl.text,
                          'floors': 'Lantai Utama',
                          'capacity': int.tryParse(capacityCtrl.text) ?? 100,
                          'occupied': 0,
                          'carSlots': ((int.tryParse(capacityCtrl.text) ?? 100) * 0.7).round(),
                          'motorSlots': ((int.tryParse(capacityCtrl.text) ?? 100) * 0.2).round(),
                          'evSlots': ((int.tryParse(capacityCtrl.text) ?? 100) * 0.1).round(),
                          'hourlyRate': int.tryParse(rateCtrl.text) ?? 5000,
                          'status': 'Aktif Normal',
                          'statusColor': const Color(0xFF17A18A),
                        };
                        await AdminLocationsBackend.instance.addLocation(newLoc);
                      }
                      if (!mounted) return;
                      nav.pop();
                      sm.showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Lokasi ${nameCtrl.text} berhasil diperbarui!' : 'Lokasi ${nameCtrl.text} berhasil ditambahkan!'),
                          backgroundColor: const Color(0xFF17A18A),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF114177),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEdit ? 'Perbarui Lokasi' : 'Simpan Lokasi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminLocationsBackend.instance,
      builder: (context, _) {
        final totalCap = _locations.fold<int>(0, (sum, l) => sum + (l['capacity'] as int));
        final totalOcc = _locations.fold<int>(0, (sum, l) => sum + (l['occupied'] as int));
        final occPercent = (totalOcc / (totalCap == 0 ? 1 : totalCap) * 100).toStringAsFixed(1);

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
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kelola Lokasi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Manajemen Fasilitas & Gedung Mitra', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined, color: Color(0xFF114177)),
            onPressed: _showAddLocationDialog,
            tooltip: 'Tambah Lokasi',
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
                    _buildStatCard('Total Fasilitas', '${_locations.length}', const Color(0xFF114177), const Color(0xFFE3EEFF)),
                    const SizedBox(width: 10),
                    _buildStatCard('Total Slot', '$totalCap', const Color(0xFF45474A), const Color(0xFFF3F4F6)),
                    const SizedBox(width: 10),
                    _buildStatCard('Okupansi Rata2', '$occPercent%', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                  ],
                ),
                const SizedBox(height: 14),

                // Search Box (Google Style)
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                          decoration: InputDecoration(
                            hintText: 'Cari gedung atau alamat...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // City Chips
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _cities.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final c = _cities[index];
                final isSelected = _selectedCity == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCity = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF114177) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        c,
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

          // Locations List
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_outlined, size: 48, color: Color(0xFF76777B)),
                        const SizedBox(height: 12),
                        Text('Tidak ada lokasi yang cocok', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredLocations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final loc = _filteredLocations[index];
                      return _buildLocationCard(loc);
                    },
                  ),
          ),
        ],
      ),
    ),
  );
},
);
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

  Widget _buildLocationCard(Map<String, dynamic> loc) {
    final statusColor = loc['statusColor'] as Color;
    final int cap = loc['capacity'] as int;
    final int occ = loc['occupied'] as int;
    final double pct = cap > 0 ? (occ / cap) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_parking, color: Color(0xFF114177), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(loc['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${loc['city']} · ${loc['floors']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                          const SizedBox(height: 4),
                          Text(loc['address'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Occupancy progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Okupansi Saat Ini', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    Text('$occ / $cap Terisi (${(pct * 100).toStringAsFixed(0)}%)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct > 0.9 ? const Color(0xFFD94B4B) : pct > 0.7 ? const Color(0xFFE07A5F) : const Color(0xFF17A18A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Slot Categories pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSlotPill(Icons.directions_car, 'Mobil', '${loc['carSlots']}'),
                _buildSlotPill(Icons.two_wheeler, 'Motor', '${loc['motorSlots']}'),
                _buildSlotPill(Icons.electric_car, 'EV Charging', '${loc['evSlots']}'),
                _buildSlotPill(Icons.payments_outlined, 'Tarif', 'Rp ${loc['hourlyRate']}/j'),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddLocationDialog(loc: loc),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF114177)),
                    label: Text('Edit Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
                    icon: const Icon(Icons.grid_view, size: 16, color: Colors.white),
                    label: Text('Kelola Denah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF114177),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotPill(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFF76777B)),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
      ],
    );
  }
}
