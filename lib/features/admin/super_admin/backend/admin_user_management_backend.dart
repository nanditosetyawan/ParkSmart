import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/hash_util.dart';

/// Backend khusus untuk AdminUserManagementScreen
/// Mengelola staf admin (Super Admin, Operasional, Finansial, CS)
/// Terkoneksi langsung ke tabel `public.admins` di Supabase
class AdminUserManagementBackend extends ChangeNotifier {
  AdminUserManagementBackend._();
  static final AdminUserManagementBackend instance = AdminUserManagementBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool isLoading = false;
  String? errorMessage;

  List<Map<String, dynamic>> admins = [];

  /// Mengambil daftar admin dari Supabase tabel `public.admins`
  Future<void> fetchAdmins() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _client
          .from('admins')
          .select('id, email, full_name, phone, role, division, avatar_url, status, last_login_at, created_at, password')
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
            'password': row['password']?.toString() ?? '-',
            'avatar': fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
            'avatarPath': row['avatar_url'] as String?,
            'lastLogin': row['last_login_at'] != null ? 'Baru saja' : 'Belum pernah',
            'locations': ['Semua Lokasi'],
            'permissions': _getPermissionsForRole(roleString),
            'createdAt': (row['created_at'] as String?)?.split('T')[0] ?? '2024-01-01',
          };
        }).toList();
      } else {
        admins = [];
      }
    } catch (e) {
      debugPrint('[AdminUserManagementBackend] fetchAdmins error: $e');
      errorMessage = e.toString();
      admins = [];
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
      final plainPassword = admin['password']?.toString() ?? 'superadmin123';
      final inserted = await _client.from('admins').insert({
        'email': admin['email'] ?? 'admin@parksmart.id',
        'full_name': admin['name'] ?? 'Admin Baru',
        'phone': admin['phone'] ?? '-',
        'role': roleDb,
        'division': admin['role'] ?? 'Operasional',
        'status': admin['status'] == 'Aktif' ? 'active' : 'inactive',
        'password': HashUtil.hashPassword(plainPassword),
      }).select().single();

      admin['id'] = inserted['id']?.toString() ?? admin['id'];
      notifyListeners();
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
      final Map<String, dynamic> updatePayload = {
        'full_name': updated['name'],
        'email': updated['email'],
        'phone': updated['phone'],
        'role': roleDb,
        'status': updated['status'] == 'Aktif' ? 'active' : 'inactive',
      };
      if (updated['password'] != null && updated['password'].toString().isNotEmpty) {
        final rawPass = updated['password'].toString();
        // Hanya hash jika belum berupa hash (hash SHA-256 panjangnya 64 karakter heksadesimal)
        final isAlreadyHashed = rawPass.length == 64 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(rawPass);
        updatePayload['password'] = isAlreadyHashed ? rawPass : HashUtil.hashPassword(rawPass);
      }
      await _client.from('admins').update(updatePayload).eq('id', id);
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
