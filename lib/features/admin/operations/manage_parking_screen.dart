import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/parking_image_service.dart';
import 'backend/manage_parking_backend.dart';

class ManageParkingScreen extends StatefulWidget {
  final int initialTabIndex;
  final String? initialLocationId;
  final String? initialLocationName;

  const ManageParkingScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialLocationId,
    this.initialLocationName,
  });

  @override
  State<ManageParkingScreen> createState() => _ManageParkingScreenState();
}

class _ManageParkingScreenState extends State<ManageParkingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';
  String _selectedLocationId = '';
  int _selectedFloorIndex = 0; // Default to first floor

  // Master Data Lokasi Parkir dari Backend
  List<Map<String, dynamic>> get _locations => ManageParkingBackend.instance.locations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    if (widget.initialLocationId != null && widget.initialLocationId!.isNotEmpty) {
      _selectedLocationId = widget.initialLocationId!;
    }
    ManageParkingBackend.instance.addListener(_onBackendUpdated);
    ManageParkingBackend.instance.fetchLocations().then((_) {
      _applyInitialLocation();
    });
  }

  void _applyInitialLocation() {
    if (_locations.isEmpty) return;
    if (widget.initialLocationId != null && _locations.any((l) => l['id'] == widget.initialLocationId)) {
      _selectedLocationId = widget.initialLocationId!;
    } else if (widget.initialLocationName != null) {
      final match = _locations.firstWhere(
        (l) => l['name'].toString().toLowerCase().contains(widget.initialLocationName!.toLowerCase()),
        orElse: () => _locations.first,
      );
      _selectedLocationId = match['id'];
    } else if (_selectedLocationId.isEmpty || !_locations.any((l) => l['id'] == _selectedLocationId)) {
      _selectedLocationId = _locations.first['id'];
    }
    ManageParkingBackend.instance.fetchSlotsForLocation(_selectedLocationId);
    if (mounted) setState(() {});
  }

  void _onBackendUpdated() {
    if (mounted) {
      if (_locations.isNotEmpty && (_selectedLocationId.isEmpty || !_locations.any((l) => l['id'] == _selectedLocationId))) {
        _selectedLocationId = _locations.first['id'];
        ManageParkingBackend.instance.fetchSlotsForLocation(_selectedLocationId);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    ManageParkingBackend.instance.removeListener(_onBackendUpdated);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _activeLocation {
    if (_locations.isEmpty) return null;
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
    return ListenableBuilder(
      listenable: ManageParkingBackend.instance,
      builder: (context, _) => Theme(
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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF114177)),
                tooltip: 'Segarkan',
                onPressed: () => ManageParkingBackend.instance.fetchLocations(),
              ),
              const SizedBox(width: 8),
            ],
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
                Icon(
                  _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.business_outlined,
                  size: 48,
                  color: const Color(0xFF9CA3AF),
                ),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isNotEmpty ? 'Tidak Ada Lokasi Ditemukan' : 'Belum Ada Gedung Parkir',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                ),
                const SizedBox(height: 4),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Coba gunakan kata kunci pencarian atau filter yang berbeda.'
                      : 'Tekan tombol "Tambah Lokasi" di atas untuk menambahkan mitra gedung parkir pertama Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          )
        else
          ...list.map((loc) => _buildLocationCard(loc)),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> loc) {
    final total = (loc['totalSlots'] is num && loc['totalSlots'] > 0) ? (loc['totalSlots'] as num).toInt() : 1;
    final occupied = (loc['occupiedSlots'] is num) ? (loc['occupiedSlots'] as num).toInt() : 0;
    final occupancy = (occupied / total).clamp(0.0, 1.0);
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
          onTap: () => _showEditLocationDialog(loc),
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
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF114177).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (loc['images'] != null &&
                              (loc['images'] as List).isNotEmpty &&
                              (loc['images'][0] as String).isNotEmpty)
                          ? _buildThumbnail(loc['images'][0])
                          : const Icon(Icons.business_rounded, color: Color(0xFF114177), size: 24),
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
                        onPressed: () => _showEditLocationDialog(loc),
                        icon: const Icon(Icons.edit_location_alt_rounded, size: 16),
                        label: Text('Edit Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold)),
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
    if (loc == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_outlined, size: 40, color: Color(0xFF114177)),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Gedung Parkir',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A18),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan tambahkan lokasi parkir pertama di tab "Daftar Lokasi & Tarif" terlebih dahulu untuk mendesain denah lantai & tata letak slot.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showAddLocationDialog,
                icon: const Icon(Icons.add_location_alt_rounded, size: 18, color: Colors.white),
                label: Text(
                  'Tambah Lokasi Sekarang',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF114177),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<String> floors = List<String>.from(loc['floors'] ?? ['Lantai 1']);
    if (_selectedFloorIndex >= floors.length) {
      _selectedFloorIndex = 0;
    }
    final activeFloorName = floors[_selectedFloorIndex];

    // Ambil data kapasitas gedung dan slot aktual dari database Supabase
    final int totalCap = (loc['totalSlots'] as num?)?.toInt() ?? 0;
    final int totalCreated = ManageParkingBackend.instance.getTotalSlotsCount(loc['id']);
    final int remainingQuota = (totalCap - totalCreated).clamp(0, totalCap);

    final zoneASlots = ManageParkingBackend.instance.getSlotsFor(loc['id'], activeFloorName, 'zoneA');
    final zoneBSlots = ManageParkingBackend.instance.getSlotsFor(loc['id'], activeFloorName, 'zoneB');

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
              value: _locations.any((l) => l['id'] == _selectedLocationId)
                  ? _selectedLocationId
                  : loc['id']?.toString(),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF114177), size: 24),
              items: _locations.map<DropdownMenuItem<String>>((l) {
                return DropdownMenuItem<String>(
                  value: l['id']?.toString(),
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
                  ManageParkingBackend.instance.fetchSlotsForLocation(v);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. Tab Pemilih Lantai (Default 1 Lantai, Maksimal 4 Lantai) + Tombol Tambah Lantai
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tingkat Lantai Parkir:',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
            ),
            if (floors.length < 4)
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
        const SizedBox(height: 12),

        // Indikator Kapasitas Slot (Terikat Total Kapasitas Lokasi)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pie_chart_outline_rounded, size: 16, color: Color(0xFF114177)),
                      const SizedBox(width: 6),
                      Text(
                        'Alokasi Slot Terpasang:',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                      ),
                    ],
                  ),
                  Text(
                    '$totalCreated / $totalCap Slot (${remainingQuota == 0 ? "Penuh" : "Sisa $remainingQuota"})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: remainingQuota == 0 ? const Color(0xFFDC2626) : const Color(0xFF114177),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalCap > 0 ? (totalCreated / totalCap).clamp(0.0, 1.0) : 0.0,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remainingQuota == 0 ? const Color(0xFFDC2626) : const Color(0xFF114177),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. KANVAS DENAH INTERAKTIF (PERSIS SEPERTI DI SISI USER BOOKING)
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
              // ZONA A: POSISI ATAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('ZONA A (POSISI ATAS)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                  ),
                  InkWell(
                    onTap: () {
                      if (totalCreated >= totalCap) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFDC2626),
                            content: Text('Batas kapasitas ($totalCap slot) untuk gedung ini sudah tercapai!'),
                          ),
                        );
                        return;
                      }
                      _showAddSlotToZoneDialog(
                        loc['id'],
                        activeFloorName,
                        'zoneA',
                        totalCreated,
                        totalCap,
                        defaultCode: 'A-0${zoneASlots.length + 1}',
                      );
                    },
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

              // Baris Slot Zona A (Swipeable Horizontal, Tanpa Overflow)
              if (zoneASlots.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.crop_free_rounded, size: 28, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 6),
                      Text(
                        'Zona A masih kosong',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tekan "+ Tambah Slot" untuk menambah slot di lantai ini.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: zoneASlots.map((slot) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 78,
                          height: 104,
                          child: _buildVisualSlotItem(slot, loc['id'], activeFloorName, 'zoneA'),
                        ),
                      );
                    }).toList(),
                  ),
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

              // ZONA B: POSISI BAWAH
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text('ZONA B (POSISI BAWAH)', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                  ),
                  InkWell(
                    onTap: () {
                      if (totalCreated >= totalCap) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFFDC2626),
                            content: Text('Batas kapasitas ($totalCap slot) untuk gedung ini sudah tercapai!'),
                          ),
                        );
                        return;
                      }
                      _showAddSlotToZoneDialog(
                        loc['id'],
                        activeFloorName,
                        'zoneB',
                        totalCreated,
                        totalCap,
                        defaultIsEv: false,
                        defaultCode: 'B-0${zoneBSlots.length + 1}',
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.add, size: 14, color: Color(0xFF17A18A)),
                        Text('Tambah Slot', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Baris Slot Zona B (Swipeable Horizontal, Tanpa Overflow)
              if (zoneBSlots.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.bolt_outlined, size: 28, color: Color(0xFF17A18A)),
                      const SizedBox(height: 6),
                      Text(
                        'Zona B masih kosong',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tekan "+ Tambah Slot" untuk menambah slot di lantai ini.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: zoneBSlots.map((slot) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 78,
                          height: 104,
                          child: _buildVisualSlotItem(slot, loc['id'], activeFloorName, 'zoneB'),
                        ),
                      );
                    }).toList(),
                  ),
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

        // Tombol Simpan / Status Sinkronisasi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_done_rounded, size: 20, color: Color(0xFF16A34A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Seluruh slot dan denah langsung tersinkronisasi otomatis dengan database Supabase & aplikasi pengguna.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF15803D)),
                ),
              ),
            ],
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
    final statusStr = (slot['status']?.toString() ?? 'available').toLowerCase();
    final bool isOccupied = statusStr == 'occupied' || statusStr == 'terisi';
    final slotTypeStr = (slot['slot_type']?.toString() ?? slot['type']?.toString() ?? 'mobil').toLowerCase();
    final bool isEV = slotTypeStr == 'ev';
    final bool isDifabel = slotTypeStr == 'difabel' || slotTypeStr.contains('disabilitas');
    final bool isMotor = slotTypeStr == 'motor';
    final bool isVip = slotTypeStr == 'vip';

    final Color primaryColor = isEV
        ? const Color(0xFF17A18A)
        : (isDifabel
            ? const Color(0xFF8B5CF6)
            : (isMotor
                ? const Color(0xFFF59E0B)
                : (isVip ? const Color(0xFFEAB308) : const Color(0xFF114177))));

    String typeLabel = 'Reguler';
    if (isEV) {
      typeLabel = '⚡ EV';
    } else if (isDifabel) {
      typeLabel = '♿ Difabel';
    } else if (isMotor) {
      typeLabel = '🛵 Motor';
    } else if (isVip) {
      typeLabel = '👑 VIP';
    }

    final String slotCode = slot['slot_code']?.toString() ?? slot['code']?.toString() ?? '-';
    final String? plateNumber = slot['current_plate_number']?.toString() ?? slot['plate']?.toString();

    return GestureDetector(
      onTap: () => _showEditSlotModal(slot, locId, floorName, zoneKey),
      child: Container(
        width: 78,
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                typeLabel,
                style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              slotCode,
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
            ),
            const SizedBox(height: 4),
            if (isOccupied)
              Text(
                (plateNumber != null && plateNumber.isNotEmpty) ? plateNumber : 'Terisi',
                style: GoogleFonts.jetBrainsMono(fontSize: 8, fontWeight: FontWeight.w600, color: const Color(0xFFD94B4B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                'Tersedia',
                style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A)),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS & MODAL CONFIGURATION ====================

  // 1. DIALOG TAMBAH LOKASI BARU (LENGKAP SESUAI SUPABASE.MD + 4 GAMBAR)
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

    final List<String> images = ['', '', '', ''];
    final List<String> newlyUploadedUrls = [];
    final Set<int> uploadingSlots = {};
    int primaryImageIndex = 0;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
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
                  // 1. FOTO LOKASI PARKIR (4 SLOT) DENGAN HIGHLIGHT FOTO UTAMA
                  _buildImageSlotsSection(
                    images: images,
                    primaryImageIndex: primaryImageIndex,
                    uploadingSlots: uploadingSlots,
                    onPrimaryChanged: (newIdx) {
                      setDialogState(() => primaryImageIndex = newIdx);
                    },
                    onImageUploaded: (slotIdx, newUrl) {
                      setDialogState(() {
                        images[slotIdx] = newUrl;
                        newlyUploadedUrls.add(newUrl);
                        if (images[primaryImageIndex].isEmpty) {
                          primaryImageIndex = slotIdx;
                        }
                      });
                    },
                    onImageRemoved: (slotIdx) {
                      final removed = images[slotIdx];
                      setDialogState(() {
                        images[slotIdx] = '';
                        if (primaryImageIndex == slotIdx) {
                          final next = images.indexWhere((img) => img.isNotEmpty);
                          primaryImageIndex = next != -1 ? next : 0;
                        }
                      });
                      if (removed.isNotEmpty && newlyUploadedUrls.contains(removed)) {
                        newlyUploadedUrls.remove(removed);
                        ParkingImageService.deleteLocationImage(removed);
                      }
                    },
                    setDialogState: setDialogState,
                    dialogContext: ctx,
                  ),
                  const SizedBox(height: 12),

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
              onPressed: () {
                if (newlyUploadedUrls.isNotEmpty) {
                  ParkingImageService.deleteMultipleLocationImages(newlyUploadedUrls);
                }
                Navigator.pop(ctx);
              },
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B))),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (nameCtrl.text.trim().isNotEmpty && slotsCtrl.text.trim().isNotEmpty) {
                  setDialogState(() => isSaving = true);
                  final List<String> finalImages = [];
                  if (primaryImageIndex < images.length && images[primaryImageIndex].isNotEmpty) {
                    finalImages.add(images[primaryImageIndex]);
                  }
                  for (int i = 0; i < images.length; i++) {
                    if (i != primaryImageIndex && images[i].isNotEmpty) {
                      finalImages.add(images[i]);
                    }
                  }

                  final newLoc = {
                    'name': nameCtrl.text.trim(),
                    'typeLabel': typeCtrl.text.trim(),
                    'city': cityCtrl.text.trim(),
                    'address': addressCtrl.text.trim().isEmpty ? 'Alamat belum diatur' : addressCtrl.text.trim(),
                    'latitude': double.tryParse(latCtrl.text) ?? -6.1754,
                    'longitude': double.tryParse(longCtrl.text) ?? 106.7933,
                    'totalSlots': int.tryParse(slotsCtrl.text) ?? 200,
                    'operatingHours': hoursCtrl.text.trim().isEmpty ? '06:00 - 23:00' : hoursCtrl.text.trim(),
                    'baseRate': int.tryParse(baseRateCtrl.text) ?? 5000,
                    'evRate': int.tryParse(evRateCtrl.text) ?? 7500,
                    'motorRate': int.tryParse(motorRateCtrl.text) ?? 2000,
                    'isEvReady': isEvReady,
                    'description': descCtrl.text.trim(),
                    'images': finalImages,
                  };

                  final messenger = ScaffoldMessenger.of(context);
                  final newLocId = await ManageParkingBackend.instance.addParkingLocation(newLoc);
                  setDialogState(() => isSaving = false);

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (newLocId != null) {
                    setState(() {
                      _selectedLocationId = newLocId;
                    });
                    await ManageParkingBackend.instance.fetchSlotsForLocation(newLocId);
                    _tabController.animateTo(1); // Langsung pindah ke tab denah untuk alokasi slot
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF17A18A),
                        content: Text('Lokasi "${newLoc['name']}" berhasil dibuat! Silakan tambah slot pada denah.'),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Gagal menyimpan: ${ManageParkingBackend.instance.errorMessage ?? "Error"}'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama gedung dan kapasitas slot wajib diisi!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114177),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Simpan Lokasi', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 2. DIALOG EDIT LOKASI LENGKAP (KOPI SEMUA STYLE & UNSUR INPUT DARI TAMBAH LOKASI)
  void _showEditLocationDialog(Map<String, dynamic> loc) {
    final nameCtrl = TextEditingController(text: loc['name']);
    final typeCtrl = TextEditingController(text: loc['typeLabel']);
    final cityCtrl = TextEditingController(text: loc['city']);
    final addressCtrl = TextEditingController(text: loc['address']);
    final latCtrl = TextEditingController(text: loc['latitude'].toString());
    final longCtrl = TextEditingController(text: loc['longitude'].toString());
    final slotsCtrl = TextEditingController(text: loc['totalSlots'].toString());
    final baseRateCtrl = TextEditingController(text: loc['baseRate'].toString());
    final evRateCtrl = TextEditingController(text: loc['evRate'].toString());
    final motorRateCtrl = TextEditingController(text: loc['motorRate'].toString());
    final hoursCtrl = TextEditingController(text: loc['operatingHours'].toString());
    final descCtrl = TextEditingController(text: loc['description'] ?? '');
    bool isEvReady = loc['isEvReady'] == true;
    String status = loc['status'] ?? 'Aktif';

    final List<String> existingImages = (loc['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final List<String> images = List.generate(4, (i) => i < existingImages.length ? existingImages[i] : '');
    final Set<String> pendingDeleteUrls = {}; // File lama yang disilang (akan diquery hapus saat simpan)
    final List<String> newlyUploadedUrls = []; // File baru yang diupload selama dialog
    final Set<int> uploadingSlots = {};
    int primaryImageIndex = 0;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit_location_alt_rounded, color: Color(0xFF114177), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edit Lokasi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(loc['name'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. FOTO LOKASI PARKIR (4 SLOT) DENGAN HIGHLIGHT FOTO UTAMA
                  _buildImageSlotsSection(
                    images: images,
                    primaryImageIndex: primaryImageIndex,
                    uploadingSlots: uploadingSlots,
                    onPrimaryChanged: (newIdx) {
                      setDialogState(() => primaryImageIndex = newIdx);
                    },
                    onImageUploaded: (slotIdx, newUrl) {
                      setDialogState(() {
                        images[slotIdx] = newUrl;
                        newlyUploadedUrls.add(newUrl);
                        if (images[primaryImageIndex].isEmpty) {
                          primaryImageIndex = slotIdx;
                        }
                      });
                    },
                    onImageRemoved: (slotIdx) {
                      final removed = images[slotIdx];
                      setDialogState(() {
                        images[slotIdx] = '';
                        if (removed.isNotEmpty) {
                          if (newlyUploadedUrls.contains(removed)) {
                            // File baru diupload pada sesi dialog ini -> langsung hapus dari storage
                            newlyUploadedUrls.remove(removed);
                            ParkingImageService.deleteLocationImage(removed);
                          } else {
                            // File lama yang tersimpan di storage -> tandai untuk dihapus saat simpan ditekan
                            pendingDeleteUrls.add(removed);
                          }
                        }
                        if (primaryImageIndex == slotIdx) {
                          final next = images.indexWhere((img) => img.isNotEmpty);
                          primaryImageIndex = next != -1 ? next : 0;
                        }
                      });
                    },
                    setDialogState: setDialogState,
                    dialogContext: ctx,
                  ),
                  const SizedBox(height: 12),

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

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: InputDecoration(
                        labelText: 'Status Operasional',
                        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                        prefixIcon: const Icon(Icons.info_outline_rounded, color: Color(0xFF114177), size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: ['Aktif', 'Padat', 'Tutup', 'Maintenance']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 12))))
                          .toList(),
                      onChanged: (v) => setDialogState(() => status = v ?? 'Aktif'),
                    ),
                  ),

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
            TextButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Hapus Lokasi Parkir?'),
                    content: Text('Lokasi "${loc['name']}" dan seluruh foto terkait di Supabase Storage akan dihapus secara permanen.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Batal')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dCtx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94B4B)),
                        child: const Text('Hapus Permanen', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final allImages = <String>{
                    ...existingImages,
                    ...newlyUploadedUrls,
                    if (loc['imageUrl'] != null) loc['imageUrl'].toString(),
                    if (loc['image_url'] != null) loc['image_url'].toString(),
                  }.where((u) => u.isNotEmpty).toList();

                  setDialogState(() => isSaving = true);
                  final ok = await ManageParkingBackend.instance.deleteParkingLocation(loc['id'], imagesToDelete: allImages);
                  setDialogState(() => isSaving = false);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ok) {
                    setState(() {
                      if (_selectedLocationId == loc['id']) {
                        final remaining = ManageParkingBackend.instance.locations;
                        _selectedLocationId = remaining.isNotEmpty ? remaining.first['id'] : '';
                      }
                    });
                    if (_selectedLocationId.isNotEmpty) {
                      ManageParkingBackend.instance.fetchSlotsForLocation(_selectedLocationId);
                    }
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF17A18A),
                        content: Text('Lokasi "${loc['name']}" dan seluruh datanya berhasil dihapus!'),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Gagal menghapus lokasi: ${ManageParkingBackend.instance.errorMessage ?? "Error database"}'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD94B4B), size: 16),
              label: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD94B4B), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                if (newlyUploadedUrls.isNotEmpty) {
                  ParkingImageService.deleteMultipleLocationImages(newlyUploadedUrls);
                }
                Navigator.pop(ctx);
              },
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B))),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (nameCtrl.text.trim().isNotEmpty && slotsCtrl.text.trim().isNotEmpty) {
                  setDialogState(() => isSaving = true);
                  final List<String> finalImages = [];
                  if (primaryImageIndex < images.length && images[primaryImageIndex].isNotEmpty) {
                    finalImages.add(images[primaryImageIndex]);
                  }
                  for (int i = 0; i < images.length; i++) {
                    if (i != primaryImageIndex && images[i].isNotEmpty) {
                      finalImages.add(images[i]);
                    }
                  }

                  final updateData = {
                    'name': nameCtrl.text.trim(),
                    'typeLabel': typeCtrl.text.trim(),
                    'city': cityCtrl.text.trim(),
                    'address': addressCtrl.text.trim(),
                    'latitude': double.tryParse(latCtrl.text) ?? loc['latitude'],
                    'longitude': double.tryParse(longCtrl.text) ?? loc['longitude'],
                    'totalSlots': int.tryParse(slotsCtrl.text) ?? loc['totalSlots'],
                    'baseRate': int.tryParse(baseRateCtrl.text) ?? loc['baseRate'],
                    'evRate': int.tryParse(evRateCtrl.text) ?? loc['evRate'],
                    'motorRate': int.tryParse(motorRateCtrl.text) ?? loc['motorRate'],
                    'operatingHours': hoursCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'status': status,
                    'isEvReady': isEvReady,
                    'images': finalImages,
                  };

                  final messenger = ScaffoldMessenger.of(context);
                  // Eksekusi query hapus foto-foto sampah dari Supabase Storage & update database
                  final ok = await ManageParkingBackend.instance.updateParkingLocationFull(
                    loc['id'],
                    updateData,
                    deletedImageUrls: pendingDeleteUrls.toList(),
                  );
                  setDialogState(() => isSaving = false);

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ok) {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF17A18A),
                        content: Text(
                          pendingDeleteUrls.isNotEmpty
                              ? 'Lokasi "${nameCtrl.text}" diperbarui & ${pendingDeleteUrls.length} foto sampah berhasil dibersihkan dari Storage!'
                              : 'Lokasi "${nameCtrl.text}" berhasil diperbarui!',
                        ),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Gagal memperbarui: ${ManageParkingBackend.instance.errorMessage ?? "Error"}'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114177),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Simpan Perubahan', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 3. MODAL EDIT DETAIL SLOT PADA DENAH
  void _showEditSlotModal(Map<String, dynamic> slot, String locId, String floorName, String zoneKey) {
    final slotId = slot['id']?.toString() ?? '';
    final code = slot['slot_code']?.toString() ?? slot['code']?.toString() ?? 'Slot';
    final rawType = (slot['slot_type']?.toString() ?? slot['type']?.toString() ?? 'mobil').toLowerCase();
    String type = 'Reguler';
    if (rawType == 'ev') {
      type = 'EV';
    } else if (rawType == 'difabel' || rawType.contains('disabilitas')) {
      type = 'Disabilitas';
    } else if (rawType == 'motor') {
      type = 'Motor';
    } else if (rawType == 'vip') {
      type = 'VIP';
    }

    final rawStatus = (slot['status']?.toString() ?? 'available').toLowerCase();
    String status = (rawStatus == 'occupied' || rawStatus == 'terisi')
        ? 'Terisi'
        : ((rawStatus == 'maintenance') ? 'Maintenance' : 'Tersedia');

    final plateCtrl = TextEditingController(text: slot['current_plate_number']?.toString() ?? slot['plate']?.toString() ?? '');

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
                  Text('Konfigurasi Slot: $code', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
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
                decoration: InputDecoration(
                  labelText: 'Tipe Parkir Slot',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['Reguler', 'EV', 'VIP', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => type = v ?? 'Reguler'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(
                  labelText: 'Status Ketersediaan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['Tersedia', 'Terisi', 'Maintenance'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSheetState(() => status = v ?? 'Tersedia'),
              ),
              if (status == 'Terisi') ...[
                const SizedBox(height: 10),
                _buildInputField('Plat Kendaraan yang Parkir', plateCtrl, Icons.badge_outlined),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);
                        if (slotId.isNotEmpty) {
                          await ManageParkingBackend.instance.deleteSlot(slotId, locId);
                          messenger.showSnackBar(SnackBar(content: Text('Slot $code berhasil dihapus')));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD94B4B)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Hapus Slot', style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD94B4B), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);
                        if (slotId.isNotEmpty) {
                          await ManageParkingBackend.instance.updateSlot(
                            slotId: slotId,
                            locationId: locId,
                            slotType: type,
                            status: status,
                            plate: plateCtrl.text.trim(),
                          );
                          messenger.showSnackBar(SnackBar(content: Text('Slot $code berhasil diperbarui')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF114177),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
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

  // 4. DIALOG TAMBAH TINGKAT LANTAI BARU (MAKSIMAL 4 LANTAI)
  void _showAddFloorDialog(Map<String, dynamic> loc) {
    final List<String> currentFloors = List<String>.from(loc['floors'] ?? ['Lantai 1']);
    if (currentFloors.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('Maksimal 4 tingkat lantai parkir sudah tercapai.'),
        ),
      );
      return;
    }
    final nextNumber = currentFloors.length + 1;
    final floorCtrl = TextEditingController(text: 'Lantai $nextNumber');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Tambah Tingkat Lantai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField('Nama Lantai (cth: Lantai 2, Basement 1)', floorCtrl, Icons.layers),
            const SizedBox(height: 6),
            Text(
              'Tingkat lantai baru akan tersimpan permanen di database. Maksimal 4 lantai.',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
          ElevatedButton(
            onPressed: () async {
              if (floorCtrl.text.trim().isNotEmpty) {
                final newFloor = floorCtrl.text.trim();
                Navigator.pop(ctx);
                final ok = await ManageParkingBackend.instance.addFloor(loc['id'], newFloor);
                if (ok && mounted) {
                  setState(() {
                    _selectedFloorIndex = currentFloors.length;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: const Color(0xFF17A18A), content: Text('Lantai "$newFloor" berhasil ditambahkan!')),
                  );
                }
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
  void _showAddSlotToZoneDialog(
    String locId,
    String floorName,
    String zoneKey,
    int totalCreated,
    int totalCap, {
    bool defaultIsEv = false,
    String defaultCode = '',
  }) {
    final codeCtrl = TextEditingController(
      text: defaultCode.isNotEmpty ? defaultCode : (zoneKey == 'zoneA' ? 'A-01' : 'B-01'),
    );
    String type = defaultIsEv ? 'EV' : 'Reguler';
    final remaining = (totalCap - totalCreated).clamp(0, totalCap);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            zoneKey == 'zoneA' ? 'Tambah Slot ke Posisi Atas' : 'Tambah Slot ke Posisi Bawah',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sisa Kuota Lokasi: $remaining dari $totalCap Slot',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1E40AF)),
                ),
              ),
              _buildInputField('Nomor / Kode Slot', codeCtrl, Icons.pin),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: InputDecoration(
                  labelText: 'Tipe Slot',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['Reguler', 'EV', 'VIP', 'Disabilitas', 'Motor'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setDState(() => type = v ?? 'Reguler'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))),
            ElevatedButton(
              onPressed: () async {
                if (codeCtrl.text.trim().isNotEmpty) {
                  final messenger = ScaffoldMessenger.of(context);
                  final code = codeCtrl.text.trim().toUpperCase();
                  Navigator.pop(ctx);
                  final ok = await ManageParkingBackend.instance.addSlot(
                    locationId: locId,
                    floorName: floorName,
                    zone: zoneKey,
                    slotCode: code,
                    slotType: type,
                  );
                  if (!ok) {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFDC2626),
                        content: Text(ManageParkingBackend.instance.errorMessage ?? 'Gagal menambah slot.'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text('Simpan', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildThumbnail(String pathOrUrl) {
    if (pathOrUrl.isEmpty) {
      return const Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 24);
    }
    if (pathOrUrl.startsWith('http://') ||
        pathOrUrl.startsWith('https://') ||
        pathOrUrl.startsWith('blob:')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8), size: 22),
        ),
      );
    }
    if (!kIsWeb && File(pathOrUrl).existsSync()) {
      return Image.file(
        File(pathOrUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_rounded, color: Color(0xFF94A3B8), size: 22),
        ),
      );
    }
    return const Center(
      child: Icon(Icons.image_rounded, color: Color(0xFF94A3B8), size: 22),
    );
  }

  Widget _buildImageSlotsSection({
    required List<String> images,
    required int primaryImageIndex,
    required Set<int> uploadingSlots,
    required ValueChanged<int> onPrimaryChanged,
    required void Function(int slotIdx, String newUrl) onImageUploaded,
    required void Function(int slotIdx) onImageRemoved,
    required StateSetter setDialogState,
    required BuildContext dialogContext,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FOTO LOKASI PARKIR (4 SLOT)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF76777B),
              ),
            ),
            if (images.any((img) => img.isNotEmpty))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A18A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${images.where((img) => img.isNotEmpty).length}/4 Terisi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF17A18A),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'Foto akan dikompres otomatis & disimpan ke Supabase Storage. Klik foto terisi untuk menjadikannya Foto Utama.',
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final hasImage = images[index].isNotEmpty;
            final isPrimary = primaryImageIndex == index && hasImage;
            final isUploading = uploadingSlots.contains(index);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    if (isUploading) return;
                    if (hasImage) {
                      // Click on uploaded photo -> highlight as primary!
                      onPrimaryChanged(index);
                    } else {
                      // Empty slot -> open picker
                      _showImageSourcePicker(
                        dialogContext,
                        index,
                        onUploaded: (slotIdx, publicUrl) {
                          onImageUploaded(slotIdx, publicUrl);
                        },
                        onUploadStateChanged: (slotIdx, uploading) {
                          setDialogState(() {
                            if (uploading) {
                              uploadingSlots.add(slotIdx);
                            } else {
                              uploadingSlots.remove(slotIdx);
                            }
                          });
                        },
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 76,
                    decoration: BoxDecoration(
                      color: hasImage ? Colors.grey[100] : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPrimary
                            ? const Color(0xFF114177)
                            : hasImage
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFFE2E8F0),
                        width: isPrimary ? 2.5 : 1,
                      ),
                      boxShadow: isPrimary
                          ? [
                              BoxShadow(
                                color: const Color(0xFF114177).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isPrimary ? 9.5 : 11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (isUploading)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF114177)),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Kompres...',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF114177),
                                  ),
                                ),
                              ],
                            )
                          else if (hasImage)
                            _buildThumbnail(images[index])
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined, size: 20, color: Color(0xFF64748B)),
                                const SizedBox(height: 4),
                                Text(
                                  'Foto ${index + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),

                          // Highlight Badge: Foto Utama
                          if (isPrimary && !isUploading)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF114177),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, size: 10, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Utama',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Clear / Remove Button on top-right (Klik Silang)
                          if (hasImage && !isUploading)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => onImageRemoved(index),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 11, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showImageSourcePicker(
    BuildContext parentContext,
    int slotIndex, {
    required Function(int slotIdx, String publicUrl) onUploaded,
    required Function(int slotIdx, bool isUploading) onUploadStateChanged,
  }) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Sumber Foto (Kompres & Simpan ke Supabase)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(bCtx),
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF76777B)),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFF3F4F6)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF114177), size: 20),
                ),
                title: Text('Galeri Perangkat', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Pilih foto, kompres resolusi, lalu simpan ke storage', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                onTap: () async {
                  Navigator.pop(bCtx);
                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      onUploadStateChanged(slotIndex, true);
                      final bytes = await picked.readAsBytes();
                      final publicUrl = await ParkingImageService.uploadLocationImage(bytes);
                      onUploadStateChanged(slotIndex, false);
                      if (publicUrl != null) {
                        onUploaded(slotIndex, publicUrl);
                      }
                    }
                  } catch (e) {
                    onUploadStateChanged(slotIndex, false);
                    debugPrint('Gallery picker/upload error: $e');
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF17A18A), size: 20),
                ),
                title: Text('Ambil Foto Kamera', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Potret gedung parkir, kompres resolusi & simpan ke storage', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                onTap: () async {
                  Navigator.pop(bCtx);
                  try {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.camera);
                    if (picked != null) {
                      onUploadStateChanged(slotIndex, true);
                      final bytes = await picked.readAsBytes();
                      final publicUrl = await ParkingImageService.uploadLocationImage(bytes);
                      onUploadStateChanged(slotIndex, false);
                      if (publicUrl != null) {
                        onUploaded(slotIndex, publicUrl);
                      }
                    }
                  } catch (e) {
                    onUploadStateChanged(slotIndex, false);
                    debugPrint('Camera picker/upload error: $e');
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.collections_rounded, color: Colors.amber, size: 20),
                ),
                title: Text('Pilih dari Foto Sampel Parkir (Preset)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Pilihan foto HD gedung & fasilitas parkir siap pakai', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                onTap: () {
                  Navigator.pop(bCtx);
                  _showSampleImagesSelector(parentContext, (url) {
                    onUploaded(slotIndex, url);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSampleImagesSelector(BuildContext parentContext, Function(String) onPicked) {
    final List<Map<String, String>> presets = [
      {'title': 'Gedung Mall Depan', 'url': 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80'},
      {'title': 'Area Parkir Basemen', 'url': 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80'},
      {'title': 'Stasiun EV Charger', 'url': 'https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?w=600&auto=format&fit=crop&q=80'},
      {'title': 'Outdoor Car Park', 'url': 'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600&auto=format&fit=crop&q=80'},
      {'title': 'Pintu Masuk Gerbang', 'url': 'https://images.unsplash.com/photo-1526628953301-3e589a6a8b74?w=600&auto=format&fit=crop&q=80'},
      {'title': 'Rooftop Car Park', 'url': 'https://images.unsplash.com/photo-1470224114660-3f6686c562eb?w=600&auto=format&fit=crop&q=80'},
    ];

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Foto Sampel Parkir',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: presets.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () {
                    Navigator.pop(sCtx);
                    onPicked(presets[i]['url']!);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(presets[i]['url']!, fit: BoxFit.cover),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            child: Text(
                              presets[i]['title']!,
                              style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}