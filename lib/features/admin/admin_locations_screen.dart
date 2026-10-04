import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
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
            ],
          ),
          const SizedBox(height: 8),
          Text('Lokasi Operasional', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          const SizedBox(height: 16),

          // Top Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DFD5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimasi Pendapatan Bulan Ini', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    const SizedBox(height: 4),
                    Text('Rp 412,5 Jt', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 14, color: Color(0xFF17A18A)),
                        const SizedBox(width: 4),
                        Text('+14.2% MoM', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF17A18A))),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: const Color(0xFF114177).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.payments, color: Color(0xFF114177)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Table Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Daftar Fasilitas Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(12)),
                    child: Text('6 Ditampilkan', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.format_list_bulleted, size: 20, color: Color(0xFF1A1A18)),
                  const SizedBox(width: 12),
                  const Icon(Icons.grid_view, size: 20, color: Color(0xFF76777B)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table Rows (Cards in Mobile)
          _buildLocationCard(
            id: 'LOC-001',
            name: 'Central Park Mall',
            address: 'Jl. Letjen S. Parman • Jakarta Barat',
            type: 'Basement (B1-B3)',
            capacity: '80 Bay',
            ev: '4 EV Fast',
            gate: '4 Gate ANPR',
            status: 'Aktif Normal',
            statusColor: const Color(0xFF17A18A),
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            id: 'LOC-002',
            name: 'Grand Indonesia',
            address: 'Jl. M.H. Thamrin • Jakarta Pusat',
            type: 'Indoor & Outdoor',
            capacity: '120 Bay',
            ev: '8 EV Fast',
            gate: '6 Gate ANPR',
            status: 'Padat (Surge)',
            statusColor: const Color(0xFFE5A33D),
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            id: 'LOC-003',
            name: 'Pacific Place SCBD',
            address: 'SCBD District • Jakarta Selatan',
            type: 'Basement Premium',
            capacity: '45 Bay',
            ev: '12 EV Fast',
            gate: '2 Gate VIP ANPR',
            status: 'Penuh (Full)',
            statusColor: const Color(0xFFD94B4B),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String id, required String name, required String address,
    required String type, required String capacity, required String ev,
    required String gate, required String status, required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4DFD5)),
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
                  width: 24, height: 24,
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE4DFD5)), borderRadius: BorderRadius.circular(6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                      Text(id, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF114177))),
                      const SizedBox(height: 4),
                      Text(address, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 4),
                      Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1EEE7)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Kapasitas', capacity),
                _buildStatItem('Slot EV', ev, icon: Icons.bolt, iconColor: const Color(0xFF006A9A)),
                _buildStatItem('Sensor Gate', gate),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1EEE7)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.grid_view, size: 20, color: Color(0xFF76777B)),
                const SizedBox(width: 16),
                const Icon(Icons.payments, size: 20, color: Color(0xFF76777B)),
                const SizedBox(width: 16),
                const Icon(Icons.edit, size: 20, color: Color(0xFF76777B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {IconData? icon, Color? iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 2),
            ],
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
          ],
        ),
      ],
    );
  }
}
