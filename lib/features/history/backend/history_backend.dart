import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryItem {
  final String id;
  final String mallName;
  final String date;
  final String status;
  final Color statusColor;
  final String duration;
  final String slot;
  final String price;
  final IconData icon;
  final bool isEv;

  HistoryItem({
    required this.id,
    required this.mallName,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.duration,
    required this.slot,
    required this.price,
    required this.icon,
    this.isEv = false,
  });

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    final statusStr = (map['status'] ?? 'selesai').toString().toLowerCase();
    final isSelesai = statusStr == 'completed' || statusStr == 'selesai';
    final vehicleDesc = (map['vehicle_desc'] ?? '').toString().toLowerCase();
    final isEv = vehicleDesc.contains('ev') || vehicleDesc.contains('ioniq');

    return HistoryItem(
      id: map['id']?.toString() ?? '',
      mallName: map['location_name'] ?? 'Central Park Mall',
      date: map['created_at'] != null
          ? map['created_at'].toString().substring(0, 10)
          : '21 Okt 2026',
      status: isSelesai ? 'Selesai' : 'Aktif',
      statusColor: isSelesai ? const Color(0xFF059669) : const Color(0xFFD97706),
      duration: map['duration'] ?? '2 Jam',
      slot: map['slot_code'] ?? 'Slot A-05',
      price: 'Rp ${(map['total_fee'] ?? 12000).toString()}',
      icon: isEv ? Icons.electric_car : Icons.local_parking,
      isEv: isEv,
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
    if (_selectedFilter == 'active') {
      return _items.where((i) => i.status == 'Aktif').toList();
    }
    return _items.where((i) => i.status == 'Selesai').toList();
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

      // 1. Ambil dari tabel parking_sessions
      final sessions = await _client
          .from('parking_sessions')
          .select('id, plate_number, vehicle_desc, check_in_time, total_fee, status, parking_locations(name)')
          .order('created_at', ascending: false)
          .limit(20);

      for (var s in sessions) {
        final locName = s['parking_locations'] != null ? s['parking_locations']['name']?.toString() : null;
        final map = Map<String, dynamic>.from(s);
        if (locName != null) map['location_name'] = locName;
        fetched.add(HistoryItem.fromMap(map));
      }

      // 2. Ambil dari tabel bookings
      final bookings = await _client
          .from('bookings')
          .select('id, booking_code, start_time, duration_hours, total_price, booking_status, parking_locations(name)')
          .order('created_at', ascending: false)
          .limit(20);

      for (var b in bookings) {
        final locName = b['parking_locations'] != null ? b['parking_locations']['name']?.toString() : 'Lokasi Parkir';
        final statusStr = b['booking_status']?.toString().toLowerCase() ?? 'upcoming';
        final isSelesai = statusStr == 'completed';
        final isAktif = statusStr == 'active' || statusStr == 'upcoming';

        fetched.add(HistoryItem(
          id: b['id']?.toString() ?? '',
          mallName: locName ?? 'ParkSmart Hub',
          date: b['start_time'] != null
              ? b['start_time'].toString().substring(0, 10)
              : 'Hari ini',
          status: isSelesai ? 'Selesai' : (isAktif ? 'Aktif' : statusStr),
          statusColor: isSelesai ? const Color(0xFF059669) : const Color(0xFFD97706),
          duration: '${b['duration_hours'] ?? 2} Jam',
          slot: 'Booking #${b['booking_code'] ?? ''}',
          price: 'Rp ${(b['total_price'] ?? 0).toString()}',
          icon: Icons.local_parking,
          isEv: false,
        ));
      }

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
