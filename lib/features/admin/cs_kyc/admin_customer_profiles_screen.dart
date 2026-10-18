import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCustomerProfilesScreen extends StatefulWidget {
  const AdminCustomerProfilesScreen({super.key});

  @override
  State<AdminCustomerProfilesScreen> createState() => _AdminCustomerProfilesScreenState();
}

class _AdminCustomerProfilesScreenState extends State<AdminCustomerProfilesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _customers = [
    {
      'id': 'USR-001',
      'name': 'Nanda Setiawan',
      'email': 'nanda.setiawan@gmail.com',
      'phone': '+62 812-3456-7890',
      'avatar': 'N',
      'status': 'Aktif',
      'kycStatus': 'Terverifikasi',
      'kycSubmittedAt': '15 Jan 2024',
      'kycApprovedAt': '16 Jan 2024',
      'joinDate': '10 Jan 2024',
      'lastActive': '2 jam lalu',
      'totalSessions': 47,
      'totalSpent': 2850000,
      'walletBalance': 150000,
      'vehicles': [
        {'plate': 'B 1234 ABC', 'type': 'Mobil', 'brand': 'Toyota', 'model': 'Avanza', 'color': 'Putih', 'isDefault': true},
        {'plate': 'B 5678 DEF', 'type': 'Motor', 'brand': 'Honda', 'model': 'Beat', 'color': 'Merah', 'isDefault': false},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': false,
        'theme': 'Sistem',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'USR-002',
      'name': 'Rafi Maulana',
      'email': 'rafi.m@example.com',
      'phone': '+62 856-7890-1234',
      'avatar': 'R',
      'status': 'Aktif',
      'kycStatus': 'Pending',
      'kycSubmittedAt': '20 Mar 2024',
      'kycApprovedAt': null,
      'joinDate': '18 Mar 2024',
      'lastActive': 'Hari ini 09:15',
      'totalSessions': 23,
      'totalSpent': 1240000,
      'walletBalance': 75000,
      'vehicles': [
        {'plate': 'B 9012 GHI', 'type': 'Mobil', 'brand': 'Daihatsu', 'model': 'Xenia', 'color': 'Hitam', 'isDefault': true},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': true,
        'theme': 'Terang',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'USR-003',
      'name': 'Siti Rahayu',
      'email': 'siti.r@example.com',
      'phone': '+62 878-1122-3344',
      'avatar': 'S',
      'status': 'Aktif',
      'kycStatus': 'Terverifikasi',
      'kycSubmittedAt': '05 Feb 2024',
      'kycApprovedAt': '06 Feb 2024',
      'joinDate': '02 Feb 2024',
      'lastActive': 'Kemarin 18:30',
      'totalSessions': 62,
      'totalSpent': 4120000,
      'walletBalance': 320000,
      'vehicles': [
        {'plate': 'D 3456 JKL', 'type': 'Mobil', 'brand': 'Mitsubishi', 'model': 'Xpander', 'color': 'Silver', 'isDefault': true},
        {'plate': 'D 7890 MNO', 'type': 'Mobil', 'brand': 'Wuling', 'model': 'Air EV', 'color': 'Biru', 'isDefault': false},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': false,
        'notifPromo': false,
        'theme': 'Gelap',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WITA',
      },
    },
    {
      'id': 'USR-004',
      'name': 'Budi Santoso',
      'email': 'budi.s@example.com',
      'phone': '+62 813-9988-7766',
      'avatar': 'B',
      'status': 'Diblokir',
      'kycStatus': 'Ditolak',
      'kycSubmittedAt': '10 Apr 2024',
      'kycApprovedAt': null,
      'joinDate': '08 Apr 2024',
      'lastActive': '3 hari lalu',
      'totalSessions': 5,
      'totalSpent': 180000,
      'walletBalance': 0,
      'vehicles': [
        {'plate': 'B 1111 AAA', 'type': 'Motor', 'brand': 'Yamaha', 'model': 'NMAX', 'color': 'Hitam', 'isDefault': true},
      ],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': true,
        'theme': 'Sistem',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
    {
      'id': 'USR-005',
      'name': 'Dewi Lestari',
      'email': 'dewi.l@example.com',
      'phone': '+62 821-4455-6677',
      'avatar': 'D',
      'status': 'Tidak Aktif',
      'kycStatus': 'Belum Submit',
      'kycSubmittedAt': null,
      'kycApprovedAt': null,
      'joinDate': 'Hari ini',
      'lastActive': 'Baru daftar',
      'totalSessions': 0,
      'totalSpent': 0,
      'walletBalance': 0,
      'vehicles': [],
      'preferences': {
        'notifBooking': true,
        'notifReminder': true,
        'notifPromo': true,
        'theme': 'Sistem',
        'language': 'Indonesia',
        'currency': 'IDR',
        'timezone': 'WIB',
      },
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _customers;
    return _customers.where((c) {
      return c['name'].toString().toLowerCase().contains(q) ||
          c['email'].toString().toLowerCase().contains(q) ||
          c['phone'].toString().toLowerCase().contains(q) ||
          c['id'].toString().toLowerCase().contains(q);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return const Color(0xFF17A18A);
      case 'Tidak Aktif':
        return const Color(0xFF76777B);
      case 'Diblokir':
        return const Color(0xFFD94B4B);
      default:
        return const Color(0xFF76777B);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Aktif':
        return const Color(0xFFD1F2EB);
      case 'Tidak Aktif':
        return const Color(0xFFF1EEE7);
      case 'Diblokir':
        return const Color(0xFFFDE8E4);
      default:
        return const Color(0xFFF1EEE7);
    }
  }

  Color _getKycColor(String status) {
    switch (status) {
      case 'Terverifikasi':
        return const Color(0xFF17A18A);
      case 'Pending':
        return const Color(0xFFE07A5F);
      case 'Ditolak':
        return const Color(0xFFD94B4B);
      case 'Belum Submit':
        return const Color(0xFF76777B);
      default:
        return const Color(0xFF76777B);
    }
  }

  Color _getKycBg(String status) {
    switch (status) {
      case 'Terverifikasi':
        return const Color(0xFFD1F2EB);
      case 'Pending':
        return const Color(0xFFFDECE7);
      case 'Ditolak':
        return const Color(0xFFFDE8E4);
      case 'Belum Submit':
        return const Color(0xFFF1EEE7);
      default:
        return const Color(0xFFF1EEE7);
    }
  }

  Color _getVehicleTypeColor(String type) {
    switch (type) {
      case 'Mobil':
        return const Color(0xFF114177);
      case 'Motor':
        return const Color(0xFFE07A5F);
      case 'EV':
        return const Color(0xFF17A18A);
      default:
        return const Color(0xFF76777B);
    }
  }

  void _showCustomerDetail(Map<String, dynamic> customer) {
    final statusColor = _getStatusColor(customer['status']);
    final statusBg = _getStatusBg(customer['status']);
    final kycColor = _getKycColor(customer['kycStatus']);
    final kycBg = _getKycBg(customer['kycStatus']);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: true,
        child: Container(
          margin: const EdgeInsets.only(top: 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Indicator Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Modal Header with Close Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Profil Pengguna',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF76777B)),
                      onPressed: () => Navigator.pop(ctx),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Identity Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF114177), Color(0xFF1E60AA)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  customer['avatar'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer['name'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A18),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    customer['email'],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF76777B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          customer['status'],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: kycBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'KYC: ${customer['kycStatus']}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: kycColor,
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
                      ),
                      const SizedBox(height: 16),

                      // Quick Stats (Sesi, Total Belanja, Saldo Dompet)
                      Row(
                        children: [
                          _buildStatItem('Total Sesi', '${customer['totalSessions']}', Icons.local_parking),
                          const SizedBox(width: 8),
                          _buildStatItem('Total Belanja', 'Rp ${_formatNumber(customer['totalSpent'])}', Icons.payments_outlined),
                          const SizedBox(width: 8),
                          _buildStatItem('Saldo Dompet', 'Rp ${_formatNumber(customer['walletBalance'])}', Icons.account_balance_wallet_outlined),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Informasi Akun (Tanpa lastActive, Tanpa KTP diajukan)
                      Text(
                        'Informasi Akun',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('ID Pengguna', customer['id']),
                            _buildInfoRow('Nomor Telepon', customer['phone']),
                            _buildInfoRow('Tanggal Bergabung', customer['joinDate']),
                            _buildInfoRow('Status KYC', customer['kycStatus']),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Daftar Kendaraan (Read-only, Tanpa tombol tambah dan tanpa tombol titik tiga)
                      Text(
                        'Kendaraan Terdaftar (${(customer['vehicles'] as List).length} Unit)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if ((customer['vehicles'] as List).isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Center(
                            child: Text(
                              'Belum ada kendaraan terdaftar',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                            ),
                          ),
                        )
                      else
                        ...List.generate((customer['vehicles'] as List).length, (i) {
                          final v = customer['vehicles'][i];
                          final typeColor = _getVehicleTypeColor(v['type']);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: typeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    v['type'] == 'Mobil' ? Icons.directions_car : Icons.two_wheeler,
                                    color: typeColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            v['plate'],
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1A1A18),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: typeColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              v['type'],
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: typeColor,
                                              ),
                                            ),
                                          ),
                                          if (v['isDefault'] == true) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFD1F2EB),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Utama',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF17A18A),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${v['brand']} ${v['model']} • ${v['color']}',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF76777B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 20),

                      // Tombol Tutup
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF114177)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Tutup',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF114177),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF114177)),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A18),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        ],
      ),
    );
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
              decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Database Profil Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('Daftar Akun Pengguna & Informasi Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search Bar Bergaya Google yang Simpel & Elegan
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                        decoration: InputDecoration(
                          hintText: 'Telusuri nama, email, telepon, atau ID user...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
                          border: InputBorder.none,
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
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Daftar Pengguna dengan Format Rapi Bebas Overflow
            Expanded(
              child: _filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text('Tidak ada pengguna yang cocok', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF64748B))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCustomers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final c = _filteredCustomers[index];
                        final statusColor = _getStatusColor(c['status']);
                        final statusBg = _getStatusBg(c['status']);
                        final kycColor = _getKycColor(c['kycStatus']);
                        final kycBg = _getKycBg(c['kycStatus']);

                        return GestureDetector(
                          onTap: () => _showCustomerDetail(c),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF114177).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      c['avatar'],
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF114177),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Urutan Kolom: 1. Nama -> 2. Email -> 3. Saldo -> 4. Jumlah Kendaraan -> 5. KYC
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 1. Nama & Status
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c['name'],
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1A1A18),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              c['status'],
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),

                                      // 2. Email
                                      Text(
                                        c['email'],
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF76777B)),
                                      ),
                                      const SizedBox(height: 6),

                                      // 3. Saldo
                                      Row(
                                        children: [
                                          const Icon(Icons.account_balance_wallet_outlined, size: 12, color: Color(0xFF17A18A)),
                                          const SizedBox(width: 4),
                                          Text('Saldo: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                          Text(
                                            'Rp ${_formatNumber(c['walletBalance'])}',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),

                                      // 4. Jumlah Kendaraan
                                      Row(
                                        children: [
                                          const Icon(Icons.directions_car_outlined, size: 12, color: Color(0xFF114177)),
                                          const SizedBox(width: 4),
                                          Text('Kendaraan: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                          Text(
                                            '${(c['vehicles'] as List).length} Unit Terdaftar',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // 5. KYC: Terverifikasi atau Belum
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: kycBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              c['kycStatus'] == 'Terverifikasi' ? Icons.check_circle_outline : Icons.pending_outlined,
                                              size: 11,
                                              color: kycColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'KYC: ${c['kycStatus']}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: kycColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
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
      ),
    );
  }
}
