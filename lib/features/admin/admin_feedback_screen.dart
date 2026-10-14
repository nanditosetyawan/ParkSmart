import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackAdminScreen extends StatefulWidget {
  const FeedbackAdminScreen({super.key});

  @override
  State<FeedbackAdminScreen> createState() => _FeedbackAdminScreenState();
}

class _FeedbackAdminScreenState extends State<FeedbackAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0; // 0=Semua, 1=Bintang 5, 2=Bintang 4, 3=Keluhan

  final List<Map<String, dynamic>> _feedbacks = [
    {
      'id': 'FDB-001',
      'user': 'Rafi Maulana',
      'avatar': 'R',
      'rating': 5,
      'location': 'Central Park Mall (B2)',
      'date': 'Hari ini, 11:20',
      'comment': 'Sensor gate dan QR ticket sangat cepat! Tidak perlu antre lama di pos keluar.',
      'adminReply': 'Terima kasih atas apresiasinya Kak Rafi! Kami terus berupaya menjaga kecepatan sistem.',
      'isResolved': true,
    },
    {
      'id': 'FDB-002',
      'user': 'Hana Aulia',
      'avatar': 'H',
      'rating': 2,
      'location': 'Grand Indonesia',
      'date': 'Kemarin, 19:45',
      'comment': 'Marka slot nomor C-05 agak pudar jadi sempat salah parkir di slot booking orang lain.',
      'adminReply': null,
      'isResolved': false,
    },
    {
      'id': 'FDB-003',
      'user': 'Budi Santoso',
      'avatar': 'B',
      'rating': 4,
      'location': 'Malioboro Mall',
      'date': '2 hari lalu',
      'comment': 'Fitur perpanjang timer tiket parkir sangat membantu pas lagi meeting mendadak.',
      'adminReply': 'Senang mendengar fitur extend timer bermanfaat untuk Kak Budi!',
      'isResolved': true,
    },
    {
      'id': 'FDB-004',
      'user': 'Dewi Lestari',
      'avatar': 'D',
      'rating': 5,
      'location': 'Pacific Place SCBD',
      'date': '3 hari lalu',
      'comment': 'Slot EV Fast Charger berfungsi sangat baik, daya masuk stabil 22 kW.',
      'adminReply': null,
      'isResolved': true,
    },
    {
      'id': 'FDB-005',
      'user': 'Joko Widarto',
      'avatar': 'J',
      'rating': 1,
      'location': 'Central Park Mall',
      'date': '1 minggu lalu',
      'comment': 'Barrier gate sempat macet 5 menit sebelum sensor terbuka otomatis.',
      'adminReply': 'Mohon maaf atas kendalanya. Kami telah melakukan kompensasi saldo dompet Rp 50.000 ke akun Bapak.',
      'isResolved': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFeedbacks {
    return _feedbacks.where((f) {
      final q = _searchController.text.toLowerCase();
      final matchesSearch = f['user'].toString().toLowerCase().contains(q) ||
          f['comment'].toString().toLowerCase().contains(q) ||
          f['location'].toString().toLowerCase().contains(q);

      if (!matchesSearch) return false;

      if (_selectedFilter == 1) return f['rating'] == 5;
      if (_selectedFilter == 2) return f['rating'] == 4;
      if (_selectedFilter == 3) return (f['rating'] as int) <= 3;
      return true;
    }).toList();
  }

  void _showReplyDialog(Map<String, dynamic> feedback) {
    final replyCtrl = TextEditingController(text: feedback['adminReply'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text('Balas Ulasan Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengguna: ${feedback['user']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
            const SizedBox(height: 4),
            Text('"${feedback['comment']}"', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontStyle: FontStyle.italic, color: const Color(0xFF76777B))),
            const SizedBox(height: 14),
            TextField(
              controller: replyCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis tanggapan atau solusi admin...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyCtrl.text.isNotEmpty) {
                setState(() {
                  feedback['adminReply'] = replyCtrl.text;
                  feedback['isResolved'] = true;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Balasan admin berhasil dikirim!'), backgroundColor: Color(0xFF17A18A)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF114177),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Kirim Balasan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unresolvedCount = _feedbacks.where((f) => f['isResolved'] == false).length;

    return Scaffold(
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
            Text('Feedback & Ulasan', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Suara Pengguna & Penanganan Keluhan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stat overview
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatCard('Skor Kepuasan', '4.8 ★', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                    const SizedBox(width: 10),
                    _buildStatCard('Total Ulasan', '${_feedbacks.length}', const Color(0xFF114177), const Color(0xFFE3EEFF)),
                    const SizedBox(width: 10),
                    _buildStatCard('Perlu Ditindak', '$unresolvedCount', const Color(0xFFD94B4B), const Color(0xFFFDE8E4)),
                  ],
                ),
                const SizedBox(height: 14),

                // Search box
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: Color(0xFF76777B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                          decoration: InputDecoration(
                            hintText: 'Cari ulasan, nama user, lokasi...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rating filter chips
          Container(
            height: 48,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                _buildFilterChip('Semua (${_feedbacks.length})', 0),
                const SizedBox(width: 8),
                _buildFilterChip('5 Bintang ★', 1),
                const SizedBox(width: 8),
                _buildFilterChip('4 Bintang ★', 2),
                const SizedBox(width: 8),
                _buildFilterChip('Keluhan (≤ 3★)', 3, isWarning: true),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE4DFD5)),

          // Feedbacks List
          Expanded(
            child: _filteredFeedbacks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rate_review_outlined, size: 48, color: Color(0xFF76777B)),
                        const SizedBox(height: 12),
                        Text('Tidak ada ulasan yang cocok', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredFeedbacks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = _filteredFeedbacks[index];
                      final int rating = item['rating'] as int;
                      final bool isResolved = item['isResolved'] as bool;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: !isResolved ? const Color(0xFFF9D8D3) : const Color(0xFFE4DFD5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFF1EEE7),
                                  child: Text(item['avatar'], style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['user'], style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                                      Text('${item['location']} · ${item['date']}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (starIdx) {
                                    return Icon(
                                      starIdx < rating ? Icons.star : Icons.star_border,
                                      size: 16,
                                      color: starIdx < rating ? const Color(0xFFE5A33D) : const Color(0xFFE4DFD5),
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['comment'],
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18), height: 1.4),
                            ),
                            if (item['adminReply'] != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EEE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.admin_panel_settings, size: 14, color: Color(0xFF114177)),
                                        const SizedBox(width: 6),
                                        Text('Tanggapan Admin ParkSmart:', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['adminReply'],
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isResolved ? const Color(0xFFD1F2EB) : const Color(0xFFFDE8E4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isResolved ? 'Selesai' : 'Belum Dibalas',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: isResolved ? const Color(0xFF17A18A) : const Color(0xFFD94B4B)),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showReplyDialog(item),
                                  icon: const Icon(Icons.reply, size: 14, color: Color(0xFF114177)),
                                  label: Text(item['adminReply'] == null ? 'Balas' : 'Edit Balasan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, {bool isWarning = false}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isWarning ? const Color(0xFFD94B4B) : const Color(0xFF114177))
              : const Color(0xFFF1EEE7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : (isWarning ? const Color(0xFFD94B4B) : const Color(0xFF45474A)),
            ),
          ),
        ),
      ),
    );
  }
}
