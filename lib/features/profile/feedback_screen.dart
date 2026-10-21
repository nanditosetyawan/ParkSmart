import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../home/home_screen.dart';
import 'backend/feedback_backend.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 5;
  final Set<String> _selectedTopics = {'Akurasi Sensor ANPR'};
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  final List<String> _topics = [
    'Akurasi Sensor ANPR',
    'Kemudahan Gate',
    'Ketersediaan Slot',
    'Tarif & Pembayaran',
    'Lainnya',
  ];

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Perlu Perbaikan (1/5)';
      case 2:
        return 'Cukup (2/5)';
      case 3:
        return 'Baik (3/5)';
      case 4:
        return 'Sangat Baik (4/5)';
      case 5:
        return 'Sangat Puas (5/5)';
      default:
        return 'Sangat Puas (5/5)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: (isDark ? theme.bg : const Color(0xFFFCF9F2)).withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF181C22) : const Color(0xFFF1EEE7),
                                shape: BoxShape.circle,
                                border: isDark ? Border.all(color: const Color(0xFF2D3542)) : null,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: isDark ? Colors.white : const Color(0xFF1C1C18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ulasan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1C1C18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Badge Parkir Presisi
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3B1E1E)
                                  : const Color(0xFFFFDBD2).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.eco,
                                  size: 14,
                                  color: isDark ? const Color(0xFFFB923C) : const Color(0xFF9A442D),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'PARKIR PRESISI',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFED7AA) : const Color(0xFF3C0800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bagaimana Pengalaman\nParkir Anda?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bantu kami meningkatkan akurasi sensor dan kenyamanan reservasi Anda.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Rating Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF181C22) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: isDark ? Border.all(color: const Color(0xFF2D3542)) : null,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C1D1F).withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TINGKAT KEPUASAN',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                                  ),
                                ),
                                Text(
                                  _ratingLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFB923C) : const Color(0xFF9A442D),
                                  ),
                                ),
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
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.star,
                                      size: 40,
                                      color: isSelected
                                          ? Colors.amber
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E2DB)),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ketuk bintang untuk mengubah penilaian',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Topics Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Topik Masukan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1C1C18),
                            ),
                          ),
                          Text(
                            'Pilih satu atau lebih',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Topic Chips (sesuai pola: selected hitam->putih teks hitam di dark mode)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _topics.map((topic) {
                          bool isSelected = _selectedTopics.contains(topic);
                          return GestureDetector(
                            onTap: () => setState(() {
                              isSelected ? _selectedTopics.remove(topic) : _selectedTopics.add(topic);
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF020304))
                                    : (isDark ? const Color(0xFF181C22) : Colors.white),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? Colors.white : const Color(0xFF020304))
                                      : (isDark ? const Color(0xFF2D3542) : Colors.transparent),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1C1D1F).withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                topic,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF020304) : Colors.white)
                                      : (isDark ? Colors.white : const Color(0xFF1C1C18)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Location Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF181C22) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF262C36) : const Color(0xFFE5E2DB),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_parking,
                                size: 20,
                                color: isDark ? Colors.white : const Color(0xFF45474A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Area Parkir B2 - Grand Indonesia',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                    ),
                                  ),
                                  Text(
                                    'Sesi hari ini • Slot B2-41',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check,
                              size: 18,
                              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF76777B),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Input Catatan / Komentar Pengguna
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF181C22) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                          ),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: 3,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF1C1C18),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tuliskan ulasan atau masukan detail Anda di sini...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button (sesuai pola: tombol hitam jadi putih teks hitam di dark mode)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  setState(() => _isSubmitting = true);
                                  await FeedbackBackend.instance.submitFeedback(
                                    rating: _rating,
                                    comment: _commentController.text,
                                    selectedTopics: _selectedTopics.toList(),
                                  );
                                  if (!mounted || !context.mounted) return;
                                  setState(() => _isSubmitting = false);

                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black.withValues(alpha: 0.65),
                                    builder: (dialogCtx) => ListenableBuilder(
                                listenable: ThemeService.instance,
                                builder: (context, _) {
                                  final dlgTheme = ThemeService.instance;
                                  final dlgIsDark = dlgTheme.isDarkMode;

                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                      side: BorderSide(
                                        color: dlgIsDark ? const Color(0xFF2D3542) : Colors.transparent,
                                      ),
                                    ),
                                    backgroundColor: dlgIsDark ? const Color(0xFF181C22) : Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: dlgIsDark ? const Color(0xFF064E3B) : const Color(0xFFBBEED4),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.favorite,
                                            size: 32,
                                            color: dlgIsDark ? const Color(0xFF34D399) : const Color(0xFF1F4F3C),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          'Terima Kasih Banyak!',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: dlgIsDark ? Colors.white : const Color(0xFF1C1D1F),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Masukan berharga Anda telah tersimpan dan membantu pengguna lain menikmati parkir yang lebih mudah.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            height: 1.45,
                                            color: dlgIsDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                                (route) => false,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: dlgIsDark ? Colors.white : const Color(0xFF020304),
                                              foregroundColor: dlgIsDark ? Colors.black : Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                              elevation: dlgIsDark ? 0 : 4,
                                            ),
                                            child: Text(
                                              'Selesai',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: dlgIsDark ? Colors.black : Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : const Color(0xFF020304),
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            elevation: isDark ? 0 : 8,
                            shadowColor: const Color(0xFF020304).withValues(alpha: 0.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kirim Masukan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: isDark ? Colors.black : Colors.white,
                              ),
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
      },
    );
  }
}
