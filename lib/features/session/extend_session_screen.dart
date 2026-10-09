import 'package:flutter/material.dart';
import '../pin/pin_screen.dart';
import '../session/active_session_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';

class ExtendSessionScreen extends StatefulWidget {
  const ExtendSessionScreen({super.key});

  @override
  State<ExtendSessionScreen> createState() => _ExtendSessionScreenState();
}

class _ExtendSessionScreenState extends State<ExtendSessionScreen> {
  int _selectedIndex = 1;
  String _selectedPaymentMethod = 'ParkSmart Wallet';

  final List<Map<String, dynamic>> _options = [
    {'title': '+30 Menit', 'cost': 'Rp 3.000', 'time': 'Hingga 16:32 WIB', 'popular': false},
    {'title': '+1 Jam', 'cost': 'Rp 5.000', 'time': 'Hingga 17:02 WIB', 'popular': true},
    {'title': '+2 Jam', 'cost': 'Rp 9.000', 'time': 'Hingga 18:02 WIB', 'popular': false},
    {'title': '+3 Jam', 'cost': 'Rp 13.000', 'time': 'Hingga 19:02 WIB', 'popular': false},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedOption = _options[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C18)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PARKSMART', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D), letterSpacing: 1.5)),
            Text('Extend Parking Session', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), offset: Offset(0, 8), blurRadius: 30)
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
                            Text('Lokasi & Penempatan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Slot A-05', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF020304))),
                        Text('Lantai B2 • Pilar 14', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF45474A))),
                      ],
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                      child: const Icon(Icons.directions_car, color: Color(0xFF1C1D1F)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E2DB))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sisa Waktu Sesi Ini', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                          Text('01:41:19', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF020304))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                            child: Text('Batas Selesai', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                          ),
                          const SizedBox(height: 4),
                          Text('16:02 WIB', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 18, color: Color(0xFF059669)),
                        const SizedBox(width: 8),
                        Text('Toyota Raize • B 1234 XYZ', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                      ],
                    ),
                  
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PILIH DURASI TAMBAHAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
              Text('Maks. +4 Jam', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9A442D))),
            ],
          ),
          const SizedBox(height: 12),
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
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1C1D1F) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? const [
                      BoxShadow(color: Color(0x2E1C1D1F), offset: Offset(0, 10), blurRadius: 24)
                    ] : const [
                      BoxShadow(color: Color(0x0A000000), offset: Offset(0, 4), blurRadius: 10)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        if (option['popular'])
                          Positioned(
                            top: 27, right: -45,
                            child: Transform.rotate(
                              angle: 0.785398,
                              child: Container(
                                width: 160,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                color: const Color(0xFFFC9174),
                                child: Text('POPULER', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF742814), letterSpacing: 1.0)),
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
                                  Text(option['title'], style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF020304))),
                                  Container(
                                    width: 20, height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? const Color(0xFF9A442D) : const Color(0xFFEBE8E1),
                                    ),
                                    child: isSelected ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(option['cost'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF020304))),
                                  Text(option['time'], style: GoogleFonts.plusJakartaSans(fontSize: 11, color: isSelected ? const Color(0xFF858587) : const Color(0xFF45474A))),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WAKTU SELESAI BARU', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                        Row(
                          children: [
                            Text(selectedOption['time'].toString().replaceAll('Hingga ', ''), style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF020304))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFFDBD2), borderRadius: BorderRadius.circular(8)),
                              child: Text('(${selectedOption['title']})', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF3C0800))),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('BIAYA TAMBAHAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A))),
                        Text(selectedOption['cost'], style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E2DB)),
                const SizedBox(height: 16),
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
                            Text(_selectedPaymentMethod, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                            if (_selectedPaymentMethod == 'ParkSmart Wallet')
                              Text('Saldo Aktif: Rp 45.000', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF1F4F3C))),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showPaymentMethodDialog,
                      child: Text('Ubah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Color.fromARGB(255, 45, 46, 47)),
              const SizedBox(width: 12),
              Expanded(child: Text('Perpanjangan otomatis dikonfirmasi tanpa perlu tiket baru.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF45474A)))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PinScreen(nextScreen: ActiveSessionScreen(), transactionType: 'perpanjangan parkir')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF020304),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Konfirmasi & Bayar ${selectedOption['cost']}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLogo(String method, double size) {
    if (method == 'ParkSmart Wallet') {
      return Container(width: size, height: size, decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle), child: Icon(Icons.account_balance_wallet, color: const Color(0xFF020304), size: size * 0.5));
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
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54, size: 24),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text('Pilih Metode Pembayaran', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
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
    bool isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
        Navigator.pop(context);
      },
      child: Container(
        height: 90, // Equal height for all (60 + 50%)
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE5E2DB),
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
                Expanded(child: Text(method, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF1C1C18)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            )
          : Center(child: _buildPaymentLogo(method, 32)),
      ),
    );
  }
}
