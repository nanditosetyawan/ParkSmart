import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk PricingScreen (admin_pricing_screen.dart)
/// Mengelola konfigurasi tarif parkir mobil, motor, EV, grace period, dan pinalti overstay
/// Terkoneksi ke `public.parking_locations` dan `public.system_settings` di Supabase
class AdminPricingBackend extends ChangeNotifier {
  AdminPricingBackend._();
  static final AdminPricingBackend instance = AdminPricingBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Map<String, Map<String, dynamic>> _locationPricings = {
    'Central Park Mall': {
      'carFirst': 5000,
      'carNext': 4000,
      'carMax': 50000,
      'motorFirst': 2000,
      'motorNext': 1000,
      'motorMax': 20000,
      'evKwh': 2500,
      'grace': 15,
      'penalty': 10000,
      'memberDiscount': true,
      'walletCashback': true,
    },
    'Grand Indonesia': {
      'carFirst': 6000,
      'carNext': 5000,
      'carMax': 60000,
      'motorFirst': 3000,
      'motorNext': 2000,
      'motorMax': 25000,
      'evKwh': 3000,
      'grace': 15,
      'penalty': 15000,
      'memberDiscount': true,
      'walletCashback': true,
    },
    'Malioboro Mall': {
      'carFirst': 3000,
      'carNext': 2000,
      'carMax': 30000,
      'motorFirst': 2000,
      'motorNext': 1000,
      'motorMax': 15000,
      'evKwh': 2000,
      'grace': 20,
      'penalty': 5000,
      'memberDiscount': true,
      'walletCashback': false,
    },
  };

  Map<String, dynamic> getPricing(String location) {
    return _locationPricings[location] ?? _locationPricings['Central Park Mall']!;
  }

  /// Memuat konfigurasi tarif dari Supabase
  Future<void> fetchPricing(String location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_locations')
          .select('name, hourly_rate_mobil, hourly_rate_motor, hourly_rate_ev')
          .eq('name', location)
          .maybeSingle();

      if (res != null) {
        final current = _locationPricings[location] ?? {};
        _locationPricings[location] = {
          ...current,
          'carFirst': (res['hourly_rate_mobil'] as num?)?.toInt() ?? 5000,
          'motorFirst': (res['hourly_rate_motor'] as num?)?.toInt() ?? 2000,
          'evKwh': (res['hourly_rate_ev'] as num?)?.toInt() ?? 2500,
        };
      }
    } catch (e) {
      debugPrint('[AdminPricingBackend] fetchPricing error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Simpan konfigurasi tarif
  Future<bool> savePricing(String location, Map<String, dynamic> data) async {
    _locationPricings[location] = {...getPricing(location), ...data};
    notifyListeners();

    try {
      await _client.from('parking_locations').update({
        'hourly_rate_mobil': data['carFirst'],
        'hourly_rate_motor': data['motorFirst'],
        'hourly_rate_ev': data['evKwh'],
      }).eq('name', location);
      return true;
    } catch (e) {
      debugPrint('[AdminPricingBackend] savePricing error: $e');
      return false;
    }
  }
}
