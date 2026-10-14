import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  String _selectedLocation = 'Central Park Mall';

  final TextEditingController _carFirstHourCtrl = TextEditingController(text: '5000');
  final TextEditingController _carNextHourCtrl = TextEditingController(text: '4000');
  final TextEditingController _carMaxDailyCtrl = TextEditingController(text: '50000');

  final TextEditingController _motorFirstHourCtrl = TextEditingController(text: '2000');
  final TextEditingController _motorNextHourCtrl = TextEditingController(text: '1000');
  final TextEditingController _motorMaxDailyCtrl = TextEditingController(text: '20000');

  final TextEditingController _evKwhCtrl = TextEditingController(text: '2500');
  final TextEditingController _gracePeriodCtrl = TextEditingController(text: '15');
  final TextEditingController _overstayPenaltyCtrl = TextEditingController(text: '10000');

  bool _enableMemberDiscount = true;
  bool _enableWalletCashback = true;

  @override
  void dispose() {
    _carFirstHourCtrl.dispose();
    _carNextHourCtrl.dispose();
    _carMaxDailyCtrl.dispose();
    _motorFirstHourCtrl.dispose();
    _motorNextHourCtrl.dispose();
    _motorMaxDailyCtrl.dispose();
    _evKwhCtrl.dispose();
    _gracePeriodCtrl.dispose();
    _overstayPenaltyCtrl.dispose();
    super.dispose();
  }

  void _savePricing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Konfigurasi tarif untuk $_selectedLocation berhasil diperbarui!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF17A18A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text('Konfigurasi Tarif', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
            Text('Pengaturan Biaya Parkir & Denda Overstay', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Location Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLocation,
                isExpanded: true,
                items: ['Central Park Mall', 'Grand Indonesia', 'Pacific Place SCBD', 'Malioboro Mall', 'Tunjungan Plaza 6'].map((loc) {
                  return DropdownMenuItem(
                    value: loc,
                    child: Row(
                      children: [
                        const Icon(Icons.business, size: 18, color: Color(0xFF114177)),
                        const SizedBox(width: 10),
                        Text(loc, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedLocation = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section 1: Mobil
          _buildTariffSection(
            icon: Icons.directions_car,
            title: 'Tarif Parkir Mobil',
            subtitle: 'Mobil penumpang, SUV, Sedan & City Car',
            color: const Color(0xFF114177),
            bgColor: const Color(0xFFE3EEFF),
            children: [
              _buildInputField('1 Jam Pertama (Rp)', _carFirstHourCtrl),
              const SizedBox(height: 10),
              _buildInputField('Jam Berikutnya / Jam (Rp)', _carNextHourCtrl),
              const SizedBox(height: 10),
              _buildInputField('Maksimal Tarif Harian (Rp)', _carMaxDailyCtrl),
            ],
          ),
          const SizedBox(height: 16),

          // Section 2: Motor
          _buildTariffSection(
            icon: Icons.two_wheeler,
            title: 'Tarif Parkir Sepeda Motor',
            subtitle: 'Motor matic, bebek, motor sport',
            color: const Color(0xFFE07A5F),
            bgColor: const Color(0xFFFDECE7),
            children: [
              _buildInputField('1 Jam Pertama (Rp)', _motorFirstHourCtrl),
              const SizedBox(height: 10),
              _buildInputField('Jam Berikutnya / Jam (Rp)', _motorNextHourCtrl),
              const SizedBox(height: 10),
              _buildInputField('Maksimal Tarif Harian (Rp)', _motorMaxDailyCtrl),
            ],
          ),
          const SizedBox(height: 16),

          // Section 3: EV Charging
          _buildTariffSection(
            icon: Icons.bolt,
            title: 'Slot EV & Pengisian Daya Listrik',
            subtitle: 'Biaya tambahan daya per kWh di slot EV',
            color: const Color(0xFF17A18A),
            bgColor: const Color(0xFFD1F2EB),
            children: [
              _buildInputField('Biaya Tambahan Charging / kWh (Rp)', _evKwhCtrl),
            ],
          ),
          const SizedBox(height: 16),

          // Section 4: Denda & Toleransi Waktu
          _buildTariffSection(
            icon: Icons.timer_outlined,
            title: 'Aturan Toleransi & Overstay',
            subtitle: 'Kebijakan timer check-in & batas waktu parkir',
            color: const Color(0xFFD94B4B),
            bgColor: const Color(0xFFFDE8E4),
            children: [
              _buildInputField('Grace Period Bebas Biaya (Menit)', _gracePeriodCtrl),
              const SizedBox(height: 10),
              _buildInputField('Denda Overstay per Jam (Rp)', _overstayPenaltyCtrl),
            ],
          ),
          const SizedBox(height: 16),

          // Section 5: Program Diskon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Benefit & Diskon Pengguna', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Diskon Langganan Bulanan (10%)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Pengguna dengan status member aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _enableMemberDiscount,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _enableMemberDiscount = v),
                ),
                const Divider(color: Color(0xFFF1EEE7), height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Cashback Bayar via Saldo ParkSmart (5%)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A18))),
                  subtitle: Text('Mendorong pembayaran non-tunai dompet aplikasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  value: _enableWalletCashback,
                  activeThumbColor: const Color(0xFF17A18A),
                  onChanged: (v) => setState(() => _enableWalletCashback = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          ElevatedButton(
            onPressed: _savePricing,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF114177),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_outlined, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text('Simpan Perubahan Tarif', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTariffSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFF1EEE7), height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1EEE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
