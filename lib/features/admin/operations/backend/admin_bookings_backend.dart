import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final List<Map<String, dynamic>> _defaultBookings = [
    {
      'id': 'BKG-20240315-001',
      'user': {'name': 'Nanda Setiawan', 'phone': '+62 812-3456-7890', 'avatar': 'N'},
      'location': 'Central Park Mall',
      'slot': 'A-05',
      'floor': 'B1',
      'vehicle': {'plate': 'B 1234 ABC', 'type': 'Mobil'},
      'startTime': '2024-03-15 08:30',
      'endTime': '2024-03-15 12:30',
      'durationHours': 4,
      'status': 'Mendatang',
      'bookingType': 'Reservasi',
      'totalPrice': 28000,
      'paymentStatus': 'Dibayar',
      'createdAt': '2024-03-14 20:15',
    },
    {
      'id': 'BKG-20240315-002',
      'user': {'name': 'Rafi Maulana', 'phone': '+62 856-7890-1234', 'avatar': 'R'},
      'location': 'Grand Indonesia',
      'slot': 'B-12',
      'floor': 'B2',
      'vehicle': {'plate': 'B 9012 GHI', 'type': 'Mobil'},
      'startTime': '2024-03-15 10:00',
      'endTime': '2024-03-15 14:00',
      'durationHours': 4,
      'status': 'Aktif',
      'bookingType': 'Langsung',
      'totalPrice': 32000,
      'paymentStatus': 'Dibayar',
      'createdAt': '2024-03-15 09:50',
    },
    {
      'id': 'BKG-20240315-003',
      'user': {'name': 'Hana Aulia', 'phone': '+62 878-1122-3344', 'avatar': 'H'},
      'location': 'Central Park Mall',
      'slot': 'B-01',
      'floor': 'B2',
      'vehicle': {'plate': 'B 1111 ION', 'type': 'EV'},
      'startTime': '2024-03-15 13:00',
      'endTime': '2024-03-15 16:00',
      'durationHours': 3,
      'status': 'Mendatang',
      'bookingType': 'Reservasi',
      'totalPrice': 37500,
      'paymentStatus': 'Dibayar',
      'createdAt': '2024-03-15 07:30',
    },
  ];

  late List<Map<String, dynamic>> bookings = List.from(_defaultBookings);

  /// Mengambil data pemesanan booking dari Supabase
  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('bookings')
          .select('id, booking_code, booking_type, start_time, end_time, duration_hours, total_price, payment_status, booking_status, created_at')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        bookings = res.map<Map<String, dynamic>>((row) {
          final bStatus = row['booking_status']?.toString().toLowerCase();
          String statusLabel = 'Mendatang';
          if (bStatus == 'active') {
            statusLabel = 'Aktif';
          } else if (bStatus == 'completed') {
            statusLabel = 'Selesai';
          } else if (bStatus == 'cancelled') {
            statusLabel = 'Dibatalkan';
          }

          final price = (row['total_price'] as num?)?.toDouble() ?? 25000;

          return {
            'id': row['booking_code']?.toString() ?? 'BKG-001',
            'db_id': row['id']?.toString(),
            'user': {'name': 'Pelanggan ParkSmart', 'phone': '+62 812-xxxx-xxxx', 'avatar': 'P'},
            'location': 'Central Park Mall',
            'slot': 'A-05',
            'floor': 'B1',
            'vehicle': {'plate': 'B 1234 ABC', 'type': 'Mobil'},
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
      }
    } catch (e) {
      debugPrint('[AdminBookingsBackend] fetchBookings error: $e');
      _errorMessage = e.toString();
      if (bookings.isEmpty) {
        bookings = List.from(_defaultBookings);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Batalkan reservasi booking
  Future<bool> cancelBooking(String bookingCode, String reason) async {
    final idx = bookings.indexWhere((b) => b['id'] == bookingCode);
    if (idx != -1) {
      bookings[idx]['status'] = 'Dibatalkan';
      notifyListeners();
    }

    try {
      await _client.from('bookings').update({
        'booking_status': 'cancelled',
        'cancel_reason': reason,
      }).eq('booking_code', bookingCode);
      return true;
    } catch (e) {
      debugPrint('[AdminBookingsBackend] cancelBooking error: $e');
      return false;
    }
  }
}
