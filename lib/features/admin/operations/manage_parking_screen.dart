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
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';
  String _selectedLocationId = 'loc_1';
  int _selectedFloorIndex = 1; // Default to Lantai B2 (which has EV)

  // Master Data Lokasi Parkir (Sesuai Schema supabase.md)
  final List<Map<String, dynamic>> _locations = [
    {
      'id': 'loc_1',
      'name': 'Central Park Mall',
      'typeLabel': 'Mall / Pusat Perbelanjaan',
      'city': 'Jakarta Barat',
      'address': 'Jl. Letjen S. Parman No.28, Tanjung Duren',
      'latitude': -6.1754,
      'longitude': 106.7933,
      'totalSlots': 300,
      'occupiedSlots': 240,
      'status': 'Aktif',
      'floors': ['Lantai B1', 'Lantai B2', 'Lantai B3'],
      'operatingHours': '06:00 - 23:00',
      'baseRate': 5000,
      'evRate': 7500,
      'motorRate': 2000,
      'isEvReady': true,
      'description': 'Gedung parkir multi-lantai dengan zona khusus EV charging di Lantai B2 dan sensor terpadu.',
      'checkinRadius': 100,
    },
    {
      'id': 'loc_2',
      'name': 'Grand Indonesia',
      'typeLabel': 'Pusat Perbelanjaan & Kantor',
      'city': 'Jakarta Pusat',
      'address': 'Jl. M.H. Thamrin No.1, Menteng',
      'latitude': -6.1931,
      'longitude': 106.8229,
      'totalSlots': 450,
      'occupiedSlots': 415,
      'status': 'Padat',
      'floors': ['Lantai B1', 'Lantai B2', 'Lantai B3', 'Lantai B4'],
      'operatingHours': '24 Jam',
      'baseRate': 8000,
      'evRate': 12000,
      'motorRate': 3000,
      'isEvReady': true,
      'description': 'Area parkir East & West Mall dengan fasilitas valet dan charging station ultra fast.',
      'checkinRadius': 150,
    },
    {
      'id': 'loc_3',
      'name': 'Malioboro Mall',
      'typeLabel': 'Pusat Perbelanjaan',
      'city': 'Yogyakarta',
      'address': 'Jl. Malioboro No.52-58, Sosrowijayan',
      'latitude': -7.7929,
      'longitude': 110.3656,
      'totalSlots': 200,
      'occupiedSlots': 102,
      'status': 'Aktif',
      'floors': ['Lantai LG', 'Lantai UG', 'Lantai 1'],
      'operatingHours': '07:00 - 22:00',
      'baseRate': 4000,
      'evRate': 6000,
      'motorRate': 2000,
      'isEvReady': false,
      'description': 'Parkiran terpadu kawasan wisata Malioboro dengan akses langsung ke pedestrian.',
      'checkinRadius': 80,
    },
  ];

  // Denah Tata Letak Slot per Lantai (Sinkron dengan Denah Booking User di slot_selection_screen)
  late Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> _floorLayouts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initFloorLayouts();
  }

  void _initFloorLayouts() {
    _floorLayouts = {
      'loc_1': {
        'Lantai B1': {
          'zoneA': [
            {'code': 'A-01', 'type': 'Reguler', 'status': 'Terisi', 'plate': 'B 1928 KPL', 'price': 5000},
            {'code': 'A-02', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'A-03', 'type': 'Reguler', 'status': 'Terisi', 'plate': 'B 2234 ABC', 'price': 5000},
            {'code': 'A-04', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
          ],
          'zoneB': [
            {'code': 'B-01', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'B-02', 'type': 'Reguler', 'status': 'Terisi', 'plate': 'B 8831 ZZZ', 'price': 5000},
            {'code': 'B-03', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'B-04', 'type': 'Disabilitas', 'status': 'Tersedia', 'price': 5000},
          ],
        },
        'Lantai B2': {
          // Posisi Atas: Parkir Biasa / Mobil Reguler
          'zoneA': [
            {'code': 'A-01', 'type': 'Reguler', 'status': 'Terisi', 'plate': 'B 1234 SKP', 'price': 5000},
            {'code': 'A-02', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'A-03', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'A-04', 'type': 'Reguler', 'status': 'Terisi', 'plate': 'B 5532 PLM', 'price': 5000},
          ],
          // Posisi Bawah: Terpisah untuk Stasiun Parkir EV
          'zoneB': [
            {'code': 'B-01', 'type': 'Reguler', 'status': 'Terisi', 'plate': 'D 8888 ABC', 'price': 5000},
            {'code': 'B-02', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'B-03', 'type': 'EV', 'status': 'Tersedia', 'price': 7500, 'charger': 'AC 22 kW'},
            {'code': 'B-04', 'type': 'EV', 'status': 'Terisi', 'plate': 'B 1111 ION', 'price': 7500, 'charger': 'DC Fast 50 kW'},
          ],
        },
        'Lantai B3': {
          'zoneA': [
            {'code': 'A-01', 'type': 'Motor', 'status': 'Terisi', 'plate': 'B 4412 XYZ', 'price': 2000},
            {'code': 'A-02', 'type': 'Motor', 'status': 'Tersedia', 'price': 2000},
            {'code': 'A-03', 'type': 'Motor', 'status': 'Terisi', 'plate': 'B 6678 QWE', 'price': 2000},
            {'code': 'A-04', 'type': 'Motor', 'status': 'Tersedia', 'price': 2000},
          ],
          'zoneB': [
            {'code': 'B-01', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'B-02', 'type': 'Reguler', 'status': 'Tersedia', 'price': 5000},
            {'code': 'B-03', 'type': 'VIP', 'status': 'Terisi', 'plate': 'RI 1', 'price': 15000},
            {'code': 'B-04', 'type': 'VIP', 'status': 'Tersedia', 'price': 15000},
          ],
        },
      },
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _activeLocation {
    return _locations.firstWhere(
      (l) => l['id'] == _selectedLocationId,
      orElse: () => _locations.first,
    );
  }

  List<Map<String, dynamic>> get _filteredLocations {
    return _locations.where((loc) {
      final matchesSearch = loc['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc['city'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc['address'].toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedStatusFilter == 'Semua') return true;
      if (_selectedStatusFilter == 'EV Ready') return loc['isEvReady'] == true;
      return loc['status'] == _selectedStatusFilter;
    }).toList();
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
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelola Parkir dan Aturan Tarif',
                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
              Text(
                'Master Lokasi, Denah Lantai & Posisi Slot EV',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF114177),
            unselectedLabelColor: const Color(0xFF76777B),
            indicatorColor: const Color(0xFF114177),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(icon: Icon(Icons.business_outlined, size: 18), text: 'Daftar Lokasi & Tarif'),
              Tab(icon: Icon(Icons.grid_view_rounded, size: 18), text: 'Denah Lantai & Desain Slot'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLocationsListTab(),
            _buildFloorPlanDesignerTab(),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 1: DAFTAR LOKASI & ATURAN TARIF ====================
  Widget _buildLocationsListTab() {
    final list = _filteredLocations;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Search Bar (Google Style)
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
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                  decoration: InputDecoration(
                    hintText: 'Cari nama gedung, kota, atau alamat...',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Tombol Tambah Lokasi Baru (Full Width mengisi kekosongan)
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _showAddLocationDialog,
            icon: const Icon(Icons.add_location_alt_rounded, size: 18, color: Colors.white),
            label: Text(
              'Tambah Lokasi',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF114177),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2. Filter Status Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Semua', 'Aktif', 'Padat', 'EV Ready'].map((filter) {
              final isSelected = _selectedStatusFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedStatusFilter = filter),
                  selectedColor: const Color(0xFF114177).withValues(alpha: 0.12),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSelected ? const Color(0xFF114177) : const Color(0xFFE5E7EB)),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF114177) : const Color(0xFF76777B),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // 3. Daftar Kartu Lokasi Parkir
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF9CA3AF)),
                const SizedBox(height: 12),
                Text('Tidak Ada Lokasi Ditemukan', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Coba gunakan kata kunci pencarian atau filter yang berbeda.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
          )
        else
          ...list.map((loc) => _buildLocationCard(loc)),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> loc) {
    final occupancy = loc['occupiedSlots'] / loc['totalSlots'];
    final isFull = occupancy >= 0.9;
    final isEvReady = loc['isEvReady'] == true;
    final statusColor = loc['status'] == 'Padat'
        ? const Color(0xFFD94B4B)
        : (loc['status'] == 'Aktif' ? const Color(0xFF17A18A) : const Color(0xFF76777B));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showQuickEditTariffAndSlotsDialog(loc),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Kartu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF114177).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_rounded, color: Color(0xFF114177), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  loc['name'],
                                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  loc['status'],
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${loc['typeLabel']} • ${loc['city']}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc['address'],
                            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF45474A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Koordinat GPS & Jam Operasional (Sesuai Supabase)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFF114177)),
                          const SizedBox(width: 4),
                          Text(
                            'GPS: ${loc['latitude']}, ${loc['longitude']}',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF374151)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 13, color: Color(0xFF76777B)),
                          const SizedBox(width: 4),
                          Text(
                            loc['operatingHours'],
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF114177)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Rincian Tarif Parkir & Tipe
                Row(
                  children: [
                    Expanded(
                      child: _buildRateBadge('Mobil', 'Rp ${_formatNumber(loc['baseRate'])}/j', Icons.directions_car, const Color(0xFF114177)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRateBadge('EV Ready', 'Rp ${_formatNumber(loc['evRate'])}/j', Icons.bolt, const Color(0xFF17A18A), isHighlight: isEvReady),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRateBadge('Motor', 'Rp ${_formatNumber(loc['motorRate'])}/j', Icons.two_wheeler, const Color(0xFF76777B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bar Kapasitas Slot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kapasitas Slot: ${loc['occupiedSlots']} / ${loc['totalSlots']} Terisi',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)),
                    ),
                    Text(
                      '${(occupancy * 100).toStringAsFixed(0)}% Okupansi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isFull ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: occupancy.clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(isFull ? const Color(0xFFD94B4B) : const Color(0xFF17A18A)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol Aksi Langsung
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQuickEditTariffAndSlotsDialog(loc),
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: Text('Ubah Tarif & Slot', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF114177),
                          side: const BorderSide(color: Color(0xFF114177)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedLocationId = loc['id'];
                            _tabController.animateTo(1);
                          });
                        },
                        icon: const Icon(Icons.grid_view_rounded, size: 16, color: Colors.white),
                        label: Text('Atur Denah Lantai', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF114177),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateBadge(String label, String rate, IconData icon, Color color, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? color.withValues(alpha: 0.1) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHighlight ? color.withValues(alpha: 0.3) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            rate,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: DENAH LANTAI & DESAINER SLOT (SINKRON USER BOOKING) ====================
  Widget _buildFloorPlanDesignerTab() {
    final loc = _activeLocation;
    final List<String> floors = List<String>.from(loc['floors'] ?? ['Lantai B1', 'Lantai B2']);
    if (_selectedFloorIndex >= floors.length) {
      _selectedFloorIndex = 0;
    }
    final activeFloorName = floors[_selectedFloorIndex];

    // Ambil denah slot dari layout map
    final locationLayout = _floorLayouts[loc['id']] ?? {};
    final floorLayout = locationLayout[activeFloorName] ?? {
      'zoneA': [
        {'code': 'A-01', 'type': 'Reguler', 'status': 'Tersedia', 'price': loc['baseRate']},
        {'code': 'A-02', 'type': 'Reguler', 'status': 'Tersedia', 'price': loc['baseRate']},
        {'code': 'A-03', 'type': 'Reguler', 'status': 'Tersedia', 'price': loc['baseRate']},
        {'code': 'A-04', 'type': 'Reguler', 'status': 'Tersedia', 'price': loc['baseRate']},
      ],
      'zoneB': [
        {'code': 'B-01', 'type': 'Reguler', 'status': 'Tersedia', 'price': loc['baseRate']},
        {'code': 'B-02', 'type': 'Reguler', 'status': 'Tersedia', 'price': loc['baseRate']},
        {'code': 'B-03', 'type': 'EV', 'status': 'Tersedia', 'price': loc['evRate'], 'charger': 'AC 22 kW'},
        {'code': 'B-04', 'type': 'EV', 'status': 'Tersedia', 'price': loc['evRate'], 'charger': 'DC Fast 50 kW'},
      ],
    };

    final zoneASlots = floorLayout['zoneA'] ?? [];
    final zoneBSlots = floorLayout['zoneB'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Dropdown Pilih Lokasi Parkir
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLocationId,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF114177), size: 24),
              items: _locations.map<DropdownMenuItem<String>>((l) {
                return DropdownMenuItem<String>(
                  value: l['id'],
                  child: Row(
                    children: [
                      const Icon(Icons.business, size: 18, color: Color(0xFF114177)),
                      const SizedBox(width: 8),
                      Text(
                        '${l['name']} (${l['city']})',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedLocationId = v;
                    _selectedFloorIndex = 0;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. Tab Pemilih Lantai (Lantai B1, B2, B3) + Tombol Tambah Lantai Baru
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tingkat Lantai Parkir:',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
            ),
            InkWell(
              onTap: () => _showAddFloorDialog(loc),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, size: 15, color: Color(0xFF114177)),
                    const SizedBox(width: 4),
                    Text(
                      'Tambah Lantai',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal Floor Pills
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: floors.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final active = i == _selectedFloorIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedFloorIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF114177) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: active ? const Color(0xFF114177) : const Color(0xFFE5E7EB)),
                    boxShadow: [
                      if (active)
                        BoxShadow(color: const Color(0xFF114177).withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.layers_outlined, size: 15, color: active ? Colors.white : const Color(0xFF76777B)),
                      const SizedBox(width: 6),
                      Text(
                        floors[i],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.bold : FontWeight.w500,
                          color: active ? Colors.white : const Color(0xFF45474A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // 3. Banner Panduan Desain Slot (Atas = Parkir Biasa, Bawah = Parkir EV)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF3FC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: const Color(0xFF114177), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.architecture_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desain Denah Tata Letak: $activeFloorName',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Posisi Atas dialokasikan untuk Parkir Mobil Biasa. Posisi Bawah disiapkan terpisah untuk Stasiun EV Charging.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF1E3A8A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. KANVAS DENAH INTERAKTIF (PERSIS SEPERTI DI SISI USER BOOKING)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ZONA A: POSISI ATAS (PARKIR BIASA / MOBIL REGULER)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('ZONA A (POSISI ATAS)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                      ),
                      const SizedBox(width: 8),
                      Text('Parkir Mobil Reguler', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showAddSlotToZoneDialog(loc['id'], activeFloorName, 'zoneA'),
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 14, color: Color(0xFF114177)),
                        Text('Tambah Slot', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Grid Slot Zona A (Posisi Atas)
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: zoneASlots.map((slot) => _buildVisualSlotItem(slot, loc['id'], activeFloorName, 'zoneA')).toList(),
              ),

              const SizedBox(height: 16),

              // JALUR SIRKULASI TENGAH (AISLE WAY)
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.east, size: 14, color: Color(0xFF76777B)),
                    const SizedBox(width: 6),
                    Text(
                      'Jalur Sirkulasi Kendaraan $activeFloorName (Satu Arah)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF45474A)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.navigation_outlined, size: 13, color: Color(0xFF76777B)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ZONA B: POSISI BAWAH (STASIUN KHUSUS EV CHARGING & CAMPURAN)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('ZONA B (POSISI BAWAH)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                      ),
                      const SizedBox(width: 8),
                      Text('Stasiun Parkir Khusus EV', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                  InkWell(
                    onTap: () => _showAddSlotToZoneDialog(loc['id'], activeFloorName, 'zoneB', defaultIsEv: true),
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 14, color: Color(0xFF17A18A)),
                        Text('Tambah Slot EV', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Grid Slot Zona B (Posisi Bawah - EV Station)
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: zoneBSlots.map((slot) => _buildVisualSlotItem(slot, loc['id'], activeFloorName, 'zoneB')).toList(),
              ),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF3F4F6), height: 1),
              const SizedBox(height: 12),

              // Keterangan Legenda
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('Reguler', const Color(0xFF114177)),
                  _buildLegendItem('EV Ready ⚡', const Color(0xFF17A18A)),
                  _buildLegendItem('Terisi 🚗', const Color(0xFFD94B4B)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tombol Simpan Konfigurasi Denah
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF17A18A),
                behavior: SnackBarBehavior.floating,
                content: Text('Konfigurasi denah $activeFloorName (${loc['name']}) berhasil disimpan dan disinkronkan ke user!'),
              ),
            );
          },
          icon: const Icon(Icons.cloud_done_rounded, size: 18, color: Colors.white),
          label: Text('Simpan & Sinkronkan Denah ke Peta User', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF114177),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
      ],
    );
  }

  // Visual Item Slot Interaktif pada Kanvas Denah
  Widget _buildVisualSlotItem(Map<String, dynamic> slot, String locId, String floorName, String zoneKey) {
    final bool isOccupied = slot['status'] == 'Terisi';
    final bool isEV = slot['type'] == 'EV';
    final Color primaryColor = isEV ? const Color(0xFF17A18A) : const Color(0xFF114177);

    return GestureDetector(
      onTap: () => _showEditSlotModal(slot, locId, floorName, zoneKey),
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied
              ? const Color(0xFFFDE8E4)
              : (isEV ? const Color(0xFFE8F7F4) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOccupied
                ? const Color(0xFFD94B4B)
                : (isEV ? const Color(0xFF17A18A) : const Color(0xFFE5E7EB)),
            width: isEV ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isEV ? '⚡ EV' : slot['type'],
                style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              slot['code'],
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
            ),
            const SizedBox(height: 2),
            if (isOccupied)
              Text(
                slot['plate'] ?? 'Terisi',
                style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.w600, color: const Color(0xFFD94B4B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                'Tersedia',
                style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A)),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS & MODAL CONFIGURATION ====================

  // 1. DIALOG TAMBAH LOKASI BARU (LENGKAP SESUAI SUPABASE.MD)
  void _showAddLocationDialog() {
    final nameCtrl = TextEditingController();
    final typeCtrl = TextEditingController(text: 'Mall / Pusat Perbelanjaan');
    final cityCtrl = TextEditingController(text: 'Jakarta');
    final addressCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: '-6.17540000');
    final longCtrl = TextEditingController(text: '106.79330000');
    final slotsCtrl = TextEditingController(text: '200');
    final baseRateCtrl = TextEditingController(text: '5000');
    final evRateCtrl = TextEditingController(text: '7500');
    final motorRateCtrl = TextEditingController(text: '2000');
    final hoursCtrl = TextEditingController(text: '06:00 - 23:00');
    final descCtrl = TextEditingController(text: 'Fasilitas parkir terpadu dengan sistem sensor pintar.');
    bool isEvReady = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.add_location_alt_rounded, color: Color(0xFF114177), size: 24),
              const SizedBox(width: 8),
              Text('Tambah Lokasi Parkir Baru', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IDENTITAS LOKASI & ALAMAT', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
                  const SizedBox(height: 6),
                  _buildInputField('Nama Gedung / Fasilitas', nameCtrl, Icons.business),
                  _buildInputField('Tipe Fasilitas (cth: Mall, Kantor, Outdoor)', typeCtrl, Icons.category_outlined),
                  _buildInputField('Kota', cityCtrl, Icons.location_city),
                  _buildInputField('Alamat Lengkap', addressCtrl, Icons.place, maxLines: 2),

                  const SizedBox(height: 10),
                  Text('KOORDINAT PETA (SUPABASE LAT/LONG)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildInputField('Latitude', latCtrl, Icons.my_location, keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInputField('Longitude', longCtrl, Icons.explore, keyboardType: TextInputType.number)),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text('KAPASITAS & STRUKTUR TARIF (RP/JAM)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
                  const SizedBox(height: 6),
                  _buildInputField('Total Kapasitas Slot', slotsCtrl, Icons.local_parking, keyboardType: TextInputType.number),
                  Row(
                    children: [
                      Expanded(child: _buildInputField('Tarif Mobil', baseRateCtrl, Icons.directions_car, keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInputField('Tarif EV', evRateCtrl, Icons.bolt, keyboardType: TextInputType.number)),
                    ],
                  ),
                  _buildInputField('Tarif Motor', motorRateCtrl, Icons.two_wheeler, keyboardType: TextInputType.number),

                  const SizedBox(height: 10),
                  Text('OPERASIONAL & KESIAPAN EV', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
                  const SizedBox(height: 6),
                  _buildInputField('Jam Operasional (cth: 06:00 - 23:00)', hoursCtrl, Icons.access_time),
                  _buildInputField('Deskripsi Fasilitas', descCtrl, Icons.description_outlined, maxLines: 2),

                  SwitchListTile(
                    value: isEvReady,
                    onChanged: (val) => setDialogState(() => isEvReady = val),
                    title: Text('Sediakan Stasiun EV Charging', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text('Aktifkan slot khusus charger di denah lantai', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                    activeTrackColor: const Color(0xFF17A18A),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B))),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && slotsCtrl.text.isNotEmpty) {
                  final newId = 'loc_${_locations.length + 1}';
                  final newLoc = {
                    'id': newId,
                    'name': nameCtrl.text,
                    'typeLabel': typeCtrl.text,
                    'city': cityCtrl.text,
                    'address': addressCtrl.text.isEmpty ? 'Alamat belum diatur' : addressCtrl.text,
                    'latitude': double.tryParse(latCtrl.text) ?? -6.1754,
                    'longitude': double.tryParse(longCtrl.text) ?? 106.7933,
                    'totalSlots': int.tryParse(slotsCtrl.text) ?? 200,
                    'occupiedSlots': 0,
                    'status': 'Aktif',
                    'floors': ['Lantai 1', 'Lantai 2'],
                    'operatingHours': hoursCtrl.text,
                    'baseRate': int.tryParse(baseRateCtrl.text) ?? 5000,
                    'evRate': int.tryParse(evRateCtrl.text) ?? 7500,
                    'motorRate': int.tryParse(motorRateCtrl.text) ?? 2000,
                    'isEvReady': isEvReady,
                    'description': descCtrl.text,
                    'checkinRadius': 100,
                  };

                  setState(() {
                    _locations.insert(0, newLoc);
                    _selectedLocationId = newId;
                  });

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF17A18A),
                      content: Text('Lokasi "${nameCtrl.text}" berhasil disimpan dan muncul di peta!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Simpan Lokasi', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 2. DIALOG UBAH TOTAL SLOT, TARIF & JENIS PARKIR
  void _showQuickEditTariffAndSlotsDialog(Map<String, dynamic> loc) {
    final slotsCtrl = TextEditingController(text: loc['totalSlots'].toString());
    final baseRateCtrl = TextEditingController(text: loc['baseRate'].toString());
    final evRateCtrl = TextEditingController(text: loc['evRate'].toString());
    final motorRateCtrl = TextEditingController(text: loc['motorRate'].toString());
    final hoursCtrl = TextEditingController(text: loc['operatingHours'].toString());
    bool isEvReady = loc['isEvReady'] == true;
    String status = loc['status'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Atur Tarif & Kapasitas Slot', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField('Total Kapasitas Slot', slotsCtrl, Icons.local_parking, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Tarif Mobil (Rp/j)', baseRateCtrl, Icons.directions_car, keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildInputField('Tarif EV (Rp/j)', evRateCtrl, Icons.bolt, keyboardType: TextInputType.number)),
                  ],
                ),
                _buildInputField('Tarif Motor (Rp/j)', motorRateCtrl, Icons.two_wheeler, keyboardType: TextInputType.number),
                _buildInputField('Jam Buka / Operasional', hoursCtrl, Icons.access_time),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: InputDecoration(
                    labelText: 'Status Operasional',
                    labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Aktif', 'Padat', 'Tutup', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                  onChanged: (v) => setDialogState(() => status = v ?? 'Aktif'),
                ),
                SwitchListTile(
                  value: isEvReady,
                  onChanged: (v) => setDialogState(() => isEvReady = v),
                  title: Text('Fasilitas EV Charging Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  activeTrackColor: const Color(0xFF17A18A),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B))),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loc['totalSlots'] = int.tryParse(slotsCtrl.text) ?? loc['totalSlots'];
                  loc['baseRate'] = int.tryParse(baseRateCtrl.text) ?? loc['baseRate'];
                  loc['evRate'] = int.tryParse(evRateCtrl.text) ?? loc['evRate'];
                  loc['motorRate'] = int.tryParse(motorRateCtrl.text) ?? loc['motorRate'];
                  loc['operatingHours'] = hoursCtrl.text;
                  loc['status'] = status;
                  loc['isEvReady'] = isEvReady;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: const Color(0xFF17A18A), content: Text('Tarif & Slot ${loc['name']} diperbarui!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Simpan Perubahan', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 3. MODAL EDIT DETAIL SLOT PADA DENAH
  void _showEditSlotModal(Map<String, dynamic> slot, String locId, String floorName, String zoneKey) {
    String type = slot['type'];
    String status = slot['status'];
    final priceCtrl = TextEditingController(text: slot['price']?.toString() ?? '5000');
    final plateCtrl = TextEditingController(text: slot['plate'] ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Konfigurasi Slot: ${slot['code']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(floorName, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: 'Tipe Parkir Slot', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                items: ['Reguler', 'EV', 'VIP', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => type = v ?? 'Reguler'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(labelText: 'Status Ketersediaan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                items: ['Tersedia', 'Terisi', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSheetState(() => status = v ?? 'Tersedia'),
              ),
              const SizedBox(height: 10),
              if (status == 'Terisi') _buildInputField('Plat Kendaraan yang Parkir', plateCtrl, Icons.badge_outlined),
              _buildInputField('Tarif Parkir Khusus (Rp/Jam)', priceCtrl, Icons.payments_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _floorLayouts[locId]?[floorName]?[zoneKey]?.removeWhere((s) => s['code'] == slot['code']);
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Slot ${slot['code']} dihapus dari denah')));
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD94B4B)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Text('Hapus Slot', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD94B4B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          slot['type'] = type;
                          slot['status'] = status;
                          slot['price'] = int.tryParse(priceCtrl.text) ?? slot['price'];
                          if (status == 'Terisi') {
                            slot['plate'] = plateCtrl.text.isEmpty ? 'B 9999 PLT' : plateCtrl.text;
                          } else {
                            slot.remove('plate');
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Text('Simpan', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. DIALOG TAMBAH TINGKAT LANTAI BARU
  void _showAddFloorDialog(Map<String, dynamic> loc) {
    final floorCtrl = TextEditingController(text: 'Lantai 3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Tambah Tingkat Lantai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInputField('Nama Lantai (cth: Lantai 3, Basement 4)', floorCtrl, Icons.layers),
            const SizedBox(height: 6),
            Text(
              'Lantai baru akan disiapkan dengan denah default Posisi Atas (Reguler) dan Posisi Bawah (EV Station).',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () {
              if (floorCtrl.text.isNotEmpty) {
                final newFloor = floorCtrl.text;
                setState(() {
                  (loc['floors'] as List).add(newFloor);
                  _selectedFloorIndex = (loc['floors'] as List).length - 1;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: const Color(0xFF17A18A), content: Text('Lantai "$newFloor" berhasil ditambahkan!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Tambah', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. TAMBAH SLOT BARU KE ZONA ATAS / BAWAH
  void _showAddSlotToZoneDialog(String locId, String floorName, String zoneKey, {bool defaultIsEv = false}) {
    final codeCtrl = TextEditingController(text: zoneKey == 'zoneA' ? 'A-05' : (defaultIsEv ? 'B-05' : 'B-05'));
    String type = defaultIsEv ? 'EV' : 'Reguler';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(zoneKey == 'zoneA' ? 'Tambah Slot ke Posisi Atas' : 'Tambah Slot ke Posisi Bawah', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField('Nomor / Kode Slot', codeCtrl, Icons.pin),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(labelText: 'Tipe Slot', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                items: ['Reguler', 'EV', 'VIP', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setDState(() => type = v ?? 'Reguler'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
            ElevatedButton(
              onPressed: () {
                if (codeCtrl.text.isNotEmpty) {
                  setState(() {
                    if (_floorLayouts[locId] == null) _floorLayouts[locId] = {};
                    if (_floorLayouts[locId]![floorName] == null) {
                      _floorLayouts[locId]![floorName] = {'zoneA': [], 'zoneB': []};
                    }
                    _floorLayouts[locId]![floorName]![zoneKey]?.add({
                      'code': codeCtrl.text,
                      'type': type,
                      'status': 'Tersedia',
                      'price': type == 'EV' ? 7500 : 5000,
                      if (type == 'EV') 'charger': 'AC 22 kW',
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Tambahkan', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
          prefixIcon: Icon(icon, color: const Color(0xFF114177), size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}