import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - consolidated from admin_user_management_screen, admin_customer_profiles_screen, admin_kyc_screen, admin_wallet_screen
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'usr_1',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@email.com',
      'phone': '+62 812-3456-7890',
      'avatar': null,
      'status': 'Aktif',
      'kycStatus': 'Terverifikasi',
      'kycSubmittedAt': '2024-11-15',
      'role': 'Pelanggan',
      'registeredAt': '2024-10-01',
      'lastActive': '2024-12-18 14:30',
      'totalSessions': 24,
      'totalSpent': 1250000,
      'walletBalance': 150000,
      'vehicles': [
        {'plate': 'B 1234 ABC', 'type': 'Mobil', 'brand': 'Toyota', 'model': 'Avanza', 'color': 'Silver', 'isDefault': true},
        {'plate': 'B 5678 DEF', 'type': 'Motor', 'brand': 'Honda', 'model': 'Beat', 'color': 'Merah', 'isDefault': false},
      ],
      'recentSessions': [
        {'location': 'Central Park Mall', 'date': '2024-12-18', 'duration': '2j 30m', 'cost': 45000, 'status': 'Selesai'},
        {'location': 'Malioboro Mall', 'date': '2024-12-15', 'duration': '1j 15m', 'cost': 20000, 'status': 'Selesai'},
        {'location': 'Grand Indonesia', 'date': '2024-12-10', 'duration': '3j 0m', 'cost': 75000, 'status': 'Selesai'},
      ],
      'recentTransactions': [
        {'date': '2024-12-18', 'type': 'Parkir', 'amount': -45000, 'status': 'Berhasil', 'ref': 'TXN-20241218-001'},
        {'date': '2024-12-15', 'type': 'Parkir', 'amount': -20000, 'status': 'Berhasil', 'ref': 'TXN-20241215-002'},
        {'date': '2024-12-10', 'type': 'Top Up', 'amount': 200000, 'status': 'Berhasil', 'ref': 'TXN-20241210-003'},
      ],
      'kycDocuments': [
        {'type': 'KTP', 'status': 'Terverifikasi', 'imageUrl': null, 'verifiedAt': '2024-11-16'},
        {'type': 'SIM', 'status': 'Terverifikasi', 'imageUrl': null, 'verifiedAt': '2024-11-16'},
        {'type': 'STNK', 'status': 'Terverifikasi', 'imageUrl': null, 'verifiedAt': '2024-11-17'},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': false,
        'notifSystem': true,
        'language': 'id',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'usr_2',
      'name': 'Siti Rahayu',
      'email': 'siti.rahayu@email.com',
      'phone': '+62 813-9876-5432',
      'avatar': null,
      'status': 'Aktif',
      'kycStatus': 'Menunggu Verifikasi',
      'kycSubmittedAt': '2024-12-10',
      'role': 'Pelanggan',
      'registeredAt': '2024-11-20',
      'lastActive': '2024-12-19 09:15',
      'totalSessions': 8,
      'totalSpent': 380000,
      'walletBalance': 50000,
      'vehicles': [
        {'plate': 'AB 9012 CD', 'type': 'Mobil', 'brand': 'Mitsubishi', 'model': 'Xpander', 'color': 'Putih', 'isDefault': true},
      ],
      'recentSessions': [
        {'location': 'Grand Indonesia', 'date': '2024-12-19', 'duration': '1j 45m', 'cost': 35000, 'status': 'Aktif'},
        {'location': 'Central Park Mall', 'date': '2024-12-12', 'duration': '2j 0m', 'cost': 40000, 'status': 'Selesai'},
      ],
      'recentTransactions': [
        {'date': '2024-12-19', 'type': 'Parkir (Hold)', 'amount': -35000, 'status': 'Pending', 'ref': 'TXN-20241219-001'},
        {'date': '2024-12-12', 'type': 'Parkir', 'amount': -40000, 'status': 'Berhasil', 'ref': 'TXN-20241212-002'},
        {'date': '2024-12-01', 'type': 'Top Up', 'amount': 100000, 'status': 'Berhasil', 'ref': 'TXN-20241201-003'},
      ],
      'kycDocuments': [
        {'type': 'KTP', 'status': 'Diajukan', 'imageUrl': null, 'verifiedAt': null},
        {'type': 'SIM', 'status': 'Diajukan', 'imageUrl': null, 'verifiedAt': null},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': true,
        'notifSystem': true,
        'language': 'id',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'usr_3',
      'name': 'Ahmad Fauzi',
      'email': 'ahmad.fauzi@email.com',
      'phone': '+62 821-5555-7777',
      'avatar': null,
      'status': 'Nonaktif',
      'kycStatus': 'Ditolak',
      'kycSubmittedAt': '2024-10-05',
      'role': 'Pelanggan',
      'registeredAt': '2024-09-15',
      'lastActive': '2024-11-20 18:00',
      'totalSessions': 2,
      'totalSpent': 45000,
      'walletBalance': 0,
      'vehicles': [
        {'plate': 'B 3344 EF', 'type': 'Mobil', 'brand': 'Daihatsu', 'model': 'Xenia', 'color': 'Hitam', 'isDefault': true},
      ],
      'recentSessions': [
        {'location': 'Malioboro Mall', 'date': '2024-11-18', 'duration': '2j 0m', 'cost': 40000, 'status': 'Selesai'},
      ],
      'recentTransactions': [
        {'date': '2024-11-18', 'type': 'Parkir', 'amount': -40000, 'status': 'Berhasil', 'ref': 'TXN-20241118-001'},
        {'date': '2024-11-01', 'type': 'Top Up', 'amount': 50000, 'status': 'Berhasil', 'ref': 'TXN-20241101-002'},
      ],
      'kycDocuments': [
        {'type': 'KTP', 'status': 'Ditolak', 'imageUrl': null, 'verifiedAt': null, 'rejectReason': 'Foto tidak jelas'},
        {'type': 'SIM', 'status': 'Ditolak', 'imageUrl': null, 'verifiedAt': null, 'rejectReason': 'Masa berlaku habis'},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': false,
        'notifPromo': false,
        'notifSystem': true,
        'language': 'id',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'usr_4',
      'name': 'Dewi Lestari',
      'email': 'dewi.lestari@email.com',
      'phone': '+62 819-4444-8888',
      'avatar': null,
      'status': 'Aktif',
      'kycStatus': 'Terverifikasi',
      'kycSubmittedAt': '2024-12-01',
      'role': 'Pelanggan',
      'registeredAt': '2024-11-28',
      'lastActive': '2024-12-19 16:45',
      'totalSessions': 15,
      'totalSpent': 675000,
      'walletBalance': 320000,
      'vehicles': [
        {'plate': 'B 5566 GH', 'type': 'EV', 'brand': 'Tesla', 'model': 'Model 3', 'color': 'Merah', 'isDefault': true},
        {'plate': 'B 7788 IJ', 'type': 'Mobil', 'brand': 'BMW', 'model': 'X1', 'color': 'Biru', 'isDefault': false},
      ],
      'recentSessions': [
        {'location': 'Grand Indonesia', 'date': '2024-12-19', 'duration': '2j 30m', 'cost': 85000, 'status': 'Selesai'},
        {'location': 'Central Park Mall', 'date': '2024-12-17', 'duration': '1j 0m', 'cost': 25000, 'status': 'Selesai'},
        {'location': 'Grand Indonesia', 'date': '2024-12-14', 'duration': '4j 0m', 'cost': 120000, 'status': 'Selesai'},
      ],
      'recentTransactions': [
        {'date': '2024-12-19', 'type': 'Parkir', 'amount': -85000, 'status': 'Berhasil', 'ref': 'TXN-20241219-004'},
        {'date': '2024-12-17', 'type': 'Parkir', 'amount': -25000, 'status': 'Berhasil', 'ref': 'TXN-20241217-005'},
        {'date': '2024-12-14', 'type': 'Parkir', 'amount': -120000, 'status': 'Berhasil', 'ref': 'TXN-20241214-006'},
        {'date': '2024-12-05', 'type': 'Top Up', 'amount': 500000, 'status': 'Berhasil', 'ref': 'TXN-20241205-007'},
      ],
      'kycDocuments': [
        {'type': 'KTP', 'status': 'Terverifikasi', 'imageUrl': null, 'verifiedAt': '2024-12-02'},
        {'type': 'SIM', 'status': 'Terverifikasi', 'imageUrl': null, 'verifiedAt': '2024-12-02'},
        {'type': 'STNK', 'status': 'Terverifikasi', 'imageUrl': null, 'verifiedAt': '2024-12-03'},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': true,
        'notifSystem': true,
        'language': 'id',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
  ];

  String _searchQuery = '';
  String _statusFilter = 'Semua';
  String _kycFilter = 'Semua';
  String _roleFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['phone'].contains(_searchQuery);
      final matchesStatus = _statusFilter == 'Semua' || user['status'] == _statusFilter;
      final matchesKyc = _kycFilter == 'Semua' || user['kycStatus'] == _kycFilter;
      final matchesRole = _roleFilter == 'Semua' || user['role'] == _roleFilter;
      return matchesSearch && matchesStatus && matchesKyc && matchesRole;
    }).toList();
  }

  Map<String, int> get _summaryStats {
    return {
      'total': _users.length,
      'active': _users.where((u) => u['status'] == 'Aktif').length,
      'verified': _users.where((u) => u['kycStatus'] == 'Terverifikasi').length,
      'pendingKyc': _users.where((u) => u['kycStatus'] == 'Menunggu Verifikasi').length,
    };
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
          child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kelola Pengguna Terpadu', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Profil • Kendaraan • KYC • Sesi • Dompet', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data pengguna diekspor'), backgroundColor: Color(0xFF17A18A))),
            icon: const Icon(Icons.download, size: 18, color: Color(0xFF17A18A)),
            label: Text('Ekspor', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Color(0xFF17A18A))),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF114177),
          unselectedLabelColor: const Color(0xFF76777B),
          indicatorColor: const Color(0xFF114177),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Daftar'),
            Tab(text: 'Profil'),
            Tab(text: 'Kendaraan'),
            Tab(text: 'KYC'),
            Tab(text: 'Dompet & Sesi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListTab(),
          _buildProfileTab(),
          _buildVehiclesTab(),
          _buildKycTab(),
          _buildWalletSessionsTab(),
        ],
      ),
    ));
  }

  // ============ TAB 1: DAFTAR USER ============
  Widget _buildListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          _buildSummarySection(),
          const SizedBox(height: 16),
          // Filters
          _buildFiltersSection(),
          const SizedBox(height: 16),
          // User list
          _buildSectionTitle('Daftar Pengguna', subtitle: '${_filteredUsers.length} dari ${_users.length} pengguna'),
          ..._filteredUsers.map((user) => _buildUserRow(user)).toList(),
          if (_filteredUsers.isEmpty)
            _buildCard(child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Tidak ada pengguna ditemukan', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B)))))),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final stats = _summaryStats;
    return _buildCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard('Total', stats['total']!, Icons.people, const Color(0xFF45474A)),
          _buildStatCard('Aktif', stats['active']!, Icons.check_circle, const Color(0xFF17A18A)),
          _buildStatCard('KYC Verified', stats['verified']!, Icons.verified, const Color(0xFF114177)),
          _buildStatCard('Pending KYC', stats['pendingKyc']!, Icons.hourglass_empty, const Color(0xFFE07A5F)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return _buildCard(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama, email, telepon...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF76777B), size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Status', _statusFilter, ['Semua', 'Aktif', 'Nonaktif', 'Diblokir'], (v) => setState(() => _statusFilter = v)),
              _buildFilterChip('KYC', _kycFilter, ['Semua', 'Terverifikasi', 'Menunggu Verifikasi', 'Ditolak'], (v) => setState(() => _kycFilter = v)),
              _buildFilterChip('Role', _roleFilter, ['Semua', 'Pelanggan', 'Admin', 'Operator'], (v) => setState(() => _roleFilter = v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (_) => options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
          const SizedBox(width: 6),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF114177), fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF76777B)),
        ]),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    final statusColors = {
      'Aktif': const Color(0xFF17A18A),
      'Nonaktif': const Color(0xFF76777B),
      'Diblokir': const Color(0xFFD94B4B),
    };
    final kycColors = {
      'Terverifikasi': const Color(0xFF17A18A),
      'Menunggu Verifikasi': const Color(0xFFE07A5F),
      'Ditolak': const Color(0xFFD94B4B),
    };
    final statusColor = statusColors[user['status']] ?? const Color(0xFF76777B);
    final kycColor = kycColors[user['kycStatus']] ?? const Color(0xFF76777B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showUserDetailBottomSheet(user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF114177).withValues(alpha: 0.1),
                child: Text(user['name'][0], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(user['name'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(user['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user['email'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kycColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(user['kycStatus'], style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: kycColor))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(user['role'], style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF114177)))),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Rp ${_formatNumber(user['walletBalance'])}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                  const SizedBox(height: 2),
                  Text('${user['totalSessions']} sesi', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Color(0xFF76777B)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ TAB 2: PROFIL DETAIL ============
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Detail Profil Pengguna'),
          _buildCard(
            child: Column(
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Pilih Pengguna', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: _users.map<DropdownMenuItem<Map<String, dynamic>>>((u) => DropdownMenuItem<Map<String, dynamic>>(value: u, child: Text('${u['name']} (${u['email']})', style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
                const Text('Pilih pengguna dari dropdown di atas untuk melihat detail profil lengkap', style: TextStyle(color: Color(0xFF76777B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 3: KENDARAAN ============
  Widget _buildVehiclesTab() {
    final allVehicles = _users.expand((u) => (u['vehicles'] as List).map((v) => {...v, 'ownerName': u['name'], 'ownerId': u['id']})).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Semua Kendaraan Terdaftar', subtitle: '${allVehicles.length} kendaraan dari ${_users.length} pengguna'),
          _buildCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allVehicles.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE4DFD5)),
              itemBuilder: (_, i) {
                final v = allVehicles[i];
                final typeColors = {'Mobil': Color(0xFF45474A), 'Motor': Color(0xFF114177), 'EV': Color(0xFFE07A5F), 'Disabilitas': Color(0xFF9B59B6)};
                final typeColor = typeColors[v['type']] ?? Color(0xFF45474A);
                return ListTile(
                  leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(v['type'] == 'Motor' ? Icons.two_wheeler : (v['type'] == 'EV' ? Icons.ev_station : Icons.directions_car), color: typeColor)),
                  title: Text(v['plate'], style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  subtitle: Text('${v['brand']} ${v['model']} • ${v['color']} • ${v['ownerName']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  trailing: v['isDefault'] ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text('Default', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)))) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 4: KYC ============
  Widget _buildKycTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Verifikasi KYC', subtitle: 'Kelola dokumen identitas & verifikasi pengguna'),
          _buildCard(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE4DFD5)),
              itemBuilder: (_, i) {
                final u = _users[i];
                final kycColors = {'Terverifikasi': Color(0xFF17A18A), 'Menunggu Verifikasi': Color(0xFFE07A5F), 'Ditolak': Color(0xFFD94B4B)};
                final kycColor = kycColors[u['kycStatus']] ?? Color(0xFF76777B);
                final docCount = (u['kycDocuments'] as List).length;
                final verifiedCount = (u['kycDocuments'] as List).where((d) => d['status'] == 'Terverifikasi').length;
                return ListTile(
                  leading: CircleAvatar(radius: 20, backgroundColor: const Color(0xFF114177).withValues(alpha: 0.1), child: Text(u['name'][0], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF114177)))),
                  title: Text(u['name'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('${u['email']} • $verifiedCount/$docCount dokumen terverifikasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: kycColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(u['kycStatus'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: kycColor))),
                  onTap: () => _showKycDetailBottomSheet(u),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ TAB 5: DOMPET & SESI ============
  Widget _buildWalletSessionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ringkasan Dompet & Sesi'),
          _buildCard(
            child: Column(
              children: [
                DropdownButtonFormField<Map<String, dynamic>>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Pilih Pengguna', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: _users.map<DropdownMenuItem<Map<String, dynamic>>>((u) => DropdownMenuItem<Map<String, dynamic>>(value: u, child: Text('${u['name']} • Saldo: Rp ${_formatNumber(u['walletBalance'])}', style: GoogleFonts.plusJakartaSans(fontSize: 12)))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
                const Text('Pilih pengguna untuk melihat riwayat transaksi & sesi lengkap', style: TextStyle(color: Color(0xFF76777B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ BOTTOM SHEETS ============
  void _showUserDetailBottomSheet(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(radius: 32, backgroundColor: const Color(0xFF114177).withValues(alpha: 0.1), child: Text(user['name'][0], style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF114177)))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user['name'], style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    const SizedBox(height: 4),
                    Text(user['email'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                    const SizedBox(height: 2),
                    Text(user['phone'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: (user['status'] == 'Aktif' ? const Color(0xFF17A18A) : const Color(0xFF76777B)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(user['status'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: user['status'] == 'Aktif' ? const Color(0xFF17A18A) : const Color(0xFF76777B)))),
                    const SizedBox(height: 4),
                    Text('Terdaftar: ${user['registeredAt']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                  ]),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Ringkasan', [
                _buildInfoRow('Total Sesi', '${user['totalSessions']}'),
                _buildInfoRow('Total Belanja', 'Rp ${_formatNumber(user['totalSpent'])}'),
                _buildInfoRow('Saldo Dompet', 'Rp ${_formatNumber(user['walletBalance'])}'),
                _buildInfoRow('KYC Status', user['kycStatus']),
                _buildInfoRow('Terakhir Aktif', user['lastActive']),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Preferensi', [
                _buildInfoRow('Notifikasi Booking', user['preferences']['notifBooking'] ? 'Aktif' : 'Nonaktif'),
                _buildInfoRow('Notifikasi Pengingat', user['preferences']['notifReminder'] ? 'Aktif' : 'Nonaktif'),
                _buildInfoRow('Notifikasi Promo', user['preferences']['notifPromo'] ? 'Aktif' : 'Nonaktif'),
                _buildInfoRow('Bahasa', user['preferences']['language'].toUpperCase()),
                _buildInfoRow('Mata Uang', user['preferences']['currency']),
                _buildInfoRow('Zona Waktu', user['preferences']['timezone']),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showKycDetailBottomSheet(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('KYC: ${user['name']}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (user['kycDocuments'] as List).length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final doc = (user['kycDocuments'] as List)[i];
                  final statusColors = {'Terverifikasi': Color(0xFF17A18A), 'Diajukan': Color(0xFFE07A5F), 'Ditolak': Color(0xFFD94B4B)};
                  final statusColor = statusColors[doc['status']] ?? Color(0xFF76777B);
                  return ListTile(
                    leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.description, color: statusColor)),
                    title: Text(doc['type'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: ${doc['status']}${doc['verifiedAt'] != null ? ' • Diverifikasi: ${doc['verifiedAt']}' : ''}${doc['rejectReason'] != null ? ' • Alasan: ${doc['rejectReason']}' : ''}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(doc['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (user['kycStatus'] == 'Menunggu Verifikasi')
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KYC disetujui'), backgroundColor: Color(0xFF17A18A))); }, icon: const Icon(Icons.check), label: Text('Setujui', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KYC ditolak'), backgroundColor: Color(0xFFD94B4B))); }, icon: const Icon(Icons.close), label: Text('Tolak', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94B4B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ HELPERS ============
  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          if (subtitle != null) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
      child: child,
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}