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

  /// Helper format jam masuk relatif (dinamis)
  static String formatRelativeCheckIn(DateTime? checkInDt, {bool multiline = false}) {
    if (checkInDt == null) return 'Baru saja';
    final now = DateTime.now();
    final diffSecs = now.difference(checkInDt).inSeconds;
    if (diffSecs < 60) {
      return 'Baru saja';
    }
    final diffMins = diffSecs ~/ 60;
    if (diffMins < 60) {
      return multiline ? '$diffMins menit\nlalu' : '$diffMins menit lalu';
    }
    final hours = diffMins ~/ 60;
    final remMins = diffMins % 60;
    if (remMins == 0) {
      return multiline ? '$hours jam\nlalu' : '$hours jam lalu';
    }
    return multiline ? '$hours j $remMins m\nlalu' : '$hours jam $remMins mnt lalu';
  }

  /// Mengambil sesi parkir aktif & overstay dari Supabase
  Future<void> fetchActiveSessions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_sessions')
          .select('''
            id,
            session_code,
            plate_number,
            vehicle_desc,
            vehicle_type,
            check_in_time,
            expected_check_out_time,
            parking_fee,
            total_fee,
            is_overstay,
            overstay_minutes,
            status,
            slot_id,
            location_id,
            booking_id,
            users(full_name, phone),
            parking_locations(name, address),
            parking_slots(slot_code, floor_name)
          ''')
          .inFilter('status', ['active', 'overstay'])
          .order('check_in_time', ascending: false);

      if (res.isNotEmpty) {
        sessions = res.map<Map<String, dynamic>>((row) {
          final isEv = (row['vehicle_type'] ?? '').toString().toLowerCase().contains('ev') ||
                       (row['vehicle_desc'] ?? '').toString().toLowerCase().contains('ev');
          final fee = (row['total_fee'] as num?)?.toDouble() ?? 
                      (row['parking_fee'] as num?)?.toDouble() ?? 10000;

          final userData = row['users'] is Map<String, dynamic> ? row['users'] as Map<String, dynamic> : null;
          final locData = row['parking_locations'] is Map<String, dynamic> ? row['parking_locations'] as Map<String, dynamic> : null;
          final slotData = row['parking_slots'] is Map<String, dynamic> ? row['parking_slots'] as Map<String, dynamic> : null;

          final userName = userData?['full_name']?.toString() ?? 'Pengguna ParkSmart';
          final userPhone = userData?['phone']?.toString() ?? '+62 812-xxxx-xxxx';
          final locName = locData?['name']?.toString() ?? 'Lokasi Parkir';
          final slotCode = slotData?['slot_code']?.toString() ?? 'Slot Parkir';
          final floorName = slotData?['floor_name']?.toString() ?? 'Lantai 1';

          final checkInDt = DateTime.tryParse(row['check_in_time']?.toString() ?? '')?.toLocal();
          final expOutDt = DateTime.tryParse(row['expected_check_out_time']?.toString() ?? '')?.toLocal();

          String checkInFormatted = '-';
          if (checkInDt != null) {
            checkInFormatted = '${checkInDt.hour.toString().padLeft(2, '0')}:${checkInDt.minute.toString().padLeft(2, '0')} WIB';
          }

          final now = DateTime.now();
          String durationStr = '1j';
          bool isOverstay = row['is_overstay'] == true;
          int overstayMins = (row['overstay_minutes'] as num?)?.toInt() ?? 0;

          if (checkInDt != null) {
            final elapsedSecs = now.difference(checkInDt).inSeconds;
            if (elapsedSecs > 0) {
              final h = elapsedSecs ~/ 3600;
              final m = (elapsedSecs % 3600) ~/ 60;
              durationStr = h > 0 ? '${h}j ${m}m' : '${m}m';
            }
          }

          if (expOutDt != null) {
            final diffSecs = expOutDt.difference(now).inSeconds;
            if (diffSecs <= 0) {
              isOverstay = true;
              overstayMins = (-diffSecs) ~/ 60;
            }
          }

          return {
            'id': row['session_code']?.toString() ?? 'SES-000',
            'db_id': row['id']?.toString(),
            'booking_id': row['booking_id']?.toString(),
            'location_id': row['location_id']?.toString() ?? '',
            'slot_id': row['slot_id']?.toString() ?? '',
            'plate': row['plate_number']?.toString() ?? 'B 1234 XYZ',
            'user': userName,
            'phone': userPhone,
            'type': isEv ? 'EV Charging' : 'Mobil',
            'vehicle': row['vehicle_desc']?.toString() ?? 'Kendaraan',
            'location': locName,
            'slot': slotCode,
            'floor': floorName,
            'raw_check_in_time': checkInDt,
            'raw_expected_check_out_time': expOutDt,
            'checkInFormatted': checkInFormatted,
            'duration': durationStr,
            'fee': 'Rp ${fee.toStringAsFixed(0)}',
            'isOverstay': isOverstay,
            'overstayDuration': '$overstayMins mnt',
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
    sessions.removeWhere((s) => s['id'] == sessionId || s['db_id'] == sessionId);
    notifyListeners();

    try {
      final sess = await _client
          .from('parking_sessions')
          .select('id, slot_id, booking_id')
          .or('id.eq.$sessionId,session_code.eq.$sessionId')
          .maybeSingle();

      if (sess != null) {
        final realId = sess['id'];
        final slotId = sess['slot_id'];
        final bookingId = sess['booking_id'];
        final now = DateTime.now().toUtc();

        // 1. Selesaikan sesi parkir ini
        await _client.from('parking_sessions').update({
          'status': 'completed',
          'check_out_time': now.toIso8601String(),
        }).eq('id', realId);

        // 2. Bebaskan slot parkir jika ada
        if (slotId != null) {
          await _client.from('parking_slots').update({
            'status': 'available',
            'current_plate_number': null,
            'occupied_since': null,
          }).eq('id', slotId);
        }

        // 3. Selesaikan status booking terkait
        if (bookingId != null) {
          await _client.from('bookings').update({
            'booking_status': 'completed',
          }).eq('id', bookingId);
        }
      } else {
        await _client.from('parking_sessions').update({
          'status': 'completed',
          'check_out_time': DateTime.now().toUtc().toIso8601String(),
        }).or('session_code.eq.$sessionId,id.eq.$sessionId');
      }
      return true;
    } catch (e) {
      debugPrint('[AdminActiveUsersBackend] forceCheckout error: $e');
      return false;
    }
  }
}
