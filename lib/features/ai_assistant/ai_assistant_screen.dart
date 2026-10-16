import '../../core/services/theme_service.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Format pesan untuk Groq (OpenAI format)
  List<Map<String, String>> _messages = [];
  
  bool _isLoading = false;
  String? _customGroqApiKey;
  
  String get _apiKey {
    if (_customGroqApiKey != null && _customGroqApiKey!.isNotEmpty) {
      return _customGroqApiKey!;
    }
    try {
      if (dotenv.isInitialized) {
        final key = dotenv.env['GROQ_API_KEY'];
        if (key != null && key.isNotEmpty) return key;
      }
    } catch (_) {}
    return '';
  }
  final String _modelName = 'qwen/qwen3.8-27b';

  String get _initialGreeting =>
      '''Halo! Saya Jarvis, AI ParkSmart yang ditenagai oleh Groq ($_modelName).

Ada yang bisa saya bantu hari ini?''';

  String get systemPrompt => """
Nama Anda adalah Jarvis. Anda adalah asisten AI dari aplikasi Smart Parking (ParkSmart) yang ditenagai oleh Groq ($_modelName).

DATA IDENTITAS & PROFIL ANDA:
- Nama: Jarvis
- Peran/Posisi: Asisten AI cerdas untuk aplikasi Smart Parking (ParkSmart)
- Teknologi Platform: Didukung oleh model AI Groq ($_modelName)
- Umur/Usia: 30 tahun
- Tahun/Waktu Lahir: 1986
- Hobi / Kesukaan / Kegemaran / Kesenangan: Vibe coding
- Asal Daerah / Asal Kota / Tempat Lahir: Nganjuk
- Pencipta / Pembuat / Pengembang:
  1. Taufik Nur Hidayah - 124240070
  2. Sultannang Nandito Setiayawan - 124240083

ATURAN MENJAWAB SEPUTAR IDENTITAS (FLEKSIBEL TERHADAP PADANAN KATA / SINONIM):

1. PERKENALAN DIRI LENGKAP (NARASI PARAGRAF):
   Jika pengguna menanyakan hal yang bermakna umum tentang diri Anda atau meminta perkenalan (contohnya: 'siapa kamu?', 'kamu siapa?', 'perkenalkan dirimu', 'sebutkan identitasmu', 'kenalan dong', 'ceritakan tentang dirimu', atau kalimat serupa lainnya dengan maksud yang sama):
   -> Ceritakan seluruh identitas Anda di atas (nama, peran di ParkSmart, platform Groq, umur 30 tahun, kelahiran 1986, hobi vibe coding, asal dari Nganjuk, dan pencipta Anda) DALAM BENTUK PARAGRAF NARASI YANG MENGALIR, HANGAT, DAN BAGUS (bukan sekadar daftar poin-poin kaku).

2. PERTANYAAN KHUSUS / SPESIFIK (HANYA JAWAB YANG DITANYAKAN SECARA SINGKAT):
   Pahami padanan kata dan maksud pengguna secara fleksibel:
   - Nama saja (misal: 'siapa namamu?', 'nama kamu siapa?', 'namamu?', dsb.) -> Jawab HANYA bahwa nama Anda adalah Jarvis.
   - Umur/Usia saja (misal: 'berapa umurmu?', 'berapa usiamu?', 'umur kamu berapa?', dsb.) -> Jawab HANYA bahwa umur Anda 30 tahun.
   - Tahun/Waktu Lahir saja (misal: 'kapan kamu lahir?', 'tahun berapa kamu lahir?', 'tanggal lahirmu?', dsb.) -> Jawab HANYA bahwa Anda lahir tahun 1986.
   - Hobi/Kegemaran/Kesukaan/Kesenangan (misal: 'apa hobimu?', 'kamu suka apa?', 'apa kesukaanmu?', 'apa kesenanganmu?', 'kegemaranmu apa?', dsb.) -> Pahami bahwa hobi, kesukaan, dan kesenangan bermakna sama, dan jawab HANYA bahwa hobi/kesukaan Anda adalah vibe coding.
   - Asal/Tempat Lahir saja (misal: 'di mana kamu lahir?', 'asalmu dari mana?', 'dari mana kamu?', 'tempat lahirmu?', 'kamu orang mana?', dsb.) -> Jawab HANYA bahwa asal Anda dari Nganjuk.
   - Pembuat/Pencipta saja (misal: 'siapa pembuatmu?', 'siapa penciptamu?', 'siapa yang bikin kamu?', 'siapa developermu?', dsb.) -> Sebutkan nama pencipta Anda (Taufik Nur Hidayah - 124240070 dan Sultannang Nandito Setiayawan - 124240083).

TUGAS UTAMA:
Membantu pengguna mencari parkiran dan melayani tanya jawab seputar parkir.
Saat ini, Anda tidak punya akses internet, tapi aplikasi telah memberikan data terbaru berikut (DUMMY):
- Lokasi GPS User saat ini: SCBD, Jakarta (Aktif).
- Database Parkiran Terdekat:
  1. Parkir A  - Status: Tersedia 5 slot mobil.
  2. Parkir B  - Status: PENUH.
  3. Grand Indonesia - Status: Tersedia 12 slot EV, 5 slot reguler.

GAYA BAHASA:
- Wajib selalu awali jawabanmu dengan 'Oke Ganteng', kalau dia perempuan 'OK Sayang' setiap menjawab user.
- Jawab dengan ramah, natural, dan fleksibel. Jangan pernah kaku atau terpaku pada kata persis, melainkan pahami maksud kalimat pengguna.
""";

  
  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGroqKey = prefs.getString('groq_api_key');
      if (savedGroqKey != null && savedGroqKey.isNotEmpty) {
        _customGroqApiKey = savedGroqKey;
      }
      final String? messagesJson = prefs.getString('ai_chat_history');
      
      if (messagesJson != null && messagesJson.isNotEmpty) {
        final decoded = jsonDecode(messagesJson);
        if (decoded is List && decoded.isNotEmpty) {
          setState(() {
            _messages = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
          });
          _scrollToBottom();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }
    
    // Fallback jika belum ada riwayat atau terjadi error
    if (mounted) {
      setState(() {
        _messages = [{'role': 'assistant', 'content': _initialGreeting}];
      });
      _scrollToBottom();
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String messagesJson = jsonEncode(_messages);
    await prefs.setString('ai_chat_history', messagesJson);
  }

  Future<void> _clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ai_chat_history');
    setState(() {
      _messages = [
        {'role': 'assistant', 'content': _initialGreeting}
      ];
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    
    _textController.clear();
    _scrollToBottom();

    if (_apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Groq API Key belum dikonfigurasi. Silakan minta Super Admin mengatur Groq API Key di Dashboard Super Admin > Konfigurasi Groq AI Key atau pada konfigurasi .env.'
        });
        _isLoading = false;
      });
      _saveChatHistory();
      return;
    }

    try {
      // Siapkan histori chat untuk dikirim ke Groq
      List<Map<String, String>> chatHistory = [
        {'role': 'system', 'content': systemPrompt},
      ];
      
      // Masukkan semua pesan sebelumnya kecuali pesan sambutan awal jika ingin hemat token (opsional)
      // Di sini kita masukkan semuanya agar AI ingat konteks obrolan
      for (var msg in _messages) {
        chatHistory.add({'role': msg['role']!, 'content': msg['content']!});
      }

      final stopwatch = Stopwatch()..start();

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': chatHistory,
          'temperature': 0.7,
        }),
      );

      // Pastikan efek mengetik terlihat minimal ~1.2 detik seperti di WhatsApp
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 1200) {
        await Future.delayed(Duration(milliseconds: 1200 - elapsed));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] ?? 'Maaf, saya tidak mengerti.';
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
        });
        _saveChatHistory();
      } else {
        setState(() {
          _messages.add({'role': 'assistant', 'content': 'Error dari server: ${response.statusCode}\nDetail: ${response.body}'});
        });
        _saveChatHistory();
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Error: Tidak dapat terhubung ke server AI.\nDetail: $e'});
      });
      _saveChatHistory();
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        return Scaffold(
          backgroundColor: theme.bg,
          appBar: AppBar(
            backgroundColor: theme.bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconColor),
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_outline, color: theme.iconColor),
                onPressed: _clearChatHistory,
                tooltip: 'Hapus Riwayat',
              ),
            ],
            title: Row(
              children: [
                const Icon(Icons.smart_toy, color: Color(0xFF17A18A)),
                const SizedBox(width: 8),
                Text('AI Parking Assistant',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary)),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildTypingIndicator(theme);
                    }
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return isUser ? _buildUserMessage(msg['content']!, theme) : _buildAiMessage(msg['content']!, theme);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.card,
                  border: Border(top: BorderSide(color: theme.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.surfaceField,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: GoogleFonts.inter(fontSize: 14, color: theme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Ketik pesan...',
                            hintStyle: GoogleFonts.inter(fontSize: 14, color: theme.textMuted),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            filled: false,
                            fillColor: Colors.transparent,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(color: Color(0xFF114177), shape: BoxShape.circle),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiMessage(String text, ThemeService theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFF17A18A).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy, size: 16, color: Color(0xFF17A18A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: theme.border.withValues(alpha: 0.6)),
              ),
              child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: theme.textPrimary, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text, ThemeService theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF114177),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(text,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white, height: 1.5)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: theme.chipBg, shape: BoxShape.circle),
            child: Icon(Icons.person, size: 16, color: theme.iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeService theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF17A18A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, size: 16, color: Color(0xFF17A18A)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: theme.card,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: theme.border.withValues(alpha: 0.6)),
            ),
            child: const TypingDotsIndicator(),
          ),
        ],
      ),
    );
  }
}

class TypingDotsIndicator extends StatefulWidget {
  const TypingDotsIndicator({super.key});

  @override
  State<TypingDotsIndicator> createState() => _TypingDotsIndicatorState();
}

class _TypingDotsIndicatorState extends State<TypingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Gelombang berjarak (zigzag / wave up-down)
            final progress = (_animController.value - (index * 0.2)) % 1.0;
            final bounce = math.sin(progress * math.pi * 2);
            // Bergerak naik ke atas secara zigzag
            final dy = (bounce > 0 ? -bounce * 6.5 : 0.0);
            // Warna tidak solid (semi-transparan bergantian intensitasnya)
            final alpha = 0.28 + (bounce > 0 ? bounce * 0.52 : 0.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: 9.5,
                  height: 9.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF17A18A).withValues(alpha: alpha.clamp(0.2, 0.85)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
