import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/parking_notification_service.dart';
import '../../profile/backend/profile_backend.dart';

/// Backend khusus untuk HomeScreen (lib/features/home/home_screen.dart)
/// Menggunakan Targeted Column Query untuk efisiensi maksimal
class HomeBackend extends ChangeNotifier {
  HomeBackend._();
  static final HomeBackend instance = HomeBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _userId = '';
  String get userId => _userId;

  String _userName = 'Pengguna';
  String get userName {
    if (_userName.isNotEmpty && _userName != 'Pengguna') {
      return _userName;
    }
    final sessionName = SessionService.instance.userName;
    if (sessionName != null && sessionName.trim().isNotEmpty) {
      return sessionName.trim();
    }
    return _userName;
  }

  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;

  int _points = 0;
  int get points => _points;

  String _memberTier = 'BRONZE';
  String get memberTier => _memberTier;

  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  List<Map<String, dynamic>> _recommendedLocations = [];
  List<Map<String, dynamic>> get recommendedLocations => _recommendedLocations;

  List<Map<String, dynamic>> _allLocations = [];
  List<Map<String, dynamic>> get allLocations => _allLocations;

  String _selectedCategory = 'Terdekat';
  String get selectedCategory => _selectedCategory;

  List<Map<String, dynamic>> _activeSessions = [];
  List<Map<String, dynamic>> get activeSessions => _activeSessions;

  Map<String, dynamic>? _activeSession;
  Map<String, dynamic>? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSessions.isNotEmpty;

  Position? _currentGpsPosition;
  Position? get currentGpsPosition => _currentGpsPosition;

  void setLoggedInUser({
    required String id,
    required String userName,
    double walletBalance = 0.0,
    int points = 0,
    String memberTier = 'BRONZE',
  }) {
    _userId = id;
    _userName = userName;
    _walletBalance = walletBalance;
    _points = points;
    _memberTier = memberTier;
    notifyListeners();
  }

  /// Reset seluruh state HomeScreen ketika user logout atau switch akun
  void clear() {
    _userId = '';
    _userName = 'Pengguna';
    _walletBalance = 0.0;
    _points = 0;
    _memberTier = 'BRONZE';
    _unreadNotificationCount = 0;
    _recommendedLocations = [];
    _allLocations = [];
    _activeSessions = [];
    _activeSession = null;
    notifyListeners();
  }

