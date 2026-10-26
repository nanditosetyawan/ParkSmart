import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../parking/parking_detail_screen.dart';
import '../home/home_screen.dart';
import '../favorite/favorite_screen.dart';
import '../navigation/ar_navigation_screen.dart';
import 'backend/explore_map_backend.dart';
import '../../core/services/currency_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profile/backend/feedback_backend.dart';
import '../profile/backend/vehicle_backend.dart';
import 'widgets/compass_detail_dialog.dart';

class ExploreMapScreen extends StatefulWidget {
  final Map<String, dynamic>? initialSelectedParking;
  const ExploreMapScreen({super.key, this.initialSelectedParking});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final MapController _mapController = MapController();

  // Search query, text controller & focus node
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  LatLng? _searchResultPoint;
  String? _searchResultName;
  bool _isSearching = false;
  List<Map<String, dynamic>> _filteredSuggestions = [];
  Map<String, dynamic>? _selectedParking;
  final DraggableScrollableController _placeDetailsController = DraggableScrollableController();
  int _selectedDetailTab = 0; // 0: Ringkasan, 1: Ulasan, 2: Tentang

  String _formatParkingPrice(Map<String, dynamic> loc) {
    final vType = VehicleBackend.instance.defaultVehicle?.vehicleType.toLowerCase() ?? 'mobil';
    final isMotor = vType.contains('motor') || vType.contains('bike');
    final isEv = vType.contains('ev') || vType.contains('electric');

    final num? rate = isMotor
        ? (loc['hourly_rate_motor'] as num?)
        : (isEv
            ? ((loc['hourly_rate_ev'] as num?) ?? (loc['hourly_rate_mobil'] as num?))
            : (loc['hourly_rate_mobil'] as num?));

    if (rate != null && rate > 0) {
      return '${CurrencyService.instance.format(rate)} / jam';
    }
    final num? fallbackRate = (loc['hourly_rate_active'] as num?) ??
        (loc['hourly_rate_mobil'] as num?) ??
        (loc['hourly_rate_ev'] as num?);
    if (fallbackRate != null && fallbackRate > 0) {
      return '${CurrencyService.instance.format(fallbackRate)} / jam';
    }
    final p = loc['price']?.toString() ?? '';
    final digits = RegExp(r'\d+').allMatches(p).map((m) => m.group(0)).join();
    final val = num.tryParse(digits);
    if (val != null && val > 0) {
      return '${CurrencyService.instance.format(val)} / jam';
    }
    return '${CurrencyService.instance.format(5000)} / jam';
  }

  final List<String> _feedbackTopics = const [
    'Akurasi Sensor ANPR',
    'Kemudahan Gate',
    'Ketersediaan Slot',
    'Tarif & Pembayaran',
    'Lainnya',
  ];

  String _selectedReviewFilterTopic = 'Semua';

  List<Map<String, dynamic>> _userReviews = [];

  /// Menghasilkan keterangan wilayah ("Nama Kabupaten/Kota, Nama Provinsi") untuk rekomendasi pencarian
  String _getLocationRegionDesc(Map<String, dynamic> loc) {
    final address = (loc['address'] ?? '').toString();
    final city = (loc['city'] ?? '').toString().trim();

    String kabupatenKota = '';
    String provinsi = '';

    final kabMatch = RegExp(r'(Kabupaten\s+[A-Za-z\s]+|Kota\s+[A-Za-z\s]+)', caseSensitive: false).firstMatch(address);
    if (kabMatch != null) {
      kabupatenKota = kabMatch.group(0)!.trim();
      if (kabupatenKota.contains(',')) {
        kabupatenKota = kabupatenKota.split(',').first.trim();
      }
    } else if (city.isNotEmpty) {
      if (city.toLowerCase().startsWith('kota') || city.toLowerCase().startsWith('kab')) {
        kabupatenKota = city;
      } else if (city.toLowerCase() == 'yogyakarta') {
        kabupatenKota = 'Kota Yogyakarta';
      } else {
        kabupatenKota = 'Kota $city';
      }
    }

    final addrLower = address.toLowerCase();
    final cityLower = city.toLowerCase();
    if (addrLower.contains('daerah istimewa yogyakarta') || addrLower.contains('d.i. yogyakarta') || addrLower.contains('diy') || cityLower.contains('yogyakarta')) {
      provinsi = 'D.I. Yogyakarta';
    } else if (addrLower.contains('jawa timur') || cityLower.contains('surabaya') || cityLower.contains('malang')) {
      provinsi = 'Jawa Timur';
    } else if (addrLower.contains('jawa tengah') || cityLower.contains('semarang') || cityLower.contains('solo')) {
      provinsi = 'Jawa Tengah';
    } else if (addrLower.contains('jawa barat') || cityLower.contains('bandung') || cityLower.contains('bogor')) {
      provinsi = 'Jawa Barat';
    } else if (addrLower.contains('dki jakarta') || addrLower.contains('jakarta') || cityLower.contains('jakarta')) {
      provinsi = 'DKI Jakarta';
    } else if (addrLower.contains('banten') || cityLower.contains('tangerang')) {
      provinsi = 'Banten';
    } else if (addrLower.contains('bali') || cityLower.contains('denpasar')) {
      provinsi = 'Bali';
    }

    if (kabupatenKota.isNotEmpty && provinsi.isNotEmpty) {
      return '$kabupatenKota, $provinsi';
    } else if (kabupatenKota.isNotEmpty) {
      return kabupatenKota;
    } else if (provinsi.isNotEmpty) {
      return provinsi;
    } else {
      return city.isNotEmpty ? city : 'Indonesia';
    }
  }

  // Mode Tile Map (Standar OSM vs Satelit)
  bool _isSatellite = false;

  // GPS & Pelacakan Lokasi
  bool _isGpsActive = false;
  String _weatherTemp = '--°C';
  String _weatherCondition = 'Memuat...';
  String _weatherEmoji = '⛅';
  LatLng? _currentPosition;
  LatLng? _userGpsPosition; // Posisi GPS riil asli perangkat pengguna
  double _heading = 0.0; // Sudut orientasi kompas dalam radian

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _lastAx = 0.0, _lastAy = 9.8, _lastAz = 0.0;

  // Draggable Sheet Controller
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  // Kategori terpilih (Terdekat, Mall, Parkir EV)
  String _selectedCategory = '';

  // Data lokasi parkir dinamis murni dari Supabase (diinput oleh Admin Operasional)
  // Tidak ada marker di peta jika database kosong / belum diinput admin
  final List<Map<String, dynamic>> _parkingLocations = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi sensor kompas riil perangkat
    _initCompassSensor();
    // Titik awal peta default: Jakarta (akan diperbarui otomatis dengan GPS perangkat riil)
    _currentPosition = const LatLng(-6.1754, 106.7933);
    _fetchWeather(_currentPosition!);
    _autoDetectGpsLocation();

