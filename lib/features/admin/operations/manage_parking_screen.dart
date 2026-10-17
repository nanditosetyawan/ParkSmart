import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageParkingScreen extends StatefulWidget {
  const ManageParkingScreen({super.key});

  @override
  State<ManageParkingScreen> createState() => _ManageParkingScreenState();
}

class _ManageParkingScreenState extends State<ManageParkingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for locations
  final List<Map<String, dynamic>> _locations = [
    {
      'id': 'loc_1',
      'name': 'Central Park Mall',
      'city': 'Jakarta Barat',
      'address': 'Jl. Letjen S. Parman No.28, Grogol petamburan',
      'latitude': -6.1754,
      'longitude': 106.7933,
      'totalSlots': 300,
      'occupiedSlots': 240,
      'status': 'Aktif',
      'floors': ['B1', 'B2', 'B3'],
      'operatingHours': '06:00 - 23:00',
      'baseRate': 5000,
      'imageUrl': null,
    },
    {
      'id': 'loc_2',
      'name': 'Malioboro Mall',
      'city': 'Yogyakarta',
      'address': 'Jl. Malioboro No.52-58, Sosrowijayan',
      'latitude': -7.7929,
      'longitude': 110.3656,
      'totalSlots': 200,
      'occupiedSlots': 102,
      'status': 'Aktif',
      'floors': ['LG', 'UG', '1', '2'],
      'operatingHours': '07:00 - 22:00',
      'baseRate': 4000,
      'imageUrl': null,
    },
    {
      'id': 'loc_3',
      'name': 'Grand Indonesia',
      'city': 'Jakarta Pusat',
      'address': 'Jl. M.H. Thamrin No.1, Menteng',
      'latitude': -6.1931,
      'longitude': 106.8229,
      'totalSlots': 450,
      'occupiedSlots': 415,
      'status': 'Padat',
      'floors': ['B1', 'B2', 'B3', 'B4'],
      'operatingHours': '24 Jam',
      'baseRate': 8000,
      'imageUrl': null,
    },
  ];

  // Mock data for slots (per location)
  final Map<String, List<Map<String, dynamic>>> _slotsByLocation = {
    'loc_1': List.generate(300, (i) => {
      'id': 'slot_${i + 1}',
      'code': 'B${(i ~/ 100) + 1}-${(i % 100 + 1).toString().padLeft(3, '0')}',
      'floor': ['B1', 'B2', 'B3'][i ~/ 100],
      'type': i % 10 == 0 ? 'EV' : (i % 15 == 0 ? 'Disabilitas' : (i % 20 == 0 ? 'Motor' : 'Reguler')),
      'status': i < 240 ? 'Terisi' : 'Tersedia',
      'vehiclePlate': i < 240 ? 'B ${1000 + i} ABC' : null,
      'pricingOverride': null,
    }),
    'loc_2': List.generate(200, (i) => {
      'id': 'slot_${i + 1}',
      'code': '${['LG', 'UG', '1', '2'][i ~/ 50]}-${(i % 50 + 1).toString().padLeft(3, '0')}',
      'floor': ['LG', 'UG', '1', '2'][i ~/ 50],
      'type': i % 8 == 0 ? 'EV' : (i % 12 == 0 ? 'Disabilitas' : (i % 15 == 0 ? 'Motor' : 'Reguler')),
      'status': i < 102 ? 'Terisi' : 'Tersedia',
      'vehiclePlate': i < 102 ? 'AB ${2000 + i} CD' : null,
      'pricingOverride': null,
    }),
    'loc_3': List.generate(450, (i) {
      final floorIdx = (i ~/ 113).clamp(0, 3);
      final floorName = ['B1', 'B2', 'B3', 'B4'][floorIdx];
      final slotNum = (i % 113 + 1).toString().padLeft(3, '0');
      return {
        'id': 'slot_${i + 1}',
        'code': '$floorName-$slotNum',
        'floor': floorName,
        'type': i % 12 == 0 ? 'EV' : (i % 18 == 0 ? 'Disabilitas' : (i % 25 == 0 ? 'Motor' : 'Reguler')),
        'status': i < 415 ? 'Terisi' : 'Tersedia',
        'vehiclePlate': i < 415 ? 'B ${3000 + i} XYZ' : null,
        'pricingOverride': null,
      };
    }),
  };

  String _selectedLocationId = 'loc_1';
  String _searchQuery = '';
  String _selectedSlotType = 'Semua';
  String _selectedSlotStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredLocations {
    return _locations.where((loc) {
      final matchesSearch = loc['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc['city'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredSlots {
    final slots = _slotsByLocation[_selectedLocationId] ?? [];
    return slots.where((slot) {
      final matchesType = _selectedSlotType == 'Semua' || slot['type'] == _selectedSlotType;
      final matchesStatus = _selectedSlotStatus == 'Semua' || slot['status'] == _selectedSlotStatus;
      return matchesType && matchesStatus;
    }).toList();
  }

  Map<String, int> get _slotSummary {
    final slots = _slotsByLocation[_selectedLocationId] ?? [];
    return {
      'total': slots.length,
      'available': slots.where((s) => s['status'] == 'Tersedia').length,
      'occupied': slots.where((s) => s['status'] == 'Terisi').length,
      'ev': slots.where((s) => s['type'] == 'EV').length,
      'disabled': slots.where((s) => s['type'] == 'Disabilitas').length,
      'motorcycle': slots.where((s) => s['type'] == 'Motor').length,
      'regular': slots.where((s) => s['type'] == 'Reguler').length,
    };
  }

  Widget _buildSectionTitle(String title, {String? subtitle, VoidCallback? onAction, String? actionLabel}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: Text(
                actionLabel,
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114177),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }

  // ============ TAB 1: LOKASI ============
  Widget _buildLocationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Kelola Lokasi Parkir', onAction: _showAddLocationDialog, actionLabel: 'Tambah'),
          _buildCard(
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari lokasi...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF76777B), size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 16),
                // Location list
                ..._filteredLocations.map((loc) => _buildLocationRow(loc)),
                if (_filteredLocations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text('Tidak ada lokasi ditemukan', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(Map<String, dynamic> loc) {
    final occupancy = loc['occupiedSlots'] / loc['totalSlots'];
    final isFull = occupancy >= 0.9;
    final statusColor = loc['status'] == 'Padat' ? const Color(0xFFD94B4B) : (loc['status'] == 'Aktif' ? const Color(0xFF17A18A) : const Color(0xFF76777B));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF114177).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_parking, color: Color(0xFF114177), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)), overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(loc['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(loc['address'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.layers, size: 14, color: const Color(0xFF76777B)),
                    const SizedBox(width: 4),
                    Text('${loc['floors'].length} Lantai • ${loc['operatingHours']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 14, color: const Color(0xFF76777B)),
                    const SizedBox(width: 4),
                    Text('Rp ${_formatNumber(loc['baseRate'])}/jam', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
                  ],
                ),
                const SizedBox(height: 8),
                // Occupancy bar
                Stack(
                  children: [
                    Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(3))),
                    FractionallySizedBox(
                      widthFactor: occupancy.clamp(0.0, 1.0),
                      child: Container(height: 6, decoration: BoxDecoration(color: isFull ? const Color(0xFFD94B4B) : const Color(0xFF17A18A), borderRadius: BorderRadius.circular(3))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${loc['occupiedSlots']} / ${loc['totalSlots']} terisi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    Text('${(occupancy * 100).toStringAsFixed(0)}%', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: isFull ? const Color(0xFFD94B4B) : const Color(0xFF17A18A))),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF76777B)),
            onSelected: (value) => _handleLocationAction(value, loc),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'slots', child: Row(children: [Icon(Icons.grid_view, size: 18), SizedBox(width: 8), Text('Kelola Slot')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Color(0xFFD94B4B)), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Color(0xFFD94B4B)))])),
            ],
          ),
        ],
      ),
    );
  }

  void _handleLocationAction(String action, Map<String, dynamic> loc) {
    switch (action) {
      case 'edit':
        _showEditLocationDialog(loc);
        break;
      case 'slots':
        setState(() {
          _selectedLocationId = loc['id'];
          _tabController.animateTo(1);
        });
        break;
      case 'delete':
        _confirmDeleteLocation(loc);
        break;
    }
  }

  void _showAddLocationDialog() {
    _showLocationDialog();
  }

  void _showEditLocationDialog(Map<String, dynamic> loc) {
    _showLocationDialog(loc: loc);
  }

  void _showLocationDialog({Map<String, dynamic>? loc}) {
    final isEdit = loc != null;
    final nameCtrl = TextEditingController(text: loc?['name'] ?? '');
    final cityCtrl = TextEditingController(text: loc?['city'] ?? '');
    final addressCtrl = TextEditingController(text: loc?['address'] ?? '');
    final slotsCtrl = TextEditingController(text: loc?['totalSlots']?.toString() ?? '100');
    final baseRateCtrl = TextEditingController(text: loc?['baseRate']?.toString() ?? '5000');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Edit Lokasi Parkir' : 'Tambah Lokasi Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 17)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Foto Lokasi
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
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
                          Text('Unggah foto tampak gerbang parkir', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
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
              // 2. Nama Lokasi
              _buildDialogField('Nama Gedung / Lokasi', nameCtrl, Icons.business),
              // 3. Kota & Alamat
              _buildDialogField('Kota (cth: Jakarta Barat)', cityCtrl, Icons.location_city),
              _buildDialogField('Alamat Lengkap', addressCtrl, Icons.place, maxLines: 2),
              // 4. Jumlah Slot
              _buildDialogField('Jumlah Slot Parkir', slotsCtrl, Icons.local_parking, keyboardType: TextInputType.number),
              // 5. Tarif Parkir
              _buildDialogField('Tarif Parkir (Rp/Jam)', baseRateCtrl, Icons.payments_outlined, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && slotsCtrl.text.isNotEmpty) {
                setState(() {
                  if (isEdit) {
                    loc['name'] = nameCtrl.text;
                    if (cityCtrl.text.isNotEmpty) loc['city'] = cityCtrl.text;
                    if (addressCtrl.text.isNotEmpty) loc['address'] = addressCtrl.text;
                    loc['totalSlots'] = int.tryParse(slotsCtrl.text) ?? loc['totalSlots'];
                    loc['baseRate'] = int.tryParse(baseRateCtrl.text) ?? loc['baseRate'];
                  } else {
                    _locations.insert(0, {
                      'id': 'loc_${_locations.length + 1}',
                      'name': nameCtrl.text,
                      'city': cityCtrl.text.isEmpty ? 'Jakarta' : cityCtrl.text,
                      'address': addressCtrl.text.isEmpty ? 'Jl. Baru' : addressCtrl.text,
                      'totalSlots': int.tryParse(slotsCtrl.text) ?? 100,
                      'occupiedSlots': 0,
                      'baseRate': int.tryParse(baseRateCtrl.text) ?? 5000,
                      'operatingHours': '24 Jam',
                      'floors': ['Lantai 1'],
                      'status': 'Aktif',
                    });
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Lokasi berhasil diperbarui' : 'Lokasi berhasil ditambahkan'), backgroundColor: const Color(0xFF17A18A)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(isEdit ? 'Simpan' : 'Tambah', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLocation(Map<String, dynamic> loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Lokasi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text('Hapus "${loc['name']}"? Semua slot & data terkait akan terhapus.', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc['name']} dihapus'), backgroundColor: const Color(0xFFD94B4B)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94B4B)),
            child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============ TAB 2: SLOT ============
  Widget _buildSlotsTab() {
    final loc = _locations.firstWhere(
      (l) => l['id'] == _selectedLocationId,
      orElse: () => _locations.first,
    );
    final summary = _slotSummary;
    final slots = _filteredSlots;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location selector + summary
          _buildCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 400;
                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kelola Slot Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                              Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedLocationId,
                            isDense: true,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: 'Pilih Lokasi', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: _locations.map<DropdownMenuItem<String>>((l) => DropdownMenuItem<String>(value: l['id'] as String, child: Text(l['name'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                            onChanged: (v) => setState(() => _selectedLocationId = v ?? _locations.first['id']),
                          ),
                        ],
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kelola Slot Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                            Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                          ],
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLocationId,
                          isDense: true,
                          decoration: InputDecoration(labelText: 'Pilih Lokasi', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: _locations.map<DropdownMenuItem<String>>((l) => DropdownMenuItem<String>(value: l['id'] as String, child: Text(l['name'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                          onChanged: (v) => setState(() => _selectedLocationId = v ?? _locations.first['id']),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Summary cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 500;
                    if (isNarrow) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              _buildSummaryCard('Total', summary['total']!, Icons.grid_3x3, const Color(0xFF45474A)),
                              _buildSummaryCard('Tersedia', summary['available']!, Icons.check_circle, const Color(0xFF17A18A)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildSummaryCard('Terisi', summary['occupied']!, Icons.directions_car, const Color(0xFFD94B4B)),
                              _buildSummaryCard('EV', summary['ev']!, Icons.ev_station, const Color(0xFFE07A5F)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildSummaryCard('Disabilitas', summary['disabled']!, Icons.accessible, const Color(0xFF9B59B6)),
                              _buildSummaryCard('Motor', summary['motorcycle']!, Icons.two_wheeler, const Color(0xFF114177)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildSummaryCard('Reguler', summary['regular']!, Icons.square, const Color(0xFF76777B)),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            _buildSummaryCard('Total', summary['total']!, Icons.grid_3x3, const Color(0xFF45474A)),
                            _buildSummaryCard('Tersedia', summary['available']!, Icons.check_circle, const Color(0xFF17A18A)),
                            _buildSummaryCard('Terisi', summary['occupied']!, Icons.directions_car, const Color(0xFFD94B4B)),
                            _buildSummaryCard('EV', summary['ev']!, Icons.ev_station, const Color(0xFFE07A5F)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSummaryCard('Disabilitas', summary['disabled']!, Icons.accessible, const Color(0xFF9B59B6)),
                            _buildSummaryCard('Motor', summary['motorcycle']!, Icons.two_wheeler, const Color(0xFF114177)),
                            _buildSummaryCard('Reguler', summary['regular']!, Icons.square, const Color(0xFF76777B)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Filters
          _buildCard(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 450;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSlotType,
                        isDense: true,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: 'Tipe Slot', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: ['Semua', 'Reguler', 'EV', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _selectedSlotType = v ?? 'Semua'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSlotStatus,
                        isDense: true,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: 'Status', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: ['Semua', 'Tersedia', 'Terisi', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _selectedSlotStatus = v ?? 'Semua'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _showAddSlotDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Tambah Slot', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSlotType,
                        isDense: true,
                        decoration: InputDecoration(labelText: 'Tipe Slot', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: ['Semua', 'Reguler', 'EV', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _selectedSlotType = v ?? 'Semua'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSlotStatus,
                        isDense: true,
                        decoration: InputDecoration(labelText: 'Status', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: ['Semua', 'Tersedia', 'Terisi', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _selectedSlotStatus = v ?? 'Semua'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showAddSlotDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('Tambah Slot', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                );
              },
            ),
          ),

          // Slot Grid
          _buildSectionTitle('Daftar Slot', subtitle: '${slots.length} slot ditampilkan'),
          _buildCard(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal cross axis count based on width
                final crossAxisCount = (constraints.maxWidth / 140).floor().clamp(2, 6);
                // Calculate childAspectRatio more carefully to avoid overflow
                final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 10) / crossAxisCount;
                final itemHeight = 150.0;
                final childAspectRatio = itemWidth / itemHeight;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio.clamp(0.8, 1.4),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: slots.length > 50 ? 50 : slots.length, // Limit for performance
                  itemBuilder: (_, i) => _buildSlotCard(slots[i]),
                );
              },
            ),
          ),
          if (slots.length > 50)
            _buildCard(
              child: Center(
                child: Text('Menampilkan 50 dari ${slots.length} slot. Gunakan filter untuk menyaring.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    final isOccupied = slot['status'] == 'Terisi';
    final typeColors = {
      'Reguler': const Color(0xFF45474A),
      'EV': const Color(0xFFE07A5F),
      'Disabilitas': const Color(0xFF9B59B6),
      'Motor': const Color(0xFF114177),
    };
    final typeColor = typeColors[slot['type']] ?? const Color(0xFF45474A);

    return GestureDetector(
      onTap: () => _showEditSlotDialog(slot),
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? const Color(0xFFFDE8E4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isOccupied ? const Color(0xFFD94B4B).withValues(alpha: 0.3) : const Color(0xFFE4DFD5)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: FittedBox(
                  child: Text(slot['type'], style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: typeColor)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: FittedBox(
                child: Text(slot['code'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: FittedBox(
                child: Text(slot['floor'], style: GoogleFonts.plusJakartaSans(fontSize: 8, color: const Color(0xFF76777B))),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isOccupied ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: FittedBox(
                child: Text(isOccupied ? 'Terisi' : 'Tersedia', style: GoogleFonts.plusJakartaSans(fontSize: 7, fontWeight: FontWeight.w600, color: isOccupied ? const Color(0xFFD94B4B) : const Color(0xFF17A18A))),
              ),
            ),
            if (isOccupied && slot['vehiclePlate'] != null) ...[
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  child: Text(slot['vehiclePlate'], style: GoogleFonts.jetBrainsMono(fontSize: 7, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddSlotDialog() {
    _showSlotDialog();
  }

  void _showEditSlotDialog(Map<String, dynamic> slot) {
    _showSlotDialog(slot: slot);
  }

  void _showSlotDialog({Map<String, dynamic>? slot}) {
    final isEdit = slot != null;
    final codeCtrl = TextEditingController(text: slot?['code'] ?? '');
    final floorCtrl = TextEditingController(text: slot?['floor'] ?? '');
    String type = slot?['type'] ?? 'Reguler';
    String status = slot?['status'] ?? 'Tersedia';
    final pricingCtrl = TextEditingController(text: slot?['pricingOverride']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Slot' : 'Tambah Slot Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Kode Slot', codeCtrl, Icons.label),
              _buildDialogField('Lantai', floorCtrl, Icons.layers),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: 'Tipe Slot', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                isExpanded: true,
                items: ['Reguler', 'EV', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => type = v ?? 'Reguler',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                isExpanded: true,
                items: ['Tersedia', 'Terisi', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => status = v ?? 'Tersedia',
              ),
              const SizedBox(height: 12),
              _buildDialogField('Override Tarif/Jam (opsional)', pricingCtrl, Icons.attach_money, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Slot diperbarui' : 'Slot ditambahkan'), backgroundColor: const Color(0xFF17A18A)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177)),
            child: Text(isEdit ? 'Simpan' : 'Tambah', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============ HELPERS ============
  Widget _buildDialogField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
            prefixIcon: Icon(icon, color: const Color(0xFF114177), size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kelola Parkir Terpadu', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Lokasi • Denah Slot', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data parkir diekspor'), backgroundColor: Color(0xFF17A18A))),
            icon: const Icon(Icons.download, size: 18, color: Color(0xFF17A18A)),
            label: Text('Ekspor', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Color(0xFF17A18A))),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF114177),
          unselectedLabelColor: const Color(0xFF76777B),
          indicatorColor: const Color(0xFF114177),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Lokasi'),
            Tab(text: 'Denah Slot'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocationsTab(),
          _buildSlotsTab(),
        ],
      ),
    ));
  }
}