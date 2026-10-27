import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/utils/ticket_status_helper.dart';
import '../../profile/backend/profile_backend.dart';

class HistoryItem {
  final String id;
  final String mallName;
  final String date;
  final DateTime rawDate;

  // Raw status fields — status dihitung ulang setiap akses (dinamis)
  final String rawPaymentStatus;
  final String rawBookingStatus;
  final String rawSessionStatus;

  // Waktu mentah untuk perhitungan status berdasarkan jam real-time
  final DateTime? rawStartTime;
  final DateTime? rawEndTime;
  final DateTime? rawCheckOutTime;
  final DateTime? rawExpectedCheckOutTime;

  /// Saat booking dibuat — dipakai untuk sisa waktu timer "Belum Dibayar"
  final DateTime? holdCreatedAt;

  final String duration;
  final String slot;
  final num rawPrice;
  final String price;
  final IconData icon;
  final bool isEv;
  final String? bookingCode;
  final bool isBookingOnly;
  final String? plateNumber;
  final String? vehicleName;

  final String? bookingId;
  final String? sessionId;

  const HistoryItem({
    required this.id,
    this.bookingId,
    this.sessionId,
    required this.mallName,
    required this.date,
    required this.rawDate,
    required this.rawPaymentStatus,
    required this.rawBookingStatus,
    required this.rawSessionStatus,
    this.rawStartTime,
    this.rawEndTime,
    this.rawCheckOutTime,
    this.rawExpectedCheckOutTime,
    this.holdCreatedAt,
    required this.duration,
    required this.slot,
    required this.rawPrice,
    required this.price,
    required this.icon,
    this.isEv = false,
    this.bookingCode,
    this.isBookingOnly = false,
    this.plateNumber,
    this.vehicleName,
  });

  /// Status dihitung DINAMIS — selalu pakai DateTime.now() terbaru
  String get status => TicketMark.resolve(
        paymentStatus: rawPaymentStatus.isNotEmpty ? rawPaymentStatus : null,
        bookingStatus: rawBookingStatus.isNotEmpty ? rawBookingStatus : null,
        sessionStatus: rawSessionStatus.isNotEmpty ? rawSessionStatus : null,
        startTime: rawStartTime,
        endTime: rawEndTime,
        checkOutTime: rawCheckOutTime,
        expectedCheckOutTime: rawExpectedCheckOutTime,
      );

  Color get statusColor => TicketMark.getColor(status);

  factory HistoryItem.fromSessionMap(Map<String, dynamic> map) {
    final statusStr = (map['status'] ?? 'active').toString().toLowerCase();
    final checkOutTime = map['check_out_time'] != null
        ? DateTime.tryParse(map['check_out_time'].toString())?.toLocal()
        : null;
    final expectedCheckOutTime = map['expected_check_out_time'] != null
        ? DateTime.tryParse(map['expected_check_out_time'].toString())?.toLocal()
        : null;
    final checkInTime = map['check_in_time'] != null
        ? DateTime.tryParse(map['check_in_time'].toString())?.toLocal()
        : null;

    final vehicleDesc = (map['vehicle_desc'] ?? '').toString();
    final isEv = vehicleDesc.toLowerCase().contains('ev') || vehicleDesc.toLowerCase().contains('ioniq');

    final slotCode = map['parking_slots']?['slot_code']?.toString() ??
        map['slot_code']?.toString() ??
        'A-01';
    final floorName = map['parking_slots']?['floor_name']?.toString() ??
        map['floor_name']?.toString() ??
        'Lantai 1';

    final booking = map['bookings'] as Map<String, dynamic>?;
    final bookingPayStatus = (booking?['payment_status'] ?? 'paid').toString().toLowerCase();
    String bookingStatus = (booking?['booking_status'] ?? '').toString().toLowerCase();

    // Jika sesi parkir berstatus aktif dan belum ada check-out time, sinkronkan bookingStatus ke active
    if (statusStr == 'active' && checkOutTime == null) {
      bookingStatus = 'active';
    }

    num fee = (map['total_fee'] as num?)?.toDouble() ??
        (map['parking_fee'] as num?)?.toDouble() ??
        0.0;
    if (fee <= 0 && booking != null) {
      fee = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
    }
    if (fee <= 0) fee = 5000.0;

    // Hitung durasi aktual dari rentang waktu check-in sampai expected check-out (termasuk perpanjangan waktu)
    int dHours = 0;
    if (expectedCheckOutTime != null && checkInTime != null) {
      final diffMins = expectedCheckOutTime.difference(checkInTime).inMinutes;
      dHours = (diffMins / 60.0).ceil();
    }
    if (dHours <= 0) {
      dHours = (booking?['duration_hours'] as num?)?.toInt() ?? 0;
    }
    if (dHours <= 0) dHours = 1;

    final createdAt = checkInTime ?? DateTime.now();
    final bookingCode = booking?['booking_code']?.toString() ??
        map['session_code']?.toString() ??
        map['id']?.toString();
    final plate = map['plate_number']?.toString() ?? booking?['plate_number']?.toString();
    final vDesc = vehicleDesc.isNotEmpty ? vehicleDesc : booking?['vehicle_desc']?.toString();

    return HistoryItem(
      id: map['id']?.toString() ?? '',
      bookingId: map['booking_id']?.toString(),
      sessionId: map['id']?.toString(),
      mallName: map['parking_locations']?['name']?.toString() ??
          map['location_name']?.toString() ??
          'ParkSmart Hub',
      date: '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
      rawDate: createdAt,
      rawPaymentStatus: bookingPayStatus,
      rawBookingStatus: bookingStatus,
      rawSessionStatus: statusStr,
      rawStartTime: checkInTime,
      rawEndTime: expectedCheckOutTime,
      rawCheckOutTime: checkOutTime,
      rawExpectedCheckOutTime: expectedCheckOutTime,
      holdCreatedAt: null,
      duration: '$dHours Jam',
      slot: 'Slot $slotCode • $floorName',
      rawPrice: fee,
      price: CurrencyService.instance.format(fee),
      icon: isEv ? Icons.electric_car : Icons.local_parking,
      isEv: isEv,
      bookingCode: bookingCode,
      isBookingOnly: false,
      plateNumber: plate,
      vehicleName: vDesc,
    );
  }