    if (widget.initialSelectedParking != null) {
      final loc = widget.initialSelectedParking!;
      _parkingLocations.add(loc);
      _selectedParking = loc;
      _fetchLiveParkingDetails(loc['id']?.toString());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onParkingMarkerTapped(loc);
      });
    }

    // Ambil data lokasi parkir live dari backend Supabase (diinput oleh Admin Operasional)
    // Jika database kosong, tidak ada titik di peta sama sekali
    ExploreMapBackend.instance.fetchMapLocations().then((_) {
      if (mounted) {
        setState(() {
          _parkingLocations.clear();
          if (widget.initialSelectedParking != null) {
            _parkingLocations.add(widget.initialSelectedParking!);
          }
          for (final loc in ExploreMapBackend.instance.locations) {
            if (!_parkingLocations.any((p) => p['name'] == loc['name'])) {
              _parkingLocations.add(loc);
            }
          }
          // Jika ada lokasi dari database, belum ada yang dipilih, dan belum dapat GPS, pusatkan ke lokasi pertama
          if (_selectedParking == null && _parkingLocations.isNotEmpty && !_isGpsActive && _userGpsPosition == null) {
            final firstLoc = _parkingLocations.first;
            if (firstLoc['point'] != null) {
              _currentPosition = firstLoc['point'] as LatLng;
            }
          }
        });
        _fetchLocationReviews(_selectedParking?['id']?.toString());
        _fetchLiveParkingDetails(_selectedParking?['id']?.toString());
      }
    });
  }

  Future<void> _fetchLocationReviews(String? locationId) async {
    try {
      var query = Supabase.instance.client
          .from('customer_feedbacks')
          .select('id, rating, comment, admin_reply, is_resolved, created_at, location_id, users(full_name, avatar_url)');

      if (locationId != null && locationId.isNotEmpty) {
        query = query.eq('location_id', locationId);
      }

      final res = await query.order('created_at', ascending: false);
      final List<Map<String, dynamic>> realReviews = [];
      for (var row in res) {
        final comment = row['comment']?.toString() ?? '';
        List<String> topics = [];
        String cleanReview = comment;
        if (comment.startsWith('[') && comment.contains(']')) {
          final endIdx = comment.indexOf(']');
          final topicsStr = comment.substring(1, endIdx);
          topics = topicsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          cleanReview = comment.substring(endIdx + 1).trim();
        }

        final userData = row['users'] as Map<String, dynamic>?;
        final name = userData?['full_name']?.toString() ?? 'Pengguna ParkSmart';

        String dateStr = 'Hari ini';
        if (row['created_at'] != null) {
          try {
            final dt = DateTime.parse(row['created_at'].toString()).toLocal();
            final diff = DateTime.now().difference(dt);
            if (diff.inMinutes < 60) {
              dateStr = '${diff.inMinutes} menit yang lalu';
            } else if (diff.inHours < 24) {
              dateStr = '${diff.inHours} jam yang lalu';
            } else if (diff.inDays < 7) {
              dateStr = '${diff.inDays} hari yang lalu';
            } else {
              dateStr = '${(diff.inDays / 7).floor()} minggu yang lalu';
            }
          } catch (_) {}
        }

        realReviews.add({
          'name': name,
          'rating': (row['rating'] as num?)?.toInt() ?? 5,
          'date': dateStr,
          'review': cleanReview.isNotEmpty ? cleanReview : 'Pelayanan parkir sangat baik.',
          'topics': topics.isNotEmpty ? topics : ['Akurasi Sensor ANPR', 'Kemudahan Gate'],
          'adminReply': row['admin_reply']?.toString(),
        });
      }

      if (mounted) {
        setState(() {
          _userReviews = realReviews;
        });
      }
    } catch (e) {
      debugPrint('[ExploreMap] _fetchLocationReviews error: $e');
    }
  }

  /// Memuat info detail tempat parkir (slot aktual, jam buka/tutup, rating) langsung by ID parkiran dari Supabase
  Future<void> _fetchLiveParkingDetails(String? locationId) async {
    if (locationId == null || locationId.isEmpty) return;
    try {
      final locRes = await Supabase.instance.client
          .from('parking_locations')
          .select('id, name, type, operating_hours, total_capacity, status, rating, review_count')
          .eq('id', locationId)
          .maybeSingle();

      final List<dynamic> slotsRes = await Supabase.instance.client
          .from('parking_slots')
          .select('id, status')
          .eq('location_id', locationId);

      if (locRes != null && mounted) {
        final availableCount = slotsRes.where((s) => s['status'] == 'available').length;
        final totalCap = slotsRes.isNotEmpty ? slotsRes.length : ((locRes['total_capacity'] as num?)?.toInt() ?? 0);
        final realSlots = slotsRes.isNotEmpty ? availableCount : totalCap;
        final num reviewCount = (locRes['review_count'] as num?) ?? 0;
        final double rawRating = (locRes['rating'] as num?)?.toDouble() ?? 0.0;
        final double effectiveRating = reviewCount == 0 ? 0.0 : rawRating;
        final String opHours = locRes['operating_hours']?.toString().trim() ?? 'Buka 24 Jam';

        setState(() {
          if (_selectedParking != null && _selectedParking!['id'] == locationId) {
            _selectedParking = {
              ..._selectedParking!,
              'operating_hours': opHours,
              'hours': opHours,
              'slots': realSlots,
              'available_slots': realSlots,
              'total_capacity': totalCap,
              'status': locRes['status'] ?? 'active',
              'rating': effectiveRating,
              'reviews': '$reviewCount',
              'review_count': reviewCount,
            };
          }
        });
      }
    } catch (e) {
      debugPrint('[ExploreMap] _fetchLiveParkingDetails error: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _positionSub?.cancel();
    _magSub?.cancel();
    _accelSub?.cancel();
    _sheetController.dispose();
    _placeDetailsController.dispose();
    super.dispose();
  }

  /// Inisialisasi sensor kompas riil menggunakan Magnetometer & Accelerometer (Tilt Compensated)
  void _initCompassSensor() {
    if (kIsWeb) {
      if (mounted) setState(() => _heading = 0.0);
      return;
    }
    try {
      _accelSub?.cancel();
      _accelSub = accelerometerEventStream().listen((acc) {
        _lastAx = acc.x;
        _lastAy = acc.y;
        _lastAz = acc.z;
      }, onError: (_) {});

      _magSub?.cancel();
      _magSub = magnetometerEventStream().listen((event) {
        double mx = event.x;
        double my = event.y;
        double mz = event.z;

        // Kompensasi kemiringan ponsel menggunakan gravitasi accelerometer
        double normAcc = sqrt(_lastAx * _lastAx + _lastAy * _lastAy + _lastAz * _lastAz);
        double rad;
        if (normAcc > 0.5) {
          double pitch = asin((_lastAy / normAcc).clamp(-1.0, 1.0));
          double roll = asin((-_lastAx / normAcc).clamp(-1.0, 1.0));

          double cosP = cos(pitch);
          double sinP = sin(pitch);
          double cosR = cos(roll);
          double sinR = sin(roll);

          double xH = mx * cosR + mz * sinR;
          double yH = mx * sinP * sinR + my * cosP - mz * sinP * cosR;
          rad = atan2(-xH, yH);
        } else {
          rad = atan2(-mx, my);
        }

        if (mounted) {
          // Circular smoothing (low-pass filter) agar jarum berputar mulus tanpa jitter
          double targetDeg = (rad * 180 / pi + 360) % 360;
          double currentDeg = (_heading * 180 / pi + 360) % 360;
          double diff = targetDeg - currentDeg;
          while (diff < -180) {
            diff += 360;
          }
          while (diff > 180) {
            diff -= 360;
          }
          double smoothedDeg = (currentDeg + diff * 0.22 + 360) % 360;
          setState(() {
            _heading = (smoothedDeg * pi) / 180;
          });
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  /// Membuka dialog kompas detail frameless dengan sensor riil
  void _showCompassDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Kompas Detail',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (context, anim, secondaryAnim) {
        return CompassDetailDialog(
          userPosition: _currentPosition,
        );
      },
    );
  }

  /// Deteksi otomatis posisi GPS pengguna saat membuka peta
  Future<void> _autoDetectGpsLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          ),
        );
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
            _userGpsPosition = LatLng(pos.latitude, pos.longitude);
            _isGpsActive = true;
          });
          _fetchWeather(_currentPosition!);
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleGpsTracking() async {
    if (_isGpsActive && _currentPosition != null) {
      // Pusatkan kembali peta ke posisi pengguna saat ini
      _mapController.move(_currentPosition!, 16.5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peta dipusatkan ke posisi Anda'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      // 1. Cek Service Enabled khusus di Mobile (Android/iOS)
      // Di Web/Chrome, browser menangani ini lewat navigator.geolocation
      if (!kIsWeb) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan GPS perangkat belum aktif. Silakan aktifkan GPS.'),
            ),
          );
          return;
        }
      }

      // 2. Request Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 3. Ambil posisi
      LatLng userPos;
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
            timeLimit: const Duration(seconds: 8),
          ),
        );
        userPos = LatLng(position.latitude, position.longitude);
      } catch (locErr) {
        // Fallback untuk Chrome/Laptop jika akses lokasi diblokir atau hardware GPS laptop tidak tersedia
        userPos = _currentPosition ?? const LatLng(-6.1774, 106.7907);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menggunakan simulasi lokasi (Pastikan izin lokasi diizinkan di Chrome).'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isGpsActive = true;
          _currentPosition = userPos;
          _userGpsPosition = userPos;
        });
        _mapController.move(userPos, 16.5);
        _fetchWeather(userPos);
      }

      // 4. Dengarkan aliran posisi GPS
      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 2,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
            _userGpsPosition = LatLng(pos.latitude, pos.longitude);
            if (pos.heading != 0) {
              _heading = (pos.heading * pi) / 180;
            }
          });
        }
      });

      // 5. Dengarkan sensor Kompas riil
      _initCompassSensor();
    } catch (e) {
      // Fallback aman
      if (mounted) {
        setState(() {
          _isGpsActive = true;
          _currentPosition = _currentPosition ?? const LatLng(-6.1774, 106.7907);
          _fetchWeather(_currentPosition!);
        });
        _mapController.move(_currentPosition!, 16.5);
      }
    }
  }

  Future<void> _fetchWeather(LatLng pos) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${pos.latitude}&longitude=${pos.longitude}&current_weather=true');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];
        if (current != null) {
          final temp = current['temperature'];
          final code = (current['weathercode'] as num?)?.toInt() ?? 0;

          String condition;
          String emoji;

          if (code == 0) {
            condition = 'Cerah';
            emoji = '☀️';
          } else if (code == 1) {
            condition = 'Sebagian Cerah';
            emoji = '🌤️';
          } else if (code == 2) {
            condition = 'Cerah Berawan';
            emoji = '⛅';
          } else if (code == 3) {
            condition = 'Berawan';
            emoji = '☁️';
          } else if (code == 45 || code == 48) {
            condition = 'Berkabut';
            emoji = '🌫️';
          } else if (code >= 51 && code <= 57) {
            condition = 'Gerimis';
            emoji = '🌦️';
          } else if (code >= 61 && code <= 67) {
            condition = 'Hujan';
            emoji = '🌧️';
          } else if (code >= 71 && code <= 77) {
            condition = 'Salju';
            emoji = '❄️';
          } else if (code >= 80 && code <= 82) {
            condition = 'Hujan Lebat';
            emoji = '🌧️';
          } else if (code >= 95) {
            condition = 'Badai Petir';
            emoji = '⛈️';
          } else {
            condition = 'Berawan';
            emoji = '⛅';
          }

          if (mounted) {
            setState(() {
              _weatherTemp = '${temp is num ? temp.round() : temp}°C';
              _weatherCondition = condition;
              _weatherEmoji = emoji;
            });
          }
        }
      }
    } catch (_) {
      if (mounted && _weatherTemp == '--°C') {
        setState(() {
          _weatherTemp = '31°C';
          _weatherCondition = 'Cerah Berawan';
          _weatherEmoji = '⛅';
        });
      }
    }
  }

  void _unselectParking() {
    setState(() {
      _selectedParking = null;
    });
    // Kembalikan level zoom peta ke tampilan normal (zoom 15.5)
    final target = _currentPosition ?? const LatLng(-6.1774, 106.7907);
    _mapController.move(target, 15.5);
  }

  /// Menghitung titik kamera peta yang digeser ke arah selatan (offset ~2 cm ke atas layar),
  /// sehingga pin lokasi parkir berada tepat di tengah area peta terbuka di atas bottom sheet.
  LatLng _getOffsetCenterForParking(LatLng point, {double offsetPixels = 135.0, double zoom = 17.0}) {
    final latRad = point.latitude * pi / 180.0;
    final metersPerPixel = 156543.03392 * cos(latRad) / pow(2, zoom);
    final latDelta = (offsetPixels * metersPerPixel) / 111139.0;
    return LatLng(point.latitude - latDelta, point.longitude);
  }

  /// Widget deretan bintang dinamis: jika rating 0.0, semua bintang berwarna abu-abu (jangan full kuning)
  Widget _buildStarRow(double rating, {double size = 15}) {
    final isDark = ThemeService.instance.isDarkMode;
    final emptyColor = isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB);
    const activeColor = Color(0xFFF4B400);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        IconData icon;
        Color color;

        if (rating >= starIndex) {
          icon = Icons.star_rounded;
          color = activeColor;
        } else if (rating >= starIndex - 0.5) {
          icon = Icons.star_half_rounded;
          color = activeColor;
        } else {
          icon = Icons.star_rounded;
          color = emptyColor;
        }

        return Icon(icon, color: color, size: size);
      }),
    );
  }

  /// Menghitung status buka/tutup dan teks jam operasional dinamis berdasarkan data parkiran dari database
  ({bool isOpen, String statusText, String detailText}) _getOperatingHoursInfo(Map<String, dynamic> loc) {
    final status = (loc['status'] ?? 'active').toString().toLowerCase();
    final opHours = (loc['operating_hours'] ?? loc['hours'] ?? 'Buka 24 Jam').toString().trim();

    // 1. Jika status lokasi bukan active (misal maintenance/tutup)
    if (status == 'maintenance' || status == 'perbaikan') {
      return (isOpen: false, statusText: 'Tutup', detailText: ' • Pemeliharaan Sementara');
    }
    if (status == 'tutup' || status == 'closed') {
      return (isOpen: false, statusText: 'Tutup', detailText: ' • Tutup Sementara');
    }

    // 2. Jika operasional 24 Jam
    if (opHours.toLowerCase().contains('24 jam') || opHours.toLowerCase().contains('24 hours')) {
      return (isOpen: true, statusText: 'Buka', detailText: ' • Buka 24 Jam');
    }

    // 3. Parsing rentang jam (misal "06:00 - 23:00", "08.00 - 22.00", "08:00 - 22:00 WIB")
    final match = RegExp(r'(\d{1,2})[:.](\d{2})\s*-\s*(\d{1,2})[:.](\d{2})').firstMatch(opHours);
    if (match != null) {
      final openH = int.tryParse(match.group(1)!) ?? 0;
      final openM = int.tryParse(match.group(2)!) ?? 0;
      final closeH = int.tryParse(match.group(3)!) ?? 0;
      final closeM = int.tryParse(match.group(4)!) ?? 0;

      final now = DateTime.now();
      final nowMinutes = now.hour * 60 + now.minute;
      final openMinutes = openH * 60 + openM;
      final closeMinutes = closeH * 60 + closeM;

      final formattedClose = '${closeH.toString().padLeft(2, '0')}.${closeM.toString().padLeft(2, '0')}';
      final formattedOpen = '${openH.toString().padLeft(2, '0')}.${openM.toString().padLeft(2, '0')}';

      if (closeMinutes > openMinutes) {
        // Jam operasional normal pada hari yang sama (misal 06:00 - 23:00)
        if (nowMinutes >= openMinutes && nowMinutes < closeMinutes) {
          return (isOpen: true, statusText: 'Buka', detailText: ' • Tutup pukul $formattedClose WIB');
        } else {
          return (isOpen: false, statusText: 'Tutup', detailText: ' • Buka pukul $formattedOpen WIB');
        }
      } else {
        // Jam operasional lintas tengah malam (misal 18:00 - 04:00)
        if (nowMinutes >= openMinutes || nowMinutes < closeMinutes) {
          return (isOpen: true, statusText: 'Buka', detailText: ' • Tutup pukul $formattedClose WIB');
        } else {
          return (isOpen: false, statusText: 'Tutup', detailText: ' • Buka pukul $formattedOpen WIB');
        }
      }
    }

    // 4. Fallback jika format kustom
    return (
      isOpen: status == 'active',
      statusText: status == 'active' ? 'Buka' : 'Tutup',
      detailText: ' • $opHours',
    );
  }

  void _onParkingMarkerTapped(Map<String, dynamic> loc) {
    setState(() {
      _selectedParking = loc;
      _selectedDetailTab = 0; // Otomatis tab Ringkasan
    });
    _fetchLocationReviews(loc['id']?.toString());
    _fetchLiveParkingDetails(loc['id']?.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_placeDetailsController.isAttached) {
        _placeDetailsController.animateTo(
          0.50,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    });
    // Auto zoom dekat ke titik yang diklik (zoom 17.0)
    // Geser kamera ke selatan (offset ~2 cm / 135px) agar pin marker tampil di atas panel bottom sheet
    if (loc['point'] != null) {
      final originalPoint = loc['point'] as LatLng;
      final cameraCenter = _getOffsetCenterForParking(originalPoint, offsetPixels: 135.0, zoom: 17.0);
      _mapController.move(cameraCenter, 17.0);
    }
  }

  void _openVoiceSearchDialog() {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return VoiceSearchBottomSheet(
          onQuerySelected: (query) {
            _performAutoSearch(query);
          },
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _isSearching = false;
      });
      return;
    }

    // Ambil seluruh daftar tempat parkir aktif murni dari database Supabase
    final Map<String, Map<String, dynamic>> uniqueParkings = {};
    for (final loc in [..._parkingLocations, ...ExploreMapBackend.instance.locations]) {
      final name = loc['name']?.toString() ?? '';
      if (name.isNotEmpty && !uniqueParkings.containsKey(name)) {
        uniqueParkings[name] = loc;
      }
    }

    final results = uniqueParkings.values.where((loc) {
      final name = (loc['name'] ?? '').toString().toLowerCase();
      final address = (loc['address'] ?? '').toString().toLowerCase();
      final city = (loc['city'] ?? '').toString().toLowerCase();
      final type = (loc['type'] ?? '').toString().toLowerCase();
      return name.contains(q) || address.contains(q) || city.contains(q) || type.contains(q);
    }).map((loc) {
      return {
        'name': loc['name'] ?? 'Spot Parkir',
        'desc': _getLocationRegionDesc(loc),
        'locData': loc,
        'point': loc['point'] as LatLng?,
      };
    }).toList();

    setState(() {
      _filteredSuggestions = results;
      _isSearching = true;
    });
  }

  void _performAutoSearch(String query, [Map<String, dynamic>? selectedLoc]) {
    final trimmed = query.trim();
    if (trimmed.isEmpty && selectedLoc == null) return;

    final q = trimmed.toLowerCase();
    _searchController.text = selectedLoc != null ? (selectedLoc['name']?.toString() ?? trimmed) : trimmed;
    _searchFocusNode.unfocus();

    // 0. Cek apakah cocok dengan lokasi parkir dari database
    Map<String, dynamic>? matchedParking = selectedLoc;
    if (matchedParking == null) {
      final allParkings = [..._parkingLocations, ...ExploreMapBackend.instance.locations];
      for (final loc in allParkings) {
        final name = (loc['name'] as String? ?? '').toLowerCase();
        final type = (loc['type'] as String? ?? '').toLowerCase();
        final city = (loc['city'] as String? ?? '').toLowerCase();
        final address = (loc['address'] as String? ?? '').toLowerCase();
        if (name == q || name.contains(q) || q.contains(name) || type.contains(q) || city.contains(q) || address.contains(q)) {
          matchedParking = loc;
          break;
        }
      }
    }

    if (matchedParking != null) {
      final pt = matchedParking['point'] as LatLng;
      final name = matchedParking['name'] as String;
      setState(() {
        _searchQuery = name;
        _searchResultPoint = pt;
        _searchResultName = name;
        _selectedParking = matchedParking;
        _filteredSuggestions = [];
        _isSearching = false;
      });
      _onParkingMarkerTapped(matchedParking);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menampilkan lokasi parkir: $name'),
          backgroundColor: const Color(0xFF1A73E8),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    } else {
      // Tidak ditemukan di database lokasi parkir
      setState(() {
        _filteredSuggestions = [];
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lokasi parkir "$trimmed" tidak ditemukan di database.'),
          backgroundColor: const Color(0xFFEA4335),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isLocationEv(Map<String, dynamic> loc) {
    if (loc['isEv'] == true) {
      return true;
    }
    if (loc['is_ev_ready'] == true) {
      return true;
    }
    if (((loc['ev_slots_capacity'] as num?) ?? 0) > 0) {
      return true;
    }
    final facs = loc['facilities'];
    if (facs is List) {
      if (facs.any((f) {
        final s = f.toString().toLowerCase();
        return s.contains('ev') || s.contains('electric') || s.contains('charging');
      })) {
        return true;
      }
    }
    final t = (loc['type']?.toString() ?? '').toLowerCase();
    if (t.contains('ev')) {
      return true;
    }
    return false;
  }

  bool _isLocationMall(Map<String, dynamic> loc) {
    final type = (loc['type']?.toString() ?? '').toLowerCase();
    final name = (loc['name']?.toString() ?? '').toLowerCase();
    return type.contains('mall') || name.contains('mall');
  }

  void _onCategoryTapped(String cat) {
    final isUnselecting = _selectedCategory == cat;
    setState(() {
      _selectedParking = null;
      _selectedCategory = isUnselecting ? '' : cat;
    });

    if (isUnselecting) {
      // Kembali ke zoom normal (15.5) dan posisi semula
      final normalCenter = _currentPosition ?? (_parkingLocations.isNotEmpty ? (_parkingLocations.first['point'] as LatLng) : const LatLng(-7.758611, 110.399));
      _mapController.move(normalCenter, 15.5);
      return;
    }

    // Layar peta mengecil 60% (zoom out ke 12.0) agar jangkauan lihat luas sehingga mengetahui lokasi parkir
    const double wideZoom = 12.0;
    LatLng targetCenter;

    if (cat == 'Terdekat') {
      if (_isGpsActive && _currentPosition != null) {
        targetCenter = _currentPosition!;
      } else if (_parkingLocations.isNotEmpty) {
        targetCenter = _parkingLocations.first['point'] as LatLng;
      } else {
        targetCenter = _currentPosition ?? const LatLng(-7.758611, 110.399);
      }
      _mapController.move(targetCenter, wideZoom);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menampilkan lokasi parkir terdekat di sekitar Anda (Jangkauan Luas)'),
          backgroundColor: Color(0xFF1A73E8),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (cat == 'Mall') {
      final matchingMalls = _parkingLocations.where(_isLocationMall).toList();
      if (matchingMalls.isNotEmpty) {
        if (_currentPosition != null) {
          matchingMalls.sort((a, b) {
            final ptA = a['point'] as LatLng?;
            final ptB = b['point'] as LatLng?;
            if (ptA == null || ptB == null) return 0;
            final distA = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, ptA.latitude, ptA.longitude);
            final distB = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, ptB.latitude, ptB.longitude);
            return distA.compareTo(distB);
          });
        }
        targetCenter = matchingMalls.first['point'] as LatLng;
      } else if (_currentPosition != null && _isGpsActive) {
        targetCenter = _currentPosition!;
      } else if (_parkingLocations.isNotEmpty) {
        targetCenter = _parkingLocations.first['point'] as LatLng;
      } else {
        targetCenter = const LatLng(-7.758611, 110.399);
      }
      _mapController.move(targetCenter, wideZoom);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            matchingMalls.isNotEmpty
                ? 'Menampilkan ${matchingMalls.length} lokasi parkir Mall (Tipe: Mall)'
                : 'Tidak ada lokasi parkir Mall yang ditemukan di database',
          ),
          backgroundColor: const Color(0xFF1A73E8),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (cat == 'Parkir EV') {
      final matchingEvs = _parkingLocations.where(_isLocationEv).toList();
      if (matchingEvs.isNotEmpty) {
        if (_currentPosition != null) {
          matchingEvs.sort((a, b) {
            final ptA = a['point'] as LatLng?;
            final ptB = b['point'] as LatLng?;
            if (ptA == null || ptB == null) return 0;
            final distA = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, ptA.latitude, ptA.longitude);
            final distB = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, ptB.latitude, ptB.longitude);
            return distA.compareTo(distB);
          });
        }
        targetCenter = matchingEvs.first['point'] as LatLng;
      } else if (_currentPosition != null && _isGpsActive) {
        targetCenter = _currentPosition!;
      } else if (_parkingLocations.isNotEmpty) {
        targetCenter = _parkingLocations.first['point'] as LatLng;
      } else {
        targetCenter = const LatLng(-7.758611, 110.399);
      }
      _mapController.move(targetCenter, wideZoom);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            matchingEvs.isNotEmpty
                ? 'Menampilkan ${matchingEvs.length} lokasi parkir dengan stasiun EV Charging'
                : 'Tidak ada lokasi parkir EV yang ditemukan di database',
          ),
          backgroundColor: const Color(0xFF1A73E8),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, ExploreMapBackend.instance, CurrencyService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        const double bottomNavHeight = 64.0;
        final totalBottomHeight = bottomNavHeight + bottomPadding;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : Colors.white,
      body: Stack(
        children: [
          // 1. FULLSCREEN FLUTTER MAP
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(-6.1774, 106.7907),
                initialZoom: 15.5,
                minZoom: 4.0,
                maxZoom: 19.0,
                onTap: (tapPosition, point) {
                  _searchFocusNode.unfocus();
                  if (_isSearching) {
                    setState(() {
                      _isSearching = false;
                      _filteredSuggestions = [];
                    });
                  }
                  // Jika panel detail parkir sedang terbuka lebar, tap map mengecilkannya ke mentok bawah 0.22 (bukan unselect)
                  if (_selectedParking != null && _placeDetailsController.isAttached) {
                    if (_placeDetailsController.size > 0.30) {
                      _placeDetailsController.animateTo(
                        0.22,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _isSatellite
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileBuilder: (!_isSatellite && isDark)
                      ? darkModeTileBuilder
                      : null,
                  userAgentPackageName: 'com.example.smart_parking',
                ),
                MarkerLayer(
                  markers: [
                    // MARKER HASIL AUTO-SEARCH (MISAL: SURABAYA / PARKIR1)
                    if (_searchResultPoint != null)
                      Marker(
                        point: _searchResultPoint!,
                        width: 180,
                        height: 76,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Map<String, dynamic>? locMatch;
                            final allParkings = [..._parkingLocations, ...ExploreMapBackend.instance.locations];
                            for (final loc in allParkings) {
                              final name = (loc['name'] as String? ?? '').toLowerCase();
                              final sName = (_searchResultName ?? _searchQuery).toLowerCase();
                              if (name == sName || name.contains(sName) || sName.contains(name)) {
                                locMatch = loc;
                                break;
                              }
                            }
                            if (locMatch != null) {
                              _onParkingMarkerTapped(locMatch);
                            } else if (_selectedParking != null) {
                              _onParkingMarkerTapped(_selectedParking!);
                            } else if (allParkings.isNotEmpty) {
                              _onParkingMarkerTapped(allParkings.first);
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA4335),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.28),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        _searchResultName ?? _searchQuery,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color: Color(0xFFEA4335),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Titik-titik marker lokasi parkir
                    ..._parkingLocations.map((loc) {
                      final LatLng pt = loc['point'] as LatLng;
                      final String name = loc['name'] as String;
                      final bool isEv = _isLocationEv(loc);
                      final bool isSelected = _selectedParking != null && _selectedParking!['name'] == name;

                      // Filter kategori jika aktif (Mall dan Parkir EV)
                      if (_selectedCategory == 'Mall' && !_isLocationMall(loc)) return null;
                      if (_selectedCategory == 'Parkir EV' && !isEv) return null;

                      // JIKA TITIK INI DIKLIK: Berubah jadi PIN MERAH khas Google Maps!
                      if (isSelected) {
                        return Marker(
                          point: pt,
                          width: 52,
                          height: 64,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => _onParkingMarkerTapped(loc),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFEA4335),
                                      size: 52,
                                      shadows: [
                                        BoxShadow(
                                          color: Color(0x55000000),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 14,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 9,
                                            height: 9,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFB3261E),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 14,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Tampilan normal sebelum titik diklik
                      return Marker(
                        point: pt,
                        width: 140,
                        height: 52,
                        child: GestureDetector(
                          onTap: () => _onParkingMarkerTapped(loc),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isEv ? const Color(0xFF10B981) : const Color(0xFF1A73E8),
                                      ),
                                      child: Icon(
                                        isEv ? Icons.electric_car : Icons.local_parking,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        name.split(' ').first,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F1F1F),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).whereType<Marker>(),

                    // MARKER POSISI PENGGUNA DENGAN CORONG SUDUT PANDANG (DISEBUTKAN & DIPERBESAR SESUAI GAMBAR)
                    if (_isGpsActive && _currentPosition != null)
                      Marker(
                        point: _currentPosition!,
                        width: 320,
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Arah sudut pandang HP: Senter corong besar dengan kontur tegas
                            CustomPaint(
                              size: const Size(320, 320),
                              painter: HeadingConePainter(heading: _heading),
                            ),
                            // Lingkaran aura biru luar (diperbesar)
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1A73E8).withValues(alpha: 0.18),
                                border: Border.all(
                                  color: const Color(0xFF1A73E8).withValues(alpha: 0.38),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            // Cincin putih kokoh (diperbesar)
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            // Titik bulat biru utama (diperbesar)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1A73E8),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 2. TOMBOL SISI KANAN ATAS (Lapisan Map untuk switch standar / satelit)
          Positioned(
            top: MediaQuery.of(context).padding.top + 116,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSatellite = !_isSatellite;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isSatellite
                          ? 'Beralih ke tampilan Peta Satelit'
                          : 'Beralih ke tampilan Peta Standar',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFC2E7FF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.layers_rounded,
                  color: isDark ? Colors.white : const Color(0xFF001D35),
                  size: 22,
                ),
              ),
            ),
          ),

          // 3. TOMBOL SISI BAWAH KANAN (Tombol Kompas & Tombol Putih GPS)
          Positioned(
            right: 16,
            bottom: totalBottomHeight + 68,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TOMBOL KOMPAS KECIL SISI USER (Ukuran 48x48 sama dengan GPS, jarum berputar mengikuti sensor riil)
                GestureDetector(
                  onTap: _showCompassDialog,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? theme.card : Colors.white,
                      border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran dial kompas kecil
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF1F5F9),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Penanda Utara N kecil
                              Positioned(
                                top: 2,
                                child: Text(
                                  'N',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Jarum kompas kecil bergerak dinamis mengikuti sensor riil asli
                        Transform.rotate(
                          angle: -_heading,
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CustomPaint(
                              painter: MiniCompassNeedlePainter(isDark: isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // TOMBOL FOKUSKAN GPS
                GestureDetector(
                  onTap: _toggleGpsTracking,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? theme.card : Colors.white,
                      border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isGpsActive ? Icons.my_location : Icons.location_disabled,
                      color: _isGpsActive ? const Color(0xFF1A73E8) : (isDark ? theme.textMuted : const Color(0xFF5F6368)),
                      size: 24,
                    ),
                  ),
                ),
                // Ruang kosong untuk menggantikan tombol biru navigasi (agar posisi tombol GPS tetap sama persis seperti referensi)
                const SizedBox(height: 56 + 14),
              ],
            ),
          ),

          // 4. TOP FLOATING SEARCH BAR & CATEGORY PILLS
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Floating Search Bar dengan TextField interaktif untuk cari kota di Indonesia
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    height: 50,
                    decoration: BoxDecoration(
                        color: isDark ? theme.card : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                        border: isDark ? Border.all(color: theme.border) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        // Logo Google Maps berwarna dari internet link
                        Image.network(
                          'https://img.icons8.com/color/96/google-maps-new.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.location_on,
                              color: Color(0xFFEA4335),
                              size: 24,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        // Interactive Search TextField
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            onSubmitted: (val) => _performAutoSearch(val),
                            style: GoogleFonts.inter(
                              color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            cursorColor: isDark ? Colors.white : const Color(0xFF1F1F1F),
                            decoration: InputDecoration(
                              hintText: 'Cari tempat parkir...'.tr,
                              hintStyle: GoogleFonts.inter(
                                color: isDark ? theme.textMuted : const Color(0xFF5F6368),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Tombol Clear (X) jika ada teks
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF5F6368), size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                              setState(() {
                                _searchQuery = '';
                                _searchResultPoint = null;
                                _searchResultName = null;
                              });
                            },
                          ),
                        // Mic Icon di sisi paling kanan - memicu Voice Search Dialog
                        IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: isDark ? Colors.white : const Color(0xFF3C4043),
                            size: 24,
                          ),
                          onPressed: _openVoiceSearchDialog,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),

                  // Autocomplete Dropdown Hasil Pencarian Tempat Parkir dari Database
                  if (_isSearching && _filteredSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: const BoxConstraints(maxHeight: 260),
                      decoration: BoxDecoration(
                        color: isDark ? theme.card : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _filteredSuggestions.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1, 
                            indent: 46,
                            color: isDark ? theme.border : const Color(0xFFE5E7EB),
                          ),
                          itemBuilder: (context, index) {
                            final place = _filteredSuggestions[index];
                            final loc = place['locData'] as Map<String, dynamic>?;
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: const Icon(Icons.location_on_outlined, color: Color(0xFF1A73E8), size: 20),
                              title: Text(
                                place['name'] as String,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                                ),
                              ),
                              subtitle: Text(
                                place['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? theme.textMuted : const Color(0xFF5F6368),
                                ),
                              ),
                              onTap: () {
                                _performAutoSearch(place['name'] as String, loc);
                              },
                            );
                          },
                        ),
                      ),
                    ),

                  // Horizontal Category Pills (Terdekat, Mall, Parkir EV - tanpa Game)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildCategoryPill(
                          title: 'Terdekat'.tr,
                          categoryKey: 'Terdekat',
                          icon: Icons.near_me_outlined,
                          isSelected: _selectedCategory == 'Terdekat',
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          title: 'Mall'.tr,
                          categoryKey: 'Mall',
                          icon: Icons.storefront_outlined,
                          isSelected: _selectedCategory == 'Mall',
                        ),
                        const SizedBox(width: 8),
                        _buildCategoryPill(
                          title: 'Parkir EV'.tr,
                          categoryKey: 'Parkir EV',
                          icon: Icons.electric_car_outlined,
                          isSelected: _selectedCategory == 'Parkir EV',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. BOTTOM SHEET DETAIL PARKIR (MUNCUL SETENGAH LAYAR SAAT TITIK DIKLIK)
          if (_selectedParking != null)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: totalBottomHeight,
              child: DraggableScrollableSheet(
                controller: _placeDetailsController,
                initialChildSize: 0.50, // Langsung muncul setengah layar
                minChildSize: 0.22,
                maxChildSize: 1.0,      // Ditarik ke atas menutup sampai searchbar
                snap: true,
                snapSizes: const [0.22, 0.50, 1.0],
                builder: (context, scrollController) {
                  final loc = _selectedParking!;
                  final List<String> photos = (loc['photos'] as List<dynamic>?)?.cast<String>() ?? [
                    'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
                    'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=600&auto=format&fit=crop&q=80',
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? theme.card : Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // AREA HEADER & DRAG HANDLE (Bisa diseret langsung dengan mouse atau jari sampai full 1.0 menutup searchbar)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            if (_placeDetailsController.isAttached) {
                              final screenHeight = MediaQuery.of(context).size.height;
                              final parentHeight = screenHeight - totalBottomHeight;
                              final deltaFraction = (details.primaryDelta ?? 0) / (parentHeight > 0 ? parentHeight : 1);
                              final newSize = (_placeDetailsController.size - deltaFraction).clamp(0.22, 1.0);
                              _placeDetailsController.jumpTo(newSize);
                            }
                          },
                          onVerticalDragEnd: (details) {
                            if (_placeDetailsController.isAttached) {
                              final currentSize = _placeDetailsController.size;
                              final velocity = details.primaryVelocity ?? 0;
                              double targetSize;
                              if (velocity < -200 || currentSize > 0.65) {
                                targetSize = 1.0; // Menutup sampai searchbar
                              } else if (velocity > 200 || currentSize < 0.35) {
                                targetSize = 0.22; // Mentok bawah (nyangkut, tetap ter-select untuk zoom in/out peta)
                              } else {
                                targetSize = 0.50; // Posisi normal setengah layar
                              }
                              _placeDetailsController.animateTo(
                                targetSize,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Drag handle pill dengan kursor grab & tap untuk toggle
                              MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    if (_placeDetailsController.isAttached) {
                                      final current = _placeDetailsController.size;
                                      final targetSize = current <= 0.30 ? 0.50 : (current < 0.75 ? 1.0 : 0.50);
                                      _placeDetailsController.animateTo(
                                        targetSize,
                                        duration: const Duration(milliseconds: 280),
                                        curve: Curves.easeOutCubic,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF475569) : const Color(0xFFC7C7C7),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // BARIS 1 MELAYANG (STICKY HEADER 1): Nama Parkiran di kiri, Tombol Silang (X) SAJA di kanan
                              Container(
                                color: isDark ? theme.card : Colors.white,
                                padding: const EdgeInsets.fromLTRB(20, 0, 12, 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        loc['name'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F3F4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: isDark ? Colors.white : const Color(0xFF5F6368),
                                          size: 20,
                                        ),
                                      ),
                                      onPressed: _unselectParking,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // AREA KONTEN SCROLLABLE DENGAN 2 STICKY HEADERS
                        Expanded(
                          child: CustomScrollView(
                            controller: scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              // Area info yang akan ter-scroll naik dan hilang saat discroll ke atas
                              SliverToBoxAdapter(
                                child: Container(
                                  color: isDark ? theme.card : Colors.white,
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Rating Angka + Bintang + Jumlah Ulasan
                                      Builder(
                                        builder: (context) {
                                          final num reviewCount = num.tryParse(loc['reviews']?.toString() ?? '') ?? (loc['review_count'] as num?) ?? 0;
                                          final double rawRating = (loc['rating'] is num)
                                              ? (loc['rating'] as num).toDouble()
                                              : (double.tryParse(loc['rating']?.toString() ?? '') ?? 0.0);
                                          final double ratingVal = reviewCount == 0 ? 0.0 : rawRating;
                                          final String ratingStr = ratingVal.toStringAsFixed(1);

                                          return Row(
                                            children: [
                                              Text(
                                                '$ratingStr ',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                                                ),
                                              ),
                                              _buildStarRow(ratingVal, size: 15),
                                              const SizedBox(width: 4),
                                              Text(
                                                '($reviewCount)',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: isDark ? theme.textMuted : const Color(0xFF5F6368),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 5),

                                      // Kategori & Biaya & Slot Tersedia Riil (by parking ID)
                                      Builder(
                                        builder: (context) {
                                          final int slots = (loc['slots'] is num)
                                              ? (loc['slots'] as num).toInt()
                                              : (int.tryParse(loc['slots']?.toString() ?? '') ?? 0);
                                          final typeStr = (loc['type'] ?? 'Parkir Resmi').toString();
                                          final priceStr = _formatParkingPrice(loc);

                                          return Text(
                                            '$typeStr • $priceStr • Tersedia $slots slot',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: isDark ? theme.textMuted : const Color(0xFF5F6368),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 5),

                                      // Jam Buka & Tutup Dinamis (by parking ID)
                                      Builder(
                                        builder: (context) {
                                          final opInfo = _getOperatingHoursInfo(loc);
                                          return Row(
                                            children: [
                                              Text(
                                                opInfo.statusText,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: opInfo.isOpen
                                                      ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF137333))
                                                      : (isDark ? const Color(0xFFF87171) : const Color(0xFFD93025)),
                                                ),
                                              ),
                                              Text(
                                                opInfo.detailText,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: isDark ? theme.textMuted : const Color(0xFF5F6368),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),

                                      // Baris Tombol Navigasi & Pesan Slot (1 Line Berbagi Sisi)
                                      Row(
                                        children: [
                                          // 1. Tombol Navigasi (ke ArNavigationScreen)
                                          Expanded(
                                            child: SizedBox(
                                              height: 46,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF1C1D1F),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(23),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.navigation_rounded, size: 18),
                                                label: Text(
                                                  'Navigasi',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => ArNavigationScreen(
                                                        destinationParking: _selectedParking,
                                                        userPosition: _isGpsActive ? _currentPosition : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // 2. Tombol Pesan Slot Parkir
                                          Expanded(
                                            child: SizedBox(
                                              height: 46,
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1A73E8),
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(23),
                                                  ),
                                                ),
                                                icon: const Icon(Icons.local_parking, size: 18),
                                                label: Text(
                                                  'Pesan Slot'.tr,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => ParkingDetailScreen(
                                                        locationId: loc['id']?.toString(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // BARIS 2 MELAYANG (STICKY HEADER 2): Tab Bar (Ringkasan, Ulasan, Tentang)
                              // Saat discroll mentok, tombol ini berhenti melayang di bawah nama parkir!
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _SliverTabBarDelegate(
                                  child: _buildDetailTabBar(),
                                ),
                              ),

                              // KONTEN TAB: Background agak keruh (#F6F8FA)
                              SliverToBoxAdapter(
                                child: Container(
                                  color: isDark ? theme.bg : const Color(0xFFF6F8FA),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: _buildSelectedTabContent(loc, photos),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // 5. DRAGGABLE BOTTOM SHEET ("Suasana lokal" saat tidak ada marker, atau Detail Parkir saat marker diklik)
          if (_selectedParking == null)
          // Bisa diseret dari collapsed (0.12) -> 1/4 layar (0.25) -> Fullscreen (1.0) menutup searchbar
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: totalBottomHeight,
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.12,
              minChildSize: 0.12,
              maxChildSize: 1.0,
              snap: true,
              snapSizes: const [0.12, 0.25, 1.0],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? theme.card : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Garis tanda seret (Drag handle) dengan interaksi geser & tap
                        MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              if (_sheetController.isAttached) {
                                final current = _sheetController.size;
                                final target = current < 0.20 ? 0.25 : (current < 0.70 ? 1.0 : 0.12);
                                _sheetController.animateTo(
                                  target,
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 10, bottom: 8),
                              alignment: Alignment.center,
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF475569) : const Color(0xFFC7C7C7),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Header Row: Suasana lokal + Kotak Cuaca Dummy
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Suasana lokal'.tr,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                                ),
                              ),
                              // Kotak Cuaca Real-Time (Open-Meteo API)
                              GestureDetector(
                                onTap: () {
                                  final pos = _currentPosition ?? const LatLng(-6.1774, 106.7907);
                                  _fetchWeather(pos);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Memperbarui cuaca lokasi...'),
                                      duration: Duration(milliseconds: 900),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isDark ? theme.surfaceField : const Color(0xFFF1F3F4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: isDark ? Border.all(color: theme.border) : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(_weatherEmoji, style: const TextStyle(fontSize: 14)),
                                          const SizedBox(width: 4),
                                          Text(
                                            _weatherTemp,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _weatherCondition.tr,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                           color: isDark ? theme.textMuted : const Color(0xFF444746),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Rekomendasi Area Parkir Terdekat Berbasis Gambar Full + Gradien Putih
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rekomendasi Parkir Terdekat'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                                ),
                              ),
                              _SpinningLoadButton(
                                onRefresh: () async {
                                  await Future.delayed(const Duration(milliseconds: 900));
                                  if (mounted) {
                                    setState(() {
                                      // Simulasi pembaruan ketersediaan slot terkini
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          child: Builder(
                            builder: (context) {
                              var displayedLocs = _parkingLocations.where((loc) {
                                if (_selectedCategory == 'Mall' && !_isLocationMall(loc)) return false;
                                if (_selectedCategory == 'Parkir EV' && !_isLocationEv(loc)) return false;
                                return true;
                              }).toList();

                              final LatLng? refGps = _userGpsPosition ?? _currentPosition;

                              // Selalu urutkan dari jarak terdekat dari lokasi GPS pengguna
                              if (refGps != null) {
                                displayedLocs.sort((a, b) {
                                  final ptA = a['point'] as LatLng?;
                                  final ptB = b['point'] as LatLng?;
                                  if (ptA == null && ptB == null) return 0;
                                  if (ptA == null) return 1;
                                  if (ptB == null) return -1;
                                  final distA = Geolocator.distanceBetween(
                                    refGps.latitude,
                                    refGps.longitude,
                                    ptA.latitude,
                                    ptA.longitude,
                                  );
                                  final distB = Geolocator.distanceBetween(
                                    refGps.latitude,
                                    refGps.longitude,
                                    ptB.latitude,
                                    ptB.longitude,
                                  );
                                  return distA.compareTo(distB);
                                });
                              }

                              return Column(
                                children: displayedLocs.map((loc) {
                                  final List<String> photos = (loc['photos'] as List<dynamic>?)?.cast<String>() ?? [
                                    'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=600&auto=format&fit=crop&q=80',
                                  ];
                                  final String img = photos.first;
                                  final String name = loc['name'] as String;
                                  final LatLng? pt = loc['point'] as LatLng?;
                                  String dist = (loc['distance'] as String?) ?? '1.2 km';
                                  if (refGps != null && pt != null) {
                                    final dMeters = Geolocator.distanceBetween(
                                      refGps.latitude,
                                      refGps.longitude,
                                      pt.latitude,
                                      pt.longitude,
                                    );
                                    if (dMeters < 1000) {
                                      dist = '${dMeters.round()} m';
                                    } else {
                                      dist = '${(dMeters / 1000).toStringAsFixed(1)} km';
                                    }
                                  }
                                  final int slots = (loc['slots'] as int?) ?? 20;
                                  final String subtitleText = '$dist • ${'$slots slot tersedia'.tr}';
                                  final String price = _formatParkingPrice(loc);
                                  final bool isEv = _isLocationEv(loc);
                                  final String rating = (loc['rating'] ?? 4.7).toString();

                                  return _buildParkingRecommendationCard(
                                    title: name,
                                    subtitle: subtitleText,
                                    price: price,
                                    imageUrl: img,
                                    rating: rating,
                                    isEv: isEv,
                                    onExplore: () {
                                      _onParkingMarkerTapped(loc);
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 800),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 6. BOTTOM NAVIGATION BAR (Jelajahi, Favorite, Home)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: totalBottomHeight,
              padding: EdgeInsets.only(bottom: bottomPadding),
              decoration: BoxDecoration(
                color: isDark ? theme.bg : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? theme.border : const Color(0xFFE5E5E5), width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  // Tab 1: Jelajahi (Active style dengan pill background cyan)
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFC2E7FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: isDark ? Colors.white : const Color(0xFF001D35),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jelajahi'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF001D35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab 2: Favorite (Menggantikan "Anda", bookmark dengan tag merah)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoriteScreen()),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.bookmark_outline,
                                color: isDark ? theme.textMuted : const Color(0xFF444746),
                                size: 24,
                              ),
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  width: 6.5,
                                  height: 6.5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFB3261E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Favorite'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444746),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tab 3: Home (Menggantikan "Kontribusi", mengarah ke HomeScreen)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_outlined,
                            color: isDark ? theme.textMuted : const Color(0xFF444746),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Home'.tr,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF444746),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  // Builder untuk Tab Bar berbaris ke kanan (Ringkasan, Ulasan, Tentang)
  Widget _buildDetailTabBar() {
    final isDark = ThemeService.instance.isDarkMode;
    final cardBg = isDark ? ThemeService.instance.card : Colors.white;
    final borderColor = isDark ? ThemeService.instance.border : const Color(0xFFE5E5E5);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          _buildDetailTabItem(index: 0, title: 'Ringkasan'.tr),
          _buildDetailTabItem(index: 1, title: 'Ulasan'.tr),
          _buildDetailTabItem(index: 2, title: 'Tentang'.tr),
        ],
      ),
    );
  }

  Widget _buildDetailTabItem({required int index, required String title}) {
    final isDark = ThemeService.instance.isDarkMode;
    final isSelected = _selectedDetailTab == index;
    final darkTeal = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E);
    final unselectedColor = isDark ? ThemeService.instance.textMuted : const Color(0xFF5F6368);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDetailTab = index;
          });
          if (index == 1 && _selectedParking != null) {
            _fetchLocationReviews(_selectedParking!['id']?.toString());
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? darkTeal : unselectedColor,
                  ),
                ),
              ),
            ),
            Container(
              height: 3,
              width: 72,
              decoration: BoxDecoration(
                color: isSelected ? darkTeal : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(Map<String, dynamic> loc, List<String> photos) {
    if (_selectedDetailTab == 0) {
      // TAB 1: RINGKASAN
      return _buildTabRingkasan(loc, photos);
    } else if (_selectedDetailTab == 1) {
      // TAB 2: ULASAN
      return _buildTabUlasan(loc);
    } else {
      // TAB 3: TENTANG (Deskripsi parkiran + Fasilitas & Layanan)
      return _buildTabTentang(loc);
    }
  }

  // TAB RINGKASAN: Galeri Foto Admin & Ringkasan Spesifikasi
  Widget _buildTabRingkasan(Map<String, dynamic> loc, List<String> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Galeri Foto Area Parkir'.tr,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                    color: ThemeService.instance.isDarkMode ? Colors.white : const Color(0xFF1F1F1F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Admin Managed',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A73E8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Bingkai Foto Admin
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: photos.length + 1,
            itemBuilder: (context, photoIdx) {
              if (photoIdx == photos.length) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDADCE0), width: 1.5),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mode Admin: Unggah foto area parkir baru.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF0F766E), size: 32),
                        const SizedBox(height: 6),
                        Text(
                          '+ Tambah Foto'.tr,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
                        ),
                        Text('oleh Admin'.tr, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF5F6368))),
                      ],
                    ),
                  ),
                );
              }

              final photoUrl = photos[photoIdx];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE8F0FE),
                          child: const Icon(Icons.image, color: Color(0xFF1A73E8), size: 36),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Foto ${photoIdx + 1}',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Card Rincian Spesifikasi Parkir
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeService.instance.isDarkMode ? ThemeService.instance.card : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: ThemeService.instance.isDarkMode ? Border.all(color: ThemeService.instance.border) : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rincian Parkir'.tr, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ThemeService.instance.isDarkMode ? Colors.white : const Color(0xFF1F1F1F))),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.payments_outlined, 'Tarif Resmi'.tr, _formatParkingPrice(loc)),
                const Divider(height: 18),
                _buildInfoRow(Icons.event_seat_outlined, 'Kapasitas'.tr, '${loc['slots']} ${'Slot Tersedia'.tr}'),
                const Divider(height: 18),
                Builder(
                  builder: (_) {
                    final opInfo = _getOperatingHoursInfo(loc);
                    return _buildInfoRow(Icons.access_time, 'Operasional'.tr, '${opInfo.statusText}${opInfo.detailText}'.tr);
                  },
                ),
                const Divider(height: 18),
                _buildInfoRow(Icons.qr_code, 'Metode Masuk'.tr, 'Tiket / Palang Otomatis'.tr),
              ],
            ),
          ),
        ),
        const SizedBox(height: 600),
      ],
    );
  }

  // Modal untuk menulis ulasan baru dengan Topik Masukan hitam putih
  void _showAddReviewDialog(BuildContext context, Map<String, dynamic> loc) {
    int rating = 5;
    final Set<String> selectedTopics = {'Akurasi Sensor ANPR'};
    final TextEditingController textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final theme = ThemeService.instance;
            final isDark = theme.isDarkMode;
            final cardBg = isDark ? theme.card : Colors.white;
            final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;

            return Container(
              margin: EdgeInsets.only(bottom: bottomInset),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: isDark ? Border(top: BorderSide(color: theme.border)) : null,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFFC7C7C7),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tulis Ulasan Parkir',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: isDark ? theme.textMuted : const Color(0xFF5F6368)),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bagikan pengalaman parkir Anda untuk membantu pengguna lain.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: isDark ? theme.textMuted : const Color(0xFF5F6368),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rating Bintang
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          final isSelected = star <= rating;
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              size: 34,
                              color: isSelected ? const Color(0xFFF4B400) : (isDark ? const Color(0xFF334155) : const Color(0xFFE0E0E0)),
                            ),
                            onPressed: () {
                              setModalState(() {
                                rating = star;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Topik Masukan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Topik Masukan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1C1C18),
                          ),
                        ),
                        Text(
                          'Pilih satu atau lebih',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? theme.textMuted : const Color(0xFF76777B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _feedbackTopics.map((topic) {
                        final isSel = selectedTopics.contains(topic);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSel) {
                                selectedTopics.remove(topic);
                              } else {
                                selectedTopics.add(topic);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF020304))
                                  : (isDark ? theme.card : Colors.white),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSel
                                    ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF020304))
                                    : (isDark ? theme.border : const Color(0xFFE0E0E0)),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              topic,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSel
                                    ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                                    : (isDark ? Colors.white : const Color(0xFF1C1C18)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Input Text
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan deskripsi pengalaman parkir Anda...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: isDark ? theme.textMuted : const Color(0xFF9AA0A6)),
                        filled: true,
                        fillColor: isDark ? theme.surfaceField : Colors.white,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? theme.border : const Color(0xFFDADCE0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? theme.border : const Color(0xFFDADCE0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF020304),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF020304),
                          foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final text = textController.text.trim();
                          final messenger = ScaffoldMessenger.of(context);
                          if (text.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Silakan masukkan deskripsi ulasan terlebih dahulu.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          await FeedbackBackend.instance.submitFeedback(
                            rating: rating,
                            comment: text,
                            locationId: loc['id']?.toString(),
                            selectedTopics: selectedTopics.toList(),
                          );
                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                          }
                          if (mounted) {
                            _fetchLocationReviews(loc['id']?.toString());
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Ulasan Anda berhasil ditambahkan!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Kirim Ulasan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // TAB ULASAN: Rating Skor, Filter Topik Masukan, dan Daftar Ulasan Nyata
  Widget _buildTabUlasan(Map<String, dynamic> loc) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
    final cardBg = isDark ? theme.card : Colors.white;

    final filteredReviews = _selectedReviewFilterTopic == 'Semua'
        ? _userReviews
        : _userReviews.where((r) => ((r['topics'] as List<dynamic>?) ?? []).contains(_selectedReviewFilterTopic)).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Ringkasan Rating & Skor
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: theme.border) : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                // Skor Besar
                Builder(
                  builder: (_) {
                    final num reviewCount = num.tryParse(loc['reviews']?.toString() ?? '') ?? (loc['review_count'] as num?) ?? 0;
                    final double rawRating = (loc['rating'] is num)
                        ? (loc['rating'] as num).toDouble()
                        : (double.tryParse(loc['rating']?.toString() ?? '') ?? 0.0);
                    final double ratingVal = reviewCount == 0 ? 0.0 : rawRating;
                    final String ratingStr = ratingVal.toStringAsFixed(1);

                    return Column(
                      children: [
                        Text(
                          ratingStr,
                          style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1F1F1F)),
                        ),
                        _buildStarRow(ratingVal, size: 16),
                        const SizedBox(height: 4),
                        Text('$reviewCount ${'ulasan'.tr}', style: GoogleFonts.inter(fontSize: 12, color: isDark ? theme.textMuted : const Color(0xFF5F6368))),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 20),
                // Progress Bar Bintang 5 s/d 1
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final totalRev = _userReviews.length;
                      final count5 = _userReviews.where((r) => r['rating'] == 5).length;
                      final count4 = _userReviews.where((r) => r['rating'] == 4).length;
                      final count3 = _userReviews.where((r) => r['rating'] == 3).length;
                      final count2 = _userReviews.where((r) => r['rating'] == 2).length;
                      final count1 = _userReviews.where((r) => r['rating'] == 1).length;

                      return Column(
                        children: [
                          _buildRatingBar('5', totalRev > 0 ? count5 / totalRev : 0.0),
                          _buildRatingBar('4', totalRev > 0 ? count4 / totalRev : 0.0),
                          _buildRatingBar('3', totalRev > 0 ? count3 / totalRev : 0.0),
                          _buildRatingBar('2', totalRev > 0 ? count2 / totalRev : 0.0),
                          _buildRatingBar('1', totalRev > 0 ? count1 / totalRev : 0.0),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Header Ulasan Pengunjung + Tombol Tulis Ulasan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan Pengunjung'.tr,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showAddReviewDialog(context, loc),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF020304),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rate_review_outlined, color: isDark ? const Color(0xFF0F172A) : Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '+ Tulis Ulasan'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // FILTER BAR TOPIK MASUKAN
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Semua',
                ..._feedbackTopics,
              ].map((topic) {
                final isSelected = _selectedReviewFilterTopic == topic;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedReviewFilterTopic = topic;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF020304))
                            : (isDark ? theme.card : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF020304))
                              : (isDark ? theme.border : const Color(0xFFE5E5E5)),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        topic.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                              : (isDark ? Colors.white : const Color(0xFF1C1C18)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Daftar Kartu Ulasan Nyata
          if (filteredReviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: theme.border) : null,
              ),
              child: Center(
                child: Text(
                  'Belum ada ulasan dengan topik ini.',
                  style: GoogleFonts.inter(fontSize: 13, color: isDark ? theme.textMuted : const Color(0xFF70757A)),
                ),
              ),
            )
          else
            ...filteredReviews.map((r) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReviewCard(
                  name: r['name'] as String,
                  rating: r['rating'] as int,
                  date: r['date'] as String,
                  review: r['review'] as String,
                  topics: ((r['topics'] as List<dynamic>?) ?? []).cast<String>(),
                  adminReply: r['adminReply'] as String?,
                ),
              );
            }),

          const SizedBox(height: 600),
        ],
      ),
    );
  }

  // TAB TENTANG: Deskripsi Parkiran + Fasilitas & Layanan
  Widget _buildTabTentang(Map<String, dynamic> loc) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
    final cardBg = isDark ? theme.card : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Deskripsi Parkiran
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: theme.border) : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tentang Parkiran'.tr, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1F1F1F))),
                const SizedBox(height: 8),
                Text(
                  LanguageService.instance.currentLanguage == 'en'
                      ? '${loc['name']} is a modern smart parking facility directly integrated with mobile navigation. Featuring spacious areas with 24-hour security protection, automated barrier access, and eco-friendly supporting facilities for all motorists.'
                      : '${loc['name']} adalah fasilitas parkir pintar modern yang terintegrasi langsung dengan sistem navigasi mobile. Memiliki area luas dengan proteksi keamanan 24 jam, kemudahan akses keluar masuk otomatis, dan fasilitas penunjang ramah lingkungan untuk seluruh pengendara.',
                  style: GoogleFonts.inter(fontSize: 13.5, height: 1.5, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF444746)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card Fasilitas & Layanan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: theme.border) : null,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fasilitas & Layanan'.tr, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF1F1F1F))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFacilityBadge(Icons.security, 'CCTV 24 Jam'.tr),
                    _buildFacilityBadge(Icons.electric_car, 'Stasiun EV'.tr),
                    _buildFacilityBadge(Icons.roofing, 'Atap Tertutup'.tr),
                    _buildFacilityBadge(Icons.sensor_door, 'Palang Otomatis'.tr),
                    _buildFacilityBadge(Icons.qr_code_2, 'Cashless / QRIS'.tr),
                    _buildFacilityBadge(Icons.shield, 'Security 24 Jam'.tr),
                    _buildFacilityBadge(Icons.lightbulb_outline, 'Penerangan LED'.tr),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 600),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDark = ThemeService.instance.isDarkMode;
    final iconCol = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E);
    final labelCol = isDark ? ThemeService.instance.textMuted : const Color(0xFF5F6368);
    final valCol = isDark ? Colors.white : const Color(0xFF1F1F1F);

    return Row(
      children:
        [
          Icon(icon, size: 18, color: iconCol),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: labelCol)),
          const Spacer(),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: valCol)),
        ],
    );
  }

  Widget _buildRatingBar(String star, double ratio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(star, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF5F6368))),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF4B400)),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRecommendationCard({
    required String title,
    required String subtitle,
    required String price,
    required String imageUrl,
    String? rating = '4.8',
    bool isEv = false,
    VoidCallback? onExplore,
  }) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
    final cardBg = isDark ? theme.card : Colors.white;

    return GestureDetector(
      onTap: onExplore,
      child: Container(
        height: 360,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? theme.border : Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. FULL BACKGROUND IMAGE
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
                    child: Center(
                      child: Icon(Icons.local_parking, size: 52, color: isDark ? Colors.white54 : const Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),

              // 2. BADGE KATEGORI DI POJOK KANAN ATAS
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: isEv ? const Color(0xFF0F766E).withValues(alpha: 0.94) : Colors.black.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isEv ? Icons.electric_car : Icons.local_parking, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        isEv ? 'EV' : 'Mobil & Motor',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. GRADIEN LUNTUR PUDAR
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        cardBg,
                        cardBg.withValues(alpha: 0.98),
                        cardBg.withValues(alpha: 0.75),
                        cardBg.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.16, 0.26, 0.34, 0.40],
                    ),
                  ),
                ),
              ),

              // 4. KONTEN INFORMASI & TOMBOL EXPLORE
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Baris Nama Parkiran & Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFF4B400), size: 15),
                                const SizedBox(width: 2),
                                Text(
                                  rating,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Keterangan Jarak & Slot
                      Row(
                        children: [
                          Icon(Icons.near_me_outlined, size: 13, color: isDark ? theme.textMuted : const Color(0xFF5F6368)),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? theme.textMuted : const Color(0xFF5F6368),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Baris Tarif Parkir & Tombol Explore
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Keterangan Harga
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TARIF PARKIR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? theme.textMuted : const Color(0xFF76777B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                price,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                                ),
                              ),
                            ],
                          ),
                          // Tombol Explore
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF1C1D1F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.explore_rounded, size: 16),
                            label: Text(
                              'Explore',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: onExplore,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String date,
    required String review,
    List<String> topics = const [],
    String? adminReply,
  }) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? theme.card : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: theme.border) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? const Color(0xFF2DD4BF).withValues(alpha: 0.20) : const Color(0xFF0F766E).withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0] : 'U',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1F1F1F))),
                  Text(date, style: GoogleFonts.inter(fontSize: 11, color: isDark ? theme.textMuted : const Color(0xFF70757A))),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(rating, (_) => const Icon(Icons.star, color: Color(0xFFF4B400), size: 14)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review,
            style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF3C4043)),
          ),

          // BAGIAN TOPIK MASUKAN
          if (topics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: isDark ? theme.border : const Color(0xFFF1F3F4), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Topik Masukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                        ),
                      ),
                      Text(
                        ' dipilih',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: isDark ? theme.textMuted : const Color(0xFF76777B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: topics.map((topic) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFF020304),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C1D1F).withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              topic,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          // Tanggapan Admin CS jika sudah dijawab (jika belum, TIDAK diberi keterangan 'belum dibalas')
          if (adminReply != null && adminReply.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF16A34A),
                    width: 3.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tanggapan Resmi Admin CS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    adminReply.trim(),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFacilityBadge(IconData icon, String text) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1A73E8)),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF3C4043),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required String title,
    required String categoryKey,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = ThemeService.instance.isDarkMode;
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF1D4ED8) : const Color(0xFFE8F0FE))
        : (isDark ? const Color(0xFF1E232B) : Colors.white);
    final borderColor = isSelected
        ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1A73E8))
        : (isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB));
    final fgColor = isSelected
        ? (isDark ? Colors.white : const Color(0xFF1A73E8))
        : (isDark ? Colors.white : const Color(0xFF1F2937));

    return GestureDetector(
      onTap: () => _onCategoryTapped(categoryKey),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fgColor, size: 19),
            const SizedBox(width: 7),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter untuk arah sudut pandang HP (Senter Tipis Bentuk Corong / Flashlight Cone)
