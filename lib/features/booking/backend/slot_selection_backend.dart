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

  List<String> get floors {
    if (_currentLocation != null && _currentLocation!['floors'] is List && (_currentLocation!['floors'] as List).isNotEmpty) {
      return List<String>.from(_currentLocation!['floors']);
    }
    return ['Lantai 1'];
  }

  List<Map<String, dynamic>> get zoneASlots {
    return _slots.where((s) {
      final zone = s['zone']?.toString();
      final code = (s['slot_code'] as String?)?.toUpperCase() ?? '';
      if (zone == 'zoneA') return true;
      if (zone == 'zoneB') return false;
      return code.startsWith('A');
    }).toList();
  }

  List<Map<String, dynamic>> get zoneBSlots {
    return _slots.where((s) {
      final zone = s['zone']?.toString();
      final code = (s['slot_code'] as String?)?.toUpperCase() ?? '';
      final type = s['slot_type']?.toString().toLowerCase() ?? '';
      if (zone == 'zoneB') return true;
      if (zone == 'zoneA') return false;
      return code.startsWith('B') || type == 'ev';
    }).toList();
  }

  /// Memuat data slot untuk lokasi dan lantai tertentu dari Supabase
  Future<void> fetchSlots({String? locationId, String? floorName}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil info ringkas lokasi (Targeted Column Query)
      var locQuery = _client
          .from('parking_locations')
          .select('id, name, address, latitude, longitude, hourly_rate_mobil, total_capacity, floors');

      if (locationId != null) {
        _currentLocation = await locQuery.eq('id', locationId).maybeSingle();
      } else {
        _currentLocation ??= await locQuery.order('created_at', ascending: false).limit(1).maybeSingle();
      }

      if (_currentLocation == null) {
        _slots = [];
        return;
      }

      // 2. Tentukan lantai aktif
      final activeFloor = floorName ?? (floors.isNotEmpty ? floors.first : 'Lantai 1');

      // 3. Ambil data slot parkir aktual dari Supabase
      var slotQuery = _client
          .from('parking_slots')
          .select('id, location_id, floor_name, zone, slot_code, slot_type, status, current_plate_number')
          .eq('location_id', _currentLocation!['id'])
          .eq('floor_name', activeFloor);

      final response = await slotQuery.order('slot_code', ascending: true);
      _slots = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[SlotSelectionBackend] fetchSlots error: $e');
      _slots = [];
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
    final status = match['status']?.toString().toLowerCase();
    return status == 'available';
  }

  /// Menghitung jumlah slot tersedia di lantai aktif
  int get availableCount {
    if (_slots.isEmpty) return 0;
    return _slots.where((s) => s['status']?.toString().toLowerCase() == 'available').length;
  }
}
