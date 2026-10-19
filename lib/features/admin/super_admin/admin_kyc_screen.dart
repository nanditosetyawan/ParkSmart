import '../../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_kyc_detail_modal.dart';
import 'backend/admin_kyc_backend.dart';

class AdminKycScreen extends StatefulWidget {
  const AdminKycScreen({super.key});

  @override
  State<AdminKycScreen> createState() => _AdminKycScreenState();
}

class _AdminKycScreenState extends State<AdminKycScreen> {
  int _selectedTab = 0; // 0=Menunggu, 1=Disetujui, 2=Ditolak
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _kycList => AdminKycBackend.instance.kycList;

  @override
  void initState() {
    super.initState();
    AdminKycBackend.instance.fetchKycList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleKycAction(Map<String, dynamic> item, bool isApproved, [String? rejectReason]) {
    setState(() {
      item['status'] = isApproved ? 'Disetujui' : 'Ditolak';
      if (!isApproved) {
        item['rejectReason'] = (rejectReason != null && rejectReason.isNotEmpty)
            ? rejectReason
            : (item['rejectReason'] ?? 'Dokumen tidak memenuhi standar kejelasan atau biometrik');
      }
    });

    if (isApproved) {
      AdminKycBackend.instance.approveKyc(item['id']);
    } else {
      AdminKycBackend.instance.rejectKyc(item['id'], item['rejectReason'] ?? 'Ditolak oleh admin');
    }

    final actionText = isApproved ? 'disetujui & diverifikasi' : 'ditolak';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendaftaran KTP ${item['name']} telah $actionText${!isApproved && item['rejectReason'] != null ? ' (${item['rejectReason']})' : ''}.'),
        backgroundColor: isApproved ? const Color(0xFF17A18A) : const Color(0xFFD94B4B),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openDetailModal(Map<String, dynamic> kyc) {
    final isPending = kyc['status'] == 'Menunggu';
    showKycDetailModal(
      context,
      kyc: kyc,
      canAction: isPending,
      onAccept: () => _handleKycAction(kyc, true),
      onRejectWithReason: (reason) => _handleKycAction(kyc, false, reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminKycBackend.instance,
      builder: (context, _) {
        final pendingCount = _kycList.where((k) => k['status'] == 'Menunggu').length;
    final approvedCount = _kycList.where((k) => k['status'] == 'Disetujui').length;
    final rejectedCount = _kycList.where((k) => k['status'] == 'Ditolak').length;

    final query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> filteredList;
    if (_selectedTab == 0) {
      filteredList = _kycList.where((k) => k['status'] == 'Menunggu').toList();
    } else if (_selectedTab == 1) {
      filteredList = _kycList.where((k) => k['status'] == 'Disetujui').toList();
    } else {
      filteredList = _kycList.where((k) => k['status'] == 'Ditolak').toList();
    }

    if (query.isNotEmpty) {
      filteredList = filteredList.where((k) {
        final name = (k['name'] ?? '').toString().toLowerCase();
        final nik = (k['nik'] ?? '').toString().toLowerCase();
        final city = (k['city'] ?? '').toString().toLowerCase();
        return name.contains(query) || nik.contains(query) || city.contains(query);
      }).toList();
    }

    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 52,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF1A1A18)),
            ),
          ),
          titleSpacing: 10,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Verifikasi KTP (KYC)', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF14B8A6), width: 0.7),
                    ),
                    child: Text(
                      'BIOMETRIK',
                      style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF0F766E)),
                    ),
                  ),
                ],
              ),
              Text('Pemeriksaan Berkas Identitas & Biometrik Wajah', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE4DFD5)),
          ),
        ),
        body: Column(
          children: [
            // Top Section: Tab Switcher & Search Bar (Konsisten ParkSmart)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                children: [
                  // Tab Switcher Konsisten (Signature ParkSmart Pill Style)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EEE7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTabItem('Menunggu ($pendingCount)', 0),
                        _buildTabItem('Disetujui ($approvedCount)', 1),
                        _buildTabItem('Ditolak ($rejectedCount)', 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Bar Bergaya Google Simple & Elegan (Tanpa Double Border)
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                            decoration: InputDecoration(
                              hintText: 'Cari nama pendaftar, NIK, atau kota...',
                              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
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
                            child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE4DFD5)),

            // KYC List Items (Kaya Visual, Tidak Flat)
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EEE7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedTab == 0
                                  ? Icons.verified_user_outlined
                                  : (_selectedTab == 1 ? Icons.check_circle_outline : Icons.cancel_outlined),
                              size: 32,
                              color: const Color(0xFF76777B),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _selectedTab == 0
                                ? 'Semua berkas KYC telah diproses'
                                : (_selectedTab == 1 ? 'Belum ada berkas KYC disetujui' : 'Tidak ada berkas yang ditolak'),
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tarik ke bawah atau periksa tab kategori lainnya.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildDynamicKycCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  },
);
}

  // ==================== KONSISTEN PARKSMART TAB ITEM ====================
  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
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
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF1A1A18) : const Color(0xFF76777B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DYNAMIC KYC CARD (TIDAK FLAT) ====================
  Widget _buildDynamicKycCard(Map<String, dynamic> item) {
    final name = item['name'] ?? '-';
    final nik = item['nik'] ?? '-';
    final submittedAt = item['submittedAt'] ?? '-';
    final status = item['status'] ?? 'Menunggu';
    final isPending = status == 'Menunggu';
    final isApproved = status == 'Disetujui';
    final rejectReason = item['rejectReason'];

    Color statusColor = isPending
        ? const Color(0xFFEA580C)
        : isApproved
            ? const Color(0xFF16A34A)
            : const Color(0xFFE11D48);

    Color statusBg = isPending
        ? const Color(0xFFFFF7ED)
        : isApproved
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFFFF1F2);

    IconData statusIcon = isPending
        ? Icons.hourglass_top_rounded
        : isApproved
            ? Icons.verified_rounded
            : Icons.cancel_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPending ? const Color(0xFFE4DFD5) : statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          if (isPending)
            BoxShadow(
              color: const Color(0xFFEA580C).withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar Gradient + Info Pendaftar + Status Badge
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Gradien Modern
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Data Pelamar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Badge Status Cantik
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // NIK dengan Tombol Salin
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Text(
                              'NIK: $nik',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF3F3F46), letterSpacing: 0.3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: nik));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('NIK ($nik) berhasil disalin.'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.copy_rounded, size: 13, color: Color(0xFF71717A)),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'ID: ${item['id']}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFFA1A1AA), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Kota & Tanggal Lahir
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF71717A)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item['city']} • ${item['dob']}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF71717A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Waktu Pengajuan tepat di bawah daerah
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF71717A)),
                          const SizedBox(width: 4),
                          Text(
                            'Diajukan: $submittedAt',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF71717A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alasan Ditolak jika ada
          if (rejectReason != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDA4AF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFE11D48)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Alasan Ditolak: $rejectReason',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFFBE123C), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1EEE7)),

          // Action Buttons: Modern & Ergonomis
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 1. Tombol Utama: Detail Berkas KTP & Selfie (Full Width)
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () => _openDetailModal(item),
                    icon: const Icon(Icons.visibility_outlined, size: 15, color: Colors.white),
                    label: Text(
                      'Lihat & Periksa 2 Foto Berkas',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF114177),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),

                // 2. Tombol Keputusan Cepat (Hanya jika Menunggu)
                if (isPending) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Tombol Tolak
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final reason = await showKycRejectReasonDialog(
                                context,
                                applicantName: item['name'] ?? 'Pengguna',
                              );
                              if (reason != null && reason.isNotEmpty) {
                                _handleKycAction(item, false, reason);
                              }
                            },
                            icon: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFDC2626)),
                            label: Text(
                              'Tolak',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
                              backgroundColor: const Color(0xFFFEF2F2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Terima & Setujui
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleKycAction(item, true),
                            icon: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                            label: Text(
                              'Terima & Setujui',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.zero,
                            ),
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
