import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveUsersScreen extends StatefulWidget {
  const ActiveUsersScreen({super.key});

  @override
  State<ActiveUsersScreen> createState() => _ActiveUsersScreenState();
}

class _ActiveUsersScreenState extends State<ActiveUsersScreen> {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PENGAWASAN KENDARAAN AKTIF', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF114177), letterSpacing: 0.5)),
                  Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFF17A18A)),
                      const SizedBox(width: 4),
                      Text('Live Sync', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF17A18A))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Pengemudi di Lokasi', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 14, color: Color(0xFF76777B)),
                  const SizedBox(width: 4),
                  Text('382 Kendaraan Terparkir', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                ],
              ),
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
                          hintText: 'Cari plat nomor atau nama user...',
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
                    _buildFilterChip('Semua (382)', true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Mendekati Waktu (14)', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Overstay (3)', false, isAlert: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Alert Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFDE8E4), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFD94B4B), shape: BoxShape.circle),
                      child: const Icon(Icons.warning_amber, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('3 Kendaraan Melebihi Batas Toleransi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                          const SizedBox(height: 4),
                          Text('Potensi kemacetan sirkulasi di Basement 2. Segera kirim reminder.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFFD94B4B).withValues(alpha: 0.8))),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFD94B4B), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.notifications_active, color: Colors.white, size: 14),
                                const SizedBox(width: 8),
                                Text('Kirim Notifikasi Push Otomatis', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // List
              _buildUserCard(
                initials: 'SP',
                name: 'Sarah Pramudita',
                tier: 'Platinum',
                vehicle: 'Toyota Raize • B 1234 XYZ',
                slot: 'Basement 2, Slot A - 05',
                statusTag: 'Slot Aman (Sisa 34 mnt)',
                statusColor: const Color(0xFF17A18A),
                duration: '1 Jam 24 Mnt',
                fee: 'Rp 9.000',
                actionText: 'Detail Sesi',
                actionStyle: 1, // Outline
              ),
              const SizedBox(height: 16),
              
              _buildUserCard(
                initials: 'DW',
                name: 'Dimas Wicaksono',
                vehicle: 'Honda CR-V • B 8910 KJA',
                slot: 'Basement 1, Slot B - 12',
                statusTag: 'Sisa 5 Menit',
                statusColor: const Color(0xFFE5A33D),
                duration: '2 Jam 55 Mnt',
                fee: 'Rp 18.000',
                actionText: 'Ingatkan User',
                actionStyle: 2, // Highlight Warning
              ),
              const SizedBox(height: 16),

              _buildUserCard(
                initials: 'HG',
                name: 'Hendra Gunawan',
                vehicle: 'BMW 320i • B 2234 RFS',
                slot: 'Basement 2, Slot A - 18',
                statusTag: 'Overstay + 15 Mnt',
                statusColor: const Color(0xFFD94B4B),
                duration: '4 Jam 15 Mnt',
                fee: 'Rp 35.000',
                actionText: 'Panggil Pengemudi',
                actionStyle: 3, // Solid Black
                isAlert: true,
              ),
            ],
          ),

          // Bottom Revenue Panel
          Positioned(
            left: 0, right: 0, bottom: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A18),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: const Color(0xFF1A1A18).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Pendapatan Berjalan', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                        Text('Rp 14.820.000', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {bool isAlert = false}) {
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
          color: isSelected ? Colors.white : (isAlert ? const Color(0xFFD94B4B) : const Color(0xFF45474A)),
        ),
      ),
    );
  }

  Widget _buildUserCard({
    required String initials, required String name, String? tier,
    required String vehicle, required String slot,
    required String statusTag, required Color statusColor,
    required String duration, required String fee,
    required String actionText, required int actionStyle, bool isAlert = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFDF7F5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAlert ? const Color(0xFFF9D8D3) : const Color(0xFFE4DFD5)),
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
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFF1EEE7), shape: BoxShape.circle),
                  child: Center(child: Text(initials, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF45474A)))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                          if (tier != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFE4DFD5), borderRadius: BorderRadius.circular(4)),
                              child: Text(tier, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(vehicle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF76777B))),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: isAlert ? const Color(0xFFD94B4B) : const Color(0xFF76777B)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1EEE7), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      const Icon(Icons.local_parking, size: 12, color: Color(0xFF45474A)),
                      const SizedBox(width: 4),
                      Text(slot, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Icon(isAlert ? Icons.warning_amber : Icons.circle, size: isAlert ? 12 : 6, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusTag, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1EEE7), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Durasi Terparkir', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                      Text(duration, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A18))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimasi Biaya', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF76777B))),
                      Text(fee, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: isAlert ? const Color(0xFFD94B4B) : const Color(0xFF1A1A18))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (actionStyle == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE4DFD5)), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Text(actionText, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF45474A))),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF45474A)),
                      ],
                    ),
                  )
                else if (actionStyle == 2)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFFDF7F5), border: Border.all(color: const Color(0xFFF9D8D3)), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active, size: 14, color: Color(0xFFD94B4B)),
                        const SizedBox(width: 4),
                        Text(actionText, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD94B4B))),
                      ],
                    ),
                  )
                else if (actionStyle == 3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF1A1A18), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(actionText, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
