import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String get userId {
    if (_userId != null && _userId!.isNotEmpty) return _userId!;
    final pid = ProfileBackend.instance.userId;
    if (pid.isNotEmpty) return pid;
    return 'e2b8c4d1-7a3f-4e92-8d15-9c64712035ba';
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

  String _slotCode = '-';
  String get slotCode => _slotCode;

  String _floorName = '-';
  String get floorName => _floorName;

  int _durationHours = 2;
  int get durationHours => _durationHours;

  double _hourlyRate = 5000;
  double get hourlyRate => _hourlyRate;

  double get subtotal => _durationHours * _hourlyRate;
  double get serviceFee => 1000;
  double get discountAmount => 0;
  double get totalPayment => (subtotal + serviceFee) - discountAmount;

  void setBookingDetails({
    String? locationId,
    String? locationName,
    String? slotCode,
    String? floorName,
    int? durationHours,
    double? hourlyRate,
  }) {
    if (locationId != null) _locationId = locationId;
    if (locationName != null) _locationName = locationName;
    if (slotCode != null) _slotCode = slotCode;
    if (floorName != null) _floorName = floorName;
    if (durationHours != null) _durationHours = durationHours;
    if (hourlyRate != null) _hourlyRate = hourlyRate;
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
    notifyListeners();
  }

  /// Membuat booking baru & memproses transaksi pembayaran di Supabase
  Future<Map<String, dynamic>?> confirmAndCreateBooking() async {
    _isLoading = true;
    notifyListeners();

    try {
      final random = Random();
      final bookingCode = 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}-${random.nextInt(900) + 100}';

      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(hours: _durationHours));

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
      String? actualSlotId;
      if (_slotCode != '-' && _slotCode.isNotEmpty) {
        final slotRes = await _client
            .from('parking_slots')
            .select('id')
            .eq('location_id', actualLocId)
            .eq('slot_code', _slotCode)
            .maybeSingle();
        actualSlotId = slotRes?['id'] as String?;
      }

      // 3. Insert ke tabel bookings (status awal 'unpaid' dengan hold time 2:59 menit)
      final bookingInsert = await _client.from('bookings').insert({
        'booking_code': bookingCode,
        'user_id': userId,
        'location_id': actualLocId,
        'slot_id': actualSlotId,
        'vehicle_id': _selectedVehicle?['id'],
        'booking_type': 'reservation',
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_hours': _durationHours,
        'total_price': totalPayment,
        'payment_status': 'unpaid',
        'booking_status': 'upcoming',
        'qr_code_hash': 'PARKSMART-$bookingCode',
      }).select('id, booking_code, total_price, start_time, end_time, location_id, slot_id, created_at').maybeSingle();

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
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
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
      final actualUserId = bRes['user_id']?.toString() ?? userId;
      final bCode = bRes['booking_code']?.toString() ?? '';
      final locName = bRes['parking_locations']?['name']?.toString() ?? _locationName;
      final sCode = bRes['parking_slots']?['slot_code']?.toString() ?? _slotCode;

      // 1. Update booking status
      await _client.from('bookings').update({
        'payment_status': 'paid',
        'booking_status': 'upcoming',
      }).eq('id', bookingId);

      // 2. Insert payments record
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

      // 3. Deduct wallet
      final userRes = await _client
          .from('users')
          .select('wallet_balance, total_parking_count')
          .eq('id', actualUserId)
          .maybeSingle();
      final currentBal = (userRes?['wallet_balance'] as num?)?.toDouble() ?? _walletBalance;
      final currentCount = (userRes?['total_parking_count'] as num?)?.toInt() ?? 0;
      final newBalance = (currentBal - price).clamp(0.0, double.infinity);
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

      // 4. Ensure slot status is reserved
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
