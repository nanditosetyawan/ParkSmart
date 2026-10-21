import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk SlotManagementScreen (admin_slot_management_screen.dart)
/// Mengelola status slot parkir fisik & sensor IoT (Tersedia, Terisi, Reserved, Maintenance)
/// Terkoneksi ke tabel `public.parking_slots` di Supabase
class AdminSlotManagementBackend extends ChangeNotifier {
  AdminSlotManagementBackend._();
  static final AdminSlotManagementBackend instance = AdminSlotManagementBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  late List<Map<String, dynamic>> slots = [];

  /// Mengambil data slot dari Supabase
  Future<void> fetchSlots({String? floorName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var query = _client
          .from('parking_slots')
          .select('id, slot_code, floor_name, slot_type, status, sensor_device_id, current_plate_number, occupied_since');

      if (floorName != null && floorName.isNotEmpty) {
        query = query.eq('floor_name', floorName);
      }

      final res = await query.order('slot_code', ascending: true);

      if (res.isNotEmpty) {
        slots = res.map<Map<String, dynamic>>((row) {
          final dbStatus = row['status']?.toString().toLowerCase();
          String statusLabel = 'Tersedia';
          if (dbStatus == 'occupied') {
            statusLabel = 'Terisi';
          } else if (dbStatus == 'reserved') {
            statusLabel = 'Reserved';
          } else if (dbStatus == 'maintenance') {
            statusLabel = 'Maintenance';
          }

          final dbType = row['slot_type']?.toString().toLowerCase();
          String typeLabel = 'Mobil';
          if (dbType == 'ev') {
            typeLabel = 'EV Charging';
          } else if (dbType == 'difabel') {
            typeLabel = 'Disabilitas';
          } else if (dbType == 'vip') {
            typeLabel = 'VIP';
          }

          return {
            'id': row['slot_code']?.toString() ?? 'A-01',
            'db_id': row['id']?.toString(),
            'type': typeLabel,
            'status': statusLabel,
            'plate': row['current_plate_number'],
            'duration': row['occupied_since'] != null ? 'Sedang Parkir' : null,
          };
        }).toList();
      } else {
        slots = [];
      }
    } catch (e) {
      debugPrint('[AdminSlotManagementBackend] fetchSlots error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update status slot
  Future<bool> updateSlotStatus(String slotCode, String newStatus) async {
    final idx = slots.indexWhere((s) => s['id'] == slotCode);
    if (idx != -1) {
      slots[idx]['status'] = newStatus;
      notifyListeners();
    }

    try {
      String dbStatus = 'available';
      if (newStatus == 'Terisi') dbStatus = 'occupied';
      if (newStatus == 'Reserved') dbStatus = 'reserved';
      if (newStatus == 'Maintenance') dbStatus = 'maintenance';

      await _client.from('parking_slots').update({
        'status': dbStatus,
      }).eq('slot_code', slotCode);
      return true;
    } catch (e) {
      debugPrint('[AdminSlotManagementBackend] updateSlotStatus error: $e');
      return false;
    }
  }
}
