import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';

/// Backend khusus untuk AiAssistantScreen
/// Menghubungkan asisten pintar dengan konfigurasi AI dari Super Admin di `public.system_settings`,
/// serta data langsung dari `public.parking_locations` untuk rekomendasi parkir presisi.
class AiAssistantBackend extends ChangeNotifier {
  AiAssistantBackend._();
  static final AiAssistantBackend instance = AiAssistantBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<Map<String, dynamic>> _chatHistory = [];
  List<Map<String, dynamic>> get chatHistory => _chatHistory;

  /// Memuat prompt & model AI dari pengaturan Super Admin (`system_settings`)
  Future<Map<String, dynamic>> getAiConfig() async {
    return await DatabaseCacheBalancerService.instance.getBalanced<Map<String, dynamic>>(
      queryKey: 'system_ai_config',
      ttl: const Duration(minutes: 10),
      queryFn: () async {
        try {
          final res = await _client
              .from('system_settings')
              .select('setting_value')
              .eq('setting_key', 'ai_assistant_config')
              .maybeSingle();

          if (res != null && res['setting_value'] is Map) {
            return Map<String, dynamic>.from(res['setting_value']);
          }
        } catch (_) {}

        return {
          'model': 'gemini-1.5-flash',
          'temperature': 0.7,
          'system_prompt': 'Kamu adalah asisten pintar ParkSmart ID yang ramah dan membantu pengguna menemukan tempat parkir terbaik.',
        };
      },
    );
  }

  /// Memproses prompt pertanyaan pengguna dan memberikan rekomendasi tempat parkir
  Future<Map<String, dynamic>> processQuery(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil data lokasi parkir terkini dari database
      final locations = await _client
          .from('parking_locations')
          .select('id, name, address, hourly_rate, available_slots, total_slots, status')
          .limit(10);

      // 2. Analisis kebutuhan pengguna
      final qLower = query.toLowerCase();
      List<dynamic> matched = [];

      if (qLower.contains('murah')) {
        // Urutkan dari tarif termurah
        matched = List.from(locations)..sort((a, b) => (a['hourly_rate'] as num).compareTo(b['hourly_rate'] as num));
      } else if (qLower.contains('banyak') || qLower.contains('kosong') || qLower.contains('tersedia')) {
        // Urutkan dari slot terbanyak
        matched = List.from(locations)..sort((a, b) => (b['available_slots'] as num).compareTo(a['available_slots'] as num));
      } else {
        matched = locations;
      }

      final responseText = matched.isNotEmpty
          ? 'Saya menemukan ${matched.length} lokasi parkir yang sesuai dengan pencarian Anda.'
          : 'Maaf, saat ini belum ada lokasi parkir yang sesuai di sekitar Anda.';

      final result = {
        'response': responseText,
        'recommendations': matched.take(3).toList(),
      };

      _chatHistory.add({
        'sender': 'user',
        'message': query,
        'time': DateTime.now(),
      });

      _chatHistory.add({
        'sender': 'ai',
        'message': responseText,
        'time': DateTime.now(),
        'recommendations': matched.take(3).toList(),
      });

      return result;
    } catch (e) {
      debugPrint('[AiAssistantBackend] Error: $e');
      _errorMessage = e.toString();
      return {
        'response': 'Terjadi kendala saat memproses permintaan Anda.',
        'recommendations': [],
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatHistory.clear();
    notifyListeners();
  }
}
