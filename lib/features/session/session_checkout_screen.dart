import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/currency_service.dart';
import '../profile/feedback_screen.dart' as feedback;
import 'backend/session_checkout_backend.dart';

class SessionCheckoutScreen extends StatefulWidget {
  const SessionCheckoutScreen({super.key});

  @override
  State<SessionCheckoutScreen> createState() => _SessionCheckoutScreenState();
}

class _SessionCheckoutScreenState extends State<SessionCheckoutScreen> {
  @override
  void initState() {
    super.initState();
    SessionCheckoutBackend.instance.fetchCheckoutDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, SessionCheckoutBackend.instance, CurrencyService.instance]),
      builder: (context, _) {
        final backend = SessionCheckoutBackend.instance;
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          body: SafeArea(
            child: Column(
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            size: 22,
                            color: isDark ? Colors.white : const Color(0xFF1C1C18),
                          ),
                        ),
                      ),
                      Text(
                        'Selesai Parkir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF181C22) : const Color(0xFFF1EEE7),
                          shape: BoxShape.circle,
                          border: isDark ? Border.all(color: const Color(0xFF2D3542)) : null,
                        ),
                        child: Icon(
                          Icons.verified,
                          size: 20,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF1C1C18),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: !backend.isLoading && !backend.hasSession
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
                                    Icons.no_crash_outlined,
                                    size: 64,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Tidak Ada Kendaraan di Area Parkir',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Saat ini tidak ada sesi parkir aktif yang perlu diselesaikan checkout.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777A),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            children: [
                              // Status Graphic & Thanks
                              Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF047857) : const Color(0xFFF1EEE7),
                                  width: 4,
                                ),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                size: 34,
                                color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF181C22) : const Color(0xFFEBE8E1),
                                borderRadius: BorderRadius.circular(20),
                                border: isDark ? Border.all(color: const Color(0xFF2D3542)) : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B5E20),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${backend.gateExitName} • Siap Keluar',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Terima Kasih, ${backend.userName}.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sesi parkir Anda telah selesai. Palang keluar akan terbuka otomatis saat mendekati ${backend.gateExitName}.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Card Toyota Raize
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF181C22) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF262C36) : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB)),
                                        ),
                                        child: Icon(
                                          Icons.local_parking,
                                          size: 22,
                                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            backend.vehicleName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                            ),
                                          ),
                                          Text(
                                            backend.plateNumber,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: isDark ? Border.all(color: const Color(0xFF2D3542)) : null,
                                    ),
                                    child: Text(
                                      backend.floorName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  color: isDark ? const Color(0xFF2D3542) : const Color(0xFFF1EEE7),
                                  height: 1,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF262C36) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Durasi Total',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                          ),
                                        ),
                                        Text(
                                          'Waktu (WIB)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          backend.totalDuration,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                          ),
                                        ),
                                        Text(
                                          backend.timeRange,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF45474A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Divider(
                                        color: isDark ? const Color(0xFF3B4454) : const Color(0xFFE5E2DB),
                                        height: 1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.pin_drop,
                                          size: 16,
                                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF1C1C18),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${backend.slotCode} • ${backend.locationName}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF45474A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RINCIAN TARIF',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1C1C18),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _ReceiptRow(
                                    label: 'Tarif Parkir (${backend.totalDuration})',
                                    value: CurrencyService.instance.format(backend.parkingRate > 0 ? backend.parkingRate : 10000),
                                  ),
                                  const SizedBox(height: 4),
                                  _ReceiptRow(
                                    label: 'Biaya Sensor ANPR',
                                    value: CurrencyService.instance.format(backend.sensorFee > 0 ? backend.sensorFee : 1000),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Diskon Promo Member',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32),
                                        ),
                                      ),
                                      Text(
                                        '-${CurrencyService.instance.format(backend.discountAmount > 0 ? backend.discountAmount : 2000)}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: List.generate(
                                  30,
                                  (index) => Expanded(
                                    child: Container(
                                      height: 1,
                                      color: index.isEven
                                          ? (isDark ? const Color(0xFF3B4454) : const Color(0xFFC6C6CA))
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Terbayar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                        ),
                                      ),
                                      Text(
                                        CurrencyService.instance.format(backend.totalPayment > 0 ? backend.totalPayment : 9000),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(16),
                                          border: isDark ? Border.all(color: const Color(0xFF047857)) : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.check,
                                              size: 14,
                                              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B5E20),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Lunas',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B5E20),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ParkSmart Pay',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  color: isDark ? const Color(0xFF2D3542) : const Color(0xFFF1EEE7),
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sensors,
                                    size: 16,
                                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B5E20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Gerbang Siap Terbuka • Sensor Aktif',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF1B5E20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol Buka Palang Keluar: tombol hitam jadi putih font color hitam di dark mode
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              await backend.completeSessionCheckout();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const feedback.FeedbackScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Buka Palang Keluar',
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
                        const SizedBox(height: 12),

                        // Tombol Unduh Struk: tombol transparan outline putih font teks putih di dark mode
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isDark ? Colors.transparent : const Color(0xFFF1EEE7),
                              foregroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
                              side: isDark ? const BorderSide(color: Colors.white, width: 1.5) : BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.download,
                                  size: 20,
                                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Unduh Struk / E-Receipt',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
  final String label;
  final String value;
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.instance.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1C1C18),
          ),
        ),
      ],
    );
  }
}
