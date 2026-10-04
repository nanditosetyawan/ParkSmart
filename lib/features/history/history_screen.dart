import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_detail_screen.dart' as history_detail;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2).withValues(alpha: 0.85),
                border: Border(bottom: BorderSide(color: const Color(0xFFE5E2DB).withValues(alpha: 0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('PARKSMART PORTAL', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF9A442D), letterSpacing: 0.5)),
                          const SizedBox(width: 6),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Halo, Sarah', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18), letterSpacing: -0.5)),
                      Text('Riwayat Transaksi Parkir', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_today, size: 22, color: Color(0xFF1C1C18)),
                      ),
                      const SizedBox(width: 8),
                      Stack(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: const DecorationImage(image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBN229OME29oeIA03JEkx6qFXdwAiS9tjF2BpuYl0hvR-KRhMbz_TvFM6WCf8r3FfXONbNsAuRJAFymMuLXfHc9_GTa3l48rS4pmj3LFXkDTJQw34ftZgSowlpEj41hbbTvfBKg3P2JHB5MfmHQNghgDyk3ewQpsqLqxRHecKK3Y9QxSY1Og5axl9wsXmXNuN4ylTP0yU_d0SB-yYJ_riMPPALuIk5G7brwi5Pkb555Yu3zsk6gd9w-'), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFAF7F2), width: 2)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Semua', count: '12', isSelected: _selectedFilter == 'all',
                          onTap: () => setState(() => _selectedFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Selesai', isSelected: _selectedFilter == 'selesai',
                          onTap: () => setState(() => _selectedFilter = 'selesai'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Sedang Berjalan', isSelected: _selectedFilter == 'berjalan',
                          onTap: () => setState(() => _selectedFilter = 'berjalan'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Dibatalkan', isSelected: _selectedFilter == 'dibatalkan',
                          onTap: () => setState(() => _selectedFilter = 'dibatalkan'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Cards
                  if (_selectedFilter == 'all' || _selectedFilter == 'selesai') ...[
                    _HistoryCard(
                      mallName: 'Central Park Mall', date: 'Hari Ini, 24 Okt • 14:02', status: 'Lunas', statusColor: const Color(0xFF059669),
                      duration: '1 Jam 48 Mnt', slot: 'Slot A-05', price: 'Rp 9.000', icon: Icons.local_parking,
                    ),
                    const SizedBox(height: 16),
                    _HistoryCard(
                      mallName: 'Grand Indonesia', date: '21 Okt 2026 • 18:30', status: 'Selesai', statusColor: const Color(0xFF059669),
                      duration: '3 Jam', slot: 'Slot C-14', price: 'Rp 18.000', icon: Icons.garage,
                    ),
                    const SizedBox(height: 16),
                    _HistoryCard(
                      mallName: 'Pacific Place SCBD', date: '18 Okt 2026 • 10:15', status: 'Selesai', statusColor: const Color(0xFF059669),
                      duration: '1 Jam', slot: 'Slot B-02 (EV)', price: 'Rp 15.000', icon: Icons.electric_car, isEv: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? count;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FilterChip({required this.label, this.count, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36, padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C1D1F) : const Color(0xFFF1EEE7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF45474A))),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(count!, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String mallName;
  final String date;
  final String status;
  final Color statusColor;
  final String duration;
  final String slot;
  final String price;
  final IconData icon;
  final bool isEv;

  const _HistoryCard({
    required this.mallName, required this.date, required this.status, required this.statusColor,
    required this.duration, required this.slot, required this.price, required this.icon, this.isEv = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const history_detail.HistoryDetailScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEBE8E1)),
        boxShadow: [BoxShadow(color: const Color(0xFF1C1D1F).withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFF6F3EC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEBE8E1))),
                    child: Icon(icon, size: 24, color: const Color(0xFF1C1C18)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mallName, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 14, color: Color(0xFF76777B)),
                          const SizedBox(width: 4),
                          Text(date, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFA7F3D0).withValues(alpha: 0.6))),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF065F46))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFFAF7F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEBE8E1).withValues(alpha: 0.8))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Durasi', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: Color(0xFF76777B)),
                          const SizedBox(width: 4),
                          Text(duration, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Slot & Area', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(isEv ? Icons.bolt : Icons.pin_drop, size: 16, color: isEv ? const Color(0xFF059669) : const Color(0xFF9A442D)),
                          const SizedBox(width: 4),
                          Text(slot, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1C1C18))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1EEE7), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Pembayaran', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF76777B))),
                  Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1C1C18), letterSpacing: -0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF6F3EC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E2DB))),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 15, color: Color(0xFF047857)),
                    const SizedBox(width: 6),
                    Text('Verified by Blockchain', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF45474A))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
