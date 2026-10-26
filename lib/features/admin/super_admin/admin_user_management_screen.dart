import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backend/admin_user_management_backend.dart';

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
  // Role yang bisa dibuat / diedit: Super Admin dihilangkan (hanya 1 Super Admin master)
  final List<String> _assignableRoles = ['Admin Operasional', 'Admin Finansial', 'Admin CS & KYC'];
  final List<String> _statusFilters = ['Semua', 'Aktif', 'Nonaktif', 'Pending Verifikasi'];



  final Map<String, List<String>> _rolePermissions = {
    'Super Admin': ['Manajemen User & RBAC', 'Pengaturan Global', 'Konfigurasi AI', 'Audit Trail'],
    'Admin Operasional': ['Kelola Titik Parkir', 'Master Lokasi & Kota', 'Denah Slot IoT', 'Monitoring Lapangan & Overstay'],
    'Admin Finansial': ['Laporan Pendapatan & Omzet', 'Atur Tarif Dinamis', 'Transaksi Real-time', 'Dompet Saldo', 'Booking Tiket'],
    'Admin CS & KYC': ['Verifikasi Dokumen KYC', 'Profil Pelanggan CRM', 'Manajemen Akun User', 'Komplain & Feedback', 'Broadcast Promo', 'Arcade Poin'],
  };

  List<Map<String, dynamic>> get _admins => AdminUserManagementBackend.instance.admins;

  @override
  void initState() {
    super.initState();
    AdminUserManagementBackend.instance.fetchAdmins();
  }

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

  Future<String?> _pickAdminPhoto(BuildContext context) async {
    final picker = ImagePicker();
    return await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Text('Pilih Foto Profil Admin', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFEDE9FE), child: Icon(Icons.photo_library, color: Color(0xFF6D28D9))),
                title: Text('Pilih dari Galeri', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600, imageQuality: 80);
                  if (bottomCtx.mounted) Navigator.pop(bottomCtx, picked?.path);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFD1F2EB), child: Icon(Icons.camera_alt, color: Color(0xFF17A18A))),
                title: Text('Ambil Foto Kamera', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.camera, maxWidth: 600, maxHeight: 600, imageQuality: 80);
                  if (bottomCtx.mounted) Navigator.pop(bottomCtx, picked?.path);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAdminDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscurePassword = true;
    String selectedRole = 'Admin Operasional';
    String selectedStatus = 'Aktif';
    String? tempAvatarPath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final roleColor = _getRoleColor(selectedRole);

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.person_add_alt_1, color: roleColor, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tambah Admin Baru', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                              Text('Atur akun dan peran administrator', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF76777B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFE4DFD5)),

                  // AVATAR PICKER
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: roleColor.withValues(alpha: 0.15),
                          backgroundImage: tempAvatarPath != null ? FileImage(File(tempAvatarPath!)) : null,
                          child: tempAvatarPath == null
                              ? Text(
                                  nameCtrl.text.isNotEmpty ? nameCtrl.text[0].toUpperCase() : 'A',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: roleColor),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final path = await _pickAdminPhoto(context);
                              if (path != null) {
                                setDialogState(() => tempAvatarPath = path);
                              }
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A18),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final path = await _pickAdminPhoto(context);
                        if (path != null) {
                          setDialogState(() => tempAvatarPath = path);
                        }
                      },
                      icon: const Icon(Icons.photo_camera_outlined, size: 14, color: Color(0xFF114177)),
                      label: Text(
                        tempAvatarPath == null ? 'Upload Foto Admin' : 'Ganti Foto',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // NAMA
                  Text('Nama Lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => setDialogState(() {}),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF76777B)),
                      hintText: 'Contoh: Ahmad Fauzi',
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // EMAIL
                  Text('Alamat Email', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF76777B)),
                      hintText: 'ahmad@parksmart.id',
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PHONE
                  Text('Nomor Telepon', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF76777B)),
                      hintText: '+62 812-xxxx-xxxx',
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PASSWORD
                  Text('Kata Sandi Akun', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: obscurePassword,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF76777B)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFF76777B),
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      hintText: 'Minimal 6 karakter',
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ROLE (HANYA OPERASIONAL, FINANSIAL, CS & KYC - SUPER ADMIN DIHILANGKAN)
                  Text('Peran Administrator', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.shield_outlined, size: 20, color: roleColor),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _assignableRoles.map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _getRoleColor(r))),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() {
                          selectedRole = v;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // STATUS
                  Text('Status Akun', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.toggle_on_outlined, size: 20, color: Color(0xFF76777B)),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _statusFilters.where((s) => s != 'Semua').map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _getStatusColor(s))),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedStatus = v);
                    },
                  ),
                  const SizedBox(height: 24),

                  // ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE4DFD5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama dan email wajib diisi!'), backgroundColor: Color(0xFFD94B4B)),
                              );
                              return;
                            }

                            if (passwordCtrl.text.trim().isEmpty || passwordCtrl.text.trim().length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Kata sandi wajib diisi minimal 6 karakter!'), backgroundColor: Color(0xFFD94B4B)),
                              );
                              return;
                            }

                            final newAdminId = 'ADM-${(_admins.length + 1).toString().padLeft(3, '0')}';
                            final newAdminData = {
                              'id': newAdminId,
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '-',
                              'password': passwordCtrl.text.trim(),
                              'role': selectedRole,
                              'status': selectedStatus,
                              'avatar': nameCtrl.text.trim()[0].toUpperCase(),
                              'avatarPath': tempAvatarPath,
                              'lastLogin': 'Baru dibuat',
                              'locations': ['Semua Lokasi'],
                              'permissions': _rolePermissions[selectedRole] ?? [],
                              'createdAt': DateTime.now().toString().split(' ')[0],
                            };

                            AdminUserManagementBackend.instance.addAdmin(newAdminData);

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Admin ${nameCtrl.text.trim()} berhasil ditambahkan!'),
                                backgroundColor: const Color(0xFF17A18A),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: roleColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text('Simpan Data', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
                          clipBehavior: Clip.antiAlias,
                          child: admin['avatarPath'] != null && !kIsWeb && File(admin['avatarPath']).existsSync()
                              ? Image.file(File(admin['avatarPath']), fit: BoxFit.cover)
                              : Center(child: Text(admin['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: roleColor))),
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
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EEE7).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4DFD5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.key, size: 16, color: Color(0xFF6D28D9)),
                          const SizedBox(width: 8),
                          Text(
                            'Kata Sandi (Database)',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF45474A)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              admin['password']?.toString() ?? '-',
                              maxLines: 1,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6D28D9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final pass = admin['password']?.toString() ?? '';
                              Clipboard.setData(ClipboardData(text: pass));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kata sandi / Hash berhasil disalin!'),
                                  backgroundColor: Color(0xFF17A18A),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE4DFD5)),
                              ),
                              child: const Icon(Icons.copy, size: 14, color: Color(0xFF6D28D9)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildDetailRow('Peran', admin['role'], valueColor: roleColor),
                _buildDetailRow('Terdaftar Sejak', admin['createdAt']),
                _buildDetailRow('Login Terakhir', admin['lastLogin']),
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
                              label: Text(
                                'Reset Sandi',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                              ),
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
                          AdminUserManagementBackend.instance.deleteAdmin(admin['id']);
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
              final tempPass = 'admin${100 + (admin['email'].toString().hashCode.abs() % 900)}';
              admin['password'] = tempPass;
              AdminUserManagementBackend.instance.updateAdmin(admin['id'], {...admin, 'password': tempPass});
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kredensial di-reset! Password sementara: $tempPass', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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
    final passwordCtrl = TextEditingController(text: admin['password'] ?? '');
    bool obscurePassword = true;
    String selectedRole = admin['role'];
    String selectedStatus = admin['status'];
    String? tempAvatarPath = admin['avatarPath'];

    final isSuperAdmin = admin['role'] == 'Super Admin';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          final roleColor = _getRoleColor(selectedRole);

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: roleColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.edit_note, color: roleColor, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Edit Data Admin', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                              Text('ID: ${admin['id']} • ${admin['name']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF76777B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFE4DFD5)),

                  // AVATAR PICKER
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: roleColor.withValues(alpha: 0.15),
                          backgroundImage: tempAvatarPath != null ? FileImage(File(tempAvatarPath!)) : null,
                          child: tempAvatarPath == null
                              ? Text(
                                  nameCtrl.text.isNotEmpty ? nameCtrl.text[0].toUpperCase() : admin['avatar'],
                                  style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: roleColor),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final path = await _pickAdminPhoto(context);
                              if (path != null) {
                                setDialogState(() => tempAvatarPath = path);
                              }
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A18),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final path = await _pickAdminPhoto(context);
                        if (path != null) {
                          setDialogState(() => tempAvatarPath = path);
                        }
                      },
                      icon: const Icon(Icons.photo_camera_outlined, size: 14, color: Color(0xFF114177)),
                      label: Text(
                        tempAvatarPath == null ? 'Upload Foto Admin' : 'Ganti Foto',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // NAMA
                  Text('Nama Lengkap', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    onChanged: (_) => setDialogState(() {}),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, size: 20, color: Color(0xFF76777B)),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // EMAIL
                  Text('Alamat Email', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: isSuperAdmin, // Super Admin email locked
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF76777B)),
                      suffixIcon: isSuperAdmin ? const Icon(Icons.lock_outline, size: 18, color: Color(0xFFD94B4B)) : null,
                      filled: true,
                      fillColor: isSuperAdmin ? const Color(0xFFF1EEE7) : const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  if (isSuperAdmin) ...[
                    const SizedBox(height: 4),
                    Text('Email Super Admin permanen demi integritas autentikasi root.', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                  ],
                  const SizedBox(height: 14),

                  // PHONE
                  Text('Nomor Telepon', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF76777B)),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PASSWORD (OPSIONAL UPDATE)
                  Text('Kata Sandi Akun', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: obscurePassword,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF76777B)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFF76777B),
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      hintText: 'Biarkan jika tidak ingin mengubah',
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: roleColor, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ROLE: Jika Super Admin, readonly. Jika bukan, hanya pilih dari _assignableRoles (tanpa Super Admin!)
                  Text('Peran Administrator', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  if (isSuperAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security, color: Color(0xFF6D28D9), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Super Admin (Master Tunggal - Otoritas Tertinggi)',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9)),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _assignableRoles.contains(selectedRole) ? selectedRole : _assignableRoles.first,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.shield_outlined, size: 20, color: roleColor),
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: _assignableRoles.map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _getRoleColor(r))),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            selectedRole = v;
                          });
                        }
                      },
                    ),
                  const SizedBox(height: 14),

                  // STATUS
                  Text('Status Akun', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.toggle_on_outlined, size: 20, color: Color(0xFF76777B)),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE4DFD5))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _statusFilters.where((s) => s != 'Semua').map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _getStatusColor(s))),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedStatus = v);
                    },
                  ),
                  const SizedBox(height: 16),



                  const SizedBox(height: 24),

                  // ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE4DFD5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Batal', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama dan email wajib diisi!'), backgroundColor: Color(0xFFD94B4B)),
                              );
                              return;
                            }

                            final List<String> finalLocations = ['Semua Lokasi'];

                            final updatedData = {
                              ...admin,
                              'name': nameCtrl.text.trim(),
                              'email': isSuperAdmin ? admin['email'] : emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : '-',
                              'role': selectedRole,
                              'status': selectedStatus,
                              'avatar': nameCtrl.text.trim()[0].toUpperCase(),
                              'avatarPath': tempAvatarPath,
                              'locations': finalLocations,
                              'permissions': _rolePermissions[selectedRole] ?? admin['permissions'],
                            };

                            if (passwordCtrl.text.trim().isNotEmpty) {
                              updatedData['password'] = passwordCtrl.text.trim();
                            }

                            AdminUserManagementBackend.instance.updateAdmin(admin['id'], updatedData);

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Data Admin ${nameCtrl.text.trim()} berhasil diperbarui!'),
                                backgroundColor: const Color(0xFF17A18A),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: roleColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text('Simpan Perubahan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
    return ListenableBuilder(
      listenable: AdminUserManagementBackend.instance,
      builder: (context, _) {
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
                    _buildStatCard('Kuota', '${_admins.length}/4 Role', const Color(0xFF6D28D9), const Color(0xFFEDE9FE)),
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
                                clipBehavior: Clip.antiAlias,
                                child: admin['avatarPath'] != null && !kIsWeb && File(admin['avatarPath']).existsSync()
                                    ? Image.file(File(admin['avatarPath']), fit: BoxFit.cover)
                                    : Center(child: Text(admin['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: roleColor))),
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
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(6)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.key, size: 10, color: Color(0xFF6D28D9)),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${admin['password'] ?? '-'}',
                                                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text('Login: ${admin['lastLogin']}', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)), overflow: TextOverflow.ellipsis),
                                        ),
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
  },
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