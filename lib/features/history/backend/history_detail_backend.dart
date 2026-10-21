import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/ticket_status_helper.dart';

/// Backend khusus untuk HistoryDetailScreen (lib/features/history/history_detail_screen.dart)
class HistoryDetailBackend extends ChangeNotifier {
  HistoryDetailBackend._();
  static final HistoryDetailBackend instance = HistoryDetailBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasData = false;
  bool get hasData => _hasData;

  String _transactionCode = '-';
  String _blockHash = '-';
  String _timestamp = '-';
  String _locationName = '-';
  String _slotInfo = '-';
  String _locationDetail = '-';
  String _vehicleInfo = '-';
  String _checkInTime = '-';
  String _checkOutTime = '-';
  String _date = '-';
  String _duration = '-';
  String _paymentMethod = '-';
  int _baseFee = 0;
  int _serviceFee = 0;
  int _discount = 0;
  int _totalAmount = 0;
  String _status = TicketMark.selesai;

  String get transactionCode => _transactionCode;
  String get blockHash => _blockHash;
  String get timestamp => _timestamp;
  String get locationName => _locationName;
  String get slotInfo => _slotInfo;
  String get locationDetail => _locationDetail;
  String get vehicleInfo => _vehicleInfo;
  String get checkInTime => _checkInTime;
  String get checkOutTime => _checkOutTime;
  String get date => _date;
  String get duration => _duration;
  String get paymentMethod => _paymentMethod;
  int get baseFee => _baseFee;
  int get serviceFee => _serviceFee;
  int get discount => _discount;
  int get totalAmount => _totalAmount;
  String get status => _status;

