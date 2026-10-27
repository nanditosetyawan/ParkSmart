import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/file_download_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../../core/utils/ticket_status_helper.dart';
import 'backend/history_detail_backend.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String? id;
  const HistoryDetailScreen({super.key, this.id});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    HistoryDetailBackend.instance.fetchDetail(widget.id);
  }

  Future<void> _downloadReceiptPng() async {
    final backend = HistoryDetailBackend.instance;
    if (!backend.hasData || _isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      // Tunggu frame render selesai
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary = _receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Render boundary tidak ditemukan');
      }

      // Render tampilan ke gambar PNG beresolusi tinggi (pixelRatio 3.0)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Gagal mengonversi gambar ke PNG');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final code = backend.transactionCode.isNotEmpty
          ? backend.transactionCode
          : (widget.id ?? 'bukti');
      final fileName = 'ParkSmart_Bukti_$code.png';

      // Simpan langsung ke Galeri Android via MediaStore (Pictures/ParkSmart)
      bool savedToGallery = false;
      try {
        const channel = MethodChannel('com.example.smart_parking/audio');
        final bool? res = await channel.invokeMethod<bool>('saveImageToGallery', {
          'bytes': pngBytes,
          'fileName': fileName,
        });
        savedToGallery = res == true;
      } catch (e) {
        debugPrint('[HistoryDetailScreen] MethodChannel saveImageToGallery failed: $e');
      }

      // Fallback simpan berkas jika native method belum terjangkau
      String? savedPath;
      if (!savedToGallery) {
        savedPath = await FileDownloadService.instance.downloadPng(pngBytes, fileName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    savedToGallery
                        ? 'Bukti transaksi berhasil disimpan ke Galeri!'.tr
                        : (savedPath != null
                            ? 'Bukti transaksi berhasil diunduh ($fileName)'.tr
                            : 'Bukti transaksi berhasil diekspor'.tr),
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('[HistoryDetailScreen] Error download PNG: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh bukti: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, HistoryDetailBackend.instance, CurrencyService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;
        final backend = HistoryDetailBackend.instance;

        final bg = isDark ? theme.bg : const Color(0xFFFCF9F2);
        final cardBg = isDark ? theme.card : Colors.white;
        final cardBorder = isDark ? theme.border : const Color(0xFFEBE8E1);
        final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);
        final textSub = isDark ? theme.textMuted : const Color(0xFF76777B);
        final surface = isDark ? theme.surfaceField : const Color(0xFFF1EEE7);
        final divider = isDark ? theme.border : const Color(0xFFF1EEE7);
        final terracotta = isDark ? const Color(0xFFE07A5F) : const Color(0xFF9A442D);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: bg.withValues(alpha: 0.9),
                    border: Border(bottom: BorderSide(color: cardBorder.withValues(alpha: 0.6))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
                          child: Icon(Icons.arrow_back, size: 20, color: textMain),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: backend.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                          ),
                        )
                      : !backend.hasData
                          ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF1EEE7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Riwayat Transaksi Tidak Ditemukan',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textMain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ID transaksi tidak valid atau data riwayat parkir belum tercatat.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: textSub,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back, size: 18),
                                  label: const Text('Kembali'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.white : const Color(0xFF020304),
                                    foregroundColor: isDark ? Colors.black : Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RepaintBoundary(
                                key: _receiptKey,
                                child: Container(
                                  color: bg,
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      // Watermark Branding ParkSmart di Gambar Bukti
                                 
                                      const SizedBox(height: 16),
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: textMain,
                                            height: 1.1,
                                            letterSpacing: -0.5,
                                          ),
                                          children: [
                                            TextSpan(text: '${'Detail Transaksi'.tr}\n'),
                                            TextSpan(
                                              text: '#${backend.transactionCode}',
                                              style: TextStyle(
                                                color: terracotta,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Receipt Card
                                      Container(
                                        decoration: BoxDecoration(
                                          color: cardBg,
                                          borderRadius: BorderRadius.circular(28),
                                          border: Border.all(color: cardBorder),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // 1. Status Selesai / Ready / Belum Bayar di paling atas dalam card
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: TicketMark.getBgColor(backend.status, isDark: isDark),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: TicketMark.getBorderColor(backend.status, isDark: isDark),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          TicketMark.getIcon(backend.status),
                                                          size: 14,
                                                          color: TicketMark.getColor(backend.status),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          backend.status.tr,
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700,
                                                            color: TicketMark.getColor(backend.status),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 14),

                                                  // 2. Bawahnya: Nama Gedung
                                                  Text(
                                                    'NAMA GEDUNG'.tr,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: textSub,
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    backend.locationName,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                      color: textMain,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),

                                                  // 3. Bawahnya lagi: Parkirannya (Slot & Alamat tidak 1 line)
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.pin_drop, size: 16, color: terracotta),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          backend.slotInfo,
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                            color: textMain,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 22),
                                                    child: Text(
                                                      backend.locationDetail,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),

                                                  // Total Biaya
                                                  Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                    decoration: BoxDecoration(
                                                      color: isDark ? theme.surfaceField : Colors.white.withValues(alpha: 0.5),
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: isDark ? Border.all(color: cardBorder) : null,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          'TOTAL BIAYA'.tr,
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: textSub,
                                                            letterSpacing: 1.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          CurrencyService.instance.format(backend.totalAmount.toDouble()),
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w800,
                                                            color: textMain,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(color: divider, height: 1),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                              child: Column(
                                                children: [
                                                  _ReceiptRow(
                                                    icon: Icons.schedule,
                                                    label: 'Waktu Parkir'.tr,
                                                    isDark: isDark,
                                                    valueWidget: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          backend.date,
                                                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: textMain),
                                                        ),
                                                        if (backend.checkOutTime.contains('Berlangsung')) ...[
                                                          Text(
                                                            backend.checkInTime,
                                                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: textMain),
                                                          ),
                                                          Text(
                                                            'Sedang Berlangsung'.tr,
                                                            style: GoogleFonts.plusJakartaSans(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                                                            ),
                                                          ),
                                                        ] else ...[
                                                          Text(
                                                            '${backend.checkInTime} - ${backend.checkOutTime}',
                                                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: textMain),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(color: divider, height: 1),
                                                  _ReceiptRow(
                                                    icon: Icons.directions_car,
                                                    label: 'Kendaraan'.tr,
                                                    isDark: isDark,
                                                    valueWidget: Text(
                                                      backend.vehicleInfo.tr,
                                                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: textMain),
                                                    ),
                                                  ),
                                                  Divider(color: divider, height: 1),
                                                  _ReceiptRow(
                                                    icon: Icons.account_balance_wallet,
                                                    label: 'Metode Bayar'.tr,
                                                    isDark: isDark,
                                                    valueWidget: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: isDark ? theme.surfaceField : Colors.white,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(color: isDark ? cardBorder : const Color(0xFFE5E2DB)),
                                                      ),
                                                      child: Text(
                                                        backend.paymentMethod.tr,
                                                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: textMain),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Text(
                                          'Dokumen ini adalah bukti transaksi sah yang diterbitkan oleh sistem ParkSmart • ${backend.date}',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: textSub,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Actions
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isDownloading ? null : _downloadReceiptPng,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F), // reversed!
                                    foregroundColor: isDark ? const Color(0xFF111418) : Colors.white, // reversed!
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                  ),
                                  child: _isDownloading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: isDark ? const Color(0xFF111418) : Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.download, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Unduh Bukti (PNG)',
                                              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
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

class _ReceiptRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget valueWidget;
  final bool isDark;

  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.valueWidget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: subColor),
              const SizedBox(width: 8),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: subColor)),
            ],
          ),
          valueWidget,
        ],
      ),
    );
  }
}
