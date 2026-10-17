import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_notifications_screen.dart';
import 'admin_kyc_screen.dart';
import 'admin_customer_profiles_screen.dart';
import 'manage_users_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_arcade_screen.dart';
import 'admin_kyc_detail_modal.dart';

class AdminCsKycDashboardScreen extends StatefulWidget {
  const AdminCsKycDashboardScreen({super.key});

  @override
  State<AdminCsKycDashboardScreen> createState() => _AdminCsKycDashboardScreenState();
}

class _AdminCsKycDashboardScreenState extends State<AdminCsKycDashboardScreen> {
  int _currentTabIndex = 0;
  String _selectedKycFilter = 'Menunggu';

  final List<Map<String, dynamic>> _kycPendingList = [
    {
      'id': 'KYC-001',
      'name': 'Sarah Wijaya',
      'nik': '3174025508990001',
      'submittedAt': '5 mnt lalu',
      'status': 'Menunggu',
      'city': 'Jakarta Selatan, DKI',
      'dob': '12 Mei 1999',
      'address': 'Jl. Kemang Raya No. 45, Bangka',
    },
    {
      'id': 'KYC-002',
      'name': 'Dimas Pratama',
      'nik': '3275031804960004',
      'submittedAt': '14 mnt lalu',
      'status': 'Menunggu',
      'city': 'Bekasi Barat, Jabar',
      'dob': '18 April 1996',
      'address': 'Jl. Ahmad Yani No. 12',
    },
    {
      'id': 'KYC-003',
      'name': 'Dewi Anggraini',
      'nik': '3578014509010002',
      'submittedAt': '30 mnt lalu',
      'status': 'Menunggu',
      'city': 'Surabaya, Jatim',
      'dob': '25 September 2001',
      'address': 'Jl. Darmo Indah No. 8',
    },
  ];

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
          automaticallyImplyLeading: false,
          titleSpacing: 16,
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
                  Text(
                    'Dashboard Layanan & Verifikasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                  ),
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
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF1A1A18)),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildTabOverview(context),
            _buildTabKyc(context),
            _buildTabCrm(context),
          ],
        ),
        // Navigasi Bar Tab di Bawah Layar (Menempel sisi bawah, tidak melayang)
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE4DFD5), width: 1)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Layanan CS',
                    index: 0,
                    activeColor: const Color(0xFF0D9488),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.badge_outlined,
                    label: 'Verifikasi KYC',
                    index: 1,
                    activeColor: const Color(0xFF0D9488),
                  ),
                  _buildBottomNavItem(
                    icon: Icons.people_outline_rounded,
                    label: 'Pelanggan & CRM',
                    index: 2,
                    activeColor: const Color(0xFF0D9488),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTabIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : const Color(0xFF76777B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF76777B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 0: LAYANAN CS & OVERVIEW ====================
  Widget _buildTabOverview(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Layanan Pelanggan & Verifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.verified_user, size: 14, color: Color(0xFF0D9488)),
            const SizedBox(width: 6),
            Text('Verifikasi KYC, Manajemen Pengguna & CRM', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        const SizedBox(height: 12),

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
        const SizedBox(height: 14),

        // KPI Khusus CS & KYC
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentTabIndex = 1),
                child: _buildKpiCard('Antrean KYC', '5 Berkas', Icons.badge_outlined, const Color(0xFFE07A5F), 'Menunggu Review'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen())),
                child: _buildKpiCard('Feedback Rating', '4.8 ★', Icons.star_rate_rounded, const Color(0xFFD97706), '18 Ulasan Baru'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                child: _buildKpiCard('Customer Aktif', '1.240 User', Icons.people_outline, const Color(0xFF114177), 'Terverifikasi'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArcadeAdminScreen())),
                child: _buildKpiCard('Hadiah Arcade', '64 Ditukar', Icons.card_giftcard, const Color(0xFF17A18A), 'Klaim Poin'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Aksi Cepat CS & KYC
        Text('Aksi Layanan Cepat', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildQuickAction(
              context,
              icon: Icons.verified_user_outlined,
              label: 'Verifikasi\nKTP (KYC)',
              color: const Color(0xFF0D9488),
              onTap: () => setState(() => _currentTabIndex = 1),
            ),
            const SizedBox(width: 8),
            _buildQuickAction(
              context,
              icon: Icons.person_search,
              label: 'Profil User\n(CRM)',
              color: const Color(0xFF114177),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen())),
            ),
            const SizedBox(width: 8),
            _buildQuickAction(
              context,
              icon: Icons.manage_accounts_outlined,
              label: 'Kelola\nStatus User',
              color: const Color(0xFFE07A5F),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
            ),
            const SizedBox(width: 8),
            _buildQuickAction(
              context,
              icon: Icons.rate_review_outlined,
              label: 'Ulasan &\nFeedback',
              color: const Color(0xFFD97706),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen())),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Secondary Quick Actions
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4DFD5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign_outlined, color: Color(0xFF114177), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Broadcast Masal', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF76777B)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4DFD5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videogame_asset_outlined, color: Color(0xFF0D9488), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Arcade & Hadiah', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF76777B)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Antrean Verifikasi KTP Terkini
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Antrean KYC Menunggu Aksi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            TextButton(
              onPressed: () => setState(() => _currentTabIndex = 1),
              child: Text('Lihat Semua', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0D9488))),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._kycPendingList.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildKycQueueCard(
            name: item['name'] as String,
            nik: item['nik'] as String,
            time: item['submittedAt'] as String,
            status: item['status'] as String,
            onTap: () => _openKycModal(item),
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  // ==================== TAB 1: VERIFIKASI KYC ====================
  Widget _buildTabKyc(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verifikasi Identitas e-KTP', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                Text('Pemeriksaan berkas foto e-KTP dan selfie pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 20, color: Color(0xFF0D9488)),
              tooltip: 'Buka Halaman KYC Lengkap',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycScreen())),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter status
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Menunggu', 'Semua Berkas', 'Disetujui', 'Ditolak'].map((f) {
              final isSel = _selectedKycFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(f),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _selectedKycFilter = f);
                  },
                  selectedColor: const Color(0xFF0D9488),
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : const Color(0xFF45474A),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isSel ? const Color(0xFF0D9488) : const Color(0xFFE4DFD5)),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // List Kartu KYC dengan Visual Kaya & Non-Monoton
        ..._kycPendingList.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (item['name'] as String)[0].toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'] as String,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.hourglass_top_rounded, size: 11, color: Color(0xFFEA580C)),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Menunggu',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFFEA580C)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'NIK: ${item['nik']}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF3F3F46)),
                            ),
                            const SizedBox(height: 4),
                            // Lokasi & Tanggal Lahir
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF71717A)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${item['city'] ?? ''}${item['dob'] != null ? ' • ${item['dob']}' : ''}',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF71717A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Waktu Pengajuan di bawah lokasi
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF71717A)),
                                const SizedBox(width: 4),
                                Text(
                                  item['submittedAt'] as String,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w500, color: const Color(0xFF71717A)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),
                const Divider(height: 1, color: Color(0xFFF1EEE7)),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () => _openKycModal(item),
                          icon: const Icon(Icons.visibility_outlined, size: 14, color: Colors.white),
                          label: Text(
                            'Lihat & Periksa 2 Foto Berkas',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF114177),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 34,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final reason = await showKycRejectReasonDialog(
                                    context,
                                    applicantName: item['name'] ?? 'Pengguna',
                                  );
                                  if (reason != null && reason.isNotEmpty) {
                                    _handleKycAction(index, false, reason);
                                  }
                                },
                                icon: const Icon(Icons.close_rounded, size: 13, color: Color(0xFFDC2626)),
                                label: Text(
                                  'Tolak',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626)),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFDC2626)),
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 34,
                              child: ElevatedButton.icon(
                                onPressed: () => _handleKycAction(index, true),
                                icon: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                                label: Text(
                                  'Terima & Setujui',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D9488),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  // ==================== TAB 2: CUSTOMER & CRM ====================
  Widget _buildTabCrm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Pusat Pengguna & Hubungan Pelanggan (CRM)', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        Text('Kelola database customer, ulasan rating, dan program poin arcade', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        const SizedBox(height: 16),

        _buildCrmHubCard(
          icon: Icons.person_search_rounded,
          color: const Color(0xFF114177),
          title: 'Database Profil Pengguna (CRM)',
          subtitle: 'Histori transaksi, status verifikasi akun, dan aktivitas booking',
          actionText: 'Buka Profil CRM',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCustomerProfilesScreen())),
        ),
        const SizedBox(height: 10),

        _buildCrmHubCard(
          icon: Icons.manage_accounts_rounded,
          color: const Color(0xFFE07A5F),
          title: 'Manajemen Status Akun User',
          subtitle: 'Blokir akun bermasalah, reset PIN keamanan, dan verifikasi manual',
          actionText: 'Kelola Akun',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
        ),
        const SizedBox(height: 10),

        _buildCrmHubCard(
          icon: Icons.rate_review_rounded,
          color: const Color(0xFFD97706),
          title: 'Ulasan & Feedback Pelanggan',
          subtitle: 'Rating bintang, saran perbaikan fasilitas, dan tanggapan customer',
          actionText: 'Kelola Ulasan',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackAdminScreen())),
        ),
        const SizedBox(height: 10),

        _buildCrmHubCard(
          icon: Icons.videogame_asset_rounded,
          color: const Color(0xFF0D9488),
          title: 'Program Hadiah Arcade & Poin',
          subtitle: 'Klaim hadiah pengguna, voucher parkir diskon, dan saldo reward',
          actionText: 'Kelola Arcade',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArcadeAdminScreen())),
        ),
        const SizedBox(height: 10),

        _buildCrmHubCard(
          icon: Icons.campaign_rounded,
          color: const Color(0xFF6D28D9),
          title: 'Pusat Broadcast Pengumuman',
          subtitle: 'Kirim notifikasi pesan push ke seluruh aplikasi pelanggan',
          actionText: 'Kirim Broadcast',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCrmHubCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4DFD5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF76777B)),
          ],
        ),
      ),
    );
  }

  void _openKycModal(Map<String, dynamic> item) {
    showKycDetailModal(
      context,
      kyc: item,
      onAccept: () {
        final idx = _kycPendingList.indexOf(item);
        if (idx != -1) {
          _handleKycAction(idx, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pendaftaran KYC ${item['name']} disetujui.'),
              backgroundColor: const Color(0xFF0D9488),
            ),
          );
        }
      },
      onRejectWithReason: (reason) {
        final idx = _kycPendingList.indexOf(item);
        if (idx != -1) {
          _handleKycAction(idx, false, reason);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pendaftaran KYC ${item['name']} ditolak. Alasan: $reason'),
              backgroundColor: const Color(0xFFD94B4B),
            ),
          );
        }
      },
    );
  }

  void _handleKycAction(int index, bool accepted, [String? rejectReason]) {
    if (index >= _kycPendingList.length) return;
    final item = _kycPendingList[index];
    setState(() {
      _kycPendingList.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          accepted
              ? 'Pendaftaran KYC ${item['name']} telah disetujui.'
              : 'Pendaftaran KYC ${item['name']} telah ditolak. Alasan: ${rejectReason ?? "Tidak memenuhi syarat"}',
        ),
        backgroundColor: accepted ? const Color(0xFF0D9488) : const Color(0xFFD94B4B),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4DFD5)),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18), height: 1.2),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4DFD5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: Color(0xFFE07A5F), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  Text('NIK: $nik · $time', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFE07A5F))),
            ),
          ],
        ),
      ),
    );
  }
}
