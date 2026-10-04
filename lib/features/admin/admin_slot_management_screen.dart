import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlotManagementScreen extends StatefulWidget {
  const SlotManagementScreen({super.key});

  @override
  State<SlotManagementScreen> createState() => _SlotManagementScreenState();
}

class _SlotManagementScreenState extends State<SlotManagementScreen> {
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
      body: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('KONTROL REAL-TIME', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF114177), letterSpacing: 0.5)),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFF17A18A)),
                  const SizedBox(width: 4),
                  Text('Live 120Hz', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF17A18A))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Denah & Status Slot', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 4),
          Text('Pemantauan okupansi sensor gerbang & kamera ANPR', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF76777B), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lokasi Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                      Text('Central Park Mall - B2', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more, color: Color(0xFF45474A)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab('Basement 1', false),
                const SizedBox(width: 8),
                _buildTab('Basement 2', true),
                const SizedBox(width: 8),
                _buildTab('Basement 3', false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RINGKASAN OKUPANSI', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF76777B))),
              Text('Total 174 Petak', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildOccupancyStat('Tersedia', '28', '16% Kosong', const Color(0xFF17A18A))),
              const SizedBox(width: 8),
              Expanded(child: _buildOccupancyStat('Terisi', '142', '82% Parkir', const Color(0xFF1A1A18))),
              const SizedBox(width: 8),
              Expanded(child: _buildOccupancyStat('Khusus', '4', 'Hold / Servis', const Color(0xFFD94B4B))),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Zona Dekat Lift Lobby', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('5 Petak Utama', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 12),
          _buildSlotRow('A1', 'B 1984 VLD', 'Honda CR-V', 'Durasi: 1j 42m • ANPR Valid', true, false, false, false),
          _buildSlotRow('A2', 'B 8201 CP', 'BMW 330i', 'Durasi: 48m • ANPR Valid', true, false, false, false),
          _buildSlotRow('A3', 'Slot Tersedia', '', 'Sensor ANPR Ready • Slot Reguler', false, false, false, true),
          _buildSlotRow('A4', 'B 2941 TZA', 'Innova Zenix', 'Durasi: 2j 11m • ANPR Valid', true, false, false, false),
          _buildSlotRow('A5', 'Sarah Pramudita', 'Toyota Raize @ 10:42', 'VIP App', true, true, false, false,
            bottomAlert: 'ETA Kedatangan 14:00 WIB (sisa 8 mnt) Tahan Slot'
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jalur Tengah & Akses EV Charger', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Text('4 Petak Khusus', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 12),
          _buildSlotRow('B1', 'B 7109 WL', 'Wuling Air EV', 'Pengisian Daya 68% • Port 22kW', true, false, true, false),
          _buildSlotRow('B2', 'Tersedia (Khusus EV)', '', 'Ultra Fast Charger 50kW Siap Pakai', false, false, true, true),
          _buildSlotRow('B3', 'Pemeliharaan', '', 'Sensor ANPR perlu kalibrasi sudut', false, false, false, false, isMaintenance: true),
          _buildSlotRow('B4', 'Slot Tersedia', '', 'Dekat pintu keluar jalur barat', false, false, false, true),
          
          const SizedBox(height: 24),
          // Floating Action Bottom Sheet snippet
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE4DFD5)),
              boxShadow: [BoxShadow(color: const Color(0xFF1A1A18).withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.warning_amber, color: Color(0xFFD94B4B), size: 16),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AKSI CEPAT PETAK', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                            Text('Slot A-05 (Sarah P.)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.close, color: Color(0xFF76777B), size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Teruskan instruksi manual sistem jika terjadi kendala verifikasi pelat nopol otomatis di palang gate masuk.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF45474A))),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh, size: 16, color: Color(0xFF45474A)),
                      const SizedBox(width: 8),
                      Text('Reset Sensor ANPR A-05', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE4DFD5)), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.block, size: 16, color: Color(0xFFD94B4B)),
                            const SizedBox(width: 8),
                            Text('Blokir Slot', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Tandai Selesai', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1A18) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF1A1A18) : const Color(0xFFE4DFD5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF45474A),
        ),
      ),
    );
  }

  Widget _buildOccupancyStat(String title, String count, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 6, color: color),
              const SizedBox(width: 4),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
            ],
          ),
          const SizedBox(height: 4),
          Text(count, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 9, color: const Color(0xFF76777B))),
        ],
      ),
    );
  }

  Widget _buildSlotRow(String slotId, String plateOrName, String vehicleDesc, String statusDesc, bool isOccupied, bool isReserved, bool isEV, bool isAvailable, {bool isMaintenance = false, String? bottomAlert}) {
    Color bgCard = isOccupied ? Colors.white : (isMaintenance ? const Color(0xFFFDF7F5) : const Color(0xFFF4FAF9));
    if (isReserved) bgCard = const Color(0xFFFDE8E4).withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isReserved ? const Color(0xFFF9D8D3) : (isOccupied ? const Color(0xFFE4DFD5) : (isAvailable ? const Color(0xFFD1F2EB) : const Color(0xFFF9D8D3)))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isReserved ? const Color(0xFFD94B4B) : const Color(0xFFF1EEE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(slotId[0], style: GoogleFonts.plusJakartaSans(fontSize: 10, color: isReserved ? Colors.white : const Color(0xFF76777B))),
                        Text(slotId.substring(1), style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: isReserved ? Colors.white : const Color(0xFF1A1A18))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isOccupied) ...[
                        Row(
                          children: [
                            if (isReserved)
                              Text(plateOrName, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18)))
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(4)),
                                child: Text(plateOrName, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                              ),
                            const SizedBox(width: 8),
                            if (!isReserved) Text(vehicleDesc, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                            if (isReserved)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(4)),
                                child: Text('VIP App', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                              ),
                          ],
                        ),
                        if (isReserved)
                          Text(vehicleDesc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                        const SizedBox(height: 4),
                        Text(statusDesc, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF45474A))),
                      ] else ...[
                        Text(plateOrName, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: isMaintenance ? const Color(0xFFD94B4B) : const Color(0xFF1A1A18))),
                        const SizedBox(height: 4),
                        Text(statusDesc, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                      ],
                    ],
                  ),
                ),
                if (isReserved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFD94B4B), borderRadius: BorderRadius.circular(20)),
                    child: Text('Reserved\nAktif', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                else if (isEV)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: isAvailable ? const Color(0xFFD1F2EB) : const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Icon(isAvailable ? Icons.ev_station : Icons.bolt, size: 14, color: isAvailable ? const Color(0xFF17A18A) : const Color(0xFFD94B4B)),
                        const SizedBox(width: 4),
                        Text(isAvailable ? 'EV\nReady' : 'Charging', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: isAvailable ? const Color(0xFF17A18A) : const Color(0xFFD94B4B))),
                      ],
                    ),
                  )
                else if (isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1F2EB)), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: Color(0xFF17A18A)),
                        const SizedBox(width: 4),
                        Text('Tersedia', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF17A18A))),
                      ],
                    ),
                  )
                else if (isMaintenance)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.build, size: 12, color: Color(0xFFD94B4B)),
                        const SizedBox(width: 4),
                        Text('Servis', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, size: 12, color: Color(0xFF45474A)),
                        const SizedBox(width: 4),
                        Text('Terisi', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (bottomAlert != null) ...[
            const Divider(color: Color(0xFFF9D8D3), height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFDF7F5),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 12, color: Color(0xFFD94B4B)),
                  const SizedBox(width: 4),
                  Text(bottomAlert, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFFD94B4B))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
