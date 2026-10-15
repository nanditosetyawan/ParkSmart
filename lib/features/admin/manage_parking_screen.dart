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
    'loc_3': List.generate(450, (i) => {
      'id': 'slot_${i + 1}',
      'code': 'B${(i ~/ 112) + 1}-${(i % 112 + 1).toString().padLeft(3, '0')}',
      'floor': ['B1', 'B2', 'B3', 'B4'][i ~/ 112],
      'type': i % 12 == 0 ? 'EV' : (i % 18 == 0 ? 'Disabilitas' : (i % 25 == 0 ? 'Motor' : 'Reguler')),
      'status': i < 415 ? 'Terisi' : 'Tersedia',
      'vehiclePlate': i < 415 ? 'B ${3000 + i} XYZ' : null,
      'pricingOverride': null,
    }),
  };

  // Mock pricing rules
  final List<Map<String, dynamic>> _pricingRules = [
    {'id': 'pr_1', 'name': 'Tarif Standar Mall', 'location': 'Semua Lokasi', 'vehicleType': 'Mobil', 'baseHourly': 5000, 'timeRules': [], 'isActive': true},
    {'id': 'pr_2', 'name': 'Tarif Motor', 'location': 'Semua Lokasi', 'vehicleType': 'Motor', 'baseHourly': 3000, 'timeRules': [], 'isActive': true},
    {'id': 'pr_3', 'name': 'Tarif EV Charging', 'location': 'Semua Lokasi', 'vehicleType': 'EV', 'baseHourly': 7000, 'timeRules': [], 'isActive': true},
    {'id': 'pr_4', 'name': 'Malam Hari (22:00-06:00)', 'location': 'Central Park Mall', 'vehicleType': 'Mobil', 'baseHourly': 3000, 'timeRules': [{'start': '22:00', 'end': '06:00', 'multiplier': 0.6}], 'isActive': true},
    {'id': 'pr_5', 'name': 'Weekend Peak', 'location': 'Grand Indonesia', 'vehicleType': 'Mobil', 'baseHourly': 10000, 'timeRules': [{'days': ['Sat', 'Sun'], 'start': '10:00', 'end': '20:00', 'multiplier': 1.5}], 'isActive': true},
    {'id': 'pr_6', 'name': 'Hari Libur Nasional', 'location': 'Semua Lokasi', 'vehicleType': 'Semua', 'baseHourly': 6000, 'timeRules': [{'isHoliday': true, 'multiplier': 1.3}], 'isActive': true},
  ];

  String _selectedLocationId = 'loc_1';
  String _searchQuery = '';
  String _selectedSlotType = 'Semua';
  String _selectedSlotStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              if (subtitle != null) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          if (onAction != null && actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 16),
              label: Text(actionLabel, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF114177)),
            ),
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
        border: Border.all(color: const Color(0xFFE4DFD5)),
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
          _buildSectionTitle('Kelola Lokasi Parkir', subtitle: 'Tambah, edit, hapus lokasi parkir & lihat ringkasan kapasitas', onAction: _showAddLocationDialog, actionLabel: 'Tambah Lokasi'),
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
                ..._filteredLocations.map((loc) => _buildLocationRow(loc)).toList(),
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
        border: Border.all(color: const Color(0xFFE4DFD5)),
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
                    Expanded(child: Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)))),
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
                    Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(3))),
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
              const PopupMenuItem(value: 'pricing', child: Row(children: [Icon(Icons.price_change, size: 18), SizedBox(width: 8), Text('Atur Tarif')])),
              const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.content_copy, size: 18), SizedBox(width: 8), Text('Duplikat')])),
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
      case 'pricing':
        // Navigate to pricing tab filtered for this location
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duplikat ${loc['name']}...')));
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
    final baseRateCtrl = TextEditingController(text: loc?['baseRate'].toString() ?? '5000');
    final floorsCtrl = TextEditingController(text: (loc?['floors'] as List?)?.join(', ') ?? 'B1, B2, B3');
    final hoursCtrl = TextEditingController(text: loc?['operatingHours'] ?? '06:00 - 23:00');
    String status = loc?['status'] ?? 'Aktif';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Lokasi' : 'Tambah Lokasi Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Nama Lokasi', nameCtrl, Icons.local_parking),
              _buildDialogField('Kota', cityCtrl, Icons.location_city),
              _buildDialogField('Alamat Lengkap', addressCtrl, Icons.map, maxLines: 2),
              _buildDialogField('Lantai (pisah koma)', floorsCtrl, Icons.layers),
              _buildDialogField('Jam Operasional', hoursCtrl, Icons.access_time),
              _buildDialogField('Tarif Dasar/Jam (Rp)', baseRateCtrl, Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Aktif', 'Padat', 'Maintenance', 'Nonaktif'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => status = v ?? 'Aktif',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && cityCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Lokasi diperbarui' : 'Lokasi ditambahkan'), backgroundColor: const Color(0xFF17A18A)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177)),
            child: Text(isEdit ? 'Simpan' : 'Tambah', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
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
    final loc = _locations.firstWhere((l) => l['id'] == _selectedLocationId);
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
                Row(
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
                ),
                const SizedBox(height: 20),
                // Summary cards
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
            ),
          ),

          // Filters
          _buildCard(
            child: Row(
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
            ),
          ),

          // Slot Grid
          _buildSectionTitle('Daftar Slot', subtitle: '${slots.length} slot ditampilkan'),
          _buildCard(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: slots.length > 50 ? 50 : slots.length, // Limit for performance
              itemBuilder: (_, i) => _buildSlotCard(slots[i]),
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
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(slot['type'], style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: typeColor)),
            ),
            const SizedBox(height: 6),
            Text(slot['code'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 2),
            Text(slot['floor'], style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))),
            const SizedBox(height: 6),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOccupied ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 2),
            Text(isOccupied ? 'Terisi' : 'Tersedia', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w600, color: isOccupied ? const Color(0xFFD94B4B) : const Color(0xFF17A18A))),
            if (isOccupied && slot['vehiclePlate'] != null) ...[
              const SizedBox(height: 4),
              Text(slot['vehiclePlate'], style: GoogleFonts.jetBrainsMono(fontSize: 8, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
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
                items: ['Reguler', 'EV', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => type = v ?? 'Reguler',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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

  // ============ TAB 3: PRICING ============
  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Kelola Aturan Tarif', subtitle: 'Tarif dasar, time-based rules, holiday rates, vehicle-type multipliers', onAction: _showAddPricingDialog, actionLabel: 'Tambah Aturan'),
          _buildCard(
            child: Column(
              children: [
                // Filter by location
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Filter Lokasi', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: [
                    const DropdownMenuItem<String>(value: 'all', child: Text('Semua Lokasi')),
                    ..._locations.map((l) => DropdownMenuItem<String>(value: l['id'] as String, child: Text(l['name'] as String))),
                  ],
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
                // Pricing rules list
                ..._pricingRules.map((rule) => _buildPricingRuleRow(rule)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingRuleRow(Map<String, dynamic> rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rule['isActive'] ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rule['isActive'] ? const Color(0xFFE4DFD5) : const Color(0xFFE4DFD5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: rule['isActive'] ? const Color(0xFF17A18A).withValues(alpha: 0.1) : const Color(0xFF76777B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(rule['isActive'] ? Icons.attach_money : Icons.attach_money_outlined, color: rule['isActive'] ? const Color(0xFF17A18A) : const Color(0xFF76777B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(rule['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: rule['isActive'] ? const Color(0xFF1A1A18) : const Color(0xFF76777B)))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: rule['isActive'] ? const Color(0xFFD1F2EB) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
                      child: Text(rule['isActive'] ? 'Aktif' : 'Nonaktif', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: rule['isActive'] ? const Color(0xFF17A18A) : const Color(0xFF76777B))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${rule['location']} • ${rule['vehicleType']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text('Rp ${_formatNumber(rule['baseHourly'])}/jam', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                    if (rule['timeRules'].isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE07A5F).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('Time-based', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFE07A5F))),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF76777B)),
            onSelected: (value) => _handlePricingAction(value, rule),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
              PopupMenuItem(value: rule['isActive'] ? 'deactivate' : 'activate', child: Row(children: [Icon(rule['isActive'] ? Icons.pause : Icons.play_arrow, size: 18), SizedBox(width: 8), Text(rule['isActive'] ? 'Nonaktifkan' : 'Aktifkan')])),
              const PopupMenuItem(value: 'duplicate', child: Row(children: [Icon(Icons.content_copy, size: 18), SizedBox(width: 8), Text('Duplikat')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Color(0xFFD94B4B)), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Color(0xFFD94B4B)))])),
            ],
          ),
        ],
      ),
    );
  }

  void _handlePricingAction(String action, Map<String, dynamic> rule) {
    switch (action) {
      case 'edit':
        _showPricingDialog(rule: rule);
        break;
      case 'activate':
      case 'deactivate':
        setState(() => rule['isActive'] = !rule['isActive']);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aturan ${rule['isActive'] ? 'diaktifkan' : 'dinonaktifkan'}'), backgroundColor: rule['isActive'] ? const Color(0xFF17A18A) : const Color(0xFFE07A5F)));
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aturan diduplikat...')));
        break;
      case 'delete':
        _confirmDeletePricing(rule);
        break;
    }
  }

  void _showAddPricingDialog() {
    _showPricingDialog();
  }

  void _showPricingDialog({Map<String, dynamic>? rule}) {
    final isEdit = rule != null;
    final nameCtrl = TextEditingController(text: rule?['name'] ?? '');
    final baseHourlyCtrl = TextEditingController(text: rule?['baseHourly'].toString() ?? '5000');
    String location = rule?['location'] ?? 'Semua Lokasi';
    String vehicleType = rule?['vehicleType'] ?? 'Mobil';
    bool isActive = rule?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Aturan Tarif' : 'Tambah Aturan Tarif', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Nama Aturan', nameCtrl, Icons.rule),
              _buildDialogField('Tarif Dasar/Jam (Rp)', baseHourlyCtrl, Icons.attach_money, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: location,
                decoration: InputDecoration(labelText: 'Lokasi', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Semua Lokasi', ..._locations.map((l) => l['name'] as String)].map<DropdownMenuItem<String>>((l) => DropdownMenuItem<String>(value: l, child: Text(l))).toList(),
                onChanged: (v) => location = v ?? 'Semua Lokasi',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: vehicleType,
                decoration: InputDecoration(labelText: 'Tipe Kendaraan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Mobil', 'Motor', 'EV', 'Semua'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => vehicleType = v ?? 'Mobil',
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                value: isActive,
                activeThumbColor: const Color(0xFF17A18A),
                onChanged: (v) => isActive = v,
              ),
              const SizedBox(height: 8),
              Text('Time-based & Holiday rules: konfigurasi detail di halaman Pricing terpisah', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && baseHourlyCtrl.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Aturan diperbarui' : 'Aturan ditambahkan'), backgroundColor: const Color(0xFF17A18A)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177)),
            child: Text(isEdit ? 'Simpan' : 'Tambah', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePricing(Map<String, dynamic> rule) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Aturan Tarif', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text('Hapus "${rule['name']}"?', style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _pricingRules.remove(rule));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aturan dihapus'), backgroundColor: const Color(0xFFD94B4B)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94B4B)),
            child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============ HELPERS ============
  Widget _buildDialogField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kelola Parkir Terpadu', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Lokasi • Slot • Tarif', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
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
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Lokasi'),
            Tab(text: 'Slot'),
            Tab(text: 'Tarif'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocationsTab(),
          _buildSlotsTab(),
          _buildPricingTab(),
        ],
      ),
    );
  }
}