  factory HistoryItem.fromBookingMap(Map<String, dynamic> map) {
    final startTime = map['start_time'] != null
        ? DateTime.tryParse(map['start_time'].toString())?.toLocal()
        : null;
    final endTime = map['end_time'] != null
        ? DateTime.tryParse(map['end_time'].toString())?.toLocal()
        : null;

    final payStatus = (map['payment_status'] ?? '').toString().toLowerCase();
    final bookStatus = (map['booking_status'] ?? 'upcoming').toString().toLowerCase();

    final slotCode = map['parking_slots']?['slot_code']?.toString() ?? 'A-01';
    final floorName = map['parking_slots']?['floor_name']?.toString() ?? 'Lantai 1';
    final dHours = (map['duration_hours'] as num?)?.toInt() ?? 1;
    final fee = (map['total_price'] as num?)?.toDouble() ?? (dHours * 5000.0);

    final createdAt = map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString())?.toLocal() ?? DateTime.now()
        : DateTime.now();

    final plate = map['plate_number']?.toString() ?? map['vehicles']?['plate_number']?.toString();
    final vDesc = map['vehicle_desc']?.toString() ??
        (map['vehicles'] != null ? '${map['vehicles']['brand'] ?? ''} ${map['vehicles']['model'] ?? ''}'.trim() : null);

    return HistoryItem(
      id: map['id']?.toString() ?? '',
      bookingId: map['id']?.toString(),
      sessionId: null,
      mallName: map['parking_locations']?['name']?.toString() ?? 'ParkSmart Hub',
      date: '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
      rawDate: createdAt,
      rawPaymentStatus: payStatus,
      rawBookingStatus: bookStatus,
      rawSessionStatus: '',
      rawStartTime: startTime,
      rawEndTime: endTime,
      rawCheckOutTime: null,
      rawExpectedCheckOutTime: null,
      holdCreatedAt: createdAt,
      duration: '$dHours Jam',
      slot: 'Slot $slotCode • $floorName',
      rawPrice: fee,
      price: CurrencyService.instance.format(fee),
      icon: Icons.local_parking,
      isEv: false,
      bookingCode: map['booking_code']?.toString(),
      isBookingOnly: true,
      plateNumber: plate,
      vehicleName: vDesc,
    );
  }
}

/// Backend khusus untuk HistoryScreen (lib/features/history/history_screen.dart)
class HistoryBackend extends ChangeNotifier {
  HistoryBackend._();
  static final HistoryBackend instance = HistoryBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedFilter = 'all';
  String get selectedFilter => _selectedFilter;