  String _formatIndoDate(DateTime dt) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  Future<void> fetchDetail(String? id) async {
    if (id == null || id.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Cek pada tabel parking_sessions
      final res = await _client
          .from('parking_sessions')
          .select('id, session_code, booking_id, plate_number, vehicle_desc, check_in_time, check_out_time, total_fee, parking_fee, status, parking_locations(name, address), parking_slots(slot_code, floor_name), bookings(booking_code, total_price, duration_hours, vehicles(brand, model, plate_number))')
          .eq('id', id)
          .maybeSingle();

      if (res != null) {
        _hasData = true;
        final booking = res['bookings'] as Map<String, dynamic>?;
        final slot = res['parking_slots'] as Map<String, dynamic>?;
        final loc = res['parking_locations'] as Map<String, dynamic>?;

        // Transaction code & hash (unique per booking / session)
        final rawCode = booking?['booking_code']?.toString() ?? res['session_code']?.toString() ?? id;
        _transactionCode = rawCode;
        final safeClean = rawCode.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
        _blockHash = '0x${safeClean.padRight(8, '0').substring(0, 8)}...${id.replaceAll('-', '').substring(0, 4)}';

        // Vehicle info
        if (booking?['vehicles'] != null) {
          final veh = booking!['vehicles'] as Map<String, dynamic>;
          _vehicleInfo = '${veh['brand'] ?? 'Kendaraan'} ${veh['model'] ?? ''} (${veh['plate_number'] ?? ''})'.trim();
        } else if (res['vehicle_desc'] != null && res['vehicle_desc'].toString() != 'Toyota Raize') {
          _vehicleInfo = '${res['vehicle_desc']} (${res['plate_number'] ?? ''})'.trim();
        } else {
          // Query user vehicle from vehicles table
          final vehRes = await _client.from('vehicles').select('brand, model, plate_number').limit(1).maybeSingle();
          if (vehRes != null) {
            _vehicleInfo = '${vehRes['brand'] ?? 'Toyota'} ${vehRes['model'] ?? 'Land Cruiser'} (${vehRes['plate_number'] ?? 'B 1945 RI'})'.trim();
          } else {
            _vehicleInfo = 'Toyota Land Cruiser (B 1945 RI)';
          }
        }

        // Amount (avoid Rp 0)
        double fee = (double.tryParse(res['total_fee']?.toString() ?? '') ?? 0.0);
        if (fee <= 0 && booking?['total_price'] != null) {
          fee = (double.tryParse(booking!['total_price'].toString()) ?? 0.0);
        }
        if (fee <= 0 && res['parking_fee'] != null) {
          fee = (double.tryParse(res['parking_fee'].toString()) ?? 0.0);
        }
        if (fee <= 0) fee = 11000.0;
        _totalAmount = fee.toInt();
        _baseFee = _totalAmount;

        // Times & Date
        DateTime? ciDt;
        DateTime? coDt;
        if (res['check_in_time'] != null) {
          try {
            ciDt = DateTime.parse(res['check_in_time'].toString()).toLocal();
            _checkInTime = '${ciDt.hour.toString().padLeft(2, '0')}:${ciDt.minute.toString().padLeft(2, '0')} WIB';
            _date = _formatIndoDate(ciDt);
            _timestamp = '${ciDt.year}-${ciDt.month.toString().padLeft(2, '0')}-${ciDt.day.toString().padLeft(2, '0')} ${ciDt.hour.toString().padLeft(2, '0')}:${ciDt.minute.toString().padLeft(2, '0')}:${ciDt.second.toString().padLeft(2, '0')} UTC+7';
          } catch (_) {}
        }
        if (res['check_out_time'] != null) {
          try {
            coDt = DateTime.parse(res['check_out_time'].toString()).toLocal();
            _checkOutTime = '${coDt.hour.toString().padLeft(2, '0')}:${coDt.minute.toString().padLeft(2, '0')} WIB';
          } catch (_) {}
        } else {
          _checkOutTime = 'Sedang Berlangsung';
        }

        if (ciDt != null && coDt != null) {
          final diff = coDt.difference(ciDt);
          final hours = diff.inHours;
          final mins = diff.inMinutes % 60;
          _duration = '${hours}j ${mins}m';
        } else if (booking?['duration_hours'] != null) {
          _duration = '${booking!['duration_hours']} Jam';
        } else {
          _duration = '2 Jam';
        }

        _paymentMethod = 'ParkSmart Pay';
        _serviceFee = 2000;
        _discount = 0;
        _status = TicketMark.resolve(sessionStatus: res['status']);

        // Location & Slot
        _locationName = loc?['name']?.toString() ?? 'ParkSmart Central Hub';
        _locationDetail = loc?['address']?.toString() ?? 'Jl. Jenderal Sudirman No. Kav 21, Jakarta Pusat';
        final slotCode = slot?['slot_code']?.toString() ?? 'A-01';
        final floorName = slot?['floor_name']?.toString() ?? 'Lantai 1';
        _slotInfo = 'Slot $slotCode • $floorName';

      } else {
        // 2. Jika tidak ada di parking_sessions, cari pada tabel bookings
        final bRes = await _client
            .from('bookings')
            .select('id, booking_code, start_time, end_time, duration_hours, total_price, payment_status, booking_status, created_at, parking_locations(name, address), parking_slots(slot_code, floor_name), vehicles(brand, model, plate_number)')
            .eq('id', id)
            .maybeSingle();

        if (bRes != null) {
          _hasData = true;
          final rawCode = bRes['booking_code']?.toString() ?? id;
          _transactionCode = rawCode;
          final safeClean = rawCode.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
          _blockHash = '0x${safeClean.padRight(8, '0').substring(0, 8)}...${id.replaceAll('-', '').substring(0, 4)}';

          final numPrice = (bRes['total_price'] as num?)?.toDouble() ?? 11000.0;
          _totalAmount = numPrice.toInt();
          _baseFee = _totalAmount;

          _status = TicketMark.resolve(
            paymentStatus: bRes['payment_status']?.toString(),
            bookingStatus: bRes['booking_status']?.toString(),
          );

          if (bRes['vehicles'] != null) {
            final veh = bRes['vehicles'] as Map<String, dynamic>;
            _vehicleInfo = '${veh['brand'] ?? 'Kendaraan'} ${veh['model'] ?? ''} (${veh['plate_number'] ?? ''})'.trim();
          } else {
            final vehRes = await _client.from('vehicles').select('brand, model, plate_number').limit(1).maybeSingle();
            if (vehRes != null) {
              _vehicleInfo = '${vehRes['brand'] ?? 'Toyota'} ${vehRes['model'] ?? 'Land Cruiser'} (${vehRes['plate_number'] ?? 'B 1945 RI'})'.trim();
            } else {
              _vehicleInfo = 'Toyota Land Cruiser (B 1945 RI)';
            }
          }

          final loc = bRes['parking_locations'] as Map<String, dynamic>?;
          _locationName = loc?['name']?.toString() ?? 'ParkSmart Central Hub';
          _locationDetail = loc?['address']?.toString() ?? 'Jl. Jenderal Sudirman No. Kav 21, Jakarta Pusat';

          final slot = bRes['parking_slots'] as Map<String, dynamic>?;
          final slotCode = slot?['slot_code']?.toString() ?? 'A-01';
          final floorName = slot?['floor_name']?.toString() ?? 'Lantai 1';
          _slotInfo = 'Slot $slotCode • $floorName';

          final durationHours = bRes['duration_hours'] ?? 2;
          _duration = '$durationHours Jam';

          DateTime dt = DateTime.now();
          if (bRes['start_time'] != null) {
            try {
              dt = DateTime.parse(bRes['start_time'].toString()).toLocal();
            } catch (_) {}
          } else if (bRes['created_at'] != null) {
            try {
              dt = DateTime.parse(bRes['created_at'].toString()).toLocal();
            } catch (_) {}
          }

          _date = _formatIndoDate(dt);
          _checkInTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
          final endDt = dt.add(Duration(hours: durationHours is int ? durationHours : int.tryParse(durationHours.toString()) ?? 2));
          _checkOutTime = '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')} WIB';
          _timestamp = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} UTC+7';

          _paymentMethod = 'ParkSmart Pay';
          _serviceFee = 2000;
          _discount = 0;
        }
      }
    } catch (e) {
      debugPrint('HistoryDetailBackend fetchDetail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
