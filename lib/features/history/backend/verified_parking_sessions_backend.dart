import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifiedSessionItem {
  final String id;
  final String locationName;
  final String slot;
  final String date;
  final String duration;
  final String amount;
  final String blockHash;
  final String validatorNode;
  final String timestamp;

  const VerifiedSessionItem({
    required this.id,
    required this.locationName,
    required this.slot,
    required this.date,
    required this.duration,
    required this.amount,
    required this.blockHash,
    required this.validatorNode,
    required this.timestamp,
  });
}

class VerifiedParkingSessionsBackend extends ChangeNotifier {
  VerifiedParkingSessionsBackend._();
  static final VerifiedParkingSessionsBackend instance = VerifiedParkingSessionsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _vehiclePlate = 'B 1234 XYZ';
  String get vehiclePlate => _vehiclePlate;

  String _vehicleInfo = 'Toyota Raize • Putih Pearl';
  String get vehicleInfo => _vehicleInfo;

  int _totalSessions = 28;
  int get totalSessions => _totalSessions;

  int _totalDurationHours = 64;
  int get totalDurationHours => _totalDurationHours;

  String _thisMonthSpending = 'Rp 284k';
  String get thisMonthSpending => _thisMonthSpending;

  String _selectedFilter = 'Semua Bulan';
  String get selectedFilter => _selectedFilter;

  List<VerifiedSessionItem> _sessions = [];
  List<VerifiedSessionItem> get sessions => _sessions.isEmpty ? _fallbackSessions : _sessions;

  static const List<VerifiedSessionItem> _fallbackSessions = [
    VerifiedSessionItem(
      id: 'sess-1',
      locationName: 'Central Park Mall',
      slot: 'Basement B2 • Slot A-05',
      date: '24 Okt 2026, 14:02 - 15:50 WIB',
      duration: '1j 48m',
      amount: 'Rp 9.000',
      blockHash: '0x7f9a...c32d',
      validatorNode: 'Jakarta Smart City Node #4',
      timestamp: '2026-10-24 15:50:12 UTC+7',
    ),
    VerifiedSessionItem(
      id: 'sess-2',
      locationName: 'Grand Indonesia Mall',
      slot: 'Lantai 3 • Slot B-12',
      date: '21 Okt 2026, 10:15 - 13:45 WIB',
      duration: '3j 30m',
      amount: 'Rp 20.000',
      blockHash: '0x3c2e...f81a',
      validatorNode: 'Jakarta Smart City Node #2',
      timestamp: '2026-10-21 13:45:30 UTC+7',
    ),
    VerifiedSessionItem(
      id: 'sess-3',
      locationName: 'Senayan City',
      slot: 'Basement B1 • Slot E-08',
      date: '18 Okt 2026, 18:20 - 20:50 WIB',
      duration: '2j 30m',
      amount: 'Rp 15.000',
      blockHash: '0x9d4b...a77e',
      validatorNode: 'Jakarta Smart City Node #1',
      timestamp: '2026-10-18 20:50:05 UTC+7',
    ),
  ];

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch default vehicle
      final vehicleRes = await _client
          .from('vehicles')
          .select('plate_number, brand, model, color')
          .limit(1)
          .maybeSingle();

      if (vehicleRes != null) {
        _vehiclePlate = vehicleRes['plate_number']?.toString() ?? _vehiclePlate;
        final brand = vehicleRes['brand']?.toString() ?? '';
        final model = vehicleRes['model']?.toString() ?? '';
        final color = vehicleRes['color']?.toString() ?? '';
        _vehicleInfo = '$brand $model • $color'.trim();
      }

      // 2. Fetch payments with blockchain hash
      final paymentsRes = await _client
          .from('payments')
          .select('id, transaction_code, amount, blockchain_hash, completed_at, description')
          .order('completed_at', ascending: false)
          .limit(20);

      if (paymentsRes.isNotEmpty) {
        _sessions = paymentsRes.map((p) {
          final hash = p['blockchain_hash']?.toString() ?? '0x${p['id'].toString().replaceAll('-', '').substring(0, 8)}...';
          final amt = (p['amount'] is num) ? (p['amount'] as num).toInt() : 0;
          return VerifiedSessionItem(
            id: p['id'].toString(),
            locationName: p['description']?.toString() ?? 'ParkSmart Facility',
            slot: 'Slot Otomatis Terverifikasi',
            date: p['completed_at']?.toString() ?? 'Terverifikasi',
            duration: '1-3 Jam',
            amount: 'Rp ${amt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            blockHash: hash.length > 14 ? '${hash.substring(0, 6)}...${hash.substring(hash.length - 4)}' : hash,
            validatorNode: 'Jakarta Smart City Node #1',
            timestamp: p['completed_at']?.toString() ?? DateTime.now().toIso8601String(),
          );
        }).toList();

        _totalSessions = _sessions.length;
      }
    } catch (e) {
      debugPrint('Error fetching verified sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
