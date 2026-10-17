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
  String _selectedStatusFilter = 'Semua';
  String _selectedKycFilter = 'Semua';

  final List<String> _statusFilters = ['Semua', 'Aktif', 'Tidak Aktif', 'Diblokir'];
  final List<String> _kycFilters = ['Semua', 'Terverifikasi', 'Pending', 'Ditolak', 'Belum Submit'];

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
    return _customers.where((c) {
      final q = _searchController.text.toLowerCase();
      final matchesSearch = c['name'].toString().toLowerCase().contains(q) ||
          c['email'].toString().toLowerCase().contains(q) ||
          c['phone'].toString().toLowerCase().contains(q) ||
          c['id'].toString().toLowerCase().contains(q);

      if (!matchesSearch) return false;

      final matchesStatus = _selectedStatusFilter == 'Semua' || c['status'] == _selectedStatusFilter;
      final matchesKyc = _selectedKycFilter == 'Semua' || c['kycStatus'] == _selectedKycFilter;

      return matchesStatus && matchesKyc;
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
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text(customer['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF114177)))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer['name'], style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          Text(customer['email'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(customer['status'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: kycBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(customer['kycStatus'], style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: kycColor)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Quick Stats
                Row(
                  children: [
                    _buildStatItem('Total Sesi', '${customer['totalSessions']}', Icons.local_parking),
                    _buildStatItem('Total Belanja', 'Rp ${_formatNumber(customer['totalSpent'])}', Icons.attach_money),
                    _buildStatItem('Saldo Dompet', 'Rp ${_formatNumber(customer['walletBalance'])}', Icons.account_balance_wallet),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Info Pribadi
                Text('Informasi Pribadi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 12),
                _buildInfoRow('ID User', customer['id']),
                _buildInfoRow('Telepon', customer['phone']),
                _buildInfoRow('Bergabung', customer['joinDate']),
                _buildInfoRow('Aktif Terakhir', customer['lastActive']),
                if (customer['kycSubmittedAt'] != null) _buildInfoRow('KTP Diajukan', customer['kycSubmittedAt']),
                if (customer['kycApprovedAt'] != null) _buildInfoRow('KTP Disetujui', customer['kycApprovedAt']),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Kendaraan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kendaraan (${customer['vehicles'].length})', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    TextButton.icon(
                      onPressed: () => _showAddVehicleDialog(customer),
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF114177)),
                      label: Text('Tambah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (customer['vehicles'].isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE4DFD5), style: BorderStyle.solid)),
                    child: Center(child: Text('Belum ada kendaraan terdaftar', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)))),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customer['vehicles'].length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final v = customer['vehicles'][i];
                      final typeColor = _getVehicleTypeColor(v['type']);
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE4DFD5))),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
                              child: Icon(v['type'] == 'Mobil' ? Icons.directions_car : Icons.two_wheeler, color: typeColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(v['plate'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(v['type'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor)),
                                      ),
                                      if (v['isDefault']) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFD1F2EB), borderRadius: BorderRadius.circular(4)),
                                          child: Text('Default', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${v['brand']} ${v['model']} · ${v['color']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Color(0xFF76777B)),
                              onSelected: (value) {
                                if (value == 'edit') _showEditVehicleDialog(customer, v);
                                if (value == 'delete') _confirmDeleteVehicle(customer, v);
                                if (value == 'default') _setDefaultVehicle(customer, v);
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'default', child: Text('Jadikan Default')),
                                const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Color(0xFFD94B4B)))),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Preferensi
                Text('Preferensi Aplikasi', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 12),
                _buildPrefRow('Notifikasi Booking', customer['preferences']['notifBooking']),
                _buildPrefRow('Pengingat Check-out', customer['preferences']['notifReminder']),
                _buildPrefRow('Promo & Penawaran', customer['preferences']['notifPromo']),
                _buildInfoRow('Tema', customer['preferences']['theme']),
                _buildInfoRow('Bahasa', customer['preferences']['language']),
                _buildInfoRow('Mata Uang', customer['preferences']['currency']),
                _buildInfoRow('Zona Waktu', customer['preferences']['timezone']),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF1EEE7), height: 1),
                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEditProfileDialog(customer);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF114177)),
                        label: Text('Edit Profil', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF114177)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showWalletInjectionDialog(customer);
                        },
                        icon: const Icon(Icons.account_balance_wallet, size: 18, color: Colors.white),
                        label: Text('Injeksi Saldo', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17A18A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddVehicleDialog(Map<String, dynamic> customer) {
    final plateCtrl = TextEditingController();
    String selectedType = 'Mobil';
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    bool isDefault = customer['vehicles'].isEmpty;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Tambah Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: plateCtrl,
                decoration: InputDecoration(
                  labelText: 'Nomor Polisi',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipe',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Mobil', 'Motor', 'EV'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                onChanged: (v) => selectedType = v ?? 'Mobil',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brandCtrl,
                decoration: InputDecoration(
                  labelText: 'Merek',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelCtrl,
                decoration: InputDecoration(
                  labelText: 'Model',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorCtrl,
                decoration: InputDecoration(
                  labelText: 'Warna',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Jadikan Kendaraan Default', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                value: isDefault,
                activeThumbColor: const Color(0xFF17A18A),
                onChanged: (v) => isDefault = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (plateCtrl.text.isNotEmpty && brandCtrl.text.isNotEmpty && modelCtrl.text.isNotEmpty) {
                setState(() {
                  if (isDefault) {
                    for (var v in customer['vehicles']) {
                      v['isDefault'] = false;
                    }
                  }
                  customer['vehicles'].add({
                    'plate': plateCtrl.text.toUpperCase(),
                    'type': selectedType,
                    'brand': brandCtrl.text,
                    'model': modelCtrl.text,
                    'color': colorCtrl.text,
                    'isDefault': isDefault,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kendaraan ditambahkan ke ${customer['name']}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleDialog(Map<String, dynamic> customer, Map<String, dynamic> vehicle) {
    final plateCtrl = TextEditingController(text: vehicle['plate']);
    String selectedType = vehicle['type'];
    final brandCtrl = TextEditingController(text: vehicle['brand']);
    final modelCtrl = TextEditingController(text: vehicle['model']);
    final colorCtrl = TextEditingController(text: vehicle['color']);
    bool isDefault = vehicle['isDefault'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Edit Kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: plateCtrl, decoration: InputDecoration(labelText: 'Nomor Polisi', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(initialValue: selectedType, decoration: InputDecoration(labelText: 'Tipe', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: ['Mobil', 'Motor', 'EV'].map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(), onChanged: (v) => selectedType = v ?? 'Mobil'),
              const SizedBox(height: 12),
              TextField(controller: brandCtrl, decoration: InputDecoration(labelText: 'Merek', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              TextField(controller: modelCtrl, decoration: InputDecoration(labelText: 'Model', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              TextField(controller: colorCtrl, decoration: InputDecoration(labelText: 'Warna', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: Text('Jadikan Kendaraan Default', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))), value: isDefault, activeThumbColor: const Color(0xFF17A18A), onChanged: (v) => isDefault = v),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (plateCtrl.text.isNotEmpty && brandCtrl.text.isNotEmpty && modelCtrl.text.isNotEmpty) {
                setState(() {
                  if (isDefault) {
                    for (var v in customer['vehicles']) {
                      v['isDefault'] = false;
                    }
                  }
                  vehicle['plate'] = plateCtrl.text.toUpperCase();
                  vehicle['type'] = selectedType;
                  vehicle['brand'] = brandCtrl.text;
                  vehicle['model'] = modelCtrl.text;
                  vehicle['color'] = colorCtrl.text;
                  vehicle['isDefault'] = isDefault;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kendaraan diperbarui', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVehicle(Map<String, dynamic> customer, Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Hapus Kendaraan?', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: Text('Yakin ingin menghapus ${vehicle['plate']} (${vehicle['brand']} ${vehicle['model']})?', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              setState(() => customer['vehicles'].removeWhere((v) => v['plate'] == vehicle['plate']));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kendaraan dihapus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFFD94B4B), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94B4B), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Hapus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _setDefaultVehicle(Map<String, dynamic> customer, Map<String, dynamic> vehicle) {
    setState(() {
      for (var v in customer['vehicles']) v['isDefault'] = false;
      vehicle['isDefault'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${vehicle['plate']} dijadikan default', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  void _showEditProfileDialog(Map<String, dynamic> customer) {
    final nameCtrl = TextEditingController(text: customer['name']);
    final emailCtrl = TextEditingController(text: customer['email']);
    final phoneCtrl = TextEditingController(text: customer['phone']);
    String selectedStatus = customer['status'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Edit Profil: ${customer['name']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nama Lengkap', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Telepon', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: InputDecoration(labelText: 'Status Akun', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Aktif', 'Tidak Aktif', 'Diblokir'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                onChanged: (v) => selectedStatus = v ?? 'Aktif',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                setState(() {
                  customer['name'] = nameCtrl.text;
                  customer['email'] = emailCtrl.text;
                  customer['phone'] = phoneCtrl.text;
                  customer['avatar'] = nameCtrl.text[0].toUpperCase();
                  customer['status'] = selectedStatus;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil diperbarui', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showWalletInjectionDialog(Map<String, dynamic> customer) {
    final amountCtrl = TextEditingController();
    final List<int> presets = [50000, 100000, 250000, 500000, 1000000];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Injeksi Saldo: ${customer['name']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Saldo saat ini: Rp ${_formatNumber(customer['walletBalance'])}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Preset Cepat', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presets.map((p) => GestureDetector(
                onTap: () => amountCtrl.text = p.toString(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE4DFD5))),
                  child: Text('Rp ${_formatNumber(p)}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                ),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
              if (amount > 0) {
                setState(() => customer['walletBalance'] += amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil injeksi Rp ${_formatNumber(amount)} ke ${customer['name']}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)), backgroundColor: const Color(0xFF17A18A), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A18A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Injeksi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF114177)),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        ],
      ),
    );
  }

  Widget _buildPrefRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          Switch(
            value: value,
            onChanged: (_) {},
            activeThumbColor: const Color(0xFF17A18A),
            inactiveThumbColor: const Color(0xFF76777B),
            inactiveTrackColor: const Color(0xFFE4DFD5),
            activeTrackColor: const Color(0xFFD1F2EB),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _customers.where((c) => c['status'] == 'Aktif').length;
    final verifiedCount = _customers.where((c) => c['kycStatus'] == 'Terverifikasi').length;

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
            Text('Manajemen Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Profil, Kendaraan & Preferensi Customer', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
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
                    _buildStatCard('Total User', '${_customers.length}', const Color(0xFF114177), const Color(0xFFE3EEFF)),
                    const SizedBox(width: 10),
                    _buildStatCard('Aktif', '$activeCount', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                    const SizedBox(width: 10),
                    _buildStatCard('KYC Verified', '$verifiedCount', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                  ],
                ),
                const SizedBox(height: 14),
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
                          decoration: InputDecoration(hintText: 'Cari nama, email, telepon, ID...', hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)), border: InputBorder.none, isDense: true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status filter
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _statusFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _selectedStatusFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatusFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: isSelected ? const Color(0xFF114177) : const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)),
                    child: Center(child: Text(filter, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF45474A)))),
                  ),
                );
              },
            ),
          ),

          // KYC filter
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _kycFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _kycFilters[index];
                final isSelected = _selectedKycFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedKycFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: isSelected ? const Color(0xFFE07A5F) : const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)),
                    child: Center(child: Text(filter, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF45474A)))),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Customers List
          Expanded(
            child: _filteredCustomers.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.people_outline, size: 48, color: Color(0xFF76777B)), const SizedBox(height: 12), Text('Tidak ada pengguna yang cocok', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B)))]))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
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
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
                          child: Row(
                            children: [
                              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(c['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF114177))))),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(child: Text(c['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)))),
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)), child: Text(c['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
                                    ]),
                                    const SizedBox(height: 2),
                                    Text(c['email'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: kycBg, borderRadius: BorderRadius.circular(6)), child: Text('KYC: ${c['kycStatus']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: kycColor))),
                                      const SizedBox(width: 8),
                                      Text('${c['vehicles'].length} kendaraan', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                      const SizedBox(width: 8),
                                      Text('Saldo: Rp ${_formatNumber(c['walletBalance'])}', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF17A18A))),
                                    ]),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFF76777B)),
                            ],
                          ),
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
    return Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 2), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color))])));
  }
}