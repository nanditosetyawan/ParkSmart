import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_notifications_screen.dart';
import 'admin_kyc_screen.dart';
import 'admin_customer_profiles_screen.dart';
import 'manage_users_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_arcade_screen.dart';
import '../../sitemap_screen.dart';

class AdminCsKycDashboardScreen extends StatelessWidget {
  const AdminCsKycDashboardScreen({super.key});

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
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.support_agent, size: 18, color: Colors.white),
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
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF14B8A6), width: 0.8),
                        ),
                        child: Text(
                          'CS & KYC',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text('Dashboard Layanan & Verifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
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
                child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF1A1A18)),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Layanan Pelanggan & Verifikasi Identitas', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.verified_user, size: 14, color: Color(0xFF0D9488)),
                const SizedBox(width: 6),
                Text('Verifikasi KYC, Manajemen Pengguna & Dukungan Pelanggan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
              ],
            ),
            const SizedBox(height: 14),

            // Restricted Division Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Color(0xFF0F766E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Akses Terbatas: Hanya berwenang mengelola Layanan Pengguna & Verifikasi KYC.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KPI Khusus CS & KYC
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
                  child: _buildKpiCard('Antrean KYC KTP', '5 Berkas', Icons.badge_outlined, const Color(0xFFE07A5F), 'Menunggu Review'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen())),
                  child: _buildKpiCard('Feedback Rating', '4.8 ★', Icons.star_rate_rounded, const Color(0xFFD97706), '18 Ulasan Baru'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                  child: _buildKpiCard('Customer Aktif', '1.240 User', Icons.people_outline, const Color(0xFF114177), 'Terdaftar & Terverifikasi'),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArcadeAdminScreen())),
                  child: _buildKpiCard('Hadiah Arcade', '64 Ditukar', Icons.card_giftcard, const Color(0xFF17A18A), 'Klaim Poin Selesai'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Aksi Khusus CS & KYC
            Text('Aksi Layanan & Verifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.verified_user_outlined,
                  label: 'Verifikasi\nKTP (KYC)',
                  color: const Color(0xFF0D9488),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.person_search,
                  label: 'Profil User\n(CRM)',
                  color: const Color(0xFF114177),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.manage_accounts_outlined,
                  label: 'Kelola\nStatus User',
                  color: const Color(0xFFE07A5F),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.rate_review_outlined,
                  label: 'Ulasan &\nFeedback',
                  color: const Color(0xFFD97706),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen())),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Secondary Quick Actions
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4DFD5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign_outlined, color: Color(0xFF114177), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Broadcast Notifikasi Masal', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF76777B)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArcadeAdminScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4DFD5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.videogame_asset_outlined, color: Color(0xFF0D9488), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Arcade Poin & Hadiah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF76777B)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Antrean Verifikasi KTP Terkini
            Text('Antrean Dokumen KYC Menunggu Aksi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 12),
            _buildKycQueueCard(
              name: 'Sarah Wijaya',
              nik: '3174**********01',
              time: '5 mnt lalu',
              status: 'Menunggu Review',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
            ),
            const SizedBox(height: 10),
            _buildKycQueueCard(
              name: 'Dimas Pratama',
              nik: '3275**********04',
              time: '14 mnt lalu',
              status: 'Menunggu Review',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
            ),
            const SizedBox(height: 10),
            _buildKycQueueCard(
              name: 'Dewi Anggraini',
              nik: '3578**********02',
              time: '30 mnt lalu',
              status: 'Menunggu Review',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
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
          backgroundColor: const Color(0xFF0D9488),
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
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
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

  Widget _buildKycQueueCard({required String name, required String nik, required String time, required String status, required VoidCallback onTap}) {
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: Color(0xFFE07A5F), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 2),
                  Text('NIK: $nik · $time', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFE07A5F))),
            ),
          ],
        ),
      ),
    );
  }
}
