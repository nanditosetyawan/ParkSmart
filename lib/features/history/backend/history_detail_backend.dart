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
  String _locationName = '-';
  String _locationDetail = '-';
  String _vehicleInfo = '-';
  String _checkInTime = '-';
  String _checkOutTime = '-';
  String _duration = '-';
  String _paymentMethod = '-';
  int _baseFee = 0;
  int _serviceFee = 0;
  int _discount = 0;
  int _totalAmount = 0;
  String _status = TicketMark.selesai;

  String get transactionCode => _transactionCode;
  String get locationName => _locationName;
  String get locationDetail => _locationDetail;
  String get vehicleInfo => _vehicleInfo;
  String get checkInTime => _checkInTime;
  String get checkOutTime => _checkOutTime;
  String get duration => _duration;
  String get paymentMethod => _paymentMethod;
  int get baseFee => _baseFee;
  int get serviceFee => _serviceFee;
  int get discount => _discount;
  int get totalAmount => _totalAmount;
  String get status => _status;

  Future<void> fetchDetail(String? id) async {
    if (id == null || id.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Cek pada tabel parking_sessions
      final res = await _client
          .from('parking_sessions')
          .select('session_code, plate_number, vehicle_desc, check_in_time, check_out_time, total_fee, status, parking_locations(name, address)')
          .eq('id', id)
          .maybeSingle();

      if (res != null) {
        _hasData = true;
        _transactionCode = res['session_code'] ?? _transactionCode;
        _vehicleInfo = '${res['vehicle_desc'] ?? 'Mobil'} (${res['plate_number'] ?? 'B 1234 XYZ'})';
        if (res['total_fee'] != null) {
          _totalAmount = (double.tryParse(res['total_fee'].toString()) ?? _totalAmount.toDouble()).toInt();
          _baseFee = _totalAmount;
        }
        if (res['check_in_time'] != null) {
          try {
            final ci = DateTime.parse(res['check_in_time'].toString()).toLocal();
            _checkInTime = '${ci.hour.toString().padLeft(2, '0')}:${ci.minute.toString().padLeft(2, '0')} WIB';
          } catch (_) {}
        }
        if (res['check_out_time'] != null) {
          try {
            final co = DateTime.parse(res['check_out_time'].toString()).toLocal();
            _checkOutTime = '${co.hour.toString().padLeft(2, '0')}:${co.minute.toString().padLeft(2, '0')} WIB';
          } catch (_) {}
        } else {
          _checkOutTime = 'Sedang Berlangsung';
        }
        if (res['check_in_time'] != null && res['check_out_time'] != null) {
          try {
            final ci = DateTime.parse(res['check_in_time'].toString());
            final co = DateTime.parse(res['check_out_time'].toString());
            final diff = co.difference(ci);
            final hours = diff.inHours;
            final mins = diff.inMinutes % 60;
            _duration = '${hours}j ${mins}m';
          } catch (_) {}
        }
        _paymentMethod = res['payment_method']?.toString() ?? 'ParkSmart Pay';
        _serviceFee = 2000;
        _discount = 0;
        _status = TicketMark.resolve(sessionStatus: res['status']);
        if (res['parking_locations'] != null) {
          _locationName = res['parking_locations']['name'] ?? _locationName;
          _locationDetail = res['parking_locations']['address'] ?? _locationDetail;
        }
      } else {
        // 2. Jika tidak ada di parking_sessions, cari pada tabel bookings
        final bRes = await _client
            .from('bookings')
            .select('booking_code, start_time, end_time, total_price, payment_status, booking_status, parking_locations(name, address), vehicles(brand, model, plate_number)')
            .eq('id', id)
            .maybeSingle();

        if (bRes != null) {
          _hasData = true;
          _transactionCode = bRes['booking_code'] ?? _transactionCode;
          _totalAmount = (double.tryParse(bRes['total_price'].toString()) ?? _totalAmount.toDouble()).toInt();
          _status = TicketMark.resolve(
            paymentStatus: bRes['payment_status']?.toString(),
            bookingStatus: bRes['booking_status']?.toString(),
          );
          if (bRes['vehicles'] != null) {
            final veh = bRes['vehicles'];
            _vehicleInfo = '${veh['brand'] ?? 'Kendaraan'} ${veh['model'] ?? ''} (${veh['plate_number'] ?? ''})'.trim();
          }
          if (bRes['parking_locations'] != null) {
            _locationName = bRes['parking_locations']['name'] ?? _locationName;
            _locationDetail = bRes['parking_locations']['address'] ?? _locationDetail;
          }
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
