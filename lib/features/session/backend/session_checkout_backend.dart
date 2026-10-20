import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk SessionCheckoutScreen (lib/features/session/session_checkout_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk performa optimal
class SessionCheckoutBackend extends ChangeNotifier {
  SessionCheckoutBackend._();
  static final SessionCheckoutBackend instance = SessionCheckoutBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userName = 'Pengguna';
  String get userName => _userName;

  String _gateExitName = '-';
  String get gateExitName => _gateExitName;

  String _vehicleName = '-';
  String get vehicleName => _vehicleName;

  String _plateNumber = '-';
  String get plateNumber => _plateNumber;

  String _locationName = '-';
  String get locationName => _locationName;

  String _slotCode = '-';
  String get slotCode => _slotCode;

  String _floorName = '-';
  String get floorName => _floorName;

  String _totalDuration = '-';
  String get totalDuration => _totalDuration;

  String _timeRange = '-';
  String get timeRange => _timeRange;

  double _parkingRate = 0;
  double get parkingRate => _parkingRate;

  double _sensorFee = 0;
  double get sensorFee => _sensorFee;

  double _discountAmount = 0;
  double get discountAmount => _discountAmount;

  double get totalPayment => (_parkingRate + _sensorFee) - _discountAmount;

  String _paymentMethod = 'ParkSmart Pay';
  String get paymentMethod => _paymentMethod;

  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;
  bool get hasSession => _activeSessionId != null;

  /// Memuat detail sesi yang akan / baru saja selesai checkout
  Future<void> fetchCheckoutDetails({String? sessionId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil nama user
      final user = await _client
          .from('users')
          .select('full_name')
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();
      if (user != null && user['full_name'] != null) {
        _userName = user['full_name'].toString().split(' ').first;
      }

      // 2. Ambil sesi parkir
      var query = _client
          .from('parking_sessions')
          .select('id, session_code, location_id, slot_id, plate_number, vehicle_desc, check_in_time, check_out_time, parking_fee, total_fee, gate_out_id, status');

      final session = sessionId != null
          ? await query.eq('id', sessionId).maybeSingle()
          : await query.order('created_at', ascending: false).limit(1).maybeSingle();

      if (session != null) {
        _activeSessionId = session['id']?.toString();
        _plateNumber = session['plate_number']?.toString() ?? _plateNumber;
        _vehicleName = session['vehicle_desc']?.toString() ?? _vehicleName;
        _gateExitName = session['gate_out_id']?.toString() ?? _gateExitName;
        _parkingRate = (session['parking_fee'] as num?)?.toDouble() ?? _parkingRate;

        if (session['check_in_time'] != null) {
          final inTime = DateTime.tryParse(session['check_in_time'].toString())?.toLocal();
          final outTime = session['check_out_time'] != null
              ? DateTime.tryParse(session['check_out_time'].toString())?.toLocal()
              : DateTime.now();

          if (inTime != null && outTime != null) {
            final diff = outTime.difference(inTime);
            final hrs = diff.inHours;
            final mins = diff.inMinutes % 60;
            _totalDuration = '$hrs Jam $mins Menit';
            _timeRange = '${inTime.hour.toString().padLeft(2, '0')}:${inTime.minute.toString().padLeft(2, '0')} - ${outTime.hour.toString().padLeft(2, '0')}:${outTime.minute.toString().padLeft(2, '0')}';
          }
        }

        // Lokasi
        if (session['location_id'] != null) {
          final loc = await _client
              .from('parking_locations')
              .select('name')
              .eq('id', session['location_id'])
              .maybeSingle();
          if (loc != null) _locationName = loc['name']?.toString() ?? _locationName;
        }

        // Slot
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
      debugPrint('[SessionCheckoutBackend] fetchCheckoutDetails error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Konfirmasi penyelesaian sesi di Supabase
  Future<bool> completeSessionCheckout() async {
    if (_activeSessionId == null) return true;

    try {
      await _client.from('parking_sessions').update({
        'status': 'completed',
        'check_out_time': DateTime.now().toUtc().toIso8601String(),
        'total_fee': totalPayment,
      }).eq('id', _activeSessionId!);
      return true;
    } catch (e) {
      debugPrint('[SessionCheckoutBackend] completeSessionCheckout error: $e');
      return false;
    }
  }
}
