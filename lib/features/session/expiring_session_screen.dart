import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/currency_service.dart';
import 'active_session_screen.dart';
import 'session_checkout_screen.dart';
import '../pin/pin_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/backend/home_backend.dart';

class ExpiringSessionScreen extends StatefulWidget {
  const ExpiringSessionScreen({super.key});

  @override
  State<ExpiringSessionScreen> createState() => _ExpiringSessionScreenState();
}

class _ExpiringSessionScreenState extends State<ExpiringSessionScreen> {
  int _selectedExtIndex = 0;
  String _selectedPaymentMethod = 'ParkSmart Wallet';
  
  late Timer _timer;
  int _remainingSeconds = 581; // 09:41

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '00:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, HomeBackend.instance, CurrencyService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        final bg = isDark ? theme.bg : const Color(0xFFFCF9F2);
        final cardBg = isDark ? theme.card : Colors.white;
        final cardBorder = isDark ? theme.border : const Color(0xFFE5E2DB).withValues(alpha: 0.8);
        final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);
        final textSub = isDark ? theme.textMuted : const Color(0xFF45474A);
        final textMuted = isDark ? theme.textMuted : const Color(0xFF76777B);
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
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
                          decoration: BoxDecoration(
                            color: surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBorder),
                          ),
                          child: Icon(Icons.arrow_back, size: 20, color: textMain),
                        ),
                      ),
                      Text(
                        'Sesi Berakhir Segera',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: HomeBackend.instance.activeSession == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.timer_off_outlined,
                                    size: 40,
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF114177),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Tidak Ada Sesi Hampir Berakhir',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textMain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Peringatan ini akan aktif otomatis ketika waktu sesi parkir Anda tersisa kurang dari 15 menit.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: textSub,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white : const Color(0xFF114177),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Kembali',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ),
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
                        // Warning Card & Countdown
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 176,
                                height: 176,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE07A5F), width: 10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SISA WAKTU',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: textMuted,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Text(
                                      _formattedTime,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: textMain,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.schedule, size: 14, color: Color(0xFFE07A5F)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '16:02 WIB',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFE07A5F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Waktu Parkir Hampir Habis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textMain,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Batas toleransi keluar adalah 16:02 WIB. Perpanjang sekarang untuk menghindari tarif denda overstay otomatis.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: textSub,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Extensions
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PILIHAN PERPANJANGAN CEPAT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textMain,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Tarif normal',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _ExtensionButton(
                                    time: '+30 Menit',
                                    price: CurrencyService.instance.format(2500),
                                    isSelected: _selectedExtIndex == 0,
                                    isDark: isDark,
                                    onTap: () => setState(() => _selectedExtIndex = 0),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ExtensionButton(
                                    time: '+1 Jam',
                                    price: CurrencyService.instance.format(5000),
                                    isSelected: _selectedExtIndex == 1,
                                    isDark: isDark,
                                    onTap: () => setState(() => _selectedExtIndex = 1),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ExtensionButton(
                                    time: '+2 Jam',
                                    price: CurrencyService.instance.format(10000),
                                    isSelected: _selectedExtIndex == 2,
                                    isDark: isDark,
                                    onTap: () => setState(() => _selectedExtIndex = 2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Session Details
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(color: surface, shape: BoxShape.circle),
                                        child: Icon(Icons.local_parking, size: 18, color: textMain),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rincian Parkir Aktif',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textMain,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                                          : const Color(0xFFBBEED4).withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Sesi Berjalan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF004A3E),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: divider, height: 1)),
                              _DetailRow(
                                icon: Icons.pin_drop,
                                label: 'Lokasi Slot',
                                value: '${HomeBackend.instance.activeSession?['location_name'] ?? 'Pakuwon Mall'} • Slot ${HomeBackend.instance.activeSession?['slot_code'] ?? 'A-01'}',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(
                                icon: Icons.directions_car,
                                label: 'Kendaraan',
                                value: '${(HomeBackend.instance.activeSession?['vehicle_desc'] != null && HomeBackend.instance.activeSession!['vehicle_desc'].toString().isNotEmpty) ? HomeBackend.instance.activeSession!['vehicle_desc'] : 'Toyota Land Cruiser'} • ${(HomeBackend.instance.activeSession?['plate_number'] != null && HomeBackend.instance.activeSession!['plate_number'].toString().isNotEmpty) ? HomeBackend.instance.activeSession!['plate_number'] : 'B 1945 RI'}',
                                isDark: isDark,
                              ),
                              Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: divider, height: 1)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet, size: 16, color: textMuted),
                                      const SizedBox(width: 6),
                                      Text('Biaya Saat Ini', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textMuted)),
                                    ],
                                  ),
                                  Text(
                                    CurrencyService.instance.format(9000),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: textMain,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildPaymentLogo(_selectedPaymentMethod, 40),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedPaymentMethod,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textMain,
                                        ),
                                      ),
                                      if (_selectedPaymentMethod == 'ParkSmart Wallet')
                                        Text(
                                          'Saldo Aktif: ${CurrencyService.instance.format(45000)}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF1F4F3C),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => _showPaymentMethodDialog(isDark, cardBg, textMain, cardBorder),
                                child: Text(
                                  'Ubah',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: terracotta,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PinScreen(
                                    nextScreen: ActiveSessionScreen(),
                                    transactionType: 'perpanjangan parkir',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : const Color(0xFF1C1D1F),
                              foregroundColor: isDark ? const Color(0xFF111418) : Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Perpanjang Durasi Parkir',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionCheckoutScreen())),
                            style: TextButton.styleFrom(
                              backgroundColor: surface,
                              foregroundColor: textMain,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                                side: BorderSide(color: cardBorder),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.exit_to_app, size: 18, color: textMuted),
                                const SizedBox(width: 8),
                                Text('Siap Check-out Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 15,
                              color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF004A3E),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Denda overstay otomatis ${CurrencyService.instance.format(5000)}/jam via ParkSmart Wallet',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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

  Widget _buildPaymentLogo(String method, double size) {
    final isDark = ThemeService.instance.isDarkMode;
    if (method == 'ParkSmart Wallet') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E232B) : const Color(0xFFF1EEE7),
          shape: BoxShape.circle,
          border: isDark ? Border.all(color: const Color(0xFF2D3542)) : null,
        ),
        child: Icon(
          Icons.account_balance_wallet,
          color: isDark ? Colors.white : const Color(0xFF020304),
          size: size * 0.5,
        ),
      );
    } else if (method == 'ShopeePay') {
      return Image.asset('assets/images/shopee-pay-seeklogo.png', width: size, height: size, fit: BoxFit.contain);
    } else if (method == 'Gopay') {
      return Image.asset('assets/images/gopay-seeklogo.png', width: size, height: size, fit: BoxFit.contain);
    } else if (method == 'OVO') {
      return Image.asset('assets/images/ovo-seeklogo.png', width: size, height: size, fit: BoxFit.contain);
    }
    return Container(width: size, height: size, color: Colors.grey);
  }

  void _showPaymentMethodDialog(bool isDark, Color cardBg, Color textMain, Color cardBorder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: textMain, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Pilih Metode Pembayaran',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildPaymentOption('ShopeePay', isDark, cardBg, textMain, cardBorder)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPaymentOption('ParkSmart Wallet', isDark, cardBg, textMain, cardBorder)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildPaymentOption('Gopay', isDark, cardBg, textMain, cardBorder)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPaymentOption('OVO', isDark, cardBg, textMain, cardBorder)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String method, bool isDark, Color cardBg, Color textMain, Color cardBorder) {
    bool isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        Navigator.pop(context);
      },
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF2C1E14) : const Color(0xFFFFF7ED)) : (isDark ? const Color(0xFF14181E) : Colors.white),
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : cardBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: method == 'ParkSmart Wallet'
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPaymentLogo(method, 20),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      method,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textMain,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Center(child: _buildPaymentLogo(method, 32)),
      ),
    );
  }
}

class _ExtensionButton extends StatelessWidget {
  final String time;
  final String price;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ExtensionButton({
    required this.time,
    required this.price,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF1E2836) : Colors.white)
        : (isDark ? const Color(0xFF181C23) : const Color(0xFFF6F3EC));
    final borderColor = isSelected
        ? const Color(0xFFE07A5F)
        : (isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB));
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C18);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(
              time,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 2),
            Text(
              price,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFE07A5F) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textSub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF76777B);
    final textMain = isDark ? Colors.white : const Color(0xFF1C1C18);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: textSub),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: textSub)),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: textMain),
        ),
      ],
    );
  }
}
