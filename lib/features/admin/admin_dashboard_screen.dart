import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_notifications_screen.dart';
import 'admin_locations_screen.dart';
import 'admin_slot_management_screen.dart';
import 'admin_pricing_screen.dart';
import 'admin_active_users_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_arcade_screen.dart';
import 'admin_kyc_screen.dart';
import 'admin_wallet_screen.dart';
import 'admin_cities_screen.dart';
import 'admin_user_management_screen.dart';
import 'admin_customer_profiles_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_transactions_screen.dart';
import 'admin_ai_config_screen.dart';
import 'admin_app_settings_screen.dart';
import 'manage_parking_screen.dart';
import 'manage_users_screen.dart';
import 'revenue_screen.dart';

typedef DashboardScreen = AdminDashboardScreen;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

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
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
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
                color: const Color(0xFF1C1D1F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_parking, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                Text('Panel Admin', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              ],
            ),
          ],
        ),
        actions: [
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
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1C1D1F),
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Selamat Datang, Admin', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF76777B)),
              const SizedBox(width: 6),
              Text('Operasional Real-Time ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 20),

          // KPI Cards
          Row(
            children: [
              _buildKpiCard('Total Omzet', 'Rp 4.2 Jt', Icons.trending_up, const Color(0xFF17A18A), 'Hari ini (+12%)'),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
                child: _buildKpiCardDirect('Kendaraan Aktif', '382', Icons.directions_car, const Color(0xFF114177), 'Sedang Parkir'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
                child: _buildKpiCardDirect('Slot Tersedia', '218/600', Icons.local_parking, const Color(0xFF45474A), 'Semua Lokasi'),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveUsersScreen())),
                child: _buildKpiCardDirect('Overstay Alert', '3', Icons.warning_amber, const Color(0xFFD94B4B), 'Perlu Aksi'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Aksi Utama
          Text('Aksi Cepat & Layanan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
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
                icon: Icons.account_balance_wallet,
                label: 'Injeksi\nSaldo',
                color: const Color(0xFF17A18A),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
              ),
              const SizedBox(width: 10),
              _buildQuickAction(
                context,
                icon: Icons.verified_user_outlined,
                label: 'Verifikasi\nKTP',
                color: const Color(0xFFE07A5F),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
              ),
              const SizedBox(width: 10),
              _buildQuickAction(
                context,
                icon: Icons.location_city,
                label: 'Master\nKota',
                color: const Color(0xFF45474A),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCitiesScreen())),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Baris Menu Sekunder
          Row(
            children: [
              _buildSecondaryAction(
                context,
                icon: Icons.grid_view,
                label: 'Denah & Slot',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
              ),
              const SizedBox(width: 10),
              _buildSecondaryAction(
                context,
                icon: Icons.price_change_outlined,
                label: 'Atur Tarif',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingScreen())),
              ),
              const SizedBox(width: 10),
              _buildSecondaryAction(
                context,
                icon: Icons.rate_review_outlined,
                label: 'Feedback',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen())),
              ),
              const SizedBox(width: 10),
              _buildSecondaryAction(
                context,
                icon: Icons.videogame_asset_outlined,
                label: 'Arcade Poin',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArcadeAdminScreen())),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Baris Menu Baru (P1 Features)
          Row(
            children: [
              _buildSecondaryAction(
                context,
                icon: Icons.people_outline,
                label: 'Kelola Admin',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserManagementScreen())),
              ),
              const SizedBox(width: 10),
              _buildSecondaryAction(
                context,
                icon: Icons.person_search,
                label: 'Profil User',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen())),
              ),
              const SizedBox(width: 10),
              _buildSecondaryAction(
                context,
                icon: Icons.calendar_month,
                label: 'Booking',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookingsScreen())),
              ),
              const SizedBox(width: 10),
              _buildSecondaryAction(
                context,
                icon: Icons.receipt_long,
                label: 'Transaksi',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTransactionsScreen())),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Baris Menu P2 (AI Config & App Settings)
          Row(
            children: [
              _buildSecondaryAction(
                context,
                icon: Icons.smart_toy_outlined,
                label: 'Konfigurasi AI',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAiConfigScreen())),
              ),
              const SizedBox(width: 10),
              _buildSecondaryAction(
                context,
                icon: Icons.settings_outlined,
                label: 'Pengaturan App',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAppSettingsScreen())),
              ),
            ],
                      ),
                      const SizedBox(height: 24),

                      // Baris Menu P3 (Consolidated Management)
                      Row(
                        children: [
                          _buildSecondaryAction(
                            context,
                            icon: Icons.local_parking_outlined,
                            label: 'Kelola Parkir',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageParkingScreen())),
                          ),
                          const SizedBox(width: 10),
                          _buildSecondaryAction(
                            context,
                            icon: Icons.group_outlined,
                            label: 'Kelola User',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                          ),
                          const SizedBox(width: 10),
                          _buildSecondaryAction(
                            context,
                            icon: Icons.analytics_outlined,
                            label: 'Pendapatan',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Peringatan Terbaru
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Peringatan & Aktivitas Terkini', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())),
                child: Text('Lihat Semua', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
              ),
            ],
          ),
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
            icon: Icons.person_add_alt_1,
            color: const Color(0xFFE07A5F),
            bgColor: const Color(0xFFFDECE7),
            title: '5 KTP Menunggu Verifikasi',
            desc: 'User baru mengunggah dokumen KYC identitas',
            time: '15 mnt lalu',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
          ),
          const SizedBox(height: 10),
          _buildAlertCard(
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF17A18A),
            bgColor: const Color(0xFFD1F2EB),
            title: 'Top-up Saldo Injeksi Sukses',
            desc: 'Admin menginjeksi Rp 500.000 ke akun Nanda S.',
            time: '1 jam lalu',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWalletScreen())),
          ),
          const SizedBox(height: 24),

          // Performa Lokasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Performa Lokasi Utama', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen())),
                child: Text('Semua Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            context,
            title: 'Central Park Mall',
            subtitle: 'Jakarta Barat · Basement B1-B3',
            status: 'Aktif Normal',
            statusColor: const Color(0xFF17A18A),
            capacity: '240 / 300 terisi',
            revenue: 'Rp 1.8 Jt',
            isWarning: true,
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            context,
            title: 'Malioboro Mall',
            subtitle: 'Yogyakarta · Area Outdoor & B1',
            status: 'Aktif Normal',
            statusColor: const Color(0xFF17A18A),
            capacity: '102 / 200 terisi',
            revenue: 'Rp 960 Rb',
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            context,
            title: 'Grand Indonesia',
            subtitle: 'Jakarta Pusat · East & West Mall',
            status: 'Padat',
            statusColor: const Color(0xFFE07A5F),
            capacity: '415 / 450 terisi',
            revenue: 'Rp 2.1 Jt',
          ),
          const SizedBox(height: 20),
        ],
      ),
    ));
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF76777B)))),
                Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCardDirect(String title, String value, IconData icon, Color color, String sub) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF76777B)))),
              Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 4),
          Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE4DFD5))),
          child: Column(
            children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF114177)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE4DFD5))),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: color)),
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
            const SizedBox(width: 8),
            Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required String capacity,
    required String revenue,
    bool isWarning = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isWarning ? const Color(0xFFFDE8E4) : const Color(0xFFE4DFD5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.local_parking, color: Color(0xFF114177)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 6, color: statusColor),
                                const SizedBox(width: 4),
                                Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ],
                            ),
                          ),
                          if (isWarning) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(4)),
                              child: Text('Hampir Penuh', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1EEE7), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kapasitas Slot', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                      Text(capacity, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pendapatan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                      Text(revenue, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SlotManagementScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(12)),
                    child: Text('Kelola', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
