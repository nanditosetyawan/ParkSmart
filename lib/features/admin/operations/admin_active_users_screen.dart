import 'dart:async';
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/admin_active_users_backend.dart';
import 'backend/admin_operations_dashboard_backend.dart';
import 'manage_parking_screen.dart';
import '../../../core/services/parking_notification_service.dart';

class ActiveUsersScreen extends StatefulWidget {
  const ActiveUsersScreen({super.key});

  @override
  State<ActiveUsersScreen> createState() => _ActiveUsersScreenState();
}

class _ActiveUsersScreenState extends State<ActiveUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0; // 0=Semua, 1=Normal, 2=Overstay, 3=EV
  Timer? _liveTimer;

  List<Map<String, dynamic>> get _sessions => AdminActiveUsersBackend.instance.sessions;

  @override
  void initState() {
    super.initState();
    // 🛡️ Pastikan HP Admin tidak menerima atau membunyikan notif alarm darurat user
    ParkingNotificationService().stopRealtimeUrgentListener();
    ParkingNotificationService().cancelUrgentNotification();
    ParkingNotificationService.stopBackgroundMonitor();

    AdminActiveUsersBackend.instance.fetchActiveSessions();
    _liveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
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
    final rawCheckIn = session['raw_check_in_time'] as DateTime?;
    final relativeCheckIn = AdminActiveUsersBackend.formatRelativeCheckIn(rawCheckIn, multiline: false);
    final checkInStr = '${session['checkInFormatted']} ($relativeCheckIn)';

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
            const Divider(color: Color(0xFFF3F4F6), height: 24),
            _buildDetailRow(
              'Lokasi Parkir:',
              '${session['location']}',
              onTapValue: () {
                Navigator.pop(ctx);
                final locId = session['location_id']?.toString() ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageParkingScreen(
                      initialTabIndex: 1,
                      initialLocationId: locId.isNotEmpty ? locId : null,
                      initialLocationName: session['location'],
                    ),
                  ),
                );
              },
            ),
            _buildDetailRow('Slot & Lantai:', '${session['slot']} (${session['floor']})'),
            _buildDetailRow('Kendaraan:', session['vehicle']),
            _buildDetailRow('Jam Check-In:', checkInStr),
            _buildDetailRow('Durasi Berjalan:', session['duration']),
            _buildDetailRow('Akumulasi Biaya:', session['fee']),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final sm = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      final targetUserId = session['user_id']?.toString();
                      final plate = session['plate']?.toString() ?? 'Kendaraan';
                      final userName = session['user']?.toString() ?? 'Pengguna';

                      // Rekam ke database system_notifications untuk user pemilik sesi (notifikasi & suara darurat dikirim ke HP user)
                      await AdminOperationsDashboardBackend.instance.sendUrgentReminderNotification(
                        userId: targetUserId,
                        plateNumber: plate,
                        locationName: session['location']?.toString(),
                      );

                      sm.showSnackBar(
                        SnackBar(
                          content: Text('Notifikasi darurat peringatan berhasil dikirimkan ke $userName!'),
                          backgroundColor: const Color(0xFF17A18A),
                        ),
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
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final sm = ScaffoldMessenger.of(context);
                      await AdminActiveUsersBackend.instance.forceCheckout(session['id'].toString());
                      if (!mounted) return;
                      nav.pop();
                      sm.showSnackBar(
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

  Widget _buildDetailRow(String label, String value, {VoidCallback? onTapValue, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTapValue,
              child: Text(
                value,
                textAlign: TextAlign.end,
                softWrap: true,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? (onTapValue != null ? const Color(0xFF114177) : const Color(0xFF1A1A18)),
                  decoration: onTapValue != null ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminActiveUsersBackend.instance,
      builder: (context, _) {
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
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard('EV Charging', '$evCount', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                  ],
                ),
                const SizedBox(height: 14),

                // Search box (Google-style pill)
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
                            hintText: 'Cari plat nomor, nama user, lokasi...',
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
                                      Text('${item['vehicle']} · ${item['slot']} (${item['floor']})', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
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
                                    child: Text('EV', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                                  ),
                              ],
                            ),
                            const Divider(color: Color(0xFFF3F4F6), height: 20),
                            Builder(
                              builder: (context) {
                                final rawCheckIn = item['raw_check_in_time'] as DateTime?;
                                final relativeCheckIn = AdminActiveUsersBackend.formatRelativeCheckIn(rawCheckIn, multiline: true);

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Jam Masuk', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                          const SizedBox(height: 2),
                                          Text(
                                            relativeCheckIn,
                                            softWrap: true,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1A1A18),
                                              height: 1.25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Durasi', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                          const SizedBox(height: 2),
                                          Text(
                                            item['duration'] ?? '-',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1A1A18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Biaya', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                          const SizedBox(height: 2),
                                          Text(
                                            item['fee'] ?? '-',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF17A18A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      flex: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          final locId = item['location_id']?.toString() ?? '';
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ManageParkingScreen(
                                                initialTabIndex: 1, // Tab Denah
                                                initialLocationId: locId.isNotEmpty ? locId : null,
                                                initialLocationName: item['location'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Lokasi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                                const SizedBox(width: 2),
                                                const Icon(Icons.arrow_outward_rounded, size: 10, color: Color(0xFF114177)),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item['location'] ?? 'Atur Denah',
                                              softWrap: true,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF114177),
                                                decoration: TextDecoration.underline,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _showActionModal(item),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Center(
                                  child: Text(
                                    'Aksi',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
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

  Widget _buildFilterChip(String label, int index, {bool isWarning = false}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isWarning ? const Color(0xFFD94B4B) : const Color(0xFF114177))
              : const Color(0xFFF3F4F6),
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
