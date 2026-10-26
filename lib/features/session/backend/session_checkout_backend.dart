import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/parking_notification_service.dart';

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

  int _durationHours = 1;
  int get durationHours => _durationHours;

  double _parkingRate = 5000;
  double get parkingRate => _parkingRate;

  final double _serviceFee = 0;
  double get serviceFee => _serviceFee;

  final double _discountAmount = 0;
  double get discountAmount => _discountAmount;

  double _totalPayment = 5000;
  double get totalPayment => _totalPayment;

  double get parkingFeeOnly {
    final fee = _totalPayment - _serviceFee + _discountAmount;
    return fee > 0 ? fee : _parkingRate;
  }

  final String _paymentMethod = 'ParkSmart Pay';
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
          .select('id, session_code, location_id, slot_id, plate_number, vehicle_desc, check_in_time, check_out_time, parking_fee, total_fee, gate_out_id, status, booking_id');

      final session = sessionId != null
          ? await query.eq('id', sessionId).maybeSingle()
          : await query.eq('status', 'active').order('check_in_time', ascending: false).limit(1).maybeSingle();

      if (session != null) {
        _activeSessionId = session['id']?.toString();
        _plateNumber = session['plate_number']?.toString() ?? _plateNumber;
        _vehicleName = session['vehicle_desc']?.toString() ?? _vehicleName;
        _gateExitName = session['gate_out_id']?.toString() ?? _gateExitName;
        _parkingRate = (session['parking_fee'] as num?)?.toDouble() ?? _parkingRate;
        _totalPayment = (session['total_fee'] as num?)?.toDouble() ?? _parkingRate;

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

        // Cek booking awal untuk menyinkronkan jam WIB yang dipilih diawal & durasi paket
        if (session['booking_id'] != null) {
          final bRes = await _client
              .from('bookings')
              .select('start_time, end_time, duration_hours, total_price')
              .eq('id', session['booking_id'])
              .maybeSingle();

          if (bRes != null) {
            _durationHours = (bRes['duration_hours'] as num?)?.toInt() ?? _durationHours;
            if (bRes['total_price'] != null) {
              _totalPayment = (bRes['total_price'] as num).toDouble();
            }
            if (bRes['start_time'] != null && bRes['end_time'] != null) {
              final bStart = DateTime.tryParse(bRes['start_time'].toString())?.toLocal();
              final bEnd = DateTime.tryParse(bRes['end_time'].toString())?.toLocal();
              if (bStart != null && bEnd != null) {
                _timeRange = '${bStart.hour.toString().padLeft(2, '0')}:${bStart.minute.toString().padLeft(2, '0')} - ${bEnd.hour.toString().padLeft(2, '0')}:${bEnd.minute.toString().padLeft(2, '0')}';
                _totalDuration = '$_durationHours Jam';
              }
            }
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
      } else {
        // Fallback: periksa tabel bookings jika pengguna langsung checkout dari reservasi aktif
        final booking = await _client
            .from('bookings')
            .select('id, booking_code, location_id, slot_id, vehicle_id, start_time, end_time, total_price, duration_hours, booking_status')
            .inFilter('booking_status', ['upcoming', 'active'])
            .order('start_time', ascending: false)
            .limit(1)
            .maybeSingle();

        if (booking != null) {
          _activeSessionId = booking['id']?.toString();
          _totalPayment = (booking['total_price'] as num?)?.toDouble() ?? _totalPayment;
          _durationHours = (booking['duration_hours'] as num?)?.toInt() ?? 1;
          _parkingRate = _totalPayment;

          if (booking['start_time'] != null) {
            final inTime = DateTime.tryParse(booking['start_time'].toString())?.toLocal();
            final outTime = booking['end_time'] != null
                ? DateTime.tryParse(booking['end_time'].toString())?.toLocal()
                : DateTime.now();

            if (inTime != null && outTime != null) {
              _totalDuration = '$_durationHours Jam';
              _timeRange = '${inTime.hour.toString().padLeft(2, '0')}:${inTime.minute.toString().padLeft(2, '0')} - ${outTime.hour.toString().padLeft(2, '0')}:${outTime.minute.toString().padLeft(2, '0')}';
            }
          }

          if (booking['location_id'] != null) {
            final loc = await _client
                .from('parking_locations')
                .select('name')
                .eq('id', booking['location_id'])
                .maybeSingle();
            if (loc != null) _locationName = loc['name']?.toString() ?? _locationName;
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

          if (booking['vehicle_id'] != null) {
            final veh = await _client
                .from('vehicles')
                .select('plate_number, brand, model')
                .eq('id', booking['vehicle_id'])
                .maybeSingle();
            if (veh != null) {
              _plateNumber = veh['plate_number']?.toString() ?? _plateNumber;
              _vehicleName = '${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim();
            }
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
      final now = DateTime.now().toUtc().toIso8601String();

      // Cari relasi booking_id dan slot_id jika ini adalah parking_sessions
      final sessionRow = await _client
          .from('parking_sessions')
          .select('booking_id, slot_id')
          .eq('id', _activeSessionId!)
          .maybeSingle();

      final relatedBookingId = sessionRow?['booking_id']?.toString();
      final relatedSlotId = sessionRow?['slot_id']?.toString();

      // 1. Coba update parking_sessions
      await _client.from('parking_sessions').update({
        'status': 'completed',
        'check_out_time': now,
        'total_fee': totalPayment,
      }).eq('id', _activeSessionId!);

      // 2. Coba update bookings jika id adalah booking id atau terkait
      await _client.from('bookings').update({
        'booking_status': 'completed',
      }).eq('id', _activeSessionId!);

      if (relatedBookingId != null && relatedBookingId.isNotEmpty) {
        await _client.from('bookings').update({
          'booking_status': 'completed',
        }).eq('id', relatedBookingId);
      }

      // 3. Kembalikan status slot menjadi available
      if (relatedSlotId != null && relatedSlotId.isNotEmpty) {
        await _client.from('parking_slots').update({
          'status': 'available',
          'current_plate_number': null,
          'occupied_since': null,
        }).eq('id', relatedSlotId);
      } else if (_slotCode != '-' && _slotCode.isNotEmpty) {
        await _client.from('parking_slots').update({
          'status': 'available',
          'current_plate_number': null,
          'occupied_since': null,
        }).eq('slot_code', _slotCode);
      }
      
      // Hentikan notifikasi darurat & monitor background saat checkout berhasil
      await ParkingNotificationService().onSessionEnded();

      return true;
    } catch (e) {
      debugPrint('[SessionCheckoutBackend] completeSessionCheckout error: $e');
      return false;
    }
  }
}
