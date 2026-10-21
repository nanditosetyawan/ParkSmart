import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/utils/ticket_status_helper.dart';

class HistoryItem {
  final String id;
  final String mallName;
  final String date;
  final DateTime rawDate;
  final String status;
  final Color statusColor;
  final String duration;
  final String slot;
  final num rawPrice;
  final String price;
  final IconData icon;
  final bool isEv;
  final String? bookingCode;
  final bool isBookingOnly;

  HistoryItem({
    required this.id,
    required this.mallName,
    required this.date,
    required this.rawDate,
    required this.status,
    required this.statusColor,
    required this.duration,
    required this.slot,
    required this.rawPrice,
    required this.price,
    required this.icon,
    this.isEv = false,
    this.bookingCode,
    this.isBookingOnly = false,
  });

  factory HistoryItem.fromSessionMap(Map<String, dynamic> map) {
    final statusStr = (map['status'] ?? 'completed').toString().toLowerCase();
    final mark = TicketMark.resolve(sessionStatus: statusStr);
    final vehicleDesc = (map['vehicle_desc'] ?? '').toString().toLowerCase();
    final isEv = vehicleDesc.contains('ev') || vehicleDesc.contains('ioniq');

    final slotCode = map['parking_slots']?['slot_code']?.toString() ??
        map['slot_code']?.toString() ??
        'A-01';
    final floorName = map['parking_slots']?['floor_name']?.toString() ??
        map['floor_name']?.toString() ??
        'Lantai 1';

    num fee = (map['total_fee'] as num?)?.toDouble() ??
        (map['parking_fee'] as num?)?.toDouble() ??
        0.0;
    if (fee <= 0 && map['bookings'] != null) {
      fee = (map['bookings']['total_price'] as num?)?.toDouble() ?? 11000.0;
    }
    if (fee <= 0) fee = 11000.0;

    final createdAt = map['check_in_time'] != null
        ? DateTime.tryParse(map['check_in_time'].toString())?.toLocal() ?? DateTime.now()
        : DateTime.now();

    final bookingCode = map['bookings']?['booking_code']?.toString() ??
        map['session_code']?.toString() ??
        map['id']?.toString();

    return HistoryItem(
      id: map['id']?.toString() ?? '',
      mallName: map['parking_locations']?['name']?.toString() ??
          map['location_name']?.toString() ??
          'ParkSmart Hub',
      date: '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
      rawDate: createdAt,
      status: mark,
      statusColor: TicketMark.getColor(mark),
      duration: map['duration'] ?? '2 Jam',
      slot: 'Slot $slotCode • $floorName',
      rawPrice: fee,
      price: CurrencyService.instance.format(fee),
      icon: isEv ? Icons.electric_car : Icons.local_parking,
      isEv: isEv,
      bookingCode: bookingCode,
      isBookingOnly: false,
    );
  }

  factory HistoryItem.fromBookingMap(Map<String, dynamic> map) {
    final mark = TicketMark.resolve(
      paymentStatus: map['payment_status']?.toString(),
      bookingStatus: map['booking_status']?.toString(),
    );

    final slotCode = map['parking_slots']?['slot_code']?.toString() ?? 'A-01';
    final floorName = map['parking_slots']?['floor_name']?.toString() ?? 'Lantai 1';
    final fee = (map['total_price'] as num?)?.toDouble() ?? 11000.0;

    final createdAt = map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString())?.toLocal() ?? DateTime.now()
        : DateTime.now();

    return HistoryItem(
      id: map['id']?.toString() ?? '',
      mallName: map['parking_locations']?['name']?.toString() ?? 'ParkSmart Hub',
      date: '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
      rawDate: createdAt,
      status: mark,
      statusColor: TicketMark.getColor(mark),
      duration: '${map['duration_hours'] ?? 2} Jam',
      slot: 'Slot $slotCode • $floorName',
      rawPrice: fee,
      price: CurrencyService.instance.format(fee),
      icon: Icons.local_parking,
      isEv: false,
      bookingCode: map['booking_code']?.toString(),
      isBookingOnly: true,
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

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<HistoryItem> fetched = [];
      final Set<String> checkedInBookingIds = {};

      // 1. Ambil dari tabel parking_sessions (sesi yang sudah check-in)
      final sessions = await _client
          .from('parking_sessions')
          .select('id, session_code, booking_id, plate_number, vehicle_desc, check_in_time, parking_fee, total_fee, status, parking_locations(name, address), parking_slots(slot_code, floor_name), bookings(booking_code, total_price, duration_hours)')
          .order('check_in_time', ascending: false)
          .limit(30);

      for (var s in sessions) {
        if (s['booking_id'] != null) {
          checkedInBookingIds.add(s['booking_id'].toString());
        }
        fetched.add(HistoryItem.fromSessionMap(Map<String, dynamic>.from(s)));
      }

      // 2. Ambil dari tabel bookings (reservasi yang belum check-in: Ready atau Belum Dibayar)
      final bookings = await _client
          .from('bookings')
          .select('id, booking_code, start_time, duration_hours, total_price, payment_status, booking_status, created_at, parking_locations(name, address), parking_slots(slot_code, floor_name), vehicles(brand, model, plate_number)')
          .order('created_at', ascending: false)
          .limit(30);

      for (var b in bookings) {
        final bId = b['id']?.toString() ?? '';
        // Jika booking ini sudah check-in menjadi parking_session, jangan gandakan di list
        if (checkedInBookingIds.contains(bId)) {
          continue;
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
