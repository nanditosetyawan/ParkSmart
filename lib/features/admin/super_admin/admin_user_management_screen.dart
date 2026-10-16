import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'Semua';
  String _selectedStatusFilter = 'Semua';

  final List<String> _roleFilters = ['Semua', 'Super Admin', 'Admin Operasional', 'Admin Finansial', 'Admin CS & KYC'];
  final List<String> _statusFilters = ['Semua', 'Aktif', 'Nonaktif', 'Pending Verifikasi'];

  final List<Map<String, dynamic>> _admins = [
    {
      'id': 'ADM-001',
      'name': 'Dito Pratama',
      'email': 'dito@parksmart.id',
      'phone': '+62 812-3456-7890',
      'role': 'Super Admin',
      'status': 'Aktif',
      'avatar': 'D',
      'lastLogin': '2 jam lalu',
      'locations': ['Semua Lokasi'],
      'permissions': ['Veto Darurat', 'Manajemen User & RBAC', 'Pengaturan Global', 'Konfigurasi AI', 'Audit Trail'],
      'createdAt': '12 Jan 2024',
    },
    {
      'id': 'ADM-002',
      'name': 'Rina Wijaya',
      'email': 'rina.ops@parksmart.id',
      'phone': '+62 856-7890-1234',
      'role': 'Admin Operasional',
      'status': 'Aktif',
      'avatar': 'R',
      'lastLogin': 'Hari ini 08:30',
      'locations': ['Semua Lokasi'],
      'permissions': ['Kelola Titik Parkir', 'Master Lokasi & Kota', 'Denah Slot IoT', 'Monitoring Lapangan & Overstay'],
      'createdAt': '05 Feb 2024',
    },
    {
      'id': 'ADM-003',
      'name': 'Bambang Sutrisno',
      'email': 'bambang.fin@parksmart.id',
      'phone': '+62 878-1122-3344',
      'role': 'Admin Finansial',
      'status': 'Aktif',
      'avatar': 'B',
      'lastLogin': 'Kemarin 17:15',
      'locations': ['Semua Lokasi'],
      'permissions': ['Laporan Pendapatan & Omzet', 'Atur Tarif Dinamis', 'Transaksi Real-time', 'Dompet Saldo', 'Booking Tiket'],
      'createdAt': '20 Mar 2024',
    },
    {
      'id': 'ADM-004',
      'name': 'Siti Rahma',
      'email': 'siti.cs@parksmart.id',
      'phone': '+62 813-9988-7766',
      'role': 'Admin CS & KYC',
      'status': 'Aktif',
      'avatar': 'S',
      'lastLogin': '1 jam lalu',
      'locations': ['Semua Lokasi'],
      'permissions': ['Verifikasi Dokumen KYC', 'Profil Pelanggan CRM', 'Manajemen Akun User', 'Komplain & Feedback', 'Broadcast Promo', 'Arcade Poin'],
      'createdAt': '10 Apr 2024',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAdmins {
    return _admins.where((a) {
      final q = _searchController.text.toLowerCase();
      final matchesSearch = a['name'].toString().toLowerCase().contains(q) ||
          a['email'].toString().toLowerCase().contains(q) ||
          a['id'].toString().toLowerCase().contains(q);

      if (!matchesSearch) return false;

      final matchesRole = _selectedRoleFilter == 'Semua' || a['role'] == _selectedRoleFilter;
      final matchesStatus = _selectedStatusFilter == 'Semua' || a['status'] == _selectedStatusFilter;

      return matchesRole && matchesStatus;
    }).toList();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Super Admin':
        return const Color(0xFF6D28D9);
      case 'Admin Operasional':
        return const Color(0xFF114177);
      case 'Admin Finansial':
        return const Color(0xFF17A18A);
      case 'Admin CS & KYC':
        return const Color(0xFFE07A5F);
      default:
        return const Color(0xFF76777B);
    }
  }

  Color _getRoleBg(String role) {
    switch (role) {
      case 'Super Admin':
        return const Color(0xFFEDE9FE);
      case 'Admin Operasional':
        return const Color(0xFFE3EEFF);
      case 'Admin Finansial':
        return const Color(0xFFD1F2EB);
      case 'Admin CS & KYC':
        return const Color(0xFFFDECE7);
      default:
        return const Color(0xFFF1EEE7);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return const Color(0xFF17A18A);
      case 'Nonaktif':
        return const Color(0xFF76777B);
      case 'Pending Verifikasi':
        return const Color(0xFFE07A5F);
      default:
        return const Color(0xFF76777B);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Aktif':
        return const Color(0xFFD1F2EB);
      case 'Nonaktif':
        return const Color(0xFFF1EEE7);
      case 'Pending Verifikasi':
        return const Color(0xFFFDECE7);
      default:
        return const Color(0xFFF1EEE7);
    }
  }

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedRole = 'Admin Operasional';
    String selectedStatus = 'Aktif';
    final List<String> selectedLocations = [];
    List<String> selectedPermissions = []; // Removed final

    final allLocations = ['Central Park Mall', 'Grand Indonesia', 'Pacific Place SCBD', 'Malioboro Mall', 'Tunjungan Plaza 6', 'Senayan City'];
    final rolePermissions = {
      'Super Admin': ['Veto Darurat', 'Manajemen User & RBAC', 'Pengaturan Global', 'Konfigurasi AI', 'Audit Trail'],
      'Admin Operasional': ['Kelola Titik Parkir', 'Master Lokasi & Kota', 'Denah Slot IoT', 'Monitoring Lapangan & Overstay'],
      'Admin Finansial': ['Laporan Pendapatan & Omzet', 'Atur Tarif Dinamis', 'Transaksi Real-time', 'Dompet Saldo', 'Booking Tiket'],
      'Admin CS & KYC': ['Verifikasi Dokumen KYC', 'Profil Pelanggan CRM', 'Manajemen Akun User', 'Komplain & Feedback', 'Broadcast Promo', 'Arcade Poin'],
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Text('Tambah Admin Baru', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Peran',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _roleFilters.where((r) => r != 'Semua').map((r) => DropdownMenuItem(value: r, child: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          selectedRole = v;
                          selectedPermissions = List.from(rolePermissions[v] ?? []);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _statusFilters.where((s) => s != 'Semua').map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedStatus = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Lokasi Akses', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allLocations.map((loc) {
                      final isSelected = selectedLocations.contains(loc);
                      return FilterChip(
                        label: Text(loc, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            selected ? selectedLocations.add(loc) : selectedLocations.remove(loc);
                          });
                        },
                        selectedColor: const Color(0xFFE3EEFF),
                        checkmarkColor: const Color(0xFF114177),
                        backgroundColor: const Color(0xFFF1EEE7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Izin (Otomatis per Peran)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rolePermissions[selectedRole]!.map((perm) {
                      final isSelected = selectedPermissions.contains(perm);
                      return FilterChip(
                        label: Text(perm, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            selected ? selectedPermissions.add(perm) : selectedPermissions.remove(perm);
                          });
                        },
                        selectedColor: const Color(0xFFD1F2EB),
                        checkmarkColor: const Color(0xFF17A18A),
                        backgroundColor: const Color(0xFFF1EEE7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  // Batasan kuota ketat: 1 akun per role
                  final existingAdmin = _admins.firstWhere(
                    (a) => a['role'] == selectedRole,
                    orElse: () => {},
                  );
                  if (existingAdmin.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (alertCtx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.white,
                        title: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD94B4B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Batas Kuota Role Terpenuhi',
                                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Role "$selectedRole" sudah memiliki 1 akun aktif (${existingAdmin['name']}).\n\nSesuai SOP keamanan, pembuatan akun dibatasi maksimal 1 admin per role. Silakan edit atau bekukan akun yang ada.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A), height: 1.4),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(alertCtx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C1D1F),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Tutup', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _admins.insert(0, {
                      'id': 'ADM-${(_admins.length + 1).toString().padLeft(3, '0')}',
                      'name': nameCtrl.text,
                      'email': emailCtrl.text,
                      'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : '-',
                      'role': selectedRole,
                      'status': selectedStatus,
                      'avatar': nameCtrl.text[0].toUpperCase(),
                      'lastLogin': 'Baru dibuat',
                      'locations': selectedLocations.isEmpty ? ['Semua Lokasi'] : selectedLocations,
                      'permissions': selectedPermissions.isEmpty ? (rolePermissions[selectedRole] ?? []) : selectedPermissions,
                      'createdAt': DateTime.now().toString().split(' ')[0],
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Admin ${nameCtrl.text} berhasil ditambahkan!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFF17A18A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114177),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminDetail(Map<String, dynamic> admin) {
    final roleColor = _getRoleColor(admin['role']);
    final roleBg = _getRoleBg(admin['role']);
    final statusColor = _getStatusColor(admin['status']);
    final statusBg = _getStatusBg(admin['status']);
    final isFrozen = admin['status'] == 'Dibekukan (SOP)' || admin['status'] == 'Nonaktif';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: roleBg, borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text(admin['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: roleColor))),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(admin['name'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                            Text(admin['email'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(admin['status'], style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetailRow('ID Admin', admin['id']),
                _buildDetailRow('Telepon', admin['phone']),
                _buildDetailRow('Peran', admin['role'], valueColor: roleColor),
                _buildDetailRow('Terdaftar Sejak', admin['createdAt']),
                _buildDetailRow('Login Terakhir', admin['lastLogin']),
                const Divider(color: Color(0xFFF1EEE7), height: 28),
                Text('Lokasi Akses', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (admin['locations'] as List).map((loc) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(8)),
                    child: Text(loc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                Text('Izin & Wewenang RBAC', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (admin['permissions'] as List).map((perm) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFE3EEFF), borderRadius: BorderRadius.circular(8)),
                    child: Text(perm, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF114177))),
                  )).toList(),
                ),
                const SizedBox(height: 20),

                // Tindakan SOP: Bekukan Admin & Reset Kredensial
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4DFD5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tindakan Tata Kelola & SOP', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showResetCredentialDialog(admin);
                              },
                              icon: const Icon(Icons.lock_reset, size: 16, color: Color(0xFF114177)),
                              label: Text('Reset Kredensial', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF114177)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _toggleFreezeAdmin(admin);
                              },
                              icon: Icon(isFrozen ? Icons.check_circle_outline : Icons.block, size: 16, color: Colors.white),
                              label: Text(
                                isFrozen ? 'Buka Blokir' : 'Bekukan (SOP)',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFrozen ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEditAdminDialog(admin);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1C1D1F)),
                        label: Text('Edit Data', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1C1D1F))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE4DFD5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (admin['role'] == 'Super Admin') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Super Admin utama tidak dapat dihapus!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                                backgroundColor: const Color(0xFFD94B4B),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _admins.removeWhere((a) => a['id'] == admin['id']);
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Admin ${admin['name']} dihapus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                              backgroundColor: const Color(0xFFD94B4B),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white),
                        label: Text('Hapus', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF45474A),
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

  void _showResetCredentialDialog(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset, color: Color(0xFF114177)),
            const SizedBox(width: 8),
            Text('Reset Kredensial', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Reset kata sandi dan kredensial untuk admin "${admin['name']}" (${admin['role']})?\n\nSistem akan men-generate password baru sementara yang wajib diganti pada saat login berikutnya.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kredensial di-reset! Password sementara: PARK-${admin['id']}-TEMP', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFF17A18A),
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177)),
            child: const Text('Reset Sekarang', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleFreezeAdmin(Map<String, dynamic> admin) {
    final isCurrentlyFrozen = admin['status'] == 'Dibekukan (SOP)' || admin['status'] == 'Nonaktif';
    if (!isCurrentlyFrozen) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.gavel, color: Color(0xFFD94B4B)),
              const SizedBox(width: 8),
              Text('Bekukan Akun Admin', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Text(
            'Admin "${admin['name']}" akan dibekukan karena dugaan pelanggaran SOP operasional.\n\nAkses login dan wewenang sistem divisi akan diblokir segera.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B))),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  admin['status'] = 'Dibekukan (SOP)';
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Akun ${admin['name']} DIBEKUKAN karena pelanggaran SOP.', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                    backgroundColor: const Color(0xFFD94B4B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD94B4B)),
              child: const Text('Bekukan Akun', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        admin['status'] = 'Aktif';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status akun ${admin['name']} dipulihkan menjadi AKTIF.', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF17A18A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final nameCtrl = TextEditingController(text: admin['name']);
    final emailCtrl = TextEditingController(text: admin['email']);
    final phoneCtrl = TextEditingController(text: admin['phone']);
    String selectedRole = admin['role'];
    String selectedStatus = admin['status'];
    final List<String> selectedLocations = List<String>.from(admin['locations']);
    List<String> selectedPermissions = List<String>.from(admin['permissions']);

    final allLocations = ['Semua Lokasi', 'Central Park Mall', 'Grand Indonesia', 'Pacific Place SCBD', 'Malioboro Mall', 'Tunjungan Plaza 6', 'Senayan City'];
    final rolePermissions = {
      'Super Admin': ['Veto Darurat', 'Manajemen User & RBAC', 'Pengaturan Global', 'Konfigurasi AI', 'Audit Trail'],
      'Admin Operasional': ['Kelola Titik Parkir', 'Master Lokasi & Kota', 'Denah Slot IoT', 'Monitoring Lapangan & Overstay'],
      'Admin Finansial': ['Laporan Pendapatan & Omzet', 'Atur Tarif Dinamis', 'Transaksi Real-time', 'Dompet Saldo', 'Booking Tiket'],
      'Admin CS & KYC': ['Verifikasi Dokumen KYC', 'Profil Pelanggan CRM', 'Manajemen Akun User', 'Komplain & Feedback', 'Broadcast Promo', 'Arcade Poin'],
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Text('Edit Admin: ${admin['name']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Peran',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _roleFilters.where((r) => r != 'Semua').map((r) => DropdownMenuItem(value: r, child: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          selectedRole = v;
                          selectedPermissions = List.from(rolePermissions[v] ?? []);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _statusFilters.where((s) => s != 'Semua').map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedStatus = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Lokasi Akses', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allLocations.map((loc) {
                      final isSelected = selectedLocations.contains(loc);
                      return FilterChip(
                        label: Text(loc, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            selected ? selectedLocations.add(loc) : selectedLocations.remove(loc);
                          });
                        },
                        selectedColor: const Color(0xFFE3EEFF),
                        checkmarkColor: const Color(0xFF114177),
                        backgroundColor: const Color(0xFFF1EEE7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Izin (Otomatis per Peran)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rolePermissions[selectedRole]!.map((perm) {
                      final isSelected = selectedPermissions.contains(perm);
                      return FilterChip(
                        label: Text(perm, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            selected ? selectedPermissions.add(perm) : selectedPermissions.remove(perm);
                          });
                        },
                        selectedColor: const Color(0xFFD1F2EB),
                        checkmarkColor: const Color(0xFF17A18A),
                        backgroundColor: const Color(0xFFF1EEE7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  // Cek kuota jika role diubah
                  if (selectedRole != admin['role']) {
                    final conflictAdmin = _admins.firstWhere(
                      (a) => a['role'] == selectedRole && a['id'] != admin['id'],
                      orElse: () => {},
                    );
                    if (conflictAdmin.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (alertCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.white,
                          title: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD94B4B)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Kuota Role Terisi', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                              ),
                            ],
                          ),
                          content: Text(
                            'Role "$selectedRole" sudah dipegang oleh ${conflictAdmin['name']}.\n\nSesuai SOP, kuota akun dibatasi maksimal 1 admin per role.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A)),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(alertCtx),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C1D1F)),
                              child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }

                  setState(() {
                    final idx = _admins.indexWhere((a) => a['id'] == admin['id']);
                    if (idx != -1) {
                      _admins[idx] = {
                        ..._admins[idx],
                        'name': nameCtrl.text,
                        'email': emailCtrl.text,
                        'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : '-',
                        'role': selectedRole,
                        'status': selectedStatus,
                        'avatar': nameCtrl.text[0].toUpperCase(),
                        'locations': selectedLocations.isEmpty ? ['Semua Lokasi'] : selectedLocations,
                        'permissions': selectedPermissions,
                      };
                    }
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Admin ${nameCtrl.text} berhasil diperbarui!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFF17A18A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF114177),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Simpan Perubahan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor ?? const Color(0xFF1A1A18))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _admins.where((a) => a['status'] == 'Aktif').length;

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
            Text('Manajemen Admin', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Akun, Peran & Hak Akses Administrator', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF114177)),
            onPressed: _showAddAdminDialog,
            tooltip: 'Tambah Admin',
          ),
          const SizedBox(width: 8),
        ],
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
                    _buildStatCard('Kuota RBAC', '${_admins.length}/4 Role', const Color(0xFF6D28D9), const Color(0xFFEDE9FE)),
                    const SizedBox(width: 10),
                    _buildStatCard('Akun Aktif', '$activeCount', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                    const SizedBox(width: 10),
                    _buildStatCard('Dibekukan/SOP', '${_admins.where((a) => a['status'] == 'Dibekukan (SOP)' || a['status'] == 'Nonaktif').length}', const Color(0xFFD94B4B), const Color(0xFFFDE8E4)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF6D28D9)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kebijakan SOP: Kuota dibatasi ketat 1 akun per role (Super Admin, Operasional, Finansial, CS & KYC).',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6D28D9)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

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
                            hintText: 'Cari nama, email, ID admin...',
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

          // Role filter chips
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _roleFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _roleFilters[index];
                final isSelected = _selectedRoleFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRoleFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF114177) : const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF45474A),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Status filter chips
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
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF17A18A) : const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF45474A),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Admins List
          Expanded(
            child: _filteredAdmins.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 48, color: Color(0xFF76777B)),
                        const SizedBox(height: 12),
                        Text('Tidak ada admin yang cocok', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF76777B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredAdmins.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final admin = _filteredAdmins[index];
                      final roleColor = _getRoleColor(admin['role']);
                      final roleBg = _getRoleBg(admin['role']);
                      final statusColor = _getStatusColor(admin['status']);
                      final statusBg = _getStatusBg(admin['status']);

                      return GestureDetector(
                        onTap: () => _showAdminDetail(admin),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE4DFD5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(color: roleBg, borderRadius: BorderRadius.circular(14)),
                                child: Center(child: Text(admin['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: roleColor))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(admin['name'], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(color: roleBg, borderRadius: BorderRadius.circular(6)),
                                          child: Text(admin['role'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: roleColor)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(admin['email'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                          child: Text(admin['status'], style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Login: ${admin['lastLogin']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                                      ],
                                    ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}