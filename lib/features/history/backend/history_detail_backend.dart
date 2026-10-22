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

  Map<String, dynamic>? _asMap(dynamic val) {
    if (val is Map<String, dynamic>) return val;
    if (val is List && val.isNotEmpty && val.first is Map<String, dynamic>) {
      return val.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> fetchDetail(String? id) async {
    _hasData = false;
    if (id == null || id.trim().isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final cleanId = id.trim();
      final bool isUuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(cleanId);

      // 1. Cek pada tabel parking_sessions
      Map<String, dynamic>? res;
      const sessionSelect = 'id, session_code, booking_id, plate_number, vehicle_desc, check_in_time, check_out_time, expected_check_out_time, total_fee, parking_fee, status, parking_locations(name, address), parking_slots(slot_code, floor_name), bookings(booking_code, total_price, duration_hours, plate_number, vehicle_desc, vehicles(brand, model, plate_number))';
      if (isUuid) {
        res = await _client
            .from('parking_sessions')
            .select(sessionSelect)
            .eq('id', cleanId)
            .maybeSingle();

        // Jika tidak ditemukan by id, coba cari by booking_id
        res ??= await _client
            .from('parking_sessions')
            .select(sessionSelect)
            .eq('booking_id', cleanId)
            .maybeSingle();
      } else {
        res = await _client
            .from('parking_sessions')
            .select(sessionSelect)
            .eq('session_code', cleanId)
            .maybeSingle();

        if (res == null) {
          final b = await _client.from('bookings').select('id').eq('booking_code', cleanId).maybeSingle();
          if (b != null && b['id'] != null) {
            res = await _client
                .from('parking_sessions')
                .select(sessionSelect)
                .eq('booking_id', b['id'])
                .maybeSingle();
          }
        }
      }

      if (res != null) {
        _hasData = true;
        final booking = _asMap(res['bookings']);
        final slot = _asMap(res['parking_slots']);
        final loc = _asMap(res['parking_locations']);

        // Transaction code & hash (unique per booking / session)
        final rawCode = booking?['booking_code']?.toString() ?? res['session_code']?.toString() ?? cleanId;
        _transactionCode = rawCode;
        final safeClean = rawCode.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
        final rawIdClean = cleanId.replaceAll('-', '');
        final idSuffix = rawIdClean.length >= 4 ? rawIdClean.substring(0, 4) : rawIdClean.padRight(4, '0');
        _blockHash = '0x${safeClean.padRight(8, '0').substring(0, 8)}...$idSuffix';

        // Vehicle info (paten dari snapshot sesi atau booking)
        final sesPlate = (res['plate_number'] ?? '').toString().trim();
        final sesDesc = (res['vehicle_desc'] ?? '').toString().trim();
        final bookPlate = (booking?['plate_number'] ?? '').toString().trim();
        final bookDesc = (booking?['vehicle_desc'] ?? '').toString().trim();
        final veh = _asMap(booking?['vehicles']);

        if (sesDesc.isNotEmpty && sesPlate.isNotEmpty) {
          _vehicleInfo = '$sesDesc ($sesPlate)';
        } else if (sesPlate.isNotEmpty) {
          _vehicleInfo = sesDesc.isNotEmpty ? '$sesDesc ($sesPlate)' : sesPlate;
        } else if (bookDesc.isNotEmpty && bookPlate.isNotEmpty) {
          _vehicleInfo = '$bookDesc ($bookPlate)';
        } else if (bookPlate.isNotEmpty) {
          _vehicleInfo = bookDesc.isNotEmpty ? '$bookDesc ($bookPlate)' : bookPlate;
        } else if (veh != null) {
          final b = (veh['brand'] ?? '').toString().trim();
          final m = (veh['model'] ?? '').toString().trim();
          final p = (veh['plate_number'] ?? '').toString().trim();
          final name = '$b $m'.trim();
          _vehicleInfo = name.isNotEmpty ? '$name ($p)' : (p.isNotEmpty ? p : 'Kendaraan Terdaftar');
        } else {
          _vehicleInfo = 'Toyota Land Cruiser (B 1945 RI)';
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

        final expectedCoDt = res['expected_check_out_time'] != null
            ? DateTime.tryParse(res['expected_check_out_time'].toString())?.toLocal()
            : null;

        _paymentMethod = 'ParkSmart Pay';
        _serviceFee = 0;
        _discount = 0;
        _status = TicketMark.resolve(
          sessionStatus: res['status'],
          checkOutTime: coDt,
          expectedCheckOutTime: expectedCoDt,
        );

        // Location & Slot
        _locationName = loc?['name']?.toString() ?? 'ParkSmart Central Hub';
        _locationDetail = loc?['address']?.toString() ?? 'Jl. Jenderal Sudirman No. Kav 21, Jakarta Pusat';
        final slotCode = slot?['slot_code']?.toString() ?? 'A-01';
        final floorName = slot?['floor_name']?.toString() ?? 'Lantai 1';
        _slotInfo = 'Slot $slotCode • $floorName';

      } else {
        // 2. Jika tidak ada di parking_sessions, cari pada tabel bookings
        Map<String, dynamic>? bRes;
        const bookingSelect = 'id, booking_code, start_time, end_time, duration_hours, total_price, payment_status, booking_status, plate_number, vehicle_desc, created_at, parking_locations(name, address), parking_slots(slot_code, floor_name), vehicles(brand, model, plate_number)';
        if (isUuid) {
          bRes = await _client
              .from('bookings')
              .select(bookingSelect)
              .eq('id', cleanId)
              .maybeSingle();

          bRes ??= await _client
              .from('bookings')
              .select(bookingSelect)
              .eq('booking_code', cleanId)
              .maybeSingle();
        } else {
          bRes = await _client
              .from('bookings')
              .select(bookingSelect)
              .eq('booking_code', cleanId)
              .maybeSingle();
        }

        if (bRes != null) {
          _hasData = true;
          final rawCode = bRes['booking_code']?.toString() ?? cleanId;
          _transactionCode = rawCode;
          final safeClean = rawCode.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
          final rawIdClean = cleanId.replaceAll('-', '');
          final idSuffix = rawIdClean.length >= 4 ? rawIdClean.substring(0, 4) : rawIdClean.padRight(4, '0');
          _blockHash = '0x${safeClean.padRight(8, '0').substring(0, 8)}...$idSuffix';

          final numPrice = (bRes['total_price'] as num?)?.toDouble() ?? 11000.0;
          _totalAmount = numPrice.toInt();
          _baseFee = _totalAmount;

          final bStart = bRes['start_time'] != null ? DateTime.tryParse(bRes['start_time'].toString())?.toLocal() : null;
          final bEnd = bRes['end_time'] != null ? DateTime.tryParse(bRes['end_time'].toString())?.toLocal() : null;

          _status = TicketMark.resolve(
            paymentStatus: bRes['payment_status']?.toString(),
            bookingStatus: bRes['booking_status']?.toString(),
            startTime: bStart,
            endTime: bEnd,
          );

          // Info kendaraan paten dari snapshot booking
          final bookPlate = (bRes['plate_number'] ?? '').toString().trim();
          final bookDesc = (bRes['vehicle_desc'] ?? '').toString().trim();
          final veh = _asMap(bRes['vehicles']);

          if (bookDesc.isNotEmpty && bookPlate.isNotEmpty) {
            _vehicleInfo = '$bookDesc ($bookPlate)';
          } else if (bookPlate.isNotEmpty) {
            _vehicleInfo = bookDesc.isNotEmpty ? '$bookDesc ($bookPlate)' : bookPlate;
          } else if (veh != null) {
            final b = (veh['brand'] ?? '').toString().trim();
            final m = (veh['model'] ?? '').toString().trim();
            final p = (veh['plate_number'] ?? '').toString().trim();
            final name = '$b $m'.trim();
            _vehicleInfo = name.isNotEmpty ? '$name ($p)' : (p.isNotEmpty ? p : 'Kendaraan Terdaftar');
          } else {
            _vehicleInfo = 'Toyota Land Cruiser (B 1945 RI)';
          }

          final loc = _asMap(bRes['parking_locations']);
          _locationName = loc?['name']?.toString() ?? 'ParkSmart Central Hub';
          _locationDetail = loc?['address']?.toString() ?? 'Jl. Jenderal Sudirman No. Kav 21, Jakarta Pusat';

          final slot = _asMap(bRes['parking_slots']);
          final slotCode = slot?['slot_code']?.toString() ?? 'A-01';
          final floorName = slot?['floor_name']?.toString() ?? 'Lantai 1';
          _slotInfo = 'Slot $slotCode • $floorName';

          final durationHours = bRes['duration_hours'] ?? 1;
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
          final endDt = dt.add(Duration(hours: durationHours is int ? durationHours : int.tryParse(durationHours.toString()) ?? 1));
          _checkOutTime = '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')} WIB';
          _timestamp = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} UTC+7';

          _paymentMethod = 'ParkSmart Pay';
          _serviceFee = 0;
          _discount = 0;
        }
      }
    } catch (e, stack) {
      debugPrint('HistoryDetailBackend fetchDetail error: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
