import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk ActiveSessionScreen (lib/features/session/active_session_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk performa optimal
class ActiveSessionBackend extends ChangeNotifier {
  ActiveSessionBackend._();
  static final ActiveSessionBackend instance = ActiveSessionBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _sessionData;
  Map<String, dynamic>? get sessionData => _sessionData;

  String _sessionId = 'active-session-001';
  String get sessionId => _sessionId;

  String _locationName = 'Central Park Mall';
  String get locationName => _locationName;

  String _locationSub = 'South Lobby, Basement B2';
  String get locationSub => _locationSub;

  String _slotCode = 'A-05';
  String get slotCode => _slotCode;

  String _floorName = 'Basement 2';
  String get floorName => _floorName;

  String _vehicleName = 'Toyota Raize';
  String get vehicleName => _vehicleName;

  String _plateNumber = 'B 1234 XYZ';
  String get plateNumber => _plateNumber;

  DateTime? _checkInTime;
  DateTime? get checkInTime => _checkInTime;

  DateTime? _expectedCheckOutTime;
  DateTime? get expectedCheckOutTime => _expectedCheckOutTime;

  int _remainingSeconds = 3600 + (42 * 60) + 15; // default ~1h 42m
  int get remainingSeconds => _remainingSeconds;

  double _currentFee = 10000;
  double get currentFee => _currentFee;

  String _sessionCode = '#PS-88210-CP';
  String get sessionCode => _sessionCode;

  /// Memuat sesi parkir aktif dari Supabase
  Future<void> fetchActiveSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = await _client
          .from('parking_sessions')
          .select('id, session_code, location_id, slot_id, vehicle_id, plate_number, vehicle_desc, check_in_time, expected_check_out_time, parking_fee, total_fee, status')
          .eq('status', 'active')
          .order('check_in_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (session != null) {
        _sessionData = session;
        _sessionId = session['id']?.toString() ?? _sessionId;
        _sessionCode = session['session_code']?.toString() ?? _sessionCode;
        _plateNumber = session['plate_number']?.toString() ?? _plateNumber;
        _vehicleName = session['vehicle_desc']?.toString() ?? _vehicleName;
        _currentFee = (session['total_fee'] as num?)?.toDouble() ?? 
                      (session['parking_fee'] as num?)?.toDouble() ?? _currentFee;

        if (session['check_in_time'] != null) {
          _checkInTime = DateTime.tryParse(session['check_in_time'].toString())?.toLocal();
        }

        if (session['expected_check_out_time'] != null) {
          _expectedCheckOutTime = DateTime.tryParse(session['expected_check_out_time'].toString())?.toLocal();
          if (_expectedCheckOutTime != null) {
            final diff = _expectedCheckOutTime!.difference(DateTime.now()).inSeconds;
            _remainingSeconds = diff > 0 ? diff : 0;
          }
        }

        // Ambil info lokasi
        if (session['location_id'] != null) {
          final loc = await _client
              .from('parking_locations')
              .select('name, address')
              .eq('id', session['location_id'])
              .maybeSingle();

          if (loc != null) {
            _locationName = loc['name']?.toString() ?? _locationName;
            _locationSub = loc['address']?.toString() ?? _locationSub;
          }
        }

        // Ambil info slot
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
      debugPrint('[ActiveSessionBackend] fetchActiveSession error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateRemainingSeconds(int seconds) {
    _remainingSeconds = seconds;
    notifyListeners();
  }
}