class HeadingConePainter extends CustomPainter {
  final double heading; // Compass orientation in radians

  HeadingConePainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Rotate towards compass heading (offset so 0 is pointing upward)
    canvas.rotate(heading - (pi / 2));

    // Ukuran diperbesar sesuai gambar referensi user
    const double radius = 145.0; // Panjang corong diperbesar ~145px
    const double sweep = 65.0 * pi / 180.0; // Sudut bukaan corong ~65 derajat
    const double halfSweep = sweep / 2;

    // Gradien corong senter pandang Google Maps (terang di dekat titik, memudar ke ujung)
    final beamPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        radius,
        [
          const Color(0x994285F4),
          const Color(0x664285F4),
          const Color(0x334285F4),
          const Color(0x084285F4),
          Colors.transparent,
        ],
        [0.0, 0.35, 0.70, 0.92, 1.0],
      );

    final path = Path();
    path.moveTo(0, 0);
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      -halfSweep,
      sweep,
      false,
    );
    path.close();

    // Gambar isi corong senter
    canvas.drawPath(path, beamPaint);

    // Gambar garis kontur tepi corong tegas persis seperti gambar coretan orange user
    final borderPaint = Paint()
      ..color = const Color(0x994285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HeadingConePainter oldDelegate) =>
      oldDelegate.heading != heading;
}


