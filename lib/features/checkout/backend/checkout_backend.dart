import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../home/backend/home_backend.dart';
import '../../profile/backend/profile_backend.dart';

/// Backend khusus untuk CheckoutScreen (lib/features/checkout/checkout_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk keamanan & efisiensi
class CheckoutBackend extends ChangeNotifier {
  CheckoutBackend._();
  static final CheckoutBackend instance = CheckoutBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _userId;
  void setUserId(String id) {
    _userId = id;
  }

  String? _holdBookingId;
  String? get holdBookingId => _holdBookingId;

  DateTime? _holdCreatedAt;
  DateTime? get holdCreatedAt => _holdCreatedAt;

  void clear() {
    _userId = null;
    _selectedVehicle = null;
    _userVehicles = [];
    _walletBalance = 0;
    _locationName = '-';
    _locationId = null;
    _slotId = null;
    _slotCode = '-';
    _floorName = '-';
    _holdBookingId = null;
    _holdCreatedAt = null;
    notifyListeners();
  }

  String get userId {
    if (_userId != null && _userId!.isNotEmpty) return _userId!;
    if (SessionService.instance.userId != null && SessionService.instance.userId!.isNotEmpty) {
      return SessionService.instance.userId!;
    }
    final pid = ProfileBackend.instance.userId;
    if (pid.isNotEmpty) return pid;
    if (HomeBackend.instance.userId.isNotEmpty) {
      return HomeBackend.instance.userId;
    }
    return '';
  }

  /// Helper asinkron untuk menjamin User ID aktif tidak pernah kosong
  Future<String> resolveUserId() async {
    final cur = userId;
    if (cur.isNotEmpty) return cur;

    final prefs = await SharedPreferences.getInstance();
    final prefUid = prefs.getString('user_profile_id') ?? prefs.getString('ps_session_user_id');
    if (prefUid != null && prefUid.isNotEmpty) {
      _userId = prefUid;
      return prefUid;
    }

    final authUser = _client.auth.currentUser;
    if (authUser != null) {
      try {
        final row = await _client.from('users').select('id').eq('auth_user_id', authUser.id).maybeSingle();
        if (row != null && row['id'] != null) {
          _userId = row['id'].toString();
          return _userId!;
        }
      } catch (_) {}
    }

    final email = SessionService.instance.identifier ?? ProfileBackend.instance.email;
    if (email.isNotEmpty) {
      try {
        final row = await _client.from('users').select('id').eq('email', email).maybeSingle();
        if (row != null && row['id'] != null) {
          _userId = row['id'].toString();
          return _userId!;
        }
      } catch (_) {}
    }

    return '';
  }

  Map<String, dynamic>? _selectedVehicle;
  Map<String, dynamic>? get selectedVehicle => _selectedVehicle;

  List<Map<String, dynamic>> _userVehicles = [];
  List<Map<String, dynamic>> get userVehicles => _userVehicles;

  double _walletBalance = 0;
  double get walletBalance => _walletBalance;

  // Detail booking aktif
  String _locationName = '-';
  String get locationName => _locationName;

  String? _locationId;
  String? get locationId => _locationId;

  String? _slotId;
  String? get slotId => _slotId;

  String _slotCode = '-';
  String get slotCode => _slotCode;

  String _floorName = '-';
  String get floorName => _floorName;

  String _slotType = 'Slot Reguler';
  String get slotType => _slotType;

  DateTime? _scheduledStartTime;
  DateTime? get scheduledStartTime => _scheduledStartTime;

  DateTime? _scheduledEndTime;
  DateTime? get scheduledEndTime => _scheduledEndTime;

  int _durationHours = 1;
  int get durationHours => _durationHours;

  double _hourlyRate = 5000;
  double get hourlyRate => _hourlyRate;

  double get subtotal => _durationHours * _hourlyRate;
  double get serviceFee => 0; // Tanpa biaya layanan
  double get discountAmount => 0;
  double get totalPayment => subtotal - discountAmount;

