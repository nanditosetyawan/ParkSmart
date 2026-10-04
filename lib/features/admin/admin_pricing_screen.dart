import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, size: 16, color: Color(0xFF114177)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ParkSmart', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                Text('Akun / Admin', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              ],
            ),
          ],
        ),
        actions: [
          const Icon(Icons.notifications_none, color: Color(0xFF45474A)),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBN229OME29oeIA03JEkx6qFXdwAiS9tjF2BpuYl0hvR-KRhMbz_TvFM6WCf8r3FfXONbNsAuRJAFymMuLXfHc9_GTa3l48rS4pmj3LFXkDTJQw34ftZgSowlpEj41hbbTvfBKg3P2JHB5MfmHQNghgDyk3ewQpsqLqxRHecKK3Y9QxSY1Og5axl9wsXmXNuN4ylTP0yU_d0SB-yYJ_riMPPALuIk5G7brwi5Pkb555Yu3zsk6gd9w-'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STRATEGI & SKEMA\nPENDAPATAN', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF114177), letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text('Konfigurasi Tarif', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        const SizedBox(height: 8),
                        Text('Kelola realtime tarif dinamis, slot pengisian daya, dan benefit langganan parkir pintar.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE4DFD5))),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF76777B)),
                        const SizedBox(width: 4),
                        Text('Central Park Mall', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dynamic Pricing Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFF9D8D3), shape: BoxShape.circle),
                      child: const Icon(Icons.electric_bolt, color: Color(0xFFD94B4B)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dynamic Pricing Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                          Text('Peak Hour Multiplier 1.2x berlaku otomatis', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFD94B4B).withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                    const Icon(Icons.info_outline, color: Color(0xFFD94B4B)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5).withValues(alpha: 0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rata-rata\nPendapatan / Slot', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                          const SizedBox(height: 8),
                          Text('Rp 34.200', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward, size: 12, color: Color(0xFF17A18A)),
                              Text(' +14.5% vs pekan lalu', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF17A18A))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5).withValues(alpha: 0.5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Okupansi Jam Sibuk\n(Rata-rata)', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                          const SizedBox(height: 8),
                          Text('89.4%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.warning_amber, size: 12, color: Color(0xFFE5A33D)),
                              Text(' Zona A & B padat', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFFE5A33D))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Schemes Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Skema Tarif Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(8)), child: Text('4 Model', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 8),
                      Text('Okupansi Silabus', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card 1
              _TariffCard(
                icon: Icons.directions_car,
                title: 'Tarif Dasar Mobil',
                subtitle: 'Zona Reguler Parkir Basement & Luar',
                tagText: 'Utama',
                price1Label: 'Jam Pertama', price1Value: 'Rp 5.000',
                price2Label: 'Jam Berikutnya', price2Value: 'Rp 4.000 / jam',
                footerLabel: '15 Menit Free Drop-off',
                footerAction: 'Ubah Tarif',
              ),
              const SizedBox(height: 16),
              
              // Card 2
              _TariffCard(
                icon: Icons.trending_up,
                title: 'Jam Sibuk & Akhir Pekan',
                subtitle: 'Dynamic Surge Multiplier',
                isActive: true,
                price1Label: 'Jadwal Sibuk', price1Value: '17:00 - 21:00 WIB',
                price2Label: 'Hari Berlaku', price2Value: 'Senin - Jumat',
                price3Label: 'Tarif Rencana\nLonjakan', price3Value: '+20% (Rp\n6.000/jam)',
                footerLabel: 'Kompensasi kapasitas otomatis saat >85%.',
              ),
              const SizedBox(height: 16),

              // Card 3
              _TariffCard(
                icon: Icons.ev_station,
                title: 'Tarif Khusus EV Charging',
                subtitle: 'Area Pengisian Lantai B1 (12 Spot)',
                tagIcon: Icons.location_on,
                price1Label: 'Rp 7.500 / jam', price1Value: '',
                price2Label: 'Termasuk daya slow charging 7kW', price2Value: '',
                footerLabel: 'Idle fee: Rp 2.000/10 mnt jika penuh',
                footerAction: 'Kelola Port',
              ),
              const SizedBox(height: 16),

              // Card 4
              _TariffCard(
                icon: Icons.workspace_premium,
                title: 'Paket Member & Langganan',
                subtitle: 'Skema Pengguna Setia & Valet',
                price1Label: 'Gold & Platinum Tier', price1Value: 'Diskon 20%',
                price2Label: 'Valet Smart Pass', price2Value: 'Rp\n50.000\nflat/kunjungan',
              ),

              const SizedBox(height: 24),
              // Ad Prediction
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&q=80&w=1000'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ESTIMASI PROYEKSI', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0)),
                    Text('Pendapatan diprediksi naik +18%', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Dengan konfigurasi dynamic surge 1.2x di titik padat B4.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),

          // Bottom Action
          Positioned(
            left: 20, right: 20, bottom: 20,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A18),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: const Color(0xFF1A1A18).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Tambah Skema Tarif Baru', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TariffCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? tagText;
  final IconData? tagIcon;
  final bool isActive;
  final String price1Label;
  final String price1Value;
  final String price2Label;
  final String price2Value;
  final String? price3Label;
  final String? price3Value;
  final String? footerLabel;
  final String? footerAction;

  const _TariffCard({
    required this.icon, required this.title, required this.subtitle,
    this.tagText, this.tagIcon, this.isActive = false,
    required this.price1Label, required this.price1Value,
    required this.price2Label, required this.price2Value,
    this.price3Label, this.price3Value,
    this.footerLabel, this.footerAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4DFD5)),
        boxShadow: [BoxShadow(color: const Color(0xFF1A1A18).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: const Color(0xFF114177)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      const SizedBox(height: 2),
                      Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                ),
                if (tagText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                    child: Text(tagText!, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                  ),
                if (tagIcon != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                    child: Icon(tagIcon, size: 16, color: const Color(0xFF45474A)),
                  ),
                if (isActive)
                  Switch(value: true, onChanged: (v){}, activeThumbColor: const Color(0xFFD94B4B)),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1EEE7), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price1Label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
                    Text(price1Value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price2Label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
                    Text(price2Value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ],
                ),
                if (price3Label != null && price3Value != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(price3Label!, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF45474A))),
                      Text(price3Value!, textAlign: TextAlign.right, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (footerLabel != null || footerAction != null) ...[
            const Divider(color: Color(0xFFF1EEE7), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Color(0xFF76777B)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(footerLabel ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B)))),
                      ],
                    ),
                  ),
                  if (footerAction != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE4DFD5)), borderRadius: BorderRadius.circular(16)),
                      child: Text(footerAction!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
