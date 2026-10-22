import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/ticket_status_helper.dart';
import 'admin_operations_dashboard_backend.dart';

/// Backend khusus untuk AdminBookingsScreen (admin_bookings_screen.dart)
/// Mengelola data reservasi booking tiket parkir yang masuk ke sistem
/// Terkoneksi ke `public.bookings` di Supabase
class AdminBookingsBackend extends ChangeNotifier {
  AdminBookingsBackend._();
  static final AdminBookingsBackend instance = AdminBookingsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  late List<Map<String, dynamic>> bookings = [];

  /// Mengambil data pemesanan booking dari Supabase
  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('bookings')
          .select('''
            id,
            booking_code,
            booking_type,
            start_time,
            end_time,
            duration_hours,
            total_price,
            payment_status,
            booking_status,
            created_at,
            users(full_name, phone, avatar_url),
            parking_locations(name),
            parking_slots(slot_code, floor_name),
            vehicles(plate_number, vehicle_type)
          ''')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        bookings = res.map<Map<String, dynamic>>((row) {
          final pStatus = row['payment_status']?.toString();
          final bStatus = row['booking_status']?.toString();

          final statusLabel = TicketMark.resolve(
            paymentStatus: pStatus,
            bookingStatus: bStatus,
          );

          final price = (row['total_price'] as num?)?.toDouble() ?? 0;
          final userData = row['users'] as Map<String, dynamic>?;
          final locData = row['parking_locations'] as Map<String, dynamic>?;
          final slotData = row['parking_slots'] as Map<String, dynamic>?;
          final vehData = row['vehicles'] as Map<String, dynamic>?;

          final userName = userData?['full_name']?.toString() ?? 'Pelanggan ParkSmart';
          final userPhone = userData?['phone']?.toString() ?? '-';
          final userAvatar = (userName.isNotEmpty) ? userName.substring(0, 1).toUpperCase() : 'P';
          final locName = locData?['name']?.toString() ?? 'Lokasi Parkir';
          final slotCode = slotData?['slot_code']?.toString() ?? '-';
          final floorName = slotData?['floor_name']?.toString() ?? 'Lantai 1';
          final plate = vehData?['plate_number']?.toString() ?? '-';
          final vType = vehData?['vehicle_type']?.toString().toLowerCase() == 'motor' ? 'Motor' : 'Mobil';

          return {
            'id': row['booking_code']?.toString() ?? 'BKG-001',
            'db_id': row['id']?.toString(),
            'user': {'name': userName, 'phone': userPhone, 'avatar': userAvatar},
            'location': locName,
            'slot': slotCode,
            'floor': floorName,
            'vehicle': {'plate': plate, 'type': vType},
            'startTime': row['start_time']?.toString().split('.')[0] ?? '2026-10-20 08:00',
            'endTime': row['end_time']?.toString().split('.')[0] ?? '2026-10-20 12:00',
            'durationHours': (row['duration_hours'] as num?)?.toInt() ?? 2,
            'status': statusLabel,
            'bookingType': row['booking_type'] == 'walk_in' ? 'Langsung' : 'Reservasi',
            'totalPrice': price.round(),
            'paymentStatus': row['payment_status'] == 'paid' ? 'Dibayar' : 'Belum Dibayar',
            'createdAt': row['created_at']?.toString().split('.')[0] ?? '2026-10-20',
          };
        }).toList();
      } else {
        bookings = [];
      }
    } catch (e) {
      debugPrint('[AdminBookingsBackend] fetchBookings error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Batalkan reservasi booking
  Future<bool> cancelBooking(String bookingCode, String reason) async {
    final idx = bookings.indexWhere((b) => b['id'] == bookingCode);
    if (idx != -1) {
      bookings[idx]['status'] = TicketMark.dibatalkan;
      notifyListeners();
    }

    try {
      final bRes = await _client.from('bookings').select('slot_id').eq('booking_code', bookingCode).maybeSingle();
      if (bRes != null && bRes['slot_id'] != null) {
        await _client.from('parking_slots').update({'status': 'available'}).eq('id', bRes['slot_id']);
      }

      await _client.from('bookings').update({
        'booking_status': 'cancelled',
        'cancel_reason': reason,
      }).eq('booking_code', bookingCode);

      await AdminOperationsDashboardBackend.instance.fetchDashboardData();
      return true;
    } catch (e) {
      debugPrint('[AdminBookingsBackend] cancelBooking error: $e');
      return false;
    }
  }
}
