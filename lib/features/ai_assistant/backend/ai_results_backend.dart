import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backend khusus untuk AiResultsScreen
/// Menangani visualisasi hasil pencarian AI, pemilihan slot dari rekomendasi,
/// dan pengarahan langsung ke reservasi/navigasi.
class AiResultsBackend extends ChangeNotifier {
  AiResultsBackend._();
  static final AiResultsBackend instance = AiResultsBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Memverifikasi ketersediaan slot terkini pada lokasi yang dipilih dari hasil AI
  Future<bool> checkLocationAvailability(String locationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _client
          .from('parking_locations')
          .select('available_slots, status')
          .eq('id', locationId)
          .maybeSingle();

      if (res != null) {
        final available = (res['available_slots'] as num?)?.toInt() ?? 0;
        final status = res['status']?.toString().toLowerCase();
        return available > 0 && status != 'full' && status != 'maintenance';
      }
      return false;
    } catch (e) {
      debugPrint('[AiResultsBackend] Check error: $e');
      _errorMessage = e.toString();
      return true; // Graceful fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
