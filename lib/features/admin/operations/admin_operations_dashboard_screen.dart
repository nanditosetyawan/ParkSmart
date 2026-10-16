import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cs_kyc/admin_notifications_screen.dart';
import 'admin_locations_screen.dart';
import 'admin_slot_management_screen.dart';
import 'admin_active_users_screen.dart';
import 'admin_cities_screen.dart';
import 'manage_parking_screen.dart';
import '../../sitemap_screen.dart';

class AdminOperationsDashboardScreen extends StatelessWidget {
  const AdminOperationsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: Navigator.canPop(context)
              ? GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
                  ),
                )
              : null,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF114177),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_outlined, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF3B82F6), width: 0.8),
                        ),
                        child: Text(
                          'Operations',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text('Dashboard Operasional & Lapangan', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                ],
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.developer_board, size: 20, color: Color(0xFF1A1A18)),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_none, size: 20, color: Color(0xFF1A1A18)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFFD94B4B), shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Manajemen Fasilitas & Lapangan', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.sensors, size: 14, color: Color(0xFF114177)),
                const SizedBox(width: 6),
                Text('Status Sensor IoT & Okupansi Fisik Real-Time', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
              ],
            ),
            const SizedBox(height: 14),

            // Restricted Division Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Color(0xFF1D4ED8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Akses Terbatas: Hanya berwenang mengelola Fasilitas Fisik, Slot & Lapangan.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1D4ED8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KPI Khusus Operasional
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
                  child: _buildKpiCard('Slot Tersedia', '218/600', Icons.local_parking, const Color(0xFF114177), 'Tingkat Okupansi 63.6%'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
                  child: _buildKpiCard('Kendaraan Parkir', '382', Icons.directions_car, const Color(0xFF17A18A), 'Sensor Deteksi Aktif'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
                  child: _buildKpiCard('Overstay Alert', '3 Unit', Icons.warning_amber, const Color(0xFFD94B4B), 'Melebihi Toleransi Waktu'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen())),
                  child: _buildKpiCard('Lokasi Fasilitas', '12 Titik', Icons.location_on_outlined, const Color(0xFF45474A), 'Semua Kota Operasional'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Aksi Khusus Operasional
            Text('Aksi Lapangan & Fasilitas', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.add_business_outlined,
                  label: 'Kelola\nLokasi',
                  color: const Color(0xFF114177),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.grid_view,
                  label: 'Denah &\nSlot IoT',
                  color: const Color(0xFF17A18A),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.location_city,
                  label: 'Master\nKota',
                  color: const Color(0xFF45474A),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCitiesScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.speed,
                  label: 'Monitoring\nKendaraan',
                  color: const Color(0xFFE07A5F),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Menu Hub Operasional Terpadu
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageParkingScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE4DFD5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF114177).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.local_parking_outlined, color: Color(0xFF114177), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kelola Parkir Terpadu', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                Text('Kelola master slot, lantai & denah lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF76777B)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Peringatan Operasional Terkini
            Text('Peringatan Lapangan Terkini', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 12),
            _buildAlertCard(
              icon: Icons.warning_amber,
              color: const Color(0xFFD94B4B),
              bgColor: const Color(0xFFFDE8E4),
              title: '3 Kendaraan Overstay',
              desc: 'Central Park Mall · Melebihi batas toleransi tiket',
              time: '2 mnt lalu',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
            ),
            const SizedBox(height: 10),
            _buildAlertCard(
              icon: Icons.sensors_off_outlined,
              color: const Color(0xFFE07A5F),
              bgColor: const Color(0xFFFDECE7),
              title: 'Sensor Slot B2-014 Offline',
              desc: 'Grand Indonesia · Sensor ultrasonik tidak merespons',
              time: '12 mnt lalu',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
            ),
            const SizedBox(height: 24),

            // Status Lokasi Operasional
            Text('Kondisi Lokasi Fisik', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 12),
            _buildLocationCard(
              context,
              title: 'Central Park Mall',
              subtitle: 'Jakarta Barat · Basement B1-B3',
              status: 'Padat',
              statusColor: const Color(0xFFE07A5F),
              capacity: '240 / 300 terisi (80%)',
              isWarning: true,
            ),
            const SizedBox(height: 10),
            _buildLocationCard(
              context,
              title: 'Malioboro Mall',
              subtitle: 'Yogyakarta · Area Outdoor & B1',
              status: 'Normal',
              statusColor: const Color(0xFF17A18A),
              capacity: '102 / 200 terisi (51%)',
            ),
            const SizedBox(height: 80),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen()));
          },
          label: const Text('Dev Sitemap'),
          icon: const Icon(Icons.developer_board),
          backgroundColor: const Color(0xFF114177),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String sub) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 4),
          Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4DFD5)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18), height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({required IconData icon, required Color color, required Color bgColor, required String title, required String desc, required String time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4DFD5)),
        ),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 2),
                  Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                ],
              ),
            ),
            Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, {required String title, required String subtitle, required String status, required Color statusColor, required String capacity, bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              const SizedBox(height: 6),
              Text(capacity, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
