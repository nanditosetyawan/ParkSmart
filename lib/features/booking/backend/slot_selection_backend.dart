import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk SlotSelectionScreen (lib/features/booking/slot_selection_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *)
class SlotSelectionBackend extends ChangeNotifier {
  SlotSelectionBackend._();
  static final SlotSelectionBackend instance = SlotSelectionBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _slots = [];
  List<Map<String, dynamic>> get slots => _slots;

  Map<String, dynamic>? _currentLocation;
  Map<String, dynamic>? get currentLocation => _currentLocation;

  String? _selectedSlotCode;
  String? get selectedSlotCode => _selectedSlotCode;

  void selectSlot(String? code) {
    _selectedSlotCode = code;
    notifyListeners();
  }

  /// Memuat data slot untuk lokasi dan lantai tertentu dari Supabase
  Future<void> fetchSlots({String? locationId, String? floorName}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil info ringkas lokasi (Targeted Column Query)
      var locQuery = _client
          .from('parking_locations')
          .select('id, name, address, hourly_rate_mobil, total_capacity');

      if (locationId != null) {
        _currentLocation = await locQuery.eq('id', locationId).maybeSingle();
      } else {
        _currentLocation = await locQuery.order('rating', ascending: false).limit(1).maybeSingle();
      }

      // 2. Ambil data slot parkir (Targeted Column Query)
      var slotQuery = _client
          .from('parking_slots')
          .select('id, location_id, floor_name, slot_code, slot_type, status, current_vehicle_plate');

      if (_currentLocation != null && _currentLocation!['id'] != null) {
        slotQuery = slotQuery.eq('location_id', _currentLocation!['id']);
      }

      if (floorName != null && floorName.isNotEmpty) {
        slotQuery = slotQuery.eq('floor_name', floorName);
      }

      final response = await slotQuery.order('slot_code', ascending: true);
      _slots = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SlotSelectionBackend] fetchSlots error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengecek apakah slot tertentu tersedia
  bool isSlotAvailable(String slotCode) {
    final match = _slots.firstWhere(
      (s) => (s['slot_code'] as String?)?.toUpperCase() == slotCode.toUpperCase(),
      orElse: () => {},
    );
    if (match.isEmpty) return false;
    return match['status'] == 'available';
  }

  /// Menghitung jumlah slot tersedia di lantai aktif
  int get availableCount {
    if (_slots.isEmpty) return 0;
    return _slots.where((s) => s['status'] == 'available').length;
  }
}