  void setBookingDetails({
    String? locationId,
    String? locationName,
    String? slotId,
    String? slotCode,
    String? floorName,
    String? slotType,
    int? durationHours,
    double? hourlyRate,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    if (locationId != null) _locationId = locationId;
    if (locationName != null) _locationName = locationName;
    if (slotId != null) _slotId = slotId;
    if (slotCode != null) _slotCode = slotCode;
    if (floorName != null) _floorName = floorName;
    if (slotType != null) _slotType = slotType;
    if (durationHours != null) _durationHours = durationHours;
    if (hourlyRate != null) _hourlyRate = hourlyRate;
    if (startTime != null) _scheduledStartTime = startTime;
    if (endTime != null) _scheduledEndTime = endTime;
    notifyListeners();
  }

  /// Memuat data kendaraan pengguna & saldo wallet (Targeted Column Query)
  Future<void> fetchCheckoutData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil info saldo wallet user (Targeted Column Query)
      final userRes = await _client
          .from('users')
          .select('id, full_name, wallet_balance, points')
          .eq('id', userId)
          .maybeSingle();

      if (userRes != null) {
        _walletBalance = (userRes['wallet_balance'] as num?)?.toDouble() ?? 0.0;
      }

      // 2. Ambil daftar kendaraan user (Targeted Column Query)
      final vehiclesRes = await _client
          .from('vehicles')
          .select('id, brand, model, color, plate_number, vehicle_type, is_default')
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      _userVehicles = List<Map<String, dynamic>>.from(vehiclesRes);
      if (_userVehicles.isNotEmpty) {
        _selectedVehicle = _userVehicles.first;
      } else {
        _selectedVehicle = null;
      }
    } catch (e) {
      debugPrint('[CheckoutBackend] fetchCheckoutData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectVehicle(Map<String, dynamic> vehicle) {
    _selectedVehicle = vehicle;
    _updateRateForVehicle(vehicle);
    notifyListeners();
  }

  Future<void> _updateRateForVehicle(Map<String, dynamic>? vehicle) async {
    if (_locationId == null || _locationId!.isEmpty) return;
    try {
      final loc = await _client
          .from('parking_locations')
          .select('hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev')
          .eq('id', _locationId!)
          .maybeSingle();
      if (loc != null) {
        final vType = vehicle?['vehicle_type']?.toString().toLowerCase();
        final isEvSlot = _slotType.toLowerCase().contains('ev');
        final isMotorSlot = _slotType.toLowerCase().contains('motor');

        if (isEvSlot || vType == 'ev') {
          _hourlyRate = (loc['hourly_rate_ev'] as num?)?.toDouble() ?? _hourlyRate;
        } else if (isMotorSlot || vType == 'motor') {
          _hourlyRate = (loc['hourly_rate_motor'] as num?)?.toDouble() ?? _hourlyRate;
        } else {
          _hourlyRate = (loc['hourly_rate_mobil'] as num?)?.toDouble() ?? _hourlyRate;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Membuat booking baru & memproses transaksi pembayaran di Supabase
  Future<Map<String, dynamic>?> confirmAndCreateBooking() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Jika sudah ada hold booking ID yang dibuat saat masuk checkout, gunakan langsung
      if (_holdBookingId != null && _holdBookingId!.isNotEmpty) {
        final existing = await _client
            .from('bookings')
            .select('id, booking_code, total_price, start_time, end_time, location_id, slot_id, created_at, plate_number, vehicle_desc')
            .eq('id', _holdBookingId!)
            .maybeSingle();
        if (existing != null) {
          return existing;
        }
      }

      final random = Random();
      final bookingCode = 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}-${random.nextInt(900) + 100}';

      final now = DateTime.now();
      final startTime = _scheduledStartTime ?? now;
      final endTime = _scheduledEndTime ?? startTime.add(Duration(hours: _durationHours));

      // 1. Ambil location_id jika belum terisi
      String? actualLocId = _locationId;
      if (actualLocId == null || actualLocId.isEmpty) {
        final loc = await _client
            .from('parking_locations')
            .select('id, name')
            .order('rating', ascending: false)
            .limit(1)
            .maybeSingle();
        actualLocId = loc?['id'] as String?;
        if (loc != null && _locationName == '-') {
          _locationName = loc['name']?.toString() ?? 'ParkSmart';
        }
      }

      if (actualLocId == null) {
        throw Exception('Lokasi parkir tidak ditemukan di database.');
      }

      // 2. Ambil slot_id jika ada
      String? actualSlotId = _slotId;
      if ((actualSlotId == null || actualSlotId.isEmpty) && _slotCode != '-' && _slotCode.isNotEmpty) {
        final slotRes = await _client
            .from('parking_slots')
            .select('id')
            .eq('location_id', actualLocId)
            .eq('slot_code', _slotCode)
            .maybeSingle();
        actualSlotId = slotRes?['id'] as String?;
      }

      // Validasi ketat bentrok slot sebelum insert ke database
      if (actualSlotId != null) {
        final hasConflict = await checkSlotConflict(
          slotId: actualSlotId,
          startTime: startTime,
          endTime: endTime,
        );
        if (hasConflict) {
          throw Exception('Slot ini sudah dibooking oleh pengguna lain pada rentang jam tersebut.');
        }
      }

      final actualUid = await resolveUserId();
      if (actualUid.isEmpty) {
        throw Exception('Sesi pengguna tidak valid. Silakan login kembali.');
      }

      final veh = _selectedVehicle;
      final vehicleDesc = veh != null
          ? ('${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim().isNotEmpty
              ? '${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim()
              : 'Toyota Land Cruiser')
          : 'Toyota Land Cruiser';
      final plateNumber = veh != null ? (veh['plate_number'] ?? 'B 1945 RI') : 'B 1945 RI';

      // 3. Insert ke tabel bookings (status awal 'unpaid' dengan hold time 2:59 menit)
      final bookingInsert = await _client.from('bookings').insert({
        'booking_code': bookingCode,
        'user_id': actualUid,
        'location_id': actualLocId,
        'slot_id': actualSlotId,
        'vehicle_id': _selectedVehicle?['id'],
        'plate_number': plateNumber,
        'vehicle_desc': vehicleDesc,
        'booking_type': 'reservation',
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'duration_hours': _durationHours,
        'total_price': totalPayment,
        'payment_status': 'unpaid',
        'booking_status': 'upcoming',
        'qr_code_hash': 'PARKSMART-$bookingCode',
      }).select('id, booking_code, total_price, start_time, end_time, location_id, slot_id, created_at, plate_number, vehicle_desc').maybeSingle();

      // Tandai slot sebagai reserved sementara
      if (actualSlotId != null) {
        await _client.from('parking_slots').update({
          'status': 'reserved',
        }).eq('id', actualSlotId);
      }

      return bookingInsert ?? {
        'id': 'mock-booking-${DateTime.now().millisecondsSinceEpoch}',
        'booking_code': bookingCode,
        'total_price': totalPayment,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('[CheckoutBackend] confirmAndCreateBooking error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Membuat booking unpaid untuk menahan slot selama 2:59 menit sejak pertama kali masuk halaman checkout
  Future<bool> createHoldBooking() async {
    try {
      final now = DateTime.now();
      final startTime = _scheduledStartTime ?? now;
      final endTime = _scheduledEndTime ?? startTime.add(Duration(hours: _durationHours));

      // 1. Ambil location_id jika belum terisi
      String? actualLocId = _locationId;
      if (actualLocId == null || actualLocId.isEmpty) {
        final loc = await _client
            .from('parking_locations')
            .select('id, name')
            .order('rating', ascending: false)
            .limit(1)
            .maybeSingle();
        actualLocId = loc?['id'] as String?;
        if (loc != null && _locationName == '-') {
          _locationName = loc['name']?.toString() ?? 'ParkSmart';
        }
      }

      if (actualLocId == null) return false;

      // 2. Ambil slot_id jika ada
      String? actualSlotId = _slotId;
      if ((actualSlotId == null || actualSlotId.isEmpty) && _slotCode != '-' && _slotCode.isNotEmpty) {
        final slotRes = await _client
            .from('parking_slots')
            .select('id')
            .eq('location_id', actualLocId)
            .eq('slot_code', _slotCode)
            .maybeSingle();
        actualSlotId = slotRes?['id'] as String?;
      }

      // Validasi bentrok slot
      if (actualSlotId != null) {
        final hasConflict = await checkSlotConflict(
          slotId: actualSlotId,
          startTime: startTime,
          endTime: endTime,
        );
        if (hasConflict) return false;
      }

      final actualUid = await resolveUserId();
      if (actualUid.isEmpty) return false;

      final random = Random();
      final bookingCode = 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}-${random.nextInt(900) + 100}';

      final veh = _selectedVehicle;
      final vehicleDesc = veh != null
          ? ('${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim().isNotEmpty
              ? '${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim()
              : 'Toyota Land Cruiser')
          : 'Toyota Land Cruiser';
      final plateNumber = veh != null ? (veh['plate_number'] ?? 'B 1945 RI') : 'B 1945 RI';

      // Insert ke tabel bookings dengan payment_status 'unpaid'
      final result = await _client.from('bookings').insert({
        'booking_code': bookingCode,
        'user_id': actualUid,
        'location_id': actualLocId,
        'slot_id': actualSlotId,
        'vehicle_id': _selectedVehicle?['id'],
        'plate_number': plateNumber,
        'vehicle_desc': vehicleDesc,
        'booking_type': 'reservation',
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'duration_hours': _durationHours,
        'total_price': totalPayment,
        'payment_status': 'unpaid',
        'booking_status': 'upcoming',
        'qr_code_hash': 'PARKSMART-$bookingCode',
      }).select('id, created_at').maybeSingle();

      if (result != null) {
        _holdBookingId = result['id']?.toString();
        _holdCreatedAt = DateTime.tryParse(result['created_at'].toString())?.toLocal() ?? DateTime.now();

        // Kunci status slot menjadi reserved agar tidak bisa dibooking orang lain
        if (actualSlotId != null) {
          await _client.from('parking_slots').update({
            'status': 'reserved',
          }).eq('id', actualSlotId);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[CheckoutBackend] createHoldBooking error: $e');
      return false;
    }
  }

  /// Batalkan penahanan slot jika waktu habis atau booking tidak dibayar
  Future<void> cancelHoldBooking({String? bookingId}) async {
    final targetId = bookingId ?? _holdBookingId;
    if (targetId == null || targetId.isEmpty) return;

    try {
      final b = await _client
          .from('bookings')
          .select('slot_id, payment_status')
          .eq('id', targetId)
          .maybeSingle();

      if (b != null && (b['payment_status'] == 'unpaid' || b['payment_status'] == 'pending')) {
        await _client.from('bookings').update({
          'booking_status': 'cancelled',
          'cancel_reason': 'Batas waktu pembayaran 2 menit 59 detik telah habis atau dibatalkan pengguna',
        }).eq('id', targetId);

        final sId = b['slot_id']?.toString() ?? _slotId;
        if (sId != null && sId.isNotEmpty) {
          await _client.from('parking_slots').update({
            'status': 'available',
            'current_plate_number': null,
            'occupied_since': null,
          }).eq('id', sId);
        }
      }

      if (targetId == _holdBookingId) {
        _holdBookingId = null;
        _holdCreatedAt = null;
      }

      // Sinkronisasi pembersihan otomatis di Supabase
      try {
        await _client.rpc('auto_process_expired_bookings_and_sessions');
      } catch (_) {}

      notifyListeners();
    } catch (e) {
      debugPrint('[CheckoutBackend] cancelHoldBooking error: $e');
    }
  }

  /// Memuat data booking dari ID yang belum dibayar di riwayat
  Future<bool> loadFromExistingBooking(String bookingId) async {
    try {
      final b = await _client
          .from('bookings')
          .select('id, created_at, booking_code, start_time, end_time, duration_hours, total_price, location_id, slot_id, vehicle_id, plate_number, vehicle_desc, payment_status')
          .eq('id', bookingId)
          .maybeSingle();

      if (b == null) return false;

      _holdBookingId = b['id']?.toString();
      _holdCreatedAt = DateTime.tryParse(b['created_at'].toString())?.toLocal() ?? DateTime.now();
      _scheduledStartTime = DateTime.tryParse(b['start_time'].toString())?.toLocal();
      _scheduledEndTime = DateTime.tryParse(b['end_time'].toString())?.toLocal();
      _durationHours = (b['duration_hours'] as num?)?.toInt() ?? 1;
      final tPrice = (b['total_price'] as num?)?.toDouble() ?? 5000.0;
      _hourlyRate = _durationHours > 0 ? (tPrice / _durationHours) : 5000.0;

      if (b['location_id'] != null) {
        _locationId = b['location_id'].toString();
        final loc = await _client
            .from('parking_locations')
            .select('id, name')
            .eq('id', _locationId!)
            .maybeSingle();
        if (loc != null) {
          _locationName = loc['name']?.toString() ?? _locationName;
        }
      }

      if (b['slot_id'] != null) {
        _slotId = b['slot_id'].toString();
        final slot = await _client
            .from('parking_slots')
            .select('slot_code, floor_name, slot_type')
            .eq('id', _slotId!)
            .maybeSingle();
        if (slot != null) {
          _slotCode = slot['slot_code']?.toString() ?? _slotCode;
          _floorName = slot['floor_name']?.toString() ?? _floorName;
          _slotType = slot['slot_type']?.toString() ?? _slotType;
        }
      }

      final pNum = b['plate_number']?.toString();
      final vDesc = b['vehicle_desc']?.toString();
      _selectedVehicle = {
        'id': b['vehicle_id'],
        'plate_number': pNum ?? 'B 1945 RI',
        'brand': vDesc ?? 'Kendaraan',
        'model': '',
      };

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[CheckoutBackend] loadFromExistingBooking error: $e');
      return false;
    }
  }

  /// Memeriksa apakah slot yang dipilih bentrok dengan reservasi yang sudah ada
  Future<bool> checkSlotConflict({
    String? slotId,
    String? slotCode,
    String? locationId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // Jalankan pembersihan otomatis sebelum pengecekan agar status slot di DB selalu akurat
      try {
        await _client.rpc('auto_process_expired_bookings_and_sessions');
      } catch (_) {}

      String? targetSlotId = slotId ?? _slotId;
      if (targetSlotId == null || targetSlotId.isEmpty) {
        final locId = locationId ?? _locationId;
        final sCode = slotCode ?? _slotCode;
        if (locId != null && sCode.isNotEmpty && sCode != '-') {
          final sRes = await _client
              .from('parking_slots')
              .select('id')
              .eq('location_id', locId)
              .eq('slot_code', sCode)
              .maybeSingle();
          targetSlotId = sRes?['id'] as String?;
        }
      }
      if (targetSlotId == null) return false;

      final now = DateTime.now();
      final bookings = await _client
          .from('bookings')
          .select('id, start_time, end_time, booking_status, payment_status, created_at')
          .eq('slot_id', targetSlotId)
          .not('booking_status', 'in', '(cancelled,completed,expired)');

      for (final b in bookings) {
        final bId = b['id']?.toString();
        // 1. Abaikan booking milik pengguna sendiri yang sedang dalam proses checkout ini
        if (_holdBookingId != null && bId == _holdBookingId) {
          continue;
        }

        // 2. Abaikan booking unpaid yang sudah melewati batas 2 menit 59 detik (179s)
        final payStatus = (b['payment_status'] ?? '').toString().toLowerCase();
        if (payStatus == 'unpaid') {
          final cat = DateTime.tryParse(b['created_at']?.toString() ?? '')?.toLocal();
          if (cat != null && now.difference(cat).inSeconds > 179) {
            continue;
          }
        }

        final bStart = DateTime.parse(b['start_time'].toString()).toLocal();
        final bEnd = DateTime.parse(b['end_time'].toString()).toLocal();

        // 3. Abaikan booking yang jadwalnya sudah selesai di masa lampau
        if (bEnd.isBefore(now) || bEnd.isAtSameMomentAs(now)) {
          continue;
        }

        // Formula overlap: startA < endB && endA > startB
        if (startTime.isBefore(bEnd) && endTime.isAfter(bStart)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('[CheckoutBackend] checkSlotConflict error: $e');
      return false;
    }
  }

  /// Menghitung jadwal jam yang masih kosong dan tersedia hari ini untuk slot terpilih
  Future<List<AvailableTimeWindow>> getAvailableTimeSlotsToday({
    String? slotId,
    String? slotCode,
    String? locationId,
  }) async {
    try {
      try {
        await _client.rpc('auto_process_expired_bookings_and_sessions');
      } catch (_) {}

      String? targetSlotId = slotId ?? _slotId;
      if (targetSlotId == null || targetSlotId.isEmpty) {
        final locId = locationId ?? _locationId;
        final sCode = slotCode ?? _slotCode;
        if (locId != null && sCode.isNotEmpty && sCode != '-') {
          final sRes = await _client
              .from('parking_slots')
              .select('id')
              .eq('location_id', locId)
              .eq('slot_code', sCode)
              .maybeSingle();
          targetSlotId = sRes?['id'] as String?;
        }
      }
      if (targetSlotId == null) return [];

      final now = DateTime.now();
      final windowStart = now;
      final windowEnd = DateTime(now.year, now.month, now.day, 23, 59);

      if (windowStart.isAfter(windowEnd)) return [];

      final bookings = await _client
          .from('bookings')
          .select('id, start_time, end_time, booking_status, payment_status, created_at')
          .eq('slot_id', targetSlotId)
          .not('booking_status', 'in', '(cancelled,completed,expired)');

      List<Map<String, DateTime>> bookedIntervals = [];
      for (final b in bookings) {
        final bId = b['id']?.toString();
        // Abaikan booking sendiri
        if (_holdBookingId != null && bId == _holdBookingId) {
          continue;
        }

        // Abaikan unpaid > 179s
        final payStatus = (b['payment_status'] ?? '').toString().toLowerCase();
        if (payStatus == 'unpaid') {
          final cat = DateTime.tryParse(b['created_at']?.toString() ?? '')?.toLocal();
          if (cat != null && now.difference(cat).inSeconds > 179) {
            continue;
          }
        }

        final bStart = DateTime.parse(b['start_time'].toString()).toLocal();
        final bEnd = DateTime.parse(b['end_time'].toString()).toLocal();

        if (bEnd.isBefore(windowStart) || bStart.isAfter(windowEnd)) continue;

        final clampedStart = bStart.isBefore(windowStart) ? windowStart : bStart;
        final clampedEnd = bEnd.isAfter(windowEnd) ? windowEnd : bEnd;

        if (clampedEnd.isAfter(clampedStart)) {
          bookedIntervals.add({'start': clampedStart, 'end': clampedEnd});
        }
      }

      bookedIntervals.sort((a, b) => a['start']!.compareTo(b['start']!));

      // Gabungkan interval booking yang saling tumpang tindih / berdekatan
      List<Map<String, DateTime>> merged = [];
      for (final interval in bookedIntervals) {
        if (merged.isEmpty) {
          merged.add(Map.from(interval));
        } else {
          final last = merged.last;
          if (interval['start']!.isBefore(last['end']!) ||
              interval['start']!.isAtSameMomentAs(last['end']!)) {
            if (interval['end']!.isAfter(last['end']!)) {
              last['end'] = interval['end']!;
            }
          } else {
            merged.add(Map.from(interval));
          }
        }
      }

      // Cari celah jam kosong yang tersisa
      List<AvailableTimeWindow> windows = [];
      DateTime ptr = windowStart;

      for (final booked in merged) {
        if (booked['start']!.isAfter(ptr)) {
          final diff = booked['start']!.difference(ptr).inMinutes;
          if (diff >= 15) {
            windows.add(_createWindow(ptr, booked['start']!));
          }
        }
        if (booked['end']!.isAfter(ptr)) {
          ptr = booked['end']!;
        }
      }

      if (windowEnd.isAfter(ptr)) {
        final diff = windowEnd.difference(ptr).inMinutes;
        if (diff >= 15) {
          windows.add(_createWindow(ptr, windowEnd));
        }
      }

      return windows;
    } catch (e) {
      debugPrint('[CheckoutBackend] getAvailableTimeSlotsToday error: $e');
      return [];
    }
  }

  AvailableTimeWindow _createWindow(DateTime start, DateTime end) {
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    final diffMinutes = end.difference(start).inMinutes;
    final hours = diffMinutes ~/ 60;
    final mins = diffMinutes % 60;
    String durText = '';
    if (hours > 0 && mins > 0) {
      durText = '$hours jam $mins mnt';
    } else if (hours > 0) {
      durText = '$hours jam';
    } else {
      durText = '$mins mnt';
    }
    return AvailableTimeWindow(
      start: start,
      end: end,
      label: '$startStr - $endStr WIB',
      durationLabel: durText,
    );
  }

  /// Memproses pembayaran booking setelah validasi PIN sukses
  Future<bool> markBookingAsPaid(String bookingId) async {
    try {
      final bRes = await _client
          .from('bookings')
          .select('id, total_price, user_id, booking_code, location_id, slot_id, parking_locations(name), parking_slots(slot_code)')
          .eq('id', bookingId)
          .maybeSingle();
      if (bRes == null) return false;

      final price = (bRes['total_price'] as num?)?.toDouble() ?? totalPayment;
      final actualUserId = (bRes['user_id'] != null && bRes['user_id'].toString().isNotEmpty)
          ? bRes['user_id'].toString()
          : (await resolveUserId());
      final bCode = bRes['booking_code']?.toString() ?? '';
      final locName = bRes['parking_locations']?['name']?.toString() ?? _locationName;
      final sCode = bRes['parking_slots']?['slot_code']?.toString() ?? _slotCode;

      // 1. CEK SALDO PENGGUNA TERLEBIH DAHULU (Wajib Cukup!)
      final userRes = await _client
          .from('users')
          .select('wallet_balance, total_parking_count')
          .eq('id', actualUserId)
          .maybeSingle();
      final currentBal = (userRes?['wallet_balance'] as num?)?.toDouble() ?? _walletBalance;

      if (currentBal < price) {
        debugPrint('[CheckoutBackend] markBookingAsPaid ditolak: Saldo tidak mencukupi (Saldo: $currentBal, Dibutuhkan: $price)');
        return false;
      }

      final newBalance = currentBal - price;

      // 2. Potong saldo wallet pengguna
      final currentCount = (userRes?['total_parking_count'] as num?)?.toInt() ?? 0;
      await _client.from('users').update({
        'wallet_balance': newBalance,
        'total_parking_count': currentCount + 1,
      }).eq('id', actualUserId);

      _walletBalance = newBalance;
      ProfileBackend.instance.setLoggedInUser(
        id: actualUserId,
        fullName: ProfileBackend.instance.name,
        email: ProfileBackend.instance.email,
        phone: ProfileBackend.instance.phone,
        walletBalance: newBalance.toInt(),
      );

      // 3. Update status booking menjadi paid & upcoming
      await _client.from('bookings').update({
        'payment_status': 'paid',
        'booking_status': 'upcoming',
      }).eq('id', bookingId);

      // 4. Catat riwayat transaksi sukses di tabel payments
      final trxCode = 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      await _client.from('payments').insert({
        'transaction_code': trxCode,
        'user_id': actualUserId,
        'booking_id': bookingId,
        'transaction_type': 'parking_payment',
        'payment_method': 'wallet',
        'amount': price,
        'description': 'Reservasi Parkir $locName Slot $sCode ($bCode)',
        'status': 'success',
        'completed_at': DateTime.now().toIso8601String(),
      });

      // 5. Pastikan slot terkunci reserved
      if (bRes['slot_id'] != null) {
        await _client.from('parking_slots').update({
          'status': 'reserved',
        }).eq('id', bRes['slot_id']);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[CheckoutBackend] markBookingAsPaid error: $e');
      return false;
    }
  }
}

class AvailableTimeWindow {
  final DateTime start;
  final DateTime end;
  final String label;
  final String durationLabel;

  const AvailableTimeWindow({
    required this.start,
    required this.end,
    required this.label,
    required this.durationLabel,
  });
}

