import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/ticket_status_helper.dart';

/// Backend khusus untuk BookingConfirmationScreen (lib/features/booking/booking_confirmation_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk tiket konfirmasi reservasi
class BookingConfirmationBackend extends ChangeNotifier {
  BookingConfirmationBackend._();
  static final BookingConfirmationBackend instance = BookingConfirmationBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _latestBooking;
  Map<String, dynamic>? get latestBooking => _latestBooking;
  bool get hasBooking => _latestBooking != null;

  String _bookingCode = '-';
  String get bookingCode => _bookingCode;

  String _ticketStatus = TicketMark.ready;
  String get ticketStatus => _ticketStatus;

  String _locationName = '-';
  String get locationName => _locationName;
  String get locationTitle => _locationName;

  String _locationSub = '-';
  String get locationSub => _locationSub;

  String _slotCode = '-';
  String get slotCode => _slotCode;

  String _vehicleName = '-';
  String get vehicleName => _vehicleName;

  String _plateNumber = '-';
  String get plateNumber => _plateNumber;

  String _validTime = '-';
  String get validTime => _validTime;

  String? _bookingId;
  String? get bookingId => _bookingId;

  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;

  double _totalPrice = 11000;
  double get totalPrice => _totalPrice;

  /// Memuat detail tiket reservasi terbaru dari Supabase (Targeted Column Query)
  Future<void> fetchLatestBooking({String? bookingId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      var query = _client
          .from('bookings')
          .select('id, booking_code, start_time, end_time, duration_hours, total_price, payment_status, booking_status, qr_code_hash, location_id, slot_id, vehicle_id, plate_number, vehicle_desc, created_at');

      final bookingData = bookingId != null
          ? await query.eq('id', bookingId).maybeSingle()
          : await query.order('created_at', ascending: false).limit(1).maybeSingle();

      if (bookingData != null) {
        _latestBooking = bookingData;
        _bookingId = bookingData['id']?.toString();
        _totalPrice = (bookingData['total_price'] as num?)?.toDouble() ?? 11000.0;
        if (bookingData['created_at'] != null) {
          _createdAt = DateTime.tryParse(bookingData['created_at'].toString())?.toLocal();
        }
        _bookingCode = bookingData['booking_code'] ?? _bookingCode;
        _ticketStatus = TicketMark.resolve(
          paymentStatus: bookingData['payment_status']?.toString() ?? 'paid',
          bookingStatus: bookingData['booking_status']?.toString() ?? 'upcoming',
        );

        // Format waktu
        try {
          final start = DateTime.parse(bookingData['start_time'].toString()).toLocal();
          final end = DateTime.parse(bookingData['end_time'].toString()).toLocal();
          _validTime = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
        } catch (_) {}

        // Ambil info lokasi jika ada
        if (bookingData['location_id'] != null) {
          final loc = await _client
              .from('parking_locations')
              .select('name, address')
              .eq('id', bookingData['location_id'])
              .maybeSingle();
          if (loc != null) {
            _locationName = loc['name'] ?? _locationName;
            _locationSub = loc['address'] ?? _locationSub;
          }
        }

        // Ambil info slot jika ada
        if (bookingData['slot_id'] != null) {
          final slot = await _client
              .from('parking_slots')
              .select('slot_code, floor_name')
              .eq('id', bookingData['slot_id'])
              .maybeSingle();
          if (slot != null) {
            _slotCode = slot['slot_code'] ?? _slotCode;
            if (slot['floor_name'] != null) {
              _locationSub = '${slot['floor_name']}';
            }
          }
        }

        // Ambil info kendaraan paten (prioritas dari snapshot bookingData)
        final snapPlate = bookingData['plate_number']?.toString();
        final snapDesc = bookingData['vehicle_desc']?.toString();
        if (snapPlate != null && snapPlate.trim().isNotEmpty) {
          _plateNumber = snapPlate.trim();
        }
        if (snapDesc != null && snapDesc.trim().isNotEmpty) {
          _vehicleName = snapDesc.trim();
        }

        // Jika belum ada di snapshot, cari via vehicle_id spesifik (bukan limit 1 acak)
        if ((_vehicleName == '-' || _vehicleName.isEmpty) && bookingData['vehicle_id'] != null) {
          final veh = await _client
              .from('vehicles')
              .select('brand, model, plate_number')
              .eq('id', bookingData['vehicle_id'])
              .maybeSingle();
          if (veh != null) {
            final name = '${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim();
            if (name.isNotEmpty) _vehicleName = name;
            if (veh['plate_number'] != null) _plateNumber = veh['plate_number'];
          }
        }

        // Fallback default jika benar-benar kosong
        if (_vehicleName == '-' || _vehicleName.isEmpty) {
          _vehicleName = 'Toyota Land Cruiser';
        }
        if (_plateNumber == '-' || _plateNumber.isEmpty) {
          _plateNumber = 'B 1945 RI';
        }
      }
    } catch (e) {
      debugPrint('[BookingConfirmationBackend] fetchLatestBooking error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menetapkan info tiket secara instan dari sesi pemesanan aktif
  void setConfirmedPass({
    required String bookingCode,
    required String locationName,
    required String locationSub,
    required String slotCode,
    required String vehicleName,
    required String plateNumber,
    required String validTime,
    String? bookingId,
    DateTime? createdAt,
    String? ticketStatus,
    double? totalPrice,
  }) {
    _bookingCode = bookingCode;
    _locationName = locationName;
    _locationSub = locationSub;
    _slotCode = slotCode;
    _vehicleName = vehicleName;
    _plateNumber = plateNumber;
    _validTime = validTime;
    if (bookingId != null) _bookingId = bookingId;
    if (createdAt != null) _createdAt = createdAt;
    if (ticketStatus != null) _ticketStatus = ticketStatus;
    if (totalPrice != null) _totalPrice = totalPrice;
    notifyListeners();
  }
}
