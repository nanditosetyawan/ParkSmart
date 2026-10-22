import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/ai_config_service.dart';

/// Backend khusus untuk AdminAiConfigScreen
/// Mengatur konfigurasi integrasi LLM AI (Groq Cloud API Key & Model Inference)
/// Terhubung ke tabel `public.system_settings` (key 'ai_config') di Supabase
class AdminAiConfigBackend extends ChangeNotifier {
  AdminAiConfigBackend._();
  static final AdminAiConfigBackend instance = AdminAiConfigBackend._();

  SupabaseClient get _client => Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String _apiKey = '';
  String get apiKey => _apiKey;

  String _modelName = 'qwen/qwen3.8-27b';
  String get modelName => _modelName;

  double _temperature = 0.4;
  double get temperature => _temperature;

  int _maxTokens = 1024;
  int get maxTokens => _maxTokens;

  bool _isAutonomousPricingEnabled = true;
  bool get isAutonomousPricingEnabled => _isAutonomousPricingEnabled;

  /// Memuat konfigurasi AI dari Supabase dan AiConfigService
  Future<void> loadConfig() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil dari AiConfigService local
      final localKey = await AiConfigService.instance.loadActiveApiKey();
      if (localKey != null && localKey.isNotEmpty) {
        _apiKey = localKey;
      }

      // 2. Ambil dari Supabase system_settings
      final res = await _client
          .from('system_settings')
          .select('value')
          .eq('key', 'ai_config')
          .maybeSingle();

      if (res != null && res['value'] is Map) {
        final val = res['value'] as Map<String, dynamic>;
        if (val['model_name'] != null) {
          _modelName = val['model_name'].toString();
        }
        if (val['temperature'] != null) {
          _temperature = (val['temperature'] as num).toDouble();
        }
        if (val['max_tokens'] != null) {
          _maxTokens = (val['max_tokens'] as num).toInt();
        }
        if (val['is_autonomous_pricing_enabled'] != null) {
          _isAutonomousPricingEnabled = val['is_autonomous_pricing_enabled'] == true;
        }
      }
    } catch (e) {
      debugPrint('[AdminAiConfigBackend] loadConfig error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menyimpan API Key & parameter AI ke local dan Supabase
  Future<bool> saveConfig({
    required String newApiKey,
    double? temperature,
    int? maxTokens,
  }) async {
    _isSaving = true;
    _apiKey = newApiKey;
    if (temperature != null) _temperature = temperature;
    if (maxTokens != null) _maxTokens = maxTokens;
    notifyListeners();

    try {
      // Simpan ke local service
      await AiConfigService.instance.saveApiKey(apiKey: newApiKey);

      // Simpan ke Supabase system_settings
      await _client.from('system_settings').upsert({
        'key': 'ai_config',
        'value': {
          'model_name': _modelName,
          'temperature': _temperature,
          'max_tokens': _maxTokens,
          'is_autonomous_pricing_enabled': _isAutonomousPricingEnabled,
        },
        'description': 'Konfigurasi model kecerdasan buatan AI Jarvis untuk deteksi plat kamera & dynamic pricing',
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[AdminAiConfigBackend] saveConfig error: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Menguji koneksi langsung ke Groq Cloud
  Future<Map<String, dynamic>> testConnection(String testKey) async {
    final startTime = DateTime.now();
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $testKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'user', 'content': 'Halo, jawab dalam 5 kata.'}
          ],
          'max_tokens': 20,
        }),
      ).timeout(const Duration(seconds: 10));

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] ?? 'Koneksi Berhasil';
        return {
          'success': true,
          'output': content,
          'latency': latency,
        };
      } else {
        return {
          'success': false,
          'output': 'HTTP Error ${response.statusCode}: ${response.body}',
          'latency': latency,
        };
      }
    } catch (e) {
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      return {
        'success': false,
        'output': 'Gagal terhubung: $e',
        'latency': latency,
      };
    }
  }
}
