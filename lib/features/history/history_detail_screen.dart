import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../../core/utils/ticket_status_helper.dart';
import 'backend/history_detail_backend.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String? id;
  const HistoryDetailScreen({super.key, this.id});

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    HistoryDetailBackend.instance.fetchDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, HistoryDetailBackend.instance]),
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
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
                            child: Icon(Icons.share, size: 19, color: textMain),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
                            child: Icon(Icons.download, size: 19, color: textMain),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: !backend.isLoading && !backend.hasData
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
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          children: [
                            const SizedBox(height: 10),
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
                            const TextSpan(text: 'Detail Transaksi\n'),
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
                                  Text(
                                    'NAMA GEDUNG',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textSub,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    backend.locationName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: terracotta),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          backend.locationDetail,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
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
                                          'TOTAL BIAYA',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: textSub,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Rp ${backend.totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                color: textMain,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: TicketMark.getBgColor(backend.status, isDark: isDark),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: TicketMark.getBorderColor(backend.status, isDark: isDark),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    TicketMark.getIcon(backend.status),
                                                    size: 13,
                                                    color: TicketMark.getColor(backend.status),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    backend.status,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: TicketMark.getColor(backend.status),
                                                    ),
                                                  ),
                                                ],
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
                            Divider(color: divider, height: 1),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Column(
                                children: [
                                  _ReceiptRow(
                                    icon: Icons.schedule,
                                    label: 'Waktu Parkir',
                                    isDark: isDark,
                                    valueWidget: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '24 Oktober 2026',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: textMain),
                                        ),
                                        Text(
                                          '${backend.checkInTime} - ${backend.checkOutTime}',
                                          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: textMain),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(color: divider, height: 1),
                                  _ReceiptRow(
                                    icon: Icons.directions_car,
                                    label: 'Kendaraan',
                                    isDark: isDark,
                                    valueWidget: Text(
                                      backend.vehicleInfo,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: textMain),
                                    ),
                                  ),
                                  Divider(color: divider, height: 1),
                                  _ReceiptRow(
                                    icon: Icons.account_balance_wallet,
                                    label: 'Metode Bayar',
                                    isDark: isDark,
                                    valueWidget: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? theme.surfaceField : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: isDark ? cardBorder : const Color(0xFFE5E2DB)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.payments, size: 15, color: terracotta),
                                          const SizedBox(width: 6),
                                          Text(
                                            backend.paymentMethod,
                                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: textMain),
                                          ),
                                        ],
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

                      // Blockchain Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFF002216),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified_user, size: 20, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Verifikasi Blockchain',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: textMain,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFF002216),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Tervalidasi 100% On-Chain',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? theme.surfaceField : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: cardBorder.withValues(alpha: 0.8)),
                              ),
                              child: Column(
                                children: [
                                  _BlockRow(
                                    label: 'Block Hash',
                                    isDark: isDark,
                                    valueWidget: Row(
                                      children: [
                                        Text(
                                          '0x7f9a...c32d',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: terracotta,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.content_copy, size: 14, color: terracotta),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: divider, height: 1)),
                                  _BlockRow(
                                    label: 'Validator Node',
                                    isDark: isDark,
                                    valueWidget: Text(
                                      'Jakarta Smart City Node #4',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: textMain,
                                      ),
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: divider, height: 1)),
                                  _BlockRow(
                                    label: 'Timestamp',
                                    isDark: isDark,
                                    valueWidget: Text(
                                      '2026-10-24 15:50:12 UTC+7',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.shield, size: 16, color: Color(0xFF17A18A)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Integritas catatan waktu dan pembayaran terenkripsi secara permanen.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: isDark ? theme.textMuted : const Color(0xFF45474A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F), // reversed!
                            foregroundColor: isDark ? const Color(0xFF111418) : Colors.white, // reversed!
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Unduh Bukti PDF',
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

class _BlockRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final bool isDark;

  const _BlockRow({
    required this.label,
    required this.valueWidget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subColor)),
        valueWidget,
      ],
    );
  }
}
