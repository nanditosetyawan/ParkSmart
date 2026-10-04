import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
              Text('MANAJEMEN GEDUNG & PARKIR', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF114177), letterSpacing: 0.5)),
              Row(
                children: [
                  const Icon(Icons.cloud_done, size: 14, color: Color(0xFF17A18A)),
                  const SizedBox(width: 4),
                  Text('Sync Cloud Sejauh', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF17A18A))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daftar Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Tambah', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('6 Gedung Rekanan Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4DFD5))),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF76777B), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama mal, gedung, atau area...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF76777B)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua (8)', true),
                const SizedBox(width: 8),
                _buildFilterChip('Mall', false),
                const SizedBox(width: 8),
                _buildFilterChip('Perkantoran', false),
                const SizedBox(width: 8),
                _buildFilterChip('Transit Hub', false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildLocationCard(
            title: 'Central Park Mall',
            subtitle: 'Jakarta Barat • 3 Sektor (B1, B2, B3)',
            status: 'Zaman Online (98%)',
            statusColor: const Color(0xFF17A18A),
            capacity: '650 / 820 Slot (84%)',
            revenue: 'Rp 18.450.000',
            gates: '2 Masuk, 3 Keluar Normal',
            hasAutoBilling: true,
          ),
          const SizedBox(height: 16),
          _buildLocationCard(
            title: 'Grand Indonesia',
            subtitle: 'Jakarta Pusat • East & West Mall',
            status: 'Normal (72%)',
            statusColor: const Color(0xFF114177),
            capacity: '412 / 680 Slot (72%)',
            revenue: 'Rp 24.200.000',
            gates: '4 Masuk, 4 Keluar Normal',
            hasAutoBilling: false,
          ),
          const SizedBox(height: 16),
          _buildLocationCard(
            title: 'Pacific Place SCBD',
            subtitle: 'Jakarta Selatan • SCBD District',
            status: 'Padat (96%)',
            statusColor: const Color(0xFFD94B4B),
            capacity: '310 / 330 Slot (94%)',
            revenue: 'Rp 14.800.000',
            gates: 'Gate Cadangan',
            hasAutoBilling: false,
            isWarning: true,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.settings_input_antenna, color: Color(0xFF17A18A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Infrastruktur IoT', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text('42 Sensor ANPR aktif beroperasi. 4 Gate Barrier terhubung cloud dengan latensi 15ms.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD94B4B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFFD94B4B) : const Color(0xFFE4DFD5)),
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

  Widget _buildLocationCard({
    required String title, required String subtitle, required String status,
    required Color statusColor, required String capacity, required String revenue,
    required String gates, required bool hasAutoBilling, bool isWarning = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4DFD5)),
        boxShadow: [BoxShadow(color: const Color(0xFF1A1A18).withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1573348722427-f1d6819fdf98?auto=format&fit=crop&q=80&w=100'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 6, color: statusColor),
                                const SizedBox(width: 4),
                                Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Color(0xFF76777B)),
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
                    Text('Kapasitas Real-Time', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    Text(capacity, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  ],
                ),
                if (isWarning) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, size: 14, color: Color(0xFFD94B4B)),
                      const SizedBox(width: 4),
                      Text('Sisa 20 Slot Kosong', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pendapatan Hari Ini', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                          Text(revenue, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ANPR Barrier', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF76777B))),
                          Text(gates, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1EEE7), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasAutoBilling)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Color(0xFF17A18A)),
                      const SizedBox(width: 4),
                      Text('Auto Billing Aktif', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF17A18A))),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.sensors, size: 16, color: Color(0xFF76777B)),
                      const SizedBox(width: 4),
                      Text('120 Sensor Kamera aktif', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Text(hasAutoBilling ? 'Kelola Sektor & Slot' : (isWarning ? 'Detail' : 'Kelola Sektor & Slot'), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
