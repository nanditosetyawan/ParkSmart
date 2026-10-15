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

  final List<String> _roleFilters = ['Semua', 'Super Admin', 'Admin Lokasi', 'Operator', 'Viewer'];
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
      'permissions': ['Manajemen User', 'Konfigurasi Sistem', 'Laporan Keuangan', 'Audit Log'],
      'createdAt': '12 Jan 2024',
    },
    {
      'id': 'ADM-002',
      'name': 'Rina Wijaya',
      'email': 'rina@parksmart.id',
      'phone': '+62 856-7890-1234',
      'role': 'Admin Lokasi',
      'status': 'Aktif',
      'avatar': 'R',
      'lastLogin': 'Hari ini 08:30',
      'locations': ['Central Park Mall', 'Grand Indonesia'],
      'permissions': ['Kelola Slot', 'Monitoring Sesi', 'Verifikasi KTP', 'Injeksi Saldo'],
      'createdAt': '05 Feb 2024',
    },
    {
      'id': 'ADM-003',
      'name': 'Bambang Sutrisno',
      'email': 'bambang@parksmart.id',
      'phone': '+62 878-1122-3344',
      'role': 'Operator',
      'status': 'Aktif',
      'avatar': 'B',
      'lastLogin': '3 hari lalu',
      'locations': ['Malioboro Mall'],
      'permissions': ['Monitoring Sesi', 'Force Check-Out', 'Kirim Notifikasi'],
      'createdAt': '20 Mar 2024',
    },
    {
      'id': 'ADM-004',
      'name': 'Siti Nurhaliza',
      'email': 'siti@parksmart.id',
      'phone': '+62 813-9988-7766',
      'role': 'Admin Lokasi',
      'status': 'Nonaktif',
      'avatar': 'S',
      'lastLogin': '2 minggu lalu',
      'locations': ['Pacific Place SCBD'],
      'permissions': ['Kelola Slot', 'Monitoring Sesi', 'Verifikasi KTP'],
      'createdAt': '10 Apr 2024',
    },
    {
      'id': 'ADM-005',
      'name': 'Andi Saputra',
      'email': 'andi@parksmart.id',
      'phone': '+62 821-4455-6677',
      'role': 'Viewer',
      'status': 'Pending Verifikasi',
      'avatar': 'A',
      'lastLogin': 'Belum login',
      'locations': ['Tunjungan Plaza 6'],
      'permissions': ['Lihat Dashboard', 'Lihat Laporan'],
      'createdAt': 'Hari ini',
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
        return const Color(0xFF7C3AED);
      case 'Admin Lokasi':
        return const Color(0xFF114177);
      case 'Operator':
        return const Color(0xFFE07A5F);
      case 'Viewer':
        return const Color(0xFF17A18A);
      default:
        return const Color(0xFF76777B);
    }
  }

  Color _getRoleBg(String role) {
    switch (role) {
      case 'Super Admin':
        return const Color(0xFFF0E8FF);
      case 'Admin Lokasi':
        return const Color(0xFFE3EEFF);
      case 'Operator':
        return const Color(0xFFFDECE7);
      case 'Viewer':
        return const Color(0xFFD1F2EB);
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
    String selectedRole = 'Operator';
    String selectedStatus = 'Aktif';
    final List<String> selectedLocations = [];
    List<String> selectedPermissions = []; // Removed final

    final allLocations = ['Central Park Mall', 'Grand Indonesia', 'Pacific Place SCBD', 'Malioboro Mall', 'Tunjungan Plaza 6', 'Senayan City'];
    final rolePermissions = {
      'Super Admin': ['Manajemen User', 'Konfigurasi Sistem', 'Laporan Keuangan', 'Audit Log', 'Kelola Slot', 'Monitoring Sesi', 'Verifikasi KTP', 'Injeksi Saldo', 'Force Check-Out', 'Kirim Notifikasi', 'Lihat Dashboard', 'Lihat Laporan'],
      'Admin Lokasi': ['Kelola Slot', 'Monitoring Sesi', 'Verifikasi KTP', 'Injeksi Saldo', 'Lihat Dashboard', 'Lihat Laporan'],
      'Operator': ['Monitoring Sesi', 'Force Check-Out', 'Kirim Notifikasi', 'Lihat Dashboard'],
      'Viewer': ['Lihat Dashboard', 'Lihat Laporan'],
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
                      'locations': selectedLocations.isEmpty ? ['Belum ditentukan'] : selectedLocations,
                      'permissions': selectedPermissions,
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
                Text('Izin & Permission', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEditAdminDialog(admin);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF114177)),
                        label: Text('Edit', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
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
                          backgroundColor: const Color(0xFFD94B4B),
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

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final nameCtrl = TextEditingController(text: admin['name']);
    final emailCtrl = TextEditingController(text: admin['email']);
    final phoneCtrl = TextEditingController(text: admin['phone']);
    String selectedRole = admin['role'];
    String selectedStatus = admin['status'];
    final List<String> selectedLocations = List<String>.from(admin['locations']);
    List<String> selectedPermissions = List<String>.from(admin['permissions']); // Removed final

    final allLocations = ['Central Park Mall', 'Grand Indonesia', 'Pacific Place SCBD', 'Malioboro Mall', 'Tunjungan Plaza 6', 'Senayan City'];
    final rolePermissions = {
      'Super Admin': ['Manajemen User', 'Konfigurasi Sistem', 'Laporan Keuangan', 'Audit Log', 'Kelola Slot', 'Monitoring Sesi', 'Verifikasi KTP', 'Injeksi Saldo', 'Force Check-Out', 'Kirim Notifikasi', 'Lihat Dashboard', 'Lihat Laporan'],
      'Admin Lokasi': ['Kelola Slot', 'Monitoring Sesi', 'Verifikasi KTP', 'Injeksi Saldo', 'Lihat Dashboard', 'Lihat Laporan'],
      'Operator': ['Monitoring Sesi', 'Force Check-Out', 'Kirim Notifikasi', 'Lihat Dashboard'],
      'Viewer': ['Lihat Dashboard', 'Lihat Laporan'],
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
                        'locations': selectedLocations.isEmpty ? ['Belum ditentukan'] : selectedLocations,
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
    final pendingCount = _admins.where((a) => a['status'] == 'Pending Verifikasi').length;
    final inactiveCount = _admins.where((a) => a['status'] == 'Nonaktif').length;

    return Scaffold(
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
                    _buildStatCard('Total Admin', '${_admins.length}', const Color(0xFF114177), const Color(0xFFE3EEFF)),
                    const SizedBox(width: 10),
                    _buildStatCard('Aktif', '$activeCount', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                    const SizedBox(width: 10),
                    _buildStatCard('Pending', '$pendingCount', const Color(0xFFE07A5F), const Color(0xFFFDECE7)),
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
    );
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