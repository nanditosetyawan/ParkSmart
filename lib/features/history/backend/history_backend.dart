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
      final res = await _client
          .from('parking_sessions')
          .select('id, plate_number, vehicle_desc, check_in_time, total_fee, status')
          .order('created_at', ascending: false)
          .limit(20);

      if (res.isNotEmpty) {
        _items = res.map((r) => HistoryItem.fromMap(r)).toList();
      } else {
        _useFallbackData();
      }
    } catch (e) {
      debugPrint('HistoryBackend fetchHistory error (using fallback): $e');
      _useFallbackData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useFallbackData() {
    _items = [
      HistoryItem(
        id: 'hist-001',
        mallName: 'Central Park Mall',
        date: 'Hari ini • 14:20',
        status: 'Aktif',
        statusColor: const Color(0xFFD97706),
        duration: '1 Jam 15 Mnt',
        slot: 'Slot A-05',
        price: 'Rp 8.000',
        icon: Icons.local_parking,
        isEv: false,
      ),
      HistoryItem(
        id: 'hist-002',
        mallName: 'Grand Indonesia',
        date: '21 Okt 2026 • 18:30',
        status: 'Selesai',
        statusColor: const Color(0xFF059669),
        duration: '3 Jam',
        slot: 'Slot C-14',
        price: 'Rp 18.000',
        icon: Icons.garage,
        isEv: false,
      ),
      HistoryItem(
        id: 'hist-003',
        mallName: 'Pacific Place SCBD',
        date: '18 Okt 2026 • 10:15',
        status: 'Selesai',
        statusColor: const Color(0xFF059669),
        duration: '1 Jam',
        slot: 'Slot B-02 (EV)',
        price: 'Rp 15.000',
        icon: Icons.electric_car,
        isEv: true,
      ),
    ];
  }
}
