import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk ArNavigationScreen
/// Menangani perhitungan rute OSRM, sinkronisasi lokasi parkir tujuan dari `public.parking_locations`,
/// dan penyeimbang request rute agar tidak membebani server OSRM/Supabase.
class ArNavigationBackend extends ChangeNotifier {
  ArNavigationBackend._();
  static final ArNavigationBackend instance = ArNavigationBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoadingRoute = false;
  bool get isLoadingRoute => _isLoadingRoute;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  double _totalDistanceMeters = 0.0;
  double get totalDistanceMeters => _totalDistanceMeters;

  int _totalDurationSeconds = 0;
  int get totalDurationSeconds => _totalDurationSeconds;

  List<Map<String, dynamic>> _steps = [];
  List<Map<String, dynamic>> get steps => _steps;

  /// Mengambil detail lokasi tujuan dari Supabase `parking_locations` jika diperlukan
  Future<Map<String, dynamic>?> fetchDestinationDetails(String locationId) async {
    try {
      return await DatabaseCacheBalancerService.instance.getBalanced<Map<String, dynamic>?>(
        queryKey: 'dest_loc_$locationId',
        ttl: const Duration(minutes: 10),
        queryFn: () async {
          return await _client
              .from('parking_locations')
              .select('id, name, address, latitude, longitude, hourly_rate, available_slots')
              .eq('id', locationId)
              .maybeSingle();
        },
      );
    } catch (e) {
      debugPrint('[ArNavigationBackend] Error fetch dest details: $e');
      return null;
    }
  }

  /// Menghitung rute navigasi OSRM dengan cache balancer
  Future<bool> calculateRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    _isLoadingRoute = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cacheKey = 'route_${start.latitude.toStringAsFixed(3)}_${start.longitude.toStringAsFixed(3)}_${end.latitude.toStringAsFixed(3)}_${end.longitude.toStringAsFixed(3)}';

      final routeData = await DatabaseCacheBalancerService.instance.getBalanced<Map<String, dynamic>?>(
        queryKey: cacheKey,
        ttl: const Duration(minutes: 15),
        queryFn: () async {
          final url = 'https://router.project-osrm.org/route/v1/driving/'
              '${start.longitude},${start.latitude};'
              '${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true';

          final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
          if (res.statusCode == 200) {
            return jsonDecode(res.body) as Map<String, dynamic>;
          }
          return null;
        },
      );

      if (routeData != null && routeData['routes'] != null && (routeData['routes'] as List).isNotEmpty) {
        final route = routeData['routes'][0];
        _totalDistanceMeters = (route['distance'] as num?)?.toDouble() ?? 1200.0;
        _totalDurationSeconds = (route['duration'] as num?)?.toInt() ?? 240;

        final coordinates = route['geometry']['coordinates'] as List;
        _routePoints = coordinates.map<LatLng>((coord) => LatLng(coord[1] as double, coord[0] as double)).toList();

        final legs = route['legs'] as List?;
        if (legs != null && legs.isNotEmpty) {
          final rawSteps = legs[0]['steps'] as List?;
          if (rawSteps != null) {
            _steps = rawSteps.map<Map<String, dynamic>>((s) {
              return {
                'instruction': s['maneuver']?['instruction'] ?? s['name'] ?? 'Lanjut lurus',
                'distance': (s['distance'] as num?)?.toDouble() ?? 0.0,
                'modifier': s['maneuver']?['modifier'] ?? 'straight',
                'type': s['maneuver']?['type'] ?? 'continue',
              };
            }).toList();
          }
        }

        notifyListeners();
        return true;
      } else {
        // Fallback straight line
        _routePoints = [start, end];
        _totalDistanceMeters = 1000.0;
        _totalDurationSeconds = 180;
        _steps = [
          {'instruction': 'Menuju lokasi tujuan parkir', 'distance': 1000.0, 'modifier': 'straight', 'type': 'straight'}
        ];
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[ArNavigationBackend] OSRM Route error: $e');
      _errorMessage = e.toString();
      _routePoints = [start, end];
      return false;
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }
}
