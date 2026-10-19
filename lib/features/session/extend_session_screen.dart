import '../../core/services/theme_service.dart';
import 'package:flutter/material.dart';
import '../pin/pin_screen.dart';
import '../session/active_session_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'backend/extend_session_backend.dart';

class ExtendSessionScreen extends StatefulWidget {
  const ExtendSessionScreen({super.key});

  @override
  State<ExtendSessionScreen> createState() => _ExtendSessionScreenState();
}

class _ExtendSessionScreenState extends State<ExtendSessionScreen> {
  int _selectedIndex = 1;
  String _selectedPaymentMethod = 'ParkSmart Wallet';

  @override
  void initState() {
    super.initState();
    ExtendSessionBackend.instance.fetchActiveSessionForExtend();
  }

  List<Map<String, dynamic>> get _options => ExtendSessionBackend.instance.options;

  @override
  Widget build(BuildContext context) {
    final selectedOption = _options[_selectedIndex];

    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, ExtendSessionBackend.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          appBar: AppBar(
            backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1C1C18)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PARKSMART',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFB923C) : const Color(0xFF9A442D),
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Extend Parking Session',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1C1C18),
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Top Card Lokasi & Penempatan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181C22) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? Border.all(color: const Color(0xFF2D3542)) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      offset: const Offset(0, 8),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_parking, size: 16, color: Color(0xFF9A442D)),
                                const SizedBox(width: 4),
                                Text(
                                  'Lokasi & Penempatan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ExtendSessionBackend.instance.slotCode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF020304),
                              ),
                            ),
                            Text(
                              ExtendSessionBackend.instance.floorInfo,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF262C36) : const Color(0xFFF1EEE7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: isDark ? Colors.white : const Color(0xFF1C1D1F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262C36) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sisa Waktu Sesi Ini',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                                ),
                              ),
                              Text(
                                ExtendSessionBackend.instance.remainingTimeFormatted,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF020304),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF181C22) : const Color(0xFFF1EEE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Batas Selesai',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ExtendSessionBackend.instance.currentDeadline,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 18, color: Color(0xFF059669)),
                        const SizedBox(width: 8),
                        Text(
                          'Toyota Raize • B 1234 XYZ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1C1C18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Section Pilih Durasi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PILIH DURASI TAMBAHAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                    ),
                  ),
                  Text(
                    'Maks. +4 Jam',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFFB923C) : const Color(0xFF9A442D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grid Durasi: Di-reverse (yang putih jadi hitam, yang hitam jadi putih)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final isSelected = _selectedIndex == index;

                  // Penentuan warna dengan aturan reverse saat dark mode:
                  // Light mode: isSelected = hitam (0xFF1C1D1F), !isSelected = putih (Colors.white)
                  // Dark mode: isSelected = putih (Colors.white), !isSelected = hitam (0xFF181C22)
                  final Color cardBg;
                  final Color titleColor;
                  final Color costColor;
                  final Color timeColor;
                  final Border? cardBorder;

                  if (isDark) {
                    if (isSelected) {
                      cardBg = Colors.white; // yang hitam jadi putih
                      titleColor = const Color(0xFF020304);
                      costColor = const Color(0xFF020304);
                      timeColor = const Color(0xFF5F6368);
                      cardBorder = Border.all(color: Colors.white, width: 1.5);
                    } else {
                      cardBg = const Color(0xFF181C22); // yang putih jadi hitam
                      titleColor = Colors.white;
                      costColor = Colors.white;
                      timeColor = const Color(0xFF94A3B8);
                      cardBorder = Border.all(color: const Color(0xFF2D3542), width: 1);
                    }
                  } else {
                    if (isSelected) {
                      cardBg = const Color(0xFF1C1D1F);
                      titleColor = Colors.white;
                      costColor = Colors.white;
                      timeColor = const Color(0xFF858587);
                      cardBorder = null;
                    } else {
                      cardBg = Colors.white;
                      titleColor = const Color(0xFF020304);
                      costColor = const Color(0xFF020304);
                      timeColor = const Color(0xFF45474A);
                      cardBorder = null;
                    }
                  }

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: cardBorder,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.18),
                                  offset: const Offset(0, 10),
                                  blurRadius: 24,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            // Pita POPULER: Tetap jangan ubah warna
                            if (option['popular'])
                              Positioned(
                                top: 27,
                                right: -45,
                                child: Transform.rotate(
                                  angle: 0.785398,
                                  child: Container(
                                    width: 160,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 3),
                                    color: const Color(0xFFFC9174),
                                    child: Text(
                                      'POPULER',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF742814),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        option['title'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: titleColor,
                                        ),
                                      ),
                                      // Radio button: Warna tetap jangan ubah
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? const Color(0xFF9A442D) // Tetap 0xFF9A442D
                                              : (isDark ? const Color(0xFF333842) : const Color(0xFFEBE8E1)),
                                        ),
                                        child: isSelected
                                            ? Center(
                                                child: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white, // Tetap dot putih
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['cost'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: costColor,
                                        ),
                                      ),
                                      Text(
                                        option['time'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: timeColor,
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
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Bottom Card Detail Waktu Selesai & Metode Pembayaran (Warna sama dengan card sisa waktu)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262C36) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WAKTU SELESAI BARU',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  selectedOption['time'].toString().replaceAll('Hingga ', ''),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF020304),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF451A14) : const Color(0xFFFFDBD2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '(${selectedOption['title']})',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFFFF8C68) : const Color(0xFF3C0800),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'BIAYA TAMBAHAN',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedOption['cost'],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFFB923C) : const Color(0xFF9A442D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        color: isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB),
                      ),
                    ),
                    Row(
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
                                    color: isDark ? Colors.white : const Color(0xFF1C1C18),
                                  ),
                                ),
                                if (_selectedPaymentMethod == 'ParkSmart Wallet')
                                  Text(
                                    'Saldo Aktif: Rp 45.000',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF1F4F3C),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _showPaymentMethodDialog,
                          child: Text(
                            'Ubah',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF45474A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: isDark ? const Color(0xFF94A3B8) : const Color.fromARGB(255, 45, 46, 47),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Perpanjangan otomatis dikonfirmasi tanpa perlu tiket baru.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF45474A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await ExtendSessionBackend.instance.extendSession(
                      optionIndex: _selectedIndex,
                      paymentMethod: _selectedPaymentMethod,
                    );
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PinScreen(
                            nextScreen: ActiveSessionScreen(),
                            transactionType: 'perpanjangan parkir',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : const Color(0xFF020304),
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Konfirmasi & Bayar ${selectedOption['cost']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          color: isDark ? const Color(0xFF181C22) : const Color(0xFFF1EEE7),
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

  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E232B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isDark ? const BorderSide(color: Color(0xFF2D3542)) : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      'Pilih Metode Pembayaran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
                      ),
                    ),
                    const SizedBox(width: 24), // balance it out
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildPaymentOption('ShopeePay')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPaymentOption('ParkSmart Wallet')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildPaymentOption('Gopay')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPaymentOption('OVO')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String method) {
    final theme = ThemeService.instance;
    final isDark = theme.isDarkMode;
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
          color: isSelected
              ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFFF7ED))
              : (isDark ? const Color(0xFF262C36) : Colors.white),
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : (isDark ? const Color(0xFF2D3542) : const Color(0xFFE5E2DB)),
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
                        color: isDark ? Colors.white : const Color(0xFF1C1C18),
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
