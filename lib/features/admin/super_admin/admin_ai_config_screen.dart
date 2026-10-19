import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../theme/app_theme.dart';

import '../../../core/services/ai_config_service.dart';
import 'backend/admin_ai_config_backend.dart';

class AdminAiConfigScreen extends StatefulWidget {
  const AdminAiConfigScreen({super.key});

  @override
  State<AdminAiConfigScreen> createState() => _AdminAiConfigScreenState();
}

class _AdminAiConfigScreenState extends State<AdminAiConfigScreen> {
  // Controller input API Key Groq
  final TextEditingController _apiKeyCtrl = TextEditingController();
  bool _obscureKey = true;
  bool _isLoading = true;
  bool _isSaving = false;

  // Status Tes Koneksi
  bool _isTesting = false;
  String? _testOutput;
  int? _testLatencyMs;
  bool? _testSuccess;

  // Spesifikasi Provider & Model (Groq + Qwen)
  static const String _providerName = 'Groq Cloud (LPU™ Inference)';
  static const String _modelName = 'Qwen 2.5 (qwen/qwen3.8-27b)';
  static const String _endpointUrl = 'https://api.groq.com/openai/v1/chat/completions';

  @override
  void initState() {
    super.initState();
    _loadSavedApiKey();
  }

  Future<void> _loadSavedApiKey() async {
    try {
      await AdminAiConfigBackend.instance.loadConfig();
      final key = AdminAiConfigBackend.instance.apiKey.isNotEmpty 
          ? AdminAiConfigBackend.instance.apiKey
          : await AiConfigService.instance.loadActiveApiKey();

      if (mounted) {
        if (key != null && key.isNotEmpty) {
          _apiKeyCtrl.text = key;
        } else {
          _apiKeyCtrl.text = '';
        }
      }
    } catch (_) {
      if (mounted) _apiKeyCtrl.text = '';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyCtrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Key tidak boleh kosong!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFD94B4B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!key.startsWith('gsk_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Format tidak valid: API Key Groq harus diawali dengan "gsk_"', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFD94B4B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Menyimpan dengan aturan Supabase: Hapus yang lama & Insert yang baru (1 Row)
      final result = await AiConfigService.instance.saveApiKey(
        apiKey: key,
        provider: _providerName,
        modelName: _modelName,
        updatedBy: 'Super Admin',
      );

      await AdminAiConfigBackend.instance.saveConfig(newApiKey: key);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: result.isSuccess ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan API Key: $e', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFD94B4B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _testAiConnection() async {
    final key = _apiKeyCtrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan API Key terlebih dahulu sebelum menguji koneksi.', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFD94B4B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isTesting = true;
      _testOutput = null;
      _testLatencyMs = null;
      _testSuccess = null;
    });

    final stopwatch = Stopwatch()..start();

    try {
      // Panggilan asli langsung ke endpoint Groq Cloud LPU
      final response = await http.post(
        Uri.parse(_endpointUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.8-27b',
          'messages': [
            {'role': 'user', 'content': 'Halo, uji koneksi sistem Smart Parking.'}
          ],
          'max_tokens': 30,
        }),
      ).timeout(const Duration(seconds: 10));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final reply = decoded['choices']?[0]?['message']?['content'] ?? 'Koneksi sukses.';
        final usage = decoded['usage'];
        final compTokens = usage?['completion_tokens'] ?? '-';
        final totalTime = usage?['total_time'] ?? '-';

        setState(() {
          _isTesting = false;
          _testLatencyMs = stopwatch.elapsedMilliseconds;
          _testSuccess = true;
          _testOutput = 'HTTP 200 OK ($_providerName Live Terhubung)\nModel: $_modelName\nLatensi Nyata: ${stopwatch.elapsedMilliseconds} ms\nPenggunaan Token: $compTokens token ($totalTime s)\nRespon Nyata: "$reply"';
        });
      } else {
        String errorDetail = response.body;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded['error']?['message'] != null) {
            errorDetail = decoded['error']['message'];
          }
        } catch (_) {}

        setState(() {
          _isTesting = false;
          _testLatencyMs = stopwatch.elapsedMilliseconds;
          _testSuccess = false;
          _testOutput = 'HTTP ${response.statusCode} - ${response.reasonPhrase}\nDetail Error Server Groq: $errorDetail';
        });
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isTesting = false;
        _testLatencyMs = stopwatch.elapsedMilliseconds;
        _testSuccess = false;
        _testOutput = 'Gagal terhubung ke endpoint Groq Cloud: $e\nSilakan periksa koneksi internet perangkat Anda atau status endpoint Groq.';
      });
    }
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konfigurasi AI Assistant',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              ),
              Text(
                'Groq Cloud LPU™ • Model Qwen',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ⚡ KARTU INFORMASI PROVIDER & MODEL (GROQ + QWEN)
                  _buildProviderInfoCard(),
                  const SizedBox(height: 20),

                  // 🔑 FORM INPUT HANYA API KEY
                  _buildApiKeyInputCard(),
                  const SizedBox(height: 20),

                  // 🧪 KARTU UJI KONEKSI REALISTIS
                  _buildConnectionTestCard(),
                  const SizedBox(height: 20),

                  // 📖 PANDUAN MENDAPATKAN API KEY GROQ GRATIS
                  _buildTutorialCard(),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  // 1. KARTU INFORMASI RESMI PROVIDER GROQ & MODEL QWEN
  Widget _buildProviderInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D1F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF55036).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF55036).withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.bolt, color: Color(0xFFF55036), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Groq Cloud',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF55036),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LPU™ Engine',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Model: $_modelName',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),

          Text(
            'Asisten cerdas ParkSmart (Jarvis AI) ditenagai oleh provider Groq LPU™ menggunakan arsitektur model open-weights Qwen. Groq memproses inferensi teks hingga 500+ token per detik sehingga respon pencarian dan booking parkir terasa instan.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFFD1D5DB),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Chips Spesifikasi Realistis
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSpecChip(Icons.speed, '500+ Tokens/detik'),
              _buildSpecChip(Icons.psychology, 'Model Qwen 2.5'),
              _buildSpecChip(Icons.memory, 'Tensor Streaming (LPU)'),
              _buildSpecChip(Icons.vpn_key_outlined, 'Prefix: gsk_...'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFF55036)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // 2. KARTU INPUT HANYA API KEY
  Widget _buildApiKeyInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4DFD5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key, color: Color(0xFFF55036), size: 20),
              const SizedBox(width: 8),
              Text(
                'Groq API Key',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Masukkan API Key resmi Anda yang didapatkan dari dashboard console.groq.com',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
          ),
          const SizedBox(height: 14),

          // TextField API Key
          TextField(
            controller: _apiKeyCtrl,
            obscureText: _obscureKey,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A18),
            ),
            decoration: InputDecoration(
              hintText: 'gsk_...',
              hintStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFB0B0B0)),
              prefixIcon: const Icon(Icons.vpn_key_outlined, color: Color(0xFFF55036)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF76777B),
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAF9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE4DFD5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE4DFD5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF55036), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Simpan
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveApiKey,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 18, color: Colors.white),
            label: Text(
              _isSaving ? 'Menyimpan ke Database...' : 'Simpan API Key',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C1D1F),
              disabledBackgroundColor: const Color(0xFF76777B),
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

        ],
      ),
    );
  }

  // 3. KARTU UJI KONEKSI REALISTIS
  Widget _buildConnectionTestCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Uji Status Endpoint Groq',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ElevatedButton.icon(
                  onPressed: _isTesting ? null : _testAiConnection,
                  icon: _isTesting
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                  label: Text(
                    _isTesting ? 'Menguji...' : 'Uji Koneksi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF114177),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),

          if (_testLatencyMs != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (_testSuccess == true) ? const Color(0xFFD1F2EB) : const Color(0xFFFDE8E4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (_testSuccess == true) ? Icons.check_circle : Icons.error_outline,
                    size: 14,
                    color: (_testSuccess == true) ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Latensi LPU: ${_testLatencyMs}ms · ${(_testSuccess == true) ? "Endpoint Aktif & Terhubung" : "Kendala Respon"}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: (_testSuccess == true) ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_testOutput != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1D1F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _testOutput!,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: (_testSuccess == true) ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 4. PANDUAN MENDAPATKAN API KEY GROQ GRATIS
  Widget _buildTutorialCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: Color(0xFF114177), size: 18),
              const SizedBox(width: 8),
              Text(
                'Cara Mendapatkan Groq API Key Gratis:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTutorialStep('1', 'Buka portal resmi: console.groq.com'),
          _buildTutorialStep('2', 'Masuk (Sign in) dengan akun Google atau GitHub Anda'),
          _buildTutorialStep('3', 'Buka menu "API Keys" di sidebar kiri dan klik "Create API Key"'),
          _buildTutorialStep('4', 'Beri nama (misal: "ParkSmart-AI"), salin key yang berawalan "gsk_...", lalu tempel di atas.'),
          const SizedBox(height: 8),
          Text(
            '💡 Groq menyediakan kuota gratis harian (Free Tier) yang sangat memadai untuk menjalankan model Qwen tanpa biaya berlangganan.',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF114177),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A)),
            ),
          ),
        ],
      ),
    );
  }
}