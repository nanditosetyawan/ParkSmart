import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 5;
  final Set<String> _selectedTopics = {'Akurasi Sensor ANPR'};
  final Set<String> _selectedAppreciations = {'Slot Sesuai Aplikasi'};
  final TextEditingController _feedbackController = TextEditingController();

  final List<String> _topics = ['Akurasi Sensor ANPR', 'Kemudahan Gate', 'Ketersediaan Slot', 'Tarif & Pembayaran', 'Lainnya'];
  final List<String> _appreciations = ['Palang Cepat Terbuka', 'Slot Sesuai Aplikasi', 'Peta Jelas'];

  String get _ratingLabel {
    switch (_rating) {
      case 1: return 'Perlu Perbaikan (1/5)';
      case 2: return 'Cukup (2/5)';
      case 3: return 'Baik (3/5)';
      case 4: return 'Sangat Baik (4/5)';
      case 5: return 'Sangat Puas (5/5)';
      default: return 'Sangat Puas (5/5)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFCF9F2).withValues(alpha: 0.8),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 1))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44, height: 44,
                          decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1C1C18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Ulasan', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBN229OME29oeIA03JEkx6qFXdwAiS9tjF2BpuYl0hvR-KRhMbz_TvFM6WCf8r3FfXONbNsAuRJAFymMuLXfHc9_GTa3l48rS4pmj3LFXkDTJQw34ftZgSowlpEj41hbbTvfBKg3P2JHB5MfmHQNghgDyk3ewQpsqLqxRHecKK3Y9QxSY1Og5axl9wsXmXNuN4ylTP0yU_d0SB-yYJ_riMPPALuIk5G7brwi5Pkb555Yu3zsk6gd9w-'),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFDBD2).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco, size: 14, color: Color(0xFF9A442D)),
                        const SizedBox(width: 6),
                        Text('PARKIR PRESISI', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF3C0800))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Bagaimana Pengalaman\nParkir Anda?', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), height: 1.2, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text('Bantu kami meningkatkan akurasi sensor dan kenyamanan reservasi Anda.', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                  const SizedBox(height: 24),
                  
                  // Rating Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))]),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TINGKAT KEPUASAN', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                            Text(_ratingLabel, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            int starVal = index + 1;
                            bool isSelected = starVal <= _rating;
                            return GestureDetector(
                              onTap: () => setState(() => _rating = starVal),
                              child: Container(
                                width: 48, height: 48,
                                alignment: Alignment.center,
                                child: Icon(Icons.star, size: 40, color: isSelected ? Colors.amber : const Color(0xFFE5E2DB)),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text('Ketuk bintang untuk mengubah penilaian', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Topics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Topik Masukan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                      Text('Pilih satu atau lebih', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _topics.map((topic) {
                      bool isSelected = _selectedTopics.contains(topic);
                      return GestureDetector(
                        onTap: () => setState(() {
                          isSelected ? _selectedTopics.remove(topic) : _selectedTopics.add(topic);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(color: isSelected ? const Color(0xFF020304) : Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))]),
                          child: Text(topic, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF1C1C18))),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  
                  
                  
                  
                  // Location Pill
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                    child: Row(
                      children: [
                        Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFE5E2DB), shape: BoxShape.circle), child: const Icon(Icons.local_parking, size: 20, color: Color(0xFF45474A))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Area Parkir B2 - Grand Indonesia', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18))),
                              Text('Sesi hari ini • Slot B2-41', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
                            ],
                          ),
                        ),
                        const Icon(Icons.check, size: 18, color: Color(0xFF76777B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity, height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Show modal mock
                        showDialog(context: context, builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          backgroundColor: Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFBBEED4), shape: BoxShape.circle), child: const Icon(Icons.favorite, size: 32, color: Color(0xFF1F4F3C))),
                              const SizedBox(height: 16),
                              Text('Terima Kasih Banyak!', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                              const SizedBox(height: 8),
                              Text('Masukan berharga Anda telah tersimpan dan membantu pengguna lain menikmati parkir yang lebih mudah.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity, height: 48,
                                child: ElevatedButton(
                                  onPressed: () { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false); },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF020304), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                                  child: Text('Selesai', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF020304), foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 8, shadowColor: const Color(0xFF020304).withValues(alpha: 0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Kirim Masukan', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
