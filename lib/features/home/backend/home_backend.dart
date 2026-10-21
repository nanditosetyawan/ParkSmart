import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk HomeScreen (lib/features/home/home_screen.dart)
/// Menggunakan Targeted Column Query (NO SELECT *) untuk efisiensi maksimal
class HomeBackend extends ChangeNotifier {
  HomeBackend._();
  static final HomeBackend instance = HomeBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userName = 'Nandito Setyawan';
  String get userName => _userName;

  double _walletBalance = 250000.0;
  double get walletBalance => _walletBalance;

  int _points = 1250;
  int get points => _points;

  String _memberTier = 'GOLD';
  String get memberTier => _memberTier;

  int _unreadNotificationCount = 2;
  int get unreadNotificationCount => _unreadNotificationCount;

  List<Map<String, dynamic>> _recommendedLocations = [];
  List<Map<String, dynamic>> get recommendedLocations => _recommendedLocations;

  List<Map<String, dynamic>> _activeSessions = [];
  List<Map<String, dynamic>> get activeSessions => _activeSessions;

  Map<String, dynamic>? _activeSession;
  Map<String, dynamic>? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSessions.isNotEmpty;

  /// Memuat seluruh data pendukung HomeScreen dari Supabase
  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _fetchUserProfile(),
        _fetchRecommendedLocations(),
        _fetchUnreadNotifications(),
        _fetchActiveSession(),
      ]);
    } catch (e) {
      debugPrint('[HomeBackend] loadHomeData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 1. Ambil nama & profil user (Targeted Columns: full_name, wallet_balance, points, member_tier)
  Future<void> _fetchUserProfile() async {
    try {
      final data = await _client
          .from('users')
          .select('full_name, wallet_balance, points, member_tier')
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        _userName = data['full_name'] as String? ?? _userName;
        _walletBalance = (data['wallet_balance'] as num?)?.toDouble() ?? _walletBalance;
        _points = (data['points'] as int?) ?? _points;
        _memberTier = data['member_tier'] as String? ?? _memberTier;
      }
    } catch (e) {
      debugPrint('[HomeBackend] _fetchUserProfile error: $e');
    }
  }

  /// 2. Ambil lokasi parkir rekomendasi dari Supabase (diinput oleh Admin Operasional)
  Future<void> _fetchRecommendedLocations() async {
    try {
      final data = await _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, rating, review_count, status, image_url, images, facilities')
          .order('rating', ascending: false)
          .limit(10);

      _recommendedLocations = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('[HomeBackend] _fetchRecommendedLocations error: $e');
    }
  }

  /// 3. Hitung notifikasi belum dibaca (Targeted Column: id saja)
  Future<void> _fetchUnreadNotifications() async {
    try {
      final data = await _client
          .from('system_notifications')
          .select('id')
          .eq('is_read', false);

      _unreadNotificationCount = data.length;
    } catch (e) {
      debugPrint('[HomeBackend] _fetchUnreadNotifications error: $e');
    }
  }

  /// 4. Ambil SEMUA sesi parkir aktif yang sudah check-in di gerbang (parking_sessions)
  Future<void> _fetchActiveSession() async {
    try {
      final sessions = await _client
          .from('parking_sessions')
          .select('id, session_code, plate_number, vehicle_type, vehicle_desc, check_in_time, expected_check_out_time, parking_fee, total_fee, status, parking_locations(name, address, image_url), parking_slots(slot_code, floor_name)')
          .eq('status', 'active')
          .order('check_in_time', ascending: false);

      final List<Map<String, dynamic>> list = [];
      for (var session in sessions) {
        list.add({
          'type': 'session',
          'id': session['id']?.toString(),
          'title': 'SESI PARKIR AKTIF',
          'tag': 'Sesi Parkir Aktif',
          'location_name': session['parking_locations']?['name'] ?? 'Spot Parkir',
          'location_address': session['parking_locations']?['address'] ?? '',
          'image_url': session['parking_locations']?['image_url'],
          'slot_code': session['parking_slots']?['slot_code'] ?? 'A-01',
          'floor_name': session['parking_slots']?['floor_name'] ?? 'Lantai B1',
          'plate_number': session['plate_number'] ?? '',
          'vehicle_desc': session['vehicle_desc'] ?? '',
          'start_time': session['check_in_time'],
          'end_time': session['expected_check_out_time'] ?? session['check_in_time'],
        });
      }

      _activeSessions = list;
      _activeSession = list.isNotEmpty ? list.first : null;
    } catch (e) {
      debugPrint('[HomeBackend] _fetchActiveSession error: $e');
      _activeSessions = [];
      _activeSession = null;
    }
  }
}
