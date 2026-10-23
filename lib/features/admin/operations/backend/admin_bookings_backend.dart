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

  /// Evaluasi otomatis: auto-cancel unpaid > 179s & auto-complete paid lewat endTime
  Future<void> _evaluateBookingsCleanup() async {
    try {
      // Jalankan stored procedure pembersihan di Supabase
      try {
        await _client.rpc('auto_process_expired_bookings_and_sessions');
      } catch (_) {}

      final nowUtc = DateTime.now().toUtc();

      // 1. Unpaid booking yang sudah lebih dari 2 menit 59 detik (179s)
      final unpaidBookings = await _client
          .from('bookings')
          .select('id, slot_id, created_at')
          .eq('payment_status', 'unpaid')
          .neq('booking_status', 'cancelled');

      for (final b in unpaidBookings) {
        final cat = DateTime.tryParse(b['created_at']?.toString() ?? '');
        if (cat != null && nowUtc.difference(cat.toUtc()).inSeconds > 179) {
          await _client.from('bookings').update({
            'booking_status': 'cancelled',
            'cancel_reason': 'Waktu pembayaran habis (Auto Cancel)',
          }).eq('id', b['id']);

          final slotId = b['slot_id']?.toString();
          if (slotId != null && slotId.isNotEmpty) {
            await _client.from('parking_slots').update({
              'status': 'available',
              'current_plate_number': null,
              'occupied_since': null,
            }).eq('id', slotId);
          }
        }
      }

      // 2. Paid booking yang belum check-in tapi waktu checkout sudah habis
      final paidUpcomingBookings = await _client
          .from('bookings')
          .select('id, slot_id, end_time')
          .eq('payment_status', 'paid')
          .inFilter('booking_status', ['upcoming', 'confirmed']);

      for (final b in paidUpcomingBookings) {
        final end = DateTime.tryParse(b['end_time']?.toString() ?? '');
        if (end != null && nowUtc.isAfter(end.toUtc())) {
          await _client.from('bookings').update({
            'booking_status': 'completed',
          }).eq('id', b['id']);

          final slotId = b['slot_id']?.toString();
          if (slotId != null && slotId.isNotEmpty) {
            final activeSessionOnSlot = await _client
                .from('parking_sessions')
                .select('id')
                .eq('slot_id', slotId)
                .inFilter('status', ['active', 'overstay'])
                .maybeSingle();

            if (activeSessionOnSlot == null) {
              await _client.from('parking_slots').update({
                'status': 'available',
                'current_plate_number': null,
                'occupied_since': null,
              }).eq('id', slotId);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AdminBookingsBackend] _evaluateBookingsCleanup error: $e');
    }
  }

  /// Mengambil data pemesanan booking dari Supabase
  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _evaluateBookingsCleanup();

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
          final startDt = DateTime.tryParse(row['start_time']?.toString() ?? '')?.toLocal();
          final endDt = DateTime.tryParse(row['end_time']?.toString() ?? '')?.toLocal();

          final statusLabel = TicketMark.resolve(
            paymentStatus: pStatus,
            bookingStatus: bStatus,
            startTime: startDt,
            endTime: endDt,
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

  /// Force Check-In reservasi dari Manajemen Booking
  Future<bool> forceCheckInBooking(String bookingCode) async {
    final ok = await AdminOperationsDashboardBackend.instance.forceCheckInBooking(bookingCode);
    await fetchBookings();
    return ok;
  }

  /// Force Check-Out booking dari Manajemen Booking
  Future<bool> forceCheckOutBooking(String bookingCode) async {
    try {
      final b = await _client.from('bookings').select('id, slot_id').eq('booking_code', bookingCode).maybeSingle();
      if (b != null) {
        final bId = b['id'];
        final sess = await _client
            .from('parking_sessions')
            .select('id')
            .eq('booking_id', bId)
            .inFilter('status', ['active', 'overstay'])
            .maybeSingle();

        if (sess != null) {
          await AdminOperationsDashboardBackend.instance.forceCheckOutSession(sess['id'].toString());
        } else {
          await _client.from('bookings').update({'booking_status': 'completed'}).eq('id', bId);
          if (b['slot_id'] != null) {
            await _client.from('parking_slots').update({
              'status': 'available',
              'current_plate_number': null,
              'occupied_since': null,
            }).eq('id', b['slot_id']);
          }
          await AdminOperationsDashboardBackend.instance.fetchDashboardData();
        }
      }
      await fetchBookings();
      return true;
    } catch (e) {
      debugPrint('[AdminBookingsBackend] forceCheckOutBooking error: $e');
      return false;
    }
  }
}
