import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveUsersScreen extends StatefulWidget {
  const ActiveUsersScreen({super.key});

  @override
  State<ActiveUsersScreen> createState() => _ActiveUsersScreenState();
}

class _ActiveUsersScreenState extends State<ActiveUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0; // 0=Semua, 1=Normal, 2=Overstay, 3=EV

  final List<Map<String, dynamic>> _sessions = [
    {
      'id': 'SES-9901',
      'plate': 'B 1234 SKP',
      'user': 'Nanda Setiawan',
      'phone': '+62 812-3456-7890',
      'type': 'Mobil',
      'vehicle': 'Honda CR-V Hitam',
      'location': 'Central Park Mall',
      'slot': 'B2 / A-01',
      'checkIn': '10:30 WIB',
      'duration': '2j 15m',
      'fee': 'Rp 13.000',
      'isOverstay': false,
      'isEv': false,
    },
    {
      'id': 'SES-9902',
      'plate': 'B 5532 PLM',
      'user': 'Rafi Maulana',
      'phone': '+62 856-7890-1234',
      'type': 'Mobil',
      'vehicle': 'Toyota Fortuner Putih',
      'location': 'Central Park Mall',
      'slot': 'B2 / C-01',
      'checkIn': '08:00 WIB',
      'duration': '4j 45m',
      'fee': 'Rp 29.000',
      'isOverstay': true,
      'overstayDuration': '45 mnt',
      'isEv': false,
    },
    {
      'id': 'SES-9903',
      'plate': 'B 1111 ION',
      'user': 'Dewi Lestari',
      'phone': '+62 813-9988-7766',
      'type': 'EV Mobil',
      'vehicle': 'Hyundai Ioniq 5',
      'location': 'Central Park Mall',
      'slot': 'B2 / B-01 (EV Fast)',
      'checkIn': '11:15 WIB',
      'duration': '1j 30m',
      'fee': 'Rp 22.500',
      'isOverstay': false,
      'isEv': true,
      'battery': '85%',
    },
    {
      'id': 'SES-9904',
      'plate': 'AB 8899 DTO',
      'user': 'Agus Pratama',
      'phone': '+62 878-1122-3344',
      'type': 'Motor',
      'vehicle': 'Yamaha NMAX Hitam',
      'location': 'Malioboro Mall',
      'slot': 'Outdoor / M-12',
      'checkIn': '11:45 WIB',
      'duration': '1j 00m',
      'fee': 'Rp 2.000',
      'isOverstay': false,
      'isEv': false,
    },
    {
      'id': 'SES-9905',
      'plate': 'D 4412 XYZ',
      'user': 'Siti Rahayu',
      'phone': '+62 821-4455-6677',
      'type': 'Mobil',
      'vehicle': 'Mazda CX-5 Merah',
      'location': 'Grand Indonesia',
      'slot': 'B1 / E-04',
      'checkIn': '09:10 WIB',
      'duration': '3j 35m',
      'fee': 'Rp 21.000',
      'isOverstay': true,
      'overstayDuration': '35 mnt',
      'isEv': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSessions {
    return _sessions.where((s) {
      final q = _searchController.text.toLowerCase();
      final matchesSearch = s['plate'].toString().toLowerCase().contains(q) ||
          s['user'].toString().toLowerCase().contains(q) ||
          s['location'].toString().toLowerCase().contains(q);

      if (!matchesSearch) return false;

      if (_selectedFilter == 1) return s['isOverstay'] == false && s['isEv'] == false;
      if (_selectedFilter == 2) return s['isOverstay'] == true;
      if (_selectedFilter == 3) return s['isEv'] == true;
      return true;
    }).toList();
  }

  void _showActionModal(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session['plate'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    Text('${session['user']} · ${session['phone']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: session['isOverstay'] ? const Color(0xFFFDE8E4) : const Color(0xFFD1F2EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session['isOverstay'] ? 'Overstay' : 'Normal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: session['isOverstay'] ? const Color(0xFFD94B4B) : const Color(0xFF17A18A),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Color(0xFFF1EEE7), height: 24),
            _buildDetailRow('Lokasi & Slot:', '${session['location']} (${session['slot']})'),
            _buildDetailRow('Kendaraan:', session['vehicle']),
            _buildDetailRow('Jam Check-In:', session['checkIn']),
            _buildDetailRow('Durasi Berjalan:', session['duration']),
            _buildDetailRow('Akumulasi Biaya:', session['fee']),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Notifikasi peringatan dikirimkan ke ${session['user']}!')),
                      );
                    },
                    icon: const Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFF114177)),
                    label: Text('Kirim Pengingat', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE4DFD5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _sessions.removeWhere((s) => s['id'] == session['id']);
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF17A18A),
                          content: Text('Kendaraan ${session['plate']} berhasil check-out manual!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.exit_to_app, size: 16, color: Colors.white),
                    label: Text('Force Check-Out', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD94B4B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overstayCount = _sessions.where((s) => s['isOverstay'] == true).length;
    final evCount = _sessions.where((s) => s['isEv'] == true).length;

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
            Text('Pengemudi di Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Monitoring Kendaraan & Sesi Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
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
                    _buildStatCard('Total Parkir', '${_sessions.length}', const Color(0xFF114177), const Color(0xFFE3EEFF)),
                    const SizedBox(width: 10),
                    _buildStatCard('Overstay', '$overstayCount', const Color(0xFFD94B4B), const Color(0xFFFDE8E4)),
                    const SizedBox(width: 10),
                    _buildStatCard('EV Charging', '$evCount', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
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
                            hintText: 'Cari plat nomor, nama user, lokasi...',
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

          // Filter tabs
          Container(
            height: 48,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                _buildFilterChip('Semua (${_sessions.length})', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Normal', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Overstay ($overstayCount)', 2, isWarning: true),
                const SizedBox(width: 8),
                _buildFilterChip('EV Charging ($evCount)', 3),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // List Sessions
          Expanded(
            child: _filteredSessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car_outlined, size: 48, color: Color(0xFF76777B)),
                        const SizedBox(height: 12),
                        Text('Tidak ada sesi kendaraan aktif yang cocok', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredSessions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredSessions[index];
                      final bool isOverstay = item['isOverstay'] as bool;
                      final bool isEv = item['isEv'] as bool;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isOverstay ? const Color(0xFFF9D8D3) : const Color(0xFFE4DFD5)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1D1F),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['plate'],
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['user'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                      const SizedBox(height: 2),
                                      Text('${item['vehicle']} · ${item['slot']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                    ],
                                  ),
                                ),
                                if (isOverstay)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(6)),
                                    child: Text('Overstay ${item['overstayDuration']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                                  )
                                else if (isEv)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFD1F2EB), borderRadius: BorderRadius.circular(6)),
                                    child: Text('EV ${item['battery']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                                  ),
                              ],
                            ),
                            const Divider(color: Color(0xFFF1EEE7), height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Durasi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                    const SizedBox(height: 2),
                                    Text(item['duration'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Biaya', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                    const SizedBox(height: 2),
                                    Text(item['fee'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Gedung', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                    const SizedBox(height: 2),
                                    Text(item['location'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => _showActionModal(item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(8)),
                                    child: Text('Aksi', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                  ),
                                ),
                              ],
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

  Widget _buildFilterChip(String label, int index, {bool isWarning = false}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isWarning ? const Color(0xFFD94B4B) : const Color(0xFF114177))
              : const Color(0xFFF1EEE7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : (isWarning ? const Color(0xFFD94B4B) : const Color(0xFF45474A)),
            ),
          ),
        ),
      ),
    );
  }
}
