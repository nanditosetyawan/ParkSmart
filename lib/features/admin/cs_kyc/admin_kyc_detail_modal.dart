import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog untuk mewajibkan input alasan penolakan berkas KTP
Future<String?> showKycRejectReasonDialog(
  BuildContext context, {
  required String applicantName,
  String initialReason = '',
}) async {
  final textController = TextEditingController(text: initialReason);
  String? errorMessage;

  final defaultTemplates = [
    'Foto KTP buram / tidak terbaca jelas',
    'Selfie wajah tidak cocok dengan foto KTP',
    'Sudut KTP terpotong / silau flash',
    'NIK atau data tidak valid / tidak sinkron',
  ];

  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD94B4B), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alasan Penolakan KTP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A18),
                        ),
                      ),
                      Text(
                        'Pemohon: $applicantName',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF76777B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih template cepat atau ketikkan alasan penolakan berkas:',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A)),
                  ),
                  const SizedBox(height: 10),

                  // Quick chips template
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: defaultTemplates.map((template) {
                      final isSelected = textController.text.trim() == template;
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            textController.text = template;
                            errorMessage = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFDE8E4) : const Color(0xFFF1EEE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFD94B4B) : const Color(0xFFE4DFD5),
                              width: isSelected ? 1.2 : 0.8,
                            ),
                          ),
                          child: Text(
                            template,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFFD94B4B) : const Color(0xFF45474A),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // Input Text Area
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    minLines: 2,
                    onChanged: (val) {
                      if (errorMessage != null && val.trim().isNotEmpty) {
                        setDialogState(() => errorMessage = null);
                      }
                    },
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF1A1A18)),
                    decoration: InputDecoration(
                      hintText: 'Wajib tuliskan alasan penolakan berkas di sini...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B)),
                      errorText: errorMessage,
                      errorStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFD94B4B)),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE4DFD5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD94B4B), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(
                  'Batal',
                  style: GoogleFonts.plusJakartaSans(color: const Color(0xFF76777B), fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final reason = textController.text.trim();
                  if (reason.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Alasan penolakan wajib diisi!';
                    });
                    return;
                  }
                  Navigator.pop(ctx, reason);
                },
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                label: Text(
                  'Tolak Berkas',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD94B4B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Modal bottom sheet untuk melihat pratinjau 2 berkas foto KYC pengguna:
/// 1. Foto Dokumen e-KTP Asli (Foto fisik KTP)
/// 2. Foto Selfie Muka Bersama e-KTP (Liveness & verifikasi biometrik)
void showKycDetailModal(
  BuildContext context, {
  required Map<String, dynamic> kyc,
  VoidCallback? onAccept,
  VoidCallback? onReject,
  void Function(String reason)? onRejectWithReason,
  bool canAction = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _KycDetailModalContent(
      kyc: kyc,
      onAccept: onAccept,
      onReject: onReject,
      onRejectWithReason: onRejectWithReason,
      canAction: canAction,
    ),
  );
}

class _KycDetailModalContent extends StatelessWidget {
  final Map<String, dynamic> kyc;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final void Function(String reason)? onRejectWithReason;
  final bool canAction;

  const _KycDetailModalContent({
    required this.kyc,
    this.onAccept,
    this.onReject,
    this.onRejectWithReason,
    this.canAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final status = kyc['status'] ?? 'Menunggu';
    final isPending = status == 'Menunggu';
    final name = kyc['name'] ?? 'Pengguna';
    final nik = kyc['nik'] ?? '-';
    final city = kyc['city'] ?? 'Semarang, Jawa Tengah';
    final dob = kyc['dob'] ?? '01 Januari 2000';
    final address = kyc['address'] ?? 'Jl. Pemuda No. 100';
    final id = kyc['id'] ?? 'KYC-${nik.length >= 4 ? nik.substring(nik.length - 4) : "001"}';
    final submittedAt = kyc['submittedAt'] ?? 'Baru saja';
    final gender = kyc['gender'] ?? 'LAKI-LAKI';

    Color statusColor = isPending
        ? const Color(0xFFE07A5F)
        : (status == 'Disetujui' ? const Color(0xFF17A18A) : const Color(0xFFD94B4B));
    Color statusBg = isPending
        ? const Color(0xFFFDECE7)
        : (status == 'Disetujui' ? const Color(0xFFD1F2EB) : const Color(0xFFFDE8E4));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD5D2CB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pratinjau Berkas KTP & Selfie',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A18),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID Registrasi: $id • Diajukan $submittedAt',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF76777B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status == 'Menunggu' ? 'Menunggu Konfirmasi' : status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Body Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ──────────────────────────────────────────────────────────
                  // FOTO 1: GAMBAR FOTO FISIK E-KTP (DOKUMEN ASLI DARI USER)
                  // ──────────────────────────────────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.document_scanner_rounded,
                    title: '1. Foto Dokumen e-KTP Fisik',
                    subtitle: 'KTP_${nik.substring(0, nik.length > 8 ? 8 : nik.length)}.jpg (1.8 MB)',
                    badgeColor: const Color(0xFF114177),
                  ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => _showZoomDialog(
                      context,
                      title: 'Foto e-KTP Fisik - $name',
                      child: _buildPhysicalKtpCard(name, nik, city, dob, address, gender),
                    ),
                    child: _buildKtpPhotoFrame(
                      context,
                      child: _buildPhysicalKtpCard(name, nik, city, dob, address, gender),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ──────────────────────────────────────────────────────────
                  // FOTO 2: FOTO SELFIE MUKA BERSAMA KTP (DOKUMEN BIOMETRIK)
                  // ──────────────────────────────────────────────────────────
                  _buildSectionHeader(
                    icon: Icons.face_retouching_natural_rounded,
                    title: '2. Foto Selfie Wajah Bersama e-KTP',
                    subtitle: 'SELFIE_HOLDING_KTP_${nik.substring(0, nik.length > 8 ? 8 : nik.length)}.jpg (2.4 MB)',
                    badgeColor: const Color(0xFF17A18A),
                  ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => _showZoomDialog(
                      context,
                      title: 'Foto Selfie bersama e-KTP - $name',
                      child: _buildSelfieCard(name, nik),
                    ),
                    child: _buildSelfiePhotoFrame(
                      context,
                      child: _buildSelfieCard(name, nik),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ──────────────────────────────────────────────────────────
                  // TABEL DATA EKSTRAKSI RESMI DARI IDENTITAS
                  // ──────────────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4DFD5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 16, color: Color(0xFF114177)),
                            const SizedBox(width: 8),
                            Text(
                              'Rincian Data Pendaftar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDataRow('Nomor Induk (NIK)', nik, isBold: true, isCopyable: true),
                        _buildDataRow('Nama Lengkap', name, isBold: true),
                        _buildDataRow('Tempat / Tgl Lahir', '${city.split(',').first}, $dob'),
                        _buildDataRow('Jenis Kelamin', gender),
                        _buildDataRow('Alamat Domisili', address),
                        _buildDataRow('Kota / Wilayah', city),
                        _buildDataRow('Waktu Pengajuan', submittedAt),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          if (canAction && isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final reason = await showKycRejectReasonDialog(
                        context,
                        applicantName: name,
                      );
                      if (reason != null && reason.isNotEmpty && context.mounted) {
                        Navigator.pop(context);
                        kyc['rejectReason'] = reason;
                        if (onRejectWithReason != null) {
                          onRejectWithReason!(reason);
                        } else if (onReject != null) {
                          onReject!();
                        }
                      }
                    },
                    icon: const Icon(Icons.close, size: 16, color: Color(0xFFD94B4B)),
                    label: Text(
                      'Tolak Berkas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD94B4B),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD94B4B), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onAccept != null) onAccept!();
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                    label: Text(
                      'Setujui & Aktifkan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17A18A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD5D2CB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Tutup Pratinjau',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: badgeColor),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A18),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF76777B),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.zoom_in, size: 14, color: Color(0xFF114177)),
            const SizedBox(width: 2),
            Text(
              'Perbesar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF114177),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bingkai foto KTP seolah-olah hasil jepretan kamera user di atas meja
  Widget _buildKtpPhotoFrame(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF37474F)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          child,
          // Viewfinder corner marks
          Positioned(
            top: 4,
            left: 4,
            child: _buildCornerBracket(top: true, left: true),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: _buildCornerBracket(top: true, left: false),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: _buildCornerBracket(top: false, left: true),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildCornerBracket(top: false, left: false),
          ),
          // Watermark tag
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 10, color: Color(0xFF17A18A)),
                  const SizedBox(width: 4),
                  Text(
                    'ORIGINAL SCAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu KTP Indonesia yang realistis dengan chip, pas foto, dan tata letak Dukcapil
  Widget _buildPhysicalKtpCard(
    String name,
    String nik,
    String city,
    String dob,
    String address,
    String gender,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C5364), Color(0xFF203A43), Color(0xFF0F2027)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CA1AF).withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header KTP
          Center(
            child: Column(
              children: [
                Text(
                  'REPUBLIK INDONESIA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'PROVINSI ${city.split(',').last.trim().toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Chip & NIK Row
          Row(
            children: [
              // Smart Chip EMV
              Container(
                width: 24,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.amber.shade200, width: 0.8),
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 10,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF8B6508), width: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NIK : $nik',
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amberAccent, width: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'e-KTP',
                  style: TextStyle(color: Colors.amberAccent, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 12),

          // Body KTP: Fields on Left, Pas Foto on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fields
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ktpItem('Nama', name.toUpperCase()),
                    _ktpItem('Tempat/Tgl Lahir', '${city.split(',').first.toUpperCase()}, $dob'),
                    _ktpItem('Jenis Kelamin', '$gender   Gol. Darah: O'),
                    _ktpItem('Alamat', address.toUpperCase()),
                    _ktpItem('  RT/RW', '004 / 009'),
                    _ktpItem('  Kel/Desa', 'CATURTUNGGAL'),
                    _ktpItem('  Kecamatan', 'DEPOK'),
                    _ktpItem('Agama', 'ISLAM'),
                    _ktpItem('Status Kawin', 'BELUM KAWIN'),
                    _ktpItem('Pekerjaan', 'KARYAWAN SWASTA'),
                    _ktpItem('Kewarganegaraan', 'WNI'),
                    _ktpItem('Berlaku Hingga', 'SEUMUR HIDUP'),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Pas Foto KTP (Latar Belakang Biru Khas KTP)
              Column(
                children: [
                  Container(
                    width: 68,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white38, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 44,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 3,
                          child: Text(
                            'PAS FOTO KTP',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 6.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Tanda Tangan Digital
                  Container(
                    width: 68,
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.gesture, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'Ttd Digital',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 7,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bingkai foto selfie bersama KTP
  Widget _buildSelfiePhotoFrame(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          child,
          // Viewfinder corner marks
          Positioned(
            top: 4,
            left: 4,
            child: _buildCornerBracket(top: true, left: true, color: const Color(0xFF17A18A)),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: _buildCornerBracket(top: true, left: false, color: const Color(0xFF17A18A)),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: _buildCornerBracket(top: false, left: true, color: const Color(0xFF17A18A)),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildCornerBracket(top: false, left: false, color: const Color(0xFF17A18A)),
          ),
        ],
      ),
    );
  }

  /// Kartu visual Selfie Pengguna Memegang Fisik KTP (Biometrik Liveness Card)
  Widget _buildSelfieCard(String name, String nik) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF17A18A).withValues(alpha: 0.3)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Camera Grid Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _CameraGridPainter(),
            ),
          ),

          // Person Selfie Graphic Holding KTP
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Biometric Face Oval Bounding Box
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 106,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: const Color(0xFF17A18A),
                        width: 1.8,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF17A18A).withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF334155),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFFE2E8F0), size: 38),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17A18A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'WAJAH TERDETEKSI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tangan memegang KTP Miniatur di samping wajah
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pan_tool_alt_rounded, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  // KTP Miniatur yang dipegang pengguna
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.amberAccent, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.amberAccent,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'e-KTP: ${nik.substring(0, nik.length > 6 ? 6 : nik.length)}***',
                          style: GoogleFonts.spaceMono(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle, size: 8, color: Color(0xFF17A18A)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top Info Banner: Liveness Passed
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF17A18A), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF17A18A)),
                  const SizedBox(width: 4),
                  Text(
                    'Biometrik Liveness: Lolos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Timestamp Info
          Positioned(
            bottom: 8,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ISO: 200 • F/2.0 • Kamera Depan',
                  style: GoogleFonts.spaceMono(
                    fontSize: 8,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  'Kecocokan Wajah: 98.7%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF17A18A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ktpItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 7.5,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.plusJakartaSans(fontSize: 7.5, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 7.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket({
    required bool top,
    required bool left,
    Color color = Colors.white54,
  }) {
    return SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(
        painter: _CornerBracketPainter(top: top, left: left, color: color),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isBold = false, bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF76777B),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF1A1A18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showZoomDialog(BuildContext context, {required String title, required Widget child}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.5,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final bool top;
  final bool left;
  final Color color;

  _CornerBracketPainter({required this.top, required this.left, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    // Rule of thirds lines
    final oneThirdX = size.width / 3;
    final twoThirdX = size.width * 2 / 3;
    final oneThirdY = size.height / 3;
    final twoThirdY = size.height * 2 / 3;

    canvas.drawLine(Offset(oneThirdX, 0), Offset(oneThirdX, size.height), paint);
    canvas.drawLine(Offset(twoThirdX, 0), Offset(twoThirdX, size.height), paint);
    canvas.drawLine(Offset(0, oneThirdY), Offset(size.width, oneThirdY), paint);
    canvas.drawLine(Offset(0, twoThirdY), Offset(size.width, twoThirdY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
