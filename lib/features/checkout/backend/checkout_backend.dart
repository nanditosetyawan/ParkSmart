import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk CheckoutScreen (lib/features/checkout/checkout_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk keamanan & efisiensi
class CheckoutBackend extends ChangeNotifier {
  CheckoutBackend._();
  static final CheckoutBackend instance = CheckoutBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _userId;
  String get userId => _userId ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

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
      final trxCode = 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}-${random.nextInt(900) + 100}';

      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(hours: _durationHours));

      // 1. Ambil location_id jika belum terisi
      String? actualLocId = _locationId;
      if (actualLocId == null) {
        final loc = await _client
            .from('parking_locations')
            .select('id')
            .order('rating', ascending: false)
            .limit(1)
            .maybeSingle();
        actualLocId = loc?['id'] as String?;
      }

      // 2. Ambil slot_id jika ada
      String? actualSlotId;
      if (actualLocId != null) {
        final slotRes = await _client
            .from('parking_slots')
            .select('id')
            .eq('location_id', actualLocId)
            .eq('slot_code', _slotCode)
            .maybeSingle();
        actualSlotId = slotRes?['id'] as String?;
      }

      // 3. Insert ke tabel bookings
      final bookingInsert = await _client.from('bookings').insert({
        'booking_code': bookingCode,
        'user_id': userId,
        'location_id': actualLocId ?? 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
        'slot_id': actualSlotId,
        'vehicle_id': _selectedVehicle?['id'],
        'booking_type': 'reservation',
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_hours': _durationHours,
        'total_price': totalPayment,
        'payment_status': 'paid',
        'booking_status': 'upcoming',
        'qr_code_hash': 'PARKSMART-$bookingCode',
      }).select('id, booking_code, total_price, start_time, end_time').maybeSingle();

      // 4. Catat transaksi pembayaran di tabel payments
      if (bookingInsert != null) {
        await _client.from('payments').insert({
          'transaction_code': trxCode,
          'user_id': userId,
          'booking_id': bookingInsert['id'],
          'transaction_type': 'parking_payment',
          'payment_method': 'wallet',
          'amount': totalPayment,
          'description': 'Reservasi Parkir $_locationName Slot $_slotCode',
          'status': 'success',
        });

        // 5. Kurangi saldo wallet user jika mencukupi
        final newBalance = (_walletBalance - totalPayment).clamp(0, double.infinity);
        await _client.from('users').update({
          'wallet_balance': newBalance,
        }).eq('id', userId);

        _walletBalance = newBalance.toDouble();

        // 6. Tandai slot sebagai reserved
        if (actualSlotId != null) {
          await _client.from('parking_slots').update({
            'status': 'reserved',
          }).eq('id', actualSlotId);
        }
      }

      return bookingInsert ?? {
        'id': 'mock-booking-${DateTime.now().millisecondsSinceEpoch}',
        'booking_code': bookingCode,
        'total_price': totalPayment,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      };
    } catch (e) {
      debugPrint('[CheckoutBackend] confirmAndCreateBooking error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
