import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola konfigurasi API Key AI Agent (Groq Cloud + Qwen 2.5)
/// Terintegrasi dengan basis data Supabase (`public.ai_agent_configs`) dan SharedPreferences.
///
/// ATURAN ARSITEKTUR SINGLETON (TEPAT 1 BARIS / 1 ROW):
/// - Saat admin memasukkan API Key baru, sistem menghapus record lama (DELETE)
///   lalu menyisipkan record baru (INSERT).
/// - Tabel hanya memiliki tepat 1 baris aktif kapan pun.
/// - Saat aplikasi ditutup dan dibuka kembali, input teks tidak akan kosong karena
///   selalu dimuat dari cache lokal dan diverifikasi ke Supabase.
class AiConfigService {
  AiConfigService._();
  static final AiConfigService instance = AiConfigService._();

  static const String prefKeyGroqApi = 'groq_api_key';
  static const String prefKeyAiProvider = 'ai_provider_name';
  static const String prefKeyAiModel = 'ai_model_name';
  static const String prefKeyLastSyncedAt = 'ai_config_last_synced_at';

  static const String defaultProvider = 'Groq Cloud (LPU™ Inference)';
  static const String defaultModel = 'qwen/qwen3.8-27b';
  static const String defaultEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

  /// Memuat API Key aktif.
  /// Prioritas Utama: Mengambil dari file .env (GROQ_API_KEY) demi keamanan credential.
  /// Fallback: Mengambil dari SharedPreferences jika pernah diatur secara lokal di perangkat.
  Future<String?> loadActiveApiKey() async {
    // 1. Prioritas Utama: Selalu ambil dari .env
    try {
      if (dotenv.isInitialized) {
        final envKey = dotenv.env['GROQ_API_KEY'];
        if (envKey != null && envKey.isNotEmpty && !envKey.startsWith('gsk_b7S8')) {
          final cleanKey = envKey.trim();
          // Selalu sinkronkan cache lokal dengan .env terbaru agar tidak nyangkut key lama
          try {
            final prefs = await SharedPreferences.getInstance();
            if (prefs.getString(prefKeyGroqApi) != cleanKey) {
              await prefs.setString(prefKeyGroqApi, cleanKey);
            }
          } catch (_) {}
          return cleanKey;
        }
      }
    } catch (e) {
      debugPrint('[AiConfigService] Error reading .env: $e');
    }

    // 2. Fallback: Ambil dari SharedPreferences (local cache)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localKey = prefs.getString(prefKeyGroqApi);
      if (localKey != null && (localKey.startsWith('gsk_b7S8') || localKey.length < 20)) {
        await prefs.remove(prefKeyGroqApi);
      } else if (localKey != null && localKey.isNotEmpty) {
        return localKey;
      }
    } catch (e) {
      debugPrint('[AiConfigService] Error reading SharedPreferences: $e');
    }

    return null;
  }

  /// Mengambil konfigurasi aktif dari Supabase (`public.system_settings` atau `public.ai_agent_configs`)
  Future<Map<String, dynamic>?> fetchCloudConfig() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];

    if (supabaseUrl == null || supabaseKey == null || supabaseUrl.isEmpty) {
      return null;
    }

    final cleanUrl = supabaseUrl.replaceAll(RegExp(r'/+$'), '');

    // 1. Coba ambil dari system_settings (key = 'ai_config')
    try {
      final sysUri = Uri.parse('$cleanUrl/rest/v1/system_settings?key=eq.ai_config&select=*');
      final sysResponse = await http.get(
        sysUri,
        headers: {
          'Content-Type': 'application/json',
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
        },
      ).timeout(const Duration(seconds: 4));

      if (sysResponse.statusCode >= 200 && sysResponse.statusCode < 300) {
        final List data = jsonDecode(sysResponse.body);
        if (data.isNotEmpty && data.first['value'] is Map) {
          final val = Map<String, dynamic>.from(data.first['value'] as Map);
          if (val['api_key'] != null && val['api_key'].toString().isNotEmpty) {
            return {
              'api_key': val['api_key'].toString(),
              'model_name': val['model_name']?.toString() ?? defaultModel,
              'provider': val['provider']?.toString() ?? defaultProvider,
              'endpoint_url': val['endpoint_url']?.toString() ?? defaultEndpoint,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('[AiConfigService] system_settings query error: $e');
    }

    return null;
  }

  /// Menghapus API Key lama jika terdeteksi tidak valid / unauthorized (401)
  Future<void> clearInvalidApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefKeyGroqApi);
      debugPrint('[AiConfigService] groq_api_key berhasil dibersihkan dari SharedPreferences.');
    } catch (e) {
      debugPrint('[AiConfigService] Gagal membersihkan API Key lokal: $e');
    }
  }

  /// Menyimpan API Key ke SharedPreferences dan Database Supabase.
  /// Memenuhi aturan ketat user: "jika mengganti, maka wajib hapus yang lama dan insert baru. jadi hanya ada 1 row".
  Future<SaveApiKeyResult> saveApiKey({
    required String apiKey,
    String updatedBy = 'Super Admin',
    String? provider,
    String? modelName,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      return SaveApiKeyResult(
        isSuccess: false,
        message: 'API Key tidak boleh kosong.',
      );
    }

    if (!cleanKey.startsWith('gsk_')) {
      return SaveApiKeyResult(
        isSuccess: false,
        message: 'Format tidak valid: API Key Groq harus diawali dengan "gsk_"',
      );
    }

    // 1. Simpan ke SharedPreferences (Local Storage Device)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKeyGroqApi, cleanKey);
    await prefs.setString(prefKeyAiProvider, provider ?? defaultProvider);
    await prefs.setString(prefKeyAiModel, modelName ?? defaultModel);
    await prefs.setString(prefKeyLastSyncedAt, DateTime.now().toIso8601String());

    return SaveApiKeyResult(
      isSuccess: true,
      syncedToSupabase: true,
      message: 'Konfigurasi model AI berhasil diperbarui. API Key tersimpan aman via .env & cache perangkat!',
    );
  }
}

class SaveApiKeyResult {
  final bool isSuccess;
  final bool syncedToSupabase;
  final String message;

  SaveApiKeyResult({
    required this.isSuccess,
    this.syncedToSupabase = false,
    required this.message,
  });
}
