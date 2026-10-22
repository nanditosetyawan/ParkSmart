import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AdminCustomerProfilesScreen (admin_customer_profiles_screen.dart)
/// Mengelola daftar profil pelanggan (CRM), status KYC, saldo dompet, riwayat kendaraan, dan preferensi
/// Terkoneksi secara realtime ke tabel `public.users`, `public.vehicles`, dan `public.user_kyc` di Supabase
class AdminCustomerProfilesBackend extends ChangeNotifier {
  AdminCustomerProfilesBackend._();
  static final AdminCustomerProfilesBackend instance = AdminCustomerProfilesBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> customers = [];

  RealtimeChannel? _realtimeChannel;

  /// Memulai langganan realtime Supabase
  void initRealtimeSubscription() {
    if (_realtimeChannel != null) return;
    try {
      _realtimeChannel = _client.channel('public:admin_customer_profiles')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            debugPrint('[AdminCustomerProfilesBackend] Realtime update dari users');
            fetchCustomers();
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'vehicles',
          callback: (payload) {
            debugPrint('[AdminCustomerProfilesBackend] Realtime update dari vehicles');
            fetchCustomers();
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_kyc',
          callback: (payload) {
            debugPrint('[AdminCustomerProfilesBackend] Realtime update dari user_kyc');
            fetchCustomers();
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('[AdminCustomerProfilesBackend] initRealtimeSubscription error: $e');
    }
  }

  /// Melepas langganan realtime
  void disposeRealtime() {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
  }

  String _formatDate(dynamic dateRaw) {
    if (dateRaw == null) return '-';
    try {
      final dt = DateTime.parse(dateRaw.toString()).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateRaw.toString();
    }
  }

  /// Mengambil data seluruh pengguna asli dari Supabase
  Future<void> fetchCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil seluruh user dari tabel users
      final userRes = await _client
          .from('users')
          .select('id, full_name, email, phone, status, wallet_balance, created_at, avatar_url')
          .order('created_at', ascending: false);

      if (userRes.isEmpty) {
        customers = [];
        return;
      }

      // 2. Ambil data kendaraan terdaftar
      List<dynamic> vehicleRes = [];
      try {
        vehicleRes = await _client
            .from('vehicles')
            .select('id, user_id, plate_number, vehicle_type, vehicle_category, brand, model, color, is_default');
      } catch (e) {
        debugPrint('[AdminCustomerProfilesBackend] vehicles query error: $e');
      }

      // 3. Ambil data KYC user
      List<dynamic> kycRes = [];
      try {
        kycRes = await _client
            .from('user_kyc')
            .select('id, user_id, status, nik, submitted_at, reviewed_at');
      } catch (e) {
        debugPrint('[AdminCustomerProfilesBackend] user_kyc query error: $e');
      }

      // 4. Ambil statistik sesi parkir
      List<dynamic> sessionRes = [];
      try {
        sessionRes = await _client.from('parking_sessions').select('id, user_id');
      } catch (_) {}

      // 5. Ambil data pengeluaran (payments)
      List<dynamic> paymentRes = [];
      try {
        paymentRes = await _client.from('payments').select('id, user_id, amount, status');
      } catch (_) {}

      // Susun mapping data
      final Map<String, List<Map<String, dynamic>>> vehiclesByUser = {};
      for (var v in vehicleRes) {
        final uid = v['user_id']?.toString() ?? '';
        if (uid.isEmpty) continue;
        final vType = (v['vehicle_type']?.toString().toLowerCase() == 'motorcycle') ? 'Motor' : 'Mobil';
        vehiclesByUser.putIfAbsent(uid, () => []).add({
          'plate': v['plate_number']?.toString() ?? '-',
          'type': vType,
          'brand': v['brand']?.toString() ?? 'Kendaraan',
          'model': v['model']?.toString() ?? '',
          'color': v['color']?.toString() ?? '',
          'isDefault': v['is_default'] == true,
        });
      }

      final Map<String, Map<String, dynamic>> kycByUser = {};
      for (var k in kycRes) {
        final uid = k['user_id']?.toString() ?? '';
        if (uid.isNotEmpty) {
          kycByUser[uid] = Map<String, dynamic>.from(k);
        }
      }

      final Map<String, int> sessionsByUser = {};
      for (var s in sessionRes) {
        final uid = s['user_id']?.toString() ?? '';
        if (uid.isNotEmpty) {
          sessionsByUser[uid] = (sessionsByUser[uid] ?? 0) + 1;
        }
      }

      final Map<String, num> spentByUser = {};
      for (var p in paymentRes) {
        final uid = p['user_id']?.toString() ?? '';
        final status = p['status']?.toString().toLowerCase();
        if (uid.isNotEmpty && (status == 'paid' || status == 'success' || status == 'completed')) {
          final amt = (p['amount'] as num?) ?? 0;
          spentByUser[uid] = (spentByUser[uid] ?? 0) + amt;
        }
      }

      // 6. Map ke format UI Admin CS
      customers = userRes.map<Map<String, dynamic>>((row) {
        final uid = row['id']?.toString() ?? '';
        final name = row['full_name']?.toString() ?? 'Pengguna ParkSmart';
        final email = row['email']?.toString() ?? '-';
        final phone = row['phone']?.toString() ?? '-';
        final rawStatus = row['status']?.toString().toLowerCase() ?? 'active';

        String statusLabel = 'Aktif';
        if (rawStatus == 'banned') {
          statusLabel = 'Diblokir';
        } else if (rawStatus == 'inactive') {
          statusLabel = 'Tidak Aktif';
        }

        final userKyc = kycByUser[uid];
        String kycStatus = 'Belum Submit';
        String? kycSubmittedAt;
        String? kycApprovedAt;

        if (userKyc != null) {
          final kStatus = userKyc['status']?.toString().toLowerCase();
          if (kStatus == 'approved' || kStatus == 'verified') {
            kycStatus = 'Terverifikasi';
          } else if (kStatus == 'rejected') {
            kycStatus = 'Ditolak';
          } else if (kStatus == 'pending') {
            kycStatus = 'Pending';
          }
          kycSubmittedAt = _formatDate(userKyc['submitted_at']);
          kycApprovedAt = userKyc['reviewed_at'] != null ? _formatDate(userKyc['reviewed_at']) : null;
        }

        final userVehicles = vehiclesByUser[uid] ?? [];
        final totalSessions = sessionsByUser[uid] ?? 0;
        final totalSpent = spentByUser[uid] ?? 0;
        final num walletBal = (row['wallet_balance'] as num?) ?? 0;

        final avatarLetter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
        // Menggunakan ID pengguna asli (UUID) langsung dari tabel users di database Supabase
        final displayId = uid;

        return {
          'id': displayId,
          'rawId': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'avatar': avatarLetter,
          'avatar_url': row['avatar_url']?.toString(),
          'status': statusLabel,
          'kycStatus': kycStatus,
          'kycSubmittedAt': kycSubmittedAt ?? '-',
          'kycApprovedAt': kycApprovedAt,
          'joinDate': _formatDate(row['created_at']),
          'lastActive': 'Baru saja',
          'totalSessions': totalSessions,
          'totalSpent': totalSpent,
          'walletBalance': walletBal,
          'vehicles': userVehicles,
          'preferences': {
            'notifBooking': true,
            'notifReminder': true,
            'notifPromo': false,
            'theme': 'Sistem',
            'language': 'Indonesia',
            'currency': 'IDR',
            'timezone': 'WIB',
          },
        };
      }).toList();
    } catch (e) {
      debugPrint('[AdminCustomerProfilesBackend] fetchCustomers error: $e');
      _errorMessage = e.toString();
      customers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
