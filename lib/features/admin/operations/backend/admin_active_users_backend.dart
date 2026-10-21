import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ActiveUsersScreen (admin_active_users_screen.dart)
/// Memonitor kendaraan yang sedang parkir, mendeteksi overstay, dan status EV charging
/// Terkoneksi ke `public.parking_sessions` di Supabase
class AdminActiveUsersBackend extends ChangeNotifier {
  AdminActiveUsersBackend._();
  static final AdminActiveUsersBackend instance = AdminActiveUsersBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  late List<Map<String, dynamic>> sessions = [];

  /// Mengambil sesi parkir aktif & overstay dari Supabase
  Future<void> fetchActiveSessions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_sessions')
          .select('id, session_code, plate_number, vehicle_desc, vehicle_type, check_in_time, parking_fee, total_fee, is_overstay, overstay_minutes, status')
          .inFilter('status', ['active', 'overstay'])
          .order('check_in_time', ascending: false);

      if (res.isNotEmpty) {
        sessions = res.map<Map<String, dynamic>>((row) {
          final isEv = row['vehicle_type'] == 'ev';
          final fee = (row['total_fee'] as num?)?.toDouble() ?? 
                      (row['parking_fee'] as num?)?.toDouble() ?? 10000;

          return {
            'id': row['session_code']?.toString() ?? 'SES-000',
            'db_id': row['id']?.toString(),
            'plate': row['plate_number']?.toString() ?? 'B 1234 XYZ',
            'user': 'Pengguna ParkSmart',
            'phone': '+62 812-xxxx-xxxx',
            'type': isEv ? 'EV Charging' : 'Mobil',
            'vehicle': row['vehicle_desc']?.toString() ?? 'Kendaraan',
            'location': 'Lokasi Parkir',
            'slot': 'Lantai Parkir',
            'checkIn': 'Baru saja',
            'duration': '1j 30m',
            'fee': 'Rp ${fee.toStringAsFixed(0)}',
            'isOverstay': row['is_overstay'] == true,
            'overstayDuration': '${row['overstay_minutes'] ?? 0} mnt',
            'isEv': isEv,
          };
        }).toList();
      } else {
        sessions = [];
      }
    } catch (e) {
      debugPrint('[AdminActiveUsersBackend] fetchActiveSessions error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selesaikan paksa sesi (Emergency Gate Out)
  Future<bool> forceCheckout(String sessionId) async {
    sessions.removeWhere((s) => s['id'] == sessionId);
    notifyListeners();

    try {
      await _client.from('parking_sessions').update({
        'status': 'completed',
        'check_out_time': DateTime.now().toIso8601String(),
      }).eq('session_code', sessionId);
      return true;
    } catch (e) {
      debugPrint('[AdminActiveUsersBackend] forceCheckout error: $e');
      return false;
    }
  }
}
