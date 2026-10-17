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
  /// 1. Prioritas utama: Ambil dari SharedPreferences (instan agar UI tidak kedip kosong).
  /// 2. Sinkronkan dengan Supabase Cloud (jika koneksi & kredensial tersedia).
  /// 3. Fallback ke .env jika belum pernah disimpan.
  Future<String?> loadActiveApiKey() async {
    String? localKey;
    try {
      final prefs = await SharedPreferences.getInstance();
      localKey = prefs.getString(prefKeyGroqApi);
    } catch (e) {
      debugPrint('[AiConfigService] Error reading SharedPreferences: $e');
    }

    // Coba sinkronisasi dari Supabase Cloud di latar belakang atau prioritaskan nilai DB jika ada
    try {
      final cloudConfig = await fetchCloudConfig();
      if (cloudConfig != null && cloudConfig['api_key'] != null) {
        final cloudKey = cloudConfig['api_key'].toString().trim();
        if (cloudKey.isNotEmpty) {
          // Update cache lokal agar selalu sinkron
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(prefKeyGroqApi, cloudKey);
          return cloudKey;
        }
      }
    } catch (e) {
      debugPrint('[AiConfigService] Cloud fetch failed, using local: $e');
    }

    if (localKey != null && localKey.isNotEmpty) {
      return localKey;
    }

    // Fallback terakhir: Cek .env
    try {
      if (dotenv.isInitialized) {
        final envKey = dotenv.env['GROQ_API_KEY'];
        if (envKey != null && envKey.isNotEmpty) {
          return envKey.trim();
        }
      }
    } catch (_) {}

    return null;
  }

  /// Mengambil konfigurasi aktif dari Supabase (`public.ai_agent_configs`)
  Future<Map<String, dynamic>?> fetchCloudConfig() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];

    if (supabaseUrl == null || supabaseKey == null || supabaseUrl.isEmpty) {
      return null;
    }

    final cleanUrl = supabaseUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanUrl/rest/v1/ai_agent_configs?select=*&order=updated_at.desc&limit=1');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return Map<String, dynamic>.from(data.first as Map);
      }
    }
    return null;
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

    // 2. Simpan ke Supabase Cloud (Hapus yang lama -> Insert yang baru -> 1 Row)
    bool syncedToSupabase = false;
    String? supabaseError;

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];

    if (supabaseUrl != null && supabaseKey != null && supabaseUrl.isNotEmpty) {
      try {
        final cleanUrl = supabaseUrl.replaceAll(RegExp(r'/+$'), '');

        // LANGKAH A: HAPUS ROW LAMA (DELETE ALL EXISTING ROWS)
        // Memastikan tabel selalu bersih dan hanya menyisakan 1 row setelah insert
        final deleteUri = Uri.parse('$cleanUrl/rest/v1/ai_agent_configs?id=not.is.null');
        await http.delete(
          deleteUri,
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Prefer': 'return=minimal',
          },
        ).timeout(const Duration(seconds: 5));

        // LANGKAH B: SISIPKAN ROW BARU (INSERT SINGLE ACTIVE ROW)
        final insertUri = Uri.parse('$cleanUrl/rest/v1/ai_agent_configs');
        final insertRes = await http.post(
          insertUri,
          headers: {
            'Content-Type': 'application/json',
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Prefer': 'return=representation',
          },
          body: jsonEncode({
            'provider': provider ?? defaultProvider,
            'model_name': modelName ?? defaultModel,
            'api_key': cleanKey,
            'endpoint_url': defaultEndpoint,
            'is_active': true,
            'updated_by': updatedBy,
            'updated_at': DateTime.now().toIso8601String(),
          }),
        ).timeout(const Duration(seconds: 5));

        if (insertRes.statusCode >= 200 && insertRes.statusCode < 300) {
          syncedToSupabase = true;
        } else {
          supabaseError = 'HTTP ${insertRes.statusCode}: ${insertRes.body}';
        }
      } catch (e) {
        supabaseError = e.toString();
        debugPrint('[AiConfigService] Error syncing to Supabase: $e');
      }
    }

    return SaveApiKeyResult(
      isSuccess: true,
      syncedToSupabase: syncedToSupabase,
      message: syncedToSupabase
          ? 'Groq API Key berhasil disimpan ke Database Supabase (1 Row Aktif) & Cache Perangkat!'
          : 'Groq API Key berhasil disimpan di Penyimpanan Perangkat (Persisten). ${supabaseError != null ? "Sinkronisasi cloud tertunda: $supabaseError" : ""}',
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