  List<HistoryItem> _items = [];
  List<HistoryItem> get items {
    if (_selectedFilter == 'all') return _items;
    if (_selectedFilter == 'ready') {
      return _items.where((i) => i.status == TicketMark.ready).toList();
    }
    if (_selectedFilter == 'active') {
      return _items.where((i) => i.status == TicketMark.aktif).toList();
    }
    if (_selectedFilter == 'completed') {
      return _items.where((i) => i.status == TicketMark.selesai).toList();
    }
    if (_selectedFilter == 'unpaid') {
      return _items.where((i) => i.status == TicketMark.belumDibayar).toList();
    }
    return _items.where((i) => i.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Durasi hold slot untuk booking belum dibayar: 2 menit 59 detik
  static const int kHoldDurationSeconds = 179;

  /// Cleanup async — hapus booking unpaid yang sudah kadaluwarsa & bebaskan slot
  Future<void> _cleanupExpiredBooking(String bookingId, String? slotId) async {
    try {
      await _client
          .from('bookings')
          .update({
            'booking_status': 'cancelled',
            'cancel_reason': 'Waktu pembayaran habis (Auto Cancel)',
          })
          .eq('id', bookingId)
          .eq('payment_status', 'unpaid');
      if (slotId != null && slotId.isNotEmpty) {
        await _client.from('parking_slots').update({
          'status': 'available',
          'current_plate_number': null,
          'occupied_since': null,
        }).eq('id', slotId);
      }
    } catch (e) {
      debugPrint('HistoryBackend _cleanupExpiredBooking error: $e');
    }
  }

  void clear() {
    _items = [];
    notifyListeners();
  }

  Future<String> _resolveUserIdAsync() async {
    final sessionUid = SessionService.instance.userId;
    if (sessionUid != null && sessionUid.trim().isNotEmpty) {
      return sessionUid.trim();
    }

    final profileUid = ProfileBackend.instance.userId;
    if (profileUid.trim().isNotEmpty) {
      return profileUid.trim();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('ps_session_user_id') ?? prefs.getString('user_profile_id');
      if (savedId != null && savedId.trim().isNotEmpty) {
        return savedId.trim();
      }
    } catch (_) {}

    final authUser = _client.auth.currentUser;
    if (authUser != null) {
      try {
        final row = await _client.from('users').select('id').eq('auth_user_id', authUser.id).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }

    final email = SessionService.instance.identifier ?? ProfileBackend.instance.email;
    if (email.isNotEmpty) {
      try {
        final row = await _client.from('users').select('id').eq('email', email).maybeSingle();
        if (row != null && row['id'] != null) {
          return row['id'].toString();
        }
      } catch (_) {}
    }

    return '';
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Jalankan pembersihan otomatis agar pesanan expired/lewat checkout langsung disinkronkan
      try {
        await _client.rpc('auto_process_expired_bookings_and_sessions');
      } catch (_) {}

      final currentUserId = await _resolveUserIdAsync();
      if (currentUserId.isEmpty) {
        _items = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<HistoryItem> fetched = [];
      final Set<String> checkedInBookingIds = {};

      // 1. Ambil dari tabel parking_sessions (sesi yang sudah check-in) HANYA milik user yang login
      final sessions = await _client
          .from('parking_sessions')
          .select('id, session_code, booking_id, plate_number, vehicle_desc, check_in_time, expected_check_out_time, check_out_time, parking_fee, total_fee, status, parking_locations(name, address), parking_slots(slot_code, floor_name), bookings(booking_code, total_price, duration_hours, payment_status, booking_status, plate_number, vehicle_desc)')
          .eq('user_id', currentUserId)
          .order('check_in_time', ascending: false)
          .limit(30);

      for (var s in sessions) {
        if (s['booking_id'] != null) {
          checkedInBookingIds.add(s['booking_id'].toString());
        }
        fetched.add(HistoryItem.fromSessionMap(Map<String, dynamic>.from(s)));
      }

      // 2. Ambil dari tabel bookings (reservasi yang belum check-in: Ready atau Belum Dibayar) HANYA milik user yang login
      final bookings = await _client
          .from('bookings')
          .select('id, booking_code, start_time, end_time, duration_hours, total_price, payment_status, booking_status, plate_number, vehicle_desc, created_at, slot_id, parking_locations(name, address), parking_slots(slot_code, floor_name), vehicles(brand, model, plate_number)')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(30);

      for (var b in bookings) {
        final bId = b['id']?.toString() ?? '';
        if (checkedInBookingIds.contains(bId)) continue;

        final payStatus = (b['payment_status'] ?? '').toString().toLowerCase();

        // Jika unpaid — cek apakah sudah kadaluwarsa (>2:59 menit)
        if (payStatus == 'unpaid' || payStatus.isEmpty) {
          final createdAt = b['created_at'] != null
              ? DateTime.tryParse(b['created_at'].toString())?.toLocal()
              : null;
          if (createdAt != null) {
            final ageSeconds = DateTime.now().difference(createdAt).inSeconds;
            if (ageSeconds > kHoldDurationSeconds) {
              // Kadaluwarsa — cleanup di background, jangan tampilkan
              _cleanupExpiredBooking(bId, b['slot_id']?.toString());
              continue;
            }
          }
        }

        fetched.add(HistoryItem.fromBookingMap(Map<String, dynamic>.from(b)));
      }

      // Sorting: Belum Dibayar paling atas, lalu Ready, lalu Aktif, lalu Selesai
      int priority(String status) {
        if (status == TicketMark.belumDibayar) return 0;
        if (status == TicketMark.ready) return 1;
        if (status == TicketMark.aktif) return 2;
        if (status == TicketMark.selesai) return 3;
        return 4;
      }

      fetched.sort((a, b) {
        final pA = priority(a.status);
        final pB = priority(b.status);
        if (pA != pB) return pA.compareTo(pB);
        return b.rawDate.compareTo(a.rawDate);
      });

      _items = fetched;
    } catch (e) {
      debugPrint('HistoryBackend fetchHistory error: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
