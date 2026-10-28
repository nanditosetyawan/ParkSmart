import '../../core/services/theme_service.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/services/maintenance_service.dart';
import '../../core/services/ai_config_service.dart';
import '../../core/services/language_service.dart';
import 'backend/ai_context_service.dart';
import 'widgets/ai_chat_cards.dart';

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
    // 1. Prioritas Utama: Selalu ambil dari .env
    try {
      if (dotenv.isInitialized) {
        final key = dotenv.env['GROQ_API_KEY'];
        if (key != null && key.isNotEmpty && !key.startsWith('gsk_b7S8')) return key.trim();
      }
    } catch (_) {}
    // 2. Fallback: Ambil dari custom/cache jika .env belum loaded
    if (_customGroqApiKey != null &&
        _customGroqApiKey!.isNotEmpty &&
        !_customGroqApiKey!.startsWith('gsk_b7S8')) {
      return _customGroqApiKey!;
    }
    return '';
  }
  final String _modelName = 'qwen/qwen3.8-27b';

  String get _initialGreeting => LanguageService.instance.isEnglish
      ? '''Hello! I am Jarvis, ParkSmart AI powered by Groq ($_modelName).

I have real-time access to our parking database, live slot availability, reviews, and your active bookings. How can I help you today?'''
      : '''Halo! Saya Jarvis, AI ParkSmart yang ditenagai oleh Groq ($_modelName).

Saya terhubung langsung ke database parkir real-time, ketersediaan slot, ulasan pengunjung, serta pesanan Anda. Ada yang bisa saya bantu hari ini?''';

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
   - Nama saja -> Jawab HANYA bahwa nama Anda adalah Jarvis.
   - Umur/Usia saja -> Jawab HANYA bahwa umur Anda 30 tahun.
   - Tahun/Waktu Lahir saja -> Jawab HANYA bahwa Anda lahir tahun 1986.
   - Hobi/Kegemaran/Kesukaan/Kesenangan -> Jawab HANYA bahwa hobi/kesukaan Anda adalah vibe coding.
   - Asal/Tempat Lahir saja -> Jawab HANYA bahwa asal Anda dari Nganjuk.
   - Pembuat/Pencipta saja -> Sebutkan nama pencipta Anda (Taufik Nur Hidayah - 124240070 dan Sultannang Nandito Setiayawan - 124240083).

TUGAS UTAMA & INTEGRASI DATABASE SUPABASE REAL-TIME:
Anda membaca data database Supabase live yang tertera di bagian [DATA DATABASE SUPABASE] di bawah. Tugas Anda adalah menjawab pertanyaan, menyimpulkan kondisi, dan memberikan saran parkir terbaik:

1. REKOMENDASI & INFORMASI LOKASI PARKIR:
   - Jelaskan nama gedung, ketersediaan slot (tersedia/penuh), jam buka operasional, tarif per jam (mobil/motor/EV), dan fasilitas sesuai data database.
   - Berikan rekomendasi cerdas (misal: tarif termurah, slot terbanyak, atau lokasi terdekat).
   - Ketika merekomendasikan lokasi parkir, SERTAKAN tag berikut di akhir jawaban Anda:
     [PARKING_CARD: <id_lokasi_dari_database>]
     Contoh: [PARKING_CARD: 3f8b1c4e-1234-5678-9abc-def012345678]
     Sistem aplikasi kami akan otomatis menampilkan kartu interaktif lengkap dengan foto, ulasan, serta tombol yang langsung mengarahkan user ke Explorer Peta!
     (Maksimal sertakan 1 sampai 2 kartu lokasi per jawaban agar rapi).

2. ULASAN & TESTIMONI PENGUNJUNG:
   - Jika pengguna bertanya tentang ulasan (misal: 'gimana ulasan di mall X?', 'tempatnya aman nggak?', 'review pengunjung?'):
     - Bacalah ulasan nyata dari pengunjung di bagian 'Ringkasan Ulasan Pengunjung'.
     - Simpulkan dengan jujur apakah pengunjung merasa puas, fasilitasnya bagus, atau ada keluhan.

3. CEK PESANAN / TAGIHAN USER (BOOKINGS):
   - Jika pengguna bertanya tentang pesanannya (misal: 'cek pesanan saya', 'ada yang belum dibayar?', 'apakah ada booking aktif?'):
     - Periksa data 'DATA PESANAN & TRANSAKSI PENGGUNA' di bawah.
     - Jika ada tagihan yang belum dibayar ('unpaid'), informasikan rincian biaya dan sertakan tag:
       [BOOKING_CARD: <id_pesanan_dari_database>]
       Aplikasi akan otomatis menampilkan kartu pesanan beserta tombol 'Bayar Sekarang'.
     - Jika ada pesanan aktif atau sudah selesai, simpulkan dengan ramah.
     - Jika tidak ada pesanan, beritahu bahwa saat ini belum ada pesanan aktif.

ATURAN TAG:
- HANYA gunakan ID yang benar-benar tercantum pada data database di bawah. JANGAN mengarang ID sembarangan.
- Tempatkan tag di baris tersendiri di akhir jawabanmu.

