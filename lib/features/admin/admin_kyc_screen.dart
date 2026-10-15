import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminKycScreen extends StatefulWidget {
  const AdminKycScreen({super.key});

  @override
  State<AdminKycScreen> createState() => _AdminKycScreenState();
}

class _AdminKycScreenState extends State<AdminKycScreen> {
  int _selectedTab = 0; // 0=Menunggu, 1=Disetujui, 2=Ditolak

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
            Text('Verifikasi KTP', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Manajemen Identitas Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatBadge('Menunggu', '5', const Color(0xFFE07A5F), const Color(0xFFFDECE7)),
                    const SizedBox(width: 10),
                    _buildStatBadge('Disetujui', '142', const Color(0xFF17A18A), const Color(0xFFD1F2EB)),
                    const SizedBox(width: 10),
                    _buildStatBadge('Ditolak', '8', const Color(0xFFD94B4B), const Color(0xFFFDE8E4)),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _buildTabItem('Menunggu', 0),
                      _buildTabItem('Disetujui', 1),
                      _buildTabItem('Ditolak', 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: _selectedTab == 0
                  ? _buildPendingList()
                  : _selectedTab == 1
                      ? _buildApprovedList()
                      : _buildRejectedList(),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatBadge(String label, String count, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(count, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF1A1A18) : const Color(0xFF76777B))),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPendingList() {
    return [
      _buildKycCard(name: 'Rafi Maulana', nik: '3273011504030001', submittedAt: '15 mnt lalu', status: 'Menunggu', isPending: true),
      const SizedBox(height: 12),
      _buildKycCard(name: 'Siti Rahayu', nik: '3578024507980002', submittedAt: '1 jam lalu', status: 'Menunggu', isPending: true),
      const SizedBox(height: 12),
      _buildKycCard(name: 'Agus Pratama', nik: '3501031806950003', submittedAt: '2 jam lalu', status: 'Menunggu', isPending: true),
      const SizedBox(height: 12),
      _buildKycCard(name: 'Dewi Lestari', nik: '3374056210010004', submittedAt: '3 jam lalu', status: 'Menunggu', isPending: true),
      const SizedBox(height: 12),
      _buildKycCard(name: 'Budi Santoso', nik: '3212012805880005', submittedAt: '5 jam lalu', status: 'Menunggu', isPending: true),
    ];
  }

  List<Widget> _buildApprovedList() {
    return [
      _buildKycCard(name: 'Nanda Setiawan', nik: '3273011504900006', submittedAt: 'Kemarin 14:30', status: 'Disetujui'),
      const SizedBox(height: 12),
      _buildKycCard(name: 'Hana Aulia', nik: '3578024507970007', submittedAt: '2 hari lalu', status: 'Disetujui'),
    ];
  }

  List<Widget> _buildRejectedList() {
    return [
      _buildKycCard(name: 'Joko Widarto', nik: '3501031806800008', submittedAt: '1 minggu lalu', status: 'Ditolak', rejectReason: 'Foto KTP buram / tidak terbaca'),
    ];
  }

  Widget _buildKycCard({required String name, required String nik, required String submittedAt, required String status, bool isPending = false, String? rejectReason}) {
    Color statusColor = status == 'Menunggu' ? const Color(0xFFE07A5F) : status == 'Disetujui' ? const Color(0xFF17A18A) : const Color(0xFFD94B4B);
    Color statusBg = status == 'Menunggu' ? const Color(0xFFFDECE7) : status == 'Disetujui' ? const Color(0xFFD1F2EB) : const Color(0xFFFDE8E4);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(name[0], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF114177)))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      const SizedBox(height: 2),
                      Text('NIK: $nik', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1EEE7), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 14, color: Color(0xFF76777B)),
                    const SizedBox(width: 6),
                    Text('Foto KTP dikirim · $submittedAt', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                  ],
                ),
                if (rejectReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(8)),
                    child: Text('Alasan ditolak: $rejectReason', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFD94B4B))),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.close, size: 16, color: Color(0xFFD94B4B)),
                          label: Text('Tolak', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD94B4B)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check, size: 16, color: Colors.white),
                          label: Text('Setujui', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17A18A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
