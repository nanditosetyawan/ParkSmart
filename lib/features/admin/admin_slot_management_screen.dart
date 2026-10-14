import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlotManagementScreen extends StatefulWidget {
  const SlotManagementScreen({super.key});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
  String _selectedLocation = 'Central Park Mall';
  int _selectedFloor = 0; // 0=B1, 1=B2, 2=Outdoor

  final List<String> _floors = ['Basement 1 (Mobil)', 'Basement 2 (EV & VIP)', 'Outdoor (Motor)'];

  late List<Map<String, dynamic>> _slots;

  @override
  void initState() {
    super.initState();
    _initSlots();
  }

  void _initSlots() {
    _slots = [
      {'id': 'A-01', 'type': 'Mobil', 'status': 'Terisi', 'plate': 'B 1234 SKP', 'duration': '1j 45m'},
      {'id': 'A-02', 'type': 'Mobil', 'status': 'Tersedia', 'plate': null, 'duration': null},
      {'id': 'A-03', 'type': 'Mobil', 'status': 'Tersedia', 'plate': null, 'duration': null},
      {'id': 'A-04', 'type': 'Mobil', 'status': 'Reserved', 'plate': 'B 8899 DTO', 'duration': 'Booking 14:00'},
      {'id': 'A-05', 'type': 'Mobil', 'status': 'Terisi', 'plate': 'B 4412 XYZ', 'duration': '42m'},
      {'id': 'A-06', 'type': 'Mobil', 'status': 'Tersedia', 'plate': null, 'duration': null},
      {'id': 'B-01', 'type': 'EV Charging', 'status': 'Terisi', 'plate': 'B 1111 ION', 'duration': '2j 10m (85%)'},
      {'id': 'B-02', 'type': 'EV Charging', 'status': 'Tersedia', 'plate': null, 'duration': null},
      {'id': 'B-03', 'type': 'VIP', 'status': 'Reserved', 'plate': 'RI 1', 'duration': 'Khusus Tamu'},
      {'id': 'B-04', 'type': 'Disabilitas', 'status': 'Tersedia', 'plate': null, 'duration': null},
      {'id': 'B-05', 'type': 'Mobil', 'status': 'Maintenance', 'plate': null, 'duration': 'Perbaikan Marka'},
      {'id': 'B-06', 'type': 'Mobil', 'status': 'Tersedia', 'plate': null, 'duration': null},
      {'id': 'C-01', 'type': 'Mobil', 'status': 'Terisi', 'plate': 'B 5532 PLM', 'duration': '3j 15m (Overstay)'},
      {'id': 'C-02', 'type': 'Mobil', 'status': 'Tersedia', 'plate': null, 'duration': null},
      {'id': 'C-03', 'type': 'Mobil', 'status': 'Terisi', 'plate': 'D 9901 AB', 'duration': '55m'},
      {'id': 'C-04', 'type': 'Mobil', 'status': 'Tersedia', 'plate': null, 'duration': null},
    ];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFF17A18A);
      case 'Terisi':
        return const Color(0xFFD94B4B);
      case 'Reserved':
        return const Color(0xFF114177);
      case 'Maintenance':
        return const Color(0xFF76777B);
      default:
        return const Color(0xFFE07A5F);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFFD1F2EB);
      case 'Terisi':
        return const Color(0xFFFDE8E4);
      case 'Reserved':
        return const Color(0xFFE3EEFF);
      case 'Maintenance':
        return const Color(0xFFF1EEE7);
      default:
        return const Color(0xFFFDECE7);
    }
  }

  void _openSlotDetail(Map<String, dynamic> slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final color = _getStatusColor(slot['status']);
          final bg = _getStatusBg(slot['status']);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(slot['id'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Slot ${slot['id']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                            Text('${_floors[_selectedFloor]} · ${slot['type']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                      child: Text(slot['status'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFF1EEE7), height: 28),

                if (slot['plate'] != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plat Nomor:', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(6)),
                        child: Text(slot['plate'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Durasi Parkir:', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                      Text(slot['duration'] ?? '-', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                Text('Tindakan Cepat Admin:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            slot['status'] = slot['status'] == 'Maintenance' ? 'Tersedia' : 'Maintenance';
                            slot['plate'] = null;
                            slot['duration'] = null;
                          });
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE4DFD5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          slot['status'] == 'Maintenance' ? 'Aktifkan Slot' : 'Kunci (Maintenance)',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            slot['status'] = slot['status'] == 'Tersedia' ? 'Terisi' : 'Tersedia';
                            if (slot['status'] == 'Tersedia') {
                              slot['plate'] = null;
                              slot['duration'] = null;
                            } else {
                              slot['plate'] = 'B 0000 NEW';
                              slot['duration'] = 'Baru Masuk';
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: slot['status'] == 'Tersedia' ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          slot['status'] == 'Tersedia' ? 'Tandai Terisi' : 'Kosongkan Slot',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _slots.length;
    final available = _slots.where((s) => s['status'] == 'Tersedia').length;
    final occupied = _slots.where((s) => s['status'] == 'Terisi').length;
    final reserved = _slots.where((s) => s['status'] == 'Reserved').length;

    return Scaffold(
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
            Text('Denah & Status Slot', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Pemantauan Fisik Slot Parkir Real-Time', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Location Selector Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EEE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLocation,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1A1A18)),
                      items: ['Central Park Mall', 'Grand Indonesia', 'Pacific Place SCBD', 'Malioboro Mall'].map((loc) {
                        return DropdownMenuItem(
                          value: loc,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFF114177)),
                              const SizedBox(width: 8),
                              Text(loc, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedLocation = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Floor Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_floors.length, (idx) {
                      final isSelected = _selectedFloor == idx;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFloor = idx),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF114177) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? const Color(0xFF114177) : const Color(0xFFE4DFD5)),
                          ),
                          child: Text(
                            _floors[idx],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF45474A),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Overview counters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: [
                _buildMiniStat('Total', '$total', const Color(0xFF45474A), const Color(0xFFF1EEE7)),
                const SizedBox(width: 8),
                _buildMiniStat('Tersedia', '$available', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                const SizedBox(width: 8),
                _buildMiniStat('Terisi', '$occupied', const Color(0xFFD94B4B), const Color(0xFFFDE8E4)),
                const SizedBox(width: 8),
                _buildMiniStat('Reserved', '$reserved', const Color(0xFF114177), const Color(0xFFE3EEFF)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Slot Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
              ),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final slot = _slots[index];
                final color = _getStatusColor(slot['status']);
                final bg = _getStatusBg(slot['status']);

                return GestureDetector(
                  onTap: () => _openSlotDetail(slot),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4DFD5)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(slot['id'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                              child: Text(slot['status'], style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
                            ),
                          ],
                        ),
                        Text(slot['type'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (slot['plate'] != null)
                              Text(slot['plate'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)))
                            else
                              Text('Siap Dipakai', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF17A18A))),
                            Icon(Icons.info_outline, size: 16, color: const Color(0xFF76777B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}
