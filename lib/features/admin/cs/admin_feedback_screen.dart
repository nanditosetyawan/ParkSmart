import '../../../theme/app_theme.dart';
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
      final q = _searchController.text.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          f['user'].toString().toLowerCase().contains(q) ||
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
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Balas Ulasan Pengguna',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        feedback['user'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          feedback['rating'] as int,
                          (_) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${feedback['comment']}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Tanggapan Resmi Admin:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: replyCtrl,
              maxLines: 3,
              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Tulis tanggapan atau solusi untuk customer...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyCtrl.text.trim().isNotEmpty) {
                setState(() {
                  feedback['adminReply'] = replyCtrl.text.trim();
                  feedback['isResolved'] = true;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tanggapan berhasil disimpan!'),
                    backgroundColor: Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Kirim Balasan',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unresolvedCount = _feedbacks.where((f) => f['isResolved'] == false).length;

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F172A)),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feedback & Ulasan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Suara Pengguna & Penanganan Keluhan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
        ),
        body: Column(
          children: [
            // Top Section: Stat Overview & Google-Style Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  // 3 Clean Minimalist Metric Cards
                  Row(
                    children: [
                      _buildStatCard(
                        'Skor Kepuasan',
                        '4.8',
                        extra: const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        'Total Ulasan',
                        '${_feedbacks.length}',
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        'Perlu Ditindak',
                        '$unresolvedCount',
                        isAlert: unresolvedCount > 0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Google-style Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cari ulasan, nama user, lokasi...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                            ),
                          )
                        else
                          const SizedBox(width: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Rating filter chips (Clean Monochrome Style)
            Container(
              height: 52,
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
                  _buildFilterChip('Keluhan (≤ 3★)', 3),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Feedbacks List
            Expanded(
              child: _filteredFeedbacks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada ulasan yang cocok',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredFeedbacks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = _filteredFeedbacks[index];
                        return _buildFeedbackCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Widget? extra, bool isAlert = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isAlert ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isAlert ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                if (extra != null) ...[
                  const SizedBox(width: 4),
                  extra,
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha:0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> item) {
    final int rating = item['rating'] as int;
    final bool isResolved = item['isResolved'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Location & Date, Stars
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: Text(
                  item['avatar'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['user'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${item['location']} · ${item['date']}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (starIdx) {
                  return Icon(
                    starIdx < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: starIdx < rating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // User Review Comment
          Text(
            item['comment'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF1E293B),
              height: 1.45,
            ),
          ),

          // Admin Reply Bubble (if exists)
          if (item['adminReply'] != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.support_agent_rounded, size: 14, color: Color(0xFF0F172A)),
                      const SizedBox(width: 6),
                      Text(
                        'Tanggapan Tim ParkSmart',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['adminReply'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Footer: Status Badge & Reply Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isResolved ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isResolved ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isResolved ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      size: 11,
                      color: isResolved ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isResolved ? 'Selesai Dibalas' : 'Belum Dibalas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isResolved ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _showReplyDialog(item),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item['adminReply'] == null ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item['adminReply'] == null ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item['adminReply'] == null ? Icons.reply_rounded : Icons.edit_note_rounded,
                        size: 13,
                        color: item['adminReply'] == null ? Colors.white : const Color(0xFF0F172A),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item['adminReply'] == null ? 'Balas Ulasan' : 'Edit Balasan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: item['adminReply'] == null ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
