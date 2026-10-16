import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAiConfigScreen extends StatefulWidget {
  const AdminAiConfigScreen({super.key});

  @override
  State<AdminAiConfigScreen> createState() => _AdminAiConfigScreenState();
}

class _AdminAiConfigScreenState extends State<AdminAiConfigScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // System Prompt
  final TextEditingController _systemPromptCtrl = TextEditingController(text: '''
Anda adalah asisten parkir ParkSmart. Tugas Anda: mengubah bahasa alami user menjadi FILTER JSON terstruktur untuk mencari slot parkir.

ATURAN:
1. Hanya output JSON valid, tanpa penjelasan tambahan.
2. Field wajib: "intent" (search_parking|get_pricing|get_directions|book_slot|extend_session|end_session|check_wallet|help)
3. Field opsional: "location", "vehicle_type", "start_time", "duration_hours", "max_price", "features" (array: ev_charger|disabled_access|roof|vip), "radius_km", "sort_by" (price_asc|distance|rating)

CONTOH:
User: "Cari parkir motor di Malioboro Mall besok jam 9 pagi 3 jam maksimal 15rb"
Output: {"intent":"search_parking","location":"Malioboro Mall","vehicle_type":"Motor","start_time":"2024-01-15T09:00:00","duration_hours":3,"max_price":15000}

User: "Berapa tarif mobil di Central Park Mall?"
Output: {"intent":"get_pricing","location":"Central Park Mall","vehicle_type":"Mobil"}
''');

  // Model Config
  String _selectedModel = 'llama3.2:3b';
  final List<String> _availableModels = ['llama3.2:3b', 'llama3.2:1b', 'mistral:7b', 'phi3:3.8b', 'gemma2:2b'];
  double _temperature = 0.1;
  int _maxTokens = 512;
  int _timeoutSeconds = 30;
  bool _enableStreaming = false;

  // Intent Schema (JSON)
  final TextEditingController _intentSchemaCtrl = TextEditingController(text: '''
{
  "type": "object",
  "properties": {
    "intent": {"type": "string", "enum": ["search_parking", "get_pricing", "get_directions", "book_slot", "extend_session", "end_session", "check_wallet", "help"]},
    "location": {"type": "string"},
    "vehicle_type": {"type": "string", "enum": ["Mobil", "Motor", "EV"]},
    "start_time": {"type": "string", "format": "date-time"},
    "duration_hours": {"type": "integer", "minimum": 1, "maximum": 24},
    "max_price": {"type": "integer", "minimum": 0},
    "features": {"type": "array", "items": {"type": "string", "enum": ["ev_charger", "disabled_access", "roof", "vip"]}},
    "radius_km": {"type": "number", "minimum": 0.5, "maximum": 50},
    "sort_by": {"type": "string", "enum": ["price_asc", "distance", "rating"]}
  },
  "required": ["intent"]
}
''');

  // Fallback Rules
  final List<Map<String, dynamic>> _fallbackRules = [
    {'trigger': 'timeout', 'action': 'use_cached_intent', 'params': {'default_intent': 'search_parking'}, 'enabled': true},
    {'trigger': 'parse_error', 'action': 'ask_clarification', 'params': {'message': 'Maaf, saya tidak mengerti. Bisa tolong ulangi dengan lebih detail?'}, 'enabled': true},
    {'trigger': 'low_confidence', 'action': 'show_suggestions', 'params': {'threshold': 0.6, 'suggestions': ['Cari parkir mobil', 'Cek tarif motor', 'Navigasi ke lokasi']}, 'enabled': true},
    {'trigger': 'no_slots_found', 'action': 'expand_search', 'params': {'radius_increment_km': 2, 'max_radius_km': 10}, 'enabled': true},
    {'trigger': 'model_unavailable', 'action': 'fallback_to_keyword', 'params': {'keywords': ['parkir', 'tarif', 'navigasi', 'booking', 'perpanjang', 'selesai', 'saldo']}, 'enabled': true},
  ];

  // Test Input
  final TextEditingController _testInputCtrl = TextEditingController();
  String? _testResult;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _systemPromptCtrl.dispose();
    _intentSchemaCtrl.dispose();
    _testInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _runTest() async {
    if (_testInputCtrl.text.trim().isEmpty) return;
    setState(() {
      _isTesting = true;
      _testResult = null;
    });
    // Simulate AI processing
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isTesting = false;
      _testResult = '''
{
  "intent": "search_parking",
  "location": "Central Park Mall",
  "vehicle_type": "Mobil",
  "start_time": "2024-12-20T14:00:00",
  "duration_hours": 2,
  "max_price": 50000,
  "features": ["roof"],
  "radius_km": 5,
  "sort_by": "price_asc"
}
''';
    });
  }

  void _addFallbackRule() {
    setState(() {
      _fallbackRules.add({
        'trigger': 'custom',
        'action': 'custom_action',
        'params': {},
        'enabled': true,
      });
    });
  }

  void _removeFallbackRule(int index) {
    setState(() => _fallbackRules.removeAt(index));
  }

  Widget _buildSectionTitle(String title, {String? subtitle, VoidCallback? onAction, String? actionLabel}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              if (subtitle != null) Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          if (onAction != null && actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 16),
              label: Text(actionLabel, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF114177)),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: child,
    );
  }

  Widget _buildCodeEditor(TextEditingController controller, {int minLines = 12, String? hint}) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: null,
      style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF1A1A18)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF76777B)),
        filled: true,
        fillColor: const Color(0xFF1A1A18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildModelConfig() {
    return Column(
      children: [
        _buildSectionTitle('Model Ollama', subtitle: 'Model lokal yang digunakan untuk inferensi'),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedModel,
                decoration: InputDecoration(
                  labelText: 'Model',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.memory, color: Color(0xFF114177)),
                ),
                items: _availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _selectedModel = v ?? _availableModels.first),
              ),
              const SizedBox(height: 16),
              _buildSliderRow(
                label: 'Temperature: ${_temperature.toStringAsFixed(1)}',
                value: _temperature,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (v) => setState(() => _temperature = v),
                icon: Icons.tune,
                color: const Color(0xFFE07A5F),
              ),
              const SizedBox(height: 12),
              _buildSliderRow(
                label: 'Max Tokens: $_maxTokens',
                value: _maxTokens.toDouble(),
                min: 128,
                max: 2048,
                divisions: 16,
                onChanged: (v) => setState(() => _maxTokens = v.round()),
                icon: Icons.text_fields,
                color: const Color(0xFF45474A),
              ),
              const SizedBox(height: 12),
              _buildSliderRow(
                label: 'Timeout: ${_timeoutSeconds}s',
                value: _timeoutSeconds.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                onChanged: (v) => setState(() => _timeoutSeconds = v.round()),
                icon: Icons.timer,
                color: const Color(0xFF17A18A),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Streaming Response', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                subtitle: Text('Tampilkan response token-by-token (perlu dukungan Ollama)', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                value: _enableStreaming,
                activeThumbColor: const Color(0xFF17A18A),
                onChanged: (v) => setState(() => _enableStreaming = v),
              ),
            ],
          ),
        ),
        _buildSectionTitle('Status Koneksi'),
        _buildCard(
          child: Row(
            children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFD1F2EB), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.cloud_done, color: Color(0xFF17A18A))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ollama Server', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    Text('http://localhost:11434 • Terhubung', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Memeriksa koneksi Ollama...'))),
                icon: const Icon(Icons.refresh, size: 16),
                label: Text('Cek Koneksi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF114177), side: const BorderSide(color: Color(0xFF114177))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)))]),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: color,
          inactiveColor: color.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildSystemPromptTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('System Prompt', subtitle: 'Instruksi utama untuk LLM. Perubahan mempengaruhi semua response AI.'),
          _buildCard(child: _buildCodeEditor(_systemPromptCtrl, minLines: 18, hint: 'System prompt untuk Ollama...')),
          _buildSectionTitle('Quick Actions'),
          _buildCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildQuickActionBtn('Reset Default', Icons.restore, const Color(0xFF76777B), () {
                  // Reset to default
                }),
                _buildQuickActionBtn('Simpan Perubahan', Icons.save, const Color(0xFF17A18A), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System prompt disimpan'), backgroundColor: Color(0xFF17A18A)));
                }),
                _buildQuickActionBtn('Validasi JSON', Icons.code, const Color(0xFF114177), () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Validasi format prompt...')));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentSchemaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('JSON Schema Intent', subtitle: 'Skema validasi output AI. Harus valid JSON Schema Draft-07.'),
          _buildCard(child: _buildCodeEditor(_intentSchemaCtrl, minLines: 20, hint: 'JSON Schema untuk validasi intent...')),
          _buildSectionTitle('Field Reference'),
          _buildCard(
            child: Column(
              children: _intentFields.map((f) => _buildFieldRow(f['name']!, f['type']!, f['desc']!, f['required']!)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, String>> _intentFields = [
    {'name': 'intent', 'type': 'string (enum)', 'desc': 'Jenis aksi utama user', 'required': 'Ya'},
    {'name': 'location', 'type': 'string', 'desc': 'Nama lokasi parkir (opsional)', 'required': 'Tidak'},
    {'name': 'vehicle_type', 'type': 'string (enum)', 'desc': 'Mobil | Motor | EV', 'required': 'Tidak'},
    {'name': 'start_time', 'type': 'ISO8601 datetime', 'desc': 'Waktu mulai parkir', 'required': 'Tidak'},
    {'name': 'duration_hours', 'type': 'integer (1-24)', 'desc': 'Durasi parkir dalam jam', 'required': 'Tidak'},
    {'name': 'max_price', 'type': 'integer (IDR)', 'desc': 'Budget maksimum user', 'required': 'Tidak'},
    {'name': 'features', 'type': 'array[string]', 'desc': 'ev_charger, disabled_access, roof, vip', 'required': 'Tidak'},
    {'name': 'radius_km', 'type': 'number (0.5-50)', 'desc': 'Radius pencarian dari lokasi', 'required': 'Tidak'},
    {'name': 'sort_by', 'type': 'string (enum)', 'desc': 'price_asc | distance | rating', 'required': 'Tidak'},
  ];

  Widget _buildFieldRow(String name, String type, String desc, String required) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 120, child: Text(name, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)))),
          Container(width: 130, child: Text(type, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF45474A)))),
          Expanded(child: Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: required == 'Ya' ? const Color(0xFFFDE8E4) : const Color(0xFFD1F2EB), borderRadius: BorderRadius.circular(4)),
            child: Text(required, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: required == 'Ya' ? const Color(0xFFD94B4B) : const Color(0xFF17A18A))),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackRulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Aturan Fallback', subtitle: 'Tindakan otomatis ketika AI gagal atau tidak tersedia', onAction: _addFallbackRule, actionLabel: 'Tambah Aturan'),
          _buildCard(
            child: Column(
              children: _fallbackRules.asMap().entries.map((e) => _buildFallbackRuleCard(e.key, e.value)).toList(),
            ),
          ),
          _buildSectionTitle('Priority Order', subtitle: 'Drag untuk mengubah prioritas (fitur drag-drop belum diimplementasi)'),
          _buildCard(
            child: Column(
              children: [
                _buildPriorityItem(1, 'timeout', 'Gunakan intent cache terakhir', true),
                _buildPriorityItem(2, 'parse_error', 'Minta klarifikasi ke user', true),
                _buildPriorityItem(3, 'low_confidence', 'Tampilkan saran perintah', true),
                _buildPriorityItem(4, 'no_slots_found', 'Perluas radius pencarian', true),
                _buildPriorityItem(5, 'model_unavailable', 'Fallback ke keyword matching', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackRuleCard(int index, Map<String, dynamic> rule) {
    final triggers = ['timeout', 'parse_error', 'low_confidence', 'no_slots_found', 'model_unavailable', 'custom'];
    final actions = ['use_cached_intent', 'ask_clarification', 'show_suggestions', 'expand_search', 'fallback_to_keyword', 'custom_action'];

    String triggerLabel = rule['trigger'];
    String actionLabel = rule['action'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE4DFD5))),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: rule['trigger'],
              isDense: true,
              decoration: InputDecoration(labelText: 'Trigger', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: triggers.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.plusJakartaSans(fontSize: 11)))).toList(),
              onChanged: (v) => setState(() => rule['trigger'] = v!),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: rule['action'],
              isDense: true,
              decoration: InputDecoration(labelText: 'Action', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: actions.map((a) => DropdownMenuItem(value: a, child: Text(a, style: GoogleFonts.plusJakartaSans(fontSize: 11)))).toList(),
              onChanged: (v) => setState(() => rule['action'] = v!),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: rule['params'].toString(),
              decoration: InputDecoration(labelText: 'Params (JSON)', labelStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              style: GoogleFonts.jetBrainsMono(fontSize: 11),
              onChanged: (v) => setState(() => rule['params'] = v),
            ),
          ),
          const SizedBox(width: 10),
          Switch(value: rule['enabled'], activeThumbColor: const Color(0xFF17A18A), onChanged: (v) => setState(() => rule['enabled'] = v)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFD94B4B), size: 20),
            onPressed: () => _removeFallbackRule(index),
            tooltip: 'Hapus aturan',
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(int priority, String trigger, String desc, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFF114177), borderRadius: BorderRadius.circular(6)), child: Center(child: Text('$priority', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(trigger, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))), Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B)))])),
          Switch(value: enabled, activeThumbColor: const Color(0xFF17A18A), onChanged: (v) {}),
        ],
      ),
    );
  }

  Widget _buildTestingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Test AI Input', subtitle: 'Masukkan query natural language untuk test ekstraksi intent'),
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _testInputCtrl,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                  decoration: InputDecoration(
                    hintText: 'Contoh: "Cari parkir motor di Malioboro Mall besok jam 9 pagi 3 jam maksimal 15rb"',
                    hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _runTest,
                    icon: _isTesting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow),
                    label: Text(_isTesting ? 'Memproses...' : 'Jalankan Test', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF114177), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
          if (_testResult != null) ...[
            _buildSectionTitle('Hasil Ekstraksi Intent'),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('JSON Output', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON disalin ke clipboard'))),
                        tooltip: 'Salin JSON',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _testResult!,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF1A1A18)),
                  ),
                ],
              ),
            ),
            _buildSectionTitle('Validasi Schema'),
            _buildCard(
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFD1F2EB), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.check_circle, color: Color(0xFF17A18A))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Valid JSON Schema', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))), Text('Output sesuai skema intent yang didefinisikan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)))])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFD1F2EB), borderRadius: BorderRadius.circular(20)), child: Text('VALID', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A)))),
                ],
              ),
            ),
          ],
          _buildSectionTitle('Contoh Cepat'),
          _buildCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _testExamples.map((ex) => ActionChip(
                label: Text(ex, style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                onPressed: () {
                  _testInputCtrl.text = ex;
                  _runTest();
                },
                backgroundColor: const Color(0xFFF1EEE7),
                side: const BorderSide(color: Color(0xFFE4DFD5)),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  final List<String> _testExamples = [
    'Cari parkir mobil di Central Park Mall jam 2 siang 3 jam',
    'Berapa tarif motor di Malioboro Mall?',
    'Navigasi ke Pacific Place SCBD',
    'Booking slot EV charger di Grand Indonesia besok pagi',
    'Perpanjang parkir 2 jam lagi',
    'Selesai parkir, hitung biayanya',
    'Cek saldo dompet saya',
  ];

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Analitik Penggunaan AI', subtitle: 'Statistik 7 hari terakhir'),
          _buildCard(
            child: Row(
              children: [
                _buildAnalyticsCard('Total Requests', '12,847', Icons.chat, const Color(0xFF114177)),
                _buildAnalyticsCard('Success Rate', '94.2%', Icons.check_circle, const Color(0xFF17A18A)),
                _buildAnalyticsCard('Avg Latency', '1.2s', Icons.speed, const Color(0xFFE07A5F)),
                _buildAnalyticsCard('Fallback Rate', '5.8%', Icons.warning_amber, const Color(0xFFD94B4B)),
              ],
            ),
          ),
          _buildSectionTitle('Distribusi Intent'),
          _buildCard(
            child: Column(
              children: _intentDistribution.map((d) => _buildIntentBar(d['label']!, d['count']!, d['pct']!, d['color']!)).toList(),
            ),
          ),
          _buildSectionTitle('Fallback Triggers'),
          _buildCard(
            child: Column(
              children: _fallbackStats.map((f) => _buildFallbackStatRow(f['trigger']!, f['count']!, f['pct']!)).toList(),
            ),
          ),
          _buildSectionTitle('Error Patterns'),
          _buildCard(
            child: Column(
              children: [
                _buildErrorRow('Timeout Ollama', '42', '0.3%'),
                _buildErrorRow('JSON Parse Error', '18', '0.1%'),
                _buildErrorRow('Low Confidence', '156', '1.2%'),
                _buildErrorRow('Model Unavailable', '8', '0.06%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _intentDistribution = [
    {'label': 'search_parking', 'count': 5420, 'pct': 42.2, 'color': Color(0xFF114177)},
    {'label': 'get_pricing', 'count': 2180, 'pct': 17.0, 'color': Color(0xFF17A18A)},
    {'label': 'book_slot', 'count': 1890, 'pct': 14.7, 'color': Color(0xFFE07A5F)},
    {'label': 'extend_session', 'count': 1240, 'pct': 9.6, 'color': Color(0xFF45474A)},
    {'label': 'end_session', 'count': 1100, 'pct': 8.6, 'color': Color(0xFFD94B4B)},
    {'label': 'check_wallet', 'count': 560, 'pct': 4.4, 'color': Color(0xFF76777B)},
    {'label': 'get_directions', 'count': 310, 'pct': 2.4, 'color': Color(0xFF9B59B6)},
    {'label': 'help', 'count': 147, 'pct': 1.1, 'color': Color(0xFFE74C3C)},
  ];

  final List<Map<String, dynamic>> _fallbackStats = [
    {'trigger': 'low_confidence', 'count': 156, 'pct': 1.2},
    {'trigger': 'no_slots_found', 'count': 89, 'pct': 0.7},
    {'trigger': 'timeout', 'count': 42, 'pct': 0.3},
    {'trigger': 'parse_error', 'count': 18, 'pct': 0.1},
    {'trigger': 'model_unavailable', 'count': 8, 'pct': 0.06},
  ];

  Widget _buildAnalyticsCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildIntentBar(String label, int count, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)))),
          Expanded(child: Stack(children: [Container(height: 10, decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(5))), FractionallySizedBox(widthFactor: pct / 100, child: Container(height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))))])),
          const SizedBox(width: 10),
          Text('${count} (${pct.toStringAsFixed(1)}%)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFallbackStatRow(String trigger, int count, double pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(trigger, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18)))),
          Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
          const SizedBox(width: 10),
          Text('${pct.toStringAsFixed(1)}%', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        ],
      ),
    );
  }

  Widget _buildErrorRow(String error, String count, String pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(error, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF1A1A18)))),
          Text(count, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
          const SizedBox(width: 10),
          Text(pct, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: color), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
    );
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
          child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A18))),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Konfigurasi AI', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Ollama LLM • Intent Extraction', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konfigurasi AI disimpan'), backgroundColor: Color(0xFF17A18A))),
            icon: const Icon(Icons.save, size: 18, color: Color(0xFF17A18A)),
            label: Text('Simpan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Color(0xFF17A18A))),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF114177),
          unselectedLabelColor: const Color(0xFF76777B),
          indicatorColor: const Color(0xFF114177),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Model Config'),
            Tab(text: 'System Prompt'),
            Tab(text: 'Intent Schema'),
            Tab(text: 'Fallback Rules'),
            Tab(text: 'Testing'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(padding: const EdgeInsets.only(bottom: 24), child: _buildModelConfig()),
          _buildSystemPromptTab(),
          _buildIntentSchemaTab(),
          _buildFallbackRulesTab(),
          _buildTestingTab(),
          _buildAnalyticsTab(),
        ],
      ),
    ));
  }
}