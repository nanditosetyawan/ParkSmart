import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../admin/operations/backend/admin_operations_dashboard_backend.dart';
import '../../profile/backend/profile_backend.dart';
import 'active_session_backend.dart';

/// Backend khusus untuk ExpiringSessionScreen (lib/features/session/expiring_session_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk performa optimal
class ExpiringSessionBackend extends ChangeNotifier {
  ExpiringSessionBackend._();
  static final ExpiringSessionBackend instance = ExpiringSessionBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _sessionId;
  int _remainingSeconds = 581; // 09:41
  int get remainingSeconds => _remainingSeconds;

  String _locationName = 'Central Park Mall';
  String get locationName => _locationName;

  String _slotCode = 'A-05';
  String get slotCode => _slotCode;

  String _floorName = 'Basement B2';
  String get floorName => _floorName;

  String _plateNumber = 'B 1234 XYZ';
  String get plateNumber => _plateNumber;

  DateTime? _expectedCheckOut;

  /// Memuat info sesi parkir yang hampir habis
  Future<void> fetchExpiringSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _client
          .from('parking_sessions')
          .select('id, location_id, slot_id, plate_number, expected_check_out_time')
          .eq('status', 'active')
          .order('check_in_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (session != null) {
        _sessionId = session['id']?.toString();
        _plateNumber = session['plate_number']?.toString() ?? _plateNumber;

        if (session['expected_check_out_time'] != null) {
          _expectedCheckOut = DateTime.tryParse(session['expected_check_out_time'].toString())?.toLocal();
          if (_expectedCheckOut != null) {
            final diff = _expectedCheckOut!.difference(DateTime.now()).inSeconds;
            _remainingSeconds = diff > 0 ? diff : 0;
          }
        }

        if (session['location_id'] != null) {
          final loc = await _client
              .from('parking_locations')
              .select('name')
              .eq('id', session['location_id'])
              .maybeSingle();
          if (loc != null) _locationName = loc['name']?.toString() ?? _locationName;
        }

        if (session['slot_id'] != null) {
          final slot = await _client
              .from('parking_slots')
              .select('slot_code, floor_name')
              .eq('id', session['slot_id'])
              .maybeSingle();
          if (slot != null) {
            _slotCode = slot['slot_code']?.toString() ?? _slotCode;
            _floorName = slot['floor_name']?.toString() ?? _floorName;
          }
        }
      }
    } catch (e) {
      debugPrint('[ExpiringSessionBackend] fetchExpiringSession error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eksekusi perpanjangan cepat dari layar sesi hampir habis
  Future<bool> quickExtendMinutes(int minutes, double cost) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newEnd = (_expectedCheckOut ?? DateTime.now()).add(Duration(minutes: minutes));

      if (_sessionId != null) {
        // 1. Update parking_sessions
        try {
          final res = await _client.from('parking_sessions').update({
            'expected_check_out_time': newEnd.toUtc().toIso8601String(),
          }).or('id.eq.$_sessionId,session_code.eq.$_sessionId').select('id, booking_id');

          if (res.isNotEmpty && res[0]['booking_id'] != null) {
            await _client.from('bookings').update({
              'end_time': newEnd.toUtc().toIso8601String(),
            }).eq('id', res[0]['booking_id']);
          }
        } catch (_) {}

        // 2. Update bookings jika _sessionId adalah booking_id
        try {
          await _client.from('bookings').update({
            'end_time': newEnd.toUtc().toIso8601String(),
          }).or('id.eq.$_sessionId,booking_code.eq.$_sessionId');
        } catch (_) {}

        _expectedCheckOut = newEnd;

        final code = 'PAY-EXP-${Random().nextInt(900000) + 100000}';
        final uid = ProfileBackend.instance.userId.isNotEmpty
            ? ProfileBackend.instance.userId
            : (SessionService.instance.userId ?? '');
        try {
          await _client.from('payments').insert({
            'transaction_code': code,
            'session_id': _sessionId,
            'user_id': uid,
            'transaction_type': 'parking_payment',
            'payment_method': 'wallet',
            'amount': cost,
            'description': 'Quick Extend $minutes Menit',
            'status': 'success',
          });
        } catch (_) {}

        // 3. Sinkronisasi ke ActiveSessionBackend (sisi user) & Admin Dashboard (sisi admin)
        await ActiveSessionBackend.instance.fetchActiveSession();
        await AdminOperationsDashboardBackend.instance.fetchDashboardData();
      }
      return true;
    } catch (e) {
      debugPrint('[ExpiringSessionBackend] quickExtendMinutes error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
