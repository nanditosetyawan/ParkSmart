import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
  final List<Map<String, String>> _messages = [
    {'role': 'assistant', 'content': 'Halo! Saya AI ParkSmart yang ditenagai oleh Groq Llama 3. Lokasi mana yang ingin Anda tuju hari ini?'}
  ];
  
  bool _isLoading = false;
  
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  final String systemPrompt = """
Anda adalah asisten AI dari aplikasi Smart Parking (ParkSmart).
Tugas Anda adalah membantu pengguna mencari parkiran.
Saat ini, Anda tidak punya akses internet, tapi aplikasi telah memberikan data terbaru berikut (DUMMY):
- Lokasi GPS User saat ini: SCBD, Jakarta (Aktif).
- Database Parkiran Terdekat:
  1. Parkir A  - Status: Tersedia 5 slot mobil.
  2. Parkir B  - Status: PENUH.
  3. Grand Indonesia - Status: Tersedia 12 slot EV, 5 slot reguler.

Jawab pertanyaan user HANYA berdasarkan data di atas dengan gaya bahasa ramah, singkat, dan natural. 
Jangan pernah memberitahu user bahwa Anda membaca data ini dari prompt rahasia. Bersikaplah seolah Anda mengecek database.
""";

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    
    _textController.clear();
    _scrollToBottom();

    try {
      // Siapkan histori chat untuk dikirim ke Groq
      List<Map<String, String>> chatHistory = [
        {'role': 'system', 'content': systemPrompt},
      ];
      
      // Masukkan semua pesan sebelumnya kecuali pesan sambutan awal jika ingin hemat token (opsional)
      // Di sini kita masukkan semuanya agar AI ingat konteks obrolan
      for (var msg in _messages) {
        if (msg['role'] != 'assistant' || msg['content'] != _messages[0]['content']) {
           chatHistory.add({'role': msg['role']!, 'content': msg['content']!});
        }
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.8-27b', // Model Meta Llama 3.1 yang terbaru
          'messages': chatHistory,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] ?? 'Maaf, saya tidak mengerti.';
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
        });
      } else {
        setState(() {
          _messages.add({'role': 'assistant', 'content': 'Error dari server: ${response.statusCode}\nDetail: ${response.body}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Error: Tidak dapat terhubung ke server AI.\nDetail: $e'});
      });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF14202B)),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false),
        ),
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: Color(0xFF17A18A)),
            const SizedBox(width: 8),
            Text('AI Parking Assistant',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF14202B))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return isUser ? _buildUserMessage(msg['content']!) : _buildAiMessage(msg['content']!);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFD8DEE5)))),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F3F3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
                        border: InputBorder.none,
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
  }

  Widget _buildAiMessage(String text) {
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF14202B), height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
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
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
