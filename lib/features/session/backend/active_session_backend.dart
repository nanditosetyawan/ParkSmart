import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/parking_notification_service.dart';

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

  double? _latitude;
  double? _longitude;
  String _locationType = 'Area Parkir';

  Map<String, dynamic> get destinationParking => {
    'name': _locationName,
    'type': _locationType,
    'address': _locationSub,
    'point': LatLng(_latitude ?? -6.1788, _longitude ?? 106.7916),
  };

  String _slotCode = 'A-05';
  String get slotCode => _slotCode;

  String _floorName = 'Basement 2';
  String get floorName => _floorName;

  String _vehicleName = 'Kendaraan';
  String get vehicleName => _vehicleName;

  String _plateNumber = '-';
  String get plateNumber => _plateNumber;

  DateTime? _checkInTime;
  DateTime? get checkInTime => _checkInTime;

  DateTime? _expectedCheckOutTime;
  DateTime? get expectedCheckOutTime => _expectedCheckOutTime;

  int _durationHours = 1;
  int get durationHours => _durationHours;

  String get checkInFormatted {
    if (_checkInTime == null) return '14:02 WIB';
    final h = _checkInTime!.hour.toString().padLeft(2, '0');
    final m = _checkInTime!.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  String get deadlineFormatted {
    if (_expectedCheckOutTime == null) return '15:02 WIB';
    final h = _expectedCheckOutTime!.hour.toString().padLeft(2, '0');
    final m = _expectedCheckOutTime!.minute.toString().padLeft(2, '0');
    return '$h:$m WIB';
  }

  int _remainingSeconds = 3600;
  int get remainingSeconds => _remainingSeconds;

  double _currentFee = 5000;
  double get currentFee => _currentFee;

  String _sessionCode = '-';
  String get sessionCode => _sessionCode;

  /// Memuat sesi parkir aktif dari Supabase
  Future<void> fetchActiveSession({String? sessionId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = _client
          .from('parking_sessions')
          .select('id, session_code, location_id, slot_id, vehicle_id, plate_number, vehicle_desc, check_in_time, expected_check_out_time, parking_fee, total_fee, status, booking_id');

      final dynamic session;
      if (sessionId != null && sessionId.isNotEmpty) {
        session = await query.eq('id', sessionId).maybeSingle();
      } else {
        session = await query
            .eq('status', 'active')
            .order('check_in_time', ascending: false)
            .limit(1)
            .maybeSingle();
      }

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

        // ============================================================================
        // [PETUNJUK PRESENTASI - MEKANISME TIMER TIKET & SINKRONISASI SERVER]
        // Kolom Database: 'expected_check_out_time' pada tabel 'public.parking_sessions'
        // Cara Kerja Timer:
        // 1. Sistem TIDAK menyimpan angka countdown statis (misal 3600), melainkan membaca
        //    timestamp target checkout dari database: DateTime.tryParse(session['expected_check_out_time'])
        // 2. Sisa waktu dihitung dinamis: expectedCheckOutTime.difference(DateTime.now()).inSeconds
        // 3. KEBAL REFRESH & KEBAL HP MATI (Timestamp Absolut vs Stopwatch):
        //    - Saat di-refresh (pull-down), waktu TIDAK ter-reset karena target timestamp di DB tetap sama.
        //    - Saat HP mati dan hidup kembali, timer TIDAK ter-reset ke awal, melainkan langsung
        //      menghitung selisih target waktu dengan jam saat HP hidup kembali.
        // 4. TESTING DOSEN (INJECT 1 MENIT):
        //    UPDATE public.parking_sessions SET expected_check_out_time = NOW() + INTERVAL '1 minute' WHERE status = 'active';
        // ============================================================================
        if (session['expected_check_out_time'] != null) {
          _expectedCheckOutTime = DateTime.tryParse(session['expected_check_out_time'].toString())?.toLocal();
          if (_expectedCheckOutTime != null) {
            final diff = _expectedCheckOutTime!.difference(DateTime.now()).inSeconds;
            _remainingSeconds = diff > 0 ? diff : 0;
            // Sinkronisasi otomatis ke background monitor agar tetap terpantau saat app ditutup
            ParkingNotificationService().saveActiveSession(expectedCheckout: _expectedCheckOutTime!);
            ParkingNotificationService.startBackgroundMonitor(expectedCheckout: _expectedCheckOutTime!);
          }
        }

        if (session['booking_id'] != null) {
          final bRes = await _client
              .from('bookings')
              .select('duration_hours')
              .eq('id', session['booking_id'])
              .maybeSingle();
          if (bRes != null && bRes['duration_hours'] != null) {
            _durationHours = (bRes['duration_hours'] as num).toInt();
          }
        } else if (_expectedCheckOutTime != null && _checkInTime != null) {
          final diffMins = _expectedCheckOutTime!.difference(_checkInTime!).inMinutes;
          final hrs = (diffMins / 60.0).round();
          if (hrs > 0) _durationHours = hrs;
        }

        // Ambil info lokasi
        if (session['location_id'] != null) {
          final loc = await _client
              .from('parking_locations')
              .select('name, address, latitude, longitude, type')
              .eq('id', session['location_id'])
              .maybeSingle();

          if (loc != null) {
            _locationName = loc['name']?.toString() ?? _locationName;
            _locationSub = loc['address']?.toString() ?? _locationSub;
            _latitude = (loc['latitude'] as num?)?.toDouble();
            _longitude = (loc['longitude'] as num?)?.toDouble();
            _locationType = loc['type']?.toString() ?? 'Area Parkir';
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
      } else {
        // Cek juga dari tabel bookings jika ada reservasi slot aktif
        final booking = await _client
            .from('bookings')
            .select('id, booking_code, slot_id, location_id, end_time, start_time, total_price, duration_hours')
            .inFilter('booking_status', ['upcoming', 'active'])
            .order('start_time', ascending: false)
            .limit(1)
            .maybeSingle();

        if (booking != null) {
          _sessionData = booking;
          _sessionId = booking['id']?.toString() ?? _sessionId;
          _sessionCode = booking['booking_code']?.toString() ?? _sessionCode;
          _currentFee = (booking['total_price'] as num?)?.toDouble() ?? _currentFee;
          _durationHours = (booking['duration_hours'] as num?)?.toInt() ?? 1;

          if (booking['start_time'] != null) {
            _checkInTime = DateTime.tryParse(booking['start_time'].toString())?.toLocal();
          }

          if (booking['end_time'] != null) {
            _expectedCheckOutTime = DateTime.tryParse(booking['end_time'].toString())?.toLocal();
            if (_expectedCheckOutTime != null) {
              final diff = _expectedCheckOutTime!.difference(DateTime.now()).inSeconds;
              _remainingSeconds = diff > 0 ? diff : 0;
            }
          }

          if (booking['location_id'] != null) {
            final loc = await _client
                .from('parking_locations')
                .select('name, address, latitude, longitude, type')
                .eq('id', booking['location_id'])
                .maybeSingle();

            if (loc != null) {
              _locationName = loc['name']?.toString() ?? _locationName;
              _locationSub = loc['address']?.toString() ?? _locationSub;
              _latitude = (loc['latitude'] as num?)?.toDouble();
              _longitude = (loc['longitude'] as num?)?.toDouble();
              _locationType = loc['type']?.toString() ?? 'Area Parkir';
            }
          }

          if (booking['slot_id'] != null) {
            final slot = await _client
                .from('parking_slots')
                .select('slot_code, floor_name')
                .eq('id', booking['slot_id'])
                .maybeSingle();

            if (slot != null) {
              _slotCode = slot['slot_code']?.toString() ?? _slotCode;
              _floorName = slot['floor_name']?.toString() ?? _floorName;
            }
          }
        } else {
          _sessionData = null;
        }
      }
    } catch (e) {
      debugPrint('[ActiveSessionBackend] fetchActiveSession error: $e');
      _sessionData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get hasActiveSession => _sessionData != null;

  void updateRemainingSeconds(int seconds) {
    _remainingSeconds = seconds;
    notifyListeners();
  }
}
