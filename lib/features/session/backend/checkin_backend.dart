import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk CheckinScreen (lib/features/session/checkin_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk performa optimal
class CheckinBackend extends ChangeNotifier {
  CheckinBackend._();
  static final CheckinBackend instance = CheckinBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _bookingCode = '#PS-88210-CP';
  String get bookingCode => _bookingCode;

  String _locationName = 'Central Park Mall';
  String get locationName => _locationName;

  String _locationSub = 'South Lobby, Basement B2';
  String get locationSub => _locationSub;

  String _slotCode = 'A-05';
  String get slotCode => _slotCode;

  String _floorName = 'Basement 2';
  String get floorName => _floorName;

  String _plateNumber = 'B 1234 XYZ';
  String get plateNumber => _plateNumber;

  final String _gateName = 'Gate Masuk 01';
  String get gateName => _gateName;

  String _vehicleDesc = '';
  String get vehicleDesc => _vehicleDesc;

  String? _bookingId;
  String? _locationId;
  String? _slotId;
  String? _userId;
  String? _vehicleId;
  double _totalPrice = 11000.0;

  /// Memuat detail tiket yang siap check-in
  Future<void> fetchCheckinTicket({String? bookingId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = _client
          .from('bookings')
          .select('id, booking_code, user_id, location_id, slot_id, vehicle_id, booking_status, total_price');

      final dynamic booking;
      if (bookingId != null && bookingId.isNotEmpty) {
        booking = await query.eq('id', bookingId).maybeSingle();
      } else {
        booking = await query
            .inFilter('booking_status', ['upcoming', 'active'])
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
      }

      if (booking != null) {
        _bookingId = booking['id']?.toString();
        _bookingCode = booking['booking_code']?.toString() ?? _bookingCode;
        _userId = booking['user_id']?.toString();
        _vehicleId = booking['vehicle_id']?.toString();
        _locationId = booking['location_id']?.toString();
        _slotId = booking['slot_id']?.toString();
        _totalPrice = (booking['total_price'] as num?)?.toDouble() ?? _totalPrice;

        if (_locationId != null) {
          final loc = await _client
              .from('parking_locations')
              .select('name, address')
              .eq('id', _locationId!)
              .maybeSingle();
          if (loc != null) {
            _locationName = loc['name']?.toString() ?? _locationName;
            _locationSub = loc['address']?.toString() ?? _locationSub;
          }
        }

        if (_slotId != null) {
          final slot = await _client
              .from('parking_slots')
              .select('slot_code, floor_name')
              .eq('id', _slotId!)
              .maybeSingle();
          if (slot != null) {
            _slotCode = slot['slot_code']?.toString() ?? _slotCode;
            _floorName = slot['floor_name']?.toString() ?? _floorName;
          }
        }

        if (booking['vehicle_id'] != null) {
          final veh = await _client
              .from('vehicles')
              .select('plate_number, brand, model')
              .eq('id', booking['vehicle_id'])
              .maybeSingle();
          if (veh != null) {
            _plateNumber = veh['plate_number']?.toString() ?? _plateNumber;
            _vehicleDesc = '${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim();
          }
        }
      }
    } catch (e) {
      debugPrint('[CheckinBackend] fetchCheckinTicket error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Eksekusi aktivasi sesi di gerbang (Check-in ANPR / QR Scan)
  Future<bool> processGateCheckin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final expectedOut = now.add(const Duration(hours: 2));

      // 1. Update status booking menjadi 'active'
      if (_bookingId != null) {
        await _client.from('bookings').update({
          'booking_status': 'active',
        }).eq('id', _bookingId!);
      }

      // 2. Buat / update record sesi parkir aktif
      final sessionCode = 'SES-${Random().nextInt(900000) + 100000}';
      await _client.from('parking_sessions').insert({
        'session_code': sessionCode,
        'booking_id': _bookingId,
        'location_id': _locationId ?? 'a0000000-0000-0000-0000-000000000001',
        'slot_id': _slotId,
        'user_id': _userId,
        'vehicle_id': _vehicleId,
        'plate_number': _plateNumber,
        'vehicle_desc': _vehicleDesc.isNotEmpty ? _vehicleDesc : 'Kendaraan Pribadi',
        'check_in_time': now.toUtc().toIso8601String(),
        'expected_check_out_time': expectedOut.toUtc().toIso8601String(),
        'parking_fee': _totalPrice,
        'total_fee': _totalPrice,
        'status': 'active',
        'gate_in_id': _gateName,
      });

      // 3. Update status slot menjadi 'occupied'
      if (_slotId != null) {
        await _client.from('parking_slots').update({
          'status': 'occupied',
          'current_plate_number': _plateNumber,
          'occupied_since': now.toUtc().toIso8601String(),
        }).eq('id', _slotId!);
      }

      return true;
    } catch (e) {
      debugPrint('[CheckinBackend] processGateCheckin error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
