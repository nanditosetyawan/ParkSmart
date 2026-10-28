import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/database_cache_balancer_service.dart';
import 'ai_context_service.dart';
import 'ai_security_service.dart';

/// Backend khusus untuk AiAssistantScreen
/// Menghubungkan asisten pintar dengan konfigurasi AI dari Super Admin di `public.system_settings`,
/// serta data langsung dari `public.parking_locations`, `public.customer_feedbacks`, dan `public.bookings`.
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
              .select('value')
              .eq('key', 'ai_assistant_config')
              .maybeSingle();

          if (res != null && res['value'] is Map) {
            return Map<String, dynamic>.from(res['value']);
          }
        } catch (_) {}

        return {
          'model': 'qwen/qwen3.8-27b',
          'temperature': 0.7,
          'system_prompt': 'Kamu adalah Jarvis, asisten AI resmi ParkSmart ID yang ramah dan siap membantu pengguna menemukan parkir terbaik.',
        };
      },
    );
  }

  /// Memproses prompt pertanyaan pengguna dan memberikan rekomendasi tempat parkir berbasis database
  Future<Map<String, dynamic>> processQuery(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🛡️ Pemeriksaan keamanan & anti-manipulasi
      final refusal = await AiSecurityService.inspectAndGetRefusal(query);
      if (refusal != null) {
        _chatHistory.add({
          'sender': 'user',
          'message': query,
          'time': DateTime.now(),
        });
        _chatHistory.add({
          'sender': 'ai',
          'message': refusal,
          'time': DateTime.now(),
          'recommendations': [],
        });
        return {
          'response': refusal,
          'recommendations': [],
        };
      }

      // 1. Ambil data konteks real-time dari AiContextService
      await AiContextService.instance.buildRealTimeContextPrompt();
      final locations = AiContextService.instance.cachedLocations;

      // 2. Analisis kebutuhan pengguna
      final qLower = query.toLowerCase();
      List<dynamic> matched = [];

      if (qLower.contains('murah')) {
        matched = List.from(locations)
          ..sort((a, b) => ((a['hourly_rate_mobil'] ?? 5000) as num)
              .compareTo((b['hourly_rate_mobil'] ?? 5000) as num));
      } else if (qLower.contains('penuh')) {
        matched = locations.where((l) => ((l['available_slots'] ?? 0) as num) == 0).toList();
      } else if (qLower.contains('banyak') || qLower.contains('kosong') || qLower.contains('tersedia')) {
        matched = List.from(locations)
          ..sort((a, b) => ((b['available_slots'] ?? 0) as num)
              .compareTo((a['available_slots'] ?? 0) as num));
      } else {
        matched = locations;
      }

      String responseText;
      if (qLower.contains('penuh')) {
        responseText = matched.isEmpty
            ? 'Saat ini tidak ada lokasi parkir yang penuh! Semua lokasi masih memiliki slot kosong yang siap dipesan.'
            : 'Berikut adalah ${matched.length} lokasi parkir yang saat ini berstatus penuh (0 slot tersedia).';
      } else {
        responseText = matched.isNotEmpty
            ? 'Saya menemukan ${matched.length} lokasi parkir yang sesuai dengan pencarian Anda.'
            : 'Maaf, saat ini belum ada lokasi parkir yang sesuai di sekitar Anda.';
      }

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