/// Widget Modal Pencarian Suara Google Assistant / Google Maps Style
class VoiceSearchBottomSheet extends StatefulWidget {
  final Function(String query) onQuerySelected;

  const VoiceSearchBottomSheet({super.key, required this.onQuerySelected});

  @override
  State<VoiceSearchBottomSheet> createState() => _VoiceSearchBottomSheetState();
}

class _VoiceSearchBottomSheetState extends State<VoiceSearchBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String _statusText = 'Mendengarkan...';
  String _recognizedText = '';
  bool _isProcessing = false;

  final stt.SpeechToText _speechToText = stt.SpeechToText();

  final List<String> _quickSuggestions = [
    'Surabaya',
    'Grand Indonesia',
    'Bandung',
    'Malang',
    'Semarang',
    'SPBU Terdekat',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _startListening();
  }

  Future<void> _startListening() async {
    try {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') && mounted && !_isProcessing && _recognizedText.trim().isNotEmpty) {
            _finishAndSearch(_recognizedText);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _statusText = 'Gagal mendengar, coba lagi.';
            });
          }
        },
      );

      if (available) {
        _speechToText.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _recognizedText = result.recognizedWords;
                _statusText = 'Terdengar: "$_recognizedText"';
              });
              if (result.finalResult) {
                _finishAndSearch(_recognizedText);
              }
            }
          },
          listenOptions: stt.SpeechListenOptions(listenMode: stt.ListenMode.confirmation),
        );
      } else {
        if (mounted) {
          setState(() {
            _statusText = 'Izin mikrofon ditolak / tidak tersedia.';
          });
        }
      }
    } catch (_) {}
  }

  void _finishAndSearch(String text) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _speechToText.stop();
        Navigator.pop(context);
        widget.onQuerySelected(text);
      }
    });
  }

  void _selectSuggestion(String suggestion) {
    if (_isProcessing) return;
    setState(() {
      _recognizedText = suggestion;
      _statusText = 'Dipilih: "$suggestion"';
      _isProcessing = true;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _speechToText.stop();
        Navigator.pop(context);
        widget.onQuerySelected(suggestion);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    'https://img.icons8.com/color/96/google-maps-new.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.mic,
                      color: Color(0xFF1A73E8),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pencarian Suara',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Animated Pulsing Mic with Sound Waves
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple wave
                  Container(
                    width: 96 * _scaleAnimation.value,
                    height: 96 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A73E8).withValues(alpha: 0.12),
                    ),
                  ),
                  // Middle ripple wave
                  Container(
                    width: 80 * _scaleAnimation.value,
                    height: 80 * _scaleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A73E8).withValues(alpha: 0.22),
                    ),
                  ),
                  // Inner solid button
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF1A73E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x401A73E8),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Status & Instruction Text
          Text(
            _statusText,
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Katakan lokasi tujuan Anda, misalnya "Surabaya"',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF5F6368),
            ),
          ),
          const SizedBox(height: 20),

          // Suggestion Chips (Bisa diklik langsung untuk pengujian instan)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Atau pilih contoh suara:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF70757A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSuggestions.map((suggestion) {
              return ActionChip(
                backgroundColor: const Color(0xFFF1F3F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
                ),
                avatar: const Icon(
                  Icons.volume_up_outlined,
                  size: 16,
                  color: Color(0xFF1A73E8),
                ),
                label: Text(
                  suggestion,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
                onPressed: () => _selectSuggestion(suggestion),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


/// Sliver Header Delegate untuk Tab Bar yang melayang (Sticky Header baris 2)
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) => true;
}


/// Tombol refresh / load dengan ikon yang berputar halus saat diklik
class _SpinningLoadButton extends StatefulWidget {
  final Future<void> Function()? onRefresh;
  const _SpinningLoadButton({this.onRefresh});

  @override
  State<_SpinningLoadButton> createState() => _SpinningLoadButtonState();
}

class _SpinningLoadButtonState extends State<_SpinningLoadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isRotating) return;
    setState(() => _isRotating = true);
    _rotationController.repeat();

    try {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      } else {
        await Future.delayed(const Duration(milliseconds: 900));
      }
    } finally {
      if (mounted) {
        _rotationController.stop();
        _rotationController.reset();
        setState(() => _isRotating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _handleTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: RotationTransition(
            turns: _rotationController,
            child: const Icon(
              Icons.refresh_rounded,
              size: 22,
              color: Color(0xFF5F6368),
            ),
          ),
        ),
      ),
    );
  }
}