  /// Memuat seluruh data pendukung HomeScreen dari Supabase
  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _fetchUserProfile();
      await Future.wait([
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

  /// 1. Ambil nama & profil user
  Future<void> _fetchUserProfile() async {
    try {
      String uid = _userId;
      if (uid.isEmpty) {
        uid = ProfileBackend.instance.userId.isNotEmpty
            ? ProfileBackend.instance.userId
            : (SessionService.instance.userId ?? '');
      }

      String email = SessionService.instance.identifier ?? ProfileBackend.instance.email;

      final user = _client.auth.currentUser;
      dynamic query = _client
          .from('users')
          .select('id, full_name, wallet_balance, points, member_tier');

      if (user != null) {
        query = query.eq('auth_user_id', user.id);
      } else if (uid.isNotEmpty) {
        query = query.eq('id', uid);
      } else if (email.isNotEmpty) {
        query = query.eq('email', email);
      } else {
        // Tidak ada user yang login! Jangan asal load user pertama
        return;
      }

      final data = await query.limit(1).maybeSingle();

      if (data != null) {
        _userId = data['id']?.toString() ?? _userId;
        _userName = data['full_name'] as String? ?? _userName;
        _walletBalance = (data['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        _points = (data['points'] as int?) ?? 0;
        _memberTier = data['member_tier'] as String? ?? 'BRONZE';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[HomeBackend] _fetchUserProfile error: $e');
    }
  }

  /// Mengubah kategori filter ('Terdekat', 'Mall', 'Parkir EV')
  Future<void> setFilterCategory(String category) async {
    _selectedCategory = category;
    notifyListeners();
    await _fetchRecommendedLocations();
    notifyListeners();
  }

  /// Muat ulang rekomendasi parkir berdasarkan filter aktif
  Future<void> refreshFilter() async {
    await _fetchRecommendedLocations();
    notifyListeners();
  }

  /// 2. Ambil lokasi parkir rekomendasi dari Supabase dengan filter GPS & Kategori
  Future<void> _fetchRecommendedLocations() async {
    try {
      // 1. Ambil semua lokasi aktif dari database Supabase
      final response = await _client
          .from('parking_locations')
          .select('id, code, name, type, city, address, latitude, longitude, total_capacity, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev, rating, review_count, status, image_url, images, facilities, operating_hours')
          .order('rating', ascending: false);

      List<Map<String, dynamic>> rawList = List<Map<String, dynamic>>.from(response);

      // Hitung koordinat dan jarak untuk seluruh lokasi terlebih dahulu
      Position? userPos = _currentGpsPosition;
      if (userPos == null) {
        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (serviceEnabled) {
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
            }
            if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
              userPos = await Geolocator.getCurrentPosition(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.medium,
                  timeLimit: Duration(seconds: 4),
                ),
              );
              _currentGpsPosition = userPos;
            }
          }
        } catch (gpsError) {
          debugPrint('[HomeBackend] GPS check error: $gpsError');
        }
      }

      // Koordinat acuan (GPS aktif atau default koordinat SCBD Jakarta)
      final refLat = userPos?.latitude ?? -6.1754;
      final refLng = userPos?.longitude ?? 106.8272;

      for (var loc in rawList) {
        final lat = (loc['latitude'] as num?)?.toDouble() ?? refLat;
        final lng = (loc['longitude'] as num?)?.toDouble() ?? refLng;
        final distMeters = Geolocator.distanceBetween(refLat, refLng, lat, lng);
        loc['calculated_distance'] = distMeters;
        loc['distance_label'] = distMeters < 1000
            ? '${distMeters.round()} m'
            : '${(distMeters / 1000).toStringAsFixed(1)} km';
      }

      // Simpan seluruh lokasi lengkap sebelum difilter kategori
      _allLocations = List<Map<String, dynamic>>.from(rawList);

      // 2. Filter Kategori berdasarkan kolom 'type' (%mall% dan %ev%) atau urutan 'Terdekat'
      if (_selectedCategory == 'Terdekat') {
        // Urutkan lokasi dari jarak terdekat ke terjauh berdasarkan posisi user
        rawList.sort((a, b) {
          final distA = (a['calculated_distance'] as num?)?.toDouble() ?? 99999999.0;
          final distB = (b['calculated_distance'] as num?)?.toDouble() ?? 99999999.0;
          return distA.compareTo(distB);
        });
      } else if (_selectedCategory == 'Mall') {
        // Filter kolom 'type' yang mengandung kata kunci "%mall%" (case-insensitive substring)
        rawList = rawList.where((loc) {
          final type = (loc['type'] ?? '').toString().toLowerCase();
          return type.contains('mall');
        }).toList();
      } else if (_selectedCategory == 'Parkir EV') {
        // Filter kolom 'type' yang mengandung kata kunci "%ev%" (case-insensitive substring)
        rawList = rawList.where((loc) {
          final type = (loc['type'] ?? '').toString().toLowerCase();
          return type.contains('ev');
        }).toList();
      }

      _recommendedLocations = rawList;
    } catch (e) {
      debugPrint('[HomeBackend] _fetchRecommendedLocations error: $e');
    }
  }

  /// 3. Hitung notifikasi belum dibaca (hanya untuk akun aktif & bukan broadcast role lain)
  Future<void> _fetchUnreadNotifications() async {
    try {
      final uid = _userId.isNotEmpty
          ? _userId
          : (ProfileBackend.instance.userId.isNotEmpty
              ? ProfileBackend.instance.userId
              : (SessionService.instance.userId ?? ''));

      if (uid.isEmpty) {
        _unreadNotificationCount = 0;
        notifyListeners();
        return;
      }

      var query = _client
          .from('system_notifications')
          .select('id, recipient_user_id, target_role')
          .eq('is_read', false)
          .inFilter('target_role', ['user', 'all']);

      query = query.or('recipient_user_id.eq.$uid,recipient_user_id.is.null');

      final data = await query;
      final rawList = List<Map<String, dynamic>>.from(data);
      final filtered = rawList.where((n) {
        final role = (n['target_role'] ?? 'all').toString().toLowerCase().trim();
        if (role != 'all' && role != 'user') return false;
        final rId = n['recipient_user_id']?.toString().trim();
        if (rId != null && rId.isNotEmpty && rId.toLowerCase() != uid.toLowerCase()) return false;
        return true;
      }).toList();

      _unreadNotificationCount = filtered.length;
      notifyListeners();
    } catch (e) {
      debugPrint('[HomeBackend] _fetchUnreadNotifications error: $e');
    }
  }

  /// Sinkronisasi badge unread notifikasi dari luar
  Future<void> refreshUnreadNotifications() => _fetchUnreadNotifications();

  /// Sinkronisasi sesi parkir aktif secara manual / otomatis dari luar
  Future<void> refreshActiveSessions() => _fetchActiveSession();

  /// 4. Ambil SEMUA sesi parkir aktif (sesi checkout / expired / force-out otomatis dihapus dari homescreen)
  Future<void> _fetchActiveSession() async {
    try {
      final now = DateTime.now();
      final uid = _userId.isNotEmpty
          ? _userId
          : (ProfileBackend.instance.userId.isNotEmpty
              ? ProfileBackend.instance.userId
              : (SessionService.instance.userId ?? ''));

      if (uid.isEmpty) {
        _activeSessions = [];
        _activeSession = null;
        notifyListeners();
        return;
      }

      // 1. Ambil riwayat sesi parkir terbaru milik user ini untuk membedakan yang aktif vs sudah selesai (termasuk force-out)
      final sessions = await _client
          .from('parking_sessions')
          .select('id, session_code, user_id, slot_id, booking_id, plate_number, vehicle_type, vehicle_desc, check_in_time, expected_check_out_time, check_out_time, parking_fee, total_fee, status, parking_locations(name, address, image_url), parking_slots(slot_code, floor_name)')
          .eq('user_id', uid)
          .order('check_in_time', ascending: false)
          .limit(30);

      final List<Map<String, dynamic>> list = [];
      final Set<String> activeBookingIds = {};
      final Set<String> completedBookingIds = {};

      for (var session in sessions) {
        final sStatus = (session['status'] ?? '').toString().toLowerCase().trim();
        final coTime = session['check_out_time'];
        final expTimeStr = session['expected_check_out_time'];
        final expTime = expTimeStr != null ? DateTime.tryParse(expTimeStr.toString())?.toLocal() : null;
        final bId = session['booking_id']?.toString();

        // Jika sesi sudah berstatus completed atau sudah terisi check_out_time (termasuk akibat Force Out admin):
        if (sStatus == 'completed' || coTime != null) {
          if (bId != null && bId.isNotEmpty) {
            completedBookingIds.add(bId);
            // Sinkronkan status booking terkait jika masih berstatus active / upcoming
            try {
              await _client
                  .from('bookings')
                  .update({'booking_status': 'completed'})
                  .eq('id', bId)
                  .neq('booking_status', 'completed');
            } catch (_) {}
          }
          continue; // Pasti TIDAK dimasukkan ke list aktif homescreen
        }

        // Jika waktu habis otomatis selesai
        if (expTime != null && now.isAfter(expTime)) {
          try {
            await _client.from('parking_sessions').update({
              'status': 'completed',
              'check_out_time': expTime.toUtc().toIso8601String(),
            }).eq('id', session['id']);

            if (session['slot_id'] != null) {
              await _client.from('parking_slots').update({
                'status': 'available',
                'current_plate_number': null,
                'occupied_since': null,
              }).eq('id', session['slot_id']);
            }

            if (bId != null && bId.isNotEmpty) {
              completedBookingIds.add(bId);
              await _client.from('bookings').update({
                'booking_status': 'completed',
              }).eq('id', bId);
            }
          } catch (_) {}
          continue; // Tidak dimasukkan ke list homescreen
        }

        // Hanya masukkan jika sesi memang murni active / overstay
        if (sStatus == 'active' || sStatus == 'overstay') {
          if (bId != null && bId.isNotEmpty) {
            activeBookingIds.add(bId);
          }

          // Sinkronisasikan ke monitor background jika ada waktu checkout
          if (expTime != null) {
            ParkingNotificationService().saveActiveSession(expectedCheckout: expTime);
            ParkingNotificationService.startBackgroundMonitor(expectedCheckout: expTime);
          }

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
      }

      // 2. Ambil booking yang sudah dibayar dan sesi mulainya sudah tiba secara otomatis (now >= start_time && now < end_time)
      // HANYA untuk reservasi yang BELUM pernah check-in / belum pernah ada sesi selesai
      if (uid.isNotEmpty) {
        try {
          final bookings = await _client
              .from('bookings')
              .select('id, booking_code, start_time, end_time, duration_hours, total_price, payment_status, booking_status, parking_locations(name, address, image_url), parking_slots(slot_code, floor_name), vehicles(plate_number, brand, model)')
              .eq('user_id', uid)
              .eq('payment_status', 'paid')
              .order('start_time', ascending: true);

          for (var b in bookings) {
            final bId = b['id']?.toString() ?? '';
            // Jangan tampilkan jika sudah ada sesi aktif ATAU booking ini sudah pernah ada sesi selesai/checkout/force-out!
            if (activeBookingIds.contains(bId) || completedBookingIds.contains(bId)) {
              continue;
            }

            final bStatus = (b['booking_status'] ?? '').toString().toLowerCase().trim();
            // Jika sudah completed, cancelled, atau active (artinya sudah pernah check-in tapi sesinya sudah tidak ada di active sessions)
            if (bStatus == 'completed' || bStatus == 'cancelled' || bStatus == 'active') {
              if (bStatus == 'active') {
                // Booking statusnya active tapi tidak ada di parking_sessions aktif -> sinkronkan ke completed
                try {
                  await _client.from('bookings').update({'booking_status': 'completed'}).eq('id', bId);
                } catch (_) {}
              }
              continue;
            }

            final start = b['start_time'] != null ? DateTime.tryParse(b['start_time'].toString())?.toLocal() : null;
            final end = b['end_time'] != null ? DateTime.tryParse(b['end_time'].toString())?.toLocal() : null;

            if (end != null && now.isAfter(end)) {
              // Waktu habis otomatis selesai
              try {
                await _client.from('bookings').update({
                  'booking_status': 'completed',
                }).eq('id', bId);
              } catch (_) {}
              continue;
            }

            if (start != null && (now.isAfter(start) || now.isAtSameMomentAs(start))) {
              // Sesi mulai otomatis timernya dengan sendirinya jika reservasi belum checkin
              final veh = b['vehicles'] as Map<String, dynamic>?;
              final vehDesc = veh != null ? '${veh['brand'] ?? ''} ${veh['model'] ?? ''}'.trim() : 'Kendaraan';
              final plate = veh?['plate_number']?.toString() ?? '';

              list.add({
                'type': 'booking',
                'id': bId,
                'title': 'SESI PARKIR AKTIF (JADWAL DIMULAI)',
                'tag': 'Sesi Parkir Aktif',
                'location_name': b['parking_locations']?['name'] ?? 'Spot Parkir',
                'location_address': b['parking_locations']?['address'] ?? '',
                'image_url': b['parking_locations']?['image_url'],
                'slot_code': b['parking_slots']?['slot_code'] ?? 'A-01',
                'floor_name': b['parking_slots']?['floor_name'] ?? 'Lantai 1',
                'plate_number': plate,
                'vehicle_desc': vehDesc,
                'start_time': b['start_time'],
                'end_time': b['end_time'],
              });
            }
          }
        } catch (e) {
          debugPrint('[HomeBackend] fetch auto-started bookings error: $e');
        }
      }

      _activeSessions = list;
      _activeSession = list.isNotEmpty ? list.first : null;
      notifyListeners();
    } catch (e) {
      debugPrint('[HomeBackend] _fetchActiveSession error: $e');
      _activeSessions = [];
      _activeSession = null;
      notifyListeners();
    }
  }
}
