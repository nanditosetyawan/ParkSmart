import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AdminUserManagementScreen
/// Mengelola staf admin (Super Admin, Operasional, Finansial, CS)
/// Terkoneksi langsung ke tabel `public.admins` di Supabase
class AdminUserManagementBackend extends ChangeNotifier {
  AdminUserManagementBackend._();
  static final AdminUserManagementBackend instance = AdminUserManagementBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool isLoading = false;
  String? errorMessage;

  final List<Map<String, dynamic>> _defaultAdmins = [
    {
      'id': 'ADM-001',
      'name': 'Dito Pratama',
      'email': 'dito@parksmart.id',
      'phone': '+62 812-3456-7890',
      'role': 'Super Admin',
      'status': 'Aktif',
      'avatar': 'D',
      'avatarPath': null,
      'lastLogin': '2 jam lalu',
      'locations': ['Semua Lokasi'],
      'permissions': ['Manajemen User & RBAC', 'Pengaturan Global', 'Konfigurasi AI', 'Audit Trail'],
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
      'avatarPath': null,
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
      'avatarPath': null,
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
      'avatarPath': null,
      'lastLogin': '1 jam lalu',
      'locations': ['Semua Lokasi'],
      'permissions': ['Verifikasi Dokumen KYC', 'Profil Pelanggan CRM', 'Manajemen Akun User', 'Komplain & Feedback', 'Broadcast Promo', 'Arcade Poin'],
      'createdAt': '10 Apr 2024',
    },
  ];

  late List<Map<String, dynamic>> admins = List.from(_defaultAdmins);

  /// Mengambil daftar admin dari Supabase tabel `public.admins`
  Future<void> fetchAdmins() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _client
          .from('admins')
          .select('id, email, full_name, phone, role, division, avatar_url, status, last_login_at, created_at')
          .order('created_at', ascending: true);

      if (response.isNotEmpty) {
        admins = response.map<Map<String, dynamic>>((row) {
          final fullName = row['full_name'] as String? ?? 'Admin';
          final roleString = _mapRole(row['role'] as String?);
          final statusString = (row['status'] == 'active') ? 'Aktif' : 'Nonaktif';

          return {
            'id': row['id']?.toString() ?? 'ADM-000',
            'name': fullName,
            'email': row['email'] as String? ?? 'admin@parksmart.id',
            'phone': row['phone'] as String? ?? '-',
            'role': roleString,
            'status': statusString,
            'avatar': fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
            'avatarPath': row['avatar_url'] as String?,
            'lastLogin': row['last_login_at'] != null ? 'Baru saja' : 'Belum pernah',
            'locations': ['Semua Lokasi'],
            'permissions': _getPermissionsForRole(roleString),
            'createdAt': (row['created_at'] as String?)?.split('T')[0] ?? '2024-01-01',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('[AdminUserManagementBackend] fetchAdmins error: $e');
      errorMessage = e.toString();
      // Tetap gunakan fallback data default agar UI tidak kosong
      if (admins.isEmpty) {
        admins = List.from(_defaultAdmins);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _mapRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return 'Super Admin';
      case 'operational':
      case 'ops':
        return 'Admin Operasional';
      case 'finance':
        return 'Admin Finansial';
      case 'cs':
      case 'support':
        return 'Admin CS & KYC';
      default:
        return role ?? 'Admin Operasional';
    }
  }

  String _mapRoleToDb(String role) {
    switch (role) {
      case 'Super Admin':
        return 'super_admin';
      case 'Admin Operasional':
        return 'operational';
      case 'Admin Finansial':
        return 'finance';
      case 'Admin CS & KYC':
        return 'cs';
      default:
        return 'operational';
    }
  }

  List<String> _getPermissionsForRole(String role) {
    switch (role) {
      case 'Super Admin':
        return ['Manajemen User & RBAC', 'Pengaturan Global', 'Konfigurasi AI', 'Audit Trail'];
      case 'Admin Operasional':
        return ['Kelola Titik Parkir', 'Master Lokasi & Kota', 'Denah Slot IoT', 'Monitoring Lapangan & Overstay'];
      case 'Admin Finansial':
        return ['Laporan Pendapatan & Omzet', 'Atur Tarif Dinamis', 'Transaksi Real-time', 'Dompet Saldo', 'Booking Tiket'];
      case 'Admin CS & KYC':
        return ['Verifikasi Dokumen KYC', 'Profil Pelanggan CRM', 'Manajemen Akun User', 'Komplain & Feedback', 'Broadcast Promo', 'Arcade Poin'];
      default:
        return ['Akses Standar Admin'];
    }
  }

  /// Tambah admin baru ke memori & Supabase
  Future<bool> addAdmin(Map<String, dynamic> admin) async {
    admins.insert(0, admin);
    notifyListeners();

    try {
      final roleDb = _mapRoleToDb(admin['role'] as String? ?? 'Admin Operasional');
      await _client.from('admins').insert({
        'email': admin['email'] ?? 'admin@parksmart.id',
        'full_name': admin['name'] ?? 'Admin Baru',
        'phone': admin['phone'] ?? '-',
        'role': roleDb,
        'division': admin['role'] ?? 'Operasional',
        'status': admin['status'] == 'Aktif' ? 'active' : 'inactive',
      });
      return true;
    } catch (e) {
      debugPrint('[AdminUserManagementBackend] addAdmin error: $e');
      return false;
    }
  }

  /// Perbarui admin
  Future<bool> updateAdmin(String id, Map<String, dynamic> updated) async {
    final idx = admins.indexWhere((a) => a['id'] == id);
    if (idx != -1) {
      admins[idx] = updated;
      notifyListeners();
    }

    try {
      final roleDb = _mapRoleToDb(updated['role'] as String? ?? 'Admin Operasional');
      await _client.from('admins').update({
        'full_name': updated['name'],
        'email': updated['email'],
        'phone': updated['phone'],
        'role': roleDb,
        'status': updated['status'] == 'Aktif' ? 'active' : 'inactive',
      }).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[AdminUserManagementBackend] updateAdmin error: $e');
      return false;
    }
  }

  /// Hapus admin
  Future<bool> deleteAdmin(String id) async {
    admins.removeWhere((a) => a['id'] == id);
    notifyListeners();

    try {
      await _client.from('admins').delete().eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[AdminUserManagementBackend] deleteAdmin error: $e');
      return false;
    }
  }

  /// Toggle status aktif/nonaktif
  Future<bool> setStatus(String id, String status) async {
    final idx = admins.indexWhere((a) => a['id'] == id);
    if (idx != -1) {
      admins[idx]['status'] = status;
      notifyListeners();
    }

    try {
      await _client.from('admins').update({
        'status': status == 'Aktif' ? 'active' : 'inactive',
      }).eq('id', id);
      return true;
    } catch (e) {
      debugPrint('[AdminUserManagementBackend] setStatus error: $e');
      return false;
    }
  }
}