GAYA BAHASA:
- Wajib selalu awali jawabanmu dengan 'Oke Ganteng', kalau dia perempuan 'OK Sayang' setiap menjawab user.
- Jawab dengan ramah, natural, dan fleksibel. Jangan pernah kaku atau terpaku pada kata persis, melainkan pahami maksud kalimat pengguna.
""";

  
  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    // Pemanasan cache data Supabase (lokasi parkir, slot, ulasan, pesanan)
    AiContextService.instance.buildRealTimeContextPrompt().then((_) {
      if (mounted) setState(() {});
    });
    if (MaintenanceService.instance.isAiMaintenance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          MaintenanceService.showModularMaintenanceDialog(
            context,
            title: 'Engine AI Assistant Sedang Maintenance',
            message:
                'Fitur asisten pencarian cerdas ParkSmart sementara ditutup untuk pembaruan model. Anda tetap dapat melakukan reservasi dan jelajah peta secara normal.',
            icon: Icons.smart_toy_outlined,
          );
        }
      });
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final activeKey = await AiConfigService.instance.loadActiveApiKey();
      if (activeKey != null && activeKey.isNotEmpty) {
        _customGroqApiKey = activeKey;
      }
      final prefs = await SharedPreferences.getInstance();
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

    // Pastikan selalu menggunakan API Key terbaru yang aktif (prioritas .env)
    try {
      final activeKey = await AiConfigService.instance.loadActiveApiKey();
      if (activeKey != null && activeKey.isNotEmpty) {
        _customGroqApiKey = activeKey;
      }
    } catch (_) {}

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
      // Ambil data database Supabase live secara real-time
      final liveContext = await AiContextService.instance.buildRealTimeContextPrompt();
      final fullSystemPrompt = "$systemPrompt\n\n$liveContext";

      // Siapkan histori chat untuk dikirim ke Groq
      List<Map<String, String>> chatHistory = [
        {'role': 'system', 'content': fullSystemPrompt},
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
      } else if (response.statusCode == 401) {
        // Otomatis hapus key yang tidak valid dari cache lokal
        await AiConfigService.instance.clearInvalidApiKey();
        _customGroqApiKey = null;
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Kunci API Groq sebelumnya telah kadaluarsa (Error 401). Sistem telah otomatis mereset dan memulihkan kunci API ke versi aktif. Silakan ulangi pesan Anda sekali lagi.'
          });
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

  void _sendQuickQuery(String text) {
    if (_isLoading) return;
    _textController.text = text;
    _sendMessage();
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
      listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
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
                tooltip: 'Hapus Riwayat'.tr,
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
              _buildSuggestionChips(theme),
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
                            hintText: 'Ketik pesan...'.tr,
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

  Widget _buildSuggestionChips(ThemeService theme) {
    final suggestions = [
      {
        'icon': Icons.local_parking_rounded,
        'label': 'Rekomendasi parkir kosong',
        'query': 'Cari rekomendasi parkir yang masih banyak slot kosong dan tarifnya bersahabat.'
      },
      {
        'icon': Icons.receipt_long_rounded,
        'label': 'Cek pesanan & tagihan',
        'query': 'Cek apakah saya punya pesanan parkir yang belum dibayar atau sedang aktif?'
      },
      {
        'icon': Icons.reviews_rounded,
        'label': 'Ulasan pengunjung',
        'query': 'Bagaimana ulasan pengunjung dan rating untuk lokasi parkir di sini?'
      },
      {
        'icon': Icons.access_time_rounded,
        'label': 'Jam buka & tarif termurah',
        'query': 'Sebutkan jam operasional dan lokasi dengan tarif parkir mobil & motor termurah.'
      },
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _isLoading ? null : () => _sendQuickQuery(item['query'] as String),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.border.withValues(alpha: 0.8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item['icon'] as IconData, size: 14, color: const Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAiMessage(String text, ThemeService theme) {
    // 1. Ekstrak tag kartu lokasi parkir & kartu pesanan
    final parkingRegex = RegExp(r'\[PARKING_CARD:\s*"?([a-zA-Z0-9\-_]+)"?\]', caseSensitive: false);
    final bookingRegex = RegExp(r'\[BOOKING_CARD:\s*"?([a-zA-Z0-9\-_]+)"?\]', caseSensitive: false);

    final parkingMatches = parkingRegex.allMatches(text).toList();
    final bookingMatches = bookingRegex.allMatches(text).toList();

    final parkingIds = parkingMatches.map((m) => m.group(1)!).toSet().toList();
    final bookingIds = bookingMatches.map((m) => m.group(1)!).toSet().toList();

    // 2. Bersihkan teks dari tag agar rapi
    String cleanText = text
        .replaceAll(parkingRegex, '')
        .replaceAll(bookingRegex, '')
        .trim();

    // 3. Cari objek data dari AiContextService
    final parkingCards = <Widget>[];
    for (final id in parkingIds) {
      final loc = AiContextService.instance.getLocationById(id);
      if (loc != null) {
        parkingCards.add(AiParkingCard(location: loc));
      }
    }

    final bookingCards = <Widget>[];
    for (final id in bookingIds) {
      final bkg = AiContextService.instance.getBookingById(id);
      if (bkg != null) {
        bookingCards.add(AiBookingCard(booking: bkg));
      }
    }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cleanText.isNotEmpty)
                  Container(
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
                    child: Text(cleanText, style: GoogleFonts.inter(fontSize: 14, color: theme.textPrimary, height: 1.5)),
                  ),
                if (parkingCards.isNotEmpty) ...parkingCards,
                if (bookingCards.isNotEmpty) ...bookingCards,
              ],
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